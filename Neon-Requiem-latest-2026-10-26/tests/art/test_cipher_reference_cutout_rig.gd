extends SceneTree

const SCENE_PATH := "res://tests/art/cipher_t1_reference_cutout_rig_preview.tscn"
const POSES := ["neutral", "idle", "walk", "aim_fire", "hit", "defeat"]
const EXPECTED_PARTS := ["head", "backpack", "torso", "pelvis", "upper_arm", "forearm", "hand", "thigh", "shin", "boot", "rifle"]
const EXPECTED_BONES := ["ground_root", "torso", "neck_socket", "near_shoulder", "near_elbow", "near_wrist", "near_hip", "near_knee", "near_ankle", "far_shoulder", "far_elbow", "far_wrist", "far_hip", "far_knee", "far_ankle"]

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load isolated art-rig scene.")
	if packed == null:
		quit(1)
		return
	var rig: Node = packed.instantiate()
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures.is_empty(), "Missing PNG part textures: %s" % str(rig.load_failures))
	_check(rig.parts.size() == EXPECTED_PARTS.size(), "Expected the complete declared set of visible profile art layers.")
	for part_name in EXPECTED_PARTS:
		_check(rig.parts.has(part_name), "Missing articulated art part: %s" % part_name)
		if rig.parts.has(part_name):
			var texture: Texture2D = rig.parts[part_name].texture
			var art: Image = texture.get_image()
			_check(art != null and art.get_width() > 0 and art.get_height() > 0, "Part texture is empty: %s" % part_name)
			if art != null:
				_check(art.get_pixel(0, 0).a == 0.0, "Part safety corner must be transparent: %s" % part_name)
	for bone_name in EXPECTED_BONES:
		_check(rig.bones.has(bone_name), "Missing bone: %s" % bone_name)
	var ground_before: Vector2 = rig.get_ground_anchor()
	for pose_name in POSES:
		_check(rig.set_pose(pose_name), "Could not set pose %s" % pose_name)
		await process_frame
		_check(rig.get_ground_anchor().distance_to(ground_before) < 0.001, "%s pose moved the ground anchor" % pose_name)
	_check(rig.parts["head"].texture.get_size().y > 150, "Head cutout unexpectedly lost its visible detail.")
	_check(rig.parts["boot"].texture.get_size().x > 100, "Boot cutout unexpectedly lost its grounding silhouette.")
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: CIPHER cutout candidate loads 11 art layers and 15 bones; six pose states preserve the ground anchor; all part images have transparent safety corners.")
		print("LIMIT: profile art currently covers one visible-side arm/leg; far-side art is not yet authored. Pivots and overlap are inferred, continuous deformation is not approved, and production approval remains pending.")
		quit(0)
	else:
		push_error("%d CIPHER cutout-rig candidate test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CIPHER CUTOUT RIG FAILED: " + message)
