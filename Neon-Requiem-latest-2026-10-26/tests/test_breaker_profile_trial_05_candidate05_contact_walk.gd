extends SceneTree

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_05_candidate05_contact_preview.tscn"
const WALK_DURATION := 0.65
const PHASES := [0.0, 0.08, 0.1625, 0.245, 0.325, 0.4075, 0.4875, 0.57, 0.649]
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load isolated BREAKER profile rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0 and rig.loaded_part_count == 13 and rig.loaded_underpaint_count == 13, "Expected all visible and inferred underpaint layers to load.")
	_check(rig.has_pose("walk"), "Isolated rig has no walk animation.")
	var starting_anchor: Vector2 = rig.get_anchor_global_position()
	var left_boot_bottom := _opaque_bottom_points(rig.sprites["left_boot"])
	var right_boot_bottom := _opaque_bottom_points(rig.sprites["right_boot"])
	_check(not left_boot_bottom.is_empty() and not right_boot_bottom.is_empty(), "Both boot masks should expose opaque sole pixels for contact checks.")
	print("Neutral sole offsets: left=%.2f right=%.2f" % [_sole_lowest_world_y(rig.sprites["left_boot"], left_boot_bottom) - starting_anchor.y, _sole_lowest_world_y(rig.sprites["right_boot"], right_boot_bottom) - starting_anchor.y])
	rig.play_pose("walk")
	rig.animation_player.pause()
	var sampled: Dictionary = {}
	for sample_time in PHASES:
		rig.animation_player.seek(float(sample_time), true)
		rig.animation_player.advance(0.0)
		sampled[float(sample_time)] = _read_pose(rig)
		_check(rig.get_anchor_global_position().distance_to(starting_anchor) < 0.001, "Walk posing must not move the world ground anchor.")
	var middle: Dictionary = sampled[0.1625]
	_check(float(middle["LeftKnee"]) > 0.20 and absf(float(middle["RightKnee"])) < 0.08, "Left swing phase should show knee lift while the opposite leg stays mostly extended.")
	var other_middle: Dictionary = sampled[0.4875]
	_check(float(other_middle["RightKnee"]) > 0.20 and absf(float(other_middle["LeftKnee"])) < 0.08, "The opposite swing phase should lift the right knee in alternation.")
	_check(absf(float(middle["LeftHip"]) + float(middle["LeftKnee"]) + float(middle["LeftAnkle"])) < 0.08, "Left boot should counter-rotate toward a level foot through the swing.")
	_check(absf(float(other_middle["RightHip"]) + float(other_middle["RightKnee"]) + float(other_middle["RightAnkle"])) < 0.08, "Right boot should counter-rotate toward a level foot through the swing.")
	_check(float(sampled[0.0]["NaturalShoulder"]) > 0.06 and float(sampled[0.325]["NaturalShoulder"]) < -0.06, "Natural arm should counter-swing across the stride.")
	_check(absf(float(middle["HeadNeck"])) < 0.02, "Head stabilization should keep the head response subtle.")
	for contact_time in [0.0, 0.325]:
		rig.animation_player.seek(float(contact_time), true)
		rig.animation_player.advance(0.0)
		var left_sole_y := _sole_lowest_world_y(rig.sprites["left_boot"], left_boot_bottom)
		var right_sole_y := _sole_lowest_world_y(rig.sprites["right_boot"], right_boot_bottom)
		var nearest_contact := minf(absf(left_sole_y - starting_anchor.y), absf(right_sole_y - starting_anchor.y))
		_check(nearest_contact < 2.5, "At gait phase %.3f at least one opaque boot sole should reach ground (offsets %.2f, %.2f px)." % [contact_time, left_sole_y - starting_anchor.y, right_sole_y - starting_anchor.y])
	var first_pose: Dictionary = sampled[0.0]
	var last_pose: Dictionary = sampled[0.649]
	var wrap_error := 0.0
	for key in first_pose:
		wrap_error = maxf(wrap_error, absf(float(first_pose[key]) - float(last_pose[key])))
	_check(wrap_error < 0.06, "Loop end should approach its starting pose smoothly (max angle delta %.3f rad)." % wrap_error)
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: trial-05 candidate 05 gait has alternating knee lift, ankle compensation, arm counter-swing, subtle head response, smooth loop closure, and a stable ground anchor.")
		quit(0)
	else:
		push_error("%d BREAKER profile walk gait test(s) failed." % failures)
		quit(1)


func _read_pose(rig: Variant) -> Dictionary:
	var pose := {}
	for bone_name in ["Pelvis", "Torso", "HeadNeck", "LeftHip", "LeftKnee", "LeftAnkle", "RightHip", "RightKnee", "RightAnkle", "NaturalShoulder", "NaturalElbow", "CyberShoulder", "CyberElbow"]:
		pose[bone_name] = rig.get_bone_rotation(bone_name)
	return pose


func _opaque_bottom_points(sprite: Sprite2D) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var image := sprite.texture.get_image() if sprite.texture != null else null
	if image == null or image.is_empty():
		return result
	for y in range(image.get_height() - 1, -1, -1):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.1:
				result.append(Vector2(x, y))
		if not result.is_empty():
			break
	return result


func _sole_lowest_world_y(sprite: Sprite2D, bottom_points: Array[Vector2]) -> float:
	var lowest := -INF
	for point in bottom_points:
		lowest = maxf(lowest, sprite.to_global(point).y)
	return lowest


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER TRIAL 05 WALK GAIT FAILED: " + message)

