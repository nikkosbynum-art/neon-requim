extends SceneTree

## Display-capable preview only. Injects disposable in-memory eligibility state;
## it does not load, overwrite, or save the player's real save file.
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const TARGET_SIZES := [Vector2i(1280, 720), Vector2i(800, 450)]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene: PackedScene = load(MAIN_SCENE_PATH)
	if main_scene == null:
		push_error("Evolution HUD preview could not load the main scene.")
		quit(1)
		return
	var main = main_scene.instantiate()
	get_root().add_child(main)
	await process_frame
	main.permanent_state["highest_wave_ever"] = 25
	main.permanent_state["evolution_materials"] = {"evolution_data": 1}
	main._refresh()
	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(output_absolute)
	if directory_error != OK:
		push_error("Evolution HUD preview could not create its output folder.")
		quit(1)
		return
	for target_size in TARGET_SIZES:
		get_root().size = target_size
		await process_frame
		main._apply_responsive_hud_scale()
		await create_timer(1.2).timeout
		var viewport_texture := get_root().get_texture()
		if viewport_texture == null:
			push_error("No viewport texture for evolution HUD preview at %s." % str(target_size))
			quit(1)
			return
		var image := viewport_texture.get_image()
		if image == null or image.is_empty():
			push_error("Empty viewport image for evolution HUD preview at %s." % str(target_size))
			quit(1)
			return
		var output_path := _available_output_path(output_absolute, "evolution_gate_%dx%d.png" % [target_size.x, target_size.y])
		var save_error := image.save_png(output_path)
		if save_error != OK:
			push_error("Could not save evolution HUD preview (%d): %s" % [save_error, output_path])
			quit(1)
			return
		print("Captured %s — %s" % [output_path, main.evolution_button.text])
	main.queue_free()
	await process_frame
	quit(0)


func _available_output_path(directory: String, filename: String) -> String:
	var output_path := directory.path_join(filename)
	if not FileAccess.file_exists(output_path):
		return output_path
	var base_name := filename.get_basename()
	var extension := filename.get_extension()
	var suffix := 2
	while true:
		var candidate := directory.path_join("%s_%02d.%s" % [base_name, suffix, extension])
		if not FileAccess.file_exists(candidate):
			return candidate
		suffix += 1
	return output_path
