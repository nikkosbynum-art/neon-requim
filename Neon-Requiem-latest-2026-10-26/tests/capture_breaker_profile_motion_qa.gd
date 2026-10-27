extends SceneTree

## Review-only contact sheet for the quarantined BREAKER profile-part trial.
## Estimated pivots and masked anatomy are not production-ready.
const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const REVIEW_STAGE_SCRIPT := preload("res://tests/breaker_motion_review_stage.gd")
const PANELS := [
	{"pose": "neutral", "label": "NEUTRAL / PIVOT BASELINE", "time": 0.0},
	{"pose": "walk", "label": "WALK / MID-SWING", "time": 0.325},
	{"pose": "punch", "label": "PUNCH / STRIKE SAMPLE", "time": 0.22},
	{"pose": "hit", "label": "HIT / RECOIL SAMPLE", "time": 0.08}
]
var failures := 0
var rigs: Array[Variant] = []
var starting_anchors: Array[Vector2] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the quarantined profile rig.")
	if packed == null:
		quit(1)
		return
	var stage := Node2D.new()
	stage.set_script(REVIEW_STAGE_SCRIPT)
	root.add_child(stage)
	for index in range(PANELS.size()):
		var rig: Variant = packed.instantiate()
		rig.draw_review_stage = false
		stage.add_child(rig)
		await process_frame
		_check(rig.load_failures == 0 and rig.loaded_part_count == 13, "Each panel must load all 13 trial part layers.")
		_check(rig.check_neutral_alignment(), "Trial pivots must share the same neutral canvas origin.")
		var panel: Dictionary = PANELS[index]
		rig.visual_root.position = Vector2(160.0 + float(index) * 320.0, 612.0)
		starting_anchors.append(rig.get_anchor_global_position())
		rig.play_pose(str(panel["pose"]))
		if str(panel["pose"]) != "neutral":
			rig.animation_player.seek(float(panel["time"]), true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
			await process_frame
		if str(panel["pose"]) != "neutral":
			_check(rig.has_pose(str(panel["pose"])), "Missing trial pose %s." % str(panel["pose"]))
		var sample_bone := "LeftHip" if str(panel["pose"]) == "walk" else "CyberShoulder" if str(panel["pose"]) == "punch" else "Torso"
		var expected_angle := 0.18 if str(panel["pose"]) == "walk" else -0.22 if str(panel["pose"]) == "punch" else 0.055 if str(panel["pose"]) == "hit" else 0.0
		_check(is_equal_approx(rig.get_bone_rotation(sample_bone), expected_angle), "%s did not reach its sampled pivot angle." % str(panel["pose"]))
		_check(rig.get_anchor_global_position().distance_to(starting_anchors[index]) < 0.001, "%s changed the world ground anchor." % str(panel["pose"]))
		print("Pose sample %s: %s rotation %.3f rad; ground anchor stable." % [str(panel["pose"]), sample_bone, rig.get_bone_rotation(sample_bone)])
		rigs.append(rig)
	_check(rigs.size() == PANELS.size(), "Not all review rigs initialized.")
	if failures > 0:
		quit(1)
		return
	await process_frame
	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	_check(DirAccess.make_dir_recursive_absolute(output_absolute) == OK, "Could not create visual QA output folder.")
	var viewport_texture := root.get_texture()
	var image := viewport_texture.get_image() if viewport_texture != null else null
	_check(image != null and not image.is_empty(), "Could not capture the four-pose motion sheet.")
	if image != null and not image.is_empty():
		var output_path := _available_output_path(output_absolute, "breaker_profile_joint_motion_1280x720.png")
		var save_error: Error = image.save_png(output_path)
		_check(save_error == OK, "Could not save the motion sheet (error %d)." % save_error)
		if save_error == OK:
			print("Captured quarantined BREAKER motion review: %s" % output_path)
	for rig in rigs:
		rig.queue_free()
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("Motion sheet captured. This validates preview assembly and pose plumbing only, not production joint fill/pivots.")
		quit(0)
	else:
		push_error("%d BREAKER motion-sheet check(s) failed." % failures)
		quit(1)


func _available_output_path(directory: String, filename: String) -> String:
	var path := directory.path_join(filename)
	if not FileAccess.file_exists(path):
		return path
	var base := filename.get_basename()
	var extension := filename.get_extension()
	var suffix := 2
	while true:
		var candidate := directory.path_join("%s_%02d.%s" % [base, suffix, extension])
		if not FileAccess.file_exists(candidate):
			return candidate
		suffix += 1
	return path


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER MOTION SHEET FAILED: " + message)
