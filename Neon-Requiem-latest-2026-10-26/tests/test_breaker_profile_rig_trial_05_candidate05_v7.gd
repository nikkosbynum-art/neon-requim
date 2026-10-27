extends SceneTree

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_05_candidate05_v7_preview.tscn"
const REQUIRED_POSES := ["idle", "walk", "punch", "hit", "defeat"]
const EXPECTED_VISIBLE_HEIGHT := 256.0
const SOURCE_VISIBLE_HEIGHT := 1466.0
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the isolated BREAKER guarded-pose trial rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0 and rig.loaded_part_count == 13, "All 13 visible art layers must load.")
	_check(rig.loaded_underpaint_count == 13 and rig.underpaint_sprites.size() == 13, "All 13 inferred underpaint layers must load.")
	_check(is_equal_approx(rig.skeleton.scale.y * SOURCE_VISIBLE_HEIGHT, EXPECTED_VISIBLE_HEIGHT), "Review scale must match the specified 256 px visible feet-to-hair height.")
	for part_name in rig.sprites:
		var image: Image = (rig.sprites[part_name] as Sprite2D).texture.get_image()
		_check(image != null and image.get_size() == Vector2i(1024, 1536), "%s must share the declared full source canvas." % part_name)
		if image != null and image.get_size() == Vector2i(1024, 1536):
			var corner_alpha := maxf(maxf(image.get_pixel(0, 0).a, image.get_pixel(1023, 0).a), maxf(image.get_pixel(0, 1535).a, image.get_pixel(1023, 1535).a))
			_check(corner_alpha <= 0.01, "%s must keep all four shared-canvas corners transparent." % part_name)
		var visible_sprite := rig.sprites[part_name] as Sprite2D
		var underpaint_sprite := rig.underpaint_sprites.get(part_name) as Sprite2D
		_check(underpaint_sprite != null, "%s must have an inferred underpaint layer." % part_name)
		if underpaint_sprite != null:
			var under_image: Image = underpaint_sprite.texture.get_image()
			_check(under_image != null and under_image.get_size() == Vector2i(1024, 1536), "%s underpaint must share the source canvas." % part_name)
			_check(underpaint_sprite.get_parent() == visible_sprite.get_parent(), "%s underpaint must follow the same bone as its visible art." % part_name)
			_check(underpaint_sprite.z_index < visible_sprite.z_index, "%s underpaint must render behind its visible part." % part_name)
			_check(under_image != null and under_image.get_used_rect().size.x > 0, "%s inferred underpaint must contain pixels." % part_name)
	var expected_pivots := ["ground_anchor", "pelvis", "torso", "head_neck", "cyber_shoulder", "cyber_elbow", "natural_shoulder", "natural_elbow", "left_hip", "left_knee", "left_ankle", "right_hip", "right_knee", "right_ankle"]
	for pivot_name in expected_pivots:
		var pivot: Vector2 = rig.pivot_px.get(pivot_name, Vector2(-1.0, -1.0))
		_check(pivot.x >= 0.0 and pivot.y >= 0.0 and pivot.x <= 1024.0 and pivot.y <= 1536.0, "Pivot %s must be declared within the source canvas." % pivot_name)
	for pose_name in REQUIRED_POSES:
		_check(rig.has_pose(pose_name), "Missing Tier I review pose: %s." % pose_name)
	var anchor_before: Vector2 = rig.get_anchor_global_position()
	rig.visual_root.scale.x = -1.0
	_check(rig.get_anchor_global_position().distance_to(anchor_before) < 0.001, "Facing flip must preserve the world ground anchor.")
	rig.visual_root.scale.x = 1.0
	var checks := [
		{"pose": "idle", "time": 0.50, "bone": "Torso"},
		{"pose": "walk", "time": 0.1625, "bone": "LeftKnee"},
		{"pose": "punch", "time": 0.22, "bone": "CyberShoulder"},
		{"pose": "hit", "time": 0.08, "bone": "Torso"},
		{"pose": "defeat", "time": 0.95, "bone": "Torso"}
	]
	for sample in checks:
		rig.play_pose(str(sample["pose"]))
		rig.animation_player.seek(float(sample["time"]), true)
		rig.animation_player.advance(0.0)
		rig.animation_player.pause()
		var angle: float = rig.get_bone_rotation(str(sample["bone"]))
		_check(is_finite(angle), "%s should produce finite pivot transforms." % str(sample["pose"]))
		if str(sample["pose"]) != "idle":
			_check(absf(angle) > 0.04, "%s should animate the expected %s pivot." % [str(sample["pose"]), str(sample["bone"])])
		_check(rig.get_anchor_global_position().distance_to(anchor_before) < 0.001, "%s must keep the ground anchor stable." % str(sample["pose"]))
		print("Art-gate sample %s: %s rotation %.3f rad; ground anchor stable." % [str(sample["pose"]), str(sample["bone"]), angle])
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: isolated guarded-pose rig structure, 256 px visible scale, inferred pivots, and five pose channels are present. This is not art-production approval.")
		quit(0)
	else:
		push_error("%d BREAKER inferred-underpaint test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER INFERRED UNDERPAINT TEST FAILED: " + message)

