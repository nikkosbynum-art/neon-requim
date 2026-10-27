extends SceneTree

## Three-process probe for an offline claim: seed -> live Main load/claim ->
## fresh Main reload. Uses a unique disposable save and never opens user data.
const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const EXPECTED_CREDITS := 158
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 2 or not arguments[0] in ["write", "claim", "verify"]:
		_fail("Usage: -- write|claim|verify <unique-id>")
		quit(2)
		return
	var probe_id := _safe_id(arguments[1])
	if failures > 0:
		quit(2)
		return
	var path := ProjectSettings.globalize_path("res://tests/_offline_restart_%s.json" % probe_id)
	match arguments[0]:
		"write":
			_write_seed(path)
		"claim":
			await _claim_in_live_main(path)
		"verify":
			await _verify_fresh_main(path)
	quit(1 if failures > 0 else 0)


func _write_seed(path: String) -> void:
	if FileAccess.file_exists(path):
		_fail("Refusing to overwrite an existing disposable offline probe save: %s" % path)
		return
	var now_unix := int(Time.get_unix_time_from_system())
	var permanent := {"lifetime_influence": 3, "highest_wave_ever": 25, "research": {"combat": 1}, "evolution_materials": {"evolution_data": 2}, "first_clear_material_claims": ["district.undercity"], "evolution": {"breaker_tier": "Origin Form"}, "unlocks": ["breaker"]}
	var run := {"credits": 50, "wave": 40, "highest_cleared_wave": 25, "recruits": {"breaker": {"level": 4}}, "squad_hp": [120.0, 91.0, 83.0, 74.0, 65.0, 56.0], "offline_claim_unix": now_unix - 3600}
	var settings := {"master_volume": 0.45, "window_mode": "windowed"}
	var error_code: Error = SAVE_SCRIPT.save_game(permanent, run, settings, path)
	if error_code != OK:
		_fail("Could not write offline probe seed (error %d)." % error_code)
		_cleanup(path)
		return
	print("Offline process probe wrote a disposable holding-wave save with one hour of elapsed time.")


func _claim_in_live_main(path: String) -> void:
	var main: Variant = await _new_main(path)
	if main == null:
		return
	main._load()
	_check(main.director.economy.credits == EXPECTED_CREDITS, "Live load process should grant one ordinary wave-25 reward (+108 credits).")
	_check(main.director.wave == 40 and main.director.highest_cleared_wave == 25, "Live load process must preserve wave and holding-wave state.")
	_check(main.director.economy.recruit_level == 4 and int(main.permanent_state.get("lifetime_influence", 0)) == 3, "Live load process must preserve recruit and permanent progression.")
	_check(main.feedback_label.text.contains("+108 offline credits") and main.feedback_label.text.contains("no waves advanced"), "Live load process should report the claim and no wave advancement.")
	var committed: Dictionary = SAVE_SCRIPT.load_game(path)
	_check(bool(committed.get("ok", false)), "Claim process must leave a valid committed save.")
	if bool(committed.get("ok", false)):
		_check(int(committed["data"]["run"]["credits"]) == EXPECTED_CREDITS, "Claim process must persist awarded credits before completion.")
		_check(int(committed["data"]["run"]["offline_claim_unix"]) >= int(Time.get_unix_time_from_system()), "Claim process must persist its timestamp before completion.")
	main.queue_free()
	await process_frame
	print("Offline process probe live Main load committed the claim without advancing the run.")


func _verify_fresh_main(path: String) -> void:
	var main: Variant = await _new_main(path)
	if main == null:
		_cleanup(path)
		return
	main._load()
	_check(main.director.economy.credits == EXPECTED_CREDITS, "Fresh process must not duplicate the already-committed claim.")
	_check(main.director.wave == 40 and main.director.highest_cleared_wave == 25, "Fresh process must restore the unchanged wave values.")
	_check(not main.feedback_label.text.contains("+108 offline credits"), "Fresh process feedback must not repeat the prior offline claim.")
	var persisted: Dictionary = SAVE_SCRIPT.load_game(path)
	_check(bool(persisted.get("ok", false)), "Fresh process must leave the offline save valid.")
	if bool(persisted.get("ok", false)):
		_check(int(persisted["data"]["run"]["credits"]) == EXPECTED_CREDITS, "Fresh-process payload should contain one claim only.")
		_check(int(persisted["data"]["run"]["wave"]) == 40, "Fresh-process payload must preserve current wave.")
	main.queue_free()
	await process_frame
	_cleanup(path)
	print("Fresh process restored one offline claim exactly once; disposable save and sidecars removed.")


func _new_main(path: String) -> Variant:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("Could not load main scene for offline restart probe.")
		return null
	var main: Variant = packed.instantiate()
	root.add_child(main)
	await process_frame
	main.save_path = path
	return main


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
		var artifact: String = path + suffix
		if FileAccess.file_exists(artifact):
			var error_code: Error = DirAccess.remove_absolute(artifact)
			if error_code != OK:
				_fail("Could not clean disposable offline probe artifact %s (error %d)." % [artifact, error_code])


func _check(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	failures += 1
	push_error("OFFLINE CLAIM PROCESS PROBE FAILED: " + message)
