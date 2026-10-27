extends SceneTree

## Captures a quarantined, genuinely skinned CIPHER 09B knee review using the
## Krita-layer exporter output. Test weights are generated for this review only.

const CANDIDATE_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/"
const EXPORT_ROOT := CANDIDATE_ROOT + "krita_export_09b_ROUNDTRIP_02_QUARANTINED/"
const SOURCE_PATH := "res://docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
const UNDERPAINT_FILE := "CIPHER_T1_NEAR_KNEE_LEG_UNDERPAINT_INFERRED_CANDIDATE_09B_04_QUARANTINED.png"
const ASSEMBLY_FILE := "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_09B_QUARANTINED.png"
const FLEX_OUTPUT_PATH := "res://docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHT_MAP_FLEX_NEG20_GODOT_07_QUARANTINED.png"
const EXTENSION_OUTPUT_PATH := "res://docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHT_MAP_EXTENSION_POS20_GODOT_07_QUARANTINED.png"
const CANVAS_SIZE := Vector2i(1280, 720)
const PANEL_SIZE := Vector2i(250, 280)
const PANEL_X := [95.0, 515.0, 935.0]
const PANEL_Y := 105.0
const CROP := Rect2i(60, 500, 250, 280)
const PROFILE_CROP := Rect2i(600, 10, 330, 960)
const APPROVED_KNEE := Vector2(170.0, 655.0)
const HIP_ANCHOR := Vector2(170.0, 500.0)
const SHIN_END_TEST := Vector2(175.0, 850.0)
const MESH_SAMPLE_STEP := 14.0

var errors: Array[String] = []


func _initialize() -> void:
	root.size = CANVAS_SIZE
	call_deferred("_capture")


func _capture() -> void:
	var candidate_manifest := _read_json(CANDIDATE_ROOT + "parts_manifest.json")
	var export_manifest := _read_json(EXPORT_ROOT + "review_manifest.json")
	_check(not candidate_manifest.is_empty(), "Candidate manifest should load.")
	_check(not export_manifest.is_empty(), "Krita-layer export manifest should load.")
	if candidate_manifest.is_empty() or export_manifest.is_empty():
		quit(1)
		return
	_check(export_manifest.get("status") == "REVIEW CANDIDATE - QUARANTINED", "Export must remain quarantined.")
	_check(export_manifest.get("production_approved", true) == false and export_manifest.get("runtime_integrated", true) == false, "Export cannot be promoted by this capture.")
	var export_canvas: Array = export_manifest.get("canvas_px", [])
	_check(export_canvas.size() == 2 and int(export_canvas[0]) == 330 and int(export_canvas[1]) == 960, "Export must retain the source profile canvas.")
	var source_pivot: Array = candidate_manifest.get("pivot", {}).get("source_xy", [])
	_check(source_pivot.size() == 2 and int(source_pivot[0]) == 770 and int(source_pivot[1]) == 665, "The approved source pivot must be retained.")
	_check(candidate_manifest.get("inferred_underpaint_review", {}).get("runtime_integration", true) == false, "Inferred underpaint must remain out of runtime.")

	var maps := [
		{"name": "CURRENT\n44 px half-band", "band": 44.0},
		{"name": "ALT A\n24 px half-band", "band": 24.0},
		{"name": "ALT B\n72 px half-band", "band": 72.0},
	]
	for pose in [{"angle": -20.0, "title": "INWARD FLEX -20° (negative)", "output": FLEX_OUTPUT_PATH}, {"angle": 20.0, "title": "EXTENSION TEST +20° (positive)", "output": EXTENSION_OUTPUT_PATH}]:
		var board := Node2D.new()
		board.name = "CIPHER09BKneeWeightMap_%s" % str(pose["angle"]).replace("-", "minus")
		root.add_child(board)
		_add_background(board)
		_add_label(board, 8.0, "CIPHER TIER I • 09B • %s" % pose["title"], Color("#ff76ba"), 1264.0, 14.0, 18)
		for column in range(maps.size()):
			var map_spec: Dictionary = maps[column]
			_add_label(board, PANEL_X[column], str(map_spec["name"]), Color("#62e5ed"), PANEL_SIZE.x, 68.0, 14)
			_add_skinned_panel(board, export_manifest, PANEL_X[column], PANEL_Y, float(pose["angle"]), float(map_spec["band"]))
		_add_label(board, 8.0, "Same source-derived parts and approved pivot [770,665] / crop [170,655]; cyan cross marks the pivot.", Color("#bac6d8"), 1264.0, 410.0, 12)
		if float(pose["angle"]) < 0.0:
			_add_label(board, 8.0, "Existing approved inferred underpaint appears only in this negative-flex pose.", Color("#bac6d8"), 1264.0, 432.0, 12)
		else:
			_add_label(board, 8.0, "No underpaint is present in this positive extension pose; source-derived parts only.", Color("#bac6d8"), 1264.0, 432.0, 12)
		_add_label(board, 8.0, "Hip anchor and all weight maps are test estimates. Diagnostic only; no art, continuous-deformation, or runtime approval.", Color("#bac6d8"), 1264.0, 454.0, 12)
		await process_frame
		await process_frame
		RenderingServer.force_draw(false)
		var frame := root.get_texture().get_image()
		_check(frame != null and frame.get_size() == CANVAS_SIZE, "Godot should render a 1280x720 weight-map comparison board.")
		if frame != null and frame.get_size() == CANVAS_SIZE:
			var output_path := str(pose["output"])
			_check(not FileAccess.file_exists(output_path), "Refusing to overwrite an existing review board: " + output_path)
			if not FileAccess.file_exists(output_path):
				_check(frame.save_png(ProjectSettings.globalize_path(output_path)) == OK, "Godot should save the weighted-mesh board: " + output_path)
		board.queue_free()
		await process_frame
	if errors.is_empty():
		print("PASS: Godot rendered current and two alternate CIPHER 09B weight bands at negative flex and positive extension angles.")
		print("LIMIT: only the knee guard pivot and boundary have scoped user approval; all weight maps are estimates.")
		quit(0)
	else:
		push_error("%d weighted-knee capture check(s) failed." % errors.size())
		quit(1)


func _add_skinned_panel(board: Node2D, manifest: Dictionary, panel_x: float, panel_y: float, knee_angle_degrees: float, weight_band: float) -> void:
	var container := _make_panel_viewport(board, panel_x, panel_y)
	var viewport := container.get_child(0) as SubViewport
	var pose_root := Node2D.new()
	pose_root.name = "WeightedPose_%s" % str(knee_angle_degrees).replace("-", "minus")
	pose_root.position = -Vector2(CROP.position)
	viewport.add_child(pose_root)

	var underpaint := _load_image(CANDIDATE_ROOT + UNDERPAINT_FILE) if knee_angle_degrees < 0.0 else null
	if underpaint != null:
		var underpaint_sprite := Sprite2D.new()
		underpaint_sprite.name = "INFERRED_underpaint_review_only"
		underpaint_sprite.texture = ImageTexture.create_from_image(underpaint)
		underpaint_sprite.centered = false
		underpaint_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pose_root.add_child(underpaint_sprite)

	var skeleton := Skeleton2D.new()
	skeleton.name = "CIPHER_09B_KneeTestSkeleton"
	skeleton.position = APPROVED_KNEE
	pose_root.add_child(skeleton)
	var root_bone := _make_bone("knee_test_root", skeleton, Vector2.ZERO, 155.0)
	var upper := _make_bone("near_thigh", root_bone, HIP_ANCHOR - APPROVED_KNEE, 155.0)
	var knee := _make_bone("near_knee_APPROVED_PIVOT", upper, APPROVED_KNEE - HIP_ANCHOR, SHIN_END_TEST.distance_to(APPROVED_KNEE))
	knee.rotation = deg_to_rad(knee_angle_degrees)
	var mesh_root := Node2D.new()
	mesh_root.name = "SkinnedMeshes"
	pose_root.add_child(mesh_root)

	var layer_order: Array[String] = []
	for part in manifest.get("parts", []):
		if part is Dictionary:
			layer_order.append(str(part.get("part_id", "")))
	var draw_order := ["near_thigh", "near_shin", "near_knee_guard", "near_boot"]
	for part_id in draw_order:
		if not layer_order.has(part_id):
			_check(false, "Krita export must contain %s." % part_id)
			continue
		var part_image := _load_image(EXPORT_ROOT + "parts/" + part_id + ".png")
		if part_image == null:
			continue
		var texture := ImageTexture.create_from_image(part_image)
		var joint_blend: bool = part_id in ["near_thigh", "near_shin"]
		var fixed_to_knee: bool = part_id in ["near_boot", "near_knee_guard"]
		var mesh_count := _add_skinned_texture(mesh_root, skeleton, upper, knee, part_id, texture, part_image, joint_blend, fixed_to_knee, weight_band)
		_check(mesh_count > 0, "%s should produce at least one skinned contour mesh." % part_id)
	_add_pivot_crosshair(viewport)


func _add_skinned_texture(parent: Node2D, skeleton: Skeleton2D, upper: Bone2D, knee: Bone2D, part_id: String, texture: Texture2D, image: Image, joint_blend: bool, fixed_to_knee: bool, weight_band: float) -> int:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, 0.12)
	var contours := bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, Vector2(image.get_size())), 2.5)
	var created := 0
	for contour_index in range(contours.size()):
		var outline: PackedVector2Array = contours[contour_index]
		if outline.size() < 3 or absf(_polygon_area(outline)) < 12.0:
			continue
		var source_points := outline.duplicate()
		source_points.append_array(_inside_points(outline))
		var points := _offset_points(source_points, -APPROVED_KNEE)
		var local_outline := _offset_points(outline, -APPROVED_KNEE)
		var triangles: Array = PolyRigDelaunay.triangulate_to_indices(points, local_outline)
		if triangles.is_empty():
			triangles = _fallback_triangulate(points, local_outline)
		if triangles.is_empty():
			continue
		var compacted := _compact_mesh(points, triangles)
		points = compacted.points
		triangles = compacted.triangles
		var polygon := Polygon2D.new()
		polygon.name = part_id + "_skin_%02d" % contour_index
		polygon.texture = texture
		polygon.polygon = points
		polygon.uv = _offset_points(points, APPROVED_KNEE)
		polygon.polygons = triangles
		polygon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		polygon.position = APPROVED_KNEE
		parent.add_child(polygon)
		polygon.skeleton = polygon.get_path_to(skeleton)
		var upper_weights := PackedFloat32Array()
		var knee_weights := PackedFloat32Array()
		upper_weights.resize(points.size())
		knee_weights.resize(points.size())
		for point_index in range(points.size()):
			var source_y := points[point_index].y + APPROVED_KNEE.y
			var knee_weight := 1.0 if fixed_to_knee else _smoothstep((source_y - (APPROVED_KNEE.y - weight_band)) / (weight_band * 2.0)) if joint_blend else 0.0
			upper_weights[point_index] = 1.0 - knee_weight
			knee_weights[point_index] = knee_weight
		polygon.add_bone(skeleton.get_path_to(upper), upper_weights)
		polygon.add_bone(skeleton.get_path_to(knee), knee_weights)
		created += 1
	return created


func _add_pivot_crosshair(viewport: SubViewport) -> void:
	var marker := Node2D.new()
	marker.name = "APPROVED_KNEE_PIVOT_MARKER"
	marker.position = APPROVED_KNEE - Vector2(CROP.position)
	viewport.add_child(marker)
	for mark in [
		{"position": Vector2(-8.0, -1.0), "size": Vector2(16.0, 2.0)},
		{"position": Vector2(-1.0, -8.0), "size": Vector2(2.0, 16.0)},
	]:
		var bar := ColorRect.new()
		bar.position = mark["position"]
		bar.size = mark["size"]
		bar.color = Color("#62e5ed")
		marker.add_child(bar)


func _make_bone(bone_name: String, parent: Node, local_position: Vector2, length: float) -> Bone2D:
	var bone := Bone2D.new()
	bone.name = bone_name
	bone.set_autocalculate_length_and_angle(false)
	bone.position = local_position
	parent.add_child(bone)
	bone.rest = bone.transform
	bone.set_length(maxf(length, 1.0))
	bone.set_bone_angle(local_position.angle())
	return bone


func _make_panel_viewport(board: Node2D, panel_x: float, panel_y: float) -> SubViewportContainer:
	var container := SubViewportContainer.new()
	container.position = Vector2(panel_x, panel_y)
	container.size = Vector2(PANEL_SIZE)
	container.stretch = false
	var viewport := SubViewport.new()
	viewport.size = CROP.size
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	board.add_child(container)
	return container


func _add_background(board: Node2D) -> void:
	var background := ColorRect.new()
	background.size = Vector2(CANVAS_SIZE)
	background.color = Color("#090d16")
	board.add_child(background)
	for column_x in PANEL_X:
		var tile := ColorRect.new()
		tile.position = Vector2(column_x, PANEL_Y)
		tile.size = Vector2(PANEL_SIZE)
		tile.color = Color("#202632")
		board.add_child(tile)
		for y in range(0, PANEL_SIZE.y, 16):
			for x in range(0, PANEL_SIZE.x, 16):
				if ((x / 16) + (y / 16)) % 2 != 0:
					var checker := ColorRect.new()
					checker.position = tile.position + Vector2(x, y)
					checker.size = Vector2(16, 16)
					checker.color = Color("#29313d")
					board.add_child(checker)


func _inside_points(outline: PackedVector2Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	var bounds := Rect2(outline[0], Vector2.ZERO)
	for point in outline:
		bounds = bounds.expand(point)
	var y := bounds.position.y + MESH_SAMPLE_STEP * 0.5
	while y < bounds.end.y:
		var x := bounds.position.x + MESH_SAMPLE_STEP * 0.5
		while x < bounds.end.x:
			var candidate := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(candidate, outline):
				points.append(candidate)
			x += MESH_SAMPLE_STEP
		y += MESH_SAMPLE_STEP
	return points


func _fallback_triangulate(points: PackedVector2Array, outline: PackedVector2Array) -> Array:
	var raw := Geometry2D.triangulate_delaunay(points)
	var accepted: Array = []
	for i in range(0, raw.size() - 2, 3):
		var a := points[raw[i]]
		var b := points[raw[i + 1]]
		var c := points[raw[i + 2]]
		if Geometry2D.is_point_in_polygon((a + b + c) / 3.0, outline):
			accepted.append(PackedInt32Array([raw[i], raw[i + 1], raw[i + 2]]))
	return accepted


func _compact_mesh(points: PackedVector2Array, triangles: Array) -> Dictionary:
	var remap := {}
	var compact_points := PackedVector2Array()
	for triangle in triangles:
		for index in triangle:
			if not remap.has(index):
				remap[index] = compact_points.size()
				compact_points.append(points[index])
	var compact_triangles: Array = []
	for triangle in triangles:
		compact_triangles.append(PackedInt32Array([remap[triangle[0]], remap[triangle[1]], remap[triangle[2]]]))
	return {"points": compact_points, "triangles": compact_triangles}


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	result.resize(points.size())
	for index in range(points.size()):
		result[index] = points[index] + offset
	return result


func _smoothstep(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _polygon_area(points: PackedVector2Array) -> float:
	var area := 0.0
	for index in range(points.size()):
		area += points[index].cross(points[(index + 1) % points.size()])
	return area * 0.5


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_check(false, "Could not open JSON: " + path)
		return {}
	var value: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not value is Dictionary:
		_check(false, "JSON root should be an object: " + path)
		return {}
	return value


func _load_image(path: String) -> Image:
	var image := Image.new()
	var result := image.load(ProjectSettings.globalize_path(path))
	_check(result == OK, "Godot should load image: " + path)
	return image if result == OK else null


func _add_label(board: Node2D, x: float, text_value: String, color: Color, width: float, y: float, font_size: int) -> void:
	var label := Label.new()
	label.position = Vector2(x, y)
	label.size = Vector2(width, 20.0)
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	board.add_child(label)


func _check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)
		push_error("CIPHER 09B WEIGHTED KNEE REVIEW FAILED: " + message)
