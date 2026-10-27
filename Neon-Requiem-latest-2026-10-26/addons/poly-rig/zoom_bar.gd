@tool
class_name PolyRigZoomBar extends HBoxContainer

@onready var zoom_more: Button = $ZoomMore
@onready var zoom_number: Button = $ZoomNumber
@onready var zoom_less: Button = $ZoomLess

signal zoom_changed(new_zoom: float)
signal reset_requested()

const ZOOM_MIN := 0.1
const ZOOM_MAX := 10.0
const ZOOM_STEP := 1.1

var _suppress_signal: bool = false

var zoom := 1.0:
	set(value):
		zoom = clampf(value, ZOOM_MIN, ZOOM_MAX)
		if zoom_number:
			zoom_number.text = str(snapped(zoom, 0.01) * 100) + "%"
		if not _suppress_signal:
			zoom_changed.emit(zoom)

func set_zoom_no_signal(value: float) -> void:
	_suppress_signal = true
	zoom = value
	_suppress_signal = false

func change_zoom(factor: float) -> void:
	zoom *= factor

func _on_zoom_less_pressed() -> void:
	change_zoom(1.0 / ZOOM_STEP)

func _on_zoom_more_pressed() -> void:
	change_zoom(ZOOM_STEP)

func _on_zoom_number_pressed() -> void:
	reset_requested.emit()
