extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const CAPTURE_DELAY_SECONDS := 3.0
const CAPTURES := [
	{"size": Vector2i(1280, 720), "filename": "undercity_atmosphere_1280x720.png"},
	{"size": Vector2i(800, 450), "filename": "undercity_atmosphere_800x450.png"}
]

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var make_dir_error := DirAccess.make_dir_recursive_absolute(output_absolute)
	_check(make_dir_error == OK, "Could not create visual QA output directory.")
	if failures > 0:
		quit(1)
		return

	var main_scene: PackedScene = load(MAIN_SCENE_PATH)
	if main_scene == null:
		_check(false, "Could not load the current main scene.")
		quit(1)
		return
	var main_instance := main_scene.instantiate()
	var root_window := get_root()
	root_window.add_child(main_instance)

	for capture in CAPTURES:
		var target_size: Vector2i = capture["size"]
		var output_path := _available_output_path(output_absolute, str(capture["filename"]))
		root_window.size = target_size
		await process_frame
		await create_timer(CAPTURE_DELAY_SECONDS).timeout
		var viewport_texture := root_window.get_texture()
		if viewport_texture == null:
			_check(false, "Godot did not provide a root viewport texture at %s." % target_size)
			continue
		var image := viewport_texture.get_image()
		if image.is_empty():
			_check(false, "Godot returned an empty viewport image at %s." % target_size)
			continue
		var save_error := image.save_png(output_path)
		_check(save_error == OK, "Could not save viewport PNG at %s (error %d)." % [output_path, save_error])
		if save_error != OK:
			continue
		var saved_image := Image.load_from_file(output_path)
		_check(saved_image != null, "Could not reload saved viewport PNG: %s" % output_path)
		if saved_image != null:
			_check(saved_image.get_size() == target_size, "Saved PNG dimensions %s do not match requested size %s." % [saved_image.get_size(), target_size])
			print("Captured %s (%d x %d)." % [output_path, saved_image.get_width(), saved_image.get_height()])

	main_instance.queue_free()
	await process_frame
	if failures == 0:
		print("Visual QA captures completed after %.1f seconds per resolution." % CAPTURE_DELAY_SECONDS)
		quit(0)
	else:
		push_error("%d visual QA capture check(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("VISUAL QA FAILED: " + message)


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
