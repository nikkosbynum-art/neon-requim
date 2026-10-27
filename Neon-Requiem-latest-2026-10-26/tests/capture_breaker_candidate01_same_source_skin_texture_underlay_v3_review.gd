extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const TRIAL := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/"
const BASE := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/"
const OUT := "res://docs/visual_qa/BREAKER_T1_candidate01_same_source_skin_texture_underlay_v3_"
const ELBOW_Y := 495
const POSES := {"neutral": 0.0, "walk": 0.1625, "punch": 0.22, "hit": 0.08, "defeat": 0.75}
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
	var vector_texture := _load_svg_texture(TRIAL + "candidate01_upper_arm_same_source_skin_texture_underlay_v3.svg")
	var skin := _load(TRIAL + "candidate01_biological_upper_arm_visible_v4.png")
	var shell := _load(TRIAL + "candidate01_external_shoulder_shell_v4.png")
	var forearm_source := _load(BASE + "cyber_forearm.png")
	if vector_texture == null or skin == null or shell == null or forearm_source == null:
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
	var underlay := _add_layer(shoulder, vector_texture, -rig.pivot_px["cyber_shoulder"], 6, "VectorV2BiologicalUnderlayReviewOnly")
	var visible_skin := _add_layer(shoulder, ImageTexture.create_from_image(skin), -rig.pivot_px["cyber_shoulder"], 8, "VisibleSourceSkinReviewOnly")
	var shell_layer := _add_layer(shoulder, ImageTexture.create_from_image(shell), -rig.pivot_px["cyber_shoulder"], 9, "ExternalShellReviewOnly")
	var shell_overlap_layer := _add_layer(shoulder, ImageTexture.create_from_image(shell_overlap), -rig.pivot_px["cyber_shoulder"], 10, "ShellElbowOverlapReviewOnly")
	var prosthesis := _add_layer(elbow, ImageTexture.create_from_image(prosthesis_image), -rig.pivot_px["cyber_elbow"], 11, "ElbowStartProsthesisReviewOnly")
	if underlay.get_parent() != shoulder or visible_skin.get_parent() != shoulder or shell_layer.get_parent() != shoulder or shell_overlap_layer.get_parent() != shoulder or prosthesis.get_parent() != elbow:
		_fail("Upper-arm parts are not attached to their expected trial bones.")
		quit(1)
		return
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
	# Native-scale shoulder closeups make silhouette and seam review readable beside the 256 px gameplay captures.
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
			_fail("Could not capture the neutral detail view with shell %s." % ["on" if shell_visible else "off"])
			continue
		var detail_suffix := "neutral_detail_shell_on" if shell_visible else "neutral_detail_shell_off"
		var detail_path := ProjectSettings.globalize_path(OUT + detail_suffix + ".png")
		if detail.save_png(detail_path) != OK:
			_fail("Could not save detail preview %s." % detail_path)
		else:
			print("Saved %s preview: %s" % [detail_suffix, detail_path])
	if failures == 0:
		print("PASS: vector underlay loaded; source skin/shell share the shoulder bone; prosthesis starts at elbow; ground anchor remains stable across five poses.")
		print("LIMIT: review-only vector art; visual approval and continuous seam quality are not certified by this capture.")
	rig.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _load(path: String) -> Image:
	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(path)) != OK:
		_fail("Could not load %s." % path)
		return null
	return image

func _load_svg_texture(path: String) -> Texture2D:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Could not open vector underlay %s." % path)
		return null
	var image := Image.new()
	var error := image.load_svg_from_string(file.get_as_text(), 1.0)
	if error != OK or image.is_empty():
		_fail("Could not rasterize vector underlay (%s)." % error_string(error))
		return null
	return ImageTexture.create_from_image(image)

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

func _check_anchor(rig: Variant, anchor: Vector2, pose: String) -> void:
	if rig.get_anchor_global_position().distance_to(anchor) > 0.001:
		_fail("Ground anchor moved during %s." % pose)

func _fail(message: String) -> void:
	failures += 1
	push_error("VECTOR UNDERARM REVIEW FAILED: " + message)


