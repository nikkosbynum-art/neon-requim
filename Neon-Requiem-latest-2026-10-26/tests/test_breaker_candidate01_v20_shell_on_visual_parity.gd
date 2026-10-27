extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const BASE := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/"
const TRIAL := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/"
const UNDERLAY_PATH := TRIAL + "candidate01_tapered_underarm_v20.png"
const SKIN_PATH := TRIAL + "candidate01_biological_upper_arm_visible_v4.png"
const SHELL_PATH := TRIAL + "candidate01_external_shoulder_shell_v4.png"
const ELBOW_Y := 495
const MAX_EDGE_DELTA_PIXELS := 64
const MAX_CHANNEL_DELTA := 96
const ALLOWED_EDGE_BOUNDS := Rect2i(560, 350, 100, 110)
const POSES := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeat": 0.95}

var failures := 0
var comparisons := 0
var peak_changed_pixels := 0
var peak_channel_delta := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the isolated candidate01 review rig.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	rig.draw_review_stage = false
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0, "Candidate01 source parts must load.")
	if failures > 0:
		quit(1)
		return

	var shoulder: Bone2D = rig.bones["CyberShoulder"]
	var elbow: Bone2D = rig.bones["CyberElbow"]
	var original_upper: Sprite2D = rig.sprites["cyber_upper_arm"]
	var original_forearm: Sprite2D = rig.sprites["cyber_forearm"]
	original_upper.visible = false
	original_forearm.visible = false
	var shoulder_pivot: Vector2 = rig.pivot_px["cyber_shoulder"]
	var elbow_pivot: Vector2 = rig.pivot_px["cyber_elbow"]
	var underlay_image := _load_image(UNDERLAY_PATH)
	var skin_image := _load_image(SKIN_PATH)
	var shell_image := _load_image(SHELL_PATH)
	var forearm_image := _load_image(BASE + "cyber_forearm.png")
	if underlay_image == null or skin_image == null or shell_image == null or forearm_image == null:
		quit(1)
		return

	var shell_overlap := forearm_image.duplicate()
	var lower_forearm := forearm_image.duplicate()
	for y in range(forearm_image.get_height()):
		for x in range(forearm_image.get_width()):
			if y < ELBOW_Y:
				lower_forearm.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				shell_overlap.set_pixel(x, y, Color(0, 0, 0, 0))

	var underlay := _add_layer(shoulder, underlay_image, -shoulder_pivot, 5, "V20UnderlayParityTest")
	_add_layer(shoulder, skin_image, -shoulder_pivot, 9, "VisibleSkinParityTest")
	_add_layer(shoulder, shell_image, -shoulder_pivot, 10, "ExternalShellParityTest")
	_add_layer(shoulder, shell_overlap, -shoulder_pivot, 11, "ShellElbowOverlapParityTest")
	_add_layer(elbow, lower_forearm, -elbow_pivot, 12, "ElbowStartForearmParityTest")
	var anchor: Vector2 = rig.get_anchor_global_position()

	var checks: Array[Dictionary] = [{"pose": "neutral", "time": 0.0}]
	for pose_name in POSES:
		for frame in range(ceili(float(POSES[pose_name]) * 60.0) + 1):
			checks.append({"pose": pose_name, "time": minf(float(frame) / 60.0, float(POSES[pose_name]))})

	for item in checks:
		var pose_name := str(item["pose"])
		rig.play_pose(pose_name)
		if pose_name != "neutral":
			rig.animation_player.seek(float(item["time"]), true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
		await process_frame
		_check(rig.get_anchor_global_position().distance_to(anchor) < 0.001, "%s moved the ground anchor." % pose_name)

		underlay.visible = false
		await process_frame
		await process_frame
		var without_underlay_first := root.get_viewport().get_texture().get_image()
		await process_frame
		await process_frame
		var without_underlay := root.get_viewport().get_texture().get_image()
		underlay.visible = true
		await process_frame
		await process_frame
		var with_underlay := root.get_viewport().get_texture().get_image()
		comparisons += 1
		if without_underlay == null or with_underlay == null or without_underlay.get_size() != with_underlay.get_size():
			_check(false, "%s at %.3f produced an invalid comparison image." % [pose_name, float(item["time"])])
			break
		elif without_underlay_first.get_data() != without_underlay.get_data():
			_check(false, "%s at %.3f was not stable across two baseline captures." % [pose_name, float(item["time"])])
			break
		elif without_underlay.get_data() != with_underlay.get_data():
			var data_without := without_underlay.get_data()
			var data_with := with_underlay.get_data()
			var width := without_underlay.get_width()
			var changed_pixels := 0
			var max_channel_delta := 0
			var min_x := width
			var min_y := without_underlay.get_height()
			var max_x := -1
			var max_y := -1
			for byte_index in range(0, data_without.size(), 4):
				if data_without[byte_index] == data_with[byte_index] and data_without[byte_index + 1] == data_with[byte_index + 1] and data_without[byte_index + 2] == data_with[byte_index + 2] and data_without[byte_index + 3] == data_with[byte_index + 3]:
					continue
				for channel in range(4):
					max_channel_delta = maxi(max_channel_delta, absi(int(data_without[byte_index + channel]) - int(data_with[byte_index + channel])))
				var pixel_index := byte_index / 4
				var px := pixel_index % width
				var py := pixel_index / width
				changed_pixels += 1
				min_x = mini(min_x, px)
				min_y = mini(min_y, py)
				max_x = maxi(max_x, px)
				max_y = maxi(max_y, py)
			peak_changed_pixels = maxi(peak_changed_pixels, changed_pixels)
			peak_channel_delta = maxi(peak_channel_delta, max_channel_delta)
			var changed_bounds := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
			_check(changed_pixels <= MAX_EDGE_DELTA_PIXELS, "%s at %.3f changed %d shell-on pixels; maximum allowed edge delta is %d." % [pose_name, float(item["time"]), changed_pixels, MAX_EDGE_DELTA_PIXELS])
			_check(max_channel_delta <= MAX_CHANNEL_DELTA, "%s at %.3f changed a rendered channel by %d; maximum allowed edge delta is %d." % [pose_name, float(item["time"]), max_channel_delta, MAX_CHANNEL_DELTA])
			_check(ALLOWED_EDGE_BOUNDS.encloses(changed_bounds), "%s at %.3f changed pixels outside the expected shoulder-edge bounds: (%d,%d)-(%d,%d)." % [pose_name, float(item["time"]), min_x, min_y, max_x, max_y])

	print("V20 shell-on edge delta summary: %d stable sampled pose frames, peak %d changed pixels / %d channel levels." % [comparisons, peak_changed_pixels, peak_channel_delta])
	if failures == 0:
		print("PASS: v20 underlay edge delta stayed within %d pixels / %d channel levels across %d stable sampled pose frames." % [MAX_EDGE_DELTA_PIXELS, MAX_CHANNEL_DELTA, comparisons])
		print("LIMIT: the bounded translucent-edge blend is an accepted test fixture tolerance, not byte-identical parity; it does not validate shell-off anatomy, authored pivots, or production readiness.")
	rig.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)


func _load_image(path: String) -> Image:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(path))
	_check(error == OK and not image.is_empty(), "Could not load %s." % path)
	return image if error == OK and not image.is_empty() else null


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


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("V20 SHELL-ON PARITY TEST FAILED: " + message)
