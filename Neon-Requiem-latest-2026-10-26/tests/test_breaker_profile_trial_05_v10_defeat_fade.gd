extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_05_candidate05_v10_preview.tscn"
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load the isolated v10 review scene.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0 and rig.loaded_part_count == 13 and rig.loaded_underpaint_count == 13, "All visible and inferred layers should load.")
	_check(rig.animation_player.has_animation("defeat"), "Defeat preview clip is missing.")
	rig.play_pose("defeat")
	rig.animation_player.seek(0.0, true)
	rig.animation_player.advance(0.0)
	_check(is_equal_approx(rig.visual_root.modulate.a, 1.0), "Defeat should begin fully visible.")
	rig.animation_player.seek(0.55, true)
	rig.animation_player.advance(0.0)
	_check(absf(rig.visual_root.modulate.a - 0.72) < 0.02, "Mid-clip fade should match the reviewed alpha key.")
	rig.animation_player.seek(0.95, true)
	rig.animation_player.advance(0.0)
	_check(rig.visual_root.modulate.a <= 0.01, "Defeat should be fully faded by the end of the clip.")
	_check(rig.get_anchor_global_position().distance_to(Vector2(640.0, 590.0)) < 0.001, "Defeat fade must preserve the world ground anchor.")
	print("Defeat fade alpha: start=%.2f mid=%.2f end=%.2f; anchor stable." % [1.0, 0.72, rig.visual_root.modulate.a])
	rig.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: v10 isolated defeat fade keys load and interpolate at the reviewed times. This is not art or anatomy approval.")
		quit(0)
	else:
		push_error("%d v10 defeat fade check(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER V10 DEFEAT FADE TEST FAILED: " + message)
