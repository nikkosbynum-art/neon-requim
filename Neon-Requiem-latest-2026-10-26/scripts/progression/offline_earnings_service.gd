extends RefCounted
class_name PrototypeOfflineEarningsService

## Applies a capped offline credit claim to a copied run payload. It never
## advances the wave or simulates encounters; callers persist the result before
## applying it to live state.
const ECONOMY_SCRIPT := preload("res://scripts/progression/economy.gd")
const APPROVED_MAX_CAP_SECONDS := 8 * 60 * 60


static func apply_claim(saved_run: Dictionary, wave_definition: Dictionary, rules: Dictionary, now_unix: int) -> Dictionary:
	if now_unix <= 0:
		return {"ok": false, "error": "Current Unix time is invalid."}
	if not saved_run.has("credits") or not _is_nonnegative_integer(saved_run["credits"]):
		return {"ok": false, "error": "Saved run credits are invalid."}
	if not saved_run.has("highest_cleared_wave") or not _is_nonnegative_integer(saved_run["highest_cleared_wave"]):
		return {"ok": false, "error": "Saved holding-wave record is invalid."}
	var cap_value: Variant = rules.get("cap_seconds", null)
	var rewards_per_hour_value: Variant = rules.get("ordinary_rewards_per_hour", null)
	if not _is_positive_integer(cap_value) or int(cap_value) > APPROVED_MAX_CAP_SECONDS:
		return {"ok": false, "error": "Offline credit cap must be within the approved eight-hour limit."}
	if (typeof(rewards_per_hour_value) != TYPE_INT and typeof(rewards_per_hour_value) != TYPE_FLOAT) or not is_finite(float(rewards_per_hour_value)) or float(rewards_per_hour_value) < 0.0 or float(rewards_per_hour_value) > 10.0:
		return {"ok": false, "error": "Offline reward rate must be a finite configurable value from 0 to 10 ordinary rewards per hour."}

	var updated_run := saved_run.duplicate(true)
	if not saved_run.has("offline_claim_unix"):
		updated_run["offline_claim_unix"] = now_unix
		return {"ok": true, "status": "baseline_created", "should_save": true, "credits_awarded": 0, "holding_wave": maxi(1, int(saved_run["highest_cleared_wave"])), "elapsed_seconds": 0, "run": updated_run}
	if not _is_nonnegative_integer(saved_run["offline_claim_unix"]):
		return {"ok": false, "error": "Saved offline-claim timestamp is invalid."}

	var previous_time := int(saved_run["offline_claim_unix"])
	if previous_time > now_unix:
		updated_run["offline_claim_unix"] = now_unix
		return {"ok": true, "status": "clock_reset", "should_save": true, "credits_awarded": 0, "holding_wave": maxi(1, int(saved_run["highest_cleared_wave"])), "elapsed_seconds": 0, "run": updated_run}
	var elapsed_seconds := now_unix - previous_time
	var holding_wave := maxi(1, int(saved_run["highest_cleared_wave"]))
	var capped_seconds := mini(elapsed_seconds, int(cap_value))
	var ordinary_reward := ECONOMY_SCRIPT.calculate_encounter_reward(holding_wave, wave_definition)
	var hourly_rate := float(rewards_per_hour_value)
	var credit_amount := floori(float(ordinary_reward) * hourly_rate * float(capped_seconds) / 3600.0)
	if credit_amount <= 0:
		return {"ok": true, "status": "no_reward", "should_save": false, "credits_awarded": 0, "holding_wave": holding_wave, "elapsed_seconds": elapsed_seconds, "run": updated_run}

	updated_run["credits"] = int(saved_run["credits"]) + credit_amount
	updated_run["offline_claim_unix"] = now_unix
	return {"ok": true, "status": "claimed", "should_save": true, "credits_awarded": credit_amount, "holding_wave": holding_wave, "elapsed_seconds": elapsed_seconds, "capped_seconds": capped_seconds, "run": updated_run}


static func _is_nonnegative_integer(value: Variant) -> bool:
	return _is_integer_value(value) and int(value) >= 0


static func _is_positive_integer(value: Variant) -> bool:
	return _is_integer_value(value) and int(value) > 0


static func _is_integer_value(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) != TYPE_FLOAT or not is_finite(float(value)):
		return false
	return float(value) == floor(float(value))
