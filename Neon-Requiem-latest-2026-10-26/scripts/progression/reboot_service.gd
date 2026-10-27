extends RefCounted
class_name PrototypeRebootService

const PROGRESSION_RULES := preload("res://scripts/progression/progression_rules.gd")
const SAVE_SERVICE := preload("res://scripts/persistence/save_service.gd")
const ROSTER_STATE_SERVICE := preload("res://scripts/progression/roster_state_service.gd")

## Applies a manual Reboot as a pure state transaction.
## The caller supplies the award profile and full-HP values; no balance is hard-coded.


static func apply_reboot(permanent_state: Dictionary, run_state: Dictionary, rule_profile: Dictionary, full_squad_hp: Array = [], max_hp_by_recruit: Dictionary = {}) -> Dictionary:
	var reboot_rules: Variant = rule_profile.get("system_reboot", null)
	if typeof(reboot_rules) != TYPE_DICTIONARY:
		return {"ok": false, "error": "System Reboot rules are missing."}
	if not _run_state_is_valid(run_state):
		return {"ok": false, "error": "Run state cannot be safely reset."}
	var eligibility_wave := int(reboot_rules.get("first_eligibility_wave", 0))
	var highest_wave := int(run_state.get("highest_cleared_wave", -1))
	if eligibility_wave < 1:
		return {"ok": false, "error": "System Reboot eligibility wave is invalid."}
	if highest_wave < eligibility_wave:
		return {"ok": false, "error": "System Reboot is not yet eligible."}
	if run_state.has("squad_hp"):
		var squad_hp: Variant = run_state["squad_hp"]
		if typeof(squad_hp) != TYPE_ARRAY or not _full_hp_is_valid(full_squad_hp, squad_hp.size()):
			return {"ok": false, "error": "Full squad health is required to reset a saved squad."}
	var award := PROGRESSION_RULES.calculate_reboot_influence(highest_wave, reboot_rules)
	var permanent_result: Dictionary = PROGRESSION_RULES.apply_influence_award(permanent_state, award)
	if not bool(permanent_result.get("ok", false)):
		return {"ok": false, "error": str(permanent_result.get("error", "Influence award failed."))}
	var permanent_update: Dictionary = permanent_result["permanent"]
	var previous_highest_ever: Variant = permanent_update.get("highest_wave_ever", 0)
	if not _is_integer_number(previous_highest_ever) or int(previous_highest_ever) < 0:
		return {"ok": false, "error": "Permanent highest-wave milestone state is invalid."}
	permanent_update["highest_wave_ever"] = maxi(int(previous_highest_ever), highest_wave)
	var reset_run := run_state.duplicate(true)
	reset_run["credits"] = 0
	reset_run["wave"] = 1
	reset_run["highest_cleared_wave"] = 0
	var recruits: Dictionary = reset_run.get("recruits", {})
	for recruit_id in recruits:
		var recruit_state: Dictionary = recruits[recruit_id]
		if recruit_state.has("level"):
			recruit_state["level"] = 1
	var owned_value: Variant = permanent_update.get("unlocks", [])
	var has_identity_state := not max_hp_by_recruit.is_empty() or reset_run.has("active_lineup") or _run_has_recruit_hp(reset_run)
	if has_identity_state:
		if typeof(owned_value) != TYPE_ARRAY or max_hp_by_recruit.is_empty():
			return {"ok": false, "error": "Full HP values are required for every owned recruit before Reboot."}
		var healed_result: Dictionary = ROSTER_STATE_SERVICE.heal_owned_recruits(reset_run, owned_value, max_hp_by_recruit)
		if not bool(healed_result.get("ok", false)):
			return {"ok": false, "error": str(healed_result.get("error", "Owned recruit healing failed."))}
		reset_run = healed_result["run"]
		reset_run.erase("squad_hp")
	elif reset_run.has("squad_hp"):
		reset_run["squad_hp"] = full_squad_hp.duplicate(true)
	return {
		"ok": true,
		"award": award,
		"permanent": permanent_update,
		"run": reset_run
	}


## Loads the latest persisted game state, applies Reboot, then commits both sections
## through SaveService's staged/verified transaction. An explicit path is required.
static func reboot_saved_game(path: String, rule_profile: Dictionary, full_squad_hp: Array, max_hp_by_recruit: Dictionary = {}) -> Dictionary:
	return _reboot_saved_game_with_file_ops(path, rule_profile, full_squad_hp, SAVE_SERVICE._DiskFileOps.new(), max_hp_by_recruit)


static func _reboot_saved_game_with_file_ops(path: String, rule_profile: Dictionary, full_squad_hp: Array, file_ops: Object, max_hp_by_recruit: Dictionary = {}) -> Dictionary:
	var load_result: Dictionary = SAVE_SERVICE._load_game_with_file_ops(path, file_ops)
	if not bool(load_result.get("ok", false)):
		return {"ok": false, "error": "Unable to load a valid save before Reboot.", "details": load_result.get("error", "")}
	var save_data: Dictionary = load_result["data"]
	var transaction := apply_reboot(save_data["permanent"], save_data["run"], rule_profile, full_squad_hp, max_hp_by_recruit)
	if not bool(transaction.get("ok", false)):
		return transaction
	var save_error: Error = SAVE_SERVICE._save_game_with_file_ops(transaction["permanent"], transaction["run"], save_data["settings"], path, file_ops)
	if save_error != OK:
		return {"ok": false, "error": "Reboot could not be committed; the previous save remains authoritative.", "save_error": save_error}
	transaction["settings"] = save_data["settings"].duplicate(true)
	return transaction


static func _run_state_is_valid(run_state: Dictionary) -> bool:
	for field in ["credits", "wave", "highest_cleared_wave"]:
		if not run_state.has(field) or not _is_integer_number(run_state[field]):
			return false
	if int(run_state["credits"]) < 0 or int(run_state["wave"]) < 1 or int(run_state["highest_cleared_wave"]) < 0:
		return false
	var recruits: Variant = run_state.get("recruits", null)
	if typeof(recruits) != TYPE_DICTIONARY:
		return false
	for recruit_id in recruits:
		if typeof(recruits[recruit_id]) != TYPE_DICTIONARY:
			return false
		var recruit_state: Dictionary = recruits[recruit_id]
		if recruit_state.has("level") and (not _is_integer_number(recruit_state["level"]) or int(recruit_state["level"]) < 1):
			return false
		if recruit_state.has("hp") and (not _is_number(recruit_state["hp"]) or float(recruit_state["hp"]) < 0.0):
			return false
	if run_state.has("squad_hp"):
		if typeof(run_state["squad_hp"]) != TYPE_ARRAY or run_state["squad_hp"].is_empty():
			return false
		for hp in run_state["squad_hp"]:
			if not _is_number(hp) or float(hp) < 0.0:
				return false
	return true


static func _run_has_recruit_hp(run_state: Dictionary) -> bool:
	var recruits: Variant = run_state.get("recruits", null)
	if typeof(recruits) != TYPE_DICTIONARY:
		return false
	for recruit_value in recruits.values():
		if typeof(recruit_value) == TYPE_DICTIONARY and recruit_value.has("hp"):
			return true
	return false


static func _full_hp_is_valid(full_hp: Array, expected_size: int) -> bool:
	if expected_size <= 0 or full_hp.size() != expected_size:
		return false
	for hp in full_hp:
		if not _is_number(hp) or float(hp) < 0.0:
			return false
	return true


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	return typeof(value) == TYPE_FLOAT and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value)))


static func _is_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))
