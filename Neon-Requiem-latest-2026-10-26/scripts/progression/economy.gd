extends RefCounted
class_name PrototypeEconomy

## Minimal run-economy model. All formulas are configurable prototype placeholders.

var credits := 0
var recruit_level := 1


func grant_encounter_reward(wave: int, wave_definition: Dictionary) -> int:
	var reward := calculate_encounter_reward(wave, wave_definition)
	credits += reward
	return reward


static func calculate_encounter_reward(wave: int, wave_definition: Dictionary) -> int:
	var safe_wave := maxi(1, wave)
	return maxi(0, int(wave_definition.get("base_credit_reward", 12)) + (safe_wave - 1) * int(wave_definition.get("credit_reward_per_wave", 4)))


func upgrade_cost(player_definition: Dictionary, current_level: int = -1) -> int:
	var level := recruit_level if current_level < 0 else current_level
	var base := float(player_definition.get("upgrade_cost_base", 20))
	var growth := float(player_definition.get("upgrade_cost_growth", 1.12))
	return maxi(1, roundi(base * pow(growth, maxf(0.0, float(level - 1)))))


func purchase_levels(player_definition: Dictionary, bulk_count: int) -> int:
	var transaction := preview_purchase_levels(player_definition, bulk_count)
	credits = int(transaction["credits"])
	recruit_level = int(transaction["recruit_level"])
	return int(transaction["bought"])


func preview_purchase_levels(player_definition: Dictionary, bulk_count: int) -> Dictionary:
	var candidate_credits := credits
	var candidate_level := recruit_level
	var bought := 0
	for _i in range(maxi(1, bulk_count)):
		var next_cost := upgrade_cost(player_definition, candidate_level)
		if candidate_credits < next_cost:
			break
		candidate_credits -= next_cost
		candidate_level += 1
		bought += 1
	return {"bought": bought, "credits": candidate_credits, "recruit_level": candidate_level}


func load_run_state(saved: Dictionary) -> void:
	credits = maxi(0, int(saved.get("credits", 0)))
	recruit_level = maxi(1, int(saved.get("recruit_level", 1)))


func make_save_data(wave: int, highest_cleared_wave: int, squad_hp: Array = [], recruit_states: Dictionary = {}, ally_ids: Array = []) -> Dictionary:
	var run_data := {
		"credits": credits,
		"wave": wave,
		"highest_cleared_wave": highest_cleared_wave,
		"recruits": recruit_states.duplicate(true)
	}
	var recruits: Dictionary = run_data["recruits"]
	var breaker_value: Variant = recruits.get("breaker", {})
	if typeof(breaker_value) != TYPE_DICTIONARY:
		breaker_value = {}
	var breaker: Dictionary = breaker_value.duplicate(true)
	breaker["level"] = recruit_level
	if not ally_ids.is_empty():
		for index in range(mini(ally_ids.size(), squad_hp.size())):
			var recruit_id := str(ally_ids[index])
			if recruit_id not in ["bulwark", "breaker", "cipher", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]:
				continue
			var recruit_value: Variant = recruits.get(recruit_id, {"level": 1})
			var recruit_state: Dictionary = recruit_value.duplicate(true) if typeof(recruit_value) == TYPE_DICTIONARY else {"level": 1}
			recruit_state["hp"] = squad_hp[index]
			recruits[recruit_id] = recruit_state
	elif not squad_hp.is_empty():
		if squad_hp.size() == 6:
			# Compatibility bridge while the old placeholder squad is active:
			# slot zero is the configured BREAKER actor; other slots remain legacy.
			breaker["hp"] = squad_hp[0]
			var legacy_placeholder_hp: Array = []
			for index in range(1, squad_hp.size()):
				legacy_placeholder_hp.append(squad_hp[index])
			run_data["legacy_placeholder_squad_hp"] = legacy_placeholder_hp
		else:
			run_data["squad_hp"] = squad_hp.duplicate(true)
	recruits["breaker"] = breaker
	run_data["recruits"] = recruits
	return run_data
