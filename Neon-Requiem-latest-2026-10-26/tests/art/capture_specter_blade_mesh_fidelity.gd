extends SceneTree

## Native-scale source-texture versus contour-mesh comparison for the
## quarantined SPECTER visible sword fragments. No rig or behavior is created.

const BUILDER := preload("res://tools/art/polyrig_contour_mesh_builder.gd")
const ROOT_PATH := "res://assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01/"
const CANVAS_SIZE := Vector2i(1280, 720)
const SOURCE_X := 100
const MESH_X := 680
const ROW_YS := [130, 390]
const PARTS := [
	{"id": "handheld_blade_hilt_visible", "file": "SPECTER_T1_BLADE_HILT_VISIBLE_CANDIDATE_01.png"},
	{"id": "handheld_blade_body_visible", "file": "SPECTER_T1_BLADE_BODY_VISIBLE_CANDIDATE_01.png"},
]

var failures: Array[String] = []
var rows: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var board := Node2D.new()
	board.name = "SpecterBladeMeshFidelityBoard"
	root.add_child(board)
	_add_background(board)
	_add_label(board, "SPECTER TIER I — VISIBLE BLADE CUTOUT / POLYRIG MESH", 16, 14, Color("#ff76ba"), 1248, 18)
	_add_label(board, "Static native-scale render check only • partial source art • quarantined • no pivot, rig, or production approval", 16, 40, Color("#bac6d8"), 1248, 11)

	for index in range(PARTS.size()):
		var part: Dictionary = PARTS[index]
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(ROOT_PATH + str(part.file)))
		_check(error == OK, "SPECTER cutout loads for render comparison: %s" % part.id)
		if error != OK:
			continue
		var bounds := image.get_used_rect().grow(8).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
		_check(bounds.has_area(), "SPECTER cutout has a nonempty review crop: %s" % part.id)
		if not bounds.has_area():
			continue
		var crop := image.get_region(bounds)
		var crop_texture := ImageTexture.create_from_image(crop)
		var row_y: int = ROW_YS[index]
		var source_sprite := Sprite2D.new()
		source_sprite.name = "%s_SourceTexture" % part.id
		source_sprite.texture = crop_texture
		source_sprite.centered = false
		source_sprite.position = Vector2(SOURCE_X, row_y)
		source_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		board.add_child(source_sprite)
		_add_label(board, "%s — CUTOUT TEXTURE" % str(part.id).to_upper(), SOURCE_X, row_y - 22, Color("#69e3ee"), 460, 11)

		var full_texture := ImageTexture.create_from_image(image)
		var mesh_owner := Node2D.new()
		mesh_owner.name = "%s_PolyRigMeshes" % part.id
		mesh_owner.position = Vector2(MESH_X - bounds.position.x, row_y - bounds.position.y)
		mesh_owner.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		board.add_child(mesh_owner)
		var mesh_result: Dictionary = BUILDER.append_contour_meshes(image, full_texture, mesh_owner, str(part.id))
		_check(bool(mesh_result.get("ok", false)), "SPECTER cutout builds all PolyRig meshes: %s %s" % [part.id, mesh_result.get("error", "")])
		_add_label(board, "%s — POLYRIG MESH" % str(part.id).to_upper(), MESH_X, row_y - 22, Color("#69e3ee"), 460, 11)
		var size_fits := MESH_X + bounds.size.x < CANVAS_SIZE.x and row_y + bounds.size.y < CANVAS_SIZE.y
		_check(size_fits, "SPECTER native crop fits the comparison board: %s" % part.id)
		rows.append({
			"id": part.id,
			"image": image,
			"bounds": bounds,
			"source_position": Vector2i(SOURCE_X, row_y),
			"mesh_position": Vector2i(MESH_X, row_y),
			"mesh_result": mesh_result,
		})

	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var frame := root.get_texture().get_image()
	_check(frame != null and frame.get_size() == CANVAS_SIZE, "Godot should render the 1280x720 SPECTER fidelity board.")
	var comparisons: Array[Dictionary] = []
	if frame != null and frame.get_size() == CANVAS_SIZE:
		for row in rows:
			comparisons.append(_compare_row(frame, row))
		for comparison in comparisons:
			var row_index := 0
			for index in range(rows.size()):
				if str(rows[index].id) == str(comparison.part_id):
					row_index = index
					break
			_add_label(board, "DIFF %.4f%% • %d contours" % [float(comparison.difference_ratio) * 100.0, int(comparison.contour_count)], 1090, ROW_YS[row_index], Color("#b8c6da"), 180, 10)
		await process_frame
		await process_frame
		RenderingServer.force_draw(false)
		var board_frame := root.get_texture().get_image()
		_check(board_frame != null and board_frame.get_size() == CANVAS_SIZE, "Godot should render the annotated SPECTER fidelity board.")
		var output_paths := _next_output_paths()
		_check(not output_paths.is_empty(), "Refusing to overwrite an existing SPECTER fidelity board or report.")
		if not output_paths.is_empty():
			var out_path: String = output_paths.image
			var save_error := board_frame.save_png(ProjectSettings.globalize_path(out_path))
			_check(save_error == OK, "Godot should save the quarantined SPECTER fidelity board.")
			if save_error == OK:
				print("Saved SPECTER PolyRig fidelity board: ", out_path)
			var report := {
				"status": "QUARANTINED_STATIC_RENDER_FIDELITY_DIAGNOSTIC",
				"image": out_path,
				"comparisons": comparisons,
				"semantic_correctness": "NOT_VERIFIED",
				"pivots_authored": false,
				"deformation_reviewed": false,
				"production_approved": false,
				"runtime_integrated": false,
			}
			var report_file := FileAccess.open(output_paths.report, FileAccess.WRITE)
			_check(report_file != null, "Godot should open the new quarantined fidelity report.")
			if report_file != null:
				report_file.store_string(JSON.stringify(report, "  ") + "\n")
				report_file.close()
				print("Saved SPECTER PolyRig fidelity report: ", output_paths.report)
	board.queue_free()
	rows.clear()
	await process_frame

	if failures.is_empty():
		print("PASS: both visible SPECTER cutout textures retain native-scale appearance through their PolyRig contour meshes.")
		print("LIMIT: partial visible source artwork only; no grip completion, pivot, deformation, weapon attachment, or production approval is implied.")
		quit(0)
	else:
		push_error("%d SPECTER blade fidelity check(s) failed." % failures.size())
		quit(1)


func _compare_row(frame: Image, row: Dictionary) -> Dictionary:
	var source_image: Image = row.image
	var bounds: Rect2i = row.bounds
	var source_position: Vector2i = row.source_position
	var mesh_position: Vector2i = row.mesh_position
	var differences := 0
	var opaque_interior_differences := 0
	var samples := bounds.size.x * bounds.size.y
	for y in range(bounds.size.y):
		for x in range(bounds.size.x):
			var source_color := frame.get_pixel(source_position.x + x, source_position.y + y)
			var mesh_color := frame.get_pixel(mesh_position.x + x, mesh_position.y + y)
			var delta := absf(source_color.r - mesh_color.r) + absf(source_color.g - mesh_color.g) + absf(source_color.b - mesh_color.b)
			if delta > 0.08:
				differences += 1
				var image_x := bounds.position.x + x
				var image_y := bounds.position.y + y
				if source_image.get_pixel(image_x, image_y).a >= 0.99 and not _has_alpha_edge_neighbor(source_image, image_x, image_y):
					opaque_interior_differences += 1
	var ratio := float(differences) / float(maxi(samples, 1))
	var build_result: Dictionary = row.mesh_result
	var contours := int(build_result.get("contour_count", 0))
	var polyrig := int(build_result.get("polyrig_count", 0))
	var fallback := int(build_result.get("godot_fallback_count", 0))
	print("SPECTER %s: %d/%d native crop pixels differ (%.5f%%); opaque interior deltas %d; contours %d, PolyRig %d, fallback %d." % [row.id, differences, samples, ratio * 100.0, opaque_interior_differences, contours, polyrig, fallback])
	_check(ratio <= 0.01, "SPECTER source crop and PolyRig render stay within the provisional 1%% diagnostic bound: %s" % row.id)
	_check(opaque_interior_differences == 0, "SPECTER PolyRig render preserves fully opaque interior pixels: %s" % row.id)
	_check(contours > 0 and polyrig == contours and fallback == 0, "All SPECTER alpha contours use PolyRig without fallback: %s" % row.id)
	return {
		"part_id": row.id,
		"source_crop_px": [bounds.size.x, bounds.size.y],
		"pixel_differences": differences,
		"sample_count": samples,
		"difference_ratio": ratio,
		"opaque_interior_differences": opaque_interior_differences,
		"contour_count": contours,
		"polyrig_contours": polyrig,
		"fallback_contours": fallback,
	}


func _has_alpha_edge_neighbor(image: Image, x: int, y: int) -> bool:
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var point: Vector2i = Vector2i(x, y) + offset
		if point.x >= 0 and point.y >= 0 and point.x < image.get_width() and point.y < image.get_height() and image.get_pixelv(point).a < 0.99:
			return true
	return false


func _add_background(parent: Node2D) -> void:
	var background := ColorRect.new()
	background.size = Vector2(CANVAS_SIZE)
	background.color = Color("#090d16")
	parent.add_child(background)


func _add_label(parent: Node2D, value: String, x: int, y: int, color: Color, width: float, font_size: int) -> void:
	var label := Label.new()
	label.position = Vector2(x, y)
	label.size = Vector2(width, 20)
	label.text = value
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)


func _next_output_paths() -> Dictionary:
	for index in range(1, 100):
		var stem := "res://docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_%02d_QUARANTINED" % index
		var image_path := stem + ".png"
		var report_path := stem + ".json"
		if not FileAccess.file_exists(image_path) and not FileAccess.file_exists(report_path):
			return {"image": image_path, "report": report_path}
	return {}


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("CHECK FAILED: " + message)
