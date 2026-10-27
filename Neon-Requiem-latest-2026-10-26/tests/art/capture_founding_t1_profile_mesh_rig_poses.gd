extends SceneTree

const PREVIEW_SCENE := preload("res://tests/art/founding_t1_profile_mesh_rig_preview.tscn")
const CHARACTERS := ["bulwark", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]
const POSES := ["neutral", "idle", "walk", "attack", "hit", "defeat"]
const OUTPUT_DIR := "res://docs/visual_qa/founding_t1_mesh_rig_pose_capture_candidate_01"
var failures := 0


func _initialize() -> void:
	call_deferred("_capture_all")


func _capture_all() -> void:
	var absolute_dir := ProjectSettings.globalize_path(OUTPUT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	_check(mkdir_error == OK or mkdir_error == ERR_ALREADY_EXISTS, "Could not create output folder.")
	for character_id: String in CHARACTERS:
		var neutral_capture: Image
		for pose: String in POSES:
			var preview := PREVIEW_SCENE.instantiate()
			preview.character_id = character_id
			root.add_child(preview)
			await process_frame
			await process_frame
			_check(preview.rig != null, "%s rig failed to initialize." % character_id)
			if preview.rig != null:
				_check(preview.rig.set_pose(pose), "%s rejected %s pose." % [character_id, pose])
			await process_frame
			await process_frame
			RenderingServer.force_draw(false)
			var image := root.get_texture().get_image()
			_check(image != null and image.get_size() == Vector2i(1280, 720), "%s %s returned an invalid viewport." % [character_id, pose])
			if image != null and not image.is_empty():
				var background := image.get_pixel(0, 0)
				var visible_samples := 0
				for y in range(0, image.get_height(), 8):
					for x in range(0, image.get_width(), 8):
						var pixel := image.get_pixel(x, y)
						var color_delta := absf(pixel.r - background.r) + absf(pixel.g - background.g) + absf(pixel.b - background.b)
						if color_delta > 0.18:
							visible_samples += 1
				_check(visible_samples > 100, "%s %s rendered a visible mesh (%d sampled pixels)." % [character_id, pose, visible_samples])
				if pose == "neutral":
					neutral_capture = image.duplicate()
				elif neutral_capture != null:
					var changed_samples := 0
					for y in range(0, image.get_height(), 8):
						for x in range(0, image.get_width(), 8):
							var delta := image.get_pixel(x, y) - neutral_capture.get_pixel(x, y)
							if absf(delta.r) + absf(delta.g) + absf(delta.b) > 0.18:
								changed_samples += 1
					_check(changed_samples > 5, "%s %s visibly differs from neutral (%d sampled pixels)." % [character_id, pose, changed_samples])
				var path := absolute_dir.path_join("%s_%s.png" % [character_id, pose])
				var save_error := image.save_png(path)
				_check(save_error == OK, "Could not save %s (%d)." % [path, save_error])
			preview.queue_free()
			await process_frame
	if failures == 0:
		print("PASS: captured 60 display-rendered candidate pose images (10 profiles × 6 generic pose transforms).")
		print("LIMIT: these are visual diagnostics for quarantined flattened-image meshes, not authored animations or art approval.")
		quit(0)
	else:
		push_error("%d profile mesh capture checks failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("PROFILE MESH CAPTURE FAILED: " + message)
