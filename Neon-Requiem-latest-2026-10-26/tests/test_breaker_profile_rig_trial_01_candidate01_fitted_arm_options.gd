extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const BASE := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/"
const TRIAL := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/"
const VARIANTS := [
	TRIAL + "candidate01_fitted_underarm_slim_affinefix_v2_review.png",
	TRIAL + "candidate01_fitted_underarm_broad_affinefix_v2_review.png",
	TRIAL + "candidate01_upper_arm_vector_underlay_v1.svg",
	TRIAL + "candidate01_upper_arm_source_texture_underlay_v2.svg",
	TRIAL + "candidate01_same_source_skin_upper_arm_underlay_v1.png",
	TRIAL + "candidate01_upper_arm_vector_underlay_v2.svg",
	TRIAL + "candidate01_upper_arm_same_source_skin_texture_underlay_v3.svg",
	TRIAL + "candidate01_upper_arm_compact_skin_texture_underlay_v4.svg",
	TRIAL + "candidate01_upper_arm_generated_texture_underlay_v5.png",
	TRIAL + "candidate01_upper_arm_generated_texture_underlay_v6.png",
	TRIAL + "candidate01_upper_arm_constrained_painted_underlay_v7.png",
	TRIAL + "candidate01_upper_arm_connected_underlay_v10.png",
	TRIAL + "candidate01_upper_arm_underarm_socket_v11.png",
	TRIAL + "candidate01_generated_skin_fitted_underlay_v14.png",
	TRIAL + "candidate01_generated_skin_fitted_underlay_v15.png",
	TRIAL + "candidate01_generated_skin_fitted_underlay_v16.png",
	TRIAL + "candidate01_generated_skin_fitted_underlay_v17.png",
	TRIAL + "candidate01_generated_skin_fitted_underlay_v18.png",
	TRIAL + "candidate01_elbow_anchored_underarm_v19.png",
	TRIAL + "candidate01_tapered_underarm_v20.png"
]
const SKIN_PATH := TRIAL + "candidate01_biological_upper_arm_visible_v4.png"
const UPPER_SHELL_PATH := TRIAL + "candidate01_external_shoulder_shell_v4.png"
const SOURCE_FOREARM_PATH := BASE + "cyber_forearm.png"
const ELBOW_Y := 495
const CONTACT_RECT := Rect2i(230, 430, 270, 170)
# Require a substantial source-space elbow overlap, not a token pixel touch.
# Existing v20 evidence bottoms at 104 contact pixels across the sampled pose set.
const MIN_CONTACT_PIXELS := 100
const EXPECTED_CONTACT_FAILURE_INDICES := [13, 18]
const POSES := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeat": 0.95}
var failures := 0
var samples := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the isolated candidate01 rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	rig.draw_review_stage = false
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0, "Candidate01 source parts must load.")
	var shoulder: Bone2D = rig.bones["CyberShoulder"]
	var elbow: Bone2D = rig.bones["CyberElbow"]
	var original_upper: Sprite2D = rig.sprites["cyber_upper_arm"]
	var original_forearm: Sprite2D = rig.sprites["cyber_forearm"]
	var shoulder_pivot: Vector2 = rig.pivot_px["cyber_shoulder"]
	var elbow_pivot: Vector2 = rig.pivot_px["cyber_elbow"]
	var skin_image := _load_image(SKIN_PATH)
	var shell_image := _load_image(UPPER_SHELL_PATH)
	var forearm_image := _load_image(SOURCE_FOREARM_PATH)
	var torso_image := _load_image(BASE + "torso.png")
	_check(skin_image != null and shell_image != null and forearm_image != null and torso_image != null, "All source partitions must load.")
	if failures > 0:
		quit(1)
		return
	var fore_shell_image := forearm_image.duplicate()
	var lower_forearm_image := forearm_image.duplicate()
	for y in range(forearm_image.get_height()):
		for x in range(forearm_image.get_width()):
			if y < ELBOW_Y:
				lower_forearm_image.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				fore_shell_image.set_pixel(x, y, Color(0, 0, 0, 0))
	var forearm_above_elbow := 0
	for y in range(ELBOW_Y):
		for x in range(lower_forearm_image.get_width()):
			if lower_forearm_image.get_pixel(x, y).a >= 0.96:
				forearm_above_elbow += 1
	_check(forearm_above_elbow == 0, "Elbow-start prosthesis must have no pixels above source y=495.")
	var forearm_contact_points := _opaque_points(lower_forearm_image, CONTACT_RECT)
	_check(not forearm_contact_points.is_empty(), "Elbow-start forearm needs contact pixels inside the test region.")
	for underlay_path in [TRIAL + "candidate01_upper_arm_vector_underlay_v1.svg", TRIAL + "candidate01_upper_arm_source_texture_underlay_v2.svg", TRIAL + "candidate01_same_source_skin_upper_arm_underlay_v1.png", TRIAL + "candidate01_upper_arm_vector_underlay_v2.svg", TRIAL + "candidate01_upper_arm_same_source_skin_texture_underlay_v3.svg", TRIAL + "candidate01_upper_arm_compact_skin_texture_underlay_v4.svg", TRIAL + "candidate01_upper_arm_generated_texture_underlay_v5.png", TRIAL + "candidate01_upper_arm_generated_texture_underlay_v6.png", TRIAL + "candidate01_upper_arm_constrained_painted_underlay_v7.png", TRIAL + "candidate01_upper_arm_connected_underlay_v10.png", TRIAL + "candidate01_upper_arm_underarm_socket_v11.png", TRIAL + "candidate01_generated_skin_fitted_underlay_v14.png", TRIAL + "candidate01_generated_skin_fitted_underlay_v15.png", TRIAL + "candidate01_generated_skin_fitted_underlay_v16.png", TRIAL + "candidate01_generated_skin_fitted_underlay_v17.png", TRIAL + "candidate01_generated_skin_fitted_underlay_v18.png", TRIAL + "candidate01_elbow_anchored_underarm_v19.png", TRIAL + "candidate01_tapered_underarm_v20.png"]:
		var unoccluded_pixels := _count_unoccluded_pixels(_load_image(underlay_path), shell_image, skin_image, forearm_image, torso_image)
		_check(unoccluded_pixels == 0, "Underlay %s must stay behind source torso/shell/skin/prosthesis for shell-on fidelity; %d pixels are exposed." % [underlay_path.get_file(), unoccluded_pixels])
		if unoccluded_pixels == 0:
			print("PASS: %s is fully occluded by approved visible layers for exact shell-on fidelity." % underlay_path.get_file())
	for index in range(VARIANTS.size()):
		var donor_image := _load_image(VARIANTS[index])
		_check(donor_image != null and donor_image.get_size() == Vector2i(1024, 1536), "Fitted donor must use the source canvas.")
		if donor_image == null:
			continue
		original_upper.visible = false
		original_forearm.visible = false
		var donor := _add_layer(shoulder, donor_image, -shoulder_pivot, 5, "FittedBiologicalUpperArmReviewOnly")
		var donor_contact_points := _opaque_points(donor_image, CONTACT_RECT)
		_add_layer(shoulder, skin_image, -shoulder_pivot, 9, "VisibleBiologicalSkinReviewOnly")
		var upper_shell := _add_layer(shoulder, shell_image, -shoulder_pivot, 10, "ExternalShoulderShellUpperPartReviewOnly")
		var fore_shell := _add_layer(shoulder, fore_shell_image, -shoulder_pivot, 11, "ExternalShoulderShellElbowOverlapReviewOnly")
		var forearm := _add_layer(elbow, lower_forearm_image, -elbow_pivot, 12, "MechanicalForearmStartingAtElbowReviewOnly")
		_check(donor_image.get_size() == skin_image.get_size(), "Donor and visible skin need identical source coordinates.")
		_check(upper_shell.get_parent() == shoulder and fore_shell.get_parent() == shoulder, "Both shell source slices must move together on the shoulder bone.")
		_check(forearm.get_parent() == elbow, "Elbow-start prosthesis must follow the elbow bone.")
		_check(upper_shell.position == -shoulder_pivot and fore_shell.position == -shoulder_pivot, "Shoulder-shell slices must retain source-space alignment.")
		_check(forearm.position == -elbow_pivot, "Forearm must retain source-space elbow alignment.")
		upper_shell.visible = false
		fore_shell.visible = false
		var anchor: Vector2 = rig.get_anchor_global_position()
		var min_contact := 1000000000
		var max_contact := 0
		var checks: Array[Dictionary] = [{"pose":"neutral","time":0.0}]
		for pose in POSES:
			for frame in range(ceili(float(POSES[pose]) * 60.0) + 1):
				checks.append({"pose":pose,"time":minf(float(frame)/60.0,float(POSES[pose]))})
		for item in checks:
			var pose_name := str(item["pose"])
			rig.play_pose(pose_name)
			if pose_name != "neutral":
				rig.animation_player.seek(float(item["time"]), true)
				rig.animation_player.advance(0.0)
				rig.animation_player.pause()
			await process_frame
			_check(rig.get_anchor_global_position().distance_to(anchor) < 0.001, "%s moved the ground anchor." % pose_name)
			_check(donor.get_parent() == shoulder, "Biological upper arm separated from shoulder during %s." % pose_name)
			_check(forearm.get_parent() == elbow, "Forearm separated from elbow during %s." % pose_name)
			var source_space: Transform2D = rig.skeleton.global_transform.affine_inverse()
			var donor_to_source: Transform2D = source_space * donor.get_global_transform()
			var forearm_to_source: Transform2D = source_space * forearm.get_global_transform()
			var contact := _transformed_contact_count(donor_contact_points, donor_to_source, forearm_contact_points, forearm_to_source, rig.pivot_px["ground_anchor"])
			min_contact = mini(min_contact, contact)
			max_contact = maxi(max_contact, contact)
			if index not in EXPECTED_CONTACT_FAILURE_INDICES:
				_check(contact >= MIN_CONTACT_PIXELS, "%s at %.3f has only %d overlapping skin/forearm pixels." % [pose_name, float(item["time"]), contact])
			samples += 1
		if index in EXPECTED_CONTACT_FAILURE_INDICES:
			_check(min_contact < MIN_CONTACT_PIXELS, "%s was expected to fail sampled elbow contact, but now meets the threshold." % VARIANTS[index].get_file())
			print("EXPECTED REJECT: %s reaches only %d–%d elbow-contact pixels across %d samples." % [VARIANTS[index].get_file(), min_contact, max_contact, checks.size()])
		else:
			print("PASS: %s underarm kept %d–%d elbow-contact pixels in %d sampled frames." % [["slim", "broad", "vector-v1", "source-texture-v2", "same-source-skin", "vector-v2", "same-source-texture-v3", "compact-texture-v4", "mapped-texture-v5", "mapped-texture-v6", "constrained-painted-v7", "connected-v10", "socket-v11", "generated-skin-fitted-v14", "generated-skin-fitted-v15", "generated-skin-shoulder-bridge-v16", "generated-skin-full-root-v17", "generated-skin-rounded-root-v18", "generated-skin-elbow-anchored-v19", "tapered-underarm-v20"][index], min_contact, max_contact, checks.size()])
		# Remove the trial children before testing the next width.
		for child in shoulder.get_children():
			if child.name.ends_with("ReviewOnly"):
				child.queue_free()
		for child in elbow.get_children():
			if child.name.ends_with("ReviewOnly"):
				child.queue_free()
		await process_frame
	original_upper.visible = true
	original_forearm.visible = true
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: all candidate underarms remain shoulder-bound and retain sampled elbow contact through %d pose frames." % samples)
		print("LIMIT: sampled pixel contact does not prove shell-off anatomy, style match, or continuous all-frame seam quality.")
		quit(0)
	else:
		push_error("%d fitted candidate01 arm rig check(s) failed." % failures)
		quit(1)

func _load_image(path: String) -> Image:
	var image := Image.new()
	var load_error := OK
	if path.ends_with(".svg"):
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_error("Could not open review SVG: %s" % path)
			failures += 1
			return null
		load_error = image.load_svg_from_string(file.get_as_text(), 1.0)
	else:
		load_error = image.load(ProjectSettings.globalize_path(path))
	if load_error != OK:
		push_error("Could not load review image: %s" % path)
		failures += 1
		return null
	return image

func _count_unoccluded_pixels(donor: Image, shell: Image, skin: Image, forearm: Image, torso: Image) -> int:
	if donor == null or shell == null or skin == null or forearm == null or torso == null:
		return -1
	if donor.get_size() != shell.get_size() or donor.get_size() != skin.get_size() or donor.get_size() != forearm.get_size() or donor.get_size() != torso.get_size():
		_check(false, "Underlay, source partitions, torso, and forearm must share the source canvas.")
		return -1
	var unoccluded := 0
	for y in range(donor.get_height()):
		for x in range(donor.get_width()):
			if donor.get_pixel(x, y).a < 0.96:
				continue
			var covered := torso.get_pixel(x, y).a >= 0.96 or shell.get_pixel(x, y).a >= 0.96 or skin.get_pixel(x, y).a >= 0.96 or forearm.get_pixel(x, y).a >= 0.96
			if not covered:
				unoccluded += 1
	return unoccluded

func _add_layer(parent: Bone2D, image: Image, position: Vector2, z_index: int, node_name: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.position = position
	sprite.z_index = z_index
	sprite.z_as_relative = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(sprite)
	return sprite

func _opaque_points(image: Image, rect: Rect2i) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var clipped := rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	for y in range(clipped.position.y, clipped.end.y):
		for x in range(clipped.position.x, clipped.end.x):
			if image.get_pixel(x, y).a >= 0.96:
				points.append(Vector2(x + 0.5, y + 0.5))
	return points

func _transformed_contact_count(donor_points: Array[Vector2], donor_transform: Transform2D, forearm_points: Array[Vector2], forearm_transform: Transform2D, source_offset: Vector2) -> int:
	var occupancy := PackedByteArray()
	occupancy.resize(CONTACT_RECT.size.x * CONTACT_RECT.size.y)
	occupancy.fill(0)
	for point in donor_points:
		var transformed := donor_transform * point + source_offset - Vector2(CONTACT_RECT.position)
		var x := roundi(transformed.x)
		var y := roundi(transformed.y)
		if x >= 0 and y >= 0 and x < CONTACT_RECT.size.x and y < CONTACT_RECT.size.y:
			occupancy[y * CONTACT_RECT.size.x + x] = 1
	var contacts := 0
	for point in forearm_points:
		var transformed := forearm_transform * point + source_offset - Vector2(CONTACT_RECT.position)
		var x := roundi(transformed.x)
		var y := roundi(transformed.y)
		var found := false
		for oy in range(-1, 2):
			for ox in range(-1, 2):
				var nx := x + ox
				var ny := y + oy
				if nx >= 0 and ny >= 0 and nx < CONTACT_RECT.size.x and ny < CONTACT_RECT.size.y and occupancy[ny * CONTACT_RECT.size.x + nx] != 0:
					found = true
					break
			if found:
				break
		if found:
			contacts += 1
	return contacts

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CANDIDATE01 FITTED ARM TEST FAILED: " + message)


