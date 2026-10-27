extends SceneTree

## Read-only Research dialog preview. No research nodes are configured, and no
## save or Influence purchase is performed.
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const TARGET_SIZES := [Vector2i(1280, 720), Vector2i(800, 450)]
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load main scene for research preview.")
	if failures > 0:
		quit(1)
		return
	var main: Variant = packed.instantiate()
	root.add_child(main)
	await process_frame
	var original_size := root.size
	main.permanent_state["spendable_influence"] = 7
	main.permanent_state["research_nodes"] = {}
	for target_size in TARGET_SIZES:
		root.size = target_size
		main._show_research_dialog()
		await process_frame
		await create_timer(0.25).timeout
		_check(main.research_dialog.visible, "Research dialog should be visible at %s." % str(target_size))
		var dialog_text: String = main._research_dialog_text()
		_check(dialog_text.contains("Combat Protocols") and dialog_text.contains("Underground Economy") and dialog_text.contains("Network Infrastructure") and dialog_text.contains("Personnel Development"), "Dialog should show all four approved branches.")
		_check(dialog_text.contains("No Influence is spent"), "Dialog must explain that the framework preview makes no purchases.")
		_check(main.research_balance_label.text.contains("7"), "Dialog should show the spendable Influence test state without changing it.")
		_check(int(main.permanent_state["spendable_influence"]) == 7 and main.permanent_state["research_nodes"].is_empty(), "Showing research must not spend Influence or create ranks.")
		var texture := root.get_texture()
		var image := texture.get_image() if texture != null else null
		_check(image != null and not image.is_empty(), "No rendered research dialog viewport at %s." % str(target_size))
		if image != null and not image.is_empty():
			var output_dir := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
			_check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "Could not create visual QA output folder.")
			var output_path := _available_output_path(output_dir, "research_framework_%dx%d.png" % [target_size.x, target_size.y])
			var save_error: Error = image.save_png(output_path)
			_check(save_error == OK, "Could not save research preview image (error %d)." % save_error)
			if save_error == OK:
				print("Captured read-only research preview: %s" % output_path)
		main.research_dialog.hide()
	root.size = original_size
	main.queue_free()
	await process_frame
	if failures == 0:
		print("Read-only research dialog preview passed at both sizes; no Influence or research records changed.")
		quit(0)
	else:
		push_error("%d research preview check(s) failed." % failures)
		quit(1)


func _available_output_path(directory: String, filename: String) -> String:
	var path := directory.path_join(filename)
	if not FileAccess.file_exists(path):
		return path
	var base := filename.get_basename()
	var extension := filename.get_extension()
	var suffix := 2
	while true:
		var candidate := directory.path_join("%s_%02d.%s" % [base, suffix, extension])
		if not FileAccess.file_exists(candidate):
			return candidate
		suffix += 1
	return path


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("RESEARCH FRAMEWORK PREVIEW FAILED: " + message)
