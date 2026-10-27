extends SceneTree

const IMAGE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_component_sheet_candidate_11.png"
const EXPECTED_SIZE := Vector2i(1024, 1536)
var failures := 0


func _initialize() -> void:
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(IMAGE_PATH))
	_check(load_error == OK, "Godot must decode candidate 11 directly from disk.")
	if load_error != OK:
		quit(1)
		return
	_check(image.get_size() == EXPECTED_SIZE, "Candidate 11 must retain the shared reference canvas size.")
	var corner_points := [Vector2i(0, 0), Vector2i(1023, 0), Vector2i(0, 1535), Vector2i(1023, 1535)]
	var corners_transparent := true
	for point in corner_points:
		if image.get_pixelv(point).a > 0.0:
			corners_transparent = false
	_check(corners_transparent, "All four canvas corners must be fully transparent.")
	var alpha_range := image.get_used_rect()
	_check(alpha_range.size.x > 0 and alpha_range.size.y > 0, "The image must contain visible art pixels.")
	if failures == 0:
		print("PASS: Godot 4.7.2 directly decodes candidate 11, verifies the reference canvas, and confirms transparent corners.")
		print("LIMIT: this does not validate panel scales, pivots, attachment geometry, anatomy, or animation; production-art gate remains NOT PASSED.")
		quit(0)
	else:
		push_error("%d candidate 11 image checks failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 11 IMAGE TEST FAILED: " + message)
