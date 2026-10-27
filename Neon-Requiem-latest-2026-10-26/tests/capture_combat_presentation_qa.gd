extends SceneTree

## Captures a live six-actor movement formation and a simulation-triggered BREAKER hit.
## The hit fixture positions the enemy for a valid CombatDirector damage step; it does not edit animation bones directly.

const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const VIEWPORT_SIZE := Vector2i(1280, 720)

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, "Could not create visual QA output directory.")
	if failures > 0:
		quit(1)
		return
	var packed: PackedScene = load(MAIN_SCENE_PATH)
	_check(packed != null, "Could not load the main scene.")
	if packed == null:
		quit(1)
		return

	var root_window := get_root()
	root_window.size = VIEWPORT_SIZE
	var movement_scene = packed.instantiate()
	root_window.add_child(movement_scene)
	await process_frame
	var initial_state: Dictionary = movement_scene.director.presentation_snapshot()
	await create_timer(1.2).timeout
	var movement_state: Dictionary = movement_scene.director.presentation_snapshot()
	_check(int(movement_state["living_ally_count"]) == 6, "The movement capture must show the full active squad.")
	var advancing_count := 0
	var moved_count := 0
	var initial_allies: Array = initial_state["allies"]
	var current_allies: Array = movement_state["allies"]
	for index in range(mini(initial_allies.size(), current_allies.size())):
		if str(current_allies[index]["animation"]) == "walk":
			advancing_count += 1
		if absf(float(current_allies[index]["x"]) - float(initial_allies[index]["x"])) > 8.0:
			moved_count += 1
	_check(advancing_count >= 4 and moved_count >= 4, "The movement frame must show at least four allies actively advancing from their initial positions.")
	_check(_save_viewport(root_window, directory, "six_actor_movement_1280x720.png"), "Could not save/verify the movement capture.")
	movement_scene.queue_free()
	await process_frame

	var hit_scene = packed.instantiate()
	root_window.add_child(hit_scene)
	await process_frame
	var director = hit_scene.director
	var breaker: Dictionary = director.allies[0]
	var breaker_x := float(breaker["x"])
	for index in range(1, director.allies.size()):
		var ally: Dictionary = director.allies[index]
		ally["x"] = breaker_x - 80.0 - float(index) * 25.0
		ally["animation"] = "idle"
		director.allies[index] = ally
	director.enemy_x = breaker_x + 4.0
	director.enemy_attack_elapsed = float(director.enemy_def.get("attack_interval", 1.0))
	var hp_before := float(director.allies[0]["hp"])
	director._simulate_enemy(0.05)
	director._sync_breaker_fields()
	_check(float(director.allies[0]["hp"]) < hp_before, "Combat simulation did not damage BREAKER in the hit-pose fixture.")
	_check(str(director.allies[0]["animation"]) == "hit", "Combat simulation did not emit BREAKER's hit state.")
	hit_scene._refresh()
	hit_scene._process(0.016)
	await process_frame
	_check(hit_scene.breaker_actor.animation_state == "hit", "The BREAKER rig did not present the simulation hit event.")
	_check(hit_scene.ally_ground_shadows[0].position.y > hit_scene.breaker_actor.position.y, "BREAKER's shadow should remain at ground contact through the hit pose.")
	_check(_save_viewport(root_window, directory, "breaker_hit_pose_1280x720.png"), "Could not save/verify the hit-pose capture.")
	hit_scene.queue_free()
	await process_frame

	if failures == 0:
		print("Combat presentation QA passed: full squad movement and simulation-triggered BREAKER hit pose captured.")
		quit(0)
	else:
		push_error("%d combat presentation QA check(s) failed." % failures)
		quit(1)


func _save_viewport(root_window: Window, output_directory: String, filename: String) -> bool:
	var output_path := output_directory.path_join(_unique_filename(filename))
	var viewport_texture := root_window.get_texture()
	if viewport_texture == null:
		_check(false, "Godot did not provide a viewport texture for %s." % filename)
		return false
	var image := viewport_texture.get_image()
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
		push_error("COMBAT PRESENTATION QA FAILED: " + message)
