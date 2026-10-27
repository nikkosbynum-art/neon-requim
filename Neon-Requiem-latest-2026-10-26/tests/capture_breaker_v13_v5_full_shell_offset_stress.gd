extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const DONOR_PATH := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/hidden_biological_upper_arm_donor_v5_full_shell.png"
const OUTPUT := "res://docs/visual_qa/breaker_trial09_v13_v5_full_shell_offset_"
const CROP := Rect2i(555, 295, 200, 205)
const CASES := ["baseline", "shift_right_12_source_px", "rotate_out_0_16rad", "shell_hidden"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load the quarantined candidate 09 review rig.")
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	rig.draw_review_stage = false
	root.add_child(rig)
	await process_frame
	var donor_image := Image.new()
	if donor_image.load(ProjectSettings.globalize_path(DONOR_PATH)) != OK:
		push_error("Could not load v13 full-shell donor.")
		quit(1)
		return
	var skin := rig.sprites["cyber_upper_arm_skin"] as Sprite2D
	var shell := rig.sprites["cyber_shoulder_shell"] as Sprite2D
	var bone := rig.bones["CyberShoulder"] as Bone2D
	var donor := Sprite2D.new()
	donor.name = "V13HiddenSkinOffsetStressReviewOnly"
	donor.texture = ImageTexture.create_from_image(donor_image)
	donor.centered = false
	donor.position = skin.position
	donor.z_index = 1
	donor.z_as_relative = false
	donor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bone.add_child(donor)
	await process_frame
	var original_position := shell.position
	var original_rotation := shell.rotation
	var anchor: Vector2 = rig.get_anchor_global_position()
	for case_name in CASES:
		shell.position = original_position
		shell.rotation = original_rotation
		shell.visible = true
		match case_name:
			"shift_right_12_source_px": shell.position += Vector2(12.0, 0.0)
			"rotate_out_0_16rad": shell.rotation += 0.16
			"shell_hidden": shell.visible = false
		await process_frame
		await process_frame
		var image := root.get_viewport().get_texture().get_image()
		if image == null or image.get_size().x < CROP.position.x + CROP.size.x or image.get_size().y < CROP.position.y + CROP.size.y:
			push_error("Viewport image unavailable for %s." % case_name)
			quit(1)
			return
		var output_path := ProjectSettings.globalize_path(OUTPUT + case_name + ".png")
		if image.get_region(CROP).save_png(output_path) != OK:
			push_error("Could not save shell stress capture %s." % case_name)
			quit(1)
			return
		if rig.get_anchor_global_position().distance_to(anchor) > 0.001:
			push_error("Shell review transform moved the ground anchor.")
			quit(1)
		print("Saved shell separation review: %s" % output_path)
	print("PASS: baseline, 12-source-pixel translation, 0.16-radian independent shell rotation, and shell-hidden captures; ground anchor stable.")
	print("LIMIT: this is a visual stress review, not an approved production animation or proof of biological accuracy.")
	quit(0)
