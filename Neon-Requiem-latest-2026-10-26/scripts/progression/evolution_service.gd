extends RefCounted
class_name PrototypeEvolutionService

## Permanent, save-backed evolution unlock transaction. This records progression
## only; it deliberately does not invent tier stat bonuses or visual assets.
const RULES_SCRIPT := preload("res://scripts/progression/progression_rules.gd")
const TIER_ORDER := ["Origin Form", "Adapted Form", "Signature Form", "Requiem Form"]
const LEGACY_TIER_LABELS := {"Street Grade": "Origin Form", "Combat Grade": "Adapted Form", "Military Grade": "Signature Form", "Apex Grade": "Requiem Form"}
const APPROVED_RECRUIT_IDS := [
	"bulwark", "breaker", "cipher", "spark", "specter", "ironclad",
	"stitch", "recoil", "echo", "vector", "deadlock", "glitch"
]


static func get_next_tier(permanent_state: Dictionary, recruit_id: String) -> Dictionary:
	var key_result := _tier_key(recruit_id)
	if not bool(key_result.get("ok", false)):
		return key_result
	var evolution_value: Variant = permanent_state.get("evolution", {})
	if typeof(evolution_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Permanent evolution state is malformed."}
	var current_tier: String = canonical_tier_label(evolution_value.get(key_result["key"], "Origin Form"))
	var current_index := TIER_ORDER.find(current_tier)
	if current_index < 0:
		return {"ok": false, "error": "Recruit evolution tier is invalid."}
	if current_index >= TIER_ORDER.size() - 1:
		return {"ok": true, "complete": true, "current_tier": TIER_ORDER[current_index]}
	return {"ok": true, "complete": false, "current_tier": TIER_ORDER[current_index], "next_tier": TIER_ORDER[current_index + 1], "key": key_result["key"]}


static func evaluate_next_tier(permanent_state: Dictionary, recruit_id: String, profile: Dictionary) -> Dictionary:
	var next_result := get_next_tier(permanent_state, recruit_id)
	if not bool(next_result.get("ok", false)) or bool(next_result.get("complete", false)):
		return next_result
	var evolution_profile: Variant = profile.get("evolution", null)
	if typeof(evolution_profile) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Evolution profile is missing."}
	var gates: Variant = evolution_profile.get("gates", null)
	if typeof(gates) != TYPE_DICTIONARY or not gates.has(next_result["next_tier"]):
		return {"ok": false, "error": "Evolution gate profile is missing for %s." % next_result["next_tier"]}
	var gate: Dictionary = RULES_SCRIPT.evaluate_permanent_evolution_gate(permanent_state, gates[next_result["next_tier"]])
	return {"ok": bool(gate.get("valid", false)), "eligible": bool(gate.get("eligible", false)), "error": str(gate.get("error", "")), "current_tier": next_result["current_tier"], "next_tier": next_result["next_tier"], "gate": gate, "requirement": gates[next_result["next_tier"]].duplicate(true), "key": next_result["key"]}


static func purchase_next_tier(permanent_state: Dictionary, recruit_id: String, profile: Dictionary) -> Dictionary:
	var evaluation := evaluate_next_tier(permanent_state, recruit_id, profile)
	if not bool(evaluation.get("ok", false)) or not bool(evaluation.get("eligible", false)):
		return {"ok": false, "evaluation": evaluation, "error": str(evaluation.get("error", "Evolution milestone or materials are not available."))}
	var inventory: Variant = permanent_state.get("evolution_materials", {})
	if typeof(inventory) != TYPE_DICTIONARY:
		return {"ok": false, "evaluation": evaluation, "error": "Permanent material inventory is malformed."}
	var consumed: Dictionary = RULES_SCRIPT.consume_evolution_materials(int(permanent_state.get("highest_wave_ever", 0)), inventory, evaluation["requirement"])
	if not bool(consumed.get("ok", false)):
		return {"ok": false, "evaluation": evaluation, "error": "Evolution milestone or materials are not available."}
	var updated := permanent_state.duplicate(true)
	updated["evolution_materials"] = consumed["inventory"]
	var evolution: Dictionary = updated.get("evolution", {}).duplicate(true)
	evolution[evaluation["key"]] = evaluation["next_tier"]
	updated["evolution"] = evolution
	return {"ok": true, "permanent": updated, "recruit_id": recruit_id, "previous_tier": evaluation["current_tier"], "unlocked_tier": evaluation["next_tier"], "evaluation": evaluation}


static func canonical_tier_label(value: Variant) -> String:
	var label := str(value)
	return str(LEGACY_TIER_LABELS.get(label, label))


static func _tier_key(recruit_id: String) -> Dictionary:
	var normalized := recruit_id.strip_edges().to_lower()
	if normalized != recruit_id or not APPROVED_RECRUIT_IDS.has(normalized):
		return {"ok": false, "error": "Unknown or non-canonical founding recruit ID."}
	# Preserve the established BREAKER save key for compatibility.
	return {"ok": true, "key": "%s_tier" % normalized}
