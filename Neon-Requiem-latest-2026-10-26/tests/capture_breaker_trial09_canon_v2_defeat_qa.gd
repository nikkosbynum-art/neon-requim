extends SceneTree

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v2_preview.tscn"
const STAGE_SCRIPT := preload("res://tests/breaker_trial09_defeat_review_stage.gd")
const OUTPUT_PATH := "res://docs/visual_qa/breaker_trial09_canon_v2_defeat_1280x720.png"
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	_check(packed != null, "Candidate 09 canon v2 review rig should load.")
	if packed == null:
		quit(1)
		return
	var stage := Node2D.new()
	stage.set_script(STAGE_SCRIPT)
	root.add_child(stage)
	var rig: Variant = packed.instantiate()
	rig.draw_review_stage = false
	stage.add_child(rig)
	await process_frame
	rig.visual_root.position = Vector2(640.0, 612.0)
	rig.play_pose("defeat")
	rig.animation_player.seek(0.75, true)
	rig.animation_player.advance(0.0)
	_check(rig.load_failures == 0 and rig.loaded_part_count == 13, "All trial layers should load for the defeat review.")
	_check(absf(rig.visual_root.rotation - 1.05) < 0.05, "Review sample should show the forward fall pose.")
	_check(rig.get_anchor_global_position().distance_to(Vector2(640.0, 612.0)) < 0.001, "Fall should rotate around and preserve the ground anchor.")
	await process_frame
	var image := root.get_texture().get_image()
	_check(image != null and image.get_size() == Vector2i(1280, 720), "Expected a full-resolution 1280×720 defeat review image.")
	if image != null and not image.is_empty():
		var output := ProjectSettings.globalize_path(OUTPUT_PATH)
		_check(DirAccess.make_dir_recursive_absolute(output.get_base_dir()) == OK, "Could not create visual QA output folder.")
		_check(image.save_png(output) == OK, "Could not save the defeat review image.")
		print("Captured BREAKER candidate 09 v2 defeat review: %s" % output)
	rig.queue_free()
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: isolated 0.75 s forward-fall review captured at the full 256 px character scale.")
		quit(0)
	else:
		push_error("%d candidate 09 v2 defeat capture checks failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 09 V2 DEFEAT CAPTURE FAILED: " + message)
