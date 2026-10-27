extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const CAPTURE_FILENAME := "modular_zone_crossfade_1280x720.png"
const TARGET_WAVE := 13
const CAPTURE_DURING_FADE_SECONDS := 0.40
const CAPTURE_AFTER_COMBAT_SECONDS := 2.60


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene: PackedScene = load(MAIN_SCENE_PATH)
	if main_scene == null:
		push_error("Could not load the main scene for zone-transition QA.")
		quit(1)
		return
	var main_instance = main_scene.instantiate()
	var root_window := get_root()
	root_window.size = Vector2i(1280, 720)
	root_window.add_child(main_instance)
	await process_frame
	if not is_instance_valid(main_instance.environment_director):
		push_error("Main scene has no active EnvironmentDirector.")
		main_instance.queue_free()
		quit(1)
		return
	main_instance.director.wave = TARGET_WAVE
	main_instance.director._begin_encounter()
	if main_instance.environment_director.active_zone_id != "undercity_proto_02":
		push_error("Combat wave entry did not select the configured prototype zone.")
		main_instance.queue_free()
		quit(1)
		return
	main_instance._refresh()
	await create_timer(CAPTURE_DURING_FADE_SECONDS).timeout
	var texture := root_window.get_texture()
	if texture == null:
		push_error("Godot did not provide a viewport texture for zone-transition QA.")
		main_instance.queue_free()
		quit(1)
		return
	var image := texture.get_image()
	var output_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(output_directory)
	if directory_error != OK:
		push_error("Could not create the visual QA directory (error %d)." % directory_error)
		main_instance.queue_free()
		quit(1)
		return
	var output_path := output_directory.path_join(CAPTURE_FILENAME)
	if FileAccess.file_exists(output_path):
		output_path = output_directory.path_join("modular_zone_crossfade_1280x720_%s.png" % Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_"))
	var save_error := image.save_png(output_path)
	var saved_image := Image.load_from_file(output_path) if save_error == OK else null
	if save_error != OK or saved_image == null or saved_image.get_size() != Vector2i(1280, 720):
		push_error("Zone-transition screenshot failed its save/dimension check.")
		main_instance.queue_free()
		quit(1)
		return
	print("Captured modular zone crossfade to %s (%d x %d)." % [output_path, saved_image.get_width(), saved_image.get_height()])
	await create_timer(CAPTURE_AFTER_COMBAT_SECONDS).timeout
	var later_image := root_window.get_texture().get_image()
	var later_path := output_directory.path_join("modular_zone_positions_after_3s_1280x720.png")
	if FileAccess.file_exists(later_path):
		later_path = output_directory.path_join("modular_zone_positions_after_3s_1280x720_%s.png" % Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_"))
	var later_error := later_image.save_png(later_path)
	var later_saved_image := Image.load_from_file(later_path) if later_error == OK else null
	if later_error != OK or later_saved_image == null or later_saved_image.get_size() != Vector2i(1280, 720):
		push_error("Post-transition position screenshot failed its save/dimension check.")
		main_instance.queue_free()
		quit(1)
		return
	print("Captured post-transition combat positioning to %s (%d x %d)." % [later_path, later_saved_image.get_width(), later_saved_image.get_height()])
	main_instance.queue_free()
	await process_frame
	quit(0)
