extends SceneTree

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_04_preview.tscn"
const STAGE_SCRIPT := preload("res://tests/breaker_profile_trial_04_review_stage.gd")
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const STRESS_POSES := ["cyber_arm", "human_arm", "left_leg", "right_leg", "torso_hips"]
var rigs: Array[Variant] = []
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load isolated trial 04 rig.")
		quit(1)
		return
	var stage := Node2D.new()
	stage.set_script(STAGE_SCRIPT)
	stage.view_mode = "joint_stress"
	root.add_child(stage)
	for index in range(STRESS_POSES.size()):
		var rig: Variant = packed.instantiate()
		rig.draw_review_stage = false
		stage.add_child(rig)
		await process_frame
		rig.visual_root.position = Vector2(128.0 + float(index) * 256.0, 612.0)
		rig.play_pose("neutral")
		_apply_stress(rig, str(STRESS_POSES[index]))
		_check(rig.loaded_part_count == 13 and rig.loaded_underpaint_count == 13, "Stress pose %s must load all visible and underpaint layers." % STRESS_POSES[index])
		_check(rig.get_anchor_global_position().distance_to(Vector2(128.0 + float(index) * 256.0, 612.0)) < 0.001, "Stress pose %s moved the ground anchor." % STRESS_POSES[index])
		rigs.append(rig)
	await process_frame
	var image := root.get_texture().get_image()
	_check(image != null and image.get_size() == Vector2i(1280, 720), "Expected 1280×720 joint-stress review.")
	if image != null and not image.is_empty():
		var out_dir := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
		DirAccess.make_dir_recursive_absolute(out_dir)
		var path := out_dir.path_join("breaker_profile_trial_04_joint_stress_1280x720.png")
		var suffix := 2
		while FileAccess.file_exists(path):
			path = out_dir.path_join("breaker_profile_trial_04_joint_stress_1280x720_%02d.png" % suffix)
			suffix += 1
		var error := image.save_png(path)
		_check(error == OK, "Could not save joint-stress image (error %d)." % error)
		if error == OK:
			print("Captured inferred joint-stress review: %s" % path)
	for rig in rigs:
		rig.queue_free()
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: review-only joint-stress capture completed; this is not anatomy or production-art approval.")
		quit(0)
	else:
		push_error("%d trial-04 joint-stress capture check(s) failed." % failures)
		quit(1)


func _apply_stress(rig: Variant, pose: String) -> void:
	match pose:
		"cyber_arm":
			rig.bones["CyberShoulder"].rotation = -0.52
			rig.bones["CyberElbow"].rotation = 0.82
		"human_arm":
			rig.bones["NaturalShoulder"].rotation = 0.45
			rig.bones["NaturalElbow"].rotation = -0.88
		"left_leg":
			rig.bones["LeftHip"].rotation = 0.48
			rig.bones["LeftKnee"].rotation = 0.85
			rig.bones["LeftAnkle"].rotation = -0.68
		"right_leg":
			rig.bones["RightHip"].rotation = -0.48
			rig.bones["RightKnee"].rotation = 0.85
			rig.bones["RightAnkle"].rotation = -0.68
		"torso_hips":
			rig.bones["Torso"].rotation = -0.25
			rig.bones["Pelvis"].rotation = 0.18
			rig.bones["LeftHip"].rotation = 0.32
			rig.bones["RightHip"].rotation = -0.32


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("TRIAL 04 JOINT-STRESS REVIEW FAILED: " + message)
