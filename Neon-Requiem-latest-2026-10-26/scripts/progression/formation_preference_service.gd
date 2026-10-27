extends RefCounted
class_name PrototypeFormationPreferenceService

## Stores UI-selected preferences only. Combat and movement do not consume these
## values in this prototype milestone.

const RECRUIT_IDS := [
	"bulwark", "breaker", "cipher", "spark", "specter", "ironclad",
	"stitch", "recoil", "echo", "vector", "deadlock", "glitch"
]
const POSITION_VALUES := ["", "Front", "Middle", "Rear"]
const ROLE_VALUES := ["", "Vanguard", "Assault", "Support", "Control"]


static func set_preference(permanent_state: Dictionary, recruit_id: String, position: String, role: String) -> Dictionary:
	if not RECRUIT_IDS.has(recruit_id):
		return {"ok": false, "error": "Formation preference recruit ID is not canonical."}
	if not POSITION_VALUES.has(position) or not ROLE_VALUES.has(role):
		return {"ok": false, "error": "Formation position or role is invalid."}
	var existing_value: Variant = permanent_state.get("formation_preferences", {})
	if typeof(existing_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Saved formation preferences are invalid."}
	var preferences: Dictionary = existing_value.duplicate(true)
	if position.is_empty() and role.is_empty():
		preferences.erase(recruit_id)
	else:
		preferences[recruit_id] = {"position": position, "role": role}
	var candidate := permanent_state.duplicate(true)
	candidate["formation_preferences"] = preferences
	return {"ok": true, "permanent": candidate}


static func validate(preferences_value: Variant) -> String:
	if typeof(preferences_value) != TYPE_DICTIONARY:
		return "Permanent formation_preferences must be an object."
	for recruit_id in preferences_value:
		if typeof(recruit_id) != TYPE_STRING or not RECRUIT_IDS.has(str(recruit_id)):
			return "Formation preference recruit IDs must be canonical founding roster IDs."
		var preference_value: Variant = preferences_value[recruit_id]
		if typeof(preference_value) != TYPE_DICTIONARY:
			return "Formation preference entries must be objects."
		var preference: Dictionary = preference_value
		for key in preference:
			if key not in ["position", "role"]:
				return "Formation preference contains an unknown selector field."
		if not POSITION_VALUES.has(str(preference.get("position", ""))) or not ROLE_VALUES.has(str(preference.get("role", ""))):
			return "Formation preference selector value is invalid."
	return ""
