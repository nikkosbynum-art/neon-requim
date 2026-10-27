extends RefCounted
class_name PolyRigContourMeshBuilder

## Review-only mesh-input helper for alpha parts with disconnected contours.
## It keeps every contour as a separate Polygon2D using the same semantic
## owner. It does not infer semantic parts, bone weights, pivots, or approval.

static func append_contour_meshes(
	image: Image,
	texture: Texture2D,
	parent: Node2D,
	name_prefix: String = "contour"
) -> Dictionary:
	if image == null or image.is_empty():
		return {"ok": false, "error": "Image is empty.", "diagnostics": []}
	if texture == null:
		return {"ok": false, "error": "Texture is missing.", "diagnostics": []}
	if Vector2i(texture.get_size()) != image.get_size():
		return {"ok": false, "error": "Texture size must match the source image for pixel-aligned UVs.", "diagnostics": []}
	if not is_instance_valid(parent):
		return {"ok": false, "error": "Parent Node2D is invalid.", "diagnostics": []}

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)
	var contours := bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), 1.0)
	if contours.is_empty():
		return {"ok": false, "error": "Image produced no alpha contours.", "diagnostics": []}

	var pending_nodes: Array[Polygon2D] = []
	var diagnostics: Array[Dictionary] = []
	var polyrig_count := 0
	var godot_fallback_count := 0
	for contour_index in range(contours.size()):
		var outline: PackedVector2Array = contours[contour_index]
		var triangles: Array = PolyRigDelaunay.triangulate_to_indices(outline, outline)
		var triangulation_source := "PolyRigDelaunay"
		if _valid_triangles(triangles, outline.size()):
			polyrig_count += 1
		else:
			triangles = _godot_fallback(outline)
			triangulation_source = "Geometry2D fallback"
			if not _valid_triangles(triangles, outline.size()):
				return {
					"ok": false,
					"error": "Contour %d could not be triangulated by PolyRig or Geometry2D." % contour_index,
					"diagnostics": diagnostics,
					"contour_count": contours.size(),
					"polyrig_count": polyrig_count,
					"godot_fallback_count": godot_fallback_count,
				}
			godot_fallback_count += 1

		var polygon := Polygon2D.new()
		polygon.name = "%s_%02d" % [name_prefix, contour_index + 1]
		polygon.polygon = outline
		polygon.uv = outline
		polygon.polygons = triangles
		polygon.texture = texture
		pending_nodes.append(polygon)
		diagnostics.append({
			"contour_index": contour_index,
			"point_count": outline.size(),
			"triangulation_source": triangulation_source,
			"triangle_count": _triangle_count(triangles),
			"bounds": _bounds(outline),
		})

	# Do not leave a partially built mesh set attached if a later contour fails.
	for polygon in pending_nodes:
		parent.add_child(polygon)

	return {
		"ok": true,
		"error": "",
		"contour_count": contours.size(),
		"polyrig_count": polyrig_count,
		"godot_fallback_count": godot_fallback_count,
		"diagnostics": diagnostics,
		"nodes": pending_nodes,
	}


static func _godot_fallback(outline: PackedVector2Array) -> Array:
	var indices := Geometry2D.triangulate_polygon(outline)
	if indices.size() < 3 or indices.size() % 3 != 0:
		return []
	var packed := PackedInt32Array()
	for index in indices:
		packed.append(index)
	return [packed]


static func _valid_triangles(triangles: Array, point_count: int) -> bool:
	if triangles.is_empty():
		return false
	for triangle in triangles:
		if not triangle is PackedInt32Array or triangle.size() != 3:
			return false
		for index in triangle:
			if index < 0 or index >= point_count:
				return false
	return true


static func _triangle_count(triangles: Array) -> int:
	var count := 0
	for triangle in triangles:
		count += int(triangle.size() / 3)
	return count


static func _bounds(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()
	var result := Rect2(points[0], Vector2.ZERO)
	for point in points:
		result = result.expand(point)
	return result
