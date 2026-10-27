extends Node
class_name AttachmentEventRouter

## Routes simulation-owned events to presentation receivers. It never calls back into combat.
## Receivers implement present_combat_event(event: Dictionary).

var _attachments: Dictionary = {}
var _last_event_sequence := 0


func register_attachment(attachment_id: String, owner_instance_id: String, receiver: Object, event_types: Array, owner_match_field: String = "source_id") -> bool:
	if attachment_id.strip_edges().is_empty() or owner_instance_id.strip_edges().is_empty():
		return false
	if _attachments.has(attachment_id):
		return false
	if not is_instance_valid(receiver) or not receiver.has_method("present_combat_event"):
		return false
	if owner_match_field not in ["source_id", "target_id"]:
		return false
	var accepted_events: Array[String] = []
	for event_type in event_types:
		var name := str(event_type).strip_edges()
		if not name.is_empty() and not accepted_events.has(name):
			accepted_events.append(name)
	if accepted_events.is_empty():
		return false
	_attachments[attachment_id] = {
		"owner_instance_id": owner_instance_id,
		"receiver": weakref(receiver),
		"event_types": accepted_events,
		"owner_match_field": owner_match_field
	}
	return true


func unregister_attachment(attachment_id: String) -> bool:
	return _attachments.erase(attachment_id)


func dispatch_combat_event(event: Dictionary) -> int:
	var sequence_value: Variant = event.get("sequence", null)
	if typeof(sequence_value) != TYPE_INT or int(sequence_value) <= _last_event_sequence:
		return 0
	var event_type := str(event.get("event_type", "")).strip_edges()
	var source_id := str(event.get("source_id", "")).strip_edges()
	# Resolved self/owner events (for example a support ability with no target)
	# are valid presentation events. Target-owned receivers simply won't match
	# unless the event contains a target_id.
	if event_type.is_empty() or source_id.is_empty():
		return 0
	_last_event_sequence = int(sequence_value)
	var delivered := 0
	var stale_ids: Array[String] = []
	for attachment_id in _attachments:
		var registration: Dictionary = _attachments[attachment_id]
		if not registration["event_types"].has(event_type):
			continue
		var match_field: String = registration["owner_match_field"]
		if str(event.get(match_field, "")) != str(registration["owner_instance_id"]):
			continue
		var receiver: Object = registration["receiver"].get_ref()
		if not is_instance_valid(receiver):
			stale_ids.append(str(attachment_id))
			continue
		receiver.call("present_combat_event", event.duplicate(true))
		delivered += 1
	for attachment_id in stale_ids:
		_attachments.erase(attachment_id)
	return delivered


func registered_attachment_count() -> int:
	return _attachments.size()


## Reset only when attaching the router to a newly initialized combat simulation.
func reset_event_sequence() -> void:
	_last_event_sequence = 0
