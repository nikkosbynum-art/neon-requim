extends SceneTree

## Read-only visual review of the roster Evolution dialog. No purchase or save is performed.
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const TARGET_SIZES := [Vector2i(1280, 720), Vector2i(800, 450)]
const EVOLUTION_SCRIPT := preload("res://scripts/progression/evolution_service.gd")
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	_check(main_scene != null, "Could not load the main scene for Evolution dialog review.")
	var output_dir := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	_check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "Could not create visual QA output directory.")
	if failures > 0 or main_scene == null:
		quit(1)
		return

	var root_window := get_root()
	var original_size := root_window.size
	var main := main_scene.instantiate()
	root.add_child(main)
	main.permanent_state["highest_wave_ever"] = 25
	main.permanent_state["evolution_materials"]["evolution_data"] = 12
	main.permanent_state["evolution"] = {"breaker_tier": "Origin Form"}
	for recruit_value in EVOLUTION_SCRIPT.APPROVED_RECRUIT_IDS:
		var recruit_id := str(recruit_value)
		main.permanent_state["evolution"]["%s_tier" % recruit_id] = "Origin Form"
	main._show_evolution_dialog()

	for target_size in TARGET_SIZES:
		root_window.size = target_size
		await process_frame
		await create_timer(0.25).timeout
		_check(main.evolution_dialog.visible and main.evolution_rows.size() == 12, "Evolution dialog should show all twelve rows at %s." % str(target_size))
		_check(_all_rows_ready(main), "At wave 25 with 12 shared Evolution Data, every recruit should show the ready gate at %s." % str(target_size))
		_capture(root_window, target_size, "READY")

		if target_size == Vector2i(800, 450):
			var scroll := main.evolution_dialog.find_child("EvolutionRosterScroll", true, false) as ScrollContainer
			_check(scroll != null, "The small viewport should retain the roster's scroll navigation.")
			if scroll != null:
				scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
				await process_frame
				var final_row: Control = main.evolution_rows["glitch"]["progress_label"]
				var visible_list_rect: Rect2 = scroll.get_global_rect()
				var last_row_rect: Rect2 = final_row.get_global_rect()
				_check(visible_list_rect.intersects(last_row_rect), "Scrolling the small viewport should bring the final recruit row into view.")
				_capture(root_window, target_size, "READY_SCROLL_BOTTOM")
				scroll.scroll_vertical = 0
				await process_frame

		main.permanent_state["highest_wave_ever"] = 24
		main._refresh_evolution_dialog()
		await process_frame
		_check(_all_rows_locked(main), "Below wave 25, every Adapted Form action should visibly report a locked gate at %s." % str(target_size))
		_capture(root_window, target_size, "LOCKED")
		main.permanent_state["highest_wave_ever"] = 25
		main._refresh_evolution_dialog()

	_check(int(main.permanent_state["evolution_materials"]["evolution_data"]) == 12, "Visual review must not consume Evolution Data.")
	root_window.size = original_size
	main.queue_free()
	await process_frame
	if failures == 0:
		print("Read-only Evolution roster visual QA passed at 1280x720 and 800x450; no purchase or save was performed.")
		quit(0)
	else:
		push_error("%d Evolution roster visual QA check(s) failed." % failures)
		quit(1)


func _all_rows_ready(main: Node) -> bool:
	for recruit_value in EVOLUTION_SCRIPT.APPROVED_RECRUIT_IDS:
		var row: Dictionary = main.evolution_rows.get(str(recruit_value), {})
		if row.is_empty() or row["record_button"].disabled or not row["record_button"].text.begins_with("RECORD "):
			return false
	return true


func _all_rows_locked(main: Node) -> bool:
	for recruit_value in EVOLUTION_SCRIPT.APPROVED_RECRUIT_IDS:
		var row: Dictionary = main.evolution_rows.get(str(recruit_value), {})
		if row.is_empty() or not row["record_button"].disabled or not row["progress_label"].text.contains("LOCKED: WAVE 25"):
			return false
	return true


func _capture(root_window: Window, target_size: Vector2i, state_name: String) -> void:
	var texture := root_window.get_texture()
	var image := texture.get_image() if texture != null else null
	_check(image != null and not image.is_empty(), "No rendered Evolution dialog image at %s (%s)." % [str(target_size), state_name])
	if image == null or image.is_empty():
		return
	_check(image.get_size() == target_size, "Capture dimensions should match %s, got %s." % [str(target_size), str(image.get_size())])
	var output_dir := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var filename := "evolution_roster_%s_%dx%d.png" % [state_name.to_lower(), target_size.x, target_size.y]
	var output_path := output_dir.path_join(_available_filename(output_dir, filename))
	var save_error := image.save_png(output_path)
	_check(save_error == OK, "Could not save Evolution review image (error %d)." % save_error)
	if save_error == OK:
		print("Captured read-only Evolution review: %s (%d x %d)." % [output_path, image.get_width(), image.get_height()])


func _available_filename(directory: String, filename: String) -> String:
	var path := directory.path_join(filename)
	if not FileAccess.file_exists(path):
		return filename
	var base := filename.get_basename()
	var extension := filename.get_extension()
	var suffix := 2
	while FileAccess.file_exists(directory.path_join("%s_%02d.%s" % [base, suffix, extension])):
		suffix += 1
	return "%s_%02d.%s" % [base, suffix, extension]


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("EVOLUTION ROSTER VISUAL QA FAILED: " + message)
