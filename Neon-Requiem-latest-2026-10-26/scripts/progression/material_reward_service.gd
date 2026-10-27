extends RefCounted
class_name PrototypeMaterialRewardService

const PROGRESSION_RULES := preload("res://scripts/progression/progression_rules.gd")


## Applies prototype material rewards to a copy of permanent state. District and
## boss first-clear bonuses are independently ledgered; repeatable clear rewards
## are granted every time the authoritative wave-clear event arrives.
static func apply_wave_clear(permanent_state: Dictionary, wave_number: int, boss_id: String, reward_rules: Dictionary) -> Dictionary:
	var material_id: Variant = reward_rules.get("material_id", null)
	var repeatable_amount: Variant = reward_rules.get("repeatable_per_clear", null)
	var first_clear_extra: Variant = reward_rules.get("first_clear_extra", null)
	var milestones: Variant = reward_rules.get("district_milestones", null)
	if not _is_canonical_id(material_id) or not _is_positive_integer(repeatable_amount) or not _is_positive_integer(first_clear_extra) or typeof(milestones) != TYPE_ARRAY:
		return {"ok": false, "error": "Material reward rules require a canonical material, positive quantities, and a district milestone list."}
	var eligible_claim_ids: Array[String] = []
	var seen_claim_ids: Dictionary = {}
	var seen_waves: Dictionary = {}
	for milestone_variant in milestones:
		if typeof(milestone_variant) != TYPE_DICTIONARY:
			return {"ok": false, "error": "District material milestones must be objects."}
		var milestone: Dictionary = milestone_variant
		var milestone_wave: Variant = milestone.get("wave", null)
		var claim_id: Variant = milestone.get("claim_id", null)
		if not _is_positive_integer(milestone_wave) or not _is_canonical_id(claim_id) or seen_claim_ids.has(claim_id) or seen_waves.has(milestone_wave):
			return {"ok": false, "error": "District material milestones require unique positive waves and canonical claim IDs."}
		seen_claim_ids[claim_id] = true
		seen_waves[milestone_wave] = true
		if int(milestone_wave) == wave_number:
			eligible_claim_ids.append(str(claim_id))
	if not boss_id.is_empty():
		if not _is_canonical_id(boss_id) or not boss_id.begins_with("boss.") or seen_claim_ids.has(boss_id):
			return {"ok": false, "error": "Named boss reward IDs must be unique canonical IDs beginning with 'boss.'."}
		eligible_claim_ids.append(boss_id)
	var repeatable_result: Dictionary = PROGRESSION_RULES.grant_repeatable_materials(permanent_state, {str(material_id): int(repeatable_amount)})
	if not bool(repeatable_result.get("ok", false)):
		return repeatable_result
	var updated_permanent: Dictionary = repeatable_result["permanent"]
	var claimed_ids: Array[String] = []
	var first_clear_amount := 0
	for claim_id in eligible_claim_ids:
		var first_clear_result: Dictionary = PROGRESSION_RULES.claim_first_clear_materials(updated_permanent, claim_id, {str(material_id): int(first_clear_extra)})
		if bool(first_clear_result.get("ok", false)):
			updated_permanent = first_clear_result["permanent"]
			claimed_ids.append(claim_id)
			first_clear_amount += int(first_clear_extra)
		elif not bool(first_clear_result.get("already_claimed", false)):
			return {"ok": false, "error": str(first_clear_result.get("error", "First-clear material reward failed."))}
	return {
		"ok": true,
		"permanent": updated_permanent,
		"material_id": str(material_id),
		"repeatable_amount": int(repeatable_amount),
		"first_clear_amount": first_clear_amount,
		"total_amount": int(repeatable_amount) + first_clear_amount,
		"claimed_ids": claimed_ids
	}


static func _is_canonical_id(value: Variant) -> bool:
	return typeof(value) == TYPE_STRING and not str(value).strip_edges().is_empty() and str(value).strip_edges() == str(value)


static func _is_positive_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return int(value) > 0
	return typeof(value) == TYPE_FLOAT and is_finite(float(value)) and float(value) > 0.0 and is_equal_approx(float(value), roundf(float(value)))
