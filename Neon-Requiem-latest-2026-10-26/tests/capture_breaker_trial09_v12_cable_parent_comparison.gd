extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const DRAFT_DIR := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v12_cable_component/"
const OUTPUT_DIR := "res://docs/visual_qa"
const CROP_RECT := Rect2i(565, 310, 150, 165)
const PARENTS := {
	"pelvis": ["Pelvis", "pelvis"],
	"torso": ["Torso", "torso"],
	"cyber_shoulder": ["CyberShoulder", "cyber_shoulder"],
	"cyber_elbow": ["CyberElbow", "cyber_elbow"],
}
const POSES := {"neutral": 0.0, "idle": 0.50, "walk": 0.1625, "punch": 0.22}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load candidate 09 v4 review rig.")
		quit(1)
		return
	var reference_rig: Variant = packed.instantiate()
	root.add_child(reference_rig)
	await process_frame
	await process_frame
	_hide_underpaint(reference_rig)
	_reset_neutral_pose(reference_rig)
	await process_frame
	await process_frame
	var reference_image := _capture_crop()
	var reference_path := ProjectSettings.globalize_path(OUTPUT_DIR + "/breaker_trial09_v12_cable_reference_neutral.png")
	if reference_image.save_png(reference_path) != OK:
		push_error("Could not save original neutral reference.")
		quit(1)
		return
	reference_rig.queue_free()
	await process_frame

	var failures := 0
	for parent_key in PARENTS:
		var rig: Variant = packed.instantiate()
		root.add_child(rig)
		await process_frame
		_hide_underpaint(rig)
		_reset_neutral_pose(rig)
		if not _replace_with_split_component(rig, str(parent_key)):
			failures += 1
			rig.queue_free()
			continue
		for pose in POSES:
			if pose != "neutral":
				rig.play_pose(str(pose))
				rig.animation_player.seek(float(POSES[pose]), true)
				rig.animation_player.advance(0.0)
				rig.animation_player.pause()
			await process_frame
			await process_frame
			var crop := _capture_crop()
			if pose == "neutral":
				var differences := _count_differences(reference_image, crop)
				print("NEUTRAL %s: %d differing rendered pixels." % [str(parent_key), differences])
				# Runtime ImageTexture filtering can shift a handful of edge pixels;
				# source RGBA reconstruction is checked exactly by the Python builder.
				if differences > 8:
					failures += 1
			var path := ProjectSettings.globalize_path(OUTPUT_DIR + "/breaker_trial09_v12_cable_%s_%s.png" % [str(parent_key), str(pose)])
			if crop.save_png(path) != OK:
				push_error("Could not save cable comparison: %s" % path)
				failures += 1
			else:
				print("Saved %s %s: %s" % [str(parent_key), str(pose), path])
		rig.queue_free()
		await process_frame
	if failures == 0:
		print("PASS: four candidate parents stay within 8 rendered edge pixels of the neutral reference and captured idle/walk/punch.")
	else:
		push_error("%d cable parent comparison assertion(s) failed." % failures)
	quit(0 if failures == 0 else 1)


func _hide_underpaint(rig: Variant) -> void:
	for sprite_variant in rig.underpaint_sprites.values():
		(sprite_variant as Sprite2D).visible = false


func _reset_neutral_pose(rig: Variant) -> void:
	for bone_variant in rig.bones.values():
		(bone_variant as Bone2D).rotation = 0.0
	rig.animation_player.stop()


func _replace_with_split_component(rig: Variant, parent_key: String) -> bool:
	var pelvis_image := Image.new()
	var cable_image := Image.new()
	if pelvis_image.load(ProjectSettings.globalize_path(DRAFT_DIR + "pelvis_without_cable_component.png")) != OK:
		push_error("Could not load clean pelvis component.")
		return false
	if cable_image.load(ProjectSettings.globalize_path(DRAFT_DIR + "cable_component.png")) != OK:
		push_error("Could not load extracted cable component.")
		return false
	(rig.sprites["pelvis"] as Sprite2D).texture = ImageTexture.create_from_image(pelvis_image)
	var parent_data: Array = PARENTS[parent_key]
	var bone := rig.bones[str(parent_data[0])] as Bone2D
	var cable := Sprite2D.new()
	cable.name = "ExtractedCableReviewOnly"
	cable.texture = ImageTexture.create_from_image(cable_image)
	cable.modulate = Color.WHITE
	cable.centered = false
	cable.position = -rig.pivot_px[str(parent_data[1])]
	cable.z_index = 6 # Preserve the original pelvis layer's global draw order.
	cable.z_as_relative = false
	cable.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bone.add_child(cable)
	print("CABLE %s: pos=%s bounds=%s alpha=%d parent_rot=%0.3f" % [parent_key, str(cable.global_position), str(cable.texture.get_image().get_used_rect()), cable_image.get_used_rect().get_area(), bone.rotation])
	return true


func _capture_crop() -> Image:
	return root.get_viewport().get_texture().get_image().get_region(CROP_RECT)


func _count_differences(a: Image, b: Image) -> int:
	var differences := 0
	for y in range(a.get_height()):
		for x in range(a.get_width()):
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				differences += 1
	return differences
