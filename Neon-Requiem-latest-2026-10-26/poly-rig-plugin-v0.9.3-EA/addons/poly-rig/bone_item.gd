@tool
class_name PolyRigBoneItem extends Button

signal delete_button_pressed
signal weight_changed(bone: Bone2D, weight: float)

@onready var _label: Label = %BoneNameLabel
@onready var _spin: SpinBox = %SpinBox
@onready var _slider: HSlider = %HSlider
@onready var _texture_rect: TextureRect = $HBoxContainer/TextureRect

var _editable: bool = true

var bone: Bone2D:
	set(value):
		bone = value
		if is_inside_tree() and bone:
			_label.text = bone.name

var color: Color:
	set(value):
		color = value
		if is_inside_tree():
			#_label.modulate = color
			_texture_rect.modulate = color
			

var weight: float = 0.0:
	set(value):
		weight = value
		if _slider and _spin:
			_spin.set_value_no_signal(value)
			_slider.set_value_no_signal(value)

func _ready() -> void:
	if bone:
		_label.text = bone.name
		#_label.modulate = color
		_texture_rect.modulate = color
	_spin.value = weight
	_slider.value = weight

func _on_delete_button_pressed() -> void:
	delete_button_pressed.emit()

func _on_spin_box_value_changed(value: float) -> void:
	if not _editable: return
	weight = value
	weight_changed.emit(bone, weight)

func _on_h_slider_value_changed(value: float) -> void:
	if not _editable: return
	weight = value
	weight_changed.emit(bone, weight)

func set_input_disabled(is_disabled: bool) -> void:
	if not is_inside_tree(): await ready
	_spin.editable = not is_disabled
	_slider.editable = not is_disabled
	_editable = not is_disabled
