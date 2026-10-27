extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_09_canon_v2_preview.tscn"
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Candidate 09 v2 preview scene must load.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	rig.play_pose("defeat")
	rig.animation_player.seek(0.0, true)
	rig.animation_player.advance(0.0)
	_check(absf(rig.visual_root.modulate.a - 1.0) < 0.01, "Defeat begins fully visible.")
	rig.animation_player.seek(0.75, true)
	rig.animation_player.advance(0.0)
	_check(absf(rig.visual_root.modulate.a - 0.72) < 0.02, "Late-defeat fade matches its reviewed key.")
	_check(absf(rig.visual_root.rotation - 1.05) < 0.05, "Late-defeat fall should tip the assembled silhouette forward as one connected layer group.")
	_check(absf(rig.get_bone_rotation("Torso") + 0.30) < 0.03, "Late-defeat torso pose should reach the reviewed connected slump.")
	_check(absf(rig.get_bone_rotation("LeftKnee") - 0.28) < 0.03, "Late-defeat front knee should bend into the reviewed slump.")
	_check(rig.get_anchor_global_position().distance_to(Vector2(640.0, 590.0)) < 0.001, "Defeat keeps the world ground anchor stable.")
	rig.animation_player.seek(0.95, true)
	rig.animation_player.advance(0.0)
	_check(rig.visual_root.modulate.a <= 0.01, "Defeated character finishes fading out.")
	_check(rig.get_anchor_global_position().distance_to(Vector2(640.0, 590.0)) < 0.001, "Fade-out keeps the ground anchor stable.")
	print("Candidate 09 v2 defeat fade alpha: start=%.2f mid=%.2f end=%.2f." % [1.0, 0.72, rig.visual_root.modulate.a])
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: restrained defeat/slump fade and stable anchor. Visual concept only; does not certify a final collapse animation.")
		quit(0)
	else:
		push_error("%d candidate 09 v2 defeat checks failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 09 V2 DEFEAT TEST FAILED: " + message)
