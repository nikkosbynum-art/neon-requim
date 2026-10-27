extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const POSE_DURATIONS := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeat": 0.95}
var failures := 0
var samples_checked := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load candidate 09 v4 hand-split rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	var skin: Sprite2D = rig.sprites["cyber_upper_arm_skin"]
	var shell: Sprite2D = rig.sprites["cyber_shoulder_shell"]
	var anchor: Vector2 = rig.get_anchor_global_position()
	_check(skin.get_parent() == shell.get_parent(), "Skin and shell must share the CyberShoulder bone.")
	_check(skin.position == shell.position, "Skin and shell source positions must match.")
	_check(rig.bones["CyberElbow"].get_parent() == rig.bones["CyberShoulder"], "Mechanical forearm must hinge from the biological upper-arm shoulder chain.")
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
		var skin_transform: Transform2D = skin.get_global_transform_with_canvas()
		var shell_transform: Transform2D = shell.get_global_transform_with_canvas()
		_check(skin_transform.is_equal_approx(shell_transform), "%s frame %.3f separated shell from the biological upper arm." % [pose_name, float(sample["time"])])
		_check(rig.get_anchor_global_position().distance_to(anchor) < 0.001, "%s frame %.3f moved the ground anchor." % [pose_name, float(sample["time"])])
		_check(is_finite(rig.get_bone_rotation("CyberShoulder")) and is_finite(rig.get_bone_rotation("CyberElbow")), "%s frame %.3f produced a non-finite arm pivot." % [pose_name, float(sample["time"])])
		samples_checked += 1
	print("Checked %d neutral/60 Hz pose samples; skin and shell shared transform held throughout." % samples_checked)
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: candidate 09 v4 arm components stay registered through idle, walk, punch, hit and defeat.")
		print("LIMIT: shared-bone movement does not verify independent shell motion or skin concealed beneath the shell.")
		quit(0)
	else:
		push_error("%d candidate 09 v4 arm registration sample(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER V4 ARM REGISTRATION TEST FAILED: " + message)
