extends SceneTree

const ART_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
const EXPECTED_CANVAS := Vector2i(1024, 1536)
const TARGET_VISIBLE_HEIGHT := 256.0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(ART_PATH))
	_check(error == OK, "Godot must decode the quarantined image directly from disk.")
	if error != OK:
		quit(1)
		return
	_check(image.get_size() == EXPECTED_CANVAS, "Image must remain 1024×1536.")
	if image.get_size() != EXPECTED_CANVAS:
		quit(1)
		return
	var min_y := image.get_height()
	var max_y := -1
	var left_boot_bottom := -1
	var right_boot_bottom := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.96:
				continue
			min_y = mini(min_y, y)
			max_y = maxi(max_y, y)
			if y >= 1200 and x >= 120 and x < 460:
				left_boot_bottom = maxi(left_boot_bottom, y)
			if y >= 1200 and x >= 600 and x < 980:
				right_boot_bottom = maxi(right_boot_bottom, y)
	for corner in [Vector2i(0,0),Vector2i(1023,0),Vector2i(0,1535),Vector2i(1023,1535)]:
		_check(image.get_pixelv(corner).a == 0.0, "Canvas corners must remain fully transparent.")
	var height := max_y-min_y+1
	var delta := absf(float(left_boot_bottom-right_boot_bottom))*TARGET_VISIBLE_HEIGHT/float(height)
	_check(height >= 1400 and height <= 1500, "Visible full-body height is outside the expected range.")
	_check(left_boot_bottom >= 0 and right_boot_bottom >= 0 and delta <= 6.0, "Both boot regions must share the ground within 6 px at review scale.")
	print("Godot candidate 09: canvas=%s visible_height=%d px projected_boot_delta=%.2f px." % [image.get_size(),height,delta])
	if failures==0:
		print("PASS: direct image decode, alpha corners, full-body scale, and boot alignment. No rig/anatomy is asserted.")
		quit(0)
	else:
		push_error("%d candidate-09 image checks failed." % failures)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 09 TEST FAILED: " + message)
