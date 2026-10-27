@tool
class_name PolyRigWeightChart extends Control

@onready var _global := PolyRigPlugin.get_instance()
@onready var _weight_manager: PolyRigWeightManager = %WeightManager
@onready var _bone_item_list: VBoxContainer = %BoneItemList
@onready var _show_bone_check: CheckBox = %ShowBoneCheckBox
@onready var _show_pie_chart_check: CheckBox = %ShowPieChartCheckBox
@onready var _polygon_2d: Polygon2D = $Polygon2D
@onready var _drag_manager: PolyRigDragManager = %DragManager

signal vertex_selected(index: int)

enum HeatMapMode { FULL, SELECTED, NONE }

const PIE_RADIUS := 12.0
const PIE_RADIUS_BIG := 16.0

const SELECT_CIRCLE_RADIUS := 2.0
const VERTEX_HIT_RADIUS := 12.0
const MESH_LINE_WIDTH := 2.0
const BONE_LINE_WIDTH := 0.5
const BONE_HEAD_RADIUS := 4.0

const BONE_BORDER_COLOR := Color(0.363, 0.363, 0.363, 1.0)

var transform_matrix: Transform2D
var scale_ratio: float = 1.0
var selected_vertex_index: int = -1

var _hover_index: int = -1
var _heatmap_mode: HeatMapMode = HeatMapMode.FULL

# Bone hover state
var _hover_bone: Bone2D = null

# Drag state
var _drag_vertex: int = -1
var _drag_bone: Bone2D = null
var _drag_init_weight: float = 0.0
var _drag_last_mouse: Vector2 = Vector2.ZERO
var _drag_snapshot: Dictionary = {}

# Draw cache (shared between heatmap and chart)
var _weight_cache: Array[Dictionary] = []
var _weight_cache_dirty := true

# --- Lifecycle ---

func _ready() -> void:
	if _global:
		_global.polygon_changed.connect(_on_polygon_changed)
	resized.connect(update_weight_chart)
	update_weight_chart()

func _on_polygon_changed(_polygon: Polygon2D) -> void:
	if _drag_vertex == -1:
		update_weight_chart()

func _on_bone_manager_bone_data_changed(_data: Array) -> void:
	update_weight_chart()

func _on_bone_item_list_bone_weights_changed() -> void:
	update_weight_chart()

func _on_bone_item_list_bone_selected(_bone: Bone2D) -> void:
	queue_redraw()

func _on_show_bone_check_box_toggled(_toggled_on: bool) -> void:
	queue_redraw()

func _on_heat_map_option_button_item_selected(index: int) -> void:
	_heatmap_mode = index as HeatMapMode
	_polygon_2d.visible = _heatmap_mode == HeatMapMode.NONE
	queue_redraw()

# --- Chart update ---

func update_weight_chart() -> void:
	_weight_cache_dirty = true
	_update_transform(PolyRigPlugin.current_polygon)
	queue_redraw()

# --- Vertex selection ---

func select_vertex(index: int) -> void:
	if index < 0: return
	selected_vertex_index = index
	vertex_selected.emit(index)
	queue_redraw()

func deselect_vertex(emit: bool = true) -> void:
	selected_vertex_index = -1
	if emit:
		vertex_selected.emit(selected_vertex_index)
	queue_redraw()

# --- Vertex drag ---

func _begin_drag(index: int) -> void:
	select_vertex(index)
	var bone: Bone2D = _bone_item_list.get_selected_bone()
	var polygon := _global.current_polygon
	if not polygon or not bone: return
	# Pre-normalize so drag init weight reflects true proportion
	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	var bone_data: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	if skeleton and not bone_data.is_empty():
		_weight_manager.ensure_vertex_normalized(polygon, index, bone_data, skeleton)
	_drag_last_mouse = get_global_mouse_position()
	_drag_vertex = index
	_drag_bone = bone
	_drag_init_weight = _weight_manager.get_vertex_weight(polygon, index, bone)
	_drag_snapshot = _weight_manager.snapshot_single_vertex_weights(polygon, index)

func _end_drag() -> void:
	var polygon := _global.current_polygon
	if polygon and _drag_bone and _drag_vertex >= 0 and not _drag_snapshot.is_empty():
		var new_snap := _weight_manager.snapshot_single_vertex_weights(polygon, _drag_vertex)
		_weight_manager.commit_vertex_weights_undo("Drag vertex weight", polygon, _drag_vertex, _drag_snapshot, new_snap)
		_drag_snapshot = {}
	_drag_vertex = -1
	_hover_index = -1
	queue_redraw()

# --- Transform ---

func _update_transform(polygon: Polygon2D) -> void:
	_drag_manager.update_base_transform(polygon, size)
	transform_matrix = _drag_manager.get_final_transform()
	scale_ratio = _drag_manager.get_scale_ratio()
	_polygon_2d.transform = transform_matrix

# --- Drawing ---

#func _gui_input(event: InputEvent) -> void:
	#if _drag_manager.handle_input(event):
		#accept_event()

func _draw() -> void:
	var polygon := PolyRigPlugin.current_polygon
	if not polygon: return

	_update_transform(polygon)
	draw_set_transform_matrix(transform_matrix)

	# Cache all vertex weights for heatmap and chart
	if _weight_cache_dirty or _weight_cache.size() != polygon.polygon.size():
		_weight_cache.clear()
		_weight_cache.resize(polygon.polygon.size())
		for i in range(polygon.polygon.size()):
			_weight_cache[i] = _weight_manager.get_vertex_weights(polygon, i)
		_weight_cache_dirty = false

	_draw_heatmap(polygon, _bone_item_list.get_selected_bone())
	_draw_mesh_lines(polygon)

	if _heatmap_mode == HeatMapMode.NONE:
		_polygon_2d.texture = polygon.texture
		_polygon_2d.uv = polygon.uv
		_polygon_2d.polygons = polygon.polygons
		_polygon_2d.polygon = polygon.polygon
		_polygon_2d.internal_vertex_count = polygon.internal_vertex_count
		_polygon_2d.transform = transform_matrix

	_draw_vertices(polygon)
	if _show_bone_check.button_pressed:
		_draw_bones(polygon)

	draw_set_transform_matrix(Transform2D.IDENTITY)

# Draws internal mesh wireframe and boundary outline.
func _draw_mesh_lines(polygon: Polygon2D) -> void:
	if not polygon.polygons or polygon.polygons.is_empty(): return
	var line_w := MESH_LINE_WIDTH / scale_ratio
	var inner_color := Color(1, 1, 1, 0.2)
	var border_color := Color(0.16, 0.79, 0.898, 1.0)

	# Inner mesh lines
	var lines := PackedVector2Array()
	for tri in polygon.polygons:
		var count: int = tri.size()
		for i in range(count):
			lines.append(polygon.polygon[tri[i]])
			lines.append(polygon.polygon[tri[(i + 1) % count]])
	draw_multiline(lines, inner_color, line_w)

	# Boundary outline (first N points, excluding internal vertices)
	var boundary_count := polygon.polygon.size() - polygon.internal_vertex_count
	if boundary_count > 2:
		var boundary := polygon.polygon.slice(0, boundary_count)
		boundary.append(boundary[0])
		draw_polyline(boundary, border_color, line_w)

# Draws vertex pie charts with selection highlight.
func _draw_vertices(polygon: Polygon2D) -> void:
	for i in range(polygon.polygon.size()):
		var v := polygon.polygon[i]
		var is_hover := _hover_index == i
		var is_sel := selected_vertex_index == i
		var big := is_hover or is_sel

		if _show_pie_chart_check.button_pressed:
			var radius := (PIE_RADIUS_BIG if big else PIE_RADIUS) 
			draw_circle(v, (radius + SELECT_CIRCLE_RADIUS) / scale_ratio, Color.WHITE if is_sel else Color.BLACK, true)
			var weights: Dictionary = _weight_cache[i] if i < _weight_cache.size() else _weight_manager.get_vertex_weights(polygon, i)
			_draw_pie(v, weights, big, radius / scale_ratio)
		else:
			if is_sel:
				draw_circle(v, 8 / scale_ratio, Color.BLACK, true)
			draw_circle(v, (6 if big else 3) / scale_ratio, Color.WHITE, true)

# Draws a pie chart at a vertex position showing bone weight distribution.
func _draw_pie(center: Vector2, weights: Dictionary, big: bool, radius: float) -> void:
	
	var total := 0.0
	for w in weights.values():
		total += w
	if total <= 0.001:
		draw_circle(center, radius, Color.DIM_GRAY)
		return

	# Optimization: single-bone shortcut
	for bp in weights:
		if weights[bp] > total * 0.999:
			draw_circle(center, radius, _weight_manager.get_bone_color(bp))
			return

	# Multi-bone pie
	var angle := -PI / 2.0
	for bp in weights:
		var w: float = weights[bp]
		if w <= 0.001: continue
		var span := (w / total) * TAU
		_draw_sector(center, radius, angle, angle + span, _weight_manager.get_bone_color(bp))
		angle += span

# Draws a filled sector (pie slice).
func _draw_sector(center: Vector2, radius: float, from: float, to: float, color: Color) -> void:
	var span := to - from
	var segments := clampi(int(span * 4.0), 3, 8)
	var pts := PackedVector2Array()
	pts.resize(segments + 2)
	pts[0] = center
	var step := span / segments
	for i in range(segments + 1):
		var a := from + i * step
		pts[i + 1] = center + Vector2(cos(a), sin(a)) * radius
	draw_colored_polygon(pts, color)

# --- Heatmap ---

func _draw_heatmap(polygon: Polygon2D, bone: Bone2D) -> void:
	if polygon.polygons.is_empty(): return

	var vert_count := polygon.polygon.size()
	var colors_cache: Array[Color] = []
	colors_cache.resize(vert_count)

	var is_sel_mode := bone and _heatmap_mode == HeatMapMode.SELECTED
	var is_none := _heatmap_mode == HeatMapMode.NONE
	var base_color: Color
	if is_sel_mode:
		base_color = _weight_manager.get_bone_color(_weight_manager.get_bone_path(bone))

	for i in range(vert_count):
		if is_none:
			colors_cache[i] = Color.WHITE
		elif is_sel_mode:
			colors_cache[i] = base_color * _weight_manager.get_vertex_weight(polygon, i, bone)
		else:
			colors_cache[i] = _blend_vertex_color(i)
		colors_cache[i] *= 0.9

	if is_none: return

	for tri in polygon.polygons:
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		pts.resize(tri.size())
		cols.resize(tri.size())
		for j in range(tri.size()):
			var idx: int = tri[j]
			pts[j] = polygon.polygon[idx]
			cols[j] = colors_cache[idx]
		draw_polygon(pts, cols)

# Blends bone colors weighted by vertex weights from cache.
func _blend_vertex_color(vertex_index: int) -> Color:
	var weights: Dictionary = _weight_cache[vertex_index]
	var r := 0.0; var g := 0.0; var b := 0.0; var tw := 0.0
	for bp in weights:
		var w: float = weights[bp]
		if w <= 0.001: continue
		var c := _weight_manager.get_bone_color(bp)
		r += c.r * w; g += c.g * w; b += c.b * w; tw += w
	if tw <= 0.001:
		return Color(0.2, 0.2, 0.2)
	return Color(r, g, b)

# --- Bone overlay ---

func _draw_bones(polygon: Polygon2D) -> void:
	var bone_paths: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	if not is_instance_valid(_global): return
	var skeleton: Skeleton2D = _global.current_skeleton
	if not skeleton or bone_paths.is_empty(): return
	var inv_poly := polygon.global_transform.affine_inverse()
	for bp in bone_paths:
		var bone: Bone2D = skeleton.get_node_or_null(bp)
		if not bone: continue
		var color := _weight_manager.get_bone_color(bp)
		var is_hovered := bone == _hover_bone
		var is_selected: bool = bone == _bone_item_list.get_selected_bone()
		var segments := PolyRigUtils.get_bone_rest_segments(bone, skeleton)
		for seg in segments:
			var head_local: Vector2 = inv_poly * seg[0]
			var tail_local: Vector2 = inv_poly * seg[1]
			_draw_bone_diamond(head_local, tail_local, color, is_hovered, is_selected)

# Draws a diamond-shaped bone gizmo in polygon-local space.
func _draw_bone_diamond(head: Vector2, tail: Vector2, color: Color, hovered: bool = false, selected: bool = false) -> void:
	var pts := _get_bone_diamond_polygon(head, tail)
	if pts.is_empty(): return

	var fill := color
	fill.a = 0.8
	if selected:
		fill = fill.lightened(0.4)
		fill.a = 1.0
	draw_colored_polygon(pts, fill)
	var border_color := Color.WHITE if (hovered or selected) else BONE_BORDER_COLOR
	for i in range(4):
		draw_line(pts[i], pts[(i + 1) % 4], border_color, BONE_LINE_WIDTH / scale_ratio, true)
	draw_circle(head, BONE_HEAD_RADIUS / scale_ratio, border_color)

func _on_show_pie_chart_check_box_toggled(toggled_on: bool) -> void:
	queue_redraw()

# --- Mouse-based hit detection ---

func _find_closest_vertex(_mouse_pos: Vector2) -> int:
	var polygon := PolyRigPlugin.current_polygon
	if not polygon: return -1
	var local_pos := _polygon_2d.get_local_mouse_position()
	var hit_radius := VERTEX_HIT_RADIUS / scale_ratio
	var best_dist := hit_radius * hit_radius
	var best_idx := -1
	for i in range(polygon.polygon.size()):
		var d := local_pos.distance_squared_to(polygon.polygon[i])
		if d < best_dist:
			best_dist = d
			best_idx = i
	return best_idx

# Returns the bone under the mouse, or null if none.
func _find_bone_at_mouse() -> Bone2D:
	if not _show_bone_check.button_pressed: return null
	var polygon := PolyRigPlugin.current_polygon
	if not polygon: return null
	var skeleton: Skeleton2D = _global.current_skeleton
	if not skeleton: return null

	var bone_paths: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	var inv_poly := polygon.global_transform.affine_inverse()
	var local_pos := _polygon_2d.get_local_mouse_position()

	for bp in bone_paths:
		var bone: Bone2D = skeleton.get_node_or_null(bp)
		if not bone: continue
		var segments := PolyRigUtils.get_bone_rest_segments(bone, skeleton)

		for seg in segments:
			var head_local: Vector2 = inv_poly * seg[0]
			var tail_local: Vector2 = inv_poly * seg[1]
			var diamond := _get_bone_diamond_polygon(head_local, tail_local)
			if Geometry2D.is_point_in_polygon(local_pos, diamond):
				return bone
				
	return null

func _get_bone_diamond_polygon(head: Vector2, tail: Vector2) -> PackedVector2Array:
	var dir := tail - head
	var length := dir.length()
	if length <= 0.001: return PackedVector2Array()
	var fwd := dir.normalized()
	var right := fwd.rotated(PI / 2)
	var width := clampf(length * 0.15, 5.0, 8.0)
	var mid := head + fwd * length * 0.2
	return PackedVector2Array([head, mid - right * width, tail, mid + right * width])

func _update_hover_from_mouse_pos(mouse_pos: Vector2) -> void:
	if _show_bone_check.button_pressed:
		var bone := _find_bone_at_mouse()
		if bone != _hover_bone:
			_hover_bone = bone
			queue_redraw()
			return

	if !_hover_bone:
		var idx := _find_closest_vertex(mouse_pos)
		if idx != _hover_index:
			_hover_index = idx
			queue_redraw()
			return

# Called when the user clicks on a bone in the chart. Override or connect to handle selection.
func _on_bone_clicked(_bone: Bone2D) -> void:
	_bone_item_list.select_bone(_bone)

func on_mouse_event(event: InputEvent):
	if not is_instance_valid(_global): return
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = event.position
		if _drag_vertex >= 0:
			var polygon := _global.current_polygon
			if polygon and _drag_bone:
				var offset := (_drag_last_mouse - get_global_mouse_position()).y / 100.0
				_weight_manager.set_vertex_weight_normalized(
					polygon,
					_drag_vertex,
					_drag_bone,
					_drag_init_weight + offset
				)
				_weight_cache_dirty = true
				queue_redraw()
		else:
			_update_hover_from_mouse_pos(mouse_pos)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var clicked_bone := _find_bone_at_mouse()
				if clicked_bone:
					_on_bone_clicked(clicked_bone)
				else:
					var idx := _find_closest_vertex(event.position)
					if idx >= 0:
						_begin_drag(idx)
					else:
						deselect_vertex()
			else:
				if _drag_vertex >= 0:
					_end_drag()

func _on_zoom_bar_zoom_changed(new_zoom: float) -> void:
	if not PolyRigBrushContainer.brush_enabled:
		var mouse_pos := get_local_mouse_position()
		_update_hover_from_mouse_pos(mouse_pos)
