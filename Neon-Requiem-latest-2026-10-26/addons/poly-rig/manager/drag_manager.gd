@tool
class_name PolyRigDragManager extends Node

@onready var _zoom_bar: PolyRigZoomBar = %ZoomBar
@onready var _weight_chart: PolyRigWeightChart = %WeightChart
@onready var _v_scroll_bar: VScrollBar = %VScrollBar
@onready var _h_scroll_bar: HScrollBar = %HScrollBar

const ZOOM_MIN := 0.1
const ZOOM_MAX := 10.0
const ZOOM_STEP := 1.1
const PAN_PADDING := 200.0

var _user_zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _base_transform: Transform2D = Transform2D.IDENTITY
var _base_scale: float = 1.0

var _is_panning: bool = false
var _pan_start_mouse: Vector2 = Vector2.ZERO
var _pan_start_offset: Vector2 = Vector2.ZERO
var _suppress_scrollbar: bool = false

func _ready() -> void:
	pass
	#_zoom_bar.zoom_changed.connect(_on_zoom_bar_zoom_changed)
	#_zoom_bar.reset_requested.connect(reset_view)
	#_h_scroll_bar.value_changed.connect(_on_h_scroll_value_changed)
	#_v_scroll_bar.value_changed.connect(_on_v_scroll_value_changed)

func reset_view() -> void:
	_user_zoom = 1.0
	_pan_offset = Vector2.ZERO
	_sync_zoom_bar()
	_sync_scrollbars()
	_weight_chart.update_weight_chart()

func update_base_transform(polygon: Polygon2D, view_size: Vector2) -> void:
	var result := PolyRigUtils.calculate_transform(polygon, view_size)
	_base_transform = result[0]
	_base_scale = result[1]
	_sync_scrollbars()

func get_final_transform() -> Transform2D:
	var user_xform := Transform2D(
		Vector2(_user_zoom, 0), Vector2(0, _user_zoom), _pan_offset
	)
	return user_xform * _base_transform

func get_scale_ratio() -> float:
	return _base_scale * _user_zoom

# --- Input handling ---

func handle_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return _handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		return _handle_mouse_motion(event)
	return false

func _handle_mouse_button(event: InputEventMouseButton) -> bool:
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			_is_panning = true
			_pan_start_mouse = event.position
			_pan_start_offset = _pan_offset
		else:
			_is_panning = false
		return true
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_zoom_at(event.position, ZOOM_STEP)
		return true
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_zoom_at(event.position, 1.0 / ZOOM_STEP)
		return true
	return false

func _handle_mouse_motion(event: InputEventMouseMotion) -> bool:
	if _is_panning:
		_pan_offset = _pan_start_offset + (event.position - _pan_start_mouse)
		_clamp_pan()
		_sync_scrollbars()
		_weight_chart.update_weight_chart()
		return true
	return false

# --- Zoom ---

func _zoom_at(mouse_pos: Vector2, factor: float) -> void:
	var new_zoom := clampf(_user_zoom * factor, ZOOM_MIN, ZOOM_MAX)
	var actual_factor := new_zoom / _user_zoom
	_pan_offset = mouse_pos * (1.0 - actual_factor) + _pan_offset * actual_factor
	_user_zoom = new_zoom
	_clamp_pan()
	_sync_zoom_bar()
	_sync_scrollbars()
	_weight_chart.update_weight_chart()

func _on_zoom_bar_zoom_changed(new_zoom: float) -> void:
	if not _weight_chart: return
	var center := _weight_chart.size / 2.0
	var clamped := clampf(new_zoom, ZOOM_MIN, ZOOM_MAX)
	var actual_factor := clamped / _user_zoom
	_pan_offset = center * (1.0 - actual_factor) + _pan_offset * actual_factor
	_user_zoom = clamped
	_clamp_pan()
	_sync_scrollbars()
	_weight_chart.update_weight_chart()

func _sync_zoom_bar() -> void:
	_zoom_bar.zoom = _user_zoom

# --- Scrollbars ---

func _on_h_scroll_value_changed(value: float) -> void:
	if _suppress_scrollbar: return
	_pan_offset.x = -value
	_weight_chart.update_weight_chart()

func _on_v_scroll_value_changed(value: float) -> void:
	if _suppress_scrollbar: return
	_pan_offset.y = -value
	_weight_chart.update_weight_chart()

func _sync_scrollbars() -> void:
	var bounds := _get_pan_bounds()
	if bounds.is_empty(): return
	var pan_min: Vector2 = bounds[0]
	var pan_max: Vector2 = bounds[1]
	var view_size := _weight_chart.size

	_suppress_scrollbar = true
	# Negate: scrollbar value = -pan_offset (scroll right => pan left)
	_h_scroll_bar.min_value = -pan_max.x
	_h_scroll_bar.max_value = -pan_min.x + view_size.x
	_h_scroll_bar.page = view_size.x
	_h_scroll_bar.value = -_pan_offset.x

	_v_scroll_bar.min_value = -pan_max.y
	_v_scroll_bar.max_value = -pan_min.y + view_size.y
	_v_scroll_bar.page = view_size.y
	_v_scroll_bar.value = -_pan_offset.y
	_suppress_scrollbar = false

# --- Pan bounds ---

func _get_pan_bounds() -> Array:
	var polygon := PolyRigPlugin.current_polygon
	if not polygon or not _weight_chart: return []
	var rect := PolyRigUtils.get_polygon_bounding_rect(polygon)
	if rect.size == Vector2.ZERO: return []
	var view_size := _weight_chart.size
	var padding := PAN_PADDING

	# Polygon corners in base-transform space
	var corners := [
		_base_transform * rect.position,
		_base_transform * (rect.position + Vector2(rect.size.x, 0)),
		_base_transform * (rect.position + rect.size),
		_base_transform * (rect.position + Vector2(0, rect.size.y)),
	]
	var bmin: Vector2 = corners[0]
	var bmax: Vector2 = corners[0]
	for c in corners:
		bmin = Vector2(minf(bmin.x, c.x), minf(bmin.y, c.y))
		bmax = Vector2(maxf(bmax.x, c.x), maxf(bmax.y, c.y))

	# Screen pos = base_pos * _user_zoom + _pan_offset
	# Constraint: polygon must stay at least partially visible
	var smax_no_pan: Vector2 = bmax * _user_zoom
	var smin_no_pan: Vector2 = bmin * _user_zoom
	var pan_min: Vector2 = Vector2(-padding, -padding) - smax_no_pan
	var pan_max: Vector2 = view_size + Vector2(padding, padding) - smin_no_pan
	return [pan_min, pan_max]

func _clamp_pan() -> void:
	var bounds := _get_pan_bounds()
	if bounds.is_empty(): return
	var pan_min: Vector2 = bounds[0]
	var pan_max: Vector2 = bounds[1]
	_pan_offset.x = clampf(_pan_offset.x, pan_min.x, pan_max.x)
	_pan_offset.y = clampf(_pan_offset.y, pan_min.y, pan_max.y)
