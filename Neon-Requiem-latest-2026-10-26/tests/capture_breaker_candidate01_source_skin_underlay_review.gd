extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const TRIAL := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/"
const BASE := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/"
const OUT := "res://docs/visual_qa/BREAKER_T1_candidate01_source_skin_underlay_"
const ELBOW_Y := 495
const POSES := {"neutral": 0.0, "walk": 0.1625, "punch": 0.22, "hit": 0.08, "defeat": 0.75}
const DONOR_PIVOT := Vector2(615.0, 330.0)
const MIRROR_SCALE := Vector2(-1.05, 0.55)
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		_fail("Could not load the candidate01 review rig.")
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	if rig.load_failures > 0:
		_fail("Candidate01 source layers failed to load.")
		quit(1)
		return
	var shoulder: Bone2D = rig.bones["CyberShoulder"]
	var elbow: Bone2D = rig.bones["CyberElbow"]
	var original_upper: Sprite2D = rig.sprites["cyber_upper_arm"]
	var original_forearm: Sprite2D = rig.sprites["cyber_forearm"]
	original_upper.visible = false
	original_forearm.visible = false
	var donor := _load(BASE + "natural_upper_arm.png")
	var skin := _load(TRIAL + "candidate01_biological_upper_arm_visible_v4.png")
	var shell := _load(TRIAL + "candidate01_external_shoulder_shell_v4.png")
	var forearm_source := _load(BASE + "cyber_forearm.png")
	if donor == null or skin == null or shell == null or forearm_source == null:
		_fail("Could not load one or more arm review layers.")
		quit(1)
		return
	var shell_overlap := forearm_source.duplicate()
	var prosthesis_image := forearm_source.duplicate()
	for y in range(forearm_source.get_height()):
		for x in range(forearm_source.get_width()):
			if y < ELBOW_Y:
				prosthesis_image.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				shell_overlap.set_pixel(x, y, Color(0, 0, 0, 0))
	var underlay := Sprite2D.new()
	underlay.name = "MirroredSourceSkinUnderlayReviewOnly"
	underlay.texture = ImageTexture.create_from_image(donor)
	underlay.centered = false
	underlay.scale = MIRROR_SCALE
	underlay.position = -DONOR_PIVOT * MIRROR_SCALE
	underlay.z_index = 6
	underlay.z_as_relative = false
	underlay.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shoulder.add_child(underlay)
	var visible_skin := _add_layer(shoulder, ImageTexture.create_from_image(skin), -rig.pivot_px["cyber_shoulder"], 8, "VisibleSourceSkinReviewOnly")
	var shell_layer := _add_layer(shoulder, ImageTexture.create_from_image(shell), -rig.pivot_px["cyber_shoulder"], 9, "ExternalShellReviewOnly")
	var shell_overlap_layer := _add_layer(shoulder, ImageTexture.create_from_image(shell_overlap), -rig.pivot_px["cyber_shoulder"], 10, "ShellElbowOverlapReviewOnly")
	var prosthesis := _add_layer(elbow, ImageTexture.create_from_image(prosthesis_image), -rig.pivot_px["cyber_elbow"], 11, "ElbowStartProsthesisReviewOnly")
	if underlay.get_parent() != shoulder or visible_skin.get_parent() != shoulder or shell_layer.get_parent() != shoulder or shell_overlap_layer.get_parent() != shoulder or prosthesis.get_parent() != elbow:
		_fail("Upper-arm parts are not attached to their expected trial bones.")
		quit(1)
		return
	_check_donor_bounds(donor)
	var out_directory := ProjectSettings.globalize_path("res://docs/visual_qa")
	DirAccess.make_dir_recursive_absolute(out_directory)
	var anchor: Vector2 = rig.get_anchor_global_position()
	for pose in POSES:
		rig.play_pose(pose)
		var sample_time := float(POSES[pose])
		if sample_time > 0.0:
			rig.animation_player.seek(sample_time, true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
		await process_frame
		await process_frame
		_check_anchor(rig, anchor, pose)
		for shell_visible in [true, false]:
			shell_layer.visible = shell_visible
			shell_overlap_layer.visible = shell_visible
			await process_frame
			var image := root.get_viewport().get_texture().get_image()
			if image == null or image.is_empty():
				_fail("Could not capture %s with shell %s." % [pose, "on" if shell_visible else "off"])
				continue
			var suffix := "shell_on" if shell_visible else "shell_off"
			var path := ProjectSettings.globalize_path(OUT + "%s_%s.png" % [pose, suffix])
			if image.save_png(path) != OK:
				_fail("Could not save %s preview." % path)
			else:
				print("Saved %s preview: %s" % [suffix, path])
	rig.play_pose("neutral")
	rig.skeleton.scale = Vector2.ONE * 0.9
	rig.visual_root.position = Vector2(807.0, 1325.0)
	await process_frame
	for shell_visible in [true, false]:
		shell_layer.visible = shell_visible
		shell_overlap_layer.visible = shell_visible
		await process_frame
		await process_frame
		var detail := root.get_viewport().get_texture().get_image()
		if detail == null or detail.is_empty():
			_fail("Could not capture detail view with shell %s." % ["on" if shell_visible else "off"])
			continue
		var label := "neutral_detail_shell_on" if shell_visible else "neutral_detail_shell_off"
		var detail_path := ProjectSettings.globalize_path(OUT + label + ".png")
		if detail.save_png(detail_path) != OK:
			_fail("Could not save detail view %s." % detail_path)
		else:
			print("Saved %s preview: %s" % [label, detail_path])
	if failures == 0:
		print("PASS: same-source natural upper-arm skin is mirrored/scaled under the approved shell; elbow-start prosthesis and anchor remain connected in the pose preview.")
		print("LIMIT: the transformed source donor is an art-fit hypothesis; no production or user visual approval is implied.")
	rig.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _load(path: String) -> Image:
	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(path)) != OK:
		_fail("Could not load %s." % path)
		return null
	return image

func _add_layer(parent: Bone2D, texture: Texture2D, position: Vector2, z: int, node_name: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = position
	sprite.z_index = z
	sprite.z_as_relative = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(sprite)
	return sprite

func _check_donor_bounds(donor: Image) -> void:
	var opaque := Rect2i()
	var initialized := false
	for y in range(donor.get_height()):
		for x in range(donor.get_width()):
			if donor.get_pixel(x, y).a < 0.96:
				continue
			if not initialized:
				opaque = Rect2i(x, y, 1, 1)
				initialized = true
			else:
				opaque = opaque.expand(Vector2i(x, y))
	if not initialized:
		_fail("Natural upper-arm donor has no opaque pixels.")
		return
	var mapped_left := 350.0 + (float(opaque.end.x) - DONOR_PIVOT.x) * MIRROR_SCALE.x
	var mapped_right := 350.0 + (float(opaque.position.x) - DONOR_PIVOT.x) * MIRROR_SCALE.x
	var mapped_top := 340.0 + (float(opaque.position.y) - DONOR_PIVOT.y) * MIRROR_SCALE.y
	var mapped_bottom := 340.0 + (float(opaque.end.y) - DONOR_PIVOT.y) * MIRROR_SCALE.y
	if absf(mapped_right - mapped_left) > 130.0 or absf(mapped_bottom - mapped_top) > 230.0:
		_fail("Transformed source underlay exceeds the proportion guard (%s)." % str(opaque))
	else:
		print("PASS: same-source skin donor maps to approx. %.0f×%.0f px at the cyber shoulder." % [absf(mapped_right - mapped_left), absf(mapped_bottom - mapped_top)])

func _check_anchor(rig: Variant, anchor: Vector2, pose: String) -> void:
	if rig.get_anchor_global_position().distance_to(anchor) > 0.001:
		_fail("Ground anchor moved during %s." % pose)

func _fail(message: String) -> void:
	failures += 1
	push_error("SOURCE SKIN UNDERARM REVIEW FAILED: " + message)
