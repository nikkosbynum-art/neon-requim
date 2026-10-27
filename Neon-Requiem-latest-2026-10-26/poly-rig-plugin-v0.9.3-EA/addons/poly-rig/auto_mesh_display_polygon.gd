@tool
extends Polygon2D

# Custom draw for auto-mesh preview: vertices, outline, and triangulation wireframe.
func _draw() -> void:
	if polygon.is_empty(): return

	var scale_ratio := scale.x
	# Draw vertex dots
	for p in polygon:
		draw_circle(p, 4.0 / scale_ratio, Color.BLACK)
		draw_circle(p, 3.0 / scale_ratio, Color.GREEN)

	# Draw outline (boundary points only)
	var outline := polygon.slice(0, -internal_vertex_count) if internal_vertex_count > 0 else polygon
	draw_polyline(outline, Color.CYAN, 2.0 / scale_ratio)
	draw_line(outline[-1], outline[0], Color.CYAN, 2.0 / scale_ratio)

	# Draw triangulation wireframe
	var wire_color := Color(1, 1, 1, 0.3)
	for tri in polygons:
		var a := polygon[tri[0]]
		var b := polygon[tri[1]]
		var c := polygon[tri[2]]
		draw_line(a, b, wire_color, 1.0 / scale_ratio, true)
		draw_line(b, c, wire_color, 1.0 / scale_ratio, true)
		draw_line(c, a, wire_color, 1.0 / scale_ratio, true)
