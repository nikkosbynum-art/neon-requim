extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const TRIAL := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/"
const BASE := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/"
const OUT := "res://docs/visual_qa/BREAKER_T1_candidate01_shell_on_rig_"
const POSES := {"neutral": 0.0, "walk": 0.1625, "punch": 0.22, "hit": 0.08, "defeat": 0.75}
const ELBOW_Y := 495
var failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load isolated candidate01 profile rig.")
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	if rig.load_failures > 0:
		push_error("Profile rig has missing source layers.")
		quit(1)
		return
	var shoulder: Bone2D = rig.bones["CyberShoulder"]
	var elbow: Bone2D = rig.bones["CyberElbow"]
	rig.sprites["cyber_upper_arm"].visible = false
	rig.sprites["cyber_forearm"].visible = false
	var skin := _load(TRIAL + "candidate01_biological_upper_arm_visible_v4.png")
	var shell_upper := _load(TRIAL + "candidate01_external_shoulder_shell_v4.png")
	var forearm := _load(BASE + "cyber_forearm.png")
	if skin == null or shell_upper == null or forearm == null:
		quit(1)
		return
	var shell_overlap := forearm.duplicate()
	var mechanical_forearm := forearm.duplicate()
	for y in range(forearm.get_height()):
		for x in range(forearm.get_width()):
			if y < ELBOW_Y:
				mechanical_forearm.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				shell_overlap.set_pixel(x, y, Color(0, 0, 0, 0))
	var skin_layer := _layer(shoulder, skin, -rig.pivot_px["cyber_shoulder"], 8, "BiologicalSkinReviewOnly")
	var shell_layer := _layer(shoulder, shell_upper, -rig.pivot_px["cyber_shoulder"], 9, "ExternalShoulderShellReviewOnly")
	var shell_overlap_layer := _layer(shoulder, shell_overlap, -rig.pivot_px["cyber_shoulder"], 10, "ShellElbowOverlapReviewOnly")
	var prosthesis := _layer(elbow, mechanical_forearm, -rig.pivot_px["cyber_elbow"], 11, "ElbowStartProsthesisReviewOnly")
	if skin_layer.get_parent() != shoulder or shell_layer.get_parent() != shoulder or shell_overlap_layer.get_parent() != shoulder or prosthesis.get_parent() != elbow:
		push_error("Shell/arm layers are not bound to their approved review bones.")
		quit(1)
		return
	var dir := ProjectSettings.globalize_path("res://docs/visual_qa")
	DirAccess.make_dir_recursive_absolute(dir)
	for pose in POSES:
		rig.play_pose(pose)
		var pose_time := float(POSES[pose])
		if pose_time > 0.0:
			rig.animation_player.seek(pose_time, true)
			rig.animation_player.advance(0.0)
			rig.animation_player.pause()
		await process_frame
		await process_frame
		var image := root.get_viewport().get_texture().get_image()
		if image == null or image.is_empty():
			push_error("Viewport capture failed for %s." % pose)
			failed = true
			continue
		var path := ProjectSettings.globalize_path(OUT + pose + ".png")
		if image.save_png(path) != OK:
			push_error("Could not save shell-on %s capture." % pose)
			failed = true
		else:
			print("Saved shell-on %s rig capture: %s" % [pose, path])
	rig.queue_free()
	await process_frame
	quit(1 if failed else 0)

func _load(path: String) -> Image:
	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(path)) != OK:
		push_error("Could not load review partition: %s" % path)
		return null
	return image

func _layer(parent: Bone2D, image: Image, position: Vector2, z: int, node_name: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.position = position
	sprite.z_index = z
	sprite.z_as_relative = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(sprite)
	return sprite
