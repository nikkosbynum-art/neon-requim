extends SceneTree

const BASE_SCENE := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const UNDERPAINT_PATH := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v5_generated_underpaint/hidden_biological_upper_arm_donor.png"
const POSE_DURATIONS := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeat": 0.95}
var failures := 0
var samples_checked := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(BASE_SCENE) as PackedScene
	_check(packed != null, "Could not load candidate 09 v4 review rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	var underpaint_image := Image.new()
	_check(underpaint_image.load(ProjectSettings.globalize_path(UNDERPAINT_PATH)) == OK, "Could not load quarantined v5 hidden-skin donor.")
	if underpaint_image.is_empty():
		rig.queue_free()
		quit(1)
		return
	_check(underpaint_image.get_size() == Vector2i(1024, 1536), "Hidden-skin donor must share the source canvas.")
	var skin: Sprite2D = rig.sprites["cyber_upper_arm_skin"]
	var shell: Sprite2D = rig.sprites["cyber_shoulder_shell"]
	var bone: Bone2D = rig.bones["CyberShoulder"]
	var donor := Sprite2D.new()
	donor.name = "HiddenBiologicalUpperArmDonor"
	donor.texture = ImageTexture.create_from_image(underpaint_image)
	donor.centered = false
	donor.position = skin.position
	donor.z_index = 1
	donor.z_as_relative = false
	donor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bone.add_child(donor)
	_check(donor.get_parent() == skin.get_parent(), "Hidden anatomy must follow the same CyberShoulder bone.")
	_check(donor.position == skin.position and donor.position == shell.position, "Hidden donor and visible layers must share source-space placement.")
	_check(donor.z_index < skin.z_index and donor.z_index < shell.z_index, "Original source skin and shell must remain in front of the hidden donor.")
	var anchor: Vector2 = rig.get_anchor_global_position()
	var samples: Array[Dictionary] = [{"pose": "neutral", "time": 0.0}]
	for pose in POSE_DURATIONS:
		var duration: float = POSE_DURATIONS[pose]
		for frame in range(ceili(duration * 60.0) + 1):
			samples.append({"pose": pose, "time": minf(float(frame) / 60.0, duration)})
	for sample in samples:
		var pose_name := str(sample["pose"])
		rig.play_pose(pose_name)
		if pose_name != "neutral":
			rig.animation_player.seek(float(sample["time"]), true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
		await process_frame
		_check(donor.get_global_transform_with_canvas().is_equal_approx(skin.get_global_transform_with_canvas()), "%s at %.3f separated hidden anatomy from the biological upper arm." % [pose_name, float(sample["time"])])
		_check(donor.get_global_transform_with_canvas().is_equal_approx(shell.get_global_transform_with_canvas()), "%s at %.3f separated hidden anatomy from the shell." % [pose_name, float(sample["time"])])
		_check(rig.get_anchor_global_position().distance_to(anchor) < 0.001, "%s at %.3f moved the ground anchor." % [pose_name, float(sample["time"])])
		samples_checked += 1
	print("Checked %d neutral/60 Hz pose samples with v5 hidden-skin donor, original bicep and shell." % samples_checked)
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: candidate 09 v5 hidden-skin donor follows the approved upper-arm/shell assembly through idle, walk, punch, hit and defeat.")
		print("LIMIT: shared-bone registration does not establish independently moving shell fit or artist-authored concealed anatomy.")
		quit(0)
	else:
		push_error("%d candidate 09 v5 hidden-arm registration sample(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER V5 UNDERPAINT TEST FAILED: " + message)
