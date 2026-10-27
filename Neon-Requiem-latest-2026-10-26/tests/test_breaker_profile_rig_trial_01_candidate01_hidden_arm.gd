extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const DONOR_PATH := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/hidden_biological_upper_arm_candidate01_v2.png"
const POSES := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeat": 0.95}
var failures := 0
var samples := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the approved candidate01 rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	rig.draw_review_stage = false
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0, "Candidate01 rig failed to load parts.")
	var image := Image.new()
	_check(image.load(ProjectSettings.globalize_path(DONOR_PATH)) == OK, "Could not load quarantined hidden-arm donor.")
	if image.is_empty():
		quit(1)
		return
	_check(image.get_size() == Vector2i(1024, 1536), "Donor must share the candidate01 canvas.")
	var skin: Sprite2D = rig.sprites["cyber_upper_arm"]
	var bone: Bone2D = rig.bones["CyberShoulder"]
	var donor := Sprite2D.new()
	donor.name = "Candidate01HiddenBiologicalUpperArmReviewOnly"
	donor.texture = ImageTexture.create_from_image(image)
	donor.centered = false
	donor.position = skin.position
	donor.z_index = skin.z_index - 1
	donor.z_as_relative = false
	donor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bone.add_child(donor)
	_check(donor.get_parent() == skin.get_parent(), "Donor must follow the same shoulder bone as visible art.")
	_check(donor.position == skin.position, "Donor and visible art must share the source-space origin.")
	_check(donor.z_index < skin.z_index, "Donor must render behind the original visible part.")
	var anchor: Vector2 = rig.get_anchor_global_position()
	var checks: Array[Dictionary] = [{"pose":"neutral","time":0.0}]
	for pose in POSES:
		var duration: float = POSES[pose]
		for frame in range(ceili(duration * 60.0) + 1):
			checks.append({"pose":pose,"time":minf(float(frame)/60.0,duration)})
	for item in checks:
		var pose_name := str(item["pose"])
		rig.play_pose(pose_name)
		if pose_name != "neutral":
			rig.animation_player.seek(float(item["time"]),true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
		await process_frame
		_check(donor.get_global_transform_with_canvas().is_equal_approx(skin.get_global_transform_with_canvas()), "%s at %.3f separated donor from visible arm." % [pose_name,float(item["time"])])
		_check(rig.get_anchor_global_position().distance_to(anchor)<0.001, "%s at %.3f moved the ground anchor." % [pose_name,float(item["time"])])
		samples += 1
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: candidate01 hidden donor registration follows the shoulder through %d neutral/60 Hz samples; ground anchor stable." % samples)
		print("LIMIT: shared-bone registration is not proof of separate-shell motion, anatomy, or production seams.")
		quit(0)
	else:
		push_error("%d candidate01 hidden-arm registration check(s) failed." % failures)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CANDIDATE01 HIDDEN-ARM TEST FAILED: " + message)
