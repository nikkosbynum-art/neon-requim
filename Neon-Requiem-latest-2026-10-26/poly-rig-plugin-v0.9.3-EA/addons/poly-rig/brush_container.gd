@tool
class_name PolyRigBrushContainer extends HBoxContainer

signal brush_settings_changed

@onready var _size_slider: HSlider = %BrushSizeSlider
@onready var _feather_slider: HSlider = %FeatheringSizeSlider
@onready var strength_input_field: PolyRigNumberInputField = $StrengthInputField

enum Mode { DIRECT, ADD, SUBTRACT, REPLACE }

static var brush_size: float = 50.0
static var feathering_size: float = 0.2
static var brush_strength: float = 1.0
static var brush_mode: Mode = Mode.DIRECT
static var brush_enabled: bool = false

func _ready() -> void:
	brush_size = 50.0
	feathering_size = 0.3
	brush_strength = 1.0
	_size_slider.value = brush_size
	_feather_slider.value = feathering_size
	strength_input_field.number = brush_strength
	brush_enabled = false
	hide()

func _on_brush_size_slider_value_changed(value: float) -> void:
	brush_size = value
	brush_settings_changed.emit()

func _on_feathering_size_slider_value_changed(value: float) -> void:
	feathering_size = value
	brush_settings_changed.emit()

func _on_weight_type_option_button_item_selected(index: int) -> void:
	brush_mode = index as Mode
	brush_enabled = brush_mode != Mode.DIRECT
	visible = brush_enabled
	brush_settings_changed.emit()

func _on_strength_input_field_value_changed(value: float) -> void:
	brush_strength = value
	brush_settings_changed.emit()
