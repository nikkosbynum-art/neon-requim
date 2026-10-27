@tool
class_name PolyRigMouseEvent extends Control

signal mouse_in_changed(mouse_in: bool)

@onready var _weight_chart: PolyRigWeightChart = %WeightChart
@onready var _drag_manager: PolyRigDragManager = %DragManager
@onready var brush: PolyRigBrush = $"../Brush"
@onready var weight_type_option_button: OptionButton = %WeightTypeOptionButton

var mouse_in = false

func _ready() -> void:
	mouse_in = false
	set_process_unhandled_key_input(true)

func _gui_input(event: InputEvent) -> void:
	var is_handled = _drag_manager.handle_input(event)
	if is_handled:
		accept_event()
	if PolyRigBrushContainer.brush_enabled:
		# 若 is_handled PolyRigBrush 也应该可以处理
		brush.on_mouse_event(event)
	elif not is_handled:
		_weight_chart.on_mouse_event(event)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner is LineEdit or focus_owner is TextEdit:
			return
		if event.ctrl_pressed or event.shift_pressed or event.alt_pressed:
			return
		var handled = true
		match event.keycode:
			KEY_D:
				weight_type_option_button.select(0)
				
			KEY_A:
				weight_type_option_button.select(1)
			KEY_S:
				weight_type_option_button.select(2)
			KEY_R:
				weight_type_option_button.select(3)
			_:
				handled = false
		if handled:
			get_viewport().set_input_as_handled()
			weight_type_option_button.item_selected.emit(weight_type_option_button.selected)
			brush.update_mouse_position()
			
func _on_mouse_entered() -> void:
	mouse_in = true
	mouse_in_changed.emit(mouse_in)

func _on_mouse_exited() -> void:
	mouse_in = false
	mouse_in_changed.emit(mouse_in)
