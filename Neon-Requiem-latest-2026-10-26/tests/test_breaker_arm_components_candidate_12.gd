extends SceneTree

const IMAGE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_12.png"
const EXPECTED_SIZE := Vector2i(1774, 887)
const EXPECTED_SPANS := [Vector2i(150, 358), Vector2i(485, 822), Vector2i(928, 1255), Vector2i(1360, 1730)]

var failures := 0


func _initialize() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(IMAGE_PATH))
	_check(error == OK, "Godot must decode candidate 12 directly from disk.")
	if error != OK:
		quit(1)
		return
	_check(image.get_size() == EXPECTED_SIZE, "Candidate 12 must retain its audited 1774x887 canvas.")
	var corner_points := [Vector2i(0, 0), Vector2i(1773, 0), Vector2i(0, 886), Vector2i(1773, 886)]
	for point in corner_points:
		_check(image.get_pixelv(point).a == 0.0, "Canvas corners must be transparent.")

	var spans: Array[Vector2i] = []
	var in_span := false
	var start_x := 0
	for x in range(image.get_width()):
		var occupied := false
		for y in range(image.get_height()):
			if image.get_pixel(x, y).a * 255.0 >= 245.0:
				occupied = true
				break
		if occupied and not in_span:
			start_x = x
			in_span = true
		elif not occupied and in_span:
			spans.append(Vector2i(start_x, x - 1))
			in_span = false
	if in_span:
		spans.append(Vector2i(start_x, image.get_width() - 1))
	_check(spans == EXPECTED_SPANS, "Four separated opaque panel spans must match the static audit.")

	if failures == 0:
		print("PASS: Godot 4.7.2 decodes candidate 12 and verifies four transparent-gutter-separated panel regions.")
		print("LIMIT: no semantic anatomy, hidden-surface, pivot, full-body proportion, or animation approval.")
		quit(0)
	else:
		push_error("%d candidate 12 structure checks failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 12 TEST FAILED: " + message)
