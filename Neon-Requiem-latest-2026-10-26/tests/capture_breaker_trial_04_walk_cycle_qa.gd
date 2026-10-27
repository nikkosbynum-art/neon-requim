extends SceneTree

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_04_preview.tscn"
const REVIEW_STAGE_SCRIPT := preload("res://tests/breaker_profile_trial_04_review_stage.gd")
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const SAMPLE_TIMES := [0.0, 0.08, 0.1625, 0.245, 0.325, 0.4075, 0.4875, 0.57]
var failures := 0
var rigs: Array[Variant] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load isolated BREAKER profile rig.")
	if packed == null:
		quit(1)
		return
	var stage := Node2D.new()
	stage.set_script(REVIEW_STAGE_SCRIPT)
	stage.view_mode = "walk_cycle"
	root.add_child(stage)
	for index in range(SAMPLE_TIMES.size()):
		var rig: Variant = packed.instantiate()
		rig.draw_review_stage = false
		stage.add_child(rig)
		await process_frame
		_check(rig.load_failures == 0 and rig.loaded_part_count == 13 and rig.loaded_underpaint_count == 13, "Every gait sample must load all visible and inferred underpaint layers.")
		rig.visual_root.position = Vector2(80.0 + float(index) * 160.0, 612.0)
		rig.play_pose("walk")
		rig.animation_player.seek(float(SAMPLE_TIMES[index]), true)
		rig.animation_player.advance(0.0)
		rig.animation_player.pause()
		_check(rig.get_anchor_global_position().distance_to(Vector2(80.0 + float(index) * 160.0, 612.0)) < 0.001, "A gait pose changed the ground anchor.")
		rigs.append(rig)
	if failures > 0:
		quit(1)
		return
	await process_frame
	var image := root.get_texture().get_image()
	_check(image != null and image.get_width() == 1280 and image.get_height() == 720, "Expected a 1280×720 motion review capture.")
	if image != null and not image.is_empty():
		var output_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
		_check(DirAccess.make_dir_recursive_absolute(output_directory) == OK, "Could not create the visual QA folder.")
		var output_path := _available_output_path(output_directory, "breaker_profile_trial_04_walk_cycle_1280x720.png")
		var save_error: Error = image.save_png(output_path)
		_check(save_error == OK, "Could not save the gait cycle image (error %d)." % save_error)
		if save_error == OK:
			print("Captured quarantined BREAKER full walk cycle: %s" % output_path)
	for rig in rigs:
		rig.queue_free()
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: trial-04 eight-phase walk-cycle preview captured; this remains a review-only pose sheet, not anatomy certification.")
		quit(0)
	else:
		push_error("%d BREAKER gait capture check(s) failed." % failures)
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
		push_error("BREAKER WALK CYCLE CAPTURE FAILED: " + message)
