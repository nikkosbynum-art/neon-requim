extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_fidelity_compare_stage.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const OUTPUT_FILENAME := "breaker_profile_fidelity_comparison_01_vs_03_1280x720.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load BREAKER profile fidelity comparison stage.")
		quit(1)
		return
	root.add_child(packed.instantiate())
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != Vector2i(1280, 720):
		push_error("Expected a 1280×720 fidelity comparison capture.")
		quit(1)
		return
	var directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		push_error("Could not create the visual QA directory.")
		quit(1)
		return
	var path := directory.path_join(OUTPUT_FILENAME)
	if FileAccess.file_exists(path):
		path = directory.path_join("breaker_profile_fidelity_comparison_01_vs_03_1280x720_02.png")
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save the fidelity comparison image.")
		quit(1)
		return
	print("Captured BREAKER approved-direction vs edited-candidate fidelity comparison: %s" % path)
	quit(0)
