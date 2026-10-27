extends SceneTree

const SOURCE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_cutout_candidate_02.png"
const THRESHOLD := 245
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(SOURCE_PATH))
	_check(error == OK, "The generated cutout candidate must load as an image.")
	if error != OK:
		quit(1)
		return
	_check(image.get_size() == Vector2i(1024, 1536), "The cutout candidate must preserve the shared 1024×1536 canvas.")
	_check(image.get_format() == Image.FORMAT_RGBA8, "The cutout candidate must retain RGBA alpha.")
	var threshold_bounds := Rect2i(1024, 1536, 0, 0)
	var high_alpha_pixels := 0
	var transparent_pixels := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var a := image.get_pixel(x, y).a
			if a <= 0.0:
				transparent_pixels += 1
			if a * 255.0 >= THRESHOLD:
				high_alpha_pixels += 1
				var point := Rect2i(x, y, 1, 1)
				threshold_bounds = threshold_bounds.merge(point) if high_alpha_pixels > 1 else point
	_check(transparent_pixels > 1000000, "Most background pixels should be fully transparent.")
	_check(high_alpha_pixels > 400000, "The subject should retain a dense high-alpha silhouette.")
	_check(threshold_bounds.position == Vector2i(239, 46), "High-alpha silhouette origin must match the recorded bounds.")
	_check(threshold_bounds.end == Vector2i(792, 1473), "High-alpha silhouette end must match the recorded bounds.")
	_check(image.get_pixel(10, 10).a == 0.0, "A known background sample should be fully transparent.")
	_check(image.get_pixel(500, 700).a >= float(THRESHOLD) / 255.0, "A known torso sample should remain in the subject.")
	if failures == 0:
		print("PASS: candidate 02 is 1024×1536 RGBA with transparent background and expected high-alpha silhouette bounds; this does not certify art readiness.")
		quit(0)
	else:
		push_error("%d cutout candidate checks failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CUTOUT CANDIDATE 02 FAILED: " + message)
