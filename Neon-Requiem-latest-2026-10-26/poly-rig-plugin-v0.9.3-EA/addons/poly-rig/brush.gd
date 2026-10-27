@tool
class_name PolyRigBrush extends Control

@onready var _weight_manager: PolyRigWeightManager = %WeightManager
@onready var _weight_chart: PolyRigWeightChart = %WeightChart
@onready var _bone_item_list: VBoxContainer = %BoneItemList
@onready var _mouse_event: PolyRigMouseEvent = $"../MouseEvent"

const _PAINT_SPEED := 5.0

var _mouse_pos: Vector2 = Vector2.ZERO
var _is_pressed: bool = false
var _weight_snapshot: Dictionary = {}
var _dirty: bool = false
var _snapshot_bone_indices: Array[int] = []

# --- PolyRigBrush cursor drawing ---

func _draw() -> void:
	if not PolyRigBrushContainer.brush_enabled or not _mouse_event.mouse_in: return
	var radius := PolyRigBrushContainer.brush_size #* _weight_chart.scale_ratio
	var feather := PolyRigBrushContainer.feathering_size
	draw_arc(_mouse_pos, radius, 0, TAU, 64, Color(1, 1, 1, 0.3), 2.0)
	if feather > 0.001:
		var inner := radius * (1.0 - clampf(feather, 0.0, 1.0))
		if inner > 0.5:
			draw_arc(_mouse_pos, inner, 0, TAU, 64, Color(1, 1, 1, 0.8), 2.0)

# --- Input handling ---

func on_mouse_event(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_pos = event.position
		if event.pressed and not _is_pressed:
			var polygon := PolyRigPlugin.current_polygon
			if polygon:
				_snapshot_bone_indices = _get_relevant_bone_indices(polygon)
				_weight_snapshot = _weight_manager.snapshot_weights(polygon, _snapshot_bone_indices)
				_dirty = false
		elif not event.pressed and _is_pressed:
			_commit_brush_undo()
		_is_pressed = event.pressed

	if event is InputEventMouseMotion:
		_mouse_pos = event.position
		queue_redraw()

func update_mouse_position():
	_mouse_pos = get_local_mouse_position()
	queue_redraw()

func _process(delta: float) -> void:
	if _is_pressed and PolyRigBrushContainer.brush_enabled:
		_apply_brush(delta)

func _on_brush_container_brush_settings_changed() -> void:
	visible = PolyRigBrushContainer.brush_enabled
	queue_redraw()

# --- Core brush logic ---

func _apply_brush(delta: float) -> void:
	var polygon := PolyRigPlugin.current_polygon
	if not polygon: return
	var bone: Bone2D = _bone_item_list.get_selected_bone()
	if not bone: return

	var xform := _weight_chart.transform_matrix
	var radius := PolyRigBrushContainer.brush_size # * _weight_chart.scale_ratio
	var strength := PolyRigBrushContainer.brush_strength
	var feather := PolyRigBrushContainer.feathering_size
	var mode := PolyRigBrushContainer.brush_mode
	var mouse_local := _weight_chart.get_local_mouse_position()
	var changed := false

	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	var bone_data: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])

	for i in range(polygon.polygon.size()):
		var screen_pos := xform * polygon.polygon[i]
		var dist := mouse_local.distance_to(screen_pos)
		if dist > radius: continue

		# Feathered falloff
		var influence := 1.0
		if feather > 0.001:
			var inner := radius * (1.0 - feather)
			if dist > inner:
				influence = clampf(inverse_lerp(radius, inner, dist), 0.0, 1.0)

		# Pre-normalize so cur reflects the true proportion
		if skeleton and not bone_data.is_empty():
			_weight_manager.ensure_vertex_normalized(polygon, i, bone_data, skeleton)
		var cur := _weight_manager.get_vertex_weight(polygon, i, bone)
		var nw := cur
		var amount := strength * influence * _PAINT_SPEED * delta

		match mode:
			PolyRigBrushContainer.Mode.ADD:
				nw += amount
			PolyRigBrushContainer.Mode.SUBTRACT:
				nw -= amount
			PolyRigBrushContainer.Mode.REPLACE:
				nw = move_toward(cur, strength, influence * _PAINT_SPEED * delta)

		nw = clampf(nw, 0.0, 1.0)
		if not is_equal_approx(cur, nw):
			_weight_manager.set_vertex_weight_normalized(polygon, i, bone, nw)
			changed = true

	if changed:
		_dirty = true
		_weight_chart.queue_redraw()

func _get_relevant_bone_indices(polygon: Polygon2D) -> Array[int]:
	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	if not skeleton: return []
	var bone_data: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	var indices: Array[int] = []
	for bp in bone_data:
		var bone: Bone2D = skeleton.get_node_or_null(bp)
		if bone:
			var bi := bone.get_index_in_skeleton()
			if bi >= 0 and bi < polygon.get_bone_count():
				indices.append(bi)
	return indices

func _commit_brush_undo() -> void:
	var polygon := PolyRigPlugin.current_polygon
	if not polygon or _weight_snapshot.is_empty() or not _dirty:
		_weight_snapshot = {}
		_snapshot_bone_indices = []
		return
	var new_snap: Dictionary = _weight_manager.snapshot_weights(polygon, _snapshot_bone_indices)
	_weight_manager.commit_all_weights_undo("PolyRigBrush paint weights", polygon, _weight_snapshot, new_snap)
	_weight_snapshot = {}
	_snapshot_bone_indices = []

func _on_zoom_bar_zoom_changed(new_zoom: float) -> void:
	queue_redraw()

func _on_mouse_event_mouse_in_changed(mouse_in: bool) -> void:
	visible = mouse_in
