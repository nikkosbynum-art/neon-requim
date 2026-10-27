@tool
class_name PolyRigMeshEditTypeButton extends Button

@onready var _global := PolyRigPlugin.get_instance()

var _suppress_draw_signal = false
var old_internal_vertex_count = 0
var old_polygon:PackedVector2Array

var display_internal_point: bool = true:
	set(value):
		display_internal_point = value
		text = "Hide Internal" if value else "Show Internal"

func set_old(poly: Polygon2D) -> void:
	if poly:
		old_internal_vertex_count = poly.internal_vertex_count
		old_polygon = poly.polygon.duplicate()
	else:
		old_internal_vertex_count = 0
		old_polygon = PackedVector2Array()

func not_old(polygon:Polygon2D) -> bool:
	var changed := old_internal_vertex_count != polygon.internal_vertex_count or old_polygon != polygon.polygon
	
	return changed

func _ready() -> void:
	display_internal_point = true
	_suppress_draw_signal = false
	
	if _global:
		_global.polygon_selected.connect(_on_polygon_selected)

		if _global.current_polygon:
			_on_polygon_selected(_global.current_polygon, null)

func _on_polygon_selected(polygon: Polygon2D, old_polygon: Polygon2D) -> void:
	if old_polygon:
		if old_polygon.has_meta(PolyRigPlugin.CACHE_KEY):
			restore(old_polygon)
		if old_polygon.draw.is_connected(_on_polygon_draw):
			old_polygon.draw.disconnect(_on_polygon_draw)
	if polygon:
		if polygon.has_meta(PolyRigPlugin.CACHE_KEY):
			restore(polygon)

		set_old(polygon)
		polygon.draw.connect(_on_polygon_draw)
		
	display_internal_point = true

func _on_pressed() -> void:
	_suppress_draw_signal = true
	display_internal_point = !display_internal_point
	var poly := PolyRigPlugin.current_polygon
	if not poly: return

	if display_internal_point:
		restore(poly)
	else:
		_cache_and_hide(poly)

	var sel := _global.get_editor_interface().get_selection()
	sel.clear()
	sel.add_node(poly)

	await _polygon_update(poly)

	_suppress_draw_signal = false

# Returns the negative index used to split internal vertices from the end.
func _get_internal_start_index(poly: Polygon2D):
	return poly.polygon.size() - poly.internal_vertex_count

# Caches internal points and strips them from the polygon.
func _cache_and_hide(polygon: Polygon2D) -> void:
	var ic := polygon.internal_vertex_count
	if polygon.polygons.size() == 0: return
	var last_index = _get_internal_start_index(polygon)
	
	# Cache bone weights for internal vertices
	var bone_weights_cache := {}
	for bi in range(polygon.get_bone_count()):
		var w := polygon.get_bone_weights(bi)
		bone_weights_cache[bi] = w.slice(last_index)
	
	polygon.set_meta(PolyRigPlugin.CACHE_KEY, {
		"internal_vertex_count": ic,
		"polygon": polygon.polygon.slice(last_index),
		"uv": polygon.uv.slice(last_index),
		"bone_weights": bone_weights_cache,
	})
	polygon.internal_vertex_count = 0
	polygon.polygon = polygon.polygon.slice(0, last_index)
	polygon.uv = polygon.uv.slice(0, last_index)
	# Trim bone weights to exclude internal vertices
	for bi in range(polygon.get_bone_count()):
		var w := polygon.get_bone_weights(bi)
		if w.size() > last_index:
			polygon.set_bone_weights(bi, w.slice(0, last_index))
	polygon.polygons = []

# Restores cached internal points.
func restore(polygon: Polygon2D) -> void:
	if not polygon.has_meta(PolyRigPlugin.CACHE_KEY): return
	_suppress_draw_signal = true
	var cache: Dictionary = polygon.get_meta(PolyRigPlugin.CACHE_KEY)
	polygon.polygon = polygon.polygon + (cache["polygon"] as PackedVector2Array)
	polygon.uv = polygon.uv + (cache["uv"] as PackedVector2Array)
	# Restore bone weights for internal vertices
	var bone_weights_cache: Dictionary = cache.get("bone_weights", {})
	for bi in bone_weights_cache:
		if bi < polygon.get_bone_count():
			var w := polygon.get_bone_weights(bi)
			polygon.set_bone_weights(bi, w + (bone_weights_cache[bi] as PackedFloat32Array))
	polygon.internal_vertex_count = cache["internal_vertex_count"]
	PolyRigDelaunay.triangulate_polygon(polygon, true)
	polygon.remove_meta(PolyRigPlugin.CACHE_KEY)
	display_internal_point = true
	_suppress_draw_signal = false

# Prevents adding internal points while in outline-only mode.
func _on_polygon_draw() -> void:
	if _suppress_draw_signal:
		return
	_suppress_draw_signal = true

	var poly :Polygon2D= PolyRigPlugin.current_polygon
	if not poly:
		_suppress_draw_signal = false
		return

	if not_old(poly):
		if poly.polygon.size() < 3:
			poly.internal_vertex_count = 0
			poly.polygons = []

			if not display_internal_point:
				poly.remove_meta(PolyRigPlugin.CACHE_KEY)
				display_internal_point = true
			set_old(poly)
			await _polygon_update(poly)
		elif display_internal_point:
			poly.polygons = []
			PolyRigDelaunay.triangulate_polygon(poly, true)
			set_old(poly)
			await _polygon_update(poly)
		elif poly.internal_vertex_count > 0:
			var last_index = _get_internal_start_index(poly)
			poly.internal_vertex_count = 0
			poly.polygon = poly.polygon.slice(0, last_index)
			poly.uv = poly.uv.slice(0, last_index)

			poly.polygons = []
			set_old(poly)
			await _polygon_update(poly)
			PolyRigUtils.show_warning(self, "Show internal points to edit internal vertices.", "Warning")

	_suppress_draw_signal = false

func _polygon_update(poly:Polygon2D):
	await get_tree().process_frame	
	poly.polygon = poly.polygon
	poly.queue_redraw()

	poly.visible = false
	poly.visible = true
	await poly.draw
