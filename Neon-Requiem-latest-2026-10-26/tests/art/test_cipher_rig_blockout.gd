extends SceneTree

const SCENE_PATH := "res://tests/art/cipher_t1_rig_blockout_preview.tscn"
const REQUIRED_BONES := [
	"ground_root", "pelvis", "torso", "neck_socket",
	"rear_hip", "rear_knee", "rear_ankle", "front_hip", "front_knee", "front_ankle",
	"rear_shoulder", "rear_elbow", "rear_wrist", "front_shoulder", "front_elbow", "front_wrist"
]
const REVIEW_POSES := ["neutral", "idle", "walk", "aim_fire", "hit", "defeat"]
const HEAD_PIVOT_PX := Vector2(760.0, 815.0)
const HEAD_DISPLAY_HEIGHT := 110.0
const HEAD_BOUNDS := Rect2i(372, 141, 793, 856)

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the isolated CIPHER rig-blockout scene.")
	if packed == null:
		quit(1)
		return
	var rig: Node = packed.instantiate()
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0, "Quarantined head composite must load into the blockout.")
	_check(rig.bones.size() == REQUIRED_BONES.size(), "Blockout must expose the complete declared bone chain and limb pivots.")
	for bone_name in REQUIRED_BONES:
		_check(rig.bones.has(bone_name), "Missing bone: %s." % bone_name)
	_check(rig.parts.size() == 15, "Placeholder body should expose all 15 articulated body segments.")
	_check(rig.head_sprite != null, "Head composite sprite must attach to the neck socket.")
	if rig.head_sprite != null:
		var expected_scale := HEAD_DISPLAY_HEIGHT / float(HEAD_BOUNDS.size.y)
		_check(is_equal_approx(rig.head_sprite.scale.x, expected_scale), "Head silhouette scale must match the declared review height.")
	_check(rig.get_ground_anchor().distance_to(Vector2(420.0, 360.0)) < 0.001, "Ground anchor must match the scene placement.")
	var anchor_before: Vector2 = rig.get_ground_anchor()
	for pose_name in REVIEW_POSES:
		_check(rig.set_pose(pose_name), "Missing review pose: %s." % pose_name)
		await process_frame
		_check(rig.get_ground_anchor().distance_to(anchor_before) < 0.001, "%s pose must keep the ground anchor fixed." % pose_name)
		if rig.head_sprite != null:
			var neck: Bone2D = rig.bones["neck_socket"]
			var art_scale := HEAD_DISPLAY_HEIGHT / float(HEAD_BOUNDS.size.y)
			_check(rig.head_sprite.to_global(HEAD_PIVOT_PX).distance_to(neck.to_global(Vector2.ZERO)) < 0.01, "%s pose must keep the head pivot attached." % pose_name)

	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: isolated CIPHER Skeleton2D blockout loads 16 bones and 15 articulated placeholder polygons; six pose states preserve the ground anchor and head pivot.")
		print("LIMIT: body geometry is generic placeholder art; no CIPHER anatomical seams or production art are verified.")
		quit(0)
	else:
		push_error("%d CIPHER rig-blockout test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CIPHER RIG BLOCKOUT FAILED: " + message)
