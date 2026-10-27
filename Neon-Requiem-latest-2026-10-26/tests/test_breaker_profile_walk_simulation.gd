extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_walk_simulation.tscn"
const WALK_CYCLE_SECONDS := 0.65
const TEST_FRAMES := 210
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the BREAKER walking simulation scene.")
	if packed == null:
		quit(1)
		return
	var simulation: Variant = packed.instantiate()
	root.add_child(simulation)
	await process_frame
	var rig: Variant = simulation.get_rig()
	_check(rig.load_failures == 0, "A profile texture or pivot failed to load.")
	_check(rig.loaded_part_count == 13, "Expected 13 modular part textures; got %d." % rig.loaded_part_count)
	_check(rig.has_pose("walk"), "The rig has no walk cycle.")
	var starting_anchor: Vector2 = rig.get_anchor_global_position()
	var left_min := INF
	var left_max := -INF
	var right_min := INF
	var right_max := -INF
	for frame in range(TEST_FRAMES):
		await process_frame
		var left_angle: float = rig.get_bone_rotation("LeftHip")
		var right_angle: float = rig.get_bone_rotation("RightHip")
		left_min = minf(left_min, left_angle)
		left_max = maxf(left_max, left_angle)
		right_min = minf(right_min, right_angle)
		right_max = maxf(right_max, right_angle)
	var ending_anchor: Vector2 = rig.get_anchor_global_position()
	var completed_cycles := int(floor(simulation.elapsed / WALK_CYCLE_SECONDS))
	_check(completed_cycles >= 4, "Expected at least four complete 0.65 s walk cycles; got %d." % completed_cycles)
	_check(left_min < -0.08 and left_max > 0.08, "Left hip did not complete both swing directions (%0.3f to %0.3f)." % [left_min, left_max])
	_check(right_min < -0.08 and right_max > 0.08, "Right hip did not complete both swing directions (%0.3f to %0.3f)." % [right_min, right_max])
	_check(absf(ending_anchor.y - starting_anchor.y) < 0.001, "The walking simulation lifted or dropped the world ground anchor.")
	_check(absf(ending_anchor.x - starting_anchor.x) > 40.0, "The walking simulation did not translate across the stage.")
	_check(rig.loaded_part_count == 13, "Part count changed during the walk simulation.")
	if failures == 0:
		print("PASS: BREAKER walked across the stage for %d cycles; left hip %.3f..%.3f rad, right hip %.3f..%.3f rad; anchor delta (%.1f, %.1f)." % [completed_cycles, left_min, left_max, right_min, right_max, ending_anchor.x - starting_anchor.x, ending_anchor.y - starting_anchor.y])
		quit(0)
	else:
		push_error("%d BREAKER walking simulation test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER WALK TEST FAILED: " + message)
