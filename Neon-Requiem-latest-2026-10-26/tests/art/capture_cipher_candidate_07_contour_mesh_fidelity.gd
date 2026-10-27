extends SceneTree

## Render-only comparison for quarantined CIPHER candidate 07 or 09B contour meshes.
## It does not create a rig, assign weights/pivots, or alter any artwork.

const BUILDER := preload("res://tools/art/polyrig_contour_mesh_builder.gd")
const CANDIDATE_07_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07/"
const CANDIDATE_09B_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/"
const SOURCE_PATH := "res://docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
const CANVAS_SIZE := Vector2i(1280, 720)
const ART_SCALE := 0.5
const PANEL_X := [0.0, 426.0, 852.0]
const PANEL_WIDTH := 426.0
const PANEL_TOP := 92.0
const ART_TOP := 120.0
const ART_LEFT_MARGIN := 130.0
const ART_VISIBLE_SIZE := Vector2(330.0, 960.0) * ART_SCALE

var errors: Array[String] = []
var requested_output_path := ""
var candidate_root := CANDIDATE_07_ROOT
var candidate_label := "candidate 07"
var assembly_filename := "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_07_QUARANTINED.png"
var expected_part_count := 10


func _initialize() -> void:
	var user_args := OS.get_cmdline_user_args()
	var arg_index := 0
	while arg_index < user_args.size():
		var flag := user_args[arg_index]
		if arg_index + 1 >= user_args.size():
			errors.append("Missing value for argument: " + flag)
			break
		var value := user_args[arg_index + 1]
		if flag == "--output":
			requested_output_path = value
		elif flag == "--candidate":
			if value.to_lower() == "09b":
				candidate_root = CANDIDATE_09B_ROOT
				candidate_label = "candidate 09B"
				assembly_filename = "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_09B_QUARANTINED.png"
				expected_part_count = 11
			elif value.to_lower() != "07":
				errors.append("Candidate must be 07 or 09B.")
		else:
			errors.append("Unknown argument: " + flag)
		arg_index += 2
	call_deferred("_capture")


func _capture() -> void:
	var manifest_file := FileAccess.open(candidate_root + "parts_manifest.json", FileAccess.READ)
	_check(manifest_file != null, "Candidate manifest should open.")
	if manifest_file == null:
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	_check(parsed is Dictionary, "Candidate manifest should be a JSON object.")
	if not parsed is Dictionary:
		quit(1)
		return
	var manifest: Dictionary = parsed
	_check(str(manifest.get("status", "")).contains("QUARANTINED"), "Candidate must remain quarantined.")
	_check(manifest.get("production_approved", true) == false, "Candidate must remain unapproved.")

	var source_crop := _load_source_crop(manifest)
	var assembly := _load_image(candidate_root + assembly_filename)
	_check(source_crop != null and assembly != null, "Approved source crop and candidate assembly should load.")
	if source_crop == null or assembly == null:
		quit(1)
		return
	_check(source_crop.get_size() == Vector2i(330, 960), "Approved reference crop should be 330x960.")
	_check(assembly.get_size() == source_crop.get_size(), "Candidate assembly should match source crop dimensions.")

	var board := Node2D.new()
	board.name = "CipherContourMeshFidelityBoard"
	root.add_child(board)
	_add_board_background(board)
	_add_panel_art(board, source_crop, PANEL_X[0], "APPROVED ANATOMY PROFILE CROP")
	_add_panel_art(board, assembly, PANEL_X[1], "%s SOURCE-ALIGNED ASSEMBLY" % candidate_label.to_upper())
	_add_mesh_assembly(board, manifest, PANEL_X[2])
	_add_label(board, PANEL_X[2], "POLYRIG CONTOUR MESH RENDER", Color("#62e5ed"))
	_add_label(board, 10.0, "CONTOUR / TEXTURE INTAKE CHECK — VISUAL QA ONLY • QUARANTINED", Color("#ff76ba"), 1260.0, 19)
	_add_label(board, 12.0, "No pivots, weights, hidden anatomy, semantic approval, or production status are implied.", Color("#bac6d8"), 1256.0, 697, 11)

	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var frame := root.get_texture().get_image()
	var frame_valid := frame != null and frame.get_size() == CANVAS_SIZE
	_check(frame_valid, "Godot should render the 1280x720 comparison board; do not continue pixel reads on a mismatched viewport.")
	if frame_valid:
		var comparison := _compare_assembly_panels(frame, assembly, manifest)
		var difference := int(comparison["difference_count"])
		var ratio := float(difference) / float(int(ART_VISIBLE_SIZE.x) * int(ART_VISIBLE_SIZE.y))
		print("CIPHER %s mesh/source assembly sampled pixel difference: %d / %d (%.5f%%), strong deltas %d, alpha-edge samples %d, mesh-panel bounds %s..%s." % [candidate_label, difference, int(ART_VISIBLE_SIZE.x) * int(ART_VISIBLE_SIZE.y), ratio * 100.0, int(comparison["strong_difference_count"]), int(comparison["alpha_edge_count"]), str(comparison["min"]), str(comparison["max"])])
		print("Difference samples by source bbox (overlaps count for every owning bbox): ", comparison["by_part"])
		_check(ratio <= 0.01, "Rendered mesh assembly should match the candidate source-aligned assembly within 1%% sampled pixels (%.5f%%)." % (ratio * 100.0))
		if not requested_output_path.is_empty():
			_check(requested_output_path.begins_with("res://docs/visual_qa/"), "Requested output must remain inside docs/visual_qa/.")
			_check(not FileAccess.file_exists(requested_output_path), "Refusing to overwrite an existing diagnostic board.")
			if requested_output_path.begins_with("res://docs/visual_qa/") and not FileAccess.file_exists(requested_output_path):
				var output_absolute := ProjectSettings.globalize_path(requested_output_path)
				_check(frame.save_png(output_absolute) == OK, "Godot should save the review-only rendered board.")
		board.visible = false
		await _compare_each_part_at_native_scale(manifest)

	if errors.is_empty():
		print("PASS: Godot rendered all contour meshes at source-aligned offsets and compared the composite with the candidate assembly.")
		print("LIMIT: static render fidelity only; candidate remains quarantined and art/rig gates remain open.")
		if requested_output_path.is_empty():
			print("INFO: no image saved; pass -- --output res://docs/visual_qa/<new_quarantined_filename.png> to save a review board.")
		quit(0)
	else:
		push_error("%d CIPHER contour-mesh render check(s) failed." % errors.size())
		quit(1)


func _load_source_crop(manifest: Dictionary) -> Image:
	var source_path := str(manifest.get("source", ""))
	var crop: Array = manifest.get("crop_xywh", [])
	if source_path.is_empty() or crop.size() != 4:
		_check(false, "Manifest should include a source image and crop rectangle.")
		return null
	var image := _load_image("res://" + source_path)
	if image == null:
		return null
	return image.get_region(Rect2i(int(crop[0]), int(crop[1]), int(crop[2]), int(crop[3])))


func _load_image(path: String) -> Image:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(path))
	_check(error == OK, "Image should load: " + path)
	return image if error == OK else null


func _add_board_background(board: Node2D) -> void:
	var background := ColorRect.new()
	background.position = Vector2.ZERO
	background.size = Vector2(CANVAS_SIZE)
	background.color = Color("#090d16")
	board.add_child(background)
	for panel_index in range(3):
		var panel := ColorRect.new()
		panel.position = Vector2(PANEL_X[panel_index] + ART_LEFT_MARGIN - 3.0, PANEL_TOP)
		panel.size = ART_VISIBLE_SIZE + Vector2(6.0, 6.0)
		panel.color = Color("#202632")
		board.add_child(panel)
		for y in range(0, int(ART_VISIBLE_SIZE.y), 18):
			for x in range(0, int(ART_VISIBLE_SIZE.x), 18):
				if ((x / 18) + (y / 18)) % 2 != 0:
					var tile := ColorRect.new()
					tile.position = panel.position + Vector2(x, y)
					tile.size = Vector2(18, 18)
					tile.color = Color("#29313d")
					board.add_child(tile)
	_add_label(board, PANEL_X[0], "APPROVED ANATOMY PROFILE CROP", Color("#62e5ed"))
	_add_label(board, PANEL_X[1], "%s SOURCE-ALIGNED ASSEMBLY" % candidate_label.to_upper(), Color("#62e5ed"))


func _add_panel_art(board: Node2D, image: Image, panel_x: float, _unused_label: String) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.position = Vector2(panel_x + ART_LEFT_MARGIN, ART_TOP)
	sprite.scale = Vector2.ONE * ART_SCALE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	board.add_child(sprite)


func _add_mesh_assembly(board: Node2D, manifest: Dictionary, panel_x: float) -> void:
	var mesh_root := Node2D.new()
	mesh_root.name = "CipherContourMeshAssembly"
	mesh_root.position = Vector2(panel_x + ART_LEFT_MARGIN, ART_TOP)
	mesh_root.scale = Vector2.ONE * ART_SCALE
	mesh_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	board.add_child(mesh_root)
	var parts: Dictionary = manifest.get("parts", {})
	var layer_order: Array = manifest.get("layer_order_back_to_front", [])
	_check(parts.size() == expected_part_count and layer_order.size() == parts.size(), "Candidate should define %d parts and a full draw order." % expected_part_count)
	for layer_index in range(layer_order.size()):
		var part_id := str(layer_order[layer_index])
		_check(parts.has(part_id), "Draw order should reference a declared part: " + part_id)
		if not parts.has(part_id):
			continue
		var part: Dictionary = parts[part_id]
		var filename := str(part.get("file", ""))
		var image := _load_image(candidate_root + filename)
		if image == null:
			continue
		var source_bounds: Array = part.get("source_bbox_xyxy", [])
		var padding := int(part.get("padding_px", -1))
		_check(source_bounds.size() == 4 and padding >= 0, "Part should have source bounds and padding: " + part_id)
		if source_bounds.size() != 4 or padding < 0:
			continue
		var owner := Node2D.new()
		owner.name = part_id
		owner.position = Vector2(int(source_bounds[0]) - padding, int(source_bounds[1]) - padding)
		owner.z_index = layer_index
		mesh_root.add_child(owner)
		var texture := ImageTexture.create_from_image(image)
		var result: Dictionary = BUILDER.append_contour_meshes(image, texture, owner, part_id)
		_check(result.get("ok", false), "All contours should build for " + part_id + ": " + str(result.get("error", "")))


func _add_label(board: Node2D, panel_x: float, text_value: String, color: Color, width: float = PANEL_WIDTH, y: float = 61.0, font_size: int = 14) -> void:
	var label := Label.new()
	label.position = Vector2(panel_x, y)
	label.size = Vector2(width, 24.0)
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	board.add_child(label)


func _compare_assembly_panels(frame: Image, assembly: Image, manifest: Dictionary) -> Dictionary:
	var candidate_left := int(PANEL_X[1] + ART_LEFT_MARGIN)
	var mesh_left := int(PANEL_X[2] + ART_LEFT_MARGIN)
	var top := int(ART_TOP)
	var width := int(ART_VISIBLE_SIZE.x)
	var height := int(ART_VISIBLE_SIZE.y)
	var differences := 0
	var strong_differences := 0
	var alpha_edge_samples := 0
	var min_x := width
	var min_y := height
	var max_x := -1
	var max_y := -1
	var by_part: Dictionary = {}
	for part_id in manifest.get("parts", {}):
		by_part[str(part_id)] = 0
	by_part["outside_part_bboxes"] = 0
	for y in range(height):
		for x in range(width):
			var candidate_color := frame.get_pixel(candidate_left + x, top + y)
			var mesh_color := frame.get_pixel(mesh_left + x, top + y)
			var delta := absf(candidate_color.r - mesh_color.r) + absf(candidate_color.g - mesh_color.g) + absf(candidate_color.b - mesh_color.b)
			var source_x := clampi(roundi((float(x) + 0.5) / ART_SCALE), 0, assembly.get_width() - 1)
			var source_y := clampi(roundi((float(y) + 0.5) / ART_SCALE), 0, assembly.get_height() - 1)
			if delta > 0.08 and assembly.get_pixel(source_x, source_y).a < 0.99:
				alpha_edge_samples += 1
			if delta > 0.08:
				differences += 1
				var part_match := false
				for part_id in manifest.get("parts", {}):
					var bounds: Array = manifest.parts[part_id].get("source_bbox_xyxy", [])
					if bounds.size() == 4 and source_x >= int(bounds[0]) and source_x < int(bounds[2]) and source_y >= int(bounds[1]) and source_y < int(bounds[3]):
						by_part[str(part_id)] += 1
						part_match = true
				if not part_match:
					by_part["outside_part_bboxes"] += 1
				if delta > 0.25:
					strong_differences += 1
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	return {
		"difference_count": differences,
		"strong_difference_count": strong_differences,
		"alpha_edge_count": alpha_edge_samples,
		"min": Vector2i(min_x, min_y) if differences > 0 else Vector2i.ZERO,
		"max": Vector2i(max_x, max_y) if differences > 0 else Vector2i.ZERO,
		"by_part": by_part,
	}


func _compare_each_part_at_native_scale(manifest: Dictionary) -> void:
	var parts: Dictionary = manifest.get("parts", {})
	var passing_parts := 0
	for part_id in manifest.get("layer_order_back_to_front", []):
		var part: Dictionary = parts.get(str(part_id), {})
		var image := _load_image(candidate_root + str(part.get("file", "")))
		if image == null:
			continue
		var stage := Node2D.new()
		stage.name = "NativePartMeshCheck_" + str(part_id)
		root.add_child(stage)
		var background := ColorRect.new()
		background.size = Vector2(CANVAS_SIZE)
		background.color = Color("#111722")
		stage.add_child(background)
		_add_label(stage, 0.0, "NATIVE SCALE PART-TO-MESH RENDER CHECK — " + str(part_id), Color("#ff76ba"), 1280.0, 24)
		_add_label(stage, 0.0, "Source texture on left • independent PolyRig contour meshes on right", Color("#bac6d8"), 1280.0, 48, 11)
		var source_sprite := Sprite2D.new()
		source_sprite.texture = ImageTexture.create_from_image(image)
		source_sprite.centered = false
		source_sprite.position = Vector2(110.0, 76.0)
		source_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		stage.add_child(source_sprite)
		var mesh_owner := Node2D.new()
		mesh_owner.position = Vector2(700.0, 76.0)
		mesh_owner.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		stage.add_child(mesh_owner)
		var texture := ImageTexture.create_from_image(image)
		var result: Dictionary = BUILDER.append_contour_meshes(image, texture, mesh_owner, str(part_id))
		_check(result.get("ok", false), "Native-scale meshes should build for " + str(part_id) + ": " + str(result.get("error", "")))
		await process_frame
		await process_frame
		RenderingServer.force_draw(false)
		var frame := root.get_texture().get_image()
		var dimensions_fit := frame != null and frame.get_size() == CANVAS_SIZE and 110 + image.get_width() <= CANVAS_SIZE.x and 700 + image.get_width() <= CANVAS_SIZE.x and 76 + image.get_height() <= CANVAS_SIZE.y
		_check(dimensions_fit, "Native-scale part comparison should fit the project viewport: " + str(part_id))
		if dimensions_fit:
			var pixel_count := int(image.get_width()) * int(image.get_height())
			var difference_count := 0
			var strong_difference_count := 0
			var semitransparent_difference_count := 0
			var opaque_difference_count := 0
			var opaque_interior_difference_count := 0
			var first_difference_coordinates: Array[String] = []
			for y in range(image.get_height()):
				for x in range(image.get_width()):
					var source_color := frame.get_pixel(110 + x, 76 + y)
					var mesh_color := frame.get_pixel(700 + x, 76 + y)
					var delta := absf(source_color.r - mesh_color.r) + absf(source_color.g - mesh_color.g) + absf(source_color.b - mesh_color.b)
					if delta > 0.08:
						difference_count += 1
						if first_difference_coordinates.size() < 8:
							first_difference_coordinates.append("(%d,%d) Δ%.3f" % [x, y, delta])
						if image.get_pixel(x, y).a < 0.99:
							semitransparent_difference_count += 1
						else:
							opaque_difference_count += 1
							if not _has_alpha_edge_neighbor(image, x, y):
								opaque_interior_difference_count += 1
						if delta > 0.25:
							strong_difference_count += 1
			var ratio := float(difference_count) / float(maxi(pixel_count, 1))
			print("Native part render %s: %d/%d differs (%.5f%%), strong %d, alpha<0.99 %d, opaque %d, opaque-interior %d; first=%s." % [str(part_id), difference_count, pixel_count, ratio * 100.0, strong_difference_count, semitransparent_difference_count, opaque_difference_count, opaque_interior_difference_count, str(first_difference_coordinates)])
			_check(ratio <= 0.01, "Native-scale textured contour meshes should match the source part within a provisional 1%% pixel-color bound: %s (%.5f%%)." % [str(part_id), ratio * 100.0])
			_check(opaque_interior_difference_count == 0, "Native-scale contour mesh should not alter fully opaque interior pixels: %s (%d differing pixels)." % [str(part_id), opaque_interior_difference_count])
			if ratio <= 0.01:
				passing_parts += 1
		stage.queue_free()
		await process_frame
	_check(passing_parts == parts.size(), "Every CIPHER %s part should pass native-scale static render comparison (%d/%d)." % [candidate_label, passing_parts, parts.size()])
	if passing_parts == parts.size():
		print("PASS: all %d CIPHER %s source textures match their independent contour-mesh renders at native scale within the provisional 1%% bound." % [expected_part_count, candidate_label])


func _check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)
		push_error("CIPHER MESH RENDER CHECK FAILED: " + message)


func _has_alpha_edge_neighbor(image: Image, x: int, y: int) -> bool:
	for offset_y in range(-1, 2):
		for offset_x in range(-1, 2):
			if offset_x == 0 and offset_y == 0:
				continue
			var neighbor_x := x + offset_x
			var neighbor_y := y + offset_y
			if neighbor_x < 0 or neighbor_y < 0 or neighbor_x >= image.get_width() or neighbor_y >= image.get_height():
				return true
			if image.get_pixel(neighbor_x, neighbor_y).a < 0.99:
				return true
	return false
