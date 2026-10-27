extends SceneTree

const REFERENCE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_cutout_candidate_02.png"
const EDIT_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_hidden_anatomy_candidate_03.png"
const ALPHA_THRESHOLD := 245.0 / 255.0
const MIN_SILHOUETTE_IOU := 0.97
const MAX_VISIBLE_RGB_MAE := 20.0
const MAX_BOUND_DELTA_PX := 4
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var reference := _load_image(REFERENCE_PATH)
	var edited := _load_image(EDIT_PATH)
	if reference == null or edited == null:
		quit(1)
		return
	_check(reference.get_size() == edited.get_size() and reference.get_size() == Vector2i(1024, 1536), "Both images must preserve the 1024×1536 source canvas.")
	_check(edited.get_pixel(10, 10).a == 0.0, "The edited candidate must retain a genuinely transparent background.")
	var reference_bounds := _alpha_bounds(reference)
	var edited_bounds := _alpha_bounds(edited)
	var intersection := 0
	var union := 0
	var color_error := 0.0
	var color_samples := 0
	for y in range(reference.get_height()):
		for x in range(reference.get_width()):
			var reference_pixel := reference.get_pixel(x, y)
			var edited_pixel := edited.get_pixel(x, y)
			var reference_visible := reference_pixel.a >= ALPHA_THRESHOLD
			var edited_visible := edited_pixel.a >= ALPHA_THRESHOLD
			if reference_visible or edited_visible:
				union += 1
			if reference_visible and edited_visible:
				intersection += 1
			if reference_visible:
				color_error += absf(reference_pixel.r - edited_pixel.r) * 255.0
				color_error += absf(reference_pixel.g - edited_pixel.g) * 255.0
				color_error += absf(reference_pixel.b - edited_pixel.b) * 255.0
				color_samples += 3
	var silhouette_iou := float(intersection) / maxf(float(union), 1.0)
	var visible_rgb_mae := color_error / maxf(float(color_samples), 1.0)
	var max_bound_delta := maxi(
		maxi(absi(reference_bounds.position.x - edited_bounds.position.x), absi(reference_bounds.position.y - edited_bounds.position.y)),
		maxi(absi(reference_bounds.end.x - edited_bounds.end.x), absi(reference_bounds.end.y - edited_bounds.end.y))
	)
	_check(silhouette_iou >= MIN_SILHOUETTE_IOU, "Visible silhouette IoU %.4f must be at least %.2f." % [silhouette_iou, MIN_SILHOUETTE_IOU])
	_check(visible_rgb_mae <= MAX_VISIBLE_RGB_MAE, "Visible RGB mean absolute error %.2f must be <= %.1f / 255." % [visible_rgb_mae, MAX_VISIBLE_RGB_MAE])
	_check(max_bound_delta <= MAX_BOUND_DELTA_PX, "High-alpha silhouette bound drift %d px must be <= %d px." % [max_bound_delta, MAX_BOUND_DELTA_PX])
	print("Fidelity comparison candidate 02 → 03: IoU %.4f, visible RGB MAE %.2f/255, max bound drift %d px." % [silhouette_iou, visible_rgb_mae, max_bound_delta])
	if failures == 0:
		print("PASS: edited candidate remains within the approved-direction cutout fidelity gate. This is a visual similarity gate, not proof of hidden anatomy or art approval.")
		quit(0)
	else:
		push_error("%d BREAKER visual-fidelity check(s) failed." % failures)
		quit(1)


func _load_image(path: String) -> Image:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(path))
	_check(error == OK, "Could not load fidelity image: %s." % path)
	return image if error == OK else null


func _alpha_bounds(image: Image) -> Rect2i:
	var minimum := Vector2i(image.get_width(), image.get_height())
	var maximum := Vector2i.ZERO
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a >= ALPHA_THRESHOLD:
				minimum.x = mini(minimum.x, x)
				minimum.y = mini(minimum.y, y)
				maximum.x = maxi(maximum.x, x + 1)
				maximum.y = maxi(maximum.y, y + 1)
	return Rect2i(minimum, maximum - minimum)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER FIDELITY CHECK FAILED: " + message)
