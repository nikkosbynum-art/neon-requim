extends SceneTree

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_02_preview.tscn"
const STAGE_SCRIPT := preload("res://tests/breaker_profile_trial_02_review_stage.gd")
const OUTPUT_DIRECTORY := "res://docs/visual_qa"
const ACTIONS := [
	{"pose": "idle", "time": 0.50},
	{"pose": "walk", "time": 0.1625},
	{"pose": "punch", "time": 0.22},
	{"pose": "hit", "time": 0.08},
	{"pose": "defeat", "time": 0.95}
]
var failures := 0
var rigs: Array[Variant] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(RIG_SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the isolated BREAKER production-gate rig.")
	if packed == null:
		quit(1)
		return
	await _capture_actions(packed)
	if failures == 0:
		await _capture_squad(packed)
	if failures == 0:
		print("PASS: five-action sheet and six-unit full-size review captured. These remain quarantined review fixtures, not production art approval.")
		quit(0)
	else:
		push_error("%d BREAKER production-gate capture check(s) failed." % failures)
		quit(1)


func _capture_actions(packed: PackedScene) -> void:
	var stage := _make_stage("actions")
	for index in range(ACTIONS.size()):
		var rig: Variant = packed.instantiate()
		rig.draw_review_stage = false
		stage.add_child(rig)
		await process_frame
		rig.visual_root.position = Vector2(128.0 + float(index) * 256.0, 612.0)
		var action: Dictionary = ACTIONS[index]
		rig.play_pose(str(action["pose"]))
		rig.animation_player.seek(float(action["time"]), true)
		rig.animation_player.advance(0.0)
		rig.animation_player.pause()
		_check(rig.load_failures == 0 and rig.loaded_part_count == 13, "Action %s must load all profile layers." % str(action["pose"]))
		_check(is_equal_approx(rig.skeleton.scale.y * 1427.0, 256.0), "Action %s must render at 256 px visible height." % str(action["pose"]))
		rigs.append(rig)
	await process_frame
	_save_view("breaker_profile_trial_02_actions_1280x720.png")
	_free_review_rigs(stage)
	await process_frame


func _capture_squad(packed: PackedScene) -> void:
	var stage := _make_stage("squad")
	for index in range(6):
		var rig: Variant = packed.instantiate()
		rig.draw_review_stage = false
		stage.add_child(rig)
		await process_frame
		var slot_width := 1280.0 / 6.0
		rig.visual_root.position = Vector2(slot_width * (float(index) + 0.5), 612.0)
		rig.play_pose("walk")
		rig.animation_player.seek(0.04 + float(index) * 0.075, true)
		rig.animation_player.advance(0.0)
		rig.animation_player.pause()
		_check(rig.loaded_part_count == 13 and is_equal_approx(rig.skeleton.scale.y * 1427.0, 256.0), "Six-unit sample %d must use all parts at the full visible-height target." % (index + 1))
		rigs.append(rig)
	await process_frame
	_save_view("breaker_profile_trial_02_six_unit_1280x720.png")
	_free_review_rigs(stage)
	await process_frame


func _make_stage(mode: String) -> Node2D:
	var stage := Node2D.new()
	stage.set_script(STAGE_SCRIPT)
	stage.view_mode = mode
	root.add_child(stage)
	return stage


func _save_view(filename: String) -> void:
	var image := root.get_texture().get_image()
	_check(image != null and image.get_width() == 1280 and image.get_height() == 720, "Expected a 1280×720 rendered review.")
	if image == null or image.is_empty():
		return
	var output_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	_check(DirAccess.make_dir_recursive_absolute(output_directory) == OK, "Could not create the visual-QA folder.")
	var output_path := _available_output_path(output_directory, filename)
	var save_error: Error = image.save_png(output_path)
	_check(save_error == OK, "Could not save %s (error %d)." % [filename, save_error])
	if save_error == OK:
		print("Captured BREAKER production-gate review: %s" % output_path)


func _free_review_rigs(stage: Node2D) -> void:
	for rig in rigs:
		rig.queue_free()
	rigs.clear()
	stage.queue_free()


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
		push_error("BREAKER PRODUCTION GATE CAPTURE FAILED: " + message)
