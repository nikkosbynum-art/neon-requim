extends RefCounted
class_name PrototypeRosterStateService

## Identity-based run state for active recruits and reserves. Combat callers own
## the timing of changes; this service never mutates a running simulation.

const ACTIVE_SLOT_COUNT := 6
const CANONICAL_RECRUIT_IDS := [
	"bulwark", "breaker", "cipher", "spark", "specter", "ironclad",
	"stitch", "recoil", "echo", "vector", "deadlock", "glitch"
]


static func migrate_legacy_slot_hp(run_state: Dictionary) -> Dictionary:
	var candidate := run_state.duplicate(true)
	if not candidate.has("squad_hp"):
		return {"ok": true, "run": candidate, "migrated": false}
	var legacy_hp: Variant = candidate.get("squad_hp", null)
	if typeof(legacy_hp) != TYPE_ARRAY or legacy_hp.size() != ACTIVE_SLOT_COUNT:
		return {"ok": false, "error": "Legacy squad HP must contain six positional values."}
	for hp_value in legacy_hp:
		if not _is_nonnegative_number(hp_value):
			return {"ok": false, "error": "Legacy squad HP contains an invalid value."}
	var recruits: Variant = candidate.get("recruits", null)
	if typeof(recruits) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Run recruit state is missing."}
	var breaker: Variant = recruits.get("breaker", null)
	if typeof(breaker) != TYPE_DICTIONARY:
		return {"ok": false, "error": "BREAKER run state is missing."}
	var breaker_state: Dictionary = breaker.duplicate(true)
	# The source squad definition explicitly identifies position zero as BREAKER.
	# Positions 1..5 are unassigned placeholders and remain unmapped legacy data.
	breaker_state["hp"] = float(legacy_hp[0])
	var updated_recruits: Dictionary = recruits.duplicate(true)
	updated_recruits["breaker"] = breaker_state
	candidate["recruits"] = updated_recruits
	var legacy_placeholder_hp: Array = []
	for index in range(1, legacy_hp.size()):
		legacy_placeholder_hp.append(legacy_hp[index])
	candidate["legacy_placeholder_squad_hp"] = legacy_placeholder_hp
	candidate.erase("squad_hp")
	return {"ok": true, "run": candidate, "migrated": true}


static func ensure_owned_recruit_records(run_state: Dictionary, owned_ids: Array, max_hp_by_id: Dictionary) -> Dictionary:
	var candidate := run_state.duplicate(true)
	var recruits_value: Variant = candidate.get("recruits", null)
	if typeof(recruits_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Run recruit state must be an object."}
	var recruits: Dictionary = recruits_value.duplicate(true)
	var seen: Dictionary = {}
	for id_value in owned_ids:
		var recruit_id := str(id_value)
		if not CANONICAL_RECRUIT_IDS.has(recruit_id) or seen.has(recruit_id):
			return {"ok": false, "error": "Owned recruit IDs must be unique founding roster IDs."}
		seen[recruit_id] = true
		var maximum_value: Variant = max_hp_by_id.get(recruit_id, null)
		if not _is_nonnegative_number(maximum_value):
			return {"ok": false, "error": "Maximum HP is missing or invalid for %s." % recruit_id}
		var existing_value: Variant = recruits.get(recruit_id, {})
		if typeof(existing_value) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Run state is invalid for %s." % recruit_id}
		var recruit_state: Dictionary = existing_value.duplicate(true)
		var level_value: Variant = recruit_state.get("level", 1)
		if not _is_positive_integer(level_value):
			return {"ok": false, "error": "Run level is invalid for %s." % recruit_id}
		recruit_state["level"] = int(level_value)
		var hp_value: Variant = recruit_state.get("hp", maximum_value)
		if not _is_nonnegative_number(hp_value):
			return {"ok": false, "error": "Run HP is invalid for %s." % recruit_id}
		recruit_state["hp"] = clampf(float(hp_value), 0.0, float(maximum_value))
		recruits[recruit_id] = recruit_state
	candidate["recruits"] = recruits
	return {"ok": true, "run": candidate}


static func validate_active_lineup(lineup_value: Variant, owned_ids: Array) -> Dictionary:
	if typeof(lineup_value) != TYPE_ARRAY or lineup_value.size() != ACTIVE_SLOT_COUNT:
		return {"ok": false, "error": "Active lineup must contain exactly six slots."}
	var owned: Dictionary = {}
	for id_value in owned_ids:
		owned[str(id_value)] = true
	var used: Dictionary = {}
	for slot_value in lineup_value:
		if typeof(slot_value) != TYPE_STRING:
			return {"ok": false, "error": "Active lineup slots must be recruit IDs or empty strings."}
		var recruit_id := str(slot_value)
		if recruit_id.is_empty():
			continue
		if not CANONICAL_RECRUIT_IDS.has(recruit_id) or not owned.has(recruit_id) or used.has(recruit_id):
			return {"ok": false, "error": "Active lineup contains an unowned, unknown, or duplicate recruit."}
		used[recruit_id] = true
	return {"ok": true, "lineup": lineup_value.duplicate(true)}


static func build_default_lineup(owned_ids: Array) -> Array[String]:
	var owned: Dictionary = {}
	for id_value in owned_ids:
		owned[str(id_value)] = true
	var lineup: Array[String] = []
	# A missing lineup is filled from the stable founding-roster order.
	for recruit_id in CANONICAL_RECRUIT_IDS:
		if owned.has(recruit_id) and lineup.size() < ACTIVE_SLOT_COUNT:
			lineup.append(recruit_id)
	while lineup.size() < ACTIVE_SLOT_COUNT:
		lineup.append("")
	return lineup


static func auto_fill_first_open(lineup_value: Variant, owned_ids: Array, recruit_id: String) -> Dictionary:
	var validation := validate_active_lineup(lineup_value, owned_ids)
	if not bool(validation.get("ok", false)):
		return validation
	if not owned_ids.has(recruit_id):
		return {"ok": false, "error": "Only an owned recruit can be deployed."}
	var lineup: Array = validation["lineup"]
	if lineup.has(recruit_id):
		return {"ok": true, "lineup": lineup, "deployed": true, "already_active": true}
	var open_slot := lineup.find("")
	if open_slot < 0:
		return {"ok": true, "lineup": lineup, "deployed": false, "reserve": true}
	lineup[open_slot] = recruit_id
	return {"ok": true, "lineup": lineup, "deployed": true, "slot": open_slot}


static func swap_lineup_slot(run_state: Dictionary, owned_ids: Array, slot_index: int, recruit_id: String, combat_is_active: bool) -> Dictionary:
	if combat_is_active:
		return {"ok": false, "error": "Lineup changes are only allowed between encounters."}
	if slot_index < 0 or slot_index >= ACTIVE_SLOT_COUNT:
		return {"ok": false, "error": "Lineup slot is outside the six-slot range."}
	if not recruit_id.is_empty() and (not CANONICAL_RECRUIT_IDS.has(recruit_id) or not owned_ids.has(recruit_id)):
		return {"ok": false, "error": "Only an owned founding recruit can be deployed."}
	var lineup_value: Variant = run_state.get("active_lineup", null)
	var lineup_check := validate_active_lineup(lineup_value, owned_ids)
	if not bool(lineup_check.get("ok", false)):
		return lineup_check
	var lineup: Array = lineup_check["lineup"]
	var prior_index := lineup.find(recruit_id) if not recruit_id.is_empty() else -1
	if prior_index >= 0 and prior_index != slot_index:
		lineup[prior_index] = str(lineup[slot_index])
	lineup[slot_index] = recruit_id
	var candidate := run_state.duplicate(true)
	candidate["active_lineup"] = lineup
	return {"ok": true, "run": candidate}


static func heal_owned_recruits(run_state: Dictionary, owned_ids: Array, max_hp_by_id: Dictionary) -> Dictionary:
	var prepared := ensure_owned_recruit_records(run_state, owned_ids, max_hp_by_id)
	if not bool(prepared.get("ok", false)):
		return prepared
	var candidate: Dictionary = prepared["run"]
	var recruits: Dictionary = candidate["recruits"]
	for id_value in owned_ids:
		var recruit_id := str(id_value)
		var recruit_state: Dictionary = recruits[recruit_id]
		recruit_state["hp"] = float(max_hp_by_id[recruit_id])
		recruits[recruit_id] = recruit_state
	candidate["recruits"] = recruits
	return {"ok": true, "run": candidate}


static func _is_nonnegative_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value)) and float(value) >= 0.0


static func _is_positive_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return int(value) > 0
	return typeof(value) == TYPE_FLOAT and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value))) and float(value) > 0.0
