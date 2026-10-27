extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v1_preview.tscn"
const POSE_DURATIONS := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeat": 0.95}
const JOINTS := [
	["neck/torso", "head_neck", "torso", "HeadNeck"],
	["torso/pelvis", "torso", "pelvis", "Pelvis"],
	["left hip", "pelvis", "left_thigh", "LeftHip"],
	["right hip", "pelvis", "right_thigh", "RightHip"],
	["cyber shoulder", "torso", "cyber_upper_arm", "CyberShoulder"],
	["cyber elbow", "cyber_upper_arm", "cyber_forearm", "CyberElbow"],
	["natural shoulder", "torso", "natural_upper_arm", "NaturalShoulder"],
	["natural elbow", "natural_upper_arm", "natural_forearm", "NaturalElbow"],
	["left knee", "left_thigh", "left_shin", "LeftKnee"],
	["left ankle", "left_shin", "left_boot", "LeftAnkle"],
	["right knee", "right_thigh", "right_shin", "RightKnee"],
	["right ankle", "right_shin", "right_boot", "RightAnkle"]
]
const CONTACT_RADIUS_PX := 12.0
var failures := 0
var sampled_contacts := 0
var min_contact_pixels := 1000000
var max_contact_pixels := 0
var texture_images: Dictionary = {}
var failure_messages: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load isolated BREAKER guarded-pose trial 09 rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0 and rig.loaded_part_count == 13 and rig.loaded_underpaint_count == 13, "All 13 visible and inferred underpaint layers must load.")
	var starting_anchor: Vector2 = rig.get_anchor_global_position()
	for sprite_name in rig.sprites:
		var sprite: Sprite2D = rig.sprites[sprite_name]
		texture_images[str(sprite_name)] = sprite.texture.get_image()
	var samples := _build_frame_samples()
	for sample in samples:
		var pose := str(sample["pose"])
		rig.play_pose(pose)
		if pose != "neutral":
			rig.animation_player.seek(float(sample["time"]), true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
		await process_frame
		_check(rig.get_anchor_global_position().distance_to(starting_anchor) < 0.001, "%s at %.3f changed the ground anchor." % [pose, float(sample["time"])])
		for joint in JOINTS:
			var label := str(joint[0])
			var center: Vector2 = rig.bones[str(joint[3])].global_position
			var points_a := _opaque_pixels_near(rig.sprites[str(joint[1])], texture_images[str(joint[1])], center)
			var points_b := _opaque_pixels_near(rig.sprites[str(joint[2])], texture_images[str(joint[2])], center)
			var under_a: Sprite2D = rig.underpaint_sprites[str(joint[1])]
			var under_b: Sprite2D = rig.underpaint_sprites[str(joint[2])]
			points_a.append_array(_opaque_pixels_near(under_a, under_a.texture.get_image(), center))
			points_b.append_array(_opaque_pixels_near(under_b, under_b.texture.get_image(), center))
			var gap := _nearest_pixel_gap_squared(points_a, points_b)
			_check(gap <= 2, "%s %s at %.3f has an alpha gap of %.2f px around the pivot." % [pose, label, float(sample["time"]), sqrt(float(gap))])
			var seam_contacts := _adjacent_pixel_contact_count(points_a, points_b)
			_check(seam_contacts >= 15, "%s %s at %.3f has only %d adjacent seam pixels in the sampled joint neighborhood." % [pose, label, float(sample["time"]), seam_contacts])
			min_contact_pixels = mini(min_contact_pixels, seam_contacts)
			max_contact_pixels = maxi(max_contact_pixels, seam_contacts)
			sampled_contacts += 1
	print("Sampled %d joint/pose contacts across %d poses at 60 Hz; adjacent contact pixels per neighborhood min=%d max=%d." % [sampled_contacts, samples.size(), min_contact_pixels, max_contact_pixels])
	for message in failure_messages:
		print("CONTACT FAILURE: " + message)
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: trial 09 visible/inferred-underpaint alpha contact held at sampled pivots. This is not a continuous seam or semantic anatomy proof.")
		quit(0)
	else:
		push_error("%d sampled BREAKER guarded-pose joint contacts failed." % failures)
		quit(1)


func _build_frame_samples() -> Array[Dictionary]:
	var samples: Array[Dictionary] = [{"pose": "neutral", "time": 0.0}]
	for pose_name in POSE_DURATIONS:
		var duration: float = POSE_DURATIONS[pose_name]
		var frame_count := ceili(duration * 60.0)
		for frame in range(frame_count + 1):
			samples.append({"pose": pose_name, "time": minf(float(frame) / 60.0, duration)})
	return samples


func _opaque_pixels_near(sprite: Sprite2D, image: Image, center: Vector2) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	if image == null or image.is_empty():
		return points
	var inverse := sprite.get_global_transform_with_canvas().affine_inverse()
	var extent := int(ceil(CONTACT_RADIUS_PX))
	for y in range(-extent, extent + 1):
		for x in range(-extent, extent + 1):
			var viewport_point := center + Vector2(x + 0.5, y + 0.5)
			var texture_point := inverse * viewport_point
			var pixel := Vector2i(floori(texture_point.x), floori(texture_point.y))
			if pixel.x < 0 or pixel.y < 0 or pixel.x >= image.get_width() or pixel.y >= image.get_height():
				continue
			if image.get_pixelv(pixel).a >= 0.10:
				points.append(Vector2i(roundi(viewport_point.x), roundi(viewport_point.y)))
	return points


func _nearest_pixel_gap_squared(points_a: Array[Vector2i], points_b: Array[Vector2i]) -> int:
	if points_a.is_empty() or points_b.is_empty():
		return 1000000
	var occupied := {}
	for point in points_a:
		occupied[point] = true
	for point in points_b:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if occupied.has(point + Vector2i(dx, dy)):
					return 0
	var nearest := 1000000
	for point_a in points_a:
		for point_b in points_b:
			nearest = mini(nearest, point_a.distance_squared_to(point_b))
	return nearest


func _adjacent_pixel_contact_count(points_a: Array[Vector2i], points_b: Array[Vector2i]) -> int:
	var occupied_b := {}
	for point in points_b:
		occupied_b[point] = true
	var touching_a := {}
	for point_a in points_a:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if occupied_b.has(point_a + Vector2i(dx, dy)):
					touching_a[point_a] = true
					break
			if touching_a.has(point_a):
				break
	return touching_a.size()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		if failure_messages.size() < 40:
			failure_messages.append(message)
