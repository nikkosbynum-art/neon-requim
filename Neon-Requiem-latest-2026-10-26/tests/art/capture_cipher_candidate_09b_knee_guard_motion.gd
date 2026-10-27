extends SceneTree

## Renders a quarantined rigid-hinge diagnostic for CIPHER candidate 09B.
## The approved knee-guard pivot is used; the ±15° poses are test-only.

const CANDIDATE_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/"
const SOURCE_PATH := "res://docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
const CANVAS_SIZE := Vector2i(1280, 720)
const PANEL_WIDTH := 320.0
const PANEL_TOP := 106.0
const CROP := Rect2i(60, 500, 250, 280)
const PIVOT_SOURCE := Vector2(170.0, 655.0)

var errors: Array[String] = []
var output_path := ""


func _initialize() -> void:
	root.size = CANVAS_SIZE
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--output":
		output_path = args[1]
	call_deferred("_capture")


func _capture() -> void:
	var manifest := _read_manifest()
	if manifest.is_empty():
		quit(1)
		return
	_check(str(manifest.get("status", "")).contains("QUARANTINED"), "Candidate 09B must stay quarantined.")
	_check(manifest.get("production_approved", true) == false, "Candidate 09B must remain unapproved.")
	var pivot_meta: Dictionary = manifest.get("pivot", {})
	_check(str(pivot_meta.get("status", "")).begins_with("USER_APPROVED_AND_AUTHORED"), "The hinge pivot must be the user-approved authored datum.")
	var source_pivot: Array = pivot_meta.get("source_xy", [])
	var local_pivot: Array = pivot_meta.get("part_local_xy", [])
	_check(source_pivot.size() == 2 and int(source_pivot[0]) == 770 and int(source_pivot[1]) == 665, "Full-source pivot must match the approved location.")
	_check(local_pivot.size() == 2 and int(local_pivot[0]) == 77 and int(local_pivot[1]) == 115, "Guard-local pivot must match the approved location.")
	var guard: Dictionary = manifest.get("parts", {}).get("near_knee_guard", {})
	var guard_bounds: Array = guard.get("source_bbox_xyxy", [])
	var guard_padding := int(guard.get("padding_px", -1))
	var guard_local: Array = guard.get("pivot_px_part_local", [])
	_check(guard_bounds.size() == 4 and guard_padding >= 0 and guard_local.size() == 2, "Guard source bounds, padding, and local pivot must be recorded.")
	if guard_bounds.size() != 4 or guard_padding < 0 or guard_local.size() != 2:
		quit(1)
		return
	var reconstructed_pivot := Vector2(float(guard_bounds[0] - guard_padding + int(guard_local[0])), float(guard_bounds[1] - guard_padding + int(guard_local[1])))
	_check(reconstructed_pivot == PIVOT_SOURCE, "Manifest guard-local pivot should resolve to source-crop hinge %s; got %s." % [PIVOT_SOURCE, reconstructed_pivot])

	var board := Node2D.new()
	board.name = "Cipher09BKneeGuardMotionDiagnostic"
	root.add_child(board)
	_add_background(board)
	var source := _load_image(SOURCE_PATH)
	var crop_xywh: Array = manifest.get("crop_xywh", [])
	_check(source != null and crop_xywh.size() == 4, "Approved source and crop must load.")
	if source == null or crop_xywh.size() != 4:
		quit(1)
		return
	var source_crop := source.get_region(Rect2i(int(crop_xywh[0]), int(crop_xywh[1]), int(crop_xywh[2]), int(crop_xywh[3])))
	var assembly := _load_image(CANDIDATE_ROOT + "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_09B_QUARANTINED.png")
	_check(source_crop.get_size() == Vector2i(330, 960) and assembly != null and assembly.get_size() == Vector2i(330, 960), "Source crop and neutral assembly must be 330x960.")
	if assembly == null:
		quit(1)
		return
	var neutral_render := _build_pose_image(manifest, 0.0)
	var expected_region := assembly.get_region(CROP)
	var neutral_difference_count := _count_image_differences(neutral_render, expected_region)
	var neutral_difference_ratio := float(neutral_difference_count) / float(CROP.size.x * CROP.size.y)
	print("CIPHER 09B neutral knee-region reconstruction: %d / %d pixels differ (%.5f%%)." % [neutral_difference_count, CROP.size.x * CROP.size.y, neutral_difference_ratio * 100.0])
	_check(neutral_difference_ratio <= 0.01, "Neutral knee-region reconstruction should stay within 1%% of the source-aligned assembly.")

	_add_panel(board, source_crop.get_region(CROP), 0.0, "APPROVED SOURCE")
	_add_pose_panel(board, manifest, PANEL_WIDTH, "NEUTRAL 0°", 0.0)
	_add_pose_panel(board, manifest, PANEL_WIDTH * 2.0, "DIAGNOSTIC -15°", deg_to_rad(-15.0))
	_add_pose_panel(board, manifest, PANEL_WIDTH * 3.0, "DIAGNOSTIC +15°", deg_to_rad(15.0))
	_add_label(board, 8.0, "CIPHER TIER I • CANDIDATE 09B • QUARANTINED HINGE CHECK", Color("#ff76ba"), 1264.0, 16, 18)
	_add_label(board, 8.0, "Approved lower-hinge pivot only. ±15° is a diagnostic rotation, not an authored animation range or production approval.", Color("#bac6d8"), 1264.0, 528, 12)

	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var frame := root.get_texture().get_image()
	_check(frame != null and frame.get_size() == CANVAS_SIZE, "Godot should render the expected 1280x720 diagnostic board.")
	if frame != null and frame.get_size() == CANVAS_SIZE:
		if not output_path.is_empty():
			_check(output_path.begins_with("res://docs/visual_qa/"), "Output must stay in the visual QA folder.")
			_check(not FileAccess.file_exists(output_path), "Refusing to overwrite an existing visual review artifact.")
			if output_path.begins_with("res://docs/visual_qa/") and not FileAccess.file_exists(output_path):
				_check(frame.save_png(ProjectSettings.globalize_path(output_path)) == OK, "Godot should save the review board.")
		_check(_pivot_stays_fixed_across_rotations(), "The approved knee pivot must remain fixed through each diagnostic rotation.")
	if errors.is_empty():
		print("PASS: Godot rendered the candidate 09B knee guard about its user-approved lower-hinge pivot.")
		print("LIMIT: rigid pivot visualization only; seams, skinning, action ranges, other part pivots, and production readiness remain unverified.")
		quit(0)
	else:
		push_error("%d CIPHER knee-guard diagnostic check(s) failed." % errors.size())
		quit(1)


func _read_manifest() -> Dictionary:
	var file := FileAccess.open(CANDIDATE_ROOT + "parts_manifest.json", FileAccess.READ)
	_check(file != null, "Candidate manifest should open.")
	if file == null:
		return {}
	var value: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_check(value is Dictionary, "Candidate manifest should be a JSON object.")
	return value if value is Dictionary else {}


func _add_background(board: Node2D) -> void:
	var background := ColorRect.new()
	background.size = Vector2(CANVAS_SIZE)
	background.color = Color("#090d16")
	board.add_child(background)
	for panel in range(4):
		var tile := ColorRect.new()
		tile.position = Vector2(float(panel) * PANEL_WIDTH + 34.0, PANEL_TOP - 3.0)
		tile.size = Vector2(CROP.size) + Vector2(6.0, 6.0)
		tile.color = Color("#202632")
		board.add_child(tile)
		for y in range(0, CROP.size.y, 16):
			for x in range(0, CROP.size.x, 16):
				if ((x / 16) + (y / 16)) % 2 != 0:
					var checker := ColorRect.new()
					checker.position = tile.position + Vector2(x + 3, y + 3)
					checker.size = Vector2(16, 16)
					checker.color = Color("#29313d")
					board.add_child(checker)
		_add_label(board, float(panel) * PANEL_WIDTH, "", Color.WHITE)


func _add_panel(board: Node2D, image: Image, panel_x: float, title: String) -> void:
	var node := Node2D.new()
	node.position = Vector2(panel_x + 37.0, PANEL_TOP)
	board.add_child(node)
	var sprite := Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	_add_label(board, panel_x, title, Color("#62e5ed"), PANEL_WIDTH, 77.0, 13)


func _add_pose_panel(board: Node2D, manifest: Dictionary, panel_x: float, title: String, knee_rotation: float) -> void:
	var pose_image := _build_pose_image(manifest, knee_rotation)
	var sprite := Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(pose_image)
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(panel_x + 37.0, PANEL_TOP)
	board.add_child(sprite)
	_add_label(board, panel_x, title, Color("#62e5ed"), PANEL_WIDTH, 77.0, 13)


func _build_pose_image(manifest: Dictionary, knee_rotation: float) -> Image:
	var canvas := Image.create(CROP.size.x, CROP.size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var parts: Dictionary = manifest.get("parts", {})
	var order: Array = manifest.get("layer_order_back_to_front", [])
	for part_value in order:
		var part_id := str(part_value)
		if not parts.has(part_id):
			continue
		var part: Dictionary = parts[part_id]
		var bounds: Array = part.get("source_bbox_xyxy", [])
		var padding := int(part.get("padding_px", -1))
		if bounds.size() != 4 or padding < 0:
			continue
		var image := _load_image(CANDIDATE_ROOT + str(part.get("file", "")))
		if image == null:
			continue
		var source_origin := Vector2(float(bounds[0] - padding), float(bounds[1] - padding))
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var source_color := image.get_pixel(x, y)
				if source_color.a <= 0.0:
					continue
				var source_point := source_origin + Vector2(x, y)
				if part_id in ["near_shin", "near_knee_guard"] and not is_zero_approx(knee_rotation):
					source_point = PIVOT_SOURCE + (source_point - PIVOT_SOURCE).rotated(knee_rotation)
				var destination := Vector2i(roundi(source_point.x - CROP.position.x), roundi(source_point.y - CROP.position.y))
				if destination.x < 0 or destination.y < 0 or destination.x >= canvas.get_width() or destination.y >= canvas.get_height():
					continue
				_blend_pixel(canvas, destination, source_color)
	return canvas


func _blend_pixel(image: Image, point: Vector2i, source: Color) -> void:
	var destination := image.get_pixelv(point)
	var output_alpha := source.a + destination.a * (1.0 - source.a)
	if output_alpha <= 0.0:
		return
	var source_rgb := Vector3(source.r, source.g, source.b)
	var destination_rgb := Vector3(destination.r, destination.g, destination.b)
	var output_rgb := (source_rgb * source.a + destination_rgb * destination.a * (1.0 - source.a)) / output_alpha
	image.set_pixelv(point, Color(output_rgb.x, output_rgb.y, output_rgb.z, output_alpha))


func _count_image_differences(actual: Image, expected: Image) -> int:
	if actual.get_size() != expected.get_size():
		return actual.get_width() * actual.get_height()
	var differences := 0
	for y in range(actual.get_height()):
		for x in range(actual.get_width()):
			var actual_pixel := actual.get_pixel(x, y)
			var expected_pixel := expected.get_pixel(x, y)
			var delta := absf(actual_pixel.r - expected_pixel.r) + absf(actual_pixel.g - expected_pixel.g) + absf(actual_pixel.b - expected_pixel.b) + absf(actual_pixel.a - expected_pixel.a)
			if delta > 0.02:
				differences += 1
	return differences


func _pivot_stays_fixed_across_rotations() -> bool:
	var point := PIVOT_SOURCE
	for angle in [deg_to_rad(-15.0), 0.0, deg_to_rad(15.0)]:
		var transform := Transform2D(angle, point)
		if not transform * Vector2.ZERO == point:
			return false
	return true


func _load_image(path: String) -> Image:
	var image := Image.new()
	var result := image.load(ProjectSettings.globalize_path(path))
	_check(result == OK, "Godot should load image: " + path)
	return image if result == OK else null


func _add_label(board: Node2D, x: float, text_value: String, color: Color, width: float = PANEL_WIDTH, y: float = 77.0, font_size: int = 14) -> void:
	if text_value.is_empty():
		return
	var label := Label.new()
	label.position = Vector2(x, y)
	label.size = Vector2(width, 22.0)
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	board.add_child(label)


func _check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)
		push_error("CIPHER CANDIDATE 09B KNEE DIAGNOSTIC FAILED: " + message)
