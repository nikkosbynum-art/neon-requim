extends SceneTree

const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")
const EVOLUTION_SERVICE := preload("res://scripts/progression/evolution_service.gd")
const PROFILE_PATH := "res://data/progression/progression_prototype_profile.json"
const STARTING_PERMANENT := {"lifetime_influence": 17, "spendable_influence": 5, "highest_wave_ever": 125, "research": {"combat": 2}, "evolution_materials": {"evolution_data": 6}, "first_clear_material_claims": ["district.undercity"], "evolution": {"breaker_tier": "Origin Form"}, "unlocks": ["breaker"]}
const RUN_PAYLOAD := {
	"run": {"credits": 321, "wave": 125, "highest_cleared_wave": 124, "recruits": {"breaker": {"level": 5}}, "squad_hp": [120.0, 91.0, 83.0, 74.0, 65.0, 56.0]},
	"settings": {"master_volume": 0.45, "window_mode": "windowed"}
}

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 2 or not arguments[0] in ["write", "read"]:
		_fail("Usage: -- write|read <unique-id>")
		quit(2)
		return
	var probe_id := _safe_id(arguments[1])
	if failures > 0:
		quit(2)
		return
	var path := "res://tests/_restart_probe_%s.json" % probe_id
	var expected_permanent := _apply_approved_test_evolutions()
	if expected_permanent.is_empty():
		quit(1)
		return
	if arguments[0] == "write":
		if FileAccess.file_exists(path):
			_fail("Refusing to overwrite an existing disposable probe file: %s" % path)
			quit(2)
			return
		var result: Error = SAVE_SCRIPT.save_game(expected_permanent, RUN_PAYLOAD["run"], RUN_PAYLOAD["settings"], path)
		if result != OK:
			_fail("Save process could not write the probe payload (error %d)." % result)
			_cleanup(path)
		else:
			print("Separate-process evolution probe wrote BREAKER's three-tier purchase result.")
	else:
		var loaded: Dictionary = SAVE_SCRIPT.load_game(path)
		if not bool(loaded.get("ok", false)):
			_fail("Fresh process could not load the probe payload: %s" % str(loaded.get("error", "unknown error")))
		elif not SAVE_SCRIPT._values_match(loaded.get("data", {}), {"save_version": SAVE_SCRIPT.SAVE_VERSION, "permanent": expected_permanent, "run": RUN_PAYLOAD["run"], "settings": RUN_PAYLOAD["settings"]}):
			_fail("Fresh process restored data that differs from the saved payload.")
		else:
			print("Fresh process restored Requiem Form, zero remaining Evolution Data, permanent records, run, HP, and settings.")
		_cleanup(path)
	quit(1 if failures > 0 else 0)


func _apply_approved_test_evolutions() -> Dictionary:
	var profile_file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if profile_file == null:
		_fail("Could not read the prototype progression profile.")
		return {}
	var profile_parser := JSON.new()
	var parse_error := profile_parser.parse(profile_file.get_as_text())
	profile_file.close()
	if parse_error != OK or typeof(profile_parser.data) != TYPE_DICTIONARY:
		_fail("The prototype progression profile is invalid JSON.")
		return {}
	var permanent: Dictionary = STARTING_PERMANENT.duplicate(true)
	for expected_tier in ["Adapted Form", "Signature Form", "Requiem Form"]:
		var purchase: Dictionary = EVOLUTION_SERVICE.purchase_next_tier(permanent, "breaker", profile_parser.data)
		if not bool(purchase.get("ok", false)) or purchase.get("unlocked_tier", "") != expected_tier:
			_fail("Expected the test purchase sequence to unlock %s: %s" % [expected_tier, str(purchase.get("error", "unexpected tier"))])
			return {}
		permanent = purchase["permanent"]
	if permanent.get("evolution", {}).get("breaker_tier", "") != "Requiem Form" or permanent.get("evolution_materials", {}).get("evolution_data", -1) != 0:
		_fail("The test sequence did not record Requiem Form and deduct exactly six Evolution Data.")
		return {}
	return permanent


func _safe_id(value: String) -> String:
	var safe := ""
	for character in value:
		if character.is_valid_identifier() or (character.length() == 1 and character >= "0" and character <= "9"):
			safe += character
		else:
			_fail("Probe ID may contain only letters, digits, and underscores.")
			return "invalid"
	if safe.is_empty():
		_fail("Probe ID must not be empty.")
	return safe


func _cleanup(path: String) -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var absolute_path := ProjectSettings.globalize_path(path + suffix)
		if FileAccess.file_exists(absolute_path):
			var error: Error = DirAccess.remove_absolute(absolute_path)
			if error != OK:
				_fail("Could not clean disposable save probe file %s (error %d)." % [absolute_path, error])


func _fail(message: String) -> void:
	failures += 1
	push_error("SAVE PROCESS PROBE FAILED: " + message)
