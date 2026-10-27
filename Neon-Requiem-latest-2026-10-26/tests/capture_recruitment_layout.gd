extends SceneTree

func _initialize() -> void:
	call_deferred("_capture_layouts")


func _capture_layouts() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame
	main._show_recruitment_dialog()
	for capture in [
		{"size": Vector2i(800, 450), "path": "res://tests/recruitment_ui_800x450.png"},
		{"size": Vector2i(1280, 720), "path": "res://tests/recruitment_ui_1280x720.png"}
	]:
		root.size = capture["size"]
		await process_frame
		await process_frame
		var frame := root.get_texture().get_image()
		if frame.get_size() != capture["size"]:
			push_error("Recruitment capture size mismatch: expected %s, got %s." % [str(capture["size"]), str(frame.get_size())])
			quit(1)
			return
		var absolute_path := ProjectSettings.globalize_path(str(capture["path"]))
		var save_error: Error = frame.save_png(absolute_path)
		if save_error != OK:
			push_error("Could not save Recruitment UI capture at %s (error %d)." % [absolute_path, save_error])
			quit(1)
			return
		print("RECRUITMENT_CAPTURE=%s" % absolute_path)
	main.queue_free()
	quit(0)
