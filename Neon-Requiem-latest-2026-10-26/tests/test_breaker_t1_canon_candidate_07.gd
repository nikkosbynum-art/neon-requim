extends SceneTree

const ART_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.png"
const EXPECTED_CANVAS := Vector2i(1024, 1536)
const TARGET_VISIBLE_HEIGHT := 256.0
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# tier_01_drafts is intentionally excluded from Godot's runtime import scan;
	# read the quarantined file directly so the audit does not add a runtime reference.
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(ART_PATH))
	_check(load_error == OK, "Godot must decode the quarantined candidate directly from disk.")
	if load_error != OK:
		quit(1)
		return
	_check(image.get_size() == EXPECTED_CANVAS, "Candidate must remain a 1024×1536 image.")
	if image.get_size() != EXPECTED_CANVAS:
		quit(1)
		return
	for corner in [Vector2i(0, 0), Vector2i(1023, 0), Vector2i(0, 1535), Vector2i(1023, 1535)]:
		_check(image.get_pixelv(corner).a == 0.0, "All canvas corners must be fully transparent.")
	var min_y := image.get_height()
	var max_y := -1
	var rear_boot_bottom := -1
	var front_boot_bottom := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.96:
				continue
			min_y = mini(min_y, y)
			max_y = maxi(max_y, y)
			if y >= 1200 and x >= 120 and x < 460:
				rear_boot_bottom = maxi(rear_boot_bottom, y)
			if y >= 1200 and x >= 600 and x < 980:
				front_boot_bottom = maxi(front_boot_bottom, y)
	var visible_height := max_y - min_y + 1
	var baseline_delta := absf(float(rear_boot_bottom - front_boot_bottom))
	var projected_baseline_delta := baseline_delta * TARGET_VISIBLE_HEIGHT / float(visible_height)
	_check(max_y >= min_y and visible_height >= 1400 and visible_height <= 1500, "Visible character bounds must remain within expected full-body range.")
	_check(rear_boot_bottom >= 0 and front_boot_bottom >= 0 and projected_baseline_delta <= 6.0, "Both boot regions must meet the shared floor within 6 px at review scale.")
	print("Godot candidate 07: canvas=%s visible_height=%dpx boot_delta=%.2fpx at 256 px target." % [image.get_size(), visible_height, projected_baseline_delta])
	if failures == 0:
		print("PASS: Godot image decode, alpha, target visible height, and foot-ground checks. Visual canon remains a manual review and no animation is asserted.")
		quit(0)
	else:
		push_error("%d candidate-07 Godot image check(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 07 TEST FAILED: " + message)
