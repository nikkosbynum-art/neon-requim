extends SceneTree

## Display-capable HUD review using a disposable local save per viewport size.
## Never reads or writes the normal user save.
const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const TARGET_SIZES := [Vector2i(1280, 720), Vector2i(800, 450)]
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	_check(DirAccess.make_dir_recursive_absolute(output_absolute) == OK, "Could not create visual QA output folder.")
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load main scene for offline HUD preview.")
	if failures > 0:
		quit(1)
		return
	var main: Variant = packed.instantiate()
	root.add_child(main)
	await process_frame
	var original_size := root.size
	for target_size in TARGET_SIZES:
		var path := ProjectSettings.globalize_path("res://tests/_offline_hud_%d_%d.json" % [target_size.x, target_size.y])
		var now_unix := int(Time.get_unix_time_from_system())
		var permanent := {"lifetime_influence": 3, "highest_wave_ever": 25, "research": {"combat": 1}, "evolution_materials": {"evolution_data": 2}, "first_clear_material_claims": ["district.undercity"], "evolution": {"breaker_tier": "Origin Form"}, "unlocks": ["breaker"]}
		var run := {"credits": 50, "wave": 40, "highest_cleared_wave": 25, "recruits": {"breaker": {"level": 4}}, "squad_hp": [120.0, 91.0, 83.0, 74.0, 65.0, 56.0], "offline_claim_unix": now_unix - 3600}
		var settings := {"master_volume": 0.45, "window_mode": "windowed"}
		var save_error: Error = SAVE_SCRIPT.save_game(permanent, run, settings, path)
		_check(save_error == OK, "Could not create the disposable offline preview save (error %d)." % save_error)
		if save_error != OK:
			continue
		main.save_path = path
		main._load()
		_check(main.feedback_label.text.contains("+108 offline credits"), "Preview state should contain a one-hour wave-25 claim.")
		root.size = target_size
		await process_frame
		main._apply_responsive_hud_scale()
		await create_timer(1.0).timeout
		var viewport_texture := root.get_texture()
		if viewport_texture == null:
			_check(false, "No rendered viewport texture at %s." % str(target_size))
		else:
			var image := viewport_texture.get_image()
			_check(image != null and not image.is_empty(), "Empty rendered viewport at %s." % str(target_size))
			if image != null and not image.is_empty():
				var output_path := _available_output_path(output_absolute, "offline_claim_%dx%d.png" % [target_size.x, target_size.y])
				var image_error: Error = image.save_png(output_path)
				_check(image_error == OK, "Could not save preview PNG at %s (error %d)." % [output_path, image_error])
				if image_error == OK:
					var reloaded := Image.load_from_file(output_path)
					_check(reloaded != null and reloaded.get_size() == target_size, "Saved preview has wrong dimensions.")
					print("Captured %s — %s" % [output_path, main.feedback_label.text])
		_cleanup(path)
	root.size = original_size
	main.queue_free()
	await process_frame
	if failures == 0:
		print("Offline claim HUD preview passed at both viewport sizes; disposable saves were removed.")
		quit(0)
	else:
		push_error("%d offline claim viewport check(s) failed." % failures)
		quit(1)


func _available_output_path(directory: String, filename: String) -> String:
	var path := directory.path_join(filename)
	if not FileAccess.file_exists(path):
		return path
	var base := filename.get_basename()
	var extension := filename.get_extension()
	var suffix := 2
	while true:
		var candidate := directory.path_join("%s_%02d.%s" % [base, suffix, extension])
		if not FileAccess.file_exists(candidate):
			return candidate
		suffix += 1
	return path


func _cleanup(path: String) -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var artifact: String = path + suffix
		if FileAccess.file_exists(artifact):
			var error_code: Error = DirAccess.remove_absolute(artifact)
			_check(error_code == OK, "Could not remove disposable preview save %s." % artifact)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("OFFLINE CLAIM HUD PREVIEW FAILED: " + message)
