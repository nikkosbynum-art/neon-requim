extends SceneTree

## Accelerates authoritative CombatDirector fixed steps to capture natural retreat and recovery.
## No save data or project balance definitions are modified by this visual QA fixture.

const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const VIEWPORT_SIZE := Vector2i(1280, 720)
const MAX_SIMULATION_STEPS := 20000

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	_check(DirAccess.make_dir_recursive_absolute(output_directory) == OK, "Could not create visual QA output directory.")
	var packed: PackedScene = load(MAIN_SCENE_PATH)
	_check(packed != null, "Could not load the main scene.")
	if failures > 0 or packed == null:
		quit(1)
		return
	var root_window := get_root()
	root_window.size = VIEWPORT_SIZE
	var main = packed.instantiate()
	root_window.add_child(main)
	await process_frame
	var director = main.director
	var reached_retreat := false
	for _step_index in range(MAX_SIMULATION_STEPS):
		director._step(director.FIXED_STEP)
		if director.phase == "retreat":
			reached_retreat = true
			break
	_check(reached_retreat, "The automatic squad should naturally reach full defeat and retreat before the prototype cap.")
	if not reached_retreat:
		main.queue_free()
		quit(1)
		return
	_check(director.wave == director.highest_cleared_wave and director.highest_cleared_wave >= 1, "Defeat should return to the highest successfully cleared holding wave.")
	_check(director._living_ally_count() == 0, "The defeat capture should show all six members down.")
	director.set_physics_process(false)
	main._refresh()
	main._process(0.016)
	await create_timer(1.0).timeout
	_check(_save_viewport(root_window, output_directory, "carryover_hp_full_squad_defeat_1280x720.png"), "Could not save the defeat capture.")
	print("Retreat QA reached holding wave %d after clearing wave %d (simulated %.1f seconds)." % [director.wave, director.highest_cleared_wave, director.sim_time])

	# Resume from the holding wave after the defeated pose has completed.
	director.phase_timer = 0.01
	director._step(director.FIXED_STEP)
	main._refresh()
	main._process(0.016)
	await create_timer(0.15).timeout
	var recovered: bool = director.phase == "combat" and director.wave == director.highest_cleared_wave and director._living_ally_count() == 6
	for ally in director.allies:
		recovered = recovered and is_equal_approx(float(ally["hp"]), float(ally["max_hp"]))
	_check(recovered, "Retreat recovery should restore all squad HP and resume combat at the holding wave.")
	_check(_save_viewport(root_window, output_directory, "carryover_hp_holding_wave_recovery_1280x720.png"), "Could not save the retreat-recovery capture.")
	main.queue_free()
	await process_frame
	if failures == 0:
		print("Carryover HP retreat/recovery visual QA passed.")
		quit(0)
	else:
		push_error("%d retreat/recovery visual QA check(s) failed." % failures)
		quit(1)


func _save_viewport(root_window: Window, output_directory: String, filename: String) -> bool:
	var output_path := output_directory.path_join(_unique_filename(filename))
	var texture := root_window.get_texture()
	if texture == null:
		_check(false, "Godot did not provide a viewport texture for %s." % filename)
		return false
	var image := texture.get_image()
	if image.is_empty() or image.save_png(output_path) != OK:
		_check(false, "Godot could not save %s." % filename)
		return false
	var saved_image := Image.load_from_file(output_path)
	var valid := saved_image != null and saved_image.get_size() == VIEWPORT_SIZE
	_check(valid, "Saved image dimensions were invalid for %s." % filename)
	if valid:
		print("Captured %s (%d x %d)." % [output_path, saved_image.get_width(), saved_image.get_height()])
	return valid


func _unique_filename(filename: String) -> String:
	var path := OUTPUT_DIRECTORY.path_join(filename)
	if not FileAccess.file_exists(path):
		return filename
	var base := filename.get_basename()
	var extension := filename.get_extension()
	var suffix := 2
	while FileAccess.file_exists(OUTPUT_DIRECTORY.path_join("%s_%02d.%s" % [base, suffix, extension])):
		suffix += 1
	return "%s_%02d.%s" % [base, suffix, extension]


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("RETREAT VISUAL QA FAILED: " + message)
