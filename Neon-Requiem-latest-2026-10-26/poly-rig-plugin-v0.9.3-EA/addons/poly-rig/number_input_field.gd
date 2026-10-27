@tool
class_name PolyRigNumberInputField extends HBoxContainer

signal value_changed(value: float)

@export var field_name: String = ""
@export var emit_drag_end: bool = true
@export var number: float = 0.0:
	set(value):
		if value == number: return
		number = value
		if _slider and _spin:
			_slider.set_value_no_signal(value)
			_spin.set_value_no_signal(value)

@export var min_value: float = 0
@export var max_value: float = 1
@export var step: float = 0.01
@export var disabled: bool = false:
	set(value):
		disabled = value
		if _slider: _slider.editable = not value
		if _spin: _spin.editable = not value

@onready var _label: Label = $Label
@onready var _slider: HSlider = $HSlider
@onready var _spin: SpinBox = $SpinBox

func _ready() -> void:
	_label.text = field_name
	_slider.set_value_no_signal(number)
	_spin.set_value_no_signal(number)
	_slider.min_value = min_value
	_spin.min_value = min_value
	_slider.max_value = max_value
	_spin.max_value = max_value
	_slider.step = step
	_spin.step = step

func _on_h_slider_value_changed(value: float) -> void:
	if number != value and not emit_drag_end:
		number = value
		value_changed.emit(number)

func _on_spin_box_value_changed(value: float) -> void:
	if number != value:
		number = value
		value_changed.emit(value)

func _on_h_slider_drag_ended(_is_value_changed: bool) -> void:
	if number != _slider.value and emit_drag_end:
		number = _slider.value
		value_changed.emit(number)
