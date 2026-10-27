extends RefCounted
class_name PrototypeRecruitmentService

const EXPECTED_RECRUIT_IDS := [
	"bulwark", "breaker", "cipher", "spark", "specter", "ironclad",
	"stitch", "recoil", "echo", "vector", "deadlock", "glitch"
]


static func validate_configuration(roster: Dictionary, profile: Dictionary) -> Dictionary:
	var recruits_value: Variant = roster.get("recruits", null)
	if typeof(recruits_value) != TYPE_ARRAY:
		return {"ok": false, "error": "Founding recruit catalog must contain a recruit list."}
	if not bool(profile.get("all_founding_recruits_available_from_start", false)):
		return {"ok": false, "error": "Founding recruit availability policy is invalid."}
	if not _is_nonnegative_integer(profile.get("starting_credits", null)):
		return {"ok": false, "error": "Starting credits must be a non-negative integer."}
	if str(profile.get("duplicate_policy", "")) != "one_copy_each_founding_recruit":
		return {"ok": false, "error": "Founding recruit duplicate policy is invalid."}
	var price_value: Variant = profile.get("price_by_rarity", null)
	if typeof(price_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Recruitment prices are missing."}
	for rarity in ["Common", "Rare", "Epic"]:
		if not _is_positive_integer(price_value.get(rarity, null)):
			return {"ok": false, "error": "Recruitment price is invalid for %s." % rarity}

	var seen: Dictionary = {}
	for recruit_value in recruits_value:
		if typeof(recruit_value) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Recruit catalog entries must be objects."}
		var recruit: Dictionary = recruit_value
		var recruit_id := str(recruit.get("id", ""))
		if recruit_id.is_empty() or seen.has(recruit_id):
			return {"ok": false, "error": "Recruit IDs must be unique and non-empty."}
		if not _is_canonical_id(recruit_id):
			return {"ok": false, "error": "Recruit ID is not canonical: %s." % recruit_id}
		for field in ["name", "faction", "roles"]:
			if str(recruit.get(field, "")).strip_edges().is_empty():
				return {"ok": false, "error": "Recruit %s is missing %s." % [recruit_id, field]}
		var rarity := str(recruit.get("rarity", ""))
		if not price_value.has(rarity):
			return {"ok": false, "error": "Recruit %s has an unsupported rarity." % recruit_id}
		seen[recruit_id] = true
	if seen.size() != EXPECTED_RECRUIT_IDS.size():
		return {"ok": false, "error": "Founding recruit catalog must contain exactly twelve approved recruits."}
	for expected_id in EXPECTED_RECRUIT_IDS:
		if not seen.has(expected_id):
			return {"ok": false, "error": "Founding recruit catalog is missing %s." % expected_id}
	var starter_value: Variant = profile.get("starting_owned_recruits", null)
	if typeof(starter_value) != TYPE_ARRAY:
		return {"ok": false, "error": "Starting owned recruit list must be an array."}
	var starter_seen: Dictionary = {}
	for starter_id_value in starter_value:
		var starter_id := str(starter_id_value)
		if not seen.has(starter_id) or starter_seen.has(starter_id):
			return {"ok": false, "error": "Starting owned recruit list contains an unknown or duplicate ID."}
		starter_seen[starter_id] = true
	if starter_seen.size() != 3 or not starter_seen.has("vector") or not starter_seen.has("spark") or not starter_seen.has("recoil"):
		return {"ok": false, "error": "Approved playtest starters must be VECTOR, SPARK, and RECOIL."}
	return {"ok": true}


static func initial_owned_recruits(profile: Dictionary) -> Array[String]:
	var owned: Array[String] = []
	for recruit_id_value in profile.get("starting_owned_recruits", []):
		var recruit_id := str(recruit_id_value)
		if not owned.has(recruit_id):
			owned.append(recruit_id)
	return owned


## Add the approved playtest starter trio while preserving existing permanent unlocks.
## Safe for legacy saves: it grants no credits and is idempotent.
static func ensure_starting_recruits(permanent: Dictionary, profile: Dictionary) -> Dictionary:
	var result := permanent.duplicate(true)
	var existing_value: Variant = result.get("unlocks", [])
	if typeof(existing_value) != TYPE_ARRAY:
		return result
	var unlocks: Array = existing_value.duplicate(true)
	for recruit_id in initial_owned_recruits(profile):
		if not unlocks.has(recruit_id):
			unlocks.append(recruit_id)
	result["unlocks"] = unlocks
	return result


static func evaluate_recruitment(permanent: Dictionary, run: Dictionary, roster: Dictionary, profile: Dictionary, recruit_id: String) -> Dictionary:
	var validation: Dictionary = validate_configuration(roster, profile)
	if not bool(validation.get("ok", false)):
		return validation
	if permanent.has("unlocks") and typeof(permanent["unlocks"]) != TYPE_ARRAY:
		return {"ok": false, "error": "Permanent recruit unlocks are invalid."}
	var recruit := _find_recruit(roster, recruit_id)
	if recruit.is_empty():
		return {"ok": false, "error": "Recruit is not in the approved founding roster."}
	var cost := int(profile["price_by_rarity"][str(recruit["rarity"])])
	var prepared_permanent := ensure_starting_recruits(permanent, profile)
	var unlocks_value: Variant = prepared_permanent.get("unlocks", [])
	if typeof(unlocks_value) != TYPE_ARRAY:
		return {"ok": false, "error": "Permanent recruit unlocks are invalid."}
	var owned: bool = unlocks_value.has(recruit_id)
	var credits_value: Variant = run.get("credits", null)
	if not _is_nonnegative_integer(credits_value):
		return {"ok": false, "error": "Run credits must be a non-negative integer."}
	return {
		"ok": true,
		"recruit": recruit.duplicate(true),
		"cost": cost,
		"owned": owned,
		"affordable": not owned and int(credits_value) >= cost
	}


static func purchase_recruit(permanent: Dictionary, run: Dictionary, roster: Dictionary, profile: Dictionary, recruit_id: String) -> Dictionary:
	var evaluation: Dictionary = evaluate_recruitment(permanent, run, roster, profile, recruit_id)
	if not bool(evaluation.get("ok", false)):
		return evaluation
	if bool(evaluation["owned"]):
		return {"ok": false, "error": "%s is already recruited." % str(evaluation["recruit"]["name"])}
	if not bool(evaluation["affordable"]):
		return {"ok": false, "error": "Not enough credits to recruit %s." % str(evaluation["recruit"]["name"])}
	var candidate_permanent := ensure_starting_recruits(permanent, profile)
	var candidate_run := run.duplicate(true)
	var unlocks: Array = candidate_permanent.get("unlocks", []).duplicate(true)
	if not unlocks.has(recruit_id):
		unlocks.append(recruit_id)
	candidate_permanent["unlocks"] = unlocks
	candidate_run["credits"] = int(candidate_run["credits"]) - int(evaluation["cost"])
	return {
		"ok": true,
		"permanent": candidate_permanent,
		"run": candidate_run,
		"recruit_id": recruit_id,
		"credits_spent": int(evaluation["cost"])
	}


static func _find_recruit(roster: Dictionary, recruit_id: String) -> Dictionary:
	for recruit_value in roster.get("recruits", []):
		if typeof(recruit_value) == TYPE_DICTIONARY and str(recruit_value.get("id", "")) == recruit_id:
			return recruit_value
	return {}


static func _is_canonical_id(value: String) -> bool:
	if value.is_empty() or value.strip_edges() != value or value.to_lower() != value:
		return false
	for character in value:
		if not (character >= "a" and character <= "z") and not (character >= "0" and character <= "9") and character != "_":
			return false
	return true


static func _is_nonnegative_integer(value: Variant) -> bool:
	return _is_integer(value) and int(value) >= 0


static func _is_positive_integer(value: Variant) -> bool:
	return _is_integer(value) and int(value) > 0


static func _is_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	return typeof(value) == TYPE_FLOAT and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value)))
