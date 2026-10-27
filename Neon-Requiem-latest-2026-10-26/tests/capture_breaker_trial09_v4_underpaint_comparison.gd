extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const OUTPUT_PATH := "res://docs/visual_qa/breaker_trial09_v4_underpaint_comparison_1280x720.png"
const POSES := {"idle": 0.50, "walk": 0.1625, "punch": 0.22, "hit": 0.08, "defeat": 0.75}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load the isolated candidate 09 v4 review rig.")
		quit(1)
		return
	var with_underpaint: Variant = packed.instantiate()
	var source_only: Variant = packed.instantiate()
	source_only.draw_review_stage = false
	root.add_child(with_underpaint)
	root.add_child(source_only)
	await process_frame
	with_underpaint.visual_root.position.x = 320.0
	source_only.visual_root.position.x = 960.0
	for sprite_variant in source_only.underpaint_sprites.values():
		(sprite_variant as Sprite2D).visible = false
	_add_label(Vector2(170, 100), "INFERRED UNDERPAINT ON")
	_add_label(Vector2(810, 100), "VISIBLE SOURCE LAYERS ONLY")
	var pose_label := Label.new()
	pose_label.position = Vector2(36, 42)
	pose_label.add_theme_font_size_override("font_size", 20)
	pose_label.add_theme_color_override("font_color", Color("#e8edf2"))
	root.add_child(pose_label)
	for pose in POSES:
		with_underpaint.play_pose(pose)
		source_only.play_pose(pose)
		with_underpaint.animation_player.seek(float(POSES[pose]), true)
		source_only.animation_player.seek(float(POSES[pose]), true)
		with_underpaint.animation_player.advance(0.0)
		source_only.animation_player.advance(0.0)
		with_underpaint.animation_player.pause()
		source_only.animation_player.pause()
		pose_label.text = "BREAKER v4 arm review — %s @ %.3fs" % [pose, float(POSES[pose])]
		await process_frame
		var capture := root.get_viewport().get_texture().get_image()
		var path := ProjectSettings.globalize_path(OUTPUT_PATH.replace(".png", "_%s.png" % pose))
		var error := capture.save_png(path)
		if error != OK:
			push_error("Could not save comparison: %s" % error_string(error))
			quit(1)
			return
		print("Saved pose comparison %s: %s" % [pose, path])
	quit(0)


func _add_label(position: Vector2, value: String) -> void:
	var label := Label.new()
	label.position = position
	label.text = value
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#e8edf2"))
	root.add_child(label)
