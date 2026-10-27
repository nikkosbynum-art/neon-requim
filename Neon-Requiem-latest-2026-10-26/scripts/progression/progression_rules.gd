extends RefCounted
class_name PrototypeProgressionRules

## Data-driven primitives for the approved prestige/evolution rules.
## Balance values are supplied by callers; this class does not define canon.


static func calculate_reboot_influence(highest_cleared_wave: int, rule: Dictionary) -> int:
	var first_wave := int(rule.get("first_eligibility_wave", 25))
	var waves_per_step := int(rule.get("waves_per_influence_step", 25))
	var influence_per_step := int(rule.get("influence_per_step", 1))
	if first_wave < 1 or waves_per_step < 1 or influence_per_step < 1:
		return 0
	if highest_cleared_wave < first_wave:
		return 0
	var steps := 1 + int(floor(float(highest_cleared_wave - first_wave) / float(waves_per_step)))
	return steps * influence_per_step


static func apply_influence_award(permanent_state: Dictionary, award: int) -> Dictionary:
	if award <= 0:
		return {"ok": false, "error": "Influence award must be positive."}
	var lifetime_value: Variant = permanent_state.get("lifetime_influence", 0)
	var spendable_value: Variant = permanent_state.get("spendable_influence", lifetime_value)
	if not _is_nonnegative_integer(lifetime_value) or not _is_nonnegative_integer(spendable_value):
		return {"ok": false, "error": "Influence balances must be non-negative integers."}
	var updated := permanent_state.duplicate(true)
	updated["lifetime_influence"] = int(lifetime_value) + award
	updated["spendable_influence"] = int(spendable_value) + award
	return {"ok": true, "permanent": updated, "award": award}


static func calculate_lifetime_power_bonus(lifetime_influence: Variant, rule: Dictionary) -> Dictionary:
	if not _is_nonnegative_integer(lifetime_influence):
		return {"ok": false, "error": "Lifetime Influence must be a non-negative integer."}
	var coefficient: Variant = rule.get("coefficient", null)
	var exponent: Variant = rule.get("influence_exponent", null)
	var maximum_bonus: Variant = rule.get("maximum_bonus_fraction", null)
	if not _is_finite_number(coefficient) or float(coefficient) < 0.0:
		return {"ok": false, "error": "Lifetime bonus coefficient must be a non-negative finite number."}
	if not _is_finite_number(exponent) or float(exponent) <= 0.0:
		return {"ok": false, "error": "Lifetime bonus exponent must be a positive finite number."}
	if not _is_finite_number(maximum_bonus) or float(maximum_bonus) < 0.0:
		return {"ok": false, "error": "Lifetime bonus cap must be a non-negative finite number."}
	var raw_bonus := float(coefficient) * pow(float(lifetime_influence), float(exponent))
	return {"ok": true, "bonus_fraction": minf(raw_bonus, float(maximum_bonus))}


static func grant_repeatable_materials(permanent_state: Dictionary, rewards: Dictionary) -> Dictionary:
	if rewards.is_empty():
		return {"ok": false, "error": "Repeatable material rewards must not be empty."}
	var inventory_value: Variant = permanent_state.get("evolution_materials", {})
	if typeof(inventory_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Material inventory must be an object."}
	var updated_inventory: Dictionary = inventory_value.duplicate(true)
	for material_id in updated_inventory:
		if typeof(material_id) != TYPE_STRING or str(material_id).strip_edges().is_empty() or str(material_id).strip_edges() != str(material_id) or not _is_nonnegative_integer(updated_inventory[material_id]):
			return {"ok": false, "error": "Material inventory contains an invalid ID or quantity."}
	for material_id in rewards:
		var reward_count: Variant = rewards[material_id]
		if typeof(material_id) != TYPE_STRING or str(material_id).strip_edges().is_empty() or str(material_id).strip_edges() != str(material_id) or not _is_positive_integer(reward_count):
			return {"ok": false, "error": "Repeatable rewards require canonical material IDs and positive integer quantities."}
		updated_inventory[material_id] = int(updated_inventory.get(material_id, 0)) + int(reward_count)
	var updated_permanent := permanent_state.duplicate(true)
	updated_permanent["evolution_materials"] = updated_inventory
	return {"ok": true, "permanent": updated_permanent, "inventory": updated_inventory, "rewards": rewards.duplicate(true)}


static func claim_first_clear_materials(permanent_state: Dictionary, claim_id: String, rewards: Dictionary) -> Dictionary:
	var normalized_claim_id := claim_id.strip_edges()
	if normalized_claim_id.is_empty() or normalized_claim_id != claim_id or rewards.is_empty():
		return {"ok": false, "error": "First-clear claim ID and material rewards are required."}
	var claims_value: Variant = permanent_state.get("first_clear_material_claims", [])
	var inventory_value: Variant = permanent_state.get("evolution_materials", {})
	if typeof(claims_value) != TYPE_ARRAY or typeof(inventory_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "First-clear ledger or material inventory is malformed."}
	var claims: Array = claims_value.duplicate(true)
	var seen_claims: Dictionary = {}
	for existing_claim in claims:
		if typeof(existing_claim) != TYPE_STRING or str(existing_claim).strip_edges().is_empty() or str(existing_claim).strip_edges() != str(existing_claim) or seen_claims.has(existing_claim):
			return {"ok": false, "error": "First-clear ledger must contain unique non-empty string IDs."}
		seen_claims[existing_claim] = true
	if seen_claims.has(normalized_claim_id):
		return {"ok": false, "already_claimed": true, "error": "First-clear reward was already claimed."}
	var updated_inventory: Dictionary = inventory_value.duplicate(true)
	for material_id in updated_inventory:
		if typeof(material_id) != TYPE_STRING or str(material_id).strip_edges().is_empty() or str(material_id).strip_edges() != str(material_id) or not _is_nonnegative_integer(updated_inventory[material_id]):
			return {"ok": false, "error": "Material inventory contains an invalid ID or quantity."}
	for material_id in rewards:
		var reward_count: Variant = rewards[material_id]
		if typeof(material_id) != TYPE_STRING or str(material_id).strip_edges().is_empty() or str(material_id).strip_edges() != str(material_id) or not _is_positive_integer(reward_count):
			return {"ok": false, "error": "First-clear material rewards must use non-empty IDs and positive integer quantities."}
		updated_inventory[material_id] = int(updated_inventory.get(material_id, 0)) + int(reward_count)
	claims.append(normalized_claim_id)
	var updated_permanent := permanent_state.duplicate(true)
	updated_permanent["first_clear_material_claims"] = claims
	updated_permanent["evolution_materials"] = updated_inventory
	return {"ok": true, "permanent": updated_permanent, "claim_id": normalized_claim_id}


static func evaluate_evolution_gate(highest_cleared_wave: int, inventory: Dictionary, requirement: Dictionary) -> Dictionary:
	var required_wave_value: Variant = requirement.get("minimum_cleared_wave", null)
	var costs_value: Variant = requirement.get("material_costs", null)
	if not _is_positive_integer(required_wave_value) or typeof(costs_value) != TYPE_DICTIONARY or costs_value.is_empty():
		return {"valid": false, "eligible": false, "error": "Evolution gate requires a positive wave milestone and material costs."}
	var missing: Dictionary = {}
	for material_id in costs_value:
		var cost: Variant = costs_value[material_id]
		var available: Variant = inventory.get(material_id, 0)
		if typeof(material_id) != TYPE_STRING or str(material_id).strip_edges().is_empty() or str(material_id).strip_edges() != str(material_id) or not _is_positive_integer(cost) or not _is_nonnegative_integer(available):
			return {"valid": false, "eligible": false, "error": "Evolution material costs and inventory must be non-negative integers, with positive costs."}
		if int(available) < int(cost):
			missing[material_id] = int(cost) - int(available)
	var milestone_met := highest_cleared_wave >= int(required_wave_value)
	return {
		"valid": true,
		"eligible": milestone_met and missing.is_empty(),
		"milestone_met": milestone_met,
		"missing_materials": missing,
		"required_wave": int(required_wave_value)
	}


static func evaluate_permanent_evolution_gate(permanent_state: Dictionary, requirement: Dictionary) -> Dictionary:
	var highest_ever: Variant = permanent_state.get("highest_wave_ever", 0)
	var inventory: Variant = permanent_state.get("evolution_materials", {})
	if not _is_nonnegative_integer(highest_ever) or typeof(inventory) != TYPE_DICTIONARY:
		return {"valid": false, "eligible": false, "error": "Permanent evolution milestone or material state is malformed."}
	return evaluate_evolution_gate(int(highest_ever), inventory, requirement)


static func consume_evolution_materials(highest_cleared_wave: int, inventory: Dictionary, requirement: Dictionary) -> Dictionary:
	var gate := evaluate_evolution_gate(highest_cleared_wave, inventory, requirement)
	if not bool(gate.get("valid", false)) or not bool(gate.get("eligible", false)):
		return {"ok": false, "gate": gate, "inventory": inventory.duplicate(true)}
	var updated := inventory.duplicate(true)
	var costs: Dictionary = requirement["material_costs"]
	for material_id in costs:
		updated[material_id] = int(updated.get(material_id, 0)) - int(costs[material_id])
	return {"ok": true, "gate": gate, "inventory": updated}


static func _is_nonnegative_integer(value: Variant) -> bool:
	return _is_integer_number(value) and float(value) >= 0.0


static func _is_positive_integer(value: Variant) -> bool:
	return _is_integer_number(value) and float(value) > 0.0


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) != TYPE_FLOAT or not is_finite(float(value)):
		return false
	return is_equal_approx(float(value), roundf(float(value)))


static func _is_finite_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))
