extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const OUTPUT_PATH := "res://docs/visual_qa/breaker_trial09_v4_punch_isolate"
const CROP_RECT := Rect2i(565, 310, 150, 165)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load the candidate 09 v4 review rig.")
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	_add_background_and_labels()
	await process_frame
	await process_frame
	var underpaint_names: Array = rig.underpaint_sprites.keys()
	for name in underpaint_names:
		(rig.underpaint_sprites[name] as Sprite2D).visible = false
	var layer_names: Array = rig.sprites.keys()
	layer_names.sort()
	rig.play_pose("punch")
	rig.animation_player.seek(0.22, true)
	rig.animation_player.advance(0.0)
	rig.animation_player.pause()
	await process_frame
	await process_frame
	var baseline := root.get_viewport().get_texture().get_image().get_region(CROP_RECT)
	var baseline_path := ProjectSettings.globalize_path(OUTPUT_PATH + "_baseline.png")
	if baseline.save_png(baseline_path) != OK:
		push_error("Could not save punch layer baseline.")
		quit(1)
		return
	print("Saved punch layer baseline: %s" % baseline_path)
	for layer in layer_names:
		for sprite_variant in rig.sprites.values():
			(sprite_variant as Sprite2D).visible = false
		(rig.sprites[layer] as Sprite2D).visible = true
		rig.play_pose("punch")
		rig.animation_player.seek(0.22, true)
		rig.animation_player.advance(0.0)
		rig.animation_player.pause()
		await process_frame
		await process_frame
		var capture := root.get_viewport().get_texture().get_image()
		var isolated := capture.get_region(CROP_RECT)
		var path := ProjectSettings.globalize_path(OUTPUT_PATH + "_show_%s.png" % layer)
		var error := isolated.save_png(path)
		if error != OK:
			push_error("Could not save punch layer isolation %s: %s" % [layer, error_string(error)])
			quit(1)
			return
		print("Saved punch layer isolation: %s" % path)
	for sprite_variant in rig.sprites.values():
		(sprite_variant as Sprite2D).visible = false
	await process_frame
	await process_frame
	var empty_art := root.get_viewport().get_texture().get_image().get_region(CROP_RECT)
	var empty_art_path := ProjectSettings.globalize_path(OUTPUT_PATH + "_hide_all_visible_sprites.png")
	if empty_art.save_png(empty_art_path) != OK:
		push_error("Could not save all-sprites-hidden punch frame.")
		quit(1)
		return
	print("Saved all-sprites-hidden punch frame: %s" % empty_art_path)
	quit(0)


func _add_background_and_labels() -> void:
	RenderingServer.set_default_clear_color(Color("#12171d"))
	var label := Label.new()
	label.position = Vector2(36.0, 48.0)
	label.text = "BREAKER PROFILE RIG TRIAL 09 — PUNCH LAYER ISOLATION"
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#e8edf2"))
	root.add_child(label)
