extends SceneTree

const WIDTH := 1024
const HEIGHT := 1536
const ORIGINAL_PATH := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v8/cyber_upper_arm.png"
const SKIN_PATH := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_arm_split_v1/visible_human_upper_arm_surface.png"
const SHELL_PATH := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_arm_split_v1/external_shoulder_shell.png"
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var original := _load_image(ORIGINAL_PATH)
	var skin := _load_image(SKIN_PATH)
	var shell := _load_image(SHELL_PATH)
	if original == null or skin == null or shell == null:
		quit(1)
		return
	_check(original.get_size() == Vector2i(WIDTH, HEIGHT), "Source arm layer must remain on the 1024×1536 common canvas.")
	_check(skin.get_size() == Vector2i(WIDTH, HEIGHT), "Skin-surface layer must retain the common canvas.")
	_check(shell.get_size() == Vector2i(WIDTH, HEIGHT), "Shoulder-shell layer must retain the common canvas.")
	if failures > 0:
		quit(1)
		return

	var rebuilt := Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	rebuilt.fill(Color(0, 0, 0, 0))
	rebuilt.blend_rect(skin, Rect2i(0, 0, WIDTH, HEIGHT), Vector2i.ZERO)
	rebuilt.blend_rect(shell, Rect2i(0, 0, WIDTH, HEIGHT), Vector2i.ZERO)
	var skin_pixels := 0
	var shell_pixels := 0
	var overlap_pixels := 0
	var differing_pixels := 0
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var pos := Vector2i(x, y)
			var skin_color: Color = skin.get_pixelv(pos)
			var shell_color: Color = shell.get_pixelv(pos)
			var source_color: Color = original.get_pixelv(pos)
			if skin_color.a > 0.0:
				skin_pixels += 1
			if shell_color.a > 0.0:
				shell_pixels += 1
			if skin_color.a > 0.0 and shell_color.a > 0.0:
				overlap_pixels += 1
			var rebuilt_color: Color = rebuilt.get_pixelv(pos)
			if source_color.a > 0.0 and rebuilt_color != source_color:
				differing_pixels += 1
			elif source_color.a == 0.0 and rebuilt_color.a > 0.0:
				differing_pixels += 1
	_check(skin_pixels > 3000, "Visible skin-surface component must contain the inspected bicep patch.")
	_check(shell_pixels > 10000, "External shell component must contain the hardware silhouette.")
	_check(overlap_pixels == 0, "Split components must have exclusive pixel ownership.")
	_check(differing_pixels == 0, "Skin plus shell must reconstruct the original visible arm layer exactly.")
	print("Godot arm split: skin=%d shell=%d overlap=%d differing=%d." % [skin_pixels, shell_pixels, overlap_pixels, differing_pixels])
	if failures == 0:
		print("PASS: direct disk decode, shared canvas, disjoint component alpha, exact neutral reconstruction.")
		print("LIMIT: hidden anatomy and motion are not asserted; outputs remain quarantined.")
		quit(0)
	else:
		push_error("%d BREAKER arm-split assertion(s) failed." % failures)
		quit(1)


func _load_image(path: String) -> Image:
	var result := Image.new()
	var error := result.load(ProjectSettings.globalize_path(path))
	_check(error == OK, "Could not decode %s directly from disk." % path)
	return result if error == OK else null


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER ARM-SPLIT TEST FAILED: " + message)
