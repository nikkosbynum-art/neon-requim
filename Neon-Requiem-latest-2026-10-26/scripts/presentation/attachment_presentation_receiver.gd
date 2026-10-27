extends Node2D
class_name AttachmentPresentationReceiver

## Receives simulation-owned events and plays explicitly mapped visual clips.
## This node never changes combat state, chooses targets, or applies effects.

@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@export var event_animation_map: Dictionary = {}

var last_presented_sequence := 0
var last_presented_event_type := ""
var last_presented_animation := ""
var received_event_count := 0


func present_combat_event(event: Dictionary) -> void:
	var sequence_value: Variant = event.get("sequence", null)
	if typeof(sequence_value) != TYPE_INT or int(sequence_value) <= last_presented_sequence:
		return
	var event_type := str(event.get("event_type", "")).strip_edges()
	if event_type.is_empty():
		return

	last_presented_sequence = int(sequence_value)
	last_presented_event_type = event_type
	received_event_count += 1

	var animation_name := str(event_animation_map.get(event_type, "")).strip_edges()
	if animation_name.is_empty():
		return
	var player := get_node_or_null(animation_player_path) as AnimationPlayer
	if player == null or not player.has_animation(animation_name):
		return
	last_presented_animation = animation_name
	player.play(animation_name)
