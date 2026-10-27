extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")

var failures := 0


func _initialize() -> void:
	call_deferred("_capture_layouts")


func _capture_layouts() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	var save_path := ProjectSettings.globalize_path("res://tests/_reboot_ui_capture_%d.json" % Time.get_ticks_usec())
	main.save_path = save_path
	main.loaded_save_path = ""
	main.director.economy.credits = 600
	main.director.economy.recruit_level = 1
	main.director.highest_cleared_wave = 0
	main._refresh()
	var baseline_permanent: Dictionary = main.permanent_state.duplicate(true)
	var baseline_influence: int = main.director.lifetime_influence
	await process_frame
	var buttons: Array[Button] = []
	_collect_buttons(main, buttons)
	var upgrade_single := _find_button(buttons, "Upgrade x1")
	var upgrade_ten := _find_button(buttons, "Upgrade x10")
	for size in [Vector2i(800, 450), Vector2i(1280, 720)]:
		main.permanent_state = baseline_permanent.duplicate(true)
		main.director.set_lifetime_influence(baseline_influence)
		main.director.wave = 1
		main.director.highest_cleared_wave = 0
		main.director.economy.credits = 600
		main.director.economy.recruit_level = 1
		main.loaded_save_path = ""
		main._refresh()
		main.feedback_label.text = ""
		root.size = size
		main._apply_responsive_hud_scale()
		await process_frame
		await process_frame
		_check(upgrade_single != null and upgrade_ten != null, "Upgrade x1/x10 controls exist at %dx%d." % [size.x, size.y])
		_check(str(main.stats_label.text).contains("TRIAL UPGRADE COST x1 20 / x10 349 CREDITS"), "Level-1 x1 and x10 trial costs are visible at %dx%d." % [size.x, size.y])
		_check(str(main.stats_label.text).to_lower().contains("trial"), "Upgrade cost should be explicitly labeled as a trial value at %dx%d." % [size.x, size.y])
		_check(not upgrade_single.disabled and not upgrade_ten.disabled, "Upgrade controls are enabled at %dx%d." % [size.x, size.y])
		_check(main.reboot_button.disabled and main.reboot_button.text.contains("LOCKED UNTIL WAVE 25 CLEAR"), "Reboot is locked before wave 25 at %dx%d." % [size.x, size.y])
		_check(_control_inside(main.hud_panel, size) and _control_inside(upgrade_single, size) and _control_inside(upgrade_ten, size) and _control_inside(main.reboot_button, size), "HUD, Upgrade, and Reboot bounds fit %dx%d." % [size.x, size.y])
		_capture("upgrade_locked_%dx%d" % [size.x, size.y], size)
		main.director.highest_cleared_wave = 25
		main._refresh()
		_check(not main.reboot_button.disabled and main.reboot_button.text == "SYSTEM REBOOT — READY", "Reboot is ready at wave 25 at %dx%d." % [size.x, size.y])
		var old_mode: int = main.director.process_mode
		main.director.process_mode = Node.PROCESS_MODE_DISABLED
		var run_before: Dictionary = main.director.snapshot()
		var permanent_before: Dictionary = main.permanent_state.duplicate(true)
		main._request_reboot_confirmation()
		await process_frame
		_check(main.reboot_confirmation.visible, "Reboot confirmation is visible at %dx%d." % [size.x, size.y])
		_check(_window_inside(main.reboot_confirmation, size), "Reboot confirmation is within bounds at %dx%d." % [size.x, size.y])
		_check(main.reboot_confirmation.get_ok_button().visible and main.reboot_confirmation.get_cancel_button().visible, "Confirm and Cancel are accessible at %dx%d." % [size.x, size.y])
		_check(_contains_dialog_copy(main.reboot_confirmation), "Reboot consequences are present in the dialog at %dx%d." % [size.x, size.y])
		_capture("reboot_confirmation_%dx%d" % [size.x, size.y], size)
		main.reboot_confirmation.get_cancel_button().pressed.emit()
		await process_frame
		_check(not main.reboot_confirmation.visible and main.director.snapshot() == run_before and main.permanent_state == permanent_before, "Cancel preserves state at %dx%d." % [size.x, size.y])
		_check(not FileAccess.file_exists(save_path), "Cancel creates no save at %dx%d." % [size.x, size.y])
		main._request_reboot_confirmation()
		await process_frame
		main.reboot_confirmation.get_ok_button().pressed.emit()
		await process_frame
		main.director.process_mode = old_mode
		_check(main.director.wave == 1 and main.director.economy.recruit_level == 1 and main.director.economy.credits == 0, "Confirm applies the reset at %dx%d." % [size.x, size.y])
		var saved := SAVE_SCRIPT.load_game(save_path)
		_check(bool(saved.get("ok", false)) and int(saved.get("data", {}).get("run", {}).get("wave", 0)) == 1, "Confirm persists the reset at %dx%d." % [size.x, size.y])
		_remove_save(save_path)
		main.director.highest_cleared_wave = 0
		main.director.wave = 1
		main._refresh()
	main.queue_free()
	if failures == 0:
		print("PASS: Upgrade/Reboot UI at 800x450 and 1280x720.")
		quit(0)
	else:
		push_error("%d Upgrade/Reboot UI assertion(s) failed." % failures)
		quit(1)


func _capture(name: String, size: Vector2i) -> void:
	var image := root.get_texture().get_image()
	if image.get_size() != size:
		_check(false, "Capture %s size mismatch: %s." % [name, str(image.get_size())])
		return
	var path := ProjectSettings.globalize_path("res://tests/%s.png" % name)
	_check(image.save_png(path) == OK, "Capture save failed: %s." % path)
	print("UI_CAPTURE=%s" % path)


func _collect_buttons(node: Node, out: Array[Button]) -> void:
	if node is Button:
		out.append(node as Button)
	for child in node.get_children():
		_collect_buttons(child, out)


func _find_button(buttons: Array[Button], label: String) -> Button:
	for button in buttons:
		if button.text == label:
			return button
	return null


func _control_inside(control: Control, size: Vector2i) -> bool:
	if control == null:
		return false
	var rect := control.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, control.size)
	return Rect2(Vector2.ZERO, Vector2(size)).encloses(rect)


func _window_inside(window: Window, size: Vector2i) -> bool:
	var canvas_scale := minf(float(size.x) / 1280.0, float(size.y) / 720.0)
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(size))
	var dialog_rect := Rect2(Vector2(window.position) * canvas_scale, Vector2(window.size) * canvas_scale)
	return viewport_rect.encloses(dialog_rect)


func _contains_dialog_copy(dialog: Node) -> bool:
	return (dialog as ConfirmationDialog).dialog_text.contains("Reboot resets") and (dialog as ConfirmationDialog).dialog_text.contains("Permanent Influence")


func _labels(node: Node) -> Array[Label]:
	var result: Array[Label] = []
	if node is Label:
		result.append(node as Label)
	for child in node.get_children():
		result.append_array(_labels(child))
	return result


func _remove_save(path: String) -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		if FileAccess.file_exists(path + suffix):
			var err := DirAccess.remove_absolute(path + suffix)
			_check(err == OK, "Disposable save cleanup failed for %s." % (path + suffix))


func _check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("UI CAPTURE TEST FAILED: " + message)
