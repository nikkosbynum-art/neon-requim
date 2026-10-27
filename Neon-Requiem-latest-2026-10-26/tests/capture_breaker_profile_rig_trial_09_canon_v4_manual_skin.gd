extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v4_manual_skin_preview.tscn"
const OUT_DIR := "res://docs/visual_qa"
const POSE_SAMPLE_TIMES := {
	"idle": 0.50,
	"walk": 0.1625,
	"punch": 0.22,
	"hit": 0.08,
	"defeat": 0.75,
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Could not load candidate 09 v4 arm review rig.")
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	await process_frame
	for pose in POSE_SAMPLE_TIMES:
		rig.play_pose(pose)
		rig.animation_player.seek(float(POSE_SAMPLE_TIMES[pose]), true)
		rig.animation_player.advance(0.0)
		rig.animation_player.pause()
		await process_frame
		var capture := root.get_viewport().get_texture().get_image()
		if capture == null or capture.is_empty():
			push_error("Godot returned an empty viewport capture for %s." % pose)
			quit(1)
			return
		var path := ProjectSettings.globalize_path(OUT_DIR + "/breaker_trial09_v4_manual_skin_%s.png" % pose)
		var error := capture.save_png(path)
		if error != OK:
			push_error("Could not save %s capture: %s" % [pose, error_string(error)])
			quit(1)
			return
		print("Saved %s" % path)
	rig.queue_free()
	await process_frame
	quit(0)
