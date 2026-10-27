extends Node2D
class_name EnvironmentDirector

## Presentation-only zone selector and crossfade. It never changes combat or wave state.

signal zone_changed(previous_zone_id: String, current_zone_id: String, wave: int)

const BACKDROP_SCRIPT := preload("res://scripts/environment/undercity_backdrop.gd")
const ZONE_DATA_PATH := "res://data/zones/undercity_prototype_zones.json"

var zone_data: Dictionary = {}
var active_zone_id := ""
var active_backdrop: UndercityBackdrop
var transition_tween: Tween


func _ready() -> void:
	zone_data = _read_zone_data()
	apply_wave(1)


func _read_zone_data() -> Dictionary:
	if not FileAccess.file_exists(ZONE_DATA_PATH):
		push_error("Missing encounter-zone definition: %s" % ZONE_DATA_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ZONE_DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("zones", null)) != TYPE_ARRAY:
		push_error("Invalid encounter-zone definition: %s" % ZONE_DATA_PATH)
		return {}
	return parsed


func zone_for_wave(target_wave: int) -> Dictionary:
	for zone_variant in zone_data.get("zones", []):
		if typeof(zone_variant) != TYPE_DICTIONARY:
			continue
		var zone: Dictionary = zone_variant
		if target_wave >= int(zone.get("first_wave", 1)) and target_wave <= int(zone.get("last_wave", 0)):
			return zone.duplicate(true)
	return {}


func apply_wave(target_wave: int) -> bool:
	var next_zone := zone_for_wave(target_wave)
	if next_zone.is_empty():
		return false
	var next_id := str(next_zone.get("zone_id", ""))
	if next_id.is_empty() or next_id == active_zone_id:
		return false

	if is_instance_valid(transition_tween) and transition_tween.is_running():
		transition_tween.kill()
	for child in get_children():
		if child != active_backdrop:
			child.queue_free()

	var previous_id := active_zone_id
	var previous_backdrop := active_backdrop
	var next_backdrop := BACKDROP_SCRIPT.new() as UndercityBackdrop
	next_backdrop.name = "EncounterZone_%s" % next_id
	next_backdrop.configure(next_zone)
	next_backdrop.modulate.a = 0.0 if is_instance_valid(previous_backdrop) else 1.0
	add_child(next_backdrop)
	move_child(next_backdrop, 0)
	active_backdrop = next_backdrop
	active_zone_id = next_id

	if is_instance_valid(previous_backdrop):
		var duration := maxf(0.05, float(next_zone.get("transition_seconds", 0.85)))
		transition_tween = create_tween().set_parallel(true)
		transition_tween.tween_property(next_backdrop, "modulate:a", 1.0, duration)
		transition_tween.tween_property(previous_backdrop, "modulate:a", 0.0, duration)
		transition_tween.finished.connect(func() -> void:
			if is_instance_valid(previous_backdrop):
				previous_backdrop.queue_free()
		)
	zone_changed.emit(previous_id, active_zone_id, target_wave)
	return true
