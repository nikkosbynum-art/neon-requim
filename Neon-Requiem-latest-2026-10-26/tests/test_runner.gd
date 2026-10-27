extends SceneTree

const DIRECTOR_SCRIPT := preload("res://scripts/combat/combat_director.gd")
const ATTACHMENT_ROUTER_SCRIPT := preload("res://scripts/presentation/attachment_event_router.gd")
const ATTACHMENT_RECEIVER_SCRIPT := preload("res://scripts/presentation/attachment_presentation_receiver.gd")
const BREAKER_RIG_SCRIPT := preload("res://scripts/characters/breaker_t1_placeholder_rig.gd")
const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")
const BACKDROP_SCRIPT := preload("res://scripts/environment/undercity_backdrop.gd")
const ENVIRONMENT_DIRECTOR_SCRIPT := preload("res://scripts/environment/environment_director.gd")
const PROGRESSION_RULES_SCRIPT := preload("res://scripts/progression/progression_rules.gd")
const REBOOT_SERVICE_SCRIPT := preload("res://scripts/progression/reboot_service.gd")
const MATERIAL_REWARD_SCRIPT := preload("res://scripts/progression/material_reward_service.gd")
const EVOLUTION_SERVICE_SCRIPT := preload("res://scripts/progression/evolution_service.gd")
const OFFLINE_EARNINGS_SCRIPT := preload("res://scripts/progression/offline_earnings_service.gd")
const RESEARCH_SERVICE_SCRIPT := preload("res://scripts/progression/research_service.gd")
const RECRUITMENT_SERVICE_SCRIPT := preload("res://scripts/progression/recruitment_service.gd")
const ROSTER_STATE_SERVICE_SCRIPT := preload("res://scripts/progression/roster_state_service.gd")
const FORMATION_PREFERENCE_SERVICE_SCRIPT := preload("res://scripts/progression/formation_preference_service.gd")
const ALPHA_CONTOUR_MESH_BUILDER := preload("res://tools/art/polyrig_contour_mesh_builder.gd")
const PROGRESSION_PROFILE_PATH := "res://data/progression/progression_prototype_profile.json"
const RECRUITMENT_PROFILE_PATH := "res://data/progression/recruitment_prototype_profile.json"
const FOUNDING_RECRUITS_PATH := "res://data/characters/founding_recruits.json"
const WAVE_PROFILE_PATH := "res://data/waves/undercity_prototype.json"
const SPARK_DRONE_REVIEW_PATHS := [
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_01_BLUE_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_02_RED_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_03_AMBER_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
]
const SPECTER_BLADE_CANDIDATE_ROOT := "res://assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01/"
const CIPHER_RIFLE_CANDIDATE_PATH := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png"
const SPARK_DRONE_PIVOT_REVIEW_PATH := "res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/attachment_pivots_review_01.json"
const CIPHER_CANDIDATE_07_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07/"
const CIPHER_CANDIDATE_09B_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/"
const FOUNDING_PROFILE_RIG_SCRIPT := preload("res://tests/art/founding_t1_profile_mesh_rig_candidate.gd")
const FOUNDING_PROFILE_RIG_IDS := ["bulwark", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]
const TEST_SAVE_PATH := "res://tests/_temporary_test_save.json"
const FAULT_SAVE_PATH := "user://neon_requiem_fault_injection_save.json"
var failures := 0
var research_save_call_count := 0
var research_saved_permanent: Dictionary = {}
var research_saved_run: Dictionary = {}
var research_saved_settings: Dictionary = {}


class _AttachmentEventReceiver extends RefCounted:
	var events: Array[Dictionary] = []
	var mutate_damage := false

	func present_combat_event(event: Dictionary) -> void:
		events.append(event.duplicate(true))
		if mutate_damage:
			event["damage"] = 999999.0


class _AbilityCommitReceiver extends RefCounted:
	var director: Variant
	var events: Array[Dictionary] = []
	var enemy_hp_at_delivery := INF
	var cooldown_active_at_delivery := false

	func present_combat_event(event: Dictionary) -> void:
		events.append(event.duplicate(true))
		enemy_hp_at_delivery = float(director.enemy_hp)
		cooldown_active_at_delivery = director.ability_cooldown_until.has(str(event.get("source_id", "")))


class _MemoryFileOps extends RefCounted:
	var files: Dictionary = {}
	var fault := ""
	var writer_path := ""
	var writer_buffer := ""
	var writer_error: Error = OK
	var fail_remove_path := ""
	var alter_read_path := ""
	var alter_read_call := 1
	var read_counts: Dictionary = {}

	func open_write(path: String) -> Object:
		if fault == "open_write":
			return null
		writer_path = path
		writer_buffer = ""
		writer_error = OK
		return self

	func open_error() -> Error:
		return ERR_CANT_OPEN

	func store_string(contents: String) -> void:
		if fault == "write":
			writer_error = ERR_FILE_CANT_WRITE
			return
		writer_buffer = contents

	func flush() -> void:
		if fault == "flush":
			writer_error = ERR_FILE_CANT_WRITE
		elif writer_error == OK:
			files[writer_path] = writer_buffer

	func get_error() -> Error:
		return writer_error

	func close() -> void:
		pass

	func file_exists(path: String) -> bool:
		return files.has(path)

	func read_text(path: String) -> Dictionary:
		if fault == "readback" and path.ends_with(".tmp"):
			return {"ok": false, "error": "Injected read-back failure."}
		if not files.has(path):
			return {"ok": false, "error": "Injected missing file."}
		read_counts[path] = int(read_counts.get(path, 0)) + 1
		var contents := str(files[path])
		if path == alter_read_path and int(read_counts[path]) == alter_read_call:
			var altered: Variant = JSON.parse_string(contents)
			if typeof(altered) == TYPE_DICTIONARY and typeof(altered.get("run", null)) == TYPE_DICTIONARY:
				altered["run"]["credits"] = int(altered["run"].get("credits", 0)) + 1
				contents = JSON.stringify(altered)
		return {"ok": true, "contents": contents}

	func read_bytes(path: String) -> Dictionary:
		if not files.has(path):
			return {"ok": false, "error": "Injected missing file."}
		return {"ok": true, "bytes": str(files[path]).to_utf8_buffer()}

	func remove_file(path: String) -> Error:
		if path == fail_remove_path:
			return ERR_FILE_CANT_WRITE
		if fault == "previous_backup_commit_recovery" and path == FAULT_SAVE_PATH + ".bak.prev":
			return ERR_FILE_CANT_WRITE
		files.erase(path)
		return OK

	func copy_file(from_path: String, to_path: String) -> Error:
		if fault == "quarantine_copy" and to_path.contains("unsupported-quarantine-"):
			return ERR_FILE_CANT_WRITE
		if fault == "quarantine_corrupt" and to_path.contains("unsupported-quarantine-"):
			files[to_path] = str(files.get(from_path, "")) + "corrupt"
			return OK
		if fault == "reset_restore_copy" and from_path.contains("confirmed-reset-rollback-") and to_path == FAULT_SAVE_PATH:
			return ERR_FILE_CANT_WRITE
		if fault == "backup_rotation" and to_path.ends_with(".bak.tmp"):
			return ERR_FILE_CANT_WRITE
		if fault == "backup_promotion" and from_path == FAULT_SAVE_PATH + ".bak.tmp" and to_path == FAULT_SAVE_PATH + ".bak":
			return ERR_FILE_CANT_WRITE
		if fault in ["rollback_copy", "corrupt_commit_rollback_copy"] and from_path == FAULT_SAVE_PATH + ".bak" and to_path == FAULT_SAVE_PATH:
			return ERR_FILE_CANT_WRITE
		if not files.has(from_path):
			return ERR_FILE_NOT_FOUND
		if fault == "partial_commit" and from_path == FAULT_SAVE_PATH + ".tmp" and to_path == FAULT_SAVE_PATH:
			files[to_path] = str(files[from_path]).substr(0, 12)
			return ERR_FILE_CANT_WRITE
		if fault in ["corrupt_commit", "corrupt_commit_rollback_copy"] and from_path == FAULT_SAVE_PATH + ".tmp" and to_path == FAULT_SAVE_PATH:
			files[to_path] = "invalid committed payload"
			return OK
		if fault == "previous_backup_commit_recovery" and from_path == FAULT_SAVE_PATH + ".tmp" and to_path == FAULT_SAVE_PATH:
			files[FAULT_SAVE_PATH + ".bak"] = "invalidated recovery backup"
			files[to_path] = "partial committed payload"
			return ERR_FILE_CANT_WRITE
		files[to_path] = files[from_path]
		return OK


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var user_args := OS.get_cmdline_user_args()
	if user_args.has("--i04-ability-router-regression-only"):
		await _test_main_scene_ability_trial_event_routing()
		if failures == 0:
			print("Focused I-04 main-scene ability event routing regression passed.")
		else:
			push_error("%d focused I-04 main-scene ability event routing regression(s) failed." % failures)
			quit(1)
			return
		quit(0)
		return
	if user_args.has("--i05-cli-seed-regression-only"):
		var cli_director: CombatDirector = DIRECTOR_SCRIPT.new()
		root.add_child(cli_director)
		_check(cli_director.combat_model == "hybrid_trial" and cli_director.encounter_seed == 12345, "The hybrid CLI flag should opt in and the explicit CLI seed should override the first encounter seed.")
		var cli_stride := int(cli_director.combat_trial_def.get("seed_stride", 0))
		cli_director._begin_encounter()
		_check(cli_stride > 0 and cli_director.encounter_seed == 12345 + cli_stride, "CLI seed override should seed subsequent encounters by the configured stride.")
		cli_director.queue_free()
		if failures == 0:
			print("Focused I-05 CLI seed override regression passed.")
			quit(0)
		else:
			push_error("%d I-05 CLI seed override regression(s) failed." % failures)
			quit(1)
		return
	if user_args.has("--i05-regression-only") or user_args.has("--hybrid-combat-regression-only"):
		_test_i05_default_and_seeded_combat()
		_test_i05_score_mapping_and_attack_sampling()
		_test_i05_timer_order_and_resets()
		_test_i05_timer_defeat_retreat_and_retry()
		if failures == 0:
			print("All focused I-05 hybrid-combat regressions passed.")
		else:
			push_error("%d focused I-05 hybrid-combat regression(s) failed." % failures)
			quit(1)
			return
		quit(0)
		return
	if OS.get_cmdline_user_args().has("--confirmed-reset-regression-only"):
		_test_save_protection_and_recovery_policy()
		if failures == 0:
			print("All focused confirmed-reset and save-protection regressions passed.")
			quit(0)
		else:
			push_error("%d confirmed-reset/save-protection regression(s) failed." % failures)
			quit(1)
		return
	if user_args.has("--save-recovery-regression-only"):
		_test_explicit_save_after_recovered_backup_preserves_unknown_fields()
		await _test_recovered_load_warning_and_offline_claim_deferral()
		if failures == 0:
			print("All focused save-recovery regressions passed.")
			quit(0)
		else:
			push_error("%d focused save-recovery regression(s) failed." % failures)
			quit(1)
		return
	if OS.get_cmdline_user_args().has("--roster-regression-only"):
		_test_roster_lineup_identity_and_preferences()
		_test_v1_roster_migration()
		if failures == 0:
			print("All focused roster and save-migration regressions passed.")
			quit(0)
		else:
			push_error("%d focused roster and save-migration regression(s) failed." % failures)
			quit(1)
		return
	_cleanup_test_save_files()
	_test_progression_rule_primitives()
	_test_recruitment_transactions()
	_test_roster_lineup_identity_and_preferences()
	_test_v1_roster_migration()
	_test_research_transactions()
	_test_offline_earnings_calculation()
	_test_material_reward_pipeline()
	_test_reboot_transaction()
	_test_lifetime_influence_combat_modifier()
	_test_combat_reward_and_order()
	_test_structured_combat_action_events()
	_test_attachment_event_routing()
	_test_attachment_presentation_receiver()
	_test_spark_drone_polyrig_mesh_inputs()
	_test_specter_blade_polyrig_mesh_inputs()
	_test_cipher_rifle_polyrig_mesh_input()
	_test_polyrig_contour_builder_rejects_mismatched_texture()
	_test_cipher_candidate_07_intake()
	_test_cipher_candidate_09b_mesh_inputs()
	await _test_founding_profile_mesh_preflights()
	_test_full_automatic_encounter()
	_test_presentation_interpolation_isolation_and_reset()
	_test_six_slot_squad_and_auto_targeting()
	_test_defeat_retreat()
	_test_hp_carryover_and_natural_retreat()
	_test_wave_cap()
	await _test_modular_encounter_zone_transition()
	_test_breaker_tier_one_rig()
	_test_local_breaker_atlas_drafts()
	_test_breaker_head_art_trial()
	_test_save_sections_round_trip()
	_test_save_validation_rejects_invalid_data()
	_test_save_protection_and_recovery_policy()
	await _test_save_ui_guard_and_confirmation()
	_test_save_fault_injection()
	await _test_main_scene_builds_default_owned_roster()
	await process_frame
	await _test_wave_clear_autosave_and_recovery()
	await _test_offline_earnings_live_load()
	await _test_recovered_load_warning_and_offline_claim_deferral()
	_cleanup_test_save_files()
	if failures == 0:
		print("All Neon Requiem prototype tests passed.")
		quit(0)
	else:
		push_error("%d Neon Requiem prototype test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("TEST FAILED: " + message)


func _test_main_scene_ability_trial_event_routing() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	main.director.set_process(false)
	main.director.set_physics_process(false)
	await process_frame
	var director = main.director
	var spark_index: int = director._find_ally_index("spark")
	_check(spark_index >= 0 and director.ability_trial_valid, "The live main scene should load SPARK and a valid opt-in ability trial profile.")
	_check(not director.ability_trial_enabled, "A fresh main scene should keep the ability trial disabled by default.")
	if spark_index < 0 or not director.ability_trial_valid:
		main.queue_free()
		await process_frame
		return
	for ally_index in range(director.allies.size()):
		if ally_index != spark_index:
			director.allies[ally_index]["hp"] = 0.0
	var spark: Dictionary = director.allies[spark_index]
	spark["x"] = float(director.enemy_x) - float(spark.get("engagement_distance", 0.0)) + 1.0
	spark["attack_elapsed"] = director._effective_ally_attack_interval(spark)
	director.allies[spark_index] = spark
	director.enemy_hp = 100000.0
	var observed_events := _AttachmentEventReceiver.new()
	director.combat_action_resolved.connect(observed_events.present_combat_event)
	var routed_receiver := _AbilityCommitReceiver.new()
	routed_receiver.director = director
	_check(main.attachment_event_router.register_attachment("test.spark.ability", "spark", routed_receiver, ["ability_resolved"]), "The live main-scene router should accept a test receiver for SPARK's committed ability event.")
	director._simulate_allies(director.FIXED_STEP)
	var disabled_ability_events: Array[Dictionary] = observed_events.events.filter(func(event: Dictionary) -> bool: return event.get("event_type") == "ability_resolved")
	var disabled_attack_events: Array[Dictionary] = observed_events.events.filter(func(event: Dictionary) -> bool: return event.get("event_type") == "attack_resolved" and event.get("source_id") == "spark")
	_check(disabled_ability_events.is_empty() and not director.ability_cooldown_until.has("spark") and not director.ability_effects.has("spark"), "With trial disabled, SPARK should not emit an ability event or commit an ability effect/cooldown.")
	_check(disabled_attack_events.size() == 1, "The disabled-trial automatic boundary should still resolve SPARK's ordinary attack.")
	_check(routed_receiver.events.is_empty(), "The live router should not deliver an ability event while the trial is disabled.")
	_check(director.configure_ability_trial(true), "The valid provisional profile should enable through the explicit trial opt-in.")
	spark = director.allies[spark_index]
	spark["attack_elapsed"] = director._effective_ally_attack_interval(spark)
	director.allies[spark_index] = spark
	var enemy_hp_before := float(director.enemy_hp)
	var ability_profile: Dictionary = director.ability_trial_def.get("abilities", {}).get("spark", {})
	director._simulate_allies(director.FIXED_STEP)
	var ability_events: Array[Dictionary] = observed_events.events.filter(func(event: Dictionary) -> bool: return event.get("event_type") == "ability_resolved" and event.get("source_id") == "spark")
	var expected_ability_id := str(ability_profile.get("ability_id", ""))
	_check(float(director.enemy_hp) < enemy_hp_before and director.ability_cooldown_until.has("spark"), "An opted-in automatic SPARK commit should change enemy HP and start its cooldown.")
	_check(ability_events.size() == 1 and ability_events[0].get("ability_id") == expected_ability_id, "The automatic SPARK commit should emit exactly one matching ability summary event.")
	_check(routed_receiver.events.size() == 1 and routed_receiver.events[0].get("event_type") == "ability_resolved" and routed_receiver.events[0].get("ability_id") == expected_ability_id, "The live main-scene router should deliver exactly one matching committed ability event.")
	_check(routed_receiver.enemy_hp_at_delivery < enemy_hp_before and routed_receiver.cooldown_active_at_delivery, "The routed event should arrive after authoritative damage and cooldown state commit.")
	main.queue_free()
	await process_frame


func _array_has_all(values: Array, expected: Array) -> bool:
	for expected_value in expected:
		if not values.has(expected_value):
			return false
	return true


func _test_recruitment_transactions() -> void:
	var roster_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(FOUNDING_RECRUITS_PATH))
	var profile_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(RECRUITMENT_PROFILE_PATH))
	_check(typeof(roster_value) == TYPE_DICTIONARY and typeof(profile_value) == TYPE_DICTIONARY, "Founding recruit catalog and prototype recruitment profile should parse as JSON objects.")
	var roster: Dictionary = roster_value if typeof(roster_value) == TYPE_DICTIONARY else {}
	var profile: Dictionary = profile_value if typeof(profile_value) == TYPE_DICTIONARY else {}
	_check(bool(RECRUITMENT_SERVICE_SCRIPT.validate_configuration(roster, profile).get("ok", false)), "Recruitment configuration should validate against the approved founding roster.")
	_check(int(profile.get("starting_credits", -1)) == 600 and profile.get("starting_owned_recruits", []) == ["vector", "spark", "recoil"], "Fresh playtest state should grant 600 credits and permanently own VECTOR, SPARK, and RECOIL.")
	var prices: Dictionary = profile.get("price_by_rarity", {})
	_check(int(prices.get("Common", -1)) == 300 and int(prices.get("Rare", -1)) == 600 and int(prices.get("Epic", -1)) == 1200, "Trial recruitment prices should remain Common 300, Rare 600, and Epic 1,200.")
	var expected_ids := ["bulwark", "breaker", "cipher", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]
	var catalog_ids: Array[String] = []
	var by_id: Dictionary = {}
	for recruit_value in roster.get("recruits", []):
		if typeof(recruit_value) == TYPE_DICTIONARY:
			var recruit: Dictionary = recruit_value
			var recruit_id := str(recruit.get("id", ""))
			catalog_ids.append(recruit_id)
			by_id[recruit_id] = recruit
			_check(not str(recruit.get("name", "")).is_empty() and not str(recruit.get("faction", "")).is_empty() and not str(recruit.get("roles", "")).is_empty(), "Recruit %s should include source-backed name, faction, and role fields." % recruit_id)
	_check(catalog_ids.size() == 12 and catalog_ids.size() == by_id.size() and by_id.keys().all(func(recruit_id): return expected_ids.has(recruit_id)), "Recruitment catalog should contain exactly the twelve unique founding recruit IDs, with no boss or unknown entries.")
	var starters := RECRUITMENT_SERVICE_SCRIPT.initial_owned_recruits(profile)
	_check(starters == ["vector", "spark", "recoil"], "Initial ownership helper should return exactly the approved playtest trio.")
	var empty_permanent := {"research": {"combat": 2}, "unlocks": []}
	var empty_run := {"credits": 600, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1}}}
	var permanent_before: Dictionary = empty_permanent.duplicate(true)
	var run_before: Dictionary = empty_run.duplicate(true)
	var common_exact := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, empty_run, roster, profile, "stitch")
	var rare_exact := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, empty_run, roster, profile, "cipher")
	var epic_exact := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, empty_run, roster, profile, "breaker")
	_check(bool(common_exact.get("ok", false)) and common_exact["cost"] == 300 and common_exact["affordable"], "A Common recruit should be affordable at exactly 300 credits.")
	_check(bool(rare_exact.get("ok", false)) and rare_exact["cost"] == 600 and rare_exact["affordable"], "A Rare recruit should be affordable at exactly 600 credits.")
	_check(bool(epic_exact.get("ok", false)) and epic_exact["cost"] == 1200 and not epic_exact["affordable"], "An Epic recruit should cost 1,200 and remain unaffordable at 600 credits.")
	var insufficient_run := empty_run.duplicate(true)
	insufficient_run["credits"] = 299
	var common_below := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, insufficient_run, roster, profile, "stitch")
	_check(bool(common_below.get("ok", false)) and not common_below["affordable"], "A Common recruit should be unaffordable one credit below its 300-credit price.")
	var rare_below_run := empty_run.duplicate(true)
	rare_below_run["credits"] = 599
	var rare_below := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, rare_below_run, roster, profile, "cipher")
	_check(bool(rare_below.get("ok", false)) and not rare_below["affordable"], "A Rare recruit should be unaffordable one credit below its 600-credit price.")
	var epic_exact_run := empty_run.duplicate(true)
	epic_exact_run["credits"] = 1200
	var epic_exact_purchase := RECRUITMENT_SERVICE_SCRIPT.purchase_recruit(empty_permanent, epic_exact_run, roster, profile, "breaker")
	_check(bool(epic_exact_purchase.get("ok", false)) and epic_exact_purchase["run"]["credits"] == 0, "An Epic recruit should be purchasable at exactly 1,200 credits.")
	var common_purchase := RECRUITMENT_SERVICE_SCRIPT.purchase_recruit(empty_permanent, empty_run, roster, profile, "stitch")
	_check(bool(common_purchase.get("ok", false)) and common_purchase["run"]["credits"] == 300 and common_purchase["permanent"]["unlocks"].has("stitch"), "A successful Common purchase should atomically propose permanent ownership and deduct exactly 300 run credits.")
	_check(empty_permanent == permanent_before and empty_run == run_before, "Recruitment evaluation and purchase should leave their input permanent and run dictionaries unchanged.")
	var duplicate := RECRUITMENT_SERVICE_SCRIPT.purchase_recruit(common_purchase["permanent"], common_purchase["run"], roster, profile, "stitch")
	_check(not bool(duplicate.get("ok", true)) and common_purchase["run"]["credits"] == 300, "A duplicate recruit purchase should be rejected without spending more credits.")
	var starter_eval := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, empty_run, roster, profile, "vector")
	_check(bool(starter_eval.get("ok", false)) and starter_eval["owned"] and not starter_eval["affordable"], "An initial starter should evaluate as already owned.")
	var unknown := RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(empty_permanent, empty_run, roster, profile, "boss.test_warden")
	_check(not bool(unknown.get("ok", true)), "Unknown recruit IDs and named bosses should fail closed.")
	var corrupt_roster := roster.duplicate(true)
	corrupt_roster["recruits"].append({"id": "unknown", "name": "UNKNOWN", "faction": "Unknown", "roles": "Unknown", "rarity": "Common"})
	_check(not bool(RECRUITMENT_SERVICE_SCRIPT.validate_configuration(corrupt_roster, profile).get("ok", true)), "A catalog containing an unknown roster entry should fail validation.")
	corrupt_roster = roster.duplicate(true)
	corrupt_roster["recruits"].pop_back()
	_check(not bool(RECRUITMENT_SERVICE_SCRIPT.validate_configuration(corrupt_roster, profile).get("ok", true)), "A catalog missing a founding recruit should fail validation.")
	var legacy := {"unlocks": ["cipher", "cipher"], "lifetime_influence": 9}
	var legacy_before: Dictionary = legacy.duplicate(true)
	var migrated := RECRUITMENT_SERVICE_SCRIPT.ensure_starting_recruits(legacy, profile)
	_check(_array_has_all(migrated["unlocks"], ["cipher", "vector", "spark", "recoil"]) and migrated["unlocks"].count("vector") == 1 and migrated["unlocks"].count("spark") == 1 and migrated["unlocks"].count("recoil") == 1, "Legacy ownership migration should idempotently add the starter trio while preserving existing ownership.")
	_check(legacy == legacy_before and not migrated.has("credits"), "Legacy ownership migration should not mutate input or grant credits.")
	_check(RECRUITMENT_SERVICE_SCRIPT.ensure_starting_recruits(migrated, profile) == migrated, "Applying legacy starter migration twice should be idempotent.")
	var save_payload := _valid_test_save_payload()
	save_payload["permanent"] = common_purchase["permanent"].duplicate(true)
	save_payload["run"]["credits"] = common_purchase["run"]["credits"]
	var file_ops := _MemoryFileOps.new()
	var save_error: Error = SAVE_SCRIPT._save_game_with_file_ops(save_payload["permanent"], save_payload["run"], save_payload["settings"], FAULT_SAVE_PATH, file_ops)
	var loaded: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, file_ops)
	_check(save_error == OK and bool(loaded.get("ok", false)) and loaded["data"]["permanent"]["unlocks"].has("stitch") and loaded["data"]["run"]["credits"] == 300, "A successful recruitment transaction should persist ownership and remaining credits together and reload them.")
	var reboot_run: Dictionary = save_payload["run"].duplicate(true)
	reboot_run["credits"] = 300
	reboot_run["wave"] = 50
	reboot_run["highest_cleared_wave"] = 50
	reboot_run["squad_hp"] = [120.0, 90.0, 80.0, 110.0, 85.0, 75.0]
	var rebooted: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(common_purchase["permanent"], reboot_run, JSON.parse_string(FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH)), reboot_run["squad_hp"])
	_check(bool(rebooted.get("ok", false)) and _array_has_all(rebooted["permanent"]["unlocks"], ["vector", "spark", "recoil", "stitch"]) and rebooted["run"]["credits"] == 0, "Reboot should preserve starter and purchased ownership while resetting run credits.")


func _test_roster_lineup_identity_and_preferences() -> void:
	var owned := ["vector", "spark", "recoil", "stitch", "bulwark", "cipher", "deadlock"]
	var default_lineup: Array = ROSTER_STATE_SERVICE_SCRIPT.build_default_lineup(owned)
	_check(default_lineup == ["bulwark", "cipher", "spark", "stitch", "recoil", "vector"], "A missing active lineup should use canonical founding-roster order up to six; later owned recruits stay in reserve.")
	var short_lineup: Array = ROSTER_STATE_SERVICE_SCRIPT.build_default_lineup(["vector", "recoil"])
	_check(short_lineup == ["recoil", "vector", "", "", "", ""], "Fewer than six owned recruits should leave remaining active slots vacant in canonical founding-roster order.")
	var valid_lineup := ["vector", "spark", "", "", "", ""]
	_check(bool(ROSTER_STATE_SERVICE_SCRIPT.validate_active_lineup(valid_lineup, ["vector", "spark"]).get("ok", false)), "An active lineup containing only unique owned IDs and vacant strings should validate.")
	_check(not bool(ROSTER_STATE_SERVICE_SCRIPT.validate_active_lineup(["vector", "vector", "", "", "", ""], ["vector"]).get("ok", true)), "An active lineup must reject duplicate deployment of one recruit.")
	_check(not bool(ROSTER_STATE_SERVICE_SCRIPT.validate_active_lineup(["vector", "stitch", "", "", "", ""], ["vector"]).get("ok", true)), "An active lineup must reject a recruit that is not owned.")
	_check(not bool(ROSTER_STATE_SERVICE_SCRIPT.ensure_owned_recruit_records({"recruits": {}}, ["vector", "vector"], {"vector": 70.0}).get("ok", true)), "Owned recruit state must reject duplicate owned IDs rather than silently creating duplicate records.")
	var filled := ROSTER_STATE_SERVICE_SCRIPT.auto_fill_first_open(valid_lineup, ["vector", "spark", "stitch"], "stitch")
	_check(bool(filled.get("ok", false)) and filled["lineup"] == ["vector", "spark", "stitch", "", "", ""] and int(filled.get("slot", -1)) == 2, "A newly purchased owned recruit should fill the first vacant saved slot.")
	var full_lineup := ["vector", "spark", "recoil", "bulwark", "cipher", "stitch"]
	var reserve_result := ROSTER_STATE_SERVICE_SCRIPT.auto_fill_first_open(full_lineup, owned, "deadlock")
	_check(bool(reserve_result.get("ok", false)) and not bool(reserve_result.get("deployed", true)) and bool(reserve_result.get("reserve", false)) and reserve_result["lineup"] == full_lineup, "A purchased recruit should remain in reserve when all six active slots are occupied.")
	var swap_run := {"active_lineup": ["vector", "spark", "recoil", "", "", ""], "recruits": {"vector": {"hp": 37.0}, "spark": {"hp": 29.0}, "stitch": {"hp": 18.0}}}
	var swapped := ROSTER_STATE_SERVICE_SCRIPT.swap_lineup_slot(swap_run, ["vector", "spark", "recoil", "stitch"], 1, "stitch", false)
	_check(bool(swapped.get("ok", false)) and swapped["run"]["active_lineup"] == ["vector", "stitch", "recoil", "", "", ""] and swap_run["active_lineup"][1] == "spark", "Between-encounter lineup swaps should return a new run state without mutating the caller's saved lineup.")
	_check(not bool(ROSTER_STATE_SERVICE_SCRIPT.swap_lineup_slot(swap_run, ["vector", "spark", "recoil", "stitch"], 1, "stitch", true).get("ok", true)), "Lineup swaps must be rejected while combat is active.")
	_check(not bool(ROSTER_STATE_SERVICE_SCRIPT.swap_lineup_slot(swap_run, ["vector", "spark", "recoil", "stitch"], 0, "deadlock", false).get("ok", true)), "Lineup swaps must reject recruits that are not owned.")

	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var initial := ["vector", "spark", "recoil", "", "", ""]
	var recruit_states := {"vector": {"level": 1, "hp": 42.0}, "spark": {"level": 1, "hp": 51.0}, "recoil": {"level": 1, "hp": 33.0}, "stitch": {"level": 1, "hp": 18.0}}
	_check(director.set_active_lineup(initial, ["vector", "spark", "recoil", "stitch"], recruit_states, true), "CombatDirector should accept a valid owned lineup for an isolated regression fixture.")
	var live_before: Array[String] = []
	for ally in director.allies:
		live_before.append(str(ally.get("id", "")))
	director.phase = "combat"
	var queued_lineup := ["vector", "spark", "recoil", "stitch", "", ""]
	_check(director.set_active_lineup(queued_lineup, ["vector", "spark", "recoil", "stitch"], recruit_states), "CombatDirector should queue an approved lineup update made during combat.")
	var live_during_combat: Array[String] = []
	for ally in director.allies:
		live_during_combat.append(str(ally.get("id", "")))
	_check(live_during_combat == live_before and director.active_lineup == initial and director.pending_active_lineup == queued_lineup, "Queued deployment must leave live encounter allies unchanged until the next encounter boundary.")
	director._begin_encounter()
	var live_next_encounter: Array[String] = []
	for ally in director.allies:
		live_next_encounter.append(str(ally.get("id", "")))
	_check(live_next_encounter == ["vector", "spark", "recoil", "stitch"] and director.pending_active_lineup.is_empty(), "Queued deployment should apply at the next encounter boundary.")
	director.allies[0]["hp"] = 26.0
	director.allies[3]["hp"] = 11.0
	var saved_run: Dictionary = director.snapshot()
	_check(float(saved_run["recruit_states"]["vector"]["hp"]) == 26.0 and float(saved_run["recruit_states"]["stitch"]["hp"]) == 11.0, "Combat snapshot should bind current HP to each recruit ID.")
	var swapped_saved := ROSTER_STATE_SERVICE_SCRIPT.swap_lineup_slot(saved_run, ["vector", "spark", "recoil", "stitch"], 0, "stitch", false)
	_check(bool(swapped_saved.get("ok", false)) and float(swapped_saved["run"]["recruit_states"]["vector"]["hp"]) == 26.0 and float(swapped_saved["run"]["recruit_states"]["stitch"]["hp"]) == 11.0, "Swapping and benching must preserve HP records by recruit identity.")
	var save_ops := _MemoryFileOps.new()
	var saved_payload := _valid_test_save_payload()
	saved_payload["permanent"]["unlocks"] = ["vector", "spark", "recoil", "stitch"]
	saved_payload["run"] = saved_run.duplicate(true)
	saved_payload["run"]["recruits"] = saved_payload["run"].get("recruit_states", {}).duplicate(true)
	if not saved_payload["run"]["recruits"].has("breaker"):
		saved_payload["run"]["recruits"]["breaker"] = {"level": 1}
	saved_payload["run"].erase("recruit_states")
	var saved_text := JSON.stringify(saved_payload)
	var save_error: Error = SAVE_SCRIPT._save_game_with_file_ops(saved_payload["permanent"], saved_payload["run"], saved_payload["settings"], FAULT_SAVE_PATH, save_ops)
	var reloaded: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, save_ops)
	_check(save_error == OK and bool(reloaded.get("ok", false)) and float(reloaded.get("data", {}).get("run", {}).get("recruits", {}).get("vector", {}).get("hp", -1.0)) == 26.0 and float(reloaded.get("data", {}).get("run", {}).get("recruits", {}).get("stitch", {}).get("hp", -1.0)) == 11.0, "Save/load round trip should retain identity-based HP and active lineup (save error %d; load error %s)." % [save_error, str(reloaded.get("error", "none"))])
	_check(str(saved_payload["run"]["active_lineup"][0]) == "vector" and saved_text == JSON.stringify(saved_payload), "Save serialization should not mutate lineup or identity records in the caller's run state.")
	director.queue_free()

	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	var purchase_path := ProjectSettings.globalize_path("res://tests/_lineup_purchase_regression.json")
	main.save_path = purchase_path
	main.loaded_save_path = ""
	main.director.phase = "combat"
	var active_before_purchase: Array[String] = []
	for ally in main.director.allies:
		active_before_purchase.append(str(ally.get("id", "")))
	main._purchase_recruit("stitch")
	var purchase_saved := SAVE_SCRIPT.load_game(purchase_path)
	var active_during_purchase: Array[String] = []
	for ally in main.director.allies:
		active_during_purchase.append(str(ally.get("id", "")))
	_check(bool(purchase_saved.get("ok", false)) and purchase_saved["data"]["run"]["active_lineup"] == ["spark", "recoil", "vector", "stitch", "", ""], "A successful in-combat purchase should persist auto-deployment into the first vacant next-encounter slot.")
	_check(main.director.economy.credits == 300 and main.active_lineup == ["spark", "recoil", "vector", "stitch", "", ""] and active_during_purchase == active_before_purchase and main.director.pending_active_lineup == main.active_lineup, "In-combat recruitment should atomically deduct credits and queue the owned recruit without changing live allies.")
	main.director._begin_encounter()
	var active_next_encounter: Array[String] = []
	for ally in main.director.allies:
		active_next_encounter.append(str(ally.get("id", "")))
	_check(active_next_encounter == ["spark", "recoil", "vector", "stitch"] and main.director.pending_active_lineup.is_empty(), "The in-combat purchase should join the active squad only after the next encounter begins.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		if FileAccess.file_exists(purchase_path + suffix):
			DirAccess.remove_absolute(purchase_path + suffix)
	main.queue_free()

	var permanent := {"unlocks": ["vector", "spark", "stitch"], "formation_preferences": {}}
	var preference_set := FORMATION_PREFERENCE_SERVICE_SCRIPT.set_preference(permanent, "vector", "Front", "Control")
	_check(bool(preference_set.get("ok", false)) and preference_set["permanent"]["formation_preferences"]["vector"] == {"position": "Front", "role": "Control"} and permanent["formation_preferences"].is_empty(), "Formation preference updates should return a copied permanent state and preserve the input.")
	var preference_clear := FORMATION_PREFERENCE_SERVICE_SCRIPT.set_preference(preference_set["permanent"], "vector", "", "")
	_check(bool(preference_clear.get("ok", false)) and not preference_clear["permanent"]["formation_preferences"].has("vector"), "Selecting blank formation preferences should clear that recruit's stored preference.")
	_check(not bool(FORMATION_PREFERENCE_SERVICE_SCRIPT.set_preference(permanent, "unknown", "Front", "Assault").get("ok", true)), "Formation preferences should reject unknown recruit IDs.")
	_check(not bool(FORMATION_PREFERENCE_SERVICE_SCRIPT.set_preference(permanent, "vector", "Center", "Assault").get("ok", true)), "Formation preferences should reject selector values outside the approved options.")
	var preference_payload := _valid_test_save_payload()
	preference_payload["permanent"]["unlocks"] = permanent["unlocks"]
	preference_payload["permanent"]["formation_preferences"] = preference_set["permanent"]["formation_preferences"]
	preference_payload["run"]["active_lineup"] = ["vector", "spark", "", "", "", ""]
	var preference_ops := _MemoryFileOps.new()
	var preference_error: Error = SAVE_SCRIPT._save_game_with_file_ops(preference_payload["permanent"], preference_payload["run"], preference_payload["settings"], FAULT_SAVE_PATH, preference_ops)
	var preference_reload := SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, preference_ops)
	_check(preference_error == OK and bool(preference_reload.get("ok", false)) and preference_reload["data"]["permanent"]["formation_preferences"] == preference_set["permanent"]["formation_preferences"], "Formation preferences should persist through a validated save/load round trip.")
	var reboot_profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH))
	var reboot_run: Dictionary = saved_run.duplicate(true)
	reboot_run["recruits"] = reboot_run.get("recruit_states", {}).duplicate(true)
	if not reboot_run["recruits"].has("breaker"):
		reboot_run["recruits"]["breaker"] = {"level": 1}
	reboot_run.erase("recruit_states")
	reboot_run["credits"] = 300
	reboot_run["wave"] = 50
	reboot_run["highest_cleared_wave"] = 50
	reboot_run["active_lineup"] = ["vector", "spark", "", "", "", ""]
	reboot_run["recruits"]["vector"]["hp"] = 9.0
	reboot_run["recruits"]["spark"]["hp"] = 12.0
	reboot_run["recruits"]["stitch"]["hp"] = 4.0
	var max_hp_by_id := {"vector": 70.0, "spark": 70.0, "stitch": 70.0}
	var reboot_result: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(preference_set["permanent"], reboot_run, reboot_profile, [], max_hp_by_id)
	_check(bool(reboot_result.get("ok", false)) and reboot_result["run"]["active_lineup"] == reboot_run["active_lineup"], "System Reboot should preserve the active lineup while retaining the formation preference state.")
	_check(reboot_result["permanent"]["formation_preferences"] == preference_set["permanent"]["formation_preferences"], "System Reboot should preserve formation preferences with permanent recruit state.")
	_check(float(reboot_result["run"]["recruits"]["vector"]["hp"]) == 70.0 and float(reboot_result["run"]["recruits"]["spark"]["hp"]) == 70.0 and float(reboot_result["run"]["recruits"]["stitch"]["hp"]) == 70.0, "System Reboot should heal all owned recruits, including a reserve recruit.")
	_check(not reboot_result["run"].has("squad_hp"), "Identity-based Reboot should remove the obsolete positional squad HP field.")
	var roster_after_reboot := ROSTER_STATE_SERVICE_SCRIPT.build_default_lineup(reboot_result["permanent"]["unlocks"])
	_check(roster_after_reboot == ["spark", "stitch", "vector", "", "", ""], "Stored formation preferences should not alter canonical founding-roster deployment order; the saved active lineup remains its separate field.")


func _test_v1_roster_migration() -> void:
	var base := _valid_test_save_payload()
	base["save_version"] = SAVE_SCRIPT.MIGRATABLE_SAVE_VERSION
	base["permanent"]["unlocks"] = ["breaker", "vector"]
	base["run"]["recruits"] = {"breaker": {"level": 7}}
	base["run"]["squad_hp"] = [33.0, 21.0, 44.0, 55.0, 66.0, 77.0]
	var original_text := JSON.stringify(base)
	var migration_ops := _MemoryFileOps.new()
	migration_ops.files[FAULT_SAVE_PATH] = original_text
	var migrated: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, migration_ops)
	_check(bool(migrated.get("ok", false)) and int(migrated.get("migrated_from_version", 0)) == 1 and int(migrated["data"]["save_version"]) == SAVE_SCRIPT.SAVE_VERSION, "A supported version-1 primary should migrate to the current version through the staged save transaction.")
	if bool(migrated.get("ok", false)):
		_check(float(migrated["data"]["run"]["recruits"]["breaker"]["hp"]) == 33.0 and migrated["data"]["run"]["legacy_placeholder_squad_hp"] == [21.0, 44.0, 55.0, 66.0, 77.0] and not migrated["data"]["run"].has("squad_hp"), "Version-1 migration should map only slot zero to BREAKER and preserve the other five values as unmapped legacy data.")
	var committed: Dictionary = SAVE_SCRIPT._parse_and_validate(str(migration_ops.files.get(FAULT_SAVE_PATH, "")))
	_check(bool(committed.get("ok", false)) and int(committed["data"]["save_version"]) == SAVE_SCRIPT.SAVE_VERSION and migration_ops.files.has(FAULT_SAVE_PATH + ".bak"), "Successful migration should commit validated version-2 bytes while retaining the original version-1 save as a recovery backup.")
	_check(not migration_ops.files.has(FAULT_SAVE_PATH + ".tmp") and not migration_ops.files.has(FAULT_SAVE_PATH + ".bak.tmp"), "Successful version-1 migration should clean staged transaction files.")

	var omitted_hp_v1 := _valid_test_save_payload()
	omitted_hp_v1["save_version"] = SAVE_SCRIPT.MIGRATABLE_SAVE_VERSION
	omitted_hp_v1["permanent"]["evolution"]["breaker_tier"] = "Combat Grade"
	omitted_hp_v1["run"]["recruits"] = {"breaker": {"level": 7}}
	omitted_hp_v1["run"].erase("squad_hp")
	var omitted_hp_original_text := JSON.stringify(omitted_hp_v1)
	var omitted_hp_ops := _MemoryFileOps.new()
	omitted_hp_ops.files[FAULT_SAVE_PATH] = omitted_hp_original_text
	var omitted_hp_migrated: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, omitted_hp_ops)
	_check(bool(omitted_hp_migrated.get("ok", false)) and int(omitted_hp_migrated.get("migrated_from_version", 0)) == SAVE_SCRIPT.MIGRATABLE_SAVE_VERSION and int(omitted_hp_migrated.get("data", {}).get("save_version", 0)) == SAVE_SCRIPT.SAVE_VERSION and str(omitted_hp_migrated.get("data", {}).get("permanent", {}).get("evolution", {}).get("breaker_tier", "")) == "Adapted Form", "A v1 save without positional HP should migrate successfully to v2 and normalize Combat Grade to Adapted Form.")
	if bool(omitted_hp_migrated.get("ok", false)):
		var omitted_hp_run: Dictionary = omitted_hp_migrated["data"]["run"]
		var omitted_hp_recruits: Dictionary = omitted_hp_run.get("recruits", {})
		_check(not omitted_hp_run.has("squad_hp") and not omitted_hp_run.has("legacy_placeholder_squad_hp") and not omitted_hp_recruits.get("breaker", {}).has("hp"), "A v1 save without squad_hp must not invent positional, placeholder, or BREAKER HP during migration.")
	var omitted_hp_committed: Dictionary = SAVE_SCRIPT._parse_and_validate(str(omitted_hp_ops.files.get(FAULT_SAVE_PATH, "")))
	_check(bool(omitted_hp_committed.get("ok", false)) and int(omitted_hp_committed.get("data", {}).get("save_version", 0)) == SAVE_SCRIPT.SAVE_VERSION and str(omitted_hp_committed.get("data", {}).get("permanent", {}).get("evolution", {}).get("breaker_tier", "")) == "Adapted Form", "The committed v2 save should contain the normalized evolution tier.")
	if bool(omitted_hp_committed.get("ok", false)):
		var committed_omitted_hp_run: Dictionary = omitted_hp_committed["data"]["run"]
		var committed_omitted_hp_recruits: Dictionary = committed_omitted_hp_run.get("recruits", {})
		_check(not committed_omitted_hp_run.has("squad_hp") and not committed_omitted_hp_run.has("legacy_placeholder_squad_hp") and not committed_omitted_hp_recruits.get("breaker", {}).has("hp"), "The committed v2 save must not invent HP fields for the v1 save that omitted them.")
	_check(omitted_hp_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == omitted_hp_original_text, "The successful v1 migration should preserve the exact original source bytes in .bak.")
	for suffix in [".tmp", ".bak.tmp", ".bak.prev.tmp"]:
		_check(not omitted_hp_ops.files.has(FAULT_SAVE_PATH + suffix), "Successful migration without squad_hp should remove the %s staging file." % suffix)

	var invalid_v1 := base.duplicate(true)
	invalid_v1["run"]["squad_hp"][2] = "unknown"
	var invalid_ops := _MemoryFileOps.new()
	var invalid_text := JSON.stringify(invalid_v1)
	invalid_ops.files[FAULT_SAVE_PATH] = invalid_text
	var invalid_result: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, invalid_ops)
	_check(not bool(invalid_result.get("ok", true)) and invalid_ops.files == {FAULT_SAVE_PATH: invalid_text}, "Invalid legacy slot HP should reject migration without changing the source or creating sidecars.")

	var rollback_ops := _MemoryFileOps.new()
	rollback_ops.files[FAULT_SAVE_PATH] = original_text
	rollback_ops.fault = "write"
	var rollback_result: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, rollback_ops)
	_check(not bool(rollback_result.get("ok", true)) and rollback_ops.files == {FAULT_SAVE_PATH: original_text}, "A failed staged migration write should leave the version-1 primary byte-for-byte authoritative and remove the temporary file.")

	var recovered_ops := _MemoryFileOps.new()
	recovered_ops.files[FAULT_SAVE_PATH] = "{corrupt primary"
	recovered_ops.files[FAULT_SAVE_PATH + ".bak"] = original_text
	var recovered_before: Dictionary = recovered_ops.files.duplicate(true)
	var recovered_result: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, recovered_ops)
	_check(bool(recovered_result.get("ok", false)) and bool(recovered_result.get("recovered_from_backup", false)) and int(recovered_result.get("migrated_from_version", 0)) == 1, "A version-1 recovery copy should be migrated in memory and reported as a recovery load.")
	_check(recovered_ops.files == recovered_before, "Loading a version-1 recovery copy must not rewrite the corrupt primary or either recovery source.")


func _test_progression_rule_primitives() -> void:
	var profile_text := FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH)
	var parsed_profile: Variant = JSON.parse_string(profile_text)
	_check(typeof(parsed_profile) == TYPE_DICTIONARY, "Proposed progression profile should parse as JSON data.")
	var profile: Dictionary = parsed_profile if typeof(parsed_profile) == TYPE_DICTIONARY else {}
	_check(str(profile.get("status", "")).contains("PROTOTYPE FEASIBILITY TESTING ONLY"), "Progression profile should label its accepted trial values as prototype-only.")
	var influence_rule: Dictionary = profile.get("system_reboot", {})
	_check(PROGRESSION_RULES_SCRIPT.calculate_reboot_influence(24, influence_rule) == 0, "Reboot Influence must remain unavailable below the approved wave-25 eligibility gate.")
	_check(PROGRESSION_RULES_SCRIPT.calculate_reboot_influence(25, influence_rule) == 1, "The provisional wave-step fixture should award its first Influence unit at wave 25.")
	_check(PROGRESSION_RULES_SCRIPT.calculate_reboot_influence(49, influence_rule) == 1, "The provisional wave-step fixture should not advance before the next full wave interval.")
	_check(PROGRESSION_RULES_SCRIPT.calculate_reboot_influence(50, influence_rule) == 2, "The provisional wave-step fixture should award one additional unit at wave 50.")
	_check(PROGRESSION_RULES_SCRIPT.calculate_reboot_influence(125, influence_rule) == 5, "The provisional wave-step fixture should scale by complete intervals through wave 125.")
	_check(PROGRESSION_RULES_SCRIPT.calculate_reboot_influence(125, {"first_eligibility_wave": 25, "waves_per_influence_step": 0, "influence_per_step": 1}) == 0, "Invalid Influence rule intervals must fail closed.")
	var permanent := {"lifetime_influence": 10, "spendable_influence": 4, "research": {"combat": 2}}
	var award_result: Dictionary = PROGRESSION_RULES_SCRIPT.apply_influence_award(permanent, 3)
	_check(bool(award_result.get("ok", false)), "A positive Influence award should be applied to permanent balances.")
	_check(award_result["permanent"]["lifetime_influence"] == 13 and award_result["permanent"]["spendable_influence"] == 7, "An Influence award should raise lifetime and spendable balances equally.")
	_check(permanent["lifetime_influence"] == 10 and permanent["spendable_influence"] == 4, "Awarding Influence must not mutate its input permanent state.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.apply_influence_award(permanent, 0).get("ok", false)), "Zero Influence awards must be rejected.")
	var lifetime_rule: Dictionary = profile.get("lifetime_influence_benefit", {})
	var bonus_at_zero: Dictionary = PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(0, lifetime_rule)
	var bonus_at_one: Dictionary = PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(1, lifetime_rule)
	var bonus_at_25: Dictionary = PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(25, lifetime_rule)
	var bonus_at_100: Dictionary = PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(100, lifetime_rule)
	var bonus_at_cap: Dictionary = PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(2500, lifetime_rule)
	var bonus_over_cap: Dictionary = PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(100000, lifetime_rule)
	_check(bonus_at_zero.get("bonus_fraction", -1.0) == 0.0 and is_equal_approx(float(bonus_at_one.get("bonus_fraction", -1.0)), 0.005), "Lifetime power bonus should start at zero and follow the configured first-point bonus.")
	_check(is_equal_approx(float(bonus_at_25.get("bonus_fraction", -1.0)), 0.025) and is_equal_approx(float(bonus_at_100.get("bonus_fraction", -1.0)), 0.05), "Lifetime power bonus should have diminishing returns under the square-root rule.")
	_check(is_equal_approx(float(bonus_at_cap.get("bonus_fraction", -1.0)), 0.25) and is_equal_approx(float(bonus_over_cap.get("bonus_fraction", -1.0)), 0.25), "Lifetime power bonus should stop increasing at the configured 25% cap.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(-1, lifetime_rule).get("ok", true)), "Negative lifetime Influence must be rejected for passive bonus calculation.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.calculate_lifetime_power_bonus(10, {"coefficient": 0.005, "influence_exponent": 0.5}).get("ok", true)), "An incomplete passive bonus profile must fail closed.")
	var evolution_profile: Dictionary = profile.get("evolution", {})
	var evolution_gates: Dictionary = evolution_profile.get("gates", {})
	var evolution_gate: Dictionary = evolution_gates.get("Adapted Form", {})
	_check(evolution_gates.get("Adapted Form", {}).get("minimum_cleared_wave", 0) == 25 and evolution_gate.get("material_costs", {}).get("evolution_data", 0) == 1, "Approved prototype Adapted Form gate should be data-driven: wave 25 plus one Evolution Data.")
	_check(evolution_gates.get("Signature Form", {}).get("minimum_cleared_wave", 0) == 75 and evolution_gates["Signature Form"].get("material_costs", {}).get("evolution_data", 0) == 2, "Approved prototype Signature Form gate should be data-driven: wave 75 plus two Evolution Data.")
	_check(evolution_gates.get("Requiem Form", {}).get("minimum_cleared_wave", 0) == 125 and evolution_gates["Requiem Form"].get("material_costs", {}).get("evolution_data", 0) == 3, "Approved prototype Requiem Form gate should be data-driven: wave 125 plus three Evolution Data.")
	var short_inventory := {"evolution_data": 0}
	var milestone_missing: Dictionary = PROGRESSION_RULES_SCRIPT.evaluate_evolution_gate(24, short_inventory, evolution_gate)
	_check(not bool(milestone_missing.get("eligible", false)) and not bool(milestone_missing.get("milestone_met", true)), "Evolution must remain locked before its configured wave milestone.")
	var material_missing: Dictionary = PROGRESSION_RULES_SCRIPT.evaluate_evolution_gate(25, short_inventory, evolution_gate)
	_check(not bool(material_missing.get("eligible", false)) and material_missing.get("missing_materials", {}).get("evolution_data", 0) == 1, "Evolution must report missing earned materials even after its milestone is reached.")
	var complete_inventory := {"evolution_data": 1, "unrelated_material": 9}
	var purchase: Dictionary = PROGRESSION_RULES_SCRIPT.consume_evolution_materials(25, complete_inventory, evolution_gate)
	_check(bool(purchase.get("ok", false)), "Evolution should be purchasable when both milestone and material gates are met.")
	_check(purchase["inventory"]["evolution_data"] == 0 and purchase["inventory"]["unrelated_material"] == 9, "Evolution should deduct only configured materials and preserve unrelated inventory.")
	_check(complete_inventory["evolution_data"] == 1, "Evolution material consumption must not mutate its input inventory.")
	var rejected_purchase: Dictionary = PROGRESSION_RULES_SCRIPT.consume_evolution_materials(25, short_inventory, evolution_gate)
	_check(not bool(rejected_purchase.get("ok", true)) and rejected_purchase["inventory"] == short_inventory, "A failed evolution purchase must not partially consume materials.")
	var invalid_gate: Dictionary = PROGRESSION_RULES_SCRIPT.evaluate_evolution_gate(125, complete_inventory, {"minimum_cleared_wave": 25})
	_check(not bool(invalid_gate.get("valid", true)), "Evolution gates missing their material requirement must fail validation.")
	var permanent_gate_state := {"highest_wave_ever": 75, "evolution_materials": {"evolution_data": 2}}
	var permanent_gate: Dictionary = PROGRESSION_RULES_SCRIPT.evaluate_permanent_evolution_gate(permanent_gate_state, {"minimum_cleared_wave": 75, "material_costs": {"evolution_data": 2}})
	_check(bool(permanent_gate.get("eligible", false)), "Permanent evolution gate should use first-cleared-ever milestones and shared permanent materials.")
	var evolution_state := {"highest_wave_ever": 125, "evolution_materials": {"evolution_data": 6}, "evolution": {"breaker_tier": "Origin Form"}}
	var breaker_unlock: Dictionary = EVOLUTION_SERVICE_SCRIPT.purchase_next_tier(evolution_state, "breaker", profile)
	_check(bool(breaker_unlock.get("ok", false)) and breaker_unlock["unlocked_tier"] == "Adapted Form", "Evolution service should record the next eligible BREAKER tier.")
	_check(breaker_unlock["permanent"]["evolution"]["breaker_tier"] == "Adapted Form" and breaker_unlock["permanent"]["evolution_materials"]["evolution_data"] == 5, "Evolution purchase should atomically record tier and consume only its configured material cost.")
	_check(evolution_state["evolution"]["breaker_tier"] == "Origin Form" and evolution_state["evolution_materials"]["evolution_data"] == 6, "Evolution transactions must leave source permanent state untouched.")
	var military_unlock: Dictionary = EVOLUTION_SERVICE_SCRIPT.purchase_next_tier(breaker_unlock["permanent"], "breaker", profile)
	var apex_unlock: Dictionary = EVOLUTION_SERVICE_SCRIPT.purchase_next_tier(military_unlock.get("permanent", {}), "breaker", profile)
	_check(bool(military_unlock.get("ok", false)) and military_unlock["unlocked_tier"] == "Signature Form" and bool(apex_unlock.get("ok", false)) and apex_unlock["unlocked_tier"] == "Requiem Form", "Evolution service should follow the approved tier order and per-tier costs.")
	_check(apex_unlock["permanent"]["evolution_materials"]["evolution_data"] == 0 and bool(EVOLUTION_SERVICE_SCRIPT.get_next_tier(apex_unlock["permanent"], "breaker").get("complete", false)), "Apex unlock should consume the remaining configured cost and reject further purchases as complete.")
	_check(not bool(EVOLUTION_SERVICE_SCRIPT.purchase_next_tier(evolution_state, "not_a_recruit", profile).get("ok", true)), "Evolution service should reject IDs outside the approved founding roster.")
	var locked_state := {"highest_wave_ever": 24, "evolution_materials": {"evolution_data": 9}, "evolution": {"breaker_tier": "Origin Form"}}
	_check(not bool(EVOLUTION_SERVICE_SCRIPT.purchase_next_tier(locked_state, "breaker", profile).get("ok", true)) and locked_state["evolution_materials"]["evolution_data"] == 9, "Evolution should not consume materials before the permanent milestone is met.")
	var all_roster_keys_valid := true
	for recruit_id in EVOLUTION_SERVICE_SCRIPT.APPROVED_RECRUIT_IDS:
		all_roster_keys_valid = all_roster_keys_valid and bool(EVOLUTION_SERVICE_SCRIPT.get_next_tier({"evolution": {}}, recruit_id).get("ok", false))
	_check(all_roster_keys_valid, "Tier progression records should support all twelve approved roster IDs without inventing recruit data.")
	var claim_source := {"evolution_materials": {"evolution_data": 2}}
	var first_claim: Dictionary = PROGRESSION_RULES_SCRIPT.claim_first_clear_materials(claim_source, "district.neon_row", {"evolution_data": 3})
	_check(bool(first_claim.get("ok", false)) and first_claim["permanent"]["evolution_materials"]["evolution_data"] == 5, "A deterministic first-clear claim should add its configured material amount to the shared roster inventory.")
	_check(first_claim["permanent"]["first_clear_material_claims"] == ["district.neon_row"] and claim_source == {"evolution_materials": {"evolution_data": 2}}, "A first-clear claim should persist its unique ID without mutating the source state.")
	var duplicate_claim: Dictionary = PROGRESSION_RULES_SCRIPT.claim_first_clear_materials(first_claim["permanent"], "district.neon_row", {"evolution_data": 3})
	_check(not bool(duplicate_claim.get("ok", true)) and bool(duplicate_claim.get("already_claimed", false)), "A permanent first-clear claim ID must reject duplicate material awards.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.claim_first_clear_materials(claim_source, "district.neon_row", {"evolution_data": 0}).get("ok", true)), "First-clear rewards must reject non-positive material amounts.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.claim_first_clear_materials(claim_source, " district.neon_row", {"evolution_data": 1}).get("ok", true)), "First-clear claim IDs with non-canonical surrounding whitespace must be rejected.")
	var whitespace_ledger := {"first_clear_material_claims": ["district.neon_row "], "evolution_materials": {}}
	_check(not bool(PROGRESSION_RULES_SCRIPT.claim_first_clear_materials(whitespace_ledger, "district.neon_row", {"evolution_data": 1}).get("ok", true)), "Existing non-canonical first-clear IDs must not allow a duplicate normalized claim.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.claim_first_clear_materials(claim_source, "district.neon_row", {" evolution_data": 1}).get("ok", true)), "First-clear reward material IDs with surrounding whitespace must be rejected.")
	_check(not bool(PROGRESSION_RULES_SCRIPT.claim_first_clear_materials({"evolution_materials": {"evolution_data ": 1}}, "district.neon_row", {"evolution_data": 1}).get("ok", true)), "Existing material inventory IDs with surrounding whitespace must be rejected.")


func _test_research_transactions() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/progression/research_catalog.json"))
	_check(typeof(catalog.get("branches", null)) == TYPE_ARRAY and catalog["branches"].size() == 4, "Research catalog should preserve the four approved branch identities.")
	_check(str(catalog.get("status", "")).contains("FRAMEWORK ONLY"), "Research catalog should clearly state that no node balance is approved yet.")
	_check(bool(RESEARCH_SERVICE_SCRIPT.validate_catalog(catalog).get("ok", false)), "The approved empty research catalog should pass structural validation.")
	_check(not bool(RESEARCH_SERVICE_SCRIPT.validate_catalog([]).get("ok", true)), "A non-object research catalog must fail closed.")
	_check(not bool(RESEARCH_SERVICE_SCRIPT.purchase({"spendable_influence": 10}, "combat.protocols.test", catalog).get("ok", true)), "Empty research branches must expose no unapproved purchaseable nodes.")
	var fixture := {
		"branches": [
			{"id": "combat_protocols", "nodes": [
				{"id": "combat.protocols.test", "influence_cost": 2, "max_rank": 2, "prerequisites": []},
				{"id": "combat.protocols.advanced_test", "influence_cost": 3, "max_rank": 1, "prerequisites": ["combat.protocols.test"]}
			]}
		]
	}
	_check(bool(RESEARCH_SERVICE_SCRIPT.validate_catalog(fixture).get("ok", false)), "A valid acyclic catalog with a configured prerequisite should pass validation.")
	var valid_node_a := {"id": "node.a", "influence_cost": 2, "max_rank": 2, "prerequisites": []}
	var valid_node_b := {"id": "node.b", "influence_cost": 3, "max_rank": 1, "prerequisites": ["node.a"]}
	var duplicate_node_id_catalog := {"branches": [{"id": "branch.a", "nodes": [valid_node_a]}, {"id": "branch.b", "nodes": [valid_node_a.duplicate(true)]}]}
	var duplicate_branch_id_catalog := {"branches": [{"id": "branch.a", "nodes": []}, {"id": "branch.a", "nodes": []}]}
	var cycle_catalog := {"branches": [{"id": "branch.a", "nodes": [
		{"id": "node.a", "influence_cost": 1, "max_rank": 1, "prerequisites": ["node.b"]},
		{"id": "node.b", "influence_cost": 1, "max_rank": 1, "prerequisites": ["node.a"]}
	]}]}
	var invalid_catalog_cases: Array[Dictionary] = [
		{"name": "missing branches", "value": {}},
		{"name": "non-array branches", "value": {"branches": {}}},
		{"name": "non-object branch", "value": {"branches": ["branch"]}},
		{"name": "non-string branch ID", "value": _research_catalog_with_nodes(7, [])},
		{"name": "empty branch ID", "value": _research_catalog_with_nodes("", [])},
		{"name": "padded branch ID", "value": _research_catalog_with_nodes(" branch.a ", [])},
		{"name": "duplicate branch IDs", "value": duplicate_branch_id_catalog},
		{"name": "non-array node list", "value": {"branches": [{"id": "branch.a", "nodes": {}}]}},
		{"name": "non-object node", "value": _research_catalog_with_nodes("branch.a", [7])},
		{"name": "non-string node ID", "value": _research_catalog_with_nodes("branch.a", [{"id": 7, "influence_cost": 1, "max_rank": 1}])},
		{"name": "empty node ID", "value": _research_catalog_with_nodes("branch.a", [{"id": "", "influence_cost": 1, "max_rank": 1}])},
		{"name": "padded node ID", "value": _research_catalog_with_nodes("branch.a", [{"id": " node.a ", "influence_cost": 1, "max_rank": 1}])},
		{"name": "duplicate node IDs", "value": duplicate_node_id_catalog},
		{"name": "missing Influence cost", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "max_rank": 1}])},
		{"name": "zero Influence cost", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 0, "max_rank": 1}])},
		{"name": "fractional Influence cost", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1.5, "max_rank": 1}])},
		{"name": "non-numeric Influence cost", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": "1", "max_rank": 1}])},
		{"name": "missing maximum rank", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1}])},
		{"name": "zero maximum rank", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 0}])},
		{"name": "fractional maximum rank", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 1.5}])},
		{"name": "non-array prerequisites", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 1, "prerequisites": "node.b"}])},
		{"name": "non-string prerequisite", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 1, "prerequisites": [7]}])},
		{"name": "padded prerequisite ID", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 1, "prerequisites": [" node.b "]}])},
		{"name": "self prerequisite", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 1, "prerequisites": ["node.a"]}])},
		{"name": "duplicate prerequisite", "value": _research_catalog_with_nodes("branch.a", [valid_node_a.duplicate(true), {"id": "node.b", "influence_cost": 1, "max_rank": 1, "prerequisites": ["node.a", "node.a"]}])},
		{"name": "unconfigured prerequisite", "value": _research_catalog_with_nodes("branch.a", [{"id": "node.a", "influence_cost": 1, "max_rank": 1, "prerequisites": ["missing.node"]}])},
		{"name": "cyclic prerequisites", "value": cycle_catalog}
	]
	for invalid_case in invalid_catalog_cases:
		_check(not bool(RESEARCH_SERVICE_SCRIPT.validate_catalog(invalid_case["value"]).get("ok", true)), "Malformed research catalog case should fail closed: %s." % str(invalid_case["name"]))
	var permanent := {"spendable_influence": 4, "lifetime_influence": 7, "research": {"combat": 1}, "research_nodes": {}}
	var run := {"credits": 42, "wave": 4, "highest_cleared_wave": 3, "recruits": {"breaker": {"level": 2}}}
	var settings := {"master_volume": 0.5}
	var prerequisite_block: Dictionary = RESEARCH_SERVICE_SCRIPT.purchase(permanent, "combat.protocols.advanced_test", fixture)
	_check(not bool(prerequisite_block.get("ok", true)), "Research prerequisites should be enforced before a purchase.")
	var first_purchase: Dictionary = RESEARCH_SERVICE_SCRIPT.purchase(permanent, "combat.protocols.test", fixture)
	_check(bool(first_purchase.get("ok", false)) and first_purchase["permanent"]["research_nodes"]["combat.protocols.test"] == 1 and first_purchase["permanent"]["spendable_influence"] == 2, "Research purchase should record one node rank and deduct spendable Influence.")
	_check(permanent["spendable_influence"] == 4 and permanent["research_nodes"].is_empty(), "Pure research purchase must not mutate permanent state in place.")
	var insufficient_state := {"spendable_influence": 1, "research_nodes": {}}
	_check(not bool(RESEARCH_SERVICE_SCRIPT.purchase(insufficient_state, "combat.protocols.test", fixture).get("ok", true)) and insufficient_state["spendable_influence"] == 1, "Insufficient Influence must leave research state unchanged.")
	var duplicate_fixture := {"branches": [fixture["branches"][0], {"id": "other", "nodes": [fixture["branches"][0]["nodes"][0]]}]}
	_check(not bool(RESEARCH_SERVICE_SCRIPT.purchase(permanent, "combat.protocols.test", duplicate_fixture).get("ok", true)), "Duplicate research IDs across branches must fail closed.")
	var malformed_fixture := {"branches": [{"id": "combat_protocols", "nodes": [{"id": "bad", "influence_cost": 0, "max_rank": 1}]}]}
	_check(not bool(RESEARCH_SERVICE_SCRIPT.purchase(permanent, "bad", malformed_fixture).get("ok", true)), "Research definitions with non-positive costs must fail closed.")
	research_save_call_count = 0
	var failed_save: Dictionary = RESEARCH_SERVICE_SCRIPT.purchase_and_save(permanent, run, settings, "combat.protocols.test", fixture, Callable(self, "_reject_research_save"), "res://tests/_research_fail.json")
	_check(not bool(failed_save.get("ok", true)) and int(failed_save.get("save_error", OK)) != OK, "Failed research persistence should reject the transaction.")
	_check(permanent["spendable_influence"] == 4 and permanent["research_nodes"].is_empty(), "Failed save must not mutate permanent research or Influence.")
	var saved_purchase: Dictionary = RESEARCH_SERVICE_SCRIPT.purchase_and_save(permanent, run, settings, "combat.protocols.test", fixture, Callable(self, "_capture_research_save"), "res://tests/_research_success.json")
	_check(bool(saved_purchase.get("ok", false)) and research_save_call_count == 2, "Successful research purchase should commit through the injected save operation.")
	_check(research_saved_permanent.get("spendable_influence", -1) == 2 and research_saved_permanent.get("research_nodes", {}).get("combat.protocols.test", 0) == 1, "Save callback should receive the candidate permanent purchase state.")
	_check(research_saved_run == run and research_saved_settings == settings and saved_purchase["run"] == run and saved_purchase["settings"] == settings, "Research transaction must preserve run progress and settings unchanged.")
	var invalid_payload := {"save_version": SAVE_SCRIPT.SAVE_VERSION, "permanent": {"research_nodes": {"invalid": 1.5}}, "run": {"credits": 0, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1}}}, "settings": {}}
	_check(not bool(SAVE_SCRIPT._parse_and_validate(JSON.stringify(invalid_payload)).get("ok", true)), "Save validation must reject fractional research node ranks.")
	print("Research framework: four empty approved branches; prototype transaction and save-before-apply tests passed without gameplay nodes.")


func _research_catalog_with_nodes(branch_id: Variant, nodes: Array) -> Dictionary:
	return {"branches": [{"id": branch_id, "nodes": nodes}]}


func _reject_research_save(_permanent: Dictionary, _run: Dictionary, _settings: Dictionary, _path: String) -> Error:
	research_save_call_count += 1
	return ERR_CANT_CREATE


func _capture_research_save(permanent: Dictionary, run: Dictionary, settings: Dictionary, _path: String) -> Error:
	research_save_call_count += 1
	research_saved_permanent = permanent.duplicate(true)
	research_saved_run = run.duplicate(true)
	research_saved_settings = settings.duplicate(true)
	return OK


func _test_offline_earnings_calculation() -> void:
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH))
	var wave_definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(WAVE_PROFILE_PATH))
	var rules: Dictionary = profile.get("offline_earnings", {})
	_check(str(rules.get("status", "")).contains("PROTOTYPE FEASIBILITY TESTING ONLY"), "Offline earnings must label its configurable trial rate as prototype-only.")
	_check(int(rules.get("cap_seconds", 0)) == 28800 and not bool(rules.get("wave_advancement", true)), "Offline earnings must preserve the eight-hour cap and prohibit offline wave advancement.")
	var saved_run := {"credits": 50, "wave": 40, "highest_cleared_wave": 25, "recruits": {"breaker": {"level": 4}}, "squad_hp": [120.0, 91.0, 83.0, 74.0, 65.0, 56.0], "offline_claim_unix": 100000}
	var one_hour: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(saved_run, wave_definition, rules, 103600)
	_check(bool(one_hour.get("ok", false)) and one_hour.get("status", "") == "claimed" and one_hour.get("credits_awarded", 0) == 108, "One offline hour should use one ordinary reward from saved holding wave 25.")
	_check(one_hour.get("run", {}).get("credits", -1) == 158 and one_hour.get("run", {}).get("wave", -1) == 40 and one_hour.get("run", {}).get("highest_cleared_wave", -1) == 25, "Offline credit claims must change credits without changing the current or cleared wave.")
	_check(one_hour.get("run", {}).get("recruits", {}) == saved_run["recruits"] and one_hour.get("run", {}).get("squad_hp", []) == saved_run["squad_hp"], "Offline claims must preserve recruit level and squad HP.")
	_check(saved_run["credits"] == 50 and saved_run["offline_claim_unix"] == 100000, "Offline calculation must not mutate the saved source run.")
	var repeated: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(one_hour.get("run", {}), wave_definition, rules, 103600)
	_check(bool(repeated.get("ok", false)) and repeated.get("credits_awarded", -1) == 0 and not bool(repeated.get("should_save", true)), "Loading the same claim timestamp again must not award duplicate credits.")
	var capped_run := saved_run.duplicate(true)
	var capped: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(capped_run, wave_definition, rules, 136000)
	_check(bool(capped.get("ok", false)) and capped.get("capped_seconds", 0) == 28800 and capped.get("credits_awarded", 0) == 864, "Ten elapsed offline hours must award at most eight ordinary holding-wave rewards.")
	var legacy_run := saved_run.duplicate(true)
	legacy_run.erase("offline_claim_unix")
	var baseline: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(legacy_run, wave_definition, rules, 200000)
	_check(baseline.get("status", "") == "baseline_created" and baseline.get("credits_awarded", -1) == 0 and baseline["run"]["offline_claim_unix"] == 200000, "Legacy saves without an offline baseline must start tracking without retroactive earnings.")
	var clock_run := saved_run.duplicate(true)
	clock_run["offline_claim_unix"] = 105000
	var clock_reset: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(clock_run, wave_definition, rules, 104000)
	_check(clock_reset.get("status", "") == "clock_reset" and clock_reset.get("credits_awarded", -1) == 0 and clock_reset["run"]["offline_claim_unix"] == 104000, "A future-dated offline timestamp must reset its baseline without crediting time.")
	var no_fractional_loss: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(saved_run, wave_definition, rules, 100001)
	_check(no_fractional_loss.get("status", "") == "no_reward" and no_fractional_loss["run"]["offline_claim_unix"] == 100000, "A sub-credit interval must retain its prior timestamp so fractional time is not discarded.")
	var invalid_rules := rules.duplicate(true)
	invalid_rules["ordinary_rewards_per_hour"] = 100.0
	_check(not bool(OFFLINE_EARNINGS_SCRIPT.apply_claim(saved_run, wave_definition, invalid_rules, 103600).get("ok", true)), "An out-of-range offline rate must fail closed.")
	invalid_rules = rules.duplicate(true)
	invalid_rules["cap_seconds"] = 28801
	_check(not bool(OFFLINE_EARNINGS_SCRIPT.apply_claim(saved_run, wave_definition, invalid_rules, 103600).get("ok", true)), "An offline time cap above eight hours must fail closed.")


func _test_material_reward_pipeline() -> void:
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH))
	var reward_policy: Dictionary = profile["evolution_material_policy"]
	var permanent := {"evolution_materials": {}, "first_clear_material_claims": []}
	var clear_one: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(permanent, 1, "", reward_policy)
	_check(bool(clear_one.get("ok", false)) and clear_one["total_amount"] == 1 and clear_one["first_clear_amount"] == 0, "An ordinary encounter clear should award the configured repeatable amount without creating a first-clear claim.")
	var district_clear: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(clear_one["permanent"], 25, "", reward_policy)
	_check(bool(district_clear.get("ok", false)) and district_clear["total_amount"] == 2 and district_clear["first_clear_amount"] == 1 and district_clear["claimed_ids"] == ["district.undercity"], "The district first-clear milestone should add its bonus to the repeatable wave-clear reward.")
	var district_replay: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(district_clear["permanent"], 25, "", reward_policy)
	_check(bool(district_replay.get("ok", false)) and district_replay["total_amount"] == 1 and district_replay["claimed_ids"].is_empty(), "A repeated district milestone should remain repeatably rewardable without duplicating its permanent first-clear bonus.")
	var boss_clear: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(district_replay["permanent"], 26, "boss.test_warden", reward_policy)
	_check(bool(boss_clear.get("ok", false)) and boss_clear["total_amount"] == 2 and boss_clear["claimed_ids"] == ["boss.test_warden"], "A named boss first clear should add one extra material to its repeatable encounter reward.")
	var boss_replay: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(boss_clear["permanent"], 26, "boss.test_warden", reward_policy)
	_check(bool(boss_replay.get("ok", false)) and boss_replay["total_amount"] == 1 and boss_replay["claimed_ids"].is_empty(), "A boss replay should retain its repeatable payout without duplicating its boss first-clear bonus.")
	_check(boss_replay["permanent"]["evolution_materials"]["evolution_data"] == 7, "Repeatable payouts plus district/boss bonuses should accumulate in the shared roster inventory.")
	_check(permanent["evolution_materials"].is_empty() and permanent["first_clear_material_claims"].is_empty(), "Applying material rewards should leave the source permanent state unchanged.")
	var invalid_policy := reward_policy.duplicate(true)
	invalid_policy["repeatable_per_clear"] = 0
	var invalid_result: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(permanent, 1, "", invalid_policy)
	_check(not bool(invalid_result.get("ok", true)) and permanent["evolution_materials"].is_empty(), "Malformed material payout configuration should fail without mutating permanent state.")
	var all_districts := permanent.duplicate(true)
	for milestone in reward_policy["district_milestones"]:
		var district_result: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(all_districts, int(milestone["wave"]), "", reward_policy)
		_check(bool(district_result.get("ok", false)) and district_result["claimed_ids"].has(str(milestone["claim_id"])), "District endpoint %d should claim its configured permanent reward exactly once." % int(milestone["wave"]))
		all_districts = district_result["permanent"]
	_check(all_districts["first_clear_material_claims"].size() == 5, "The five supplied district endpoints should each have a distinct permanent first-clear claim.")


func _test_reboot_transaction() -> void:
	var profile_text := FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH)
	var profile: Dictionary = JSON.parse_string(profile_text)
	var permanent := {
		"lifetime_influence": 12,
		"spendable_influence": 5,
		"highest_wave_ever": 25,
		"research": {"combat": 2},
		"evolution": {"breaker_tier": "Adapted Form"},
		"evolution_materials": {"evolution_data": 3},
		"first_clear_material_claims": ["district.undercity"],
		"unlocks": ["breaker"]
	}
	var run := {
		"credits": 742,
		"wave": 54,
		"highest_cleared_wave": 50,
		"recruits": {"breaker": {"level": 17}, "spark": {"level": 9}},
		"squad_hp": [2.0, 14.0, 0.0, 31.0, 18.0, 6.0],
		"last_event": "test-only state"
	}
	var full_hp: Array[float] = [120.0, 90.0, 80.0, 110.0, 85.0, 75.0]
	var result: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(permanent, run, profile, full_hp)
	_check(bool(result.get("ok", false)), "Manual Reboot should succeed after the approved first-clear eligibility checkpoint.")
	_check(result.get("award", 0) == 2, "Reboot should calculate the proposed award from the run's highest-cleared wave.")
	_check(result["permanent"]["lifetime_influence"] == 14 and result["permanent"]["spendable_influence"] == 7, "Reboot should add its award to both lifetime and spendable Influence.")
	_check(result["permanent"]["research"] == permanent["research"] and result["permanent"]["evolution"] == permanent["evolution"] and result["permanent"]["evolution_materials"] == permanent["evolution_materials"] and result["permanent"]["first_clear_material_claims"] == permanent["first_clear_material_claims"] and result["permanent"]["highest_wave_ever"] == 50 and result["permanent"]["unlocks"] == permanent["unlocks"], "Reboot should preserve permanent research, evolution, materials, first-clear claims, recruit unlocks, and update the first-cleared-ever milestone.")
	var evolution_after_reboot: Dictionary = PROGRESSION_RULES_SCRIPT.evaluate_permanent_evolution_gate(result["permanent"], {"minimum_cleared_wave": 25, "material_costs": {"evolution_data": 3}})
	_check(bool(evolution_after_reboot.get("eligible", false)), "A first-cleared evolution milestone should remain satisfied after Reboot, while material cost is still checked.")
	_check(result["run"]["credits"] == 0 and result["run"]["wave"] == 1 and result["run"]["highest_cleared_wave"] == 0, "Reboot should reset run credits, current wave, and run high-water mark.")
	_check(result["run"]["recruits"]["breaker"]["level"] == 1 and result["run"]["recruits"]["spark"]["level"] == 1, "Reboot should reset every recruit run-level without deleting roster entries.")
	_check(result["run"]["squad_hp"] == full_hp and result["run"]["last_event"] == run["last_event"], "Reboot should restore supplied full squad HP while preserving unrelated run data.")
	_check(permanent["lifetime_influence"] == 12 and run["wave"] == 54 and run["highest_cleared_wave"] == 50, "Reboot transaction should not mutate its input states.")
	var second_reboot: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(result["permanent"], result["run"], profile, full_hp)
	_check(not bool(second_reboot.get("ok", true)), "A Rebooted run must earn the eligibility milestone again before another award.")
	var ineligible := run.duplicate(true)
	ineligible["highest_cleared_wave"] = 24
	var rejected: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(permanent, ineligible, profile, full_hp)
	_check(not bool(rejected.get("ok", true)) and not rejected.has("permanent") and not rejected.has("run"), "An ineligible Reboot must not award or reset state.")
	var missing_hp: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(permanent, run, profile)
	_check(not bool(missing_hp.get("ok", true)), "A saved squad Reboot must require supplied full-health values.")
	var malformed_hp := run.duplicate(true)
	malformed_hp["squad_hp"] = "not-an-array"
	var malformed: Dictionary = REBOOT_SERVICE_SCRIPT.apply_reboot(permanent, malformed_hp, profile, full_hp)
	_check(not bool(malformed.get("ok", true)), "Malformed saved squad health must not crash or permit Reboot.")
	var file_ops := _MemoryFileOps.new()
	var persisted_data := _valid_test_save_payload()
	persisted_data["permanent"] = permanent.duplicate(true)
	var persistable_run := run.duplicate(true)
	persistable_run["wave"] = 50
	persistable_run["highest_cleared_wave"] = 50
	persisted_data["run"] = persistable_run
	persisted_data["settings"] = {"master_volume": 0.42, "window_mode": "windowed"}
	var save_path := "res://tests/fake_reboot_transaction.json"
	file_ops.files[save_path] = JSON.stringify(persisted_data)
	var persisted_reboot: Dictionary = REBOOT_SERVICE_SCRIPT._reboot_saved_game_with_file_ops(save_path, profile, full_hp, file_ops)
	_check(bool(persisted_reboot.get("ok", false)), "Reboot should load a wave-50 save and atomically persist its two-Influence award and reset.")
	var persisted_load: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(save_path, file_ops)
	_check(bool(persisted_load.get("ok", false)) and int(persisted_load["data"]["permanent"]["lifetime_influence"]) == 14 and persisted_load["data"]["run"]["wave"] == 1 and persisted_load["data"]["run"]["highest_cleared_wave"] == 0, "One committed save should contain both the two-Influence award and reset run state.")
	_check(persisted_load["data"]["permanent"]["first_clear_material_claims"] == ["district.undercity"] and persisted_load["data"]["settings"] == persisted_data["settings"], "Reboot save should preserve the permanent reward ledger and user settings.")
	var saved_once: String = file_ops.files[save_path]
	var duplicate_persisted_reboot: Dictionary = REBOOT_SERVICE_SCRIPT._reboot_saved_game_with_file_ops(save_path, profile, full_hp, file_ops)
	_check(not bool(duplicate_persisted_reboot.get("ok", true)) and file_ops.files[save_path] == saved_once, "A second Reboot attempt should reload the reset state and avoid a duplicate award.")
	var fail_ops := _MemoryFileOps.new()
	fail_ops.files[save_path] = JSON.stringify(persisted_data)
	fail_ops.fault = "write"
	var failed_commit: Dictionary = REBOOT_SERVICE_SCRIPT._reboot_saved_game_with_file_ops(save_path, profile, full_hp, fail_ops)
	_check(not bool(failed_commit.get("ok", true)) and fail_ops.files[save_path] == JSON.stringify(persisted_data), "A failed Reboot save must leave the previous valid save unchanged.")
	var partial_reboot_ops := _MemoryFileOps.new()
	partial_reboot_ops.files[FAULT_SAVE_PATH] = JSON.stringify(persisted_data)
	var partial_reboot_baseline: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, partial_reboot_ops)
	partial_reboot_ops.fault = "partial_commit"
	var partial_reboot: Dictionary = REBOOT_SERVICE_SCRIPT._reboot_saved_game_with_file_ops(FAULT_SAVE_PATH, profile, full_hp, partial_reboot_ops)
	var partial_reboot_load: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, partial_reboot_ops)
	_check(not bool(partial_reboot.get("ok", true)), "A partial commit while saving Reboot should report that the transaction failed.")
	_check(bool(partial_reboot_baseline.get("ok", false)) and bool(partial_reboot_load.get("ok", false)) and partial_reboot_load["data"]["permanent"] == partial_reboot_baseline["data"]["permanent"] and partial_reboot_load["data"]["run"] == partial_reboot_baseline["data"]["run"], "After a partial Reboot commit, loading must return the previously committed run and permanent state.")
	_check(not partial_reboot_ops.files.has(FAULT_SAVE_PATH + ".tmp") and not partial_reboot_ops.files.has(FAULT_SAVE_PATH + ".bak.tmp"), "A failed partial Reboot commit should leave no staged save artifacts.")
	var disk_write: Error = SAVE_SCRIPT.save_game(permanent, persistable_run, persisted_data["settings"], _test_disk_save_path())
	_check(disk_write == OK, "Public Reboot integration test should stage a disposable wave-50 disk save.")
	var disk_reboot: Dictionary = REBOOT_SERVICE_SCRIPT.reboot_saved_game(_test_disk_save_path(), profile, full_hp)
	var disk_loaded: Dictionary = SAVE_SCRIPT.load_game(_test_disk_save_path())
	_check(bool(disk_reboot.get("ok", false)) and bool(disk_loaded.get("ok", false)) and int(disk_loaded["data"]["permanent"]["lifetime_influence"]) == 14 and disk_loaded["data"]["run"]["wave"] == 1, "Public save-backed Reboot should persist the second reward band through real disposable disk I/O.")
	var disk_second_reboot: Dictionary = REBOOT_SERVICE_SCRIPT.reboot_saved_game(_test_disk_save_path(), profile, full_hp)
	_check(not bool(disk_second_reboot.get("ok", true)), "A second public Reboot call should load disk state and remain ineligible.")
	_cleanup_test_save_files()


func _test_lifetime_influence_combat_modifier() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var base_attack: Array[float] = []
	var base_hp: Array[float] = []
	var base_max_hp: Array[float] = []
	for ally in director.allies:
		base_attack.append(float(ally["base_attack_power"]))
		base_hp.append(float(ally["hp"]))
		base_max_hp.append(float(ally["max_hp"]))
	var enemy_attack_before := director._enemy_attack_power()
	_check(director.set_lifetime_influence(100), "CombatDirector should accept a valid saved lifetime Influence value.")
	_check(is_equal_approx(director.lifetime_power_bonus_fraction, 0.05), "CombatDirector should derive the configured 5% bonus at 100 lifetime Influence.")
	var expected_damage_total := 0.0
	for index in range(director.allies.size()):
		var ally: Dictionary = director.allies[index]
		_check(is_equal_approx(float(ally["attack_power"]), base_attack[index] * 1.05), "The permanent bonus should multiply each ally's authoritative outgoing attack power.")
		_check(is_equal_approx(float(ally["hp"]), base_hp[index]) and is_equal_approx(float(ally["max_hp"]), base_max_hp[index]), "The permanent damage bonus must not change squad HP or defense stats.")
		ally["x"] = director.enemy_x - float(ally["engagement_distance"])
		ally["attack_elapsed"] = float(ally["attack_interval"])
		expected_damage_total += float(ally["attack_power"])
	director.enemy_hp = 10000.0
	var enemy_hp_before: float = director.enemy_hp
	director._simulate_allies(director.FIXED_STEP)
	_check(is_equal_approx(enemy_hp_before - director.enemy_hp, expected_damage_total), "Simulation damage should use the bonus-adjusted authoritative attack powers.")
	_check(is_equal_approx(director._enemy_attack_power(), enemy_attack_before), "The lifetime damage bonus must not affect enemy damage.")
	_check(director.set_lifetime_influence(2500) and is_equal_approx(director.lifetime_power_bonus_fraction, 0.25), "CombatDirector should apply the configured 25% cap at the cap boundary.")
	_check(not director.set_lifetime_influence(-1) and is_equal_approx(director.lifetime_power_bonus_fraction, 0.25), "Invalid lifetime Influence must not alter the active combat bonus.")
	director.queue_free()


func _cleanup_test_save_files() -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var path: String = _test_disk_save_path() + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _test_disk_save_path() -> String:
	return ProjectSettings.globalize_path(TEST_SAVE_PATH)


func _test_combat_reward_and_order() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	_check(director.economy.upgrade_cost({}, 1) == 20 and director.economy.upgrade_cost({}, 2) == 22, "When the cost growth field is absent, the approved 1.12 trial default should price level 1 at 20 and level 2 at 22.")
	var events: Array[String] = []
	var structured_clear_events: Array[Dictionary] = []
	director.event_logged.connect(func(message: String): events.append(message))
	director.enemy_def["boss_id"] = "boss.test_warden"
	director.wave_cleared.connect(func(wave_number: int, credit_reward: int, run_high_water: int, boss_id: String) -> void:
		structured_clear_events.append({
			"wave": wave_number,
			"credit_reward": credit_reward,
			"run_high_water": run_high_water,
			"boss_id": boss_id,
			"credits_at_emit": director.economy.credits,
			"phase_at_emit": director.phase,
			"next_wave_at_emit": director.wave
		})
	)
	director.economy.credits = 0
	director.wave = 1
	var breaker: Dictionary = director.allies[0]
	breaker["x"] = 500.0
	director.enemy_x = 504.0
	director.enemy_hp = 1.0
	breaker["attack_elapsed"] = float(director.player_def["attack_interval"])
	director.enemy_attack_elapsed = 0.0
	director._step(0.05)
	_check(director.phase == "intermission", "Enemy defeat should advance to intermission.")
	_check(director.economy.credits == int(director.wave_def["base_credit_reward"]), "Reward should be credited once.")
	_check(director.highest_cleared_wave == 1, "Cleared-wave state should update after victory.")
	_check(structured_clear_events.size() == 1, "The authoritative clear event should emit once for the resolved wave.")
	if not structured_clear_events.is_empty():
		var clear_event: Dictionary = structured_clear_events[0]
		_check(clear_event["wave"] == 1 and clear_event["credit_reward"] == director.wave_def["base_credit_reward"] and clear_event["run_high_water"] == 1 and clear_event["boss_id"] == "boss.test_warden", "The structured clear event should identify the cleared wave, credited reward, updated run record, and optional boss ID.")
		_check(clear_event["credits_at_emit"] == clear_event["credit_reward"] and clear_event["phase_at_emit"] == "intermission" and clear_event["next_wave_at_emit"] == 2, "Clear listeners should observe credits and wave state after the authoritative reward/transition transaction.")
	_check(not events.is_empty() and events[-1].contains("cleared"), "Victory event should follow the attack event.")
	director.economy.credits = 100
	var two_level_cost := director.upgrade_cost(1) + director.upgrade_cost(2)
	_check(director.upgrade_recruit(2) == 2, "Bulk upgrade should purchase affordable levels.")
	_check(director.economy.credits == 100 - two_level_cost and director.economy.recruit_level == 3, "Bulk upgrade should deduct the configured cost once for each purchased level.")
	_check(is_equal_approx(director._player_attack_power(), 22.8), "Recruit levels should increase combat attack power.")
	_check(is_equal_approx(director._player_max_hp(), 138.0), "Recruit levels should increase maximum health.")
	_check(is_equal_approx(float(director.allies[0]["attack_power"]), 22.8) and is_equal_approx(float(director.allies[0]["max_hp"]), 138.0), "Upgrades should change BREAKER's authoritative combat stats.")
	var awarded: int = int(director.economy.credits)
	var level_before_blocked_upgrade: int = director.economy.recruit_level
	var blocked_cost: int = director.upgrade_cost(level_before_blocked_upgrade)
	director.economy.credits = blocked_cost - 1
	_check(director.upgrade_recruit(1) == 0, "An upgrade must not be purchased when credits are one below its cost.")
	_check(director.economy.credits == blocked_cost - 1 and director.economy.recruit_level == level_before_blocked_upgrade, "An unaffordable upgrade must leave credits and recruit level unchanged.")
	director.economy.credits = blocked_cost
	_check(director.upgrade_recruit(1) == 1, "An upgrade should be purchased when credits exactly match its cost.")
	_check(director.economy.credits == 0 and director.economy.recruit_level == level_before_blocked_upgrade + 1, "An exact-cost upgrade should deduct the full cost and raise the level once.")
	director._step(0.05)
	_check(director.economy.credits == 0 and awarded > 0, "Intermission must not award credits twice after the reward was spent.")
	_check(structured_clear_events.size() == 1, "Intermission ticks must not emit a duplicate clear event.")
	director.queue_free()


func _test_structured_combat_action_events() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	for ally in director.allies:
		ally["hp"] = 0.0
	var breaker: Dictionary = director.allies[0]
	breaker["hp"] = float(breaker["max_hp"])
	breaker["x"] = 500.0
	breaker["attack_elapsed"] = float(breaker["attack_interval"])
	director.allies[0] = breaker
	director.enemy_x = 504.0
	director.enemy_hp = 500.0
	var observed: Array[Dictionary] = []
	var hp_at_emit: Array[float] = []
	director.combat_action_resolved.connect(func(event: Dictionary) -> void:
		observed.append(event.duplicate(true))
		hp_at_emit.append(float(director.enemy_hp if str(event.get("source_side", "")) == "ally" else director.allies[0]["hp"]))
		event["damage"] = 999999.0
		event["target_hp_after"] = 0.0
	)
	var enemy_hp_before: float = float(director.enemy_hp)
	director._simulate_allies(0.05)
	_check(observed.size() == 1, "One resolved ally strike should emit one structured combat action.")
	if not observed.is_empty():
		var ally_event: Dictionary = observed[0]
		_check(ally_event["sequence"] == 1 and ally_event["event_type"] == "attack_resolved", "Combat action events should use a monotonic sequence and explicit resolved-event type.")
		_check(ally_event["source_id"] == "breaker" and ally_event["source_side"] == "ally" and ally_event["target_id"] == "undercity_grunt", "Ally attack events should identify the attacker and target for weapon presentation routing.")
		_check(is_equal_approx(float(ally_event["damage"]), float(breaker["attack_power"])) and is_equal_approx(float(ally_event["target_hp_after"]), director.enemy_hp), "Attack event payload should match damage and already-committed target HP.")
		_check(is_equal_approx(hp_at_emit[0], director.enemy_hp), "Presentation subscribers should observe combat state after the authoritative hit is resolved.")
	_check(is_equal_approx(director.enemy_hp, enemy_hp_before - float(breaker["attack_power"])), "Mutating a received event payload must not change authoritative combat damage.")

	director.enemy_attack_elapsed = float(director.enemy_def["attack_interval"])
	var breaker_hp_before := float(director.allies[0]["hp"])
	director._simulate_enemy(0.05)
	_check(observed.size() == 2, "One resolved enemy strike should emit one structured combat action.")
	if observed.size() >= 2:
		var enemy_event: Dictionary = observed[1]
		_check(enemy_event["sequence"] == 2 and enemy_event["source_id"] == "undercity_grunt" and enemy_event["source_side"] == "enemy" and enemy_event["target_id"] == "breaker", "Enemy attack events should identify source and automatically selected ally target.")
		_check(is_equal_approx(float(enemy_event["target_hp_after"]), float(director.allies[0]["hp"])) and is_equal_approx(hp_at_emit[1], float(director.allies[0]["hp"])), "Enemy attack event should emit after target HP and hit state are committed.")
	_check(is_equal_approx(float(director.allies[0]["hp"]), breaker_hp_before - director._enemy_attack_power()), "Mutating the visual event must not affect authoritative ally health.")
	director._emit_ability_resolved("breaker", "ally", "test_ability", "", "test_effect_committed")
	_check(observed.size() == 3, "A resolved ability presentation hook should publish through the shared combat-action event stream.")
	if observed.size() >= 3:
		var ability_event: Dictionary = observed[2]
		_check(ability_event.get("sequence") == 3 and ability_event.get("event_type") == "ability_resolved", "Ability events should share monotonic ordering with resolved attacks.")
		_check(ability_event.get("source_id") == "breaker" and ability_event.get("source_side") == "ally" and ability_event.get("ability_id") == "test_ability" and ability_event.get("effect_id") == "test_effect_committed" and not ability_event.has("target_id"), "A targetless ability event should preserve its explicit identity without inventing a target.")
	var sequence_before_invalid_ability: int = int(director.combat_action_sequence)
	director._emit_ability_resolved("", "ally", "test_ability")
	director._emit_ability_resolved("breaker", "neutral", "test_ability")
	director._emit_ability_resolved("breaker", "ally", "")
	_check(director.combat_action_sequence == sequence_before_invalid_ability and observed.size() == 3, "Malformed ability events should fail closed without consuming sequence numbers.")
	director.queue_free()


func _make_i05_director(seed_base: int) -> CombatDirector:
	var director: CombatDirector = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	_check(director.configure_combat_model("hybrid_trial", seed_base), "Hybrid trial fixtures should configure from the provisional profile.")
	var timers: Dictionary = director.combat_trial_def.get("timers", {}).duplicate(true)
	timers["maximum_encounter_seconds"] = 1000.0
	timers["no_progress_seconds"] = 1000.0
	director.combat_trial_def["timers"] = timers
	return director


func _prepare_i05_single_attacker(director: CombatDirector, enemy_hp_value: float = 10000.0) -> void:
	for index in range(director.allies.size()):
		var ally: Dictionary = director.allies[index]
		ally["hp"] = 0.0
		ally["attack_elapsed"] = 0.0
		director.allies[index] = ally
	var attacker: Dictionary = director.allies[0]
	attacker["hp"] = 100.0
	attacker["max_hp"] = 100.0
	attacker["attack_power"] = 10.0
	attacker["attack_interval"] = 1.0
	attacker["engagement_distance"] = 4.0
	attacker["x"] = 500.0
	attacker["attack_elapsed"] = 1.0
	director.allies[0] = attacker
	director.enemy_x = 504.0
	director.enemy_max_hp = 100.0
	director.enemy_hp = enemy_hp_value
	director.enemy_def["attack_power_base"] = 10.0
	director.enemy_def["attack_per_wave"] = 0.0
	director.enemy_def["attack_interval"] = 1.0
	director.enemy_attack_elapsed = 0.0


func _prepare_i05_no_action_positions(director: CombatDirector) -> void:
	director.enemy_x = 600.0
	director.enemy_attack_elapsed = 0.0
	for index in range(director.allies.size()):
		var ally: Dictionary = director.allies[index]
		ally["hp"] = float(ally["max_hp"])
		ally["x"] = 190.0 + float(ally.get("formation_start_offset_x", 0.0))
		ally["attack_elapsed"] = 0.0
		director.allies[index] = ally


func _i05_attack_event_for_seed(seed_base: int) -> Dictionary:
	var director := _make_i05_director(seed_base)
	_prepare_i05_single_attacker(director)
	var events: Array[Dictionary] = []
	director.combat_action_resolved.connect(func(event: Dictionary) -> void: events.append(event.duplicate(true)))
	director._simulate_allies(director.FIXED_STEP)
	var result: Dictionary = events[0].duplicate(true) if not events.is_empty() else {}
	director.queue_free()
	return result


func _test_i05_default_and_seeded_combat() -> void:
	var direct: CombatDirector = DIRECTOR_SCRIPT.new()
	root.add_child(direct)
	_check(direct.combat_model == "direct_damage", "The default combat model must remain direct damage.")
	_prepare_i05_single_attacker(direct)
	var direct_events: Array[Dictionary] = []
	direct.combat_action_resolved.connect(func(event: Dictionary) -> void: direct_events.append(event.duplicate(true)))
	direct._simulate_allies(direct.FIXED_STEP)
	_check(direct_events.size() == 1 and is_equal_approx(float(direct_events[0].get("damage", -1.0)), 10.0), "Default direct damage should preserve its configured per-hit damage and event count.")
	_check(not direct_events.is_empty() and not direct_events[0].has("impact_roll") and not direct_events[0].has("high_impact_probability"), "Direct-damage events must not gain hybrid impact outcomes by default.")
	direct.queue_free()

	var malformed: CombatDirector = DIRECTOR_SCRIPT.new()
	root.add_child(malformed)
	var malformed_profile: Dictionary = malformed.combat_trial_def.duplicate(true)
	malformed_profile["seed_base"] = 1.5
	malformed.combat_trial_def = malformed_profile
	_check(not malformed.configure_combat_model("hybrid_trial", 731) and malformed.combat_model == "direct_damage", "A malformed fractional seed should fail closed to direct damage.")
	malformed.queue_free()

	var seed_base := 481516
	var first := _make_i05_director(seed_base)
	_check(first.encounter_seed == seed_base, "An explicit positive seed should override the first encounter seed.")
	var first_event := _i05_attack_event_for_seed(seed_base)
	var replay_event := _i05_attack_event_for_seed(seed_base)
	_check(not first_event.is_empty() and first_event == replay_event, "Identical encounter seeds and inputs should reproduce the committed attack event and impact roll.")
	var stride := int(first.combat_trial_def.get("seed_stride", 0))
	first._begin_encounter()
	_check(stride > 0 and first.encounter_seed == seed_base + stride, "A later encounter should derive its seed from the explicit first seed and configured stride.")
	first.queue_free()


func _test_i05_score_mapping_and_attack_sampling() -> void:
	var director := _make_i05_director(8128)
	_prepare_i05_single_attacker(director, 100.0)
	var baseline := director._actor_power(100.0, 100.0, 10.0, 1.0)
	_check(director._actor_power(50.0, 100.0, 10.0, 1.0) < baseline, "Current HP should contribute to the selected per-actor score.")
	_check(director._actor_power(100.0, 200.0, 10.0, 1.0) > baseline, "Maximum HP should contribute to the selected per-actor score.")
	_check(director._actor_power(100.0, 100.0, 20.0, 1.0) > baseline, "Attack power should contribute to the selected per-actor score.")
	_check(director._actor_power(100.0, 100.0, 10.0, 2.0) < baseline, "Longer attack interval should reduce the cadence contribution to the selected score.")

	var profile_likelihood: Dictionary = director.combat_trial_def.get("likelihood", {})
	var minimum_probability := float(profile_likelihood.get("minimum_high_impact_probability", 0.0))
	var maximum_probability := float(profile_likelihood.get("maximum_high_impact_probability", 1.0))
	director.allies[0]["attack_power"] = 5.0
	director._committed_attack_damage(10.0, "ally")
	var weak_probability := float(director._last_impact_payload["high_impact_probability"])
	director.allies[0]["attack_power"] = 10.0
	director._committed_attack_damage(10.0, "ally")
	var equal_probability := float(director._last_impact_payload["high_impact_probability"])
	director.allies[0]["attack_power"] = 30.0
	director._committed_attack_damage(10.0, "ally")
	var strong_probability := float(director._last_impact_payload["high_impact_probability"])
	_check(minimum_probability <= weak_probability and weak_probability < equal_probability and equal_probability < strong_probability and strong_probability <= maximum_probability, "High-impact likelihood should stay bounded and increase monotonically with relative power.")
	_check(weak_probability > 0.0 and strong_probability < 1.0, "The likelihood mapping must leave both low- and high-impact outcomes possible.")

	# Mirror the same 3:1 power ratio so an enemy attack exercises the same relative mapping.
	director.allies[0]["attack_power"] = 30.0
	director.enemy_def["attack_power_base"] = 10.0
	director._committed_attack_damage(10.0, "ally")
	var allied_advantage_probability := float(director._last_impact_payload["high_impact_probability"])
	director.allies[0]["attack_power"] = 10.0
	director.enemy_def["attack_power_base"] = 30.0
	director._committed_attack_damage(10.0, "enemy")
	var enemy_advantage_probability := float(director._last_impact_payload["high_impact_probability"])
	_check(is_equal_approx(allied_advantage_probability, enemy_advantage_probability), "Mirrored relative-power advantage should use the same likelihood rule for allied and enemy attacks.")

	_prepare_i05_single_attacker(director)
	var attack_events: Array[Dictionary] = []
	director.combat_action_resolved.connect(func(event: Dictionary) -> void: attack_events.append(event.duplicate(true)))
	director._simulate_allies(director.FIXED_STEP)
	director.allies[0]["attack_power"] = 20.0
	director.allies[0]["attack_elapsed"] = float(director.allies[0]["attack_interval"])
	director._simulate_allies(director.FIXED_STEP)
	_check(attack_events.size() == 2, "Both forced cadence commits should resolve as ordinary authoritative attacks.")
	if attack_events.size() == 2:
		_check(float(attack_events[1].get("source_effective_power", 0.0)) > float(attack_events[0].get("source_effective_power", 0.0)) and float(attack_events[1].get("high_impact_probability", 0.0)) > float(attack_events[0].get("high_impact_probability", 0.0)), "The power score and likelihood should be recalculated at each committed attack using then-current actor values.")
		var second_roll := float(attack_events[1].get("impact_roll", -1.0))
		var second_probability := float(attack_events[1].get("high_impact_probability", -1.0))
		_check(second_roll >= 0.0 and second_roll < 1.0 and attack_events[1].get("impact_band", "") == ("high" if second_roll < second_probability else "low"), "Each committed attack should use its encounter-local random draw to choose its impact band.")
	director.queue_free()


func _test_i05_timer_order_and_resets() -> void:
	var director := _make_i05_director(7001)
	var timers: Dictionary = director.combat_trial_def["timers"]
	timers["maximum_encounter_seconds"] = 10.0
	timers["no_progress_seconds"] = director.FIXED_STEP * 2.0
	director.combat_trial_def["timers"] = timers
	_prepare_i05_single_attacker(director)
	director.encounter_elapsed = 0.0
	director.no_progress_elapsed = director.FIXED_STEP
	var attack_events: Array[Dictionary] = []
	director.combat_action_resolved.connect(func(event: Dictionary) -> void: attack_events.append(event.duplicate(true)))
	var enemy_hp_before := director.enemy_hp
	director._step(director.FIXED_STEP)
	_check(attack_events.size() == 1 and director.enemy_hp < enemy_hp_before, "Fixed-step attacks should resolve before timer evaluation.")
	_check(director.phase == "combat" and is_equal_approx(director.no_progress_elapsed, 0.0), "Committed HP change should reset no-progress before its threshold is checked.")

	_prepare_i05_no_action_positions(director)
	director.no_progress_elapsed = director.FIXED_STEP
	director.notify_qualifying_progress_effect()
	director._step(director.FIXED_STEP)
	_check(director.phase == "combat" and is_equal_approx(director.no_progress_elapsed, 0.0), "The qualifying-effect hook should reset no-progress on its next fixed-step resolution.")
	director.queue_free()

	var no_progress := _make_i05_director(7002)
	timers = no_progress.combat_trial_def["timers"]
	timers["maximum_encounter_seconds"] = 10.0
	timers["no_progress_seconds"] = no_progress.FIXED_STEP
	no_progress.combat_trial_def["timers"] = timers
	_prepare_i05_no_action_positions(no_progress)
	no_progress.wave = 5
	no_progress.highest_cleared_wave = 3
	no_progress._begin_encounter()
	_prepare_i05_no_action_positions(no_progress)
	no_progress._step(no_progress.FIXED_STEP)
	_check(no_progress.phase == "retreat" and no_progress.last_timer_expiry_primary == "no_progress" and no_progress.last_timer_expiry_also.is_empty(), "No-progress expiry alone should resolve as defeat with the correct primary reason.")
	no_progress.queue_free()


func _test_i05_timer_defeat_retreat_and_retry() -> void:
	var director := _make_i05_director(7003)
	var timers: Dictionary = director.combat_trial_def["timers"]
	timers["maximum_encounter_seconds"] = director.FIXED_STEP
	timers["no_progress_seconds"] = director.FIXED_STEP
	director.combat_trial_def["timers"] = timers
	director.wave = 5
	director.highest_cleared_wave = 3
	director._begin_encounter()
	_prepare_i05_no_action_positions(director)
	var cues: Array[Dictionary] = []
	director.stalemate_arrival.connect(func(holding_wave: int, retry_wave: int) -> void: cues.append({"holding_wave": holding_wave, "retry_wave": retry_wave}))
	director._step(director.FIXED_STEP)
	_check(director.phase == "retreat" and director.last_terminal_reason == "maximum_timeout", "Simultaneous expiry should resolve as maximum-timeout defeat.")
	_check(director.last_timer_expiry_primary == "maximum_timeout" and director.last_timer_expiry_also == ["no_progress"], "A timer tie should record no-progress as also expired behind maximum timeout.")
	_check(director.wave == 3, "Timer defeat should return to the highest previously cleared holding wave.")
	director.phase_timer = director.FIXED_STEP
	director._step(director.FIXED_STEP)
	var recovered_to_full := director.phase == "combat" and director.wave == 3
	for ally in director.allies:
		recovered_to_full = recovered_to_full and is_equal_approx(float(ally["hp"]), float(ally["max_hp"]))
	_check(recovered_to_full, "Timer retreat should restore the squad to full HP on holding-wave re-entry.")
	_check(cues.size() == 1 and cues[0]["holding_wave"] == 3 and cues[0]["retry_wave"] == 4, "Holding-wave arrival should emit one cue naming the next uncleared wave; this tests the cue, not a completed cinematic.")

	for index in range(1, director.allies.size()):
		director.allies[index]["hp"] = 0.0
	director.allies[0]["x"] = 500.0
	director.allies[0]["attack_elapsed"] = float(director.allies[0]["attack_interval"])
	director.enemy_x = 504.0
	director.enemy_hp = 1.0
	director.enemy_max_hp = 100.0
	timers["maximum_encounter_seconds"] = 100.0
	timers["no_progress_seconds"] = 100.0
	director.combat_trial_def["timers"] = timers
	director._step(director.FIXED_STEP)
	_check(director.phase == "intermission" and director.highest_cleared_wave == 3 and director.wave == 4, "One holding-wave clear should advance the retry to the next uncleared wave.")
	director.phase_timer = director.FIXED_STEP
	director._step(director.FIXED_STEP)
	_check(director.phase == "combat" and director.wave == 4, "The next uncleared wave should begin automatically after the holding-wave clear.")

	# A second timer retreat in this process should not replay the one-time arrival cue.
	timers["no_progress_seconds"] = director.FIXED_STEP
	director.combat_trial_def["timers"] = timers
	_prepare_i05_no_action_positions(director)
	director._step(director.FIXED_STEP)
	if director.phase == "retreat":
		director.phase_timer = director.FIXED_STEP
		director._step(director.FIXED_STEP)
	_check(cues.size() == 1, "The stalemate arrival cue should remain one-time within the process.")
	director.queue_free()


func _test_attachment_event_routing() -> void:
	var router = ATTACHMENT_ROUTER_SCRIPT.new()
	var weapon_receiver := _AttachmentEventReceiver.new()
	weapon_receiver.mutate_damage = true
	var second_weapon_receiver := _AttachmentEventReceiver.new()
	var armor_receiver := _AttachmentEventReceiver.new()
	var drone_receiver := _AttachmentEventReceiver.new()
	var second_drone_receiver := _AttachmentEventReceiver.new()
	var third_drone_receiver := _AttachmentEventReceiver.new()
	var second_breaker_receiver := _AttachmentEventReceiver.new()
	var support_accessory_receiver := _AttachmentEventReceiver.new()
	_check(router.register_attachment("breaker.rifle", "breaker", weapon_receiver, ["attack_resolved"]), "A weapon presentation receiver should register for its owner's attack events.")
	_check(router.register_attachment("breaker.muzzle", "breaker", second_weapon_receiver, ["attack_resolved"]), "Multiple equipment nodes on one owner should receive the same resolved attack independently.")
	_check(router.register_attachment("breaker.armor", "breaker", armor_receiver, ["attack_resolved"], "target_id"), "A hit-reactive armor receiver should register against the event target.")
	_check(router.register_attachment("spark.drone_01", "spark", drone_receiver, ["attack_resolved"]), "SPARK's first attack drone should receive its owner's resolved attack event.")
	_check(router.register_attachment("spark.drone_02", "spark", second_drone_receiver, ["attack_resolved"]), "SPARK's second attack drone should have its own event receiver.")
	_check(router.register_attachment("spark.drone_03", "spark", third_drone_receiver, ["attack_resolved"]), "SPARK's third attack drone should have its own event receiver.")
	_check(router.register_attachment("breaker_copy_02.rifle", "breaker_instance_02", second_breaker_receiver, ["attack_resolved"]), "Equipment routing should use the unique actor instance ID, not only the recruit definition ID.")
	_check(router.register_attachment("bulwark.medical_pack", "bulwark", support_accessory_receiver, ["ability_resolved"]), "Support accessories should be able to receive owner ability events without requiring an enemy target.")
	_check(not router.register_attachment("breaker.rifle", "breaker", weapon_receiver, ["attack_resolved"]), "Duplicate attachment IDs should be rejected rather than silently replacing an existing receiver.")
	_check(not router.register_attachment("invalid.owner", "breaker", armor_receiver, ["attack_resolved"], "ability_id"), "Unsupported owner-match fields should fail closed.")
	var ally_attack := {"sequence": 1, "event_type": "attack_resolved", "source_id": "breaker", "target_id": "undercity_grunt", "damage": 18.0}
	_check(router.dispatch_combat_event(ally_attack) == 2, "Only source-owned weapon nodes should receive BREAKER's resolved attack.")
	_check(weapon_receiver.events.size() == 1 and second_weapon_receiver.events.size() == 1 and armor_receiver.events.is_empty() and drone_receiver.events.is_empty() and second_drone_receiver.events.is_empty() and third_drone_receiver.events.is_empty(), "Source/target routing should not leak events to unrelated attachments.")
	if not second_weapon_receiver.events.is_empty():
		_check(is_equal_approx(float(second_weapon_receiver.events[0]["damage"]), 18.0), "Each attachment should receive its own immutable copy even when another receiver mutates its event.")
	var enemy_attack := {"sequence": 2, "event_type": "attack_resolved", "source_id": "undercity_grunt", "target_id": "breaker", "damage": 8.0}
	_check(router.dispatch_combat_event(enemy_attack) == 1 and armor_receiver.events.size() == 1, "Target-owned armor should receive only events addressed to its owner.")
	var second_instance_attack := {"sequence": 3, "event_type": "attack_resolved", "source_id": "breaker_instance_02", "target_id": "undercity_grunt", "damage": 18.0}
	_check(router.dispatch_combat_event(second_instance_attack) == 1 and second_breaker_receiver.events.size() == 1, "A second instance of the same recruit should route only to its own equipment.")
	var spark_attack := {"sequence": 4, "event_type": "attack_resolved", "source_id": "spark", "target_id": "undercity_grunt", "damage": 12.0}
	_check(router.dispatch_combat_event(spark_attack) == 3, "One authoritative SPARK attack event should reach all three separately registered drone presentation nodes.")
	_check(drone_receiver.events.size() == 1 and second_drone_receiver.events.size() == 1 and third_drone_receiver.events.size() == 1, "All three SPARK drone receivers should observe one event without sharing identity or registration.")
	var support_ability := {"sequence": 5, "event_type": "ability_resolved", "source_id": "bulwark", "ability_id": "last_protocol", "effect_id": "heal_committed"}
	_check(router.dispatch_combat_event(support_ability) == 1 and support_accessory_receiver.events.size() == 1, "Owner ability events without a target should reach only their registered support accessory presentation.")
	_check(armor_receiver.events.size() == 1 and drone_receiver.events.size() == 1, "Target-only armor and unrelated drone presentations should ignore a targetless support event.")
	_check(router.dispatch_combat_event(ally_attack) == 0, "Duplicate or out-of-order combat sequences should not replay attachment presentation.")
	var missing_sequence := {"event_type": "attack_resolved", "source_id": "breaker", "target_id": "undercity_grunt"}
	_check(router.dispatch_combat_event(missing_sequence) == 0, "Events without a positive monotonic sequence should fail closed.")
	var missing_event_data := {"sequence": 6, "event_type": "attack_resolved"}
	_check(router.dispatch_combat_event(missing_event_data) == 0, "Malformed event data should be ignored without dispatch.")
	var stale_receiver := _AttachmentEventReceiver.new()
	var stale_receiver_ref: WeakRef = weakref(stale_receiver)
	_check(router.register_attachment("breaker.stale", "breaker", stale_receiver, ["attack_resolved"]), "A matching receiver should register before its owner releases it.")
	_check(router.registered_attachment_count() == 9, "The router should count the registered weak receiver before it is released.")
	stale_receiver = null
	_check(stale_receiver_ref.get_ref() == null, "The weak receiver fixture should be freed after its last strong reference is released.")
	var stale_receiver_attack := {"sequence": 6, "event_type": "attack_resolved", "source_id": "breaker", "target_id": "undercity_grunt", "damage": 6.0}
	_check(router.dispatch_combat_event(stale_receiver_attack) == 2, "A matching event should still reach the two live BREAKER receivers when a third receiver is stale.")
	_check(router.registered_attachment_count() == 8, "Dispatch should remove the freed receiver registration after its matching event.")
	_check(weapon_receiver.events.size() == 2 and second_weapon_receiver.events.size() == 2, "Live matching receivers should receive the event while stale receiver cleanup runs.")
	_check(router.unregister_attachment("breaker.rifle") and router.registered_attachment_count() == 7, "An attachment should be removable without disturbing other routes.")
	router.free()


func _test_attachment_presentation_receiver() -> void:
	var router := ATTACHMENT_ROUTER_SCRIPT.new()
	var receiver = ATTACHMENT_RECEIVER_SCRIPT.new()
	var animation_player := AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	var library := AnimationLibrary.new()
	library.add_animation("weapon_fire", Animation.new())
	animation_player.add_animation_library("", library)
	receiver.add_child(animation_player)
	receiver.event_animation_map = {"attack_resolved": "weapon_fire"}
	root.add_child(router)
	root.add_child(receiver)
	_check(router.register_attachment("test.weapon", "test_actor", receiver, ["attack_resolved", "ability_resolved"]), "The presentation receiver should register as a routed attachment.")
	var event := {"sequence": 1, "event_type": "attack_resolved", "source_id": "test_actor", "target_id": "test_enemy", "damage": 17.0}
	_check(router.dispatch_combat_event(event) == 1, "The authoritative attack event should route to the presentation receiver.")
	_check(receiver.received_event_count == 1 and receiver.last_presented_sequence == 1, "The receiver should record one monotonically sequenced presentation event.")
	_check(receiver.last_presented_animation == "weapon_fire" and animation_player.current_animation == "weapon_fire", "The receiver should play only the explicitly mapped visual clip (receiver=%s, current=%s, has=%s)." % [receiver.last_presented_animation, animation_player.current_animation, animation_player.has_animation("weapon_fire")])
	_check(is_equal_approx(float(event["damage"]), 17.0) and str(event["target_id"]) == "test_enemy", "Presentation playback must not mutate authoritative event damage or target data.")
	_check(router.dispatch_combat_event(event) == 0 and receiver.received_event_count == 1, "A repeated routed event must not replay the attachment presentation.")
	receiver.present_combat_event(event)
	_check(receiver.received_event_count == 1, "The receiver itself should reject a duplicate sequence if invoked outside the router.")
	var unmapped_event := {"sequence": 2, "event_type": "ability_resolved", "source_id": "test_actor"}
	_check(router.dispatch_combat_event(unmapped_event) == 1 and receiver.received_event_count == 2, "A mapped-to-no-clip event can route without choosing an arbitrary animation.")
	_check(animation_player.current_animation == "weapon_fire" and receiver.last_presented_animation == "weapon_fire", "Unmapped event types must not trigger or replace the current animation.")
	receiver.queue_free()
	router.queue_free()
	await process_frame


func _test_spark_drone_polyrig_mesh_inputs() -> void:
	_check(SPARK_DRONE_REVIEW_PATHS.size() == 3, "SPARK's source-backed drone mesh preflight should cover exactly three independent candidates.")
	var pivot_text := FileAccess.get_file_as_string(SPARK_DRONE_PIVOT_REVIEW_PATH)
	var pivot_data: Variant = JSON.parse_string(pivot_text)
	_check(typeof(pivot_data) == TYPE_DICTIONARY, "SPARK's quarantined drone pivot review manifest should parse as JSON.")
	var pivot_parts: Dictionary = {}
	if typeof(pivot_data) == TYPE_DICTIONARY:
		var pivot_manifest: Dictionary = pivot_data
		_check(str(pivot_manifest.get("status", "")).contains("QUARANTINED"), "SPARK's authored drone pivots should remain quarantined.")
		_check(pivot_manifest.get("animation_ready", true) == false and pivot_manifest.get("production_approved", true) == false and pivot_manifest.get("runtime_integrated", true) == false, "Drone pivot review must not claim animation, production, or runtime readiness.")
		for part_value in pivot_manifest.get("parts", []):
			if typeof(part_value) != TYPE_DICTIONARY:
				_check(false, "Every SPARK drone pivot record should be a dictionary.")
				continue
			var part: Dictionary = part_value
			var part_id := str(part.get("part_id", ""))
			_check(not part_id.is_empty() and not pivot_parts.has(part_id), "SPARK drone pivot IDs should be present and unique.")
			if not part_id.is_empty():
				pivot_parts[part_id] = part
	_check(pivot_parts.size() == 3, "The pivot review should define exactly three independent source-backed SPARK drone attachments.")
	var seen_paths: Dictionary = {}
	for path in SPARK_DRONE_REVIEW_PATHS:
		_check(not seen_paths.has(path), "SPARK drone preflight paths should be unique: %s" % path)
		seen_paths[path] = true
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		_check(image != null, "Quarantined SPARK drone mesh input should load from disk: %s" % path.get_file())
		if image == null:
			continue
		var part_id: String = str(path).get_file().get_basename().replace("SPARK_T1_", "").replace("_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED", "").to_lower()
		var part: Dictionary = pivot_parts.get(part_id, {})
		var pivot_value: Variant = part.get("pivot_px", null)
		_check(typeof(pivot_value) == TYPE_ARRAY and pivot_value.size() == 2, "Each SPARK drone should have an explicit author-placed pivot: %s" % part_id)
		if typeof(pivot_value) == TYPE_ARRAY and pivot_value.size() == 2:
			var pivot := Vector2i(int(pivot_value[0]), int(pivot_value[1]))
			var visible_bounds := image.get_used_rect()
			_check(visible_bounds.has_point(pivot), "Each SPARK drone pivot should fall on visible authored art, not the transparent border: %s" % part_id)
		_check(str(part.get("attachment_role_id", "")).begins_with("spark.") and str(part.get("owner_character_id", "")) == "SPARK", "Each drone pivot should retain stable SPARK owner/role metadata: %s" % part_id)
		_check(image.get_format() in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAH, Image.FORMAT_RGBAF], "SPARK drone mesh input must preserve transparent RGBA data: %s" % path.get_file())
		_check(image.get_pixel(0, 0).a <= 0.01 and image.get_pixel(image.get_width() - 1, image.get_height() - 1).a <= 0.01, "SPARK drone mesh input must retain transparent outer corners: %s" % path.get_file())
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(image)
		var contours := bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), 1.0)
		_check(contours.size() == 1, "Each SPARK drone texture should contain one PolyRig contour; split distinct moving pieces into their own inputs: %s" % path.get_file())
		if contours.size() != 1:
			continue
		var texture := ImageTexture.create_from_image(image)
		var mesh_parent := Node2D.new()
		var mesh_result: Dictionary = ALPHA_CONTOUR_MESH_BUILDER.append_contour_meshes(image, texture, mesh_parent, path.get_file().get_basename())
		_check(bool(mesh_result.get("ok", false)), "Each SPARK drone should pass through the shared contour-mesh builder: %s %s" % [path.get_file(), mesh_result.get("error", "")])
		_check(int(mesh_result.get("contour_count", 0)) == 1, "Each SPARK drone should produce exactly one review mesh contour: %s" % path.get_file())
		var mesh_nodes: Array = mesh_result.get("nodes", [])
		_check(mesh_nodes.size() == 1 and mesh_parent.get_child_count() == 1, "Each SPARK drone should attach exactly one Polygon2D under its semantic review owner: %s" % path.get_file())
		if mesh_nodes.size() == 1 and mesh_nodes[0] is Polygon2D:
			var mesh: Polygon2D = mesh_nodes[0]
			_check(mesh.texture == texture, "SPARK drone mesh must retain the original RGBA texture without flattening or recoloring: %s" % path.get_file())
			_check(mesh.polygon.size() >= 3 and mesh.uv == mesh.polygon, "SPARK drone mesh UVs should remain pixel-aligned to its contour: %s" % path.get_file())
			_check(not mesh.polygons.is_empty(), "SPARK drone mesh should contain triangulated faces: %s" % path.get_file())
		mesh_parent.free()


func _test_specter_blade_polyrig_mesh_inputs() -> void:
	var manifest_file := FileAccess.open(SPECTER_BLADE_CANDIDATE_ROOT + "parts_manifest.json", FileAccess.READ)
	_check(manifest_file != null, "SPECTER visible blade candidate should have a readable quarantine manifest.")
	if manifest_file == null:
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	_check(parsed is Dictionary, "SPECTER visible blade manifest should parse as a JSON object.")
	if not parsed is Dictionary:
		return
	var manifest: Dictionary = parsed
	_check(str(manifest.get("status", "")).contains("QUARANTINED"), "SPECTER visible blade candidate must remain quarantined.")	
	for flag in ["production_approved", "semantic_review_passed", "pivots_authored", "deformation_reviewed", "runtime_integrated"]:
		_check(manifest.get(flag, true) == false, "SPECTER candidate must keep %s false." % flag)
	var part_records: Array = manifest.get("parts", [])
	_check(part_records.size() == 2, "SPECTER candidate should contain only the exposed hilt and blade fragments.")
	var seen_ids: Dictionary = {}
	var valid_parts := 0
	var summaries: Array[String] = []
	for part_value in part_records:
		if not part_value is Dictionary:
			_check(false, "Every SPECTER cutout record should be a dictionary.")
			continue
		var part: Dictionary = part_value
		var part_id := str(part.get("part_id", ""))
		_check(not part_id.is_empty() and not seen_ids.has(part_id), "SPECTER candidate part IDs should be present and unique.")
		seen_ids[part_id] = true
		_check(str(part.get("owner_character_id", "")) == "SPECTER" and str(part.get("attachment_role_id", "")) == "specter.blade", "Each visible blade fragment should retain its SPECTER attachment owner and role.")
		_check(part.get("pivot_source_xy", null) == null, "SPECTER blade fragment must not invent a pivot.")
		var filename := str(part.get("file", ""))
		var image := Image.new()
		var load_error := image.load(ProjectSettings.globalize_path(SPECTER_BLADE_CANDIDATE_ROOT + filename))
		_check(not filename.is_empty() and load_error == OK, "SPECTER source-pixel fragment should load from disk: %s" % part_id)
		if load_error != OK:
			continue
		var canvas_px: Array = manifest.get("canvas_px", [])
		_check(canvas_px.size() == 2 and image.get_size() == Vector2i(int(canvas_px[0]), int(canvas_px[1])), "SPECTER cutout canvas should stay aligned to its registered source: %s" % part_id)
		_check(image.get_format() in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAH, Image.FORMAT_RGBAF] and image.get_used_rect().has_area(), "SPECTER cutout should retain visible RGBA pixels: %s" % part_id)
		var texture := ImageTexture.create_from_image(image)
		var owner := Node2D.new()
		var mesh_result: Dictionary = ALPHA_CONTOUR_MESH_BUILDER.append_contour_meshes(image, texture, owner, part_id)
		_check(bool(mesh_result.get("ok", false)), "SPECTER visible fragment should build through the shared PolyRig mesh helper: %s %s" % [part_id, mesh_result.get("error", "")])
		if bool(mesh_result.get("ok", false)):
			var contour_count := int(mesh_result.get("contour_count", 0))
			var mesh_nodes: Array = mesh_result.get("nodes", [])
			_check(contour_count > 0 and mesh_nodes.size() == contour_count and owner.get_child_count() == contour_count, "Every SPECTER alpha contour should receive a separately owned review mesh: %s" % part_id)
			var polyrig_count := int(mesh_result.get("polyrig_count", 0))
			var fallback_count := int(mesh_result.get("godot_fallback_count", 0))
			_check(polyrig_count == contour_count and fallback_count == 0, "Every SPECTER fragment contour should triangulate through PolyRig without fallback: %s" % part_id)
			var all_meshes_valid := mesh_nodes.size() == contour_count
			for mesh_node in mesh_nodes:
				var mesh_valid := false
				if mesh_node is Polygon2D:
					var mesh: Polygon2D = mesh_node
					mesh_valid = mesh.texture == texture and mesh.polygon.size() >= 3 and mesh.uv == mesh.polygon and not mesh.polygons.is_empty()
				_check(mesh_valid, "Every SPECTER review mesh should preserve its texture, pixel-aligned UVs, and triangles: %s" % part_id)
				all_meshes_valid = all_meshes_valid and mesh_valid
			if all_meshes_valid:
				valid_parts += 1
			summaries.append("%s=%d contours (PolyRig %d; fallback %d)" % [part_id, contour_count, polyrig_count, fallback_count])
		owner.free()
	_check(valid_parts == 2, "Both SPECTER visible sword fragments should produce structurally valid review meshes (%d/2)." % valid_parts)
	print("SPECTER quarantined visible blade mesh preflight: ", "; ".join(summaries))


func _test_cipher_candidate_07_intake() -> void:
	var manifest_file := FileAccess.open(CIPHER_CANDIDATE_07_ROOT + "parts_manifest.json", FileAccess.READ)
	_check(manifest_file != null, "CIPHER candidate 07 should have a readable part manifest.")
	if manifest_file == null:
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	_check(parsed is Dictionary, "CIPHER candidate 07 manifest should be a JSON object.")
	if not parsed is Dictionary:
		return
	var manifest: Dictionary = parsed
	_check(str(manifest.get("status", "")).contains("QUARANTINED"), "CIPHER candidate 07 must remain quarantined.")
	_check(manifest.get("semantic_review_status", "") == "NOT_VERIFIED", "CIPHER candidate 07 semantics must remain unverified until visual review.")
	_check(manifest.get("production_approved", true) == false, "CIPHER candidate 07 must not claim production approval.")
	var source_path := str(manifest.get("source", ""))
	_check(not source_path.is_empty() and FileAccess.file_exists("res://" + source_path), "CIPHER candidate 07 source reference should remain available.")
	var ownership_adjustment: Variant = manifest.get("ownership_adjustment", {})
	_check(ownership_adjustment is Dictionary, "CIPHER candidate 07 should document the mast ownership remap.")
	if ownership_adjustment is Dictionary:
		_check(ownership_adjustment.get("from", "") == "head_hood_hair_face" and ownership_adjustment.get("to", "") == "backpack_mount", "CIPHER mast pixels should remain assigned to the backpack candidate, not the head.")
	var parts: Variant = manifest.get("parts", {})
	_check(parts is Dictionary and parts.size() == 10, "CIPHER candidate 07 should declare ten semantic review cutouts.")
	if not parts is Dictionary:
		return
	var seen_files: Dictionary = {}
	var mesh_input_summary: Array[String] = []
	var multi_contour_parts: Array[String] = []
	var fallback_contour_total := 0
	for semantic_name in parts:
		var part: Dictionary = parts[semantic_name]
		var filename := str(part.get("file", ""))
		_check(not filename.is_empty() and not seen_files.has(filename), "CIPHER candidate 07 part filenames must be present and unique: %s" % semantic_name)
		seen_files[filename] = true
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(CIPHER_CANDIDATE_07_ROOT + filename))
		_check(error == OK, "CIPHER candidate 07 part should load from disk: %s" % semantic_name)
		if error != OK:
			continue
		var expected_size: Array = part.get("size_px", [])
		_check(expected_size.size() == 2 and image.get_size() == Vector2i(int(expected_size[0]), int(expected_size[1])), "CIPHER candidate 07 part dimensions should match its manifest: %s" % semantic_name)
		_check(image.get_format() in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAH, Image.FORMAT_RGBAF], "CIPHER candidate 07 part must preserve alpha: %s" % semantic_name)
		_check(image.get_pixel(0, 0).a <= 0.01 and image.get_pixel(image.get_width() - 1, image.get_height() - 1).a <= 0.01, "CIPHER candidate 07 part corners must remain transparent: %s" % semantic_name)
		_check(image.get_used_rect().has_area(), "CIPHER candidate 07 part must contain visible pixels: %s" % semantic_name)
		var mesh_parent := Node2D.new()
		var part_texture := ImageTexture.create_from_image(image)
		var mesh_result: Dictionary = ALPHA_CONTOUR_MESH_BUILDER.append_contour_meshes(image, part_texture, mesh_parent, semantic_name)
		_check(mesh_result.get("ok", false), "CIPHER candidate 07 contours should build separate Polygon2D inputs: %s %s" % [semantic_name, mesh_result.get("error", "")])
		if mesh_result.get("ok", false):
			var contour_count := int(mesh_result.get("contour_count", 0))
			var polyrig_count := int(mesh_result.get("polyrig_count", 0))
			var fallback_count := int(mesh_result.get("godot_fallback_count", 0))
			fallback_contour_total += fallback_count
			_check(mesh_parent.get_child_count() == contour_count, "Each raster contour should have one mesh node under the same semantic owner: %s" % semantic_name)
			for child in mesh_parent.get_children():
				_check(child is Polygon2D and not child.polygons.is_empty() and child.texture == part_texture, "Each contour mesh should retain triangles and the original part texture: %s" % semantic_name)
			mesh_input_summary.append("%s=%d meshes (PolyRig %d; fallback %d)" % [semantic_name, contour_count, polyrig_count, fallback_count])
			if contour_count > 1:
				multi_contour_parts.append(semantic_name)
		mesh_parent.free()
	print("CIPHER candidate 07 mesh preflight: ", "; ".join(mesh_input_summary))
	if fallback_contour_total > 0:
		print("LIMIT: ", fallback_contour_total, " contours use the Geometry2D fallback after PolyRig returned no triangles; source pixels are retained.")
	if not multi_contour_parts.is_empty():
		print("LIMIT: multiple Polygon2D meshes share each raster semantic owner for: ", ", ".join(multi_contour_parts), ". Review semantic ownership before rigging.")
	var assembly := Image.new()
	var assembly_error := assembly.load(ProjectSettings.globalize_path(CIPHER_CANDIDATE_07_ROOT + "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_07_QUARANTINED.png"))
	_check(assembly_error == OK and assembly.get_size() == Vector2i(330, 960), "CIPHER candidate 07 neutral assembly should load at the source profile crop size.")


func _test_cipher_candidate_09b_mesh_inputs() -> void:
	var manifest_file := FileAccess.open(CIPHER_CANDIDATE_09B_ROOT + "parts_manifest.json", FileAccess.READ)
	_check(manifest_file != null, "CIPHER candidate 09B should have a readable part manifest.")
	if manifest_file == null:
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	_check(parsed is Dictionary, "CIPHER candidate 09B manifest should be a JSON object.")
	if not parsed is Dictionary:
		return
	var manifest: Dictionary = parsed
	_check(str(manifest.get("status", "")).contains("QUARANTINED"), "CIPHER candidate 09B must remain quarantined.")
	_check(str(manifest.get("semantic_review_status", "")).begins_with("PARTIAL_USER_APPROVAL") and str(manifest.get("semantic_review_status", "")).contains("RASTER_AND_RIG_REVIEW_OPEN"), "CIPHER candidate 09B should preserve the approved knee-guard owner split while keeping raster and rig review open.")
	_check(manifest.get("production_approved", true) == false, "CIPHER candidate 09B must not claim production approval.")
	var approved_pivot: Dictionary = manifest.get("pivot", {})
	var approved_source_xy: Array = approved_pivot.get("source_xy", [])
	var approved_part_xy: Array = approved_pivot.get("part_local_xy", [])
	_check(str(approved_pivot.get("status", "")).begins_with("USER_APPROVED_AND_AUTHORED"), "CIPHER candidate 09B should retain the user-approved knee-guard pivot status.")
	_check(approved_source_xy.size() == 2 and int(approved_source_xy[0]) == 770 and int(approved_source_xy[1]) == 665, "CIPHER candidate 09B source pivot should remain at approved pixel (770, 665).")
	_check(approved_part_xy.size() == 2 and int(approved_part_xy[0]) == 77 and int(approved_part_xy[1]) == 115, "CIPHER candidate 09B guard-local pivot should remain at approved pixel (77, 115).")
	_check(not str(manifest.get("pivot_and_overlap_status", "")).contains("pivots and hidden/far-side anatomy are not authored"), "CIPHER candidate 09B summary should not contradict its one approved authored pivot.")
	var layer_order: Array = manifest.get("layer_order_back_to_front", [])
	var parts: Variant = manifest.get("parts", {})
	_check(parts is Dictionary and parts.size() == 11, "CIPHER candidate 09B should declare eleven semantic review parts, including its separate knee guard.")
	_check(layer_order.size() == 11 and layer_order.has("near_knee_guard"), "CIPHER candidate 09B draw order should include the separately owned knee guard.")
	if not parts is Dictionary:
		return
	var comparison_file := FileAccess.open(CIPHER_CANDIDATE_09B_ROOT + "neutral_assembly_comparison.json", FileAccess.READ)
	_check(comparison_file != null, "CIPHER candidate 09B should retain its candidate-08 neutral-composite comparison report.")
	if comparison_file != null:
		var comparison: Variant = JSON.parse_string(comparison_file.get_as_text())
		comparison_file.close()
		_check(comparison is Dictionary and comparison.get("pixel_identical", false) == true, "Candidate 09B metadata should record a source-preserving neutral assembly comparison.")
		_check(comparison is Dictionary and comparison.get("semantic_review_status", "") == "NOT_VERIFIED" and comparison.get("production_approved", true) == false, "Candidate 09B comparison must not imply semantic or production approval.")
	var seen_files: Dictionary = {}
	var summaries: Array[String] = []
	var valid_parts := 0
	for semantic_name in layer_order:
		if not parts.has(semantic_name):
			_check(false, "CIPHER candidate 09B draw order should reference a declared part: %s" % semantic_name)
			continue
		var part: Dictionary = parts[semantic_name]
		var filename := str(part.get("file", ""))
		_check(not filename.is_empty() and not seen_files.has(filename), "CIPHER candidate 09B part filenames should be present and unique: %s" % semantic_name)
		seen_files[filename] = true
		var image := Image.new()
		var load_error := image.load(ProjectSettings.globalize_path(CIPHER_CANDIDATE_09B_ROOT + filename))
		_check(load_error == OK, "CIPHER candidate 09B part should load from disk: %s" % semantic_name)
		if load_error != OK:
			continue
		var expected_size: Array = part.get("size_px", [])
		_check(expected_size.size() == 2 and image.get_size() == Vector2i(int(expected_size[0]), int(expected_size[1])), "CIPHER candidate 09B image dimensions should match its manifest: %s" % semantic_name)
		_check(image.get_format() in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAH, Image.FORMAT_RGBAF], "CIPHER candidate 09B image should preserve RGBA: %s" % semantic_name)
		_check(image.get_used_rect().has_area(), "CIPHER candidate 09B part should contain visible pixels: %s" % semantic_name)
		var texture := ImageTexture.create_from_image(image)
		var parent := Node2D.new()
		var mesh_result: Dictionary = ALPHA_CONTOUR_MESH_BUILDER.append_contour_meshes(image, texture, parent, semantic_name)
		_check(bool(mesh_result.get("ok", false)), "CIPHER candidate 09B contours should build through PolyRigContourMeshBuilder: %s %s" % [semantic_name, mesh_result.get("error", "")])
		if bool(mesh_result.get("ok", false)):
			var contour_count := int(mesh_result.get("contour_count", 0))
			_check(contour_count > 0 and parent.get_child_count() == contour_count, "Every candidate 09B alpha contour should have a mesh under its semantic part owner: %s" % semantic_name)
			var part_meshes_valid := true
			for mesh_node in parent.get_children():
				var mesh_valid: bool = mesh_node is Polygon2D and mesh_node.texture == texture and mesh_node.polygon.size() >= 3 and mesh_node.uv == mesh_node.polygon and not mesh_node.polygons.is_empty()
				_check(mesh_valid, "Candidate 09B mesh should retain source texture, pixel UVs, and triangles: %s" % semantic_name)
				part_meshes_valid = part_meshes_valid and mesh_valid
			if part_meshes_valid:
				valid_parts += 1
			summaries.append("%s=%d contours (PolyRig %d; fallback %d)" % [semantic_name, contour_count, int(mesh_result.get("polyrig_count", 0)), int(mesh_result.get("godot_fallback_count", 0))])
		parent.free()
	print("CIPHER candidate 09B mesh preflight: ", "; ".join(summaries))
	_check(valid_parts == 11, "All eleven CIPHER candidate 09B parts should produce structurally valid mesh inputs (%d/11)." % valid_parts)
	var guard: Dictionary = parts.get("near_knee_guard", {})
	var guard_bounds: Array = guard.get("source_bbox_xyxy", [])
	var guard_padding := int(guard.get("padding_px", -1))
	_check(guard_bounds.size() == 4 and guard_padding >= 0 and guard.get("pivot_px_part_local", []) == approved_part_xy, "CIPHER candidate 09B guard metadata should bind the approved local pivot to the named guard part.")
	if guard_bounds.size() == 4 and guard_padding >= 0 and approved_part_xy.size() == 2:
		var reconstructed_source := Vector2i(int(guard_bounds[0]) - guard_padding + int(approved_part_xy[0]), int(guard_bounds[1]) - guard_padding + int(approved_part_xy[1]))
		_check(reconstructed_source == Vector2i(170, 655), "CIPHER candidate 09B approved pivot should resolve to crop hinge (170, 655).")
	var assembly := Image.new()
	var assembly_error := assembly.load(ProjectSettings.globalize_path(CIPHER_CANDIDATE_09B_ROOT + "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_09B_QUARANTINED.png"))
	_check(assembly_error == OK and assembly.get_size() == Vector2i(330, 960), "CIPHER candidate 09B neutral assembly should load at the source profile crop size.")


func _test_cipher_rifle_polyrig_mesh_input() -> void:
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(CIPHER_RIFLE_CANDIDATE_PATH))
	_check(load_error == OK, "Quarantined CIPHER rifle PNG should load for mesh-input preflight.")
	if load_error != OK:
		return
	_check(image.get_size() == Vector2i(540, 270), "CIPHER rifle review cutout should retain its documented 540x270 canvas.")
	_check(image.get_used_rect().has_area(), "CIPHER rifle review cutout should contain visible pixels.")
	var texture := ImageTexture.create_from_image(image)
	var parent := Node2D.new()
	var result: Dictionary = ALPHA_CONTOUR_MESH_BUILDER.append_contour_meshes(image, texture, parent, "cipher_rifle_review")
	_check(bool(result.get("ok", false)), "CIPHER rifle review cutout should build through the shared PolyRig contour helper: %s" % str(result.get("error", "")))
	if bool(result.get("ok", false)):
		var contours := int(result.get("contour_count", 0))
		var mesh_nodes: Array = result.get("nodes", [])
		_check(contours == 1 and mesh_nodes.size() == 1 and parent.get_child_count() == 1, "CIPHER rifle candidate should produce one contour mesh without inferred parts.")
		_check(int(result.get("polyrig_count", 0)) == contours and int(result.get("godot_fallback_count", 0)) == 0, "CIPHER rifle mesh input should triangulate through PolyRig without fallback.")
		if mesh_nodes.size() == 1 and mesh_nodes[0] is Polygon2D:
			var mesh: Polygon2D = mesh_nodes[0]
			_check(mesh.texture == texture and mesh.polygon.size() >= 3 and mesh.uv == mesh.polygon and not mesh.polygons.is_empty(), "CIPHER rifle mesh should preserve its texture, pixel-aligned UVs, and triangles.")
	parent.free()
	print("CIPHER quarantined rifle static mesh-input preflight: 1 contour (PolyRig; fallback 0). Semantic source match, optic ownership, pivots, mounting, pose, behavior, and production status remain unverified.")

func _test_polyrig_contour_builder_rejects_mismatched_texture() -> void:
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.set_pixel(1, 1, Color.WHITE)
	var texture := ImageTexture.create_from_image(Image.create(2, 2, false, Image.FORMAT_RGBA8))
	var parent := Node2D.new()
	var result: Dictionary = ALPHA_CONTOUR_MESH_BUILDER.append_contour_meshes(image, texture, parent, "mismatch")
	_check(not result.get("ok", true), "Contour mesh builder should reject texture/image size mismatch before attaching meshes.")
	_check(parent.get_child_count() == 0, "Contour mesh builder must leave the parent unchanged after a texture/image size mismatch.")
	parent.free()


func _test_founding_profile_mesh_preflights() -> void:
	var expected_bones := ["ground_root", "pelvis", "torso", "neck", "head", "near_shoulder", "near_elbow", "near_wrist", "near_hip", "near_knee", "near_ankle", "near_toe", "far_shoulder", "far_elbow", "far_wrist", "far_hip", "far_knee", "far_ankle", "far_toe"]
	var checked_profiles := 0
	for character_id in FOUNDING_PROFILE_RIG_IDS:
		var rig: FoundingT1ProfileMeshRigCandidate = FOUNDING_PROFILE_RIG_SCRIPT.new()
		root.add_child(rig)
		await process_frame
		_check(rig.build(character_id), "%s quarantined profile mesh preflight should build (%s)" % [character_id, rig.load_error])
		_check(rig.skeleton is Skeleton2D and rig.bones.size() == expected_bones.size(), "%s preflight should expose its full placeholder Skeleton2D blockout" % character_id)
		for bone_name in expected_bones:
			_check(rig.bones.has(bone_name), "%s preflight should include bone %s" % [character_id, bone_name])
		_check(not rig.meshes.is_empty(), "%s flattened source profile should produce at least one mesh contour" % character_id)
		for mesh in rig.meshes:
			_check(mesh.texture != null and mesh.texture.get_size() == rig.source_image_size, "%s preflight mesh should preserve the full source texture mapping" % character_id)
			_check(not mesh.polygons.is_empty(), "%s preflight mesh should have triangulated polygons" % character_id)
			var outline_area := float(mesh.get_meta("outline_area_px", 0.0))
			var triangle_area := float(mesh.get_meta("triangulated_area_px", 0.0))
			var coverage := triangle_area / outline_area if outline_area > 0.0 else 0.0
			_check(coverage > 0.90 and coverage <= 1.05, "%s preflight triangulation coverage should be bounded (%.3f)" % [character_id, coverage])
			_check(mesh.skeleton == mesh.get_path_to(rig.skeleton), "%s preflight skeleton path should resolve from Polygon2D" % character_id)
			var weights_normalized := true
			for vertex_index in range(mesh.polygon.size()):
				var weight_sum := 0.0
				for bone_index in range(rig.skeleton.get_bone_count()):
					var bone_weights: PackedFloat32Array = mesh.get_bone_weights(bone_index)
					if vertex_index < bone_weights.size():
						weight_sum += bone_weights[vertex_index]
				if absf(weight_sum - 1.0) >= 0.01:
					weights_normalized = false
			_check(weights_normalized, "%s preflight vertices should have normalized bone weights" % character_id)
		var ground_anchor := rig.get_ground_anchor()
		for pose in ["neutral", "idle", "walk", "attack", "hit", "defeat"]:
			_check(rig.set_pose(pose), "%s preflight accepts the %s diagnostic pose" % [character_id, pose])
			_check(rig.get_ground_anchor().distance_to(ground_anchor) < 0.001, "%s preflight ground anchor remains fixed in %s" % [character_id, pose])
		checked_profiles += 1
		rig.queue_free()
		await process_frame
	_check(checked_profiles == 10, "The profile-mesh preflight batch should cover exactly ten source profiles.")
	print("Quarantined profile-mesh preflight: %d visible flattened profiles built; semantic art, far-side anatomy, pivots, deformation quality, and production approval remain unverified." % checked_profiles)


func _test_full_automatic_encounter() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var encounter_events: Array[String] = []
	director.event_logged.connect(func(message: String): encounter_events.append(message))
	var start_player_x: float = float(director.allies[0]["x"])
	var start_enemy_x: float = director.enemy_x
	for _step_index in range(2000):
		director._step(director.FIXED_STEP)
		if director.highest_cleared_wave >= 1:
			break
	var result: Dictionary = director.snapshot()
	_check(float(director.allies[0]["x"]) > start_player_x and director.enemy_x < start_enemy_x, "Squad and enemy should automatically close distance.")
	var squad_hp_after: float = _sum_ally_hp(director)
	var squad_max_hp: float = 0.0
	for ally in director.allies:
		squad_max_hp += float(ally["max_hp"])
	_check(squad_hp_after < squad_max_hp, "Enemy attacks should apply real damage to a squad member during the encounter.")
	_check(director.highest_cleared_wave == 1 and director.phase == "intermission", "A complete automatic encounter should resolve and advance.")
	_check(director.economy.credits > 0, "A successful automatic encounter should award credits.")
	var placeholder_attack_logged := false
	for message in encounter_events:
		if message.contains("Unassigned Ally") and message.contains("hits"):
			placeholder_attack_logged = true
	_check(placeholder_attack_logged, "Generic ally placeholders should participate in automatic squad attacks.")
	var hp_before_next_wave: Array[float] = []
	for ally in director.allies:
		hp_before_next_wave.append(float(ally["hp"]))
	var first_result := {"credits": director.economy.credits, "sim_time": director.sim_time, "squad_hp": squad_hp_after}
	for _transition_step in range(30):
		if director.phase != "intermission":
			break
		director._step(director.FIXED_STEP)
	_check(director.wave == 2 and director.phase == "combat", "Victory should automatically start the next wave after intermission.")
	var next_wave_kept_hp: bool = director.wave == 2 and director.phase == "combat"
	for index in range(director.allies.size()):
		next_wave_kept_hp = next_wave_kept_hp and is_equal_approx(float(director.allies[index]["hp"]), hp_before_next_wave[index])
	_check(next_wave_kept_hp, "The automatic post-victory intermission transition should carry each ally's remaining HP into the next wave.")
	director.queue_free()

	var replay = DIRECTOR_SCRIPT.new()
	root.add_child(replay)
	for _replay_step in range(2000):
		replay._step(replay.FIXED_STEP)
		if replay.highest_cleared_wave >= 1:
			break
	_check(replay.economy.credits == first_result["credits"] and is_equal_approx(replay.sim_time, first_result["sim_time"]) and is_equal_approx(_sum_ally_hp(replay), first_result["squad_hp"]), "Identical simulation inputs should reproduce the same encounter result.")
	replay.queue_free()


func _test_presentation_interpolation_isolation_and_reset() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var before := director.snapshot()
	director._step(director.FIXED_STEP)
	var after := director.snapshot()
	director.accumulator = director.FIXED_STEP * 0.5
	var rendered := director.presentation_snapshot()
	_check(is_equal_approx(float(rendered["enemy_x"]), lerpf(float(before["enemy_x"]), float(after["enemy_x"]), 0.5)), "Presentation snapshot should interpolate enemy position between fixed steps.")
	var before_allies: Array = before["allies"]
	var after_allies: Array = after["allies"]
	var rendered_allies: Array = rendered["allies"]
	for index in range(director.allies.size()):
		var expected_x := lerpf(float(before_allies[index]["x"]), float(after_allies[index]["x"]), 0.5)
		_check(is_equal_approx(float(rendered_allies[index]["x"]), expected_x), "Presentation snapshot should interpolate each ally between fixed steps.")
	var authoritative_after_render := director.snapshot()
	_check(is_equal_approx(float(authoritative_after_render["enemy_x"]), float(after["enemy_x"])), "Rendering interpolation must not mutate authoritative enemy position.")
	for index in range(director.allies.size()):
		_check(is_equal_approx(float(authoritative_after_render["allies"][index]["x"]), float(after_allies[index]["x"])), "Rendering interpolation must not mutate authoritative ally positions.")

	director.enemy_x = -400.0
	director.render_previous_enemy_x = -500.0
	for index in range(director.allies.size()):
		director.allies[index]["x"] = 900.0 + float(index)
	director.render_previous_ally_x.fill(-500.0)
	director._begin_encounter()
	director.accumulator = director.FIXED_STEP * 0.5
	var fresh_render := director.presentation_snapshot()
	_check(is_equal_approx(float(fresh_render["enemy_x"]), 600.0), "A fresh encounter should reset enemy presentation origin without stale-location interpolation.")
	for index in range(director.allies.size()):
		var expected_start_x := 190.0 + float(director.allies[index]["formation_start_offset_x"])
		_check(is_equal_approx(float(fresh_render["allies"][index]["x"]), expected_start_x), "A fresh encounter should initialize each ally presentation origin at its configured start position.")
	director.queue_free()


func _test_six_slot_squad_and_auto_targeting() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	_check(director.allies.size() == 6, "The prototype should initialize all six approved active squad slots.")
	_check(director.allies[0]["id"] == "breaker" and not director.allies[0]["prototype_placeholder"], "BREAKER should occupy slot one as the only defined prototype recruit.")
	_check(director.allies.slice(1).all(func(ally: Dictionary): return ally["prototype_placeholder"]), "The other five slots should be explicitly marked as generic placeholders.")
	var formation_depths: Array[float] = []
	var movement_speeds: Array[float] = []
	var combat_styles: Array[String] = []
	var engagement_distances: Array[float] = []
	for ally in director.allies:
		formation_depths.append(float(ally["formation_depth"]))
		movement_speeds.append(float(ally["move_speed"]))
		combat_styles.append(str(ally["combat_style"]))
		engagement_distances.append(float(ally["engagement_distance"]))
		_check(float(ally["engagement_distance"]) <= float(ally["attack_range"]), "Each ally's engagement distance should remain inside attack range.")
		_check(is_equal_approx(float(ally["x"]), 190.0 + float(ally["formation_start_offset_x"])), "Each squad member should start at its configured horizontal formation offset.")
	_check(combat_styles == ["melee", "ranged", "ranged", "melee", "melee", "melee"], "The prototype should load the configured melee/ranged styles for all six squad slots.")
	_check(engagement_distances == [4.0, 88.0, 68.0, 4.0, 4.0, 4.0], "Melee contact and ranged engagement distances should load from their definitions.")
	formation_depths.sort()
	var depth_spacing_valid := formation_depths.size() == 6
	for index in range(1, formation_depths.size()):
		depth_spacing_valid = depth_spacing_valid and formation_depths[index] - formation_depths[index - 1] >= 28.0
	_check(depth_spacing_valid, "Six configured squad depth positions should be unique with at least 28 world units between adjacent positions.")
	_check(movement_speeds == [52.0, 36.0, 43.0, 49.0, 58.0, 66.0], "Each squad slot should load its configured, distinct movement speed.")
	var start_positions: Array[float] = []
	for ally in director.allies:
		start_positions.append(float(ally["x"]))
	director.enemy_x = 1000.0
	director._simulate_allies(0.1)
	for index in range(director.allies.size()):
		var expected_x: float = start_positions[index] + movement_speeds[index] * 0.1
		_check(is_equal_approx(float(director.allies[index]["x"]), expected_x), "Each ally's approach movement should use its own configured speed.")
	_test_melee_and_ranged_engagement(director)
	for ally in director.allies:
		ally["hp"] = 70.0
		director.allies[0]["hp"] = 120.0
		ally["x"] = 100.0
	director.allies[1]["x"] = 300.0
	for index in range(2, director.allies.size()):
		director.allies[index]["hp"] = 0.0
	director.enemy_x = 304.0
	_check(director._select_enemy_target() == 1, "Automatic enemy targeting should choose the nearest living ally.")
	var health_before: float = director.allies[1]["hp"]
	director.enemy_attack_elapsed = float(director.enemy_def["attack_interval"])
	director._simulate_enemy(0.05)
	_check(is_equal_approx(float(director.allies[1]["hp"]), health_before - director._enemy_attack_power()), "Enemy damage should be applied to its automatically selected ally.")
	_check(director.allies[1]["animation"] == "hit", "The selected ally should receive hit presentation state.")
	director.queue_free()


func _test_melee_and_ranged_engagement(director) -> void:
	for ally in director.allies:
		ally["hp"] = 0.0
	var melee: Dictionary = director.allies[0]
	melee["hp"] = 120.0
	melee["x"] = 295.0
	melee["attack_elapsed"] = 0.0
	director.allies[0] = melee
	director.enemy_x = 300.0
	director._simulate_allies(0.1)
	_check(is_equal_approx(float(director.allies[0]["x"]), 296.0), "Melee should advance until it reaches the 4-unit contact distance without overshooting.")
	var melee_x_at_contact: float = float(director.allies[0]["x"])
	director._simulate_allies(0.1)
	_check(is_equal_approx(float(director.allies[0]["x"]), melee_x_at_contact) and str(director.allies[0]["animation"]) == "idle", "Melee should hold at contact instead of advancing to its attack range.")

	for ranged_index in [1, 2]:
		for ally in director.allies:
			ally["hp"] = 0.0
		var ranged: Dictionary = director.allies[ranged_index]
		ranged["hp"] = float(ranged["max_hp"])
		ranged["x"] = 100.0
		ranged["attack_elapsed"] = 0.0
		director.allies[ranged_index] = ranged
		director.enemy_x = 300.0
		director.enemy_hp = 1000.0
		director._simulate_allies(10.0)
		var stand_off_x := 300.0 - float(ranged["engagement_distance"])
		_check(is_equal_approx(float(director.allies[ranged_index]["x"]), stand_off_x), "Ranged slot %02d should stop at its configured engagement distance." % (ranged_index + 1))
		_check(is_equal_approx(director.enemy_x - float(director.allies[ranged_index]["x"]), float(director.allies[ranged_index]["engagement_distance"])), "Ranged slot %02d should hold its configured stand-off distance." % (ranged_index + 1))
		ranged = director.allies[ranged_index]
		ranged["attack_elapsed"] = float(ranged["attack_interval"])
		director.allies[ranged_index] = ranged
		var enemy_hp_before: float = director.enemy_hp
		director._simulate_allies(0.01)
		_check(is_equal_approx(float(director.allies[ranged_index]["x"]), stand_off_x) and director.enemy_hp < enemy_hp_before, "Ranged slot %02d should attack without closing inside its configured engagement distance." % (ranged_index + 1))

	for ally in director.allies:
		ally["hp"] = 0.0
	var target: Dictionary = director.allies[0]
	target["hp"] = 120.0
	target["x"] = 100.0
	director.allies[0] = target
	director.enemy_x = 200.0
	director._simulate_enemy(10.0)
	_check(is_equal_approx(director.enemy_x - float(director.allies[0]["x"]), 4.0), "The configured melee grunt should advance to its 4-unit contact distance.")


func _sum_ally_hp(director) -> float:
	var total := 0.0
	for ally in director.allies:
		total += float(ally["hp"])
	return total


func _test_defeat_retreat() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	director.wave = 5
	director.highest_cleared_wave = 3
	director.enemy_x = 504.0
	for ally in director.allies:
		ally["x"] = 500.0
		ally["hp"] = 1.0
	for _attack_index in range(director.allies.size()):
		director.enemy_attack_elapsed = float(director.enemy_def["attack_interval"])
		director._step(0.05)
	_check(director.phase == "retreat", "Defeating the full squad should trigger automatic retreat.")
	_check(director.wave == 3, "Retreat should return to the highest previously cleared holding wave.")
	director.phase_timer = 0.01
	director._step(0.05)
	_check(director.phase == "combat" and director.wave == 3, "Automatic retreat should resume combat at the holding wave.")
	director.queue_free()


func _test_hp_carryover_and_natural_retreat() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var carried_hp: Array[float] = []
	for index in range(director.allies.size()):
		director.allies[index]["hp"] = maxf(0.0, float(director.allies[index]["max_hp"]) - 25.0 * float(index + 1))
		carried_hp.append(float(director.allies[index]["hp"]))
	director.snapshot()
	director.wave = 2
	director._begin_encounter()
	var retained_hp := true
	var defeated_slots_stay_down := true
	for index in range(director.allies.size()):
		retained_hp = retained_hp and is_equal_approx(float(director.allies[index]["hp"]), carried_hp[index])
		if carried_hp[index] <= 0.0:
			defeated_slots_stay_down = defeated_slots_stay_down and str(director.allies[index]["animation"]) == "defeated"
	_check(retained_hp, "Starting a wave after victory should preserve each ally's remaining HP, including defeated allies.")
	_check(defeated_slots_stay_down, "Allies carried at 0 HP must remain visually defeated in the next wave.")
	director.wave = 1
	for ally in director.allies:
		ally["hp"] = float(ally["max_hp"])
	director._begin_encounter()

	var reached_retreat := false
	for _step_index in range(20000):
		director._step(director.FIXED_STEP)
		if director.phase == "retreat":
			reached_retreat = true
			break
	_check(reached_retreat, "The configured carryover-HP prototype encounter should naturally reach full-squad defeat before the wave cap.")
	_check(director.highest_cleared_wave >= 1 and director.wave == director.highest_cleared_wave, "Natural defeat should retreat to the highest successfully cleared holding wave.")
	_check(director._living_ally_count() == 0, "Retreat should begin only after the entire squad is defeated.")
	if reached_retreat:
		print("Carryover-HP retreat reached: wave %d, highest cleared %d, sim time %.1f s." % [director.wave, director.highest_cleared_wave, director.sim_time])
		director.phase_timer = 0.01
		director._step(director.FIXED_STEP)
		var recovered_to_full: bool = director.phase == "combat" and director.wave == director.highest_cleared_wave
		for ally in director.allies:
			recovered_to_full = recovered_to_full and is_equal_approx(float(ally["hp"]), float(ally["max_hp"]))
		_check(recovered_to_full, "After retreat, the holding-wave encounter should restart with the full squad restored.")
	director.queue_free()


func _test_wave_cap() -> void:
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var capped_clear_events: Array[int] = []
	director.wave_cleared.connect(func(wave_number: int, _credit_reward: int, _run_high_water: int, _boss_id: String) -> void:
		capped_clear_events.append(wave_number)
	)
	var configured_limit := int(director.wave_def["last_wave"])
	_check(configured_limit == SAVE_SCRIPT.MAX_PROTOTYPE_WAVE, "Combat progression and save validation should share the same prototype horizon.")
	director.wave = configured_limit
	director._begin_encounter()
	director.allies[0]["x"] = 500.0
	director.enemy_x = 504.0
	director.enemy_hp = 1.0
	director.allies[0]["attack_elapsed"] = float(director.player_def["attack_interval"])
	director._step(director.FIXED_STEP)
	_check(director.phase == "intermission" and director.wave == configured_limit and director.wave_limit_reached, "The prototype progression fixture should stop advancing at its configured wave limit.")
	_check(capped_clear_events == [configured_limit], "The configured final wave should emit one structured clear event before the prototype-complete state.")
	director.phase_timer = 0.01
	director._step(director.FIXED_STEP)
	_check(director.phase == "prototype_complete", "The configured wave cap should enter a clear prototype-complete state.")
	director.wave = 25
	_check(director.snapshot()["district_name"] == "Undercity Prototype", "Waves through 25 should retain the explicit Undercity prototype label.")
	director.wave = 26
	_check(director.snapshot()["district_name"] == "Progression Test Fixture", "Waves beyond 25 should be labeled as test progression, not as authored district content.")
	director.queue_free()


func _test_modular_encounter_zone_transition() -> void:
	var environment = ENVIRONMENT_DIRECTOR_SCRIPT.new()
	root.add_child(environment)
	_check(environment.active_zone_id == "undercity_proto_01", "The environment director should load the first Undercity zone data module.")
	_check(environment.zone_for_wave(12).get("zone_id", "") == "undercity_proto_01", "Wave 12 should remain in the first provisional zone.")
	_check(environment.zone_for_wave(13).get("zone_id", "") == "undercity_proto_02", "Wave 13 should select the second provisional zone boundary.")
	_check(environment.zone_for_wave(26).is_empty(), "The prototype zones should not claim content beyond the Undercity wave cap.")
	_check(not environment.apply_wave(12), "Advancing inside one zone should not start a redundant transition.")
	var changes: Array[String] = []
	environment.zone_changed.connect(func(previous_id: String, current_id: String, changed_wave: int) -> void:
		changes.append("%s>%s@%d" % [previous_id, current_id, changed_wave])
	)
	_check(environment.apply_wave(13), "A configured zone boundary should start a transition.")
	_check(environment.active_zone_id == "undercity_proto_02", "The target module should become active immediately for presentation state.")
	_check(environment.get_child_count() == 2, "Crossfading should retain outgoing and incoming backdrops together.")
	_check(changes.size() == 1 and str(changes[0]).contains("undercity_proto_02") and str(changes[0]).ends_with("@13"), "Zone transitions should emit one presentation event with the crossed wave. Actual: %s" % [changes])
	var incoming: Node2D = environment.active_backdrop
	_check(is_equal_approx(incoming.modulate.a, 0.0), "The incoming backdrop should begin transparent for a crossfade.")
	_check(environment.apply_wave(1), "A rapid return across the boundary should replace an in-progress zone transition.")
	await process_frame
	_check(environment.active_zone_id == "undercity_proto_01" and environment.get_child_count() == 2, "An interrupted crossfade should keep only its prior active backdrop and the newest target module after queued cleanup.")
	_check(changes.size() == 2 and str(changes[1]).ends_with("undercity_proto_01@1"), "A rapid reverse transition should emit one new presentation event for its requested wave.")
	_check(environment.active_backdrop.modulate.a < 0.99, "The replacement target should still be inside its own crossfade after the earlier transition is interrupted.")
	await create_timer(1.0).timeout
	await process_frame
	_check(environment.get_child_count() == 1 and environment.active_zone_id == "undercity_proto_01" and environment.active_backdrop.modulate.a > 0.99, "The replacement crossfade should finish with only its fully visible target zone remaining.")
	environment.queue_free()
	await process_frame


func _test_breaker_tier_one_rig() -> void:
	var rig = BREAKER_RIG_SCRIPT.new()
	root.add_child(rig)
	_check(rig.skeleton is Skeleton2D, "BREAKER placeholder should use a Skeleton2D hierarchy.")
	_check(rig.bones.has("signature_right_fist"), "Tier I rig should expose its asymmetric signature right fist.")
	_check(rig.parts.has("facial_scars") and rig.parts.has("neck_regulator") and rig.parts.has("left_knee_brace"), "Tier I signature visual components should be present.")
	_check(rig.anchors.has("fx_anchor_ground") and rig.anchors.has("fx_anchor_neck") and rig.anchors.has("fx_anchor_fist_r"), "The presentation rig should expose stable ground, neck, and signature fist effect anchors.")
	_check(rig.find_children("*", "CollisionShape2D", true, false).is_empty() and rig.find_children("*", "CollisionPolygon2D", true, false).is_empty(), "The visual rig must not own combat collision shapes or polygons.")
	_check(rig.set_tier(1), "Tier I should be selectable.")
	_check(not rig.set_tier(2), "Unbuilt evolution tiers must not be exposed as implemented.")
	rig.present(123.0, "idle", 1.0)
	var ground_anchor_before_flip: Vector2 = rig.get_anchor_global_position(&"fx_anchor_ground")
	var fist_anchor_before_flip: Vector2 = rig.get_anchor_global_position(&"fx_anchor_fist_r")
	var breaker_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters/breaker_t1.json"))
	var configured_durations: Dictionary = breaker_config.get("animation_durations", {})
	rig.set_animation_durations(configured_durations)
	var walk_bone := rig.bones["thigh_left"] as Bone2D
	walk_bone.rotation = 0.7
	var transition_start := walk_bone.rotation
	rig.present(123.0, "walk", 1.0)
	rig._process(0.01)
	var first_walk_target := sin(rig.animation_clock * TAU / float(configured_durations["walk"])) * 0.22
	var first_walk_rotation := walk_bone.rotation
	_check(absf(first_walk_rotation - transition_start) < absf(first_walk_target - transition_start) and absf(first_walk_rotation - first_walk_target) < absf(transition_start - first_walk_target), "A walk state change should blend gradually from the current bone rotation instead of snapping.")
	rig._process(float(rig.POSE_TRANSITION_DURATION) - 0.01)
	var completed_walk_target := sin(rig.animation_clock * TAU / float(configured_durations["walk"])) * 0.22
	_check(rig.pose_transition_from.is_empty() and is_equal_approx(walk_bone.rotation, completed_walk_target), "The eased bone transition should reach the intended walk pose when complete.")
	rig.animation_clock = float(configured_durations["walk"]) * 0.75
	rig._process(0.0)
	var opposite_thigh := rig.bones["thigh_right"] as Bone2D
	var left_ankle := rig.bones["ankle_left"] as Bone2D
	var natural_arm := rig.bones["shoulder_left"] as Bone2D
	var cyber_arm := rig.bones["shoulder_right"] as Bone2D
	_check(walk_bone.rotation * opposite_thigh.rotation < 0.0, "Walking legs should swing in opposite directions.")
	_check(absf(left_ankle.rotation) > 0.1, "The ankle should counter-rotate during the gait to keep BREAKER's boot closer to level.")
	_check(walk_bone.rotation * (natural_arm.rotation - 0.1) < 0.0, "The natural arm should counter-swing against the leg.")
	_check(absf(cyber_arm.rotation - 0.06) < absf(natural_arm.rotation - 0.1), "The heavier cyber arm should use a smaller stride swing than the natural arm.")
	_check(rig.get_anchor_global_position(&"fx_anchor_ground").is_equal_approx(ground_anchor_before_flip), "Locomotion pose updates must preserve the world ground anchor.")
	for action in ["punch", "hit"]:
		rig.play_action(action)
		_check(is_equal_approx(rig.action_time_left, float(configured_durations[action])), "%s duration should remain sourced from the BREAKER config." % action)
	rig.play_action("defeat")
	_check(rig.animation_state == "defeated" and is_equal_approx(rig.action_time_left, float(configured_durations["defeated"])), "Defeat duration should remain sourced from the BREAKER config.")
	rig.set_facing_right(false)
	_check(is_equal_approx(rig.position.x, 123.0) and rig.skeleton.scale.x < 0.0, "Facing should flip visuals without changing the gameplay anchor.")
	_check(rig.get_anchor_global_position(&"fx_anchor_ground").is_equal_approx(ground_anchor_before_flip), "Facing changes must not move BREAKER's ground anchor.")
	_check(rig.get_anchor_global_position(&"fx_anchor_fist_r").x < fist_anchor_before_flip.x, "The signature fist effect anchor should follow the flipped visual rig.")
	var position_before_action: Vector2 = rig.position
	var hp_before_action: float = rig.hp_ratio
	rig.play_action("punch")
	_check(rig.position.is_equal_approx(position_before_action) and is_equal_approx(rig.hp_ratio, hp_before_action), "Presentation actions must not alter simulation position or health.")
	rig.set_facing_right(true)
	rig.queue_free()


func _test_local_breaker_atlas_drafts() -> void:
	var draft_specs := [
		{"path": "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_parts_atlas_draft_01.png", "empty_sample": Vector2i(10, 500), "part_sample": Vector2i(100, 100)},
		{"path": "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_parts_atlas_draft_02.png", "empty_sample": Vector2i(800, 20), "part_sample": Vector2i(100, 100)}
	]
	_check(FileAccess.file_exists("res://assets/characters/breaker/tier_01_drafts/.gdignore"), "Local art drafts should remain excluded from Godot's runtime import scan.")
	for spec in draft_specs:
		var image_path: String = ProjectSettings.globalize_path(str(spec["path"]))
		var image := Image.load_from_file(image_path)
		_check(image != null, "Local BREAKER draft should load from its quarantined workspace path: %s" % str(spec["path"]))
		if image == null:
			continue
		_check(image.get_size() == Vector2i(1536, 1024), "Local BREAKER draft should preserve the 1536x1024 atlas canvas.")
		var image_format: int = image.get_format()
		var has_rgba_format := image_format in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAH, Image.FORMAT_RGBAF]
		_check(has_rgba_format, "Local BREAKER draft should load in an RGBA image format.")
		if has_rgba_format:
			var empty_sample: Vector2i = spec["empty_sample"]
			var part_sample: Vector2i = spec["part_sample"]
			_check(image.get_pixel(empty_sample.x, empty_sample.y).a <= 0.01, "Local BREAKER draft should have transparent alpha in the sampled gutter.")
			_check(image.get_pixel(part_sample.x, part_sample.y).a >= 0.95, "Local BREAKER draft should retain opaque sprite content in the sampled part.")


func _test_breaker_head_art_trial() -> void:
	var asset_path := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_head_candidate_01.png"
	var image := Image.load_from_file(ProjectSettings.globalize_path(asset_path))
	_check(image != null, "Quarantined BREAKER head candidate should load for an isolated rig trial.")
	if image == null:
		return
	_check(image.get_size() == Vector2i(1254, 1254), "The head candidate's actual generated dimensions should be recorded and stable for its trial metadata.")
	_check(image.get_format() in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAH, Image.FORMAT_RGBAF], "Head candidate should have alpha-capable RGBA data.")
	_check(image.get_pixel(0, 0).a <= 0.01 and image.get_pixel(600, 600).a >= 0.95, "Head candidate should have transparent canvas and opaque head pixels.")
	var texture := ImageTexture.create_from_image(image)
	var rig = BREAKER_RIG_SCRIPT.new()
	root.add_child(rig)
	rig.present(123.0, "idle", 0.73, 510.0)
	var root_anchor_before := rig.get_anchor_global_position(&"fx_anchor_ground")
	var root_position_before: Vector2 = rig.position
	var hp_before: float = rig.hp_ratio
	var pivot_px := Vector2(571.0, 1156.0)
	var display_height := 29.0
	_check(rig.set_head_art(texture, pivot_px, display_height), "An alpha head texture with an in-bounds neck pivot should attach to the visual head bone.")
	_check(rig.head_art_sprite != null and is_equal_approx(rig.head_art_sprite.scale.y, display_height / float(image.get_height())), "Head trial should scale from the configured displayed art height without changing world scale elsewhere.")
	_check(rig.head_art_sprite.to_global(pivot_px).is_equal_approx((rig.bones["head"] as Bone2D).global_position), "Configured neck pivot should map exactly to the head-bone origin.")
	_check(not rig.parts["face"].visible and not rig.parts["facial_scars"].visible, "Head art trial should hide corresponding polygon placeholders to avoid doubled features.")
	_check(rig.get_anchor_global_position(&"fx_anchor_ground").is_equal_approx(root_anchor_before) and rig.position.is_equal_approx(root_position_before) and is_equal_approx(rig.hp_ratio, hp_before), "Attaching visual head art must not modify simulation position, ground anchor, or health.")
	_check(not rig.set_head_art(texture, Vector2(-1.0, 0.0), display_height), "An out-of-bounds art pivot should be rejected.")
	var head_point_before_flip: Vector2 = rig.head_art_sprite.to_global(Vector2(100.0, 600.0))
	rig.set_facing_right(false)
	_check(rig.get_anchor_global_position(&"fx_anchor_ground").is_equal_approx(root_anchor_before), "The art trial must retain the ground anchor when facing left.")
	_check(rig.head_art_sprite.to_global(Vector2(100.0, 600.0)).x > head_point_before_flip.x, "The isolated head sprite should mirror with the visual skeleton while its ground anchor stays fixed.")
	rig.queue_free()


func _test_save_sections_round_trip() -> void:
	var permanent := {"lifetime_influence": 123, "spendable_influence": 27, "highest_wave_ever": 125, "evolution_materials": {"evolution_data": 4}, "first_clear_material_claims": ["district.undercity"], "research": {"damage": 2}, "evolution": {"breaker_tier": "Origin Form"}, "unlocks": []}
	var run := {"credits": 456, "wave": 125, "highest_cleared_wave": 124, "recruits": {"breaker": {"level": 7}}, "squad_hp": [90.0, 61.0, 52.0, 43.0, 34.0, 25.0], "offline_claim_unix": 1792861200}
	var settings := {"master_volume": 0.65, "window_mode": "windowed"}
	var write_error: Error = SAVE_SCRIPT.save_game(permanent, run, settings, _test_disk_save_path())
	_check(write_error == OK, "Test save should write successfully at %s (error %d)." % [_test_disk_save_path(), write_error])
	var loaded: Dictionary = SAVE_SCRIPT.load_game(_test_disk_save_path())
	_check(loaded.get("ok", false), "Test save should load successfully (%s)." % str(loaded.get("error", "unknown error")))
	if not loaded.get("ok", false):
		return
	var payload: Dictionary = loaded["data"]
	_check(payload["save_version"] == SAVE_SCRIPT.SAVE_VERSION, "Save payload should carry its schema version.")
	_check(payload["permanent"]["lifetime_influence"] == 123, "Permanent state should remain in its own section.")
	_check(payload["permanent"]["spendable_influence"] == 27, "Spendable Influence should round-trip in permanent state.")
	_check(int(payload["permanent"]["highest_wave_ever"]) == 125, "First-cleared-ever wave-125 progression should round-trip in permanent state.")
	_check(payload["permanent"]["evolution_materials"]["evolution_data"] == 4, "Evolution material inventory should round-trip in permanent state.")
	_check(payload["permanent"]["first_clear_material_claims"] == ["district.undercity"], "First-clear material claim ledger should round-trip in permanent state.")
	_check(payload["run"]["credits"] == 456, "Run state should remain in its own section.")
	_check(payload["run"]["squad_hp"] == run["squad_hp"], "Saved run should preserve per-slot squad HP for wave carryover.")
	_check(payload["run"]["offline_claim_unix"] == run["offline_claim_unix"], "Optional offline claim timestamp should round-trip in run state.")
	_check(payload["settings"]["master_volume"] == 0.65, "Settings should remain in their own section.")
	_check(not _contains_movement_preference_key(payload["run"]), "Run saves must not serialize movement speeds as player preferences.")
	_check(not _contains_movement_preference_key(payload["settings"]), "Settings saves must not serialize movement speeds as player preferences.")
	var director = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	var saved_run: Dictionary = payload["run"]
	var saved_recruits: Dictionary = saved_run["recruits"]
	director.load_run_state({
		"credits": saved_run["credits"],
		"wave": saved_run.get("wave", 1),
		"highest_cleared_wave": saved_run.get("highest_cleared_wave", 0),
		"recruit_level": saved_recruits["breaker"]["level"],
		"squad_hp": saved_run.get("squad_hp", [])
	})
	var restored: Dictionary = director.snapshot()
	_check(restored["credits"] == 456 and restored["recruit_level"] == 7 and restored["wave"] == 125 and restored["highest_cleared_wave"] == 124, "Run save should restore credits, recruit level, and the wave-125 test progression state.")
	var restored_hp: Array[float] = []
	for ally in restored["allies"]:
		restored_hp.append(float(ally["hp"]))
	_check(restored_hp == run["squad_hp"], "Loading should restore each ally's carried HP before the current wave resumes.")
	director.load_run_state({"credits": 20, "wave": 1, "highest_cleared_wave": 0, "recruit_level": 1})
	var legacy_hp_defaults_to_full := true
	for ally in director.allies:
		legacy_hp_defaults_to_full = legacy_hp_defaults_to_full and is_equal_approx(float(ally["hp"]), float(ally["max_hp"]))
	_check(legacy_hp_defaults_to_full, "Older version-1 saves without squad_hp should load with a fresh full-health squad.")
	director.queue_free()
	var bad_version_file := FileAccess.open(_test_disk_save_path(), FileAccess.WRITE)
	bad_version_file.store_string("{\"save_version\":0,\"permanent\":{},\"run\":{},\"settings\":{}}")
	bad_version_file.close()
	_check(not SAVE_SCRIPT.load_game(_test_disk_save_path()).get("ok", false), "Unsupported save versions should be rejected.")
	DirAccess.remove_absolute(_test_disk_save_path())


func _test_save_validation_rejects_invalid_data() -> void:
	_assert_invalid_save_json("not-json", "Invalid JSON should fail safely.")
	_assert_invalid_save_json("{\"save_version\":1,\"permanent\":{", "Truncated JSON should fail safely.")

	var valid_payload := _valid_test_save_payload()
	for section in ["permanent", "run", "settings"]:
		var missing_section: Dictionary = valid_payload.duplicate(true)
		missing_section.erase(section)
		_assert_invalid_save_payload(missing_section, "Missing top-level %s section should be rejected." % section)
		var wrong_section_type: Dictionary = valid_payload.duplicate(true)
		wrong_section_type[section] = []
		_assert_invalid_save_payload(wrong_section_type, "Non-object top-level %s section should be rejected." % section)

	var invalid_payloads: Array[Dictionary] = []
	var bad := valid_payload.duplicate(true)
	bad["save_version"] = "1"
	invalid_payloads.append({"payload": bad, "message": "String save version should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["lifetime_influence"] = "123"
	invalid_payloads.append({"payload": bad, "message": "String lifetime influence should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["spendable_influence"] = -1
	invalid_payloads.append({"payload": bad, "message": "Negative spendable influence should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["highest_wave_ever"] = 126
	invalid_payloads.append({"payload": bad, "message": "Permanent highest wave beyond the current prototype cap should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["wave"] = 126
	invalid_payloads.append({"payload": bad, "message": "Run wave beyond the current prototype cap should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["highest_cleared_wave"] = 126
	invalid_payloads.append({"payload": bad, "message": "Run high-water beyond the current prototype cap should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["evolution_materials"] = {"evolution_data": -1}
	invalid_payloads.append({"payload": bad, "message": "Negative evolution material counts should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["evolution_materials"] = []
	invalid_payloads.append({"payload": bad, "message": "Evolution material inventory with the wrong type should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["evolution_materials"] = {"evolution_data ": 2}
	invalid_payloads.append({"payload": bad, "message": "Non-canonical whitespace in evolution material IDs should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["first_clear_material_claims"] = ["district.undercity", "district.undercity"]
	invalid_payloads.append({"payload": bad, "message": "Duplicate permanent first-clear claim IDs should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["first_clear_material_claims"] = [""]
	invalid_payloads.append({"payload": bad, "message": "Empty permanent first-clear claim IDs should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["first_clear_material_claims"] = ["district.undercity "]
	invalid_payloads.append({"payload": bad, "message": "Non-canonical whitespace in permanent first-clear IDs should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["research"] = []
	invalid_payloads.append({"payload": bad, "message": "Research with the wrong type should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["evolution"] = "Origin Form"
	invalid_payloads.append({"payload": bad, "message": "Evolution with the wrong type should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["unlocks"] = {}
	invalid_payloads.append({"payload": bad, "message": "Unlocks with the wrong type should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"].erase("recruits")
	invalid_payloads.append({"payload": bad, "message": "Missing recruit data should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"] = []
	invalid_payloads.append({"payload": bad, "message": "Recruit data with the wrong type should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"].erase("breaker")
	invalid_payloads.append({"payload": bad, "message": "Missing nested BREAKER run data should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"]["breaker"] = 7
	invalid_payloads.append({"payload": bad, "message": "BREAKER run data with the wrong type should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"]["breaker"].erase("level")
	invalid_payloads.append({"payload": bad, "message": "Missing BREAKER level should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["credits"] = "456"
	invalid_payloads.append({"payload": bad, "message": "String credits should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["wave"] = "5"
	invalid_payloads.append({"payload": bad, "message": "String wave should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["highest_cleared_wave"] = false
	invalid_payloads.append({"payload": bad, "message": "Boolean holding wave should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"]["breaker"]["level"] = "7"
	invalid_payloads.append({"payload": bad, "message": "String BREAKER level should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["settings"]["master_volume"] = "loud"
	invalid_payloads.append({"payload": bad, "message": "String master volume should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["settings"]["window_mode"] = true
	invalid_payloads.append({"payload": bad, "message": "Boolean window mode should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["credits"] = -1
	invalid_payloads.append({"payload": bad, "message": "Negative credits should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["credits"] = 456.5
	invalid_payloads.append({"payload": bad, "message": "Fractional credits should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["wave"] = 0
	invalid_payloads.append({"payload": bad, "message": "Wave zero should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["wave"] = 126
	invalid_payloads.append({"payload": bad, "message": "Wave above the prototype progression cap should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["highest_cleared_wave"] = -1
	invalid_payloads.append({"payload": bad, "message": "Negative highest-cleared wave should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["highest_cleared_wave"] = 126
	invalid_payloads.append({"payload": bad, "message": "Highest-cleared wave above the prototype progression cap should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"]["breaker"]["level"] = 0
	invalid_payloads.append({"payload": bad, "message": "BREAKER level zero should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["recruits"]["breaker"]["level"] = 1.5
	invalid_payloads.append({"payload": bad, "message": "Fractional BREAKER level should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["squad_hp"] = [120, 70]
	invalid_payloads.append({"payload": bad, "message": "Squad HP with the wrong number of slots should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["squad_hp"] = [120, 70, 70, 70, 70, -1]
	invalid_payloads.append({"payload": bad, "message": "Negative squad HP should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["squad_hp"] = [120, 70, 70, 70, 70, "70"]
	invalid_payloads.append({"payload": bad, "message": "String squad HP should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["offline_claim_unix"] = -1
	invalid_payloads.append({"payload": bad, "message": "Negative offline-claim timestamp should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["run"]["offline_claim_unix"] = 1000.5
	invalid_payloads.append({"payload": bad, "message": "Fractional offline-claim timestamp should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["permanent"]["lifetime_influence"] = -1
	invalid_payloads.append({"payload": bad, "message": "Negative lifetime influence should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["settings"]["master_volume"] = -0.01
	invalid_payloads.append({"payload": bad, "message": "Master volume below zero should be rejected."})
	bad = valid_payload.duplicate(true)
	bad["settings"]["master_volume"] = 1.01
	invalid_payloads.append({"payload": bad, "message": "Master volume above one should be rejected."})

	for test_case in invalid_payloads:
		_assert_invalid_save_payload(test_case["payload"], test_case["message"])

	var valid_json := JSON.stringify(valid_payload)
	var valid_file := FileAccess.open(_test_disk_save_path(), FileAccess.WRITE)
	_check(valid_file != null, "Test save path should remain writable after invalid save attempts.")
	if valid_file != null:
		valid_file.store_string(valid_json)
		valid_file.close()
	var recovered := SAVE_SCRIPT.load_game(_test_disk_save_path())
	_check(recovered.get("ok", false), "A valid save should load after malformed inputs fail safely (%s)." % str(recovered.get("error", "unknown error")))
	DirAccess.remove_absolute(_test_disk_save_path())


func _test_save_protection_and_recovery_policy() -> void:
	var future_payload := _save_test_payload(777)
	future_payload["save_version"] = SAVE_SCRIPT.SAVE_VERSION + 1
	var future_text := JSON.stringify(future_payload)
	var unsupported_ops := _MemoryFileOps.new()
	unsupported_ops.files[FAULT_SAVE_PATH] = future_text
	unsupported_ops.files[FAULT_SAVE_PATH + ".bak"] = JSON.stringify(_save_test_payload(200))
	unsupported_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = JSON.stringify(_save_test_payload(100))
	var unsupported_files_before: Dictionary = unsupported_ops.files.duplicate(true)
	var unsupported_save_error: Error = _attempt_injected_save(unsupported_ops, 900)
	_check(unsupported_save_error == SAVE_SCRIPT.SAVE_PROTECTED_ERROR and unsupported_ops.files == unsupported_files_before, "Ordinary Save must leave an unsupported-schema primary and all recovery sidecars byte-for-byte unchanged, even when older backups are valid.")

	var corrupt_ops := _MemoryFileOps.new()
	corrupt_ops.files[FAULT_SAVE_PATH] = "{corrupt primary"
	corrupt_ops.files[FAULT_SAVE_PATH + ".bak"] = "{corrupt backup"
	corrupt_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = "{corrupt previous backup"
	var corrupt_files_before: Dictionary = corrupt_ops.files.duplicate(true)
	var corrupt_save_error: Error = _attempt_injected_save(corrupt_ops, 900)
	_check(corrupt_save_error == SAVE_SCRIPT.SAVE_PROTECTED_ERROR and corrupt_ops.files == corrupt_files_before and not corrupt_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Ordinary Save must block when every save candidate is corrupt and preserve the entire corrupt set without staging a replacement.")

	var malformed_version_cases: Array[Dictionary] = []
	var malformed_version_payload := _save_test_payload(300)
	malformed_version_payload["save_version"] = null
	malformed_version_cases.append({"label": "null", "payload": malformed_version_payload})
	malformed_version_payload = _save_test_payload(300)
	malformed_version_payload["save_version"] = "1"
	malformed_version_cases.append({"label": "string", "payload": malformed_version_payload})
	malformed_version_payload = _save_test_payload(300)
	malformed_version_payload["save_version"] = 1.5
	malformed_version_cases.append({"label": "fractional", "payload": malformed_version_payload})
	malformed_version_payload = _save_test_payload(300)
	malformed_version_payload.erase("save_version")
	malformed_version_cases.append({"label": "missing", "payload": malformed_version_payload})
	for malformed_case in malformed_version_cases:
		var malformed_version_ops := _MemoryFileOps.new()
		malformed_version_ops.files[FAULT_SAVE_PATH] = JSON.stringify(malformed_case["payload"])
		var malformed_files_before: Dictionary = malformed_version_ops.files.duplicate(true)
		var malformed_save_error: Error = _attempt_injected_save(malformed_version_ops, 900)
		_check(not bool(SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, malformed_version_ops).get("ok", false)), "Save with %s version metadata must be rejected by the loader." % str(malformed_case["label"]))
		_check(malformed_save_error == SAVE_SCRIPT.SAVE_PROTECTED_ERROR and malformed_version_ops.files == malformed_files_before and not malformed_version_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Ordinary Save must protect a save with %s version metadata without changing it or staging a replacement." % str(malformed_case["label"]))

	var malformed_backup_ops := _MemoryFileOps.new()
	malformed_backup_ops.files[FAULT_SAVE_PATH] = JSON.stringify(_save_test_payload(300))
	malformed_backup_ops.files[FAULT_SAVE_PATH + ".bak"] = "{malformed backup"
	var malformed_backup_files_before: Dictionary = malformed_backup_ops.files.duplicate(true)
	var malformed_backup_save_error: Error = _attempt_injected_save(malformed_backup_ops, 900)
	_check(malformed_backup_save_error == SAVE_SCRIPT.SAVE_PROTECTED_ERROR and malformed_backup_ops.files == malformed_backup_files_before and not malformed_backup_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Ordinary Save must protect a malformed .bak beside a valid primary without changing any save-set bytes or staging a replacement.")

	var invalid_previous_payload := _save_test_payload(250)
	invalid_previous_payload["run"]["credits"] = -1
	var invalid_previous_ops := _MemoryFileOps.new()
	invalid_previous_ops.files[FAULT_SAVE_PATH] = JSON.stringify(_save_test_payload(300))
	invalid_previous_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = JSON.stringify(invalid_previous_payload)
	var invalid_previous_files_before: Dictionary = invalid_previous_ops.files.duplicate(true)
	var invalid_previous_save_error: Error = _attempt_injected_save(invalid_previous_ops, 900)
	_check(invalid_previous_save_error == SAVE_SCRIPT.SAVE_PROTECTED_ERROR and invalid_previous_ops.files == invalid_previous_files_before and not invalid_previous_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Ordinary Save must protect a supported-version but invalid .bak.prev beside a valid primary without changing any save-set bytes or staging a replacement.")

	var primary_payload := _save_test_payload(300)
	var backup_payload := _save_test_payload(200)
	var previous_payload := _save_test_payload(100)
	var precedence_ops := _MemoryFileOps.new()
	precedence_ops.files[FAULT_SAVE_PATH] = JSON.stringify(primary_payload)
	precedence_ops.files[FAULT_SAVE_PATH + ".bak"] = JSON.stringify(backup_payload)
	precedence_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = JSON.stringify(previous_payload)
	var primary_precedence: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, precedence_ops)
	_check(bool(primary_precedence.get("ok", false)) and int(primary_precedence["data"]["run"]["credits"]) == 300 and not bool(primary_precedence.get("recovered_from_backup", false)), "A valid primary must take precedence over both valid recovery sidecars.")
	precedence_ops.files[FAULT_SAVE_PATH] = "{corrupt primary"
	var backup_precedence: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, precedence_ops)
	_check(bool(backup_precedence.get("ok", false)) and int(backup_precedence["data"]["run"]["credits"]) == 200 and bool(backup_precedence.get("recovered_from_backup", false)), "When the primary is corrupt, a valid .bak must precede a valid .bak.prev.")
	precedence_ops.files[FAULT_SAVE_PATH + ".bak"] = "{corrupt backup"
	var previous_precedence: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, precedence_ops)
	_check(bool(previous_precedence.get("ok", false)) and int(previous_precedence["data"]["run"]["credits"]) == 100 and bool(previous_precedence.get("recovered_from_backup", false)), "A valid .bak.prev must be used after the primary and .bak are invalid.")
	precedence_ops.files.erase(FAULT_SAVE_PATH)
	precedence_ops.files[FAULT_SAVE_PATH + ".bak"] = JSON.stringify(backup_payload)
	var missing_primary_precedence: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, precedence_ops)
	_check(bool(missing_primary_precedence.get("ok", false)) and int(missing_primary_precedence["data"]["run"]["credits"]) == 200, "When the primary is missing, the valid .bak must precede .bak.prev.")

	var unknown_source := _save_test_payload(300)
	unknown_source["future_envelope"] = {"release": 2, "flags": ["root"]}
	unknown_source["future_root_array"] = ["future", {"revision": 3}]
	unknown_source["permanent"]["future_passive"] = {"id": "permanent.experimental", "rank": 3}
	unknown_source["permanent"]["research"]["future_branch"] = {"rank": 2, "modifiers": {"critical": 0.15}}
	unknown_source["permanent"]["research_nodes"] = {"combat.protocols.future_node": 2}
	unknown_source["permanent"]["evolution"]["future_recruit_tier"] = {"rank": 3, "visual_set": "prototype"}
	unknown_source["permanent"]["evolution_materials"] = {"evolution_data": 4, "future_material": 6}
	unknown_source["run"]["future_inventory"] = [{"item_id": "prototype_shard", "count": 4}]
	unknown_source["run"]["recruits"]["breaker"]["future_talent"] = {"id": "breaker.focus", "enabled": true}
	unknown_source["settings"]["future_accessibility"] = {"reduced_flash": true}
	var preservation_ops := _MemoryFileOps.new()
	preservation_ops.files[FAULT_SAVE_PATH] = JSON.stringify(unknown_source)
	var new_payload := _save_test_payload(900)
	new_payload["permanent"]["research"] = {"damage": 5}
	new_payload["permanent"]["research_nodes"] = {"combat.protocols.core": 1}
	new_payload["permanent"]["evolution"] = {"breaker_tier": "Adapted Form"}
	new_payload["permanent"]["evolution_materials"] = {"evolution_data": 9}
	var permanent_input_before: Dictionary = new_payload["permanent"].duplicate(true)
	var run_input_before: Dictionary = new_payload["run"].duplicate(true)
	var settings_input_before: Dictionary = new_payload["settings"].duplicate(true)
	var preservation_error: Error = SAVE_SCRIPT._save_game_with_file_ops(new_payload["permanent"], new_payload["run"], new_payload["settings"], FAULT_SAVE_PATH, preservation_ops)
	var preserved_load: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, preservation_ops)
	_check(preservation_error == OK and bool(preserved_load.get("ok", false)), "Ordinary Save should commit successfully while preserving unknown fields from a valid supported save.")
	if bool(preserved_load.get("ok", false)):
		var preserved_data: Dictionary = preserved_load["data"]
		_check(SAVE_SCRIPT._values_match(preserved_data.get("future_envelope", {}), unknown_source["future_envelope"]) and SAVE_SCRIPT._values_match(preserved_data["permanent"].get("future_passive", {}), unknown_source["permanent"]["future_passive"]), "Save should preserve unknown root and permanent fields (root=%s, permanent=%s)." % [str(preserved_data.get("future_envelope", null)), str(preserved_data["permanent"].get("future_passive", null))])
		_check(SAVE_SCRIPT._values_match(preserved_data.get("future_root_array", []), unknown_source["future_root_array"]), "Save should preserve unknown root array fields without mutating their nested values.")
		_check(SAVE_SCRIPT._values_match(preserved_data["permanent"]["research"].get("future_branch", {}), unknown_source["permanent"]["research"]["future_branch"]) and int(preserved_data["permanent"]["research"]["damage"]) == 5, "Save should preserve unknown nested research fields while applying the new known research value (research=%s)." % str(preserved_data["permanent"]["research"]))
		_check(SAVE_SCRIPT._values_match(preserved_data["permanent"]["research_nodes"].get("combat.protocols.future_node", null), unknown_source["permanent"]["research_nodes"]["combat.protocols.future_node"]) and int(preserved_data["permanent"]["research_nodes"]["combat.protocols.core"]) == 1, "Save should preserve future research-node entries while applying the new known node state.")
		_check(SAVE_SCRIPT._values_match(preserved_data["permanent"]["evolution"].get("future_recruit_tier", {}), unknown_source["permanent"]["evolution"]["future_recruit_tier"]) and preserved_data["permanent"]["evolution"].get("breaker_tier") == "Adapted Form", "Save should preserve unknown evolution data while applying the updated known tier.")
		_check(int(preserved_data["permanent"]["evolution_materials"].get("future_material", -1)) == 6 and int(preserved_data["permanent"]["evolution_materials"].get("evolution_data", -1)) == 9, "Save should preserve unknown material balances while applying the updated known balance.")
		_check(SAVE_SCRIPT._values_match(preserved_data["run"].get("future_inventory", []), unknown_source["run"]["future_inventory"]) and SAVE_SCRIPT._values_match(preserved_data["run"]["recruits"]["breaker"].get("future_talent", {}), unknown_source["run"]["recruits"]["breaker"]["future_talent"]), "Save should preserve unknown run and nested recruit fields (run=%s)." % str(preserved_data["run"]))
		_check(SAVE_SCRIPT._values_match(preserved_data["settings"].get("future_accessibility", {}), unknown_source["settings"]["future_accessibility"]) and int(preserved_data["run"]["credits"]) == 900, "Save should preserve unknown settings fields while applying the new run state.")
	_check(new_payload["permanent"] == permanent_input_before and new_payload["run"] == run_input_before and new_payload["settings"] == settings_input_before, "Unknown-field merging must not mutate the caller's permanent, run, or settings inputs.")

	var reset_path := ProjectSettings.globalize_path("res://tests/_confirmed_reset_policy_%d.json" % Time.get_ticks_usec())
	var unsupported_file := FileAccess.open(reset_path, FileAccess.WRITE)
	_check(unsupported_file != null, "A disposable unsupported-schema save should be writable for the explicit reset policy test.")	
	if unsupported_file != null:
		unsupported_file.store_string(future_text)
		unsupported_file.close()
	var unconfirmed_reset_error: Error = SAVE_SCRIPT.save_game_after_confirmed_reset(_save_test_payload(44)["permanent"], _save_test_payload(44)["run"], _save_test_payload(44)["settings"], reset_path, false)
	_check(unconfirmed_reset_error == SAVE_SCRIPT.SAVE_PROTECTED_ERROR and FileAccess.get_file_as_string(reset_path) == future_text, "Reset Save without explicit confirmation must leave the unsupported-schema file unchanged.")
	var reset_payload := _save_test_payload(44)
	var confirmed_reset_error: Error = SAVE_SCRIPT.save_game_after_confirmed_reset(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], reset_path, true)
	var confirmed_reset_load: Dictionary = SAVE_SCRIPT.load_game(reset_path)
	_check(confirmed_reset_error == OK and bool(confirmed_reset_load.get("ok", false)) and int(confirmed_reset_load["data"]["run"]["credits"]) == 44, "Only explicitly confirmed Reset Save may replace an unsupported-schema file with the new valid save.")

	var sidecar_reset_ops := _MemoryFileOps.new()
	var valid_reset_primary := JSON.stringify(_save_test_payload(30))
	var unsupported_sidecar_text := future_text + "\n"
	var valid_previous_sidecar := JSON.stringify(_save_test_payload(20))
	var unsupported_backup_path := FAULT_SAVE_PATH + ".bak"
	var unsupported_previous_path := FAULT_SAVE_PATH + ".bak.prev"
	sidecar_reset_ops.files[FAULT_SAVE_PATH] = valid_reset_primary
	sidecar_reset_ops.files[unsupported_backup_path] = unsupported_sidecar_text
	sidecar_reset_ops.files[unsupported_previous_path] = valid_previous_sidecar
	var sidecar_reset_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, sidecar_reset_ops, true)
	var quarantine_path := unsupported_backup_path + ".unsupported-quarantine-" + SAVE_SCRIPT._sha256_bytes(unsupported_sidecar_text.to_utf8_buffer())
	_check(sidecar_reset_error == OK and sidecar_reset_ops.files.get(quarantine_path, "") == unsupported_sidecar_text and SAVE_SCRIPT._sha256_bytes(str(sidecar_reset_ops.files.get(quarantine_path, "")).to_utf8_buffer()) == SAVE_SCRIPT._sha256_bytes(unsupported_sidecar_text.to_utf8_buffer()), "Confirmed Reset must preserve unsupported .bak bytes in a content-hash-named quarantine before removing the active sidecar.")
	_check(not sidecar_reset_ops.files.has(unsupported_backup_path) and sidecar_reset_ops.files.get(unsupported_previous_path, "") == valid_previous_sidecar, "After verified quarantine, confirmed Reset must remove only the unsupported active sidecar while retaining valid recovery data.")
	var post_reset_ordinary_save_error: Error = _attempt_injected_save(sidecar_reset_ops, 45)
	_check(post_reset_ordinary_save_error == OK, "After verified quarantine, ordinary saves must be allowed again.")

	var quarantine_copy_failure_ops := _MemoryFileOps.new()
	quarantine_copy_failure_ops.files[FAULT_SAVE_PATH] = valid_reset_primary
	quarantine_copy_failure_ops.files[unsupported_backup_path] = unsupported_sidecar_text
	quarantine_copy_failure_ops.fault = "quarantine_copy"
	var quarantine_copy_before: Dictionary = quarantine_copy_failure_ops.files.duplicate(true)
	var quarantine_copy_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, quarantine_copy_failure_ops, true)
	_check(quarantine_copy_error != OK and quarantine_copy_failure_ops.files == quarantine_copy_before, "A failed quarantine copy must abort confirmed Reset without changing the current save or unsupported sidecar.")

	var quarantine_verify_failure_ops := _MemoryFileOps.new()
	quarantine_verify_failure_ops.files[FAULT_SAVE_PATH] = valid_reset_primary
	quarantine_verify_failure_ops.files[unsupported_backup_path] = unsupported_sidecar_text
	quarantine_verify_failure_ops.fault = "quarantine_corrupt"
	var quarantine_verify_before: Dictionary = quarantine_verify_failure_ops.files.duplicate(true)
	var quarantine_verify_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, quarantine_verify_failure_ops, true)
	_check(quarantine_verify_error != OK and quarantine_verify_failure_ops.files == quarantine_verify_before, "A quarantine copy whose bytes or hash do not match must be removed and must not replace the active sidecar.")

	var quarantine_remove_failure_ops := _MemoryFileOps.new()
	quarantine_remove_failure_ops.files[FAULT_SAVE_PATH] = valid_reset_primary
	quarantine_remove_failure_ops.files[unsupported_backup_path] = unsupported_sidecar_text
	quarantine_remove_failure_ops.fail_remove_path = unsupported_backup_path
	var quarantine_remove_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, quarantine_remove_failure_ops, true)
	var quarantine_rollback_load: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, quarantine_remove_failure_ops)
	_check(quarantine_remove_error != OK and quarantine_remove_failure_ops.files.get(FAULT_SAVE_PATH, "") == valid_reset_primary and quarantine_remove_failure_ops.files.get(unsupported_backup_path, "") == unsupported_sidecar_text, "If active-sidecar removal fails after commit, Reset must roll back the primary and retain the original sidecar bytes.")
	_check(bool(quarantine_rollback_load.get("ok", false)) and quarantine_remove_failure_ops.files.has(quarantine_path), "Failed quarantine cleanup must leave the original save loadable and the verified quarantine copy recoverable.")

	var reset_restore_failure_ops := _MemoryFileOps.new()
	reset_restore_failure_ops.files[FAULT_SAVE_PATH] = valid_reset_primary
	reset_restore_failure_ops.files[unsupported_backup_path] = unsupported_sidecar_text
	reset_restore_failure_ops.fail_remove_path = unsupported_backup_path
	reset_restore_failure_ops.fault = "reset_restore_copy"
	var reset_restore_failure_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, reset_restore_failure_ops, true)
	var primary_restore_snapshot := FAULT_SAVE_PATH + ".confirmed-reset-rollback-" + SAVE_SCRIPT._sha256_bytes(valid_reset_primary.to_utf8_buffer())
	_check(reset_restore_failure_error != OK and not reset_restore_failure_ops.files.has(FAULT_SAVE_PATH) and reset_restore_failure_ops.files.get(primary_restore_snapshot, "") == valid_reset_primary, "If rollback itself cannot restore the original primary, its verified hash-named snapshot must remain available for recovery.")
	_check(reset_restore_failure_ops.files.get(unsupported_backup_path, "") == unsupported_sidecar_text and reset_restore_failure_ops.files.has(quarantine_path), "A rollback failure must retain the original unsupported sidecar and its verified quarantine copy.")

	var reset_open_failure_ops := _MemoryFileOps.new()
	reset_open_failure_ops.files[FAULT_SAVE_PATH] = future_text
	reset_open_failure_ops.files[FAULT_SAVE_PATH + ".bak"] = JSON.stringify(_save_test_payload(200))
	reset_open_failure_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = JSON.stringify(_save_test_payload(100))
	reset_open_failure_ops.fault = "open_write"
	var reset_open_files_before: Dictionary = reset_open_failure_ops.files.duplicate(true)
	var reset_open_failure_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, reset_open_failure_ops, true)
	_check(reset_open_failure_error != OK and reset_open_failure_ops.files == reset_open_files_before, "A confirmed Reset Save that cannot open its staging file must preserve the unsupported primary and both recovery sidecars byte-for-byte.")

	var reset_rollback_ops := _MemoryFileOps.new()
	reset_rollback_ops.files[FAULT_SAVE_PATH] = future_text
	reset_rollback_ops.files[FAULT_SAVE_PATH + ".bak"] = JSON.stringify(_save_test_payload(200))
	reset_rollback_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = JSON.stringify(_save_test_payload(100))
	reset_rollback_ops.fault = "partial_commit"
	var reset_rollback_error: Error = SAVE_SCRIPT._save_game_with_file_ops(reset_payload["permanent"], reset_payload["run"], reset_payload["settings"], FAULT_SAVE_PATH, reset_rollback_ops, true)
	var reset_rollback_load: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, reset_rollback_ops)
	_check(reset_rollback_error != OK and bool(reset_rollback_load.get("ok", false)) and int(reset_rollback_load["data"]["run"]["credits"]) == 200 and reset_rollback_ops.files.get(FAULT_SAVE_PATH, "") == future_text, "A confirmed Reset Save with a failed commit must restore the original unsupported primary byte-for-byte; load may then recover from the valid .bak.")
	_check(reset_rollback_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == JSON.stringify(_save_test_payload(200)) and reset_rollback_ops.files.get(FAULT_SAVE_PATH + ".bak.prev", "") == JSON.stringify(_save_test_payload(100)) and not reset_rollback_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Failed confirmed reset rollback must retain both recovery sidecars and clean the staged save.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var reset_artifact: String = reset_path + suffix
		if FileAccess.file_exists(reset_artifact):
			DirAccess.remove_absolute(reset_artifact)


func _test_save_ui_guard_and_confirmation() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var action_row := main.hud_panel.get_child(0).get_child(4) as HBoxContainer
	var save_button := action_row.get_child(2) as Button
	var reset_button := action_row.get_child(5) as Button
	_check(save_button != null and save_button.text == "Save" and save_button.pressed.is_connected(Callable(main, "_save")), "The live Save button should remain connected to the ordinary-save call site.")
	_check(reset_button != null and reset_button.text == "Reset Save" and reset_button.pressed.is_connected(Callable(main, "_request_save_reset_confirmation")), "The live Reset Save button should request confirmation before changing saved data.")
	if save_button == null or reset_button == null:
		main.queue_free()
		await process_frame
		return

	var save_path := ProjectSettings.globalize_path("res://tests/_save_ui_policy_%d.json" % Time.get_ticks_usec())
	main.save_path = save_path
	main.loaded_save_path = ""
	var future_payload := _save_test_payload(777)
	future_payload["save_version"] = SAVE_SCRIPT.SAVE_VERSION + 1
	var future_text := JSON.stringify(future_payload)
	var valid_backup_text := JSON.stringify(_save_test_payload(200))
	var valid_previous_text := JSON.stringify(_save_test_payload(100))
	var fixture_writes_ok := _write_text_fixture(save_path, future_text)
	fixture_writes_ok = _write_text_fixture(save_path + ".bak", valid_backup_text) and fixture_writes_ok
	fixture_writes_ok = _write_text_fixture(save_path + ".bak.prev", valid_previous_text) and fixture_writes_ok
	_check(fixture_writes_ok, "The isolated Reset Save UI fixture should write its primary and recovery sidecars.")
	if fixture_writes_ok:
		var cancel_snapshot := {
			save_path: FileAccess.get_file_as_string(save_path),
			save_path + ".bak": FileAccess.get_file_as_string(save_path + ".bak"),
			save_path + ".bak.prev": FileAccess.get_file_as_string(save_path + ".bak.prev")
		}
		reset_button.pressed.emit()
		_check(main.reset_save_confirmation.visible, "Pressing Reset Save should show the confirmation dialog before touching the save set.")
		main.reset_save_confirmation.get_cancel_button().pressed.emit()
		await process_frame
		var cancel_unchanged := true
		for artifact_path in cancel_snapshot:
			cancel_unchanged = cancel_unchanged and FileAccess.get_file_as_string(str(artifact_path)) == str(cancel_snapshot[artifact_path])
		_check(not main.reset_save_confirmation.visible and cancel_unchanged, "Canceling Reset Save must close the dialog and leave the primary plus both recovery sidecars byte-for-byte unchanged.")

		reset_button.pressed.emit()
		_check(main.reset_save_confirmation.visible, "A second Reset Save request should present confirmation again.")
		main.reset_save_confirmation.get_ok_button().pressed.emit()
		await process_frame
		var confirmed_result: Dictionary = SAVE_SCRIPT.load_game(save_path)
		_check(bool(confirmed_result.get("ok", false)) and int(confirmed_result.get("data", {}).get("save_version", -1)) == SAVE_SCRIPT.SAVE_VERSION and int(confirmed_result.get("data", {}).get("run", {}).get("credits", -1)) == int(main.director.economy.credits), "Confirming Replace Save should route through the explicit confirmed-reset path and commit the current session over an unsupported primary.")
		_check(main.feedback_label.text == "Saved locally." and main.loaded_save_path == save_path and FileAccess.get_file_as_string(save_path + ".bak") == valid_backup_text and FileAccess.get_file_as_string(save_path + ".bak.prev") == valid_previous_text, "Successful UI Reset Save should report success while retaining the valid recovery sidecars.")

	var ordinary_save_cases: Array[Dictionary] = []
	var malformed_payload := _save_test_payload(310)
	malformed_payload["save_version"] = "1"
	ordinary_save_cases.append({"label": "malformed version metadata", "primary": JSON.stringify(malformed_payload), "backup": "", "previous": ""})
	ordinary_save_cases.append({"label": "unsupported schema with valid recovery copies", "primary": future_text, "backup": valid_backup_text, "previous": valid_previous_text})
	ordinary_save_cases.append({"label": "unrecoverable corrupt save set", "primary": "{broken primary", "backup": "[]", "previous": "{\\\"save_version\\\":1}"})
	for save_case in ordinary_save_cases:
		for suffix in ["", ".bak", ".bak.prev", ".tmp", ".bak.tmp", ".bak.prev.tmp"]:
			if FileAccess.file_exists(save_path + suffix):
				DirAccess.remove_absolute(save_path + suffix)
		var case_files_ok := _write_text_fixture(save_path, str(save_case["primary"]))
		if not str(save_case["backup"]).is_empty():
			case_files_ok = _write_text_fixture(save_path + ".bak", str(save_case["backup"])) and case_files_ok
		if not str(save_case["previous"]).is_empty():
			case_files_ok = _write_text_fixture(save_path + ".bak.prev", str(save_case["previous"])) and case_files_ok
		var before_save_click: Dictionary = {}
		for suffix in ["", ".bak", ".bak.prev"]:
			var artifact_path: String = save_path + str(suffix)
			if FileAccess.file_exists(artifact_path):
				before_save_click[artifact_path] = FileAccess.get_file_as_string(artifact_path)
		main.feedback_label.text = ""
		save_button.pressed.emit()
		var ordinary_save_unchanged: bool = case_files_ok and main.feedback_label.text.contains("Save blocked")
		for artifact_path in before_save_click:
			ordinary_save_unchanged = ordinary_save_unchanged and FileAccess.get_file_as_string(str(artifact_path)) == str(before_save_click[artifact_path])
		for suffix in [".tmp", ".bak.tmp", ".bak.prev.tmp"]:
			ordinary_save_unchanged = ordinary_save_unchanged and not FileAccess.file_exists(save_path + suffix)
		_check(ordinary_save_unchanged, "The live ordinary Save button must remain blocked and preserve the full save set for %s." % str(save_case["label"]))

	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		if FileAccess.file_exists(save_path + suffix):
			DirAccess.remove_absolute(save_path + suffix)
	main.queue_free()
	await process_frame


func _write_text_fixture(path: String, contents: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(contents)
	file.close()
	return true


func _valid_test_save_payload() -> Dictionary:
	return {
		"save_version": SAVE_SCRIPT.SAVE_VERSION,
		"permanent": {"lifetime_influence": 123, "research": {"damage": 2}, "evolution": {"breaker_tier": "Origin Form"}, "unlocks": [], "first_clear_material_claims": []},
		"run": {"credits": 456, "wave": 5, "highest_cleared_wave": 4, "recruits": {"breaker": {"level": 7}}},
		"settings": {"master_volume": 0.65, "window_mode": "windowed"}
	}


func _assert_invalid_save_payload(payload: Dictionary, message: String) -> void:
	_assert_invalid_save_json(JSON.stringify(payload), message)


func _assert_invalid_save_json(json_text: String, message: String) -> void:
	var test_file := FileAccess.open(_test_disk_save_path(), FileAccess.WRITE)
	_check(test_file != null, "Test save path should be writable for validation cases.")
	if test_file == null:
		return
	test_file.store_string(json_text)
	test_file.close()
	var result: Dictionary = SAVE_SCRIPT.load_game(_test_disk_save_path())
	_check(not result.get("ok", false) and not str(result.get("error", "")).is_empty(), message)


func _test_save_fault_injection() -> void:
	var original_primary := JSON.stringify(_save_test_payload(300))
	var original_backup := JSON.stringify(_save_test_payload(200))
	for injected_fault in ["open_write", "write", "flush", "readback"]:
		var file_ops := _MemoryFileOps.new()
		file_ops.files[FAULT_SAVE_PATH] = original_primary
		file_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
		file_ops.fault = injected_fault
		var save_error: Error = _attempt_injected_save(file_ops, 900)
		_check(save_error != OK, "%s failure should reject the staged save." % injected_fault)
		_check(file_ops.files.get(FAULT_SAVE_PATH, "") == original_primary and file_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_backup, "%s failure should preserve the current primary and backup." % injected_fault)
		_check(not file_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "%s failure should remove its temporary file." % injected_fault)

	var backup_failure_ops := _MemoryFileOps.new()
	backup_failure_ops.files[FAULT_SAVE_PATH] = original_primary
	backup_failure_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	backup_failure_ops.fault = "backup_rotation"
	var backup_failure_error: Error = _attempt_injected_save(backup_failure_ops, 900)
	_check(backup_failure_error != OK and backup_failure_ops.files.get(FAULT_SAVE_PATH, "") == original_primary, "Backup rotation failure should leave the current primary loadable and abort the save.")
	_check(backup_failure_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_backup and not backup_failure_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Failed backup rotation should preserve the older valid backup and remove the temp file.")
	var backup_probe_ops := _MemoryFileOps.new()
	backup_probe_ops.files[FAULT_SAVE_PATH + ".bak"] = backup_failure_ops.files.get(FAULT_SAVE_PATH + ".bak", "")
	var older_backup_result: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, backup_probe_ops)
	_check(older_backup_result.get("ok", false) and older_backup_result["data"]["run"]["credits"] == 200, "Older backup should remain loadable after rotation failure.")

	var promotion_failure_ops := _MemoryFileOps.new()
	promotion_failure_ops.files[FAULT_SAVE_PATH] = original_primary
	promotion_failure_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	promotion_failure_ops.fault = "backup_promotion"
	var promotion_failure_error: Error = _attempt_injected_save(promotion_failure_ops, 900)
	_check(promotion_failure_error != OK and promotion_failure_ops.files.get(FAULT_SAVE_PATH, "") == original_primary, "Backup promotion failure should abort while preserving the current primary.")
	_check(promotion_failure_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_backup and not promotion_failure_ops.files.has(FAULT_SAVE_PATH + ".bak.prev"), "Failed backup promotion should restore the older valid backup from the recovery sidecar.")
	var previous_backup_probe := _MemoryFileOps.new()
	previous_backup_probe.files[FAULT_SAVE_PATH + ".bak"] = promotion_failure_ops.files.get(FAULT_SAVE_PATH + ".bak", "")
	var previous_backup_result: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, previous_backup_probe)
	_check(previous_backup_result.get("ok", false) and previous_backup_result.get("recovered_from_backup", false) and previous_backup_result["data"]["run"]["credits"] == 200, "Loader should recover from the restored .bak after backup promotion failure.")

	var removal_failure_ops := _MemoryFileOps.new()
	removal_failure_ops.files[FAULT_SAVE_PATH] = original_primary
	removal_failure_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	removal_failure_ops.fail_remove_path = FAULT_SAVE_PATH + ".bak"
	var removal_failure_error: Error = _attempt_injected_save(removal_failure_ops, 900)
	_check(removal_failure_error != OK and removal_failure_ops.files.get(FAULT_SAVE_PATH, "") == original_primary and removal_failure_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_backup, "Existing-backup removal failure should preserve both current files and abort the save.")

	var altered_read_scenarios := [
		{"name": "staged", "path": FAULT_SAVE_PATH + ".tmp", "read_call": 1},
		{"name": "staged backup", "path": FAULT_SAVE_PATH + ".bak.tmp", "read_call": 1},
		# Save-set inspection reads each committed file twice before the transaction begins.
		{"name": "promoted backup", "path": FAULT_SAVE_PATH + ".bak", "read_call": 4},
		{"name": "preserved older backup", "path": FAULT_SAVE_PATH + ".bak.prev", "read_call": 1},
		{"name": "committed", "path": FAULT_SAVE_PATH, "read_call": 4}
	]
	for scenario in altered_read_scenarios:
		var altered_read_ops := _MemoryFileOps.new()
		altered_read_ops.files[FAULT_SAVE_PATH] = original_primary
		altered_read_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
		altered_read_ops.alter_read_path = str(scenario["path"])
		altered_read_ops.alter_read_call = int(scenario["read_call"])
		var altered_read_error: Error = _attempt_injected_save(altered_read_ops, 900)
		_check(altered_read_error != OK, "Valid-but-altered %s read-back must be rejected by equality verification." % str(scenario["name"]))
		_check(altered_read_ops.files.get(FAULT_SAVE_PATH, "") == original_primary, "Valid-but-altered %s read-back must not replace the current primary." % str(scenario["name"]))
		_check(not altered_read_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Valid-but-altered %s read-back should clean up the staged file." % str(scenario["name"]))

	var partial_commit_ops := _MemoryFileOps.new()
	partial_commit_ops.files[FAULT_SAVE_PATH] = original_primary
	partial_commit_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	partial_commit_ops.fault = "partial_commit"
	var partial_commit_error: Error = _attempt_injected_save(partial_commit_ops, 900)
	_check(partial_commit_error != OK and partial_commit_ops.files.get(FAULT_SAVE_PATH, "") == original_primary, "Partial commit-copy error should return an error and restore the previous primary.")
	_check(partial_commit_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_primary and not partial_commit_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Partial commit rollback should retain a verified backup and remove the temp file.")

	var corrupt_commit_ops := _MemoryFileOps.new()
	corrupt_commit_ops.files[FAULT_SAVE_PATH] = original_primary
	corrupt_commit_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	corrupt_commit_ops.fault = "corrupt_commit"
	var corrupt_commit_error: Error = _attempt_injected_save(corrupt_commit_ops, 900)
	_check(corrupt_commit_error != OK, "Invalid committed bytes should fail validation and report a save error.")
	_check(corrupt_commit_ops.files.get(FAULT_SAVE_PATH, "") == original_primary, "Bad committed data should trigger rollback to the previous primary.")
	_check(corrupt_commit_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_primary, "Verified rollback should retain the last known-good primary in backup.")
	_check(not corrupt_commit_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Failed commit should remove the staged temporary file after rollback.")

	var rollback_failure_ops := _MemoryFileOps.new()
	rollback_failure_ops.files[FAULT_SAVE_PATH] = original_primary
	rollback_failure_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	rollback_failure_ops.fault = "corrupt_commit_rollback_copy"
	var rollback_failure_error: Error = _attempt_injected_save(rollback_failure_ops, 900)
	_check(rollback_failure_error != OK, "Rollback copy failure should return an error.")
	_check(not rollback_failure_ops.files.has(FAULT_SAVE_PATH) and rollback_failure_ops.files.get(FAULT_SAVE_PATH + ".bak", "") == original_primary, "Rollback copy failure should retain the previous valid save in backup.")
	_check(not rollback_failure_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Rollback failure should remove the staged temporary file.")
	var backup_recovery: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, rollback_failure_ops)
	_check(backup_recovery.get("ok", false) and backup_recovery.get("recovered_from_backup", false) and backup_recovery.get("data", {}).get("run", {}).get("credits", -1) == 300, "Retained backup should remain loadable after rollback copy failure.")

	var previous_backup_commit_ops := _MemoryFileOps.new()
	previous_backup_commit_ops.files[FAULT_SAVE_PATH] = original_primary
	previous_backup_commit_ops.files[FAULT_SAVE_PATH + ".bak"] = original_backup
	previous_backup_commit_ops.fault = "previous_backup_commit_recovery"
	var previous_backup_commit_error: Error = _attempt_injected_save(previous_backup_commit_ops, 900)
	_check(previous_backup_commit_error != OK, "Commit failure with an invalid current backup should report an error after recovery from .bak.prev.")
	_check(previous_backup_commit_ops.files.get(FAULT_SAVE_PATH, "") == original_backup and previous_backup_commit_ops.files.get(FAULT_SAVE_PATH + ".bak.prev", "") == original_backup, "Commit failure should restore the exact valid payload from .bak.prev when .bak is invalid.")
	_check(not previous_backup_commit_ops.files.has(FAULT_SAVE_PATH + ".tmp"), "Previous-backup commit recovery should clean up the staged save.")

	var backup_payload := JSON.stringify(_save_test_payload(500))
	var missing_primary_ops := _MemoryFileOps.new()
	missing_primary_ops.files[FAULT_SAVE_PATH + ".bak"] = backup_payload
	var missing_recovery: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, missing_primary_ops)
	_check(missing_recovery.get("ok", false) and missing_recovery.get("recovered_from_backup", false) and missing_recovery["data"]["run"]["credits"] == 500, "Injected loader should recover from a missing primary using the valid backup.")

	var corrupt_primary_ops := _MemoryFileOps.new()
	corrupt_primary_ops.files[FAULT_SAVE_PATH] = "{truncated primary"
	corrupt_primary_ops.files[FAULT_SAVE_PATH + ".bak"] = backup_payload
	var corrupt_recovery: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, corrupt_primary_ops)
	_check(corrupt_recovery.get("ok", false) and corrupt_recovery.get("recovered_from_backup", false) and corrupt_recovery["data"]["run"]["credits"] == 500, "Injected loader should recover from a corrupt primary using the valid backup.")

	var previous_only_ops := _MemoryFileOps.new()
	previous_only_ops.files[FAULT_SAVE_PATH] = "{truncated primary"
	previous_only_ops.files[FAULT_SAVE_PATH + ".bak.prev"] = original_backup
	var previous_only_recovery: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, previous_only_ops)
	_check(previous_only_recovery.get("ok", false) and previous_only_recovery.get("recovered_from_backup", false) and previous_only_recovery["data"]["run"]["credits"] == 200, "Loader should recover from .bak.prev when the primary is corrupt and .bak is missing.")


func _save_test_payload(credits: int) -> Dictionary:
	var payload := _valid_test_save_payload()
	payload["run"]["credits"] = credits
	return payload


func _attempt_injected_save(file_ops: _MemoryFileOps, credits: int) -> Error:
	var payload := _save_test_payload(credits)
	return SAVE_SCRIPT._save_game_with_file_ops(payload["permanent"], payload["run"], payload["settings"], FAULT_SAVE_PATH, file_ops)


func _test_explicit_save_after_recovered_backup_preserves_unknown_fields() -> void:
	for recovery_suffix in [".bak", ".bak.prev"]:
		var unknown_source := _save_test_payload(300)
		unknown_source["future_envelope"] = {"release": 2, "flags": ["root"]}
		unknown_source["future_root_array"] = ["future", {"revision": 3}]
		unknown_source["permanent"]["future_passive"] = {"id": "permanent.experimental", "rank": 3}
		unknown_source["permanent"]["research"]["future_branch"] = {"rank": 2, "modifiers": {"critical": 0.15}}
		unknown_source["run"]["future_inventory"] = [{"item_id": "prototype_shard", "count": 4}]
		unknown_source["run"]["recruits"]["breaker"]["future_talent"] = {"id": "breaker.focus", "enabled": true}
		unknown_source["settings"]["future_accessibility"] = {"reduced_flash": true}
		var file_ops := _MemoryFileOps.new()
		file_ops.files[FAULT_SAVE_PATH + recovery_suffix] = JSON.stringify(unknown_source)
		var recovered: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, file_ops)
		_check(bool(recovered.get("ok", false)) and bool(recovered.get("recovered_from_backup", false)) and int(recovered.get("data", {}).get("run", {}).get("credits", -1)) == 300, "A supported %s should load as the recovered save before an explicit update." % recovery_suffix)
		if not bool(recovered.get("ok", false)):
			continue
		var updated_payload := _save_test_payload(900)
		updated_payload["permanent"]["research"] = {"damage": 5}
		updated_payload["run"]["credits"] = 900
		updated_payload["settings"]["master_volume"] = 0.35
		var save_error: Error = SAVE_SCRIPT._save_game_with_file_ops(updated_payload["permanent"], updated_payload["run"], updated_payload["settings"], FAULT_SAVE_PATH, file_ops)
		var reloaded: Dictionary = SAVE_SCRIPT._load_game_with_file_ops(FAULT_SAVE_PATH, file_ops)
		_check(save_error == OK and bool(reloaded.get("ok", false)), "An explicit save after recovery from %s should commit and reload successfully." % recovery_suffix)
		if not bool(reloaded.get("ok", false)):
			continue
		var saved: Dictionary = reloaded["data"]
		_check(int(saved["run"]["credits"]) == 900 and int(saved["permanent"]["research"]["damage"]) == 5 and is_equal_approx(float(saved["settings"]["master_volume"]), 0.35), "An explicit save after recovery from %s should apply known-value updates." % recovery_suffix)
		_check(SAVE_SCRIPT._values_match(saved.get("future_envelope", {}), unknown_source["future_envelope"]) and SAVE_SCRIPT._values_match(saved.get("future_root_array", []), unknown_source["future_root_array"]), "An explicit save after recovery from %s should preserve unknown root fields." % recovery_suffix)
		_check(SAVE_SCRIPT._values_match(saved["permanent"].get("future_passive", {}), unknown_source["permanent"]["future_passive"]) and SAVE_SCRIPT._values_match(saved["permanent"]["research"].get("future_branch", {}), unknown_source["permanent"]["research"]["future_branch"]), "An explicit save after recovery from %s should preserve unknown permanent and nested research fields." % recovery_suffix)
		_check(SAVE_SCRIPT._values_match(saved["run"].get("future_inventory", []), unknown_source["run"]["future_inventory"]) and SAVE_SCRIPT._values_match(saved["run"]["recruits"]["breaker"].get("future_talent", {}), unknown_source["run"]["recruits"]["breaker"]["future_talent"]), "An explicit save after recovery from %s should preserve unknown run and recruit fields." % recovery_suffix)
		_check(SAVE_SCRIPT._values_match(saved["settings"].get("future_accessibility", {}), unknown_source["settings"]["future_accessibility"]), "An explicit save after recovery from %s should preserve unknown settings fields." % recovery_suffix)


func _test_main_scene_builds_default_owned_roster() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	_check(main.get_child_count() > 0 and main.get_child(0).get_script() == ENVIRONMENT_DIRECTOR_SCRIPT and main.get_child(0).name == "EnvironmentDirector", "The main scene should keep the encounter environment director as a separate first child.")
	_check(main.environment_director.active_backdrop.get_script() == BACKDROP_SCRIPT and main.environment_director.active_zone_id == "undercity_proto_01", "The environment director should own the current procedural Undercity backdrop module.")
	_check(main.active_lineup == ["spark", "recoil", "vector", "", "", ""] and main.allied_actors.size() == 3, "A fresh main scene should deploy its three owned starters in canonical founding-roster order and keep the other slots vacant.")
	_check(main.ally_ground_shadows.size() == main.allied_actors.size() and main.enemy_ground_shadow is Polygon2D, "The battlefield should create ground-contact shadows for all deployed squad members and the enemy.")
	_check(main.attachment_event_router != null and main.director.combat_action_resolved.get_connections().size() == 1, "The main scene should route authoritative combat action events to the attachment presentation router.")
	var routed_weapon_receiver := _AttachmentEventReceiver.new()
	_check(main.attachment_event_router.register_attachment("test.vector.weapon", "vector", routed_weapon_receiver, ["attack_resolved"]), "A test weapon should register with the live main-scene attachment event router.")
	_check(main.ground_shadow_layer.get_index() < main.allied_actors[0].get_index(), "Ground shadows should render below character actors.")
	main._process(0.0)
	var grounded_shadows := true
	for index in range(main.allied_actors.size()):
		var ally: Dictionary = main.director.allies[index]
		var expected_contact_y := 510.0 + float(ally["formation_depth"]) + (3.0 if bool(ally.get("is_breaker", false)) else 9.0)
		grounded_shadows = grounded_shadows and main.ally_ground_shadows[index].position.is_equal_approx(Vector2(float(ally["x"]), expected_contact_y))
	_check(grounded_shadows, "Each squad shadow should align with its combat actor's configured depth lane and foot contact point.")
	var positions_before_zone_change: Array[Vector2] = []
	for actor in main.allied_actors:
		positions_before_zone_change.append(actor.position)
	var vector_index := -1
	for index in range(main.director.allies.size()):
		if str(main.director.allies[index].get("id", "")) == "vector":
			vector_index = index
	_check(vector_index >= 0, "The canonical default roster should include VECTOR for the resolved-attack routing check.")
	main.director.wave = 12
	main.director.highest_cleared_wave = 11
	main.director.enemy_x = float(main.director.allies[vector_index]["x"]) + float(main.director.allies[vector_index]["engagement_distance"])
	main.director.enemy_hp = 1.0
	main.director.allies[vector_index]["attack_elapsed"] = float(main.director.allies[vector_index]["attack_interval"])
	main.director._step(main.director.FIXED_STEP)
	_check(routed_weapon_receiver.events.size() == 1 and routed_weapon_receiver.events[0]["source_id"] == "vector", "A live resolved VECTOR attack should reach its registered weapon presentation node exactly once.")
	_check(main.director.wave == 13 and main.director.phase == "intermission", "The simulated wave-12 victory should advance combat into wave 13 intermission.")
	_check(main.permanent_state["highest_wave_ever"] == 12, "Main scene should retain cleared-wave milestones in permanent progression state.")
	_check(main.permanent_state["evolution_materials"]["evolution_data"] == 1, "The live wave-clear listener should apply one repeatable material for an ordinary clear.")
	_check(main.feedback_label.text.contains("+1 Evolution Data"), "The HUD should report the repeatable material reward after the clear.")
	main._on_wave_cleared(25, 0, 25, "")
	_check(main.permanent_state["evolution_materials"]["evolution_data"] == 3 and main.permanent_state["first_clear_material_claims"].has("district.undercity"), "The first district milestone should add one first-clear material to its repeatable clear payout.")
	main._on_wave_cleared(26, 0, 26, "boss.test_warden")
	_check(main.permanent_state["evolution_materials"]["evolution_data"] == 5 and main.permanent_state["first_clear_material_claims"].has("boss.test_warden"), "A named boss event should add a separate first-clear bonus to the shared material inventory.")
	main._on_wave_cleared(26, 0, 26, "boss.test_warden")
	_check(main.permanent_state["evolution_materials"]["evolution_data"] == 6 and main.permanent_state["first_clear_material_claims"].count("boss.test_warden") == 1, "A replayed boss clear should pay the repeatable amount once without duplicating the permanent boss bonus.")
	if not main.permanent_state["unlocks"].has("breaker"):
		main.permanent_state["unlocks"].append("breaker")
	main.active_lineup[3] = "breaker"
	_check(main.director.set_active_lineup(main.active_lineup, main.permanent_state["unlocks"], main.recruit_run_states, true), "The live UI regression fixture should deploy owned BREAKER for the existing evolution and upgrade checks.")
	main._refresh()
	var original_save_path: String = main.save_path
	var evolution_test_path := ProjectSettings.globalize_path("res://tests/_evolution_ui_%d.json" % Time.get_ticks_usec())
	main.save_path = evolution_test_path
	var evolution_run_before: Dictionary = main.director.snapshot()
	main._evolve_breaker()
	var evolution_saved: Dictionary = SAVE_SCRIPT.load_game(evolution_test_path)
	_check(bool(evolution_saved.get("ok", false)), "Eligible BREAKER evolution HUD action should persist through the versioned save service.")
	if bool(evolution_saved.get("ok", false)):
		var saved_permanent: Dictionary = evolution_saved["data"]["permanent"]
		_check(saved_permanent["evolution"]["breaker_tier"] == "Adapted Form" and saved_permanent["evolution_materials"]["evolution_data"] == 5, "Evolution HUD save should contain the tier record and material deduction together.")
		_check(int(evolution_saved["data"]["run"]["wave"]) == int(evolution_run_before["wave"]) and int(evolution_saved["data"]["run"]["recruits"]["breaker"]["level"]) == int(evolution_run_before["recruit_level"]), "Evolution purchase should save the current run alongside the permanent transaction.")
		_check(int(evolution_saved["data"]["run"].get("offline_claim_unix", 0)) > 0, "Evolution saves should reset the offline accrual baseline in the same transaction.")
	_check(main.permanent_state["evolution"]["breaker_tier"] == "Adapted Form" and main.permanent_state["evolution_materials"]["evolution_data"] == 5, "Live permanent state should update only after evolution save succeeds.")
	_check(main.feedback_label.text.contains("stat and art effects are not implemented"), "Evolution HUD should disclose that stat and art effects remain unimplemented.")
	var committed_permanent: Dictionary = main.permanent_state.duplicate(true)
	main.permanent_state["highest_wave_ever"] = 75
	main.permanent_state["evolution_materials"]["evolution_data"] = 2
	main.permanent_state["evolution"]["breaker_tier"] = "Adapted Form"
	var failed_save_baseline: Dictionary = main.permanent_state.duplicate(true)
	main.save_path = ProjectSettings.globalize_path("res://tests/_missing_evolution_save_directory/save.json")
	main._evolve_breaker()
	_check(main.permanent_state == failed_save_baseline and main.feedback_label.text.contains("no materials were consumed"), "Failed evolution save should preserve the entire live permanent state.")
	main.permanent_state = committed_permanent
	main.save_path = original_save_path
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var evolution_file: String = evolution_test_path + suffix
		if FileAccess.file_exists(evolution_file):
			DirAccess.remove_absolute(evolution_file)
	_check(main.environment_director.active_zone_id == "undercity_proto_02" and main.environment_director.get_child_count() == 2, "The combat-owned wave transition should notify the environment director to begin the seamless crossfade.")
	main._process(0.0)
	var positions_preserved := true
	for index in range(mini(main.allied_actors.size(), positions_before_zone_change.size())):
		positions_preserved = positions_preserved and main.allied_actors[index].position.is_equal_approx(positions_before_zone_change[index])
	_check(positions_preserved, "Changing environment zones must not alter any squad actor's presentation position.")
	_check(main.status_label.text.contains("Wave 13"), "The HUD should stay synchronized with the combat-owned wave during the environment transition.")
	var root_window := get_root()
	var original_window_size := root_window.size
	root_window.size = Vector2i(1280, 720)
	main._apply_responsive_hud_scale()
	_check(is_equal_approx(float(main.hud_panel.scale.x), 1.0) and is_equal_approx(float(main.hud_panel.scale.y), 1.0), "The HUD should keep baseline scale at 1280x720.")
	_check(main.hint_label.visible, "The auxiliary automatic-combat caption should remain visible at the wide reference viewport.")
	root_window.size = Vector2i(800, 450)
	main._apply_responsive_hud_scale()
	_check(main.hud_panel.scale.x > 1.0 and main.hud_panel.scale.y > 1.0, "The HUD should scale up at 800x450.")
	_check(main.hud_panel.scale.x <= 1.16 and main.hud_panel.scale.y <= 1.16, "The HUD scale at 800x450 should remain within the 1.16 cap.")
	_check(not main.hint_label.visible, "The auxiliary caption should hide on the narrow reference viewport to prevent crowding the HUD panel.")
	var hud_rect: Rect2 = main.hud_panel.get_global_rect()
	_check(hud_rect.position.x >= 0.0 and hud_rect.position.y >= 0.0 and hud_rect.end.x <= 800.0 and hud_rect.end.y <= 450.0, "The responsive HUD panel should remain inside the 800x450 minimum viewport.")
	_check(main.allied_actors.size() == 4, "The main scene should display the four owned deployed recruits and leave two active slots vacant.")
	_check(main.squad_label.text.contains("3 placeholder allies"), "The HUD should disclose that the three non-BREAKER recruits still use prototype placeholder visuals.")
	_check(_find_speed_controls(main).is_empty(), "The main HUD and any settings UI must not expose player-facing speed or pace controls.")
	_check(not _contains_movement_preference_key(main.settings_state), "Player settings state must not include movement speed preferences.")
	var hud_panel := _find_descendant_by_type(main, PanelContainer)
	_check(hud_panel != null and hud_panel.is_ancestor_of(main.feedback_label), "Save and upgrade feedback should remain inside the HUD panel.")
	var action_buttons: Array[Button] = []
	_collect_buttons(main, action_buttons)
	var action_labels: Array[String] = []
	for button in action_buttons:
		if button.text in ["Upgrade x1", "Upgrade x10", "Save", "Load", "Research"]:
			action_labels.append(button.text)
	_check(action_labels == ["Upgrade x1", "Upgrade x10", "Save", "Load", "Research"], "Existing HUD actions should remain in order with the new read-only Research entry.")
	for button in action_buttons:
		if button is OptionButton:
			_check((button as OptionButton).item_selected.get_connections().size() == 1, "%s selector should remain wired to its preference action." % button.text)
		else:
			_check(button.pressed.get_connections().size() == 1, "%s should remain wired to its action." % button.text)
	main.permanent_state["spendable_influence"] = 7
	main._show_research_dialog()
	_check(main.research_dialog.visible and main._research_dialog_text().contains("Combat Protocols") and main._research_dialog_text().contains("Personnel Development"), "Research preview should expose all four approved branches.")
	_check(main._research_dialog_text().contains("No Influence is spent") and main.research_catalog["branches"].all(func(branch): return branch.get("nodes", []).is_empty()), "Research preview must be read-only while node costs/effects remain unapproved.")
	_check(main.research_balance_label.text.contains("7"), "Research preview should show the current spendable Influence without changing it.")
	var research_buttons: Array[Button] = []
	_collect_buttons(main.research_dialog, research_buttons)
	_check(research_buttons.size() == 1 and research_buttons[0].text == "CLOSE", "Research should expose no purchase actions while node costs and effects remain unapproved.")
	_check(int(main.permanent_state["spendable_influence"]) == 7, "Opening the read-only Research dialog must not consume Influence.")
	main.research_dialog.hide()
	main.permanent_state.erase("spendable_influence")
	await _test_roster_evolution_dialog(main, root_window, original_window_size)
	_check(main.reboot_button.disabled and main.reboot_button.text.contains("LOCKED UNTIL WAVE 25 CLEAR"), "System Reboot should remain unavailable until the first wave-25 clear.")
	main.director.highest_cleared_wave = 25
	main._refresh()
	_check(not main.reboot_button.disabled and main.reboot_button.text == "SYSTEM REBOOT — READY", "System Reboot should become available after the live run clears wave 25.")
	main.director.highest_cleared_wave = 12
	main._refresh()
	await _test_hud_upgrade_transactions(main, action_buttons[0], action_buttons[1])
	main._process(0.0)
	var breaker_ally_index: int = main.director._find_ally_index("breaker")
	var presented_allies: Array = main.director.presentation_snapshot().get("allies", [])
	_check(breaker_ally_index >= 0 and is_equal_approx(main.breaker_actor.position.x, float(presented_allies[breaker_ally_index]["x"])), "BREAKER presentation should follow the interpolated combat simulation anchor.")
	var live_reboot_path := ProjectSettings.globalize_path("res://tests/_live_reboot_%d.json" % Time.get_ticks_usec())
	main.save_path = live_reboot_path
	main.permanent_state["research"] = {"combat": 2}
	main.permanent_state["first_clear_material_claims"] = ["district.undercity"]
	var expected_reboot_evolution: Dictionary = {}
	var approved_tiers := ["Origin Form", "Adapted Form", "Signature Form", "Requiem Form"]
	for recruit_index in range(EVOLUTION_SERVICE_SCRIPT.APPROVED_RECRUIT_IDS.size()):
		var recruit_id := str(EVOLUTION_SERVICE_SCRIPT.APPROVED_RECRUIT_IDS[recruit_index])
		var tier_key := "breaker_tier" if recruit_id == "breaker" else "%s_tier" % recruit_id
		expected_reboot_evolution[tier_key] = approved_tiers[recruit_index % approved_tiers.size()]
	main.permanent_state["evolution"] = expected_reboot_evolution.duplicate(true)
	main.permanent_state["evolution_materials"] = {"evolution_data": 5}
	main.director.economy.credits = 321
	main.director.economy.recruit_level = 4
	main.director.highest_cleared_wave = 50
	main.director.wave = 50
	main.permanent_state["highest_wave_ever"] = 50
	main.director.allies[0]["hp"] = 1.0
	var expected_reboot_hp: Dictionary = {}
	for ally in main.director.allies:
		var recruit_id := str(ally.get("id", ""))
		expected_reboot_hp[recruit_id] = float(main.director.player_def["max_hp"]) if bool(ally.get("is_breaker", false)) else float(ally["max_hp"])
	main._refresh()
	_check(not main.reboot_button.disabled, "The live Reboot control should unlock after first clearing wave 25.")
	main._request_reboot_confirmation()
	_check(main.reboot_confirmation.visible, "An eligible live Reboot request should require explicit confirmation.")
	var reboot_cancel_permanent: Dictionary = main.permanent_state.duplicate(true)
	var reboot_cancel_run: Dictionary = main.director.snapshot()
	var reboot_cancel_process_mode: int = main.director.process_mode
	main.director.process_mode = Node.PROCESS_MODE_DISABLED
	main.reboot_confirmation.get_cancel_button().pressed.emit()
	await process_frame
	main.director.process_mode = reboot_cancel_process_mode
	_check(not main.reboot_confirmation.visible, "Canceling the live Reboot dialog should close the confirmation window.")
	_check(main.permanent_state == reboot_cancel_permanent, "Canceling the live Reboot dialog must not award Influence or alter permanent progression.")
	_check(main.director.snapshot() == reboot_cancel_run, "Canceling the live Reboot dialog must not reset the live run.")
	_check(not FileAccess.file_exists(live_reboot_path), "Canceling the live Reboot dialog must not create a save.")
	var permanent_before_failed_reboot: Dictionary = main.permanent_state.duplicate(true)
	var run_before_failed_reboot: Dictionary = main.director.snapshot()
	var unavailable_reboot_path := ProjectSettings.globalize_path("res://tests/_missing_live_reboot_%d/save.json" % Time.get_ticks_usec())
	main.save_path = unavailable_reboot_path
	main._perform_reboot()
	_check(main.permanent_state == permanent_before_failed_reboot, "A failed live Reboot save must not change permanent state.")
	_check(main.director.snapshot() == run_before_failed_reboot, "A failed live Reboot save must leave the complete run snapshot unchanged.")
	_check(main.feedback_label.text.contains("live run was not reset"), "A failed live Reboot save should explain that the run was not reset.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		_check(not FileAccess.file_exists(unavailable_reboot_path + suffix), "Failed live Reboot should not leave a save or sidecar artifact: %s" % suffix)
	main.save_path = live_reboot_path
	main._request_reboot_confirmation()
	_check(main.reboot_confirmation.visible, "A successful live Reboot should still require the explicit confirmation dialog after a prior failed-save attempt.")
	main.reboot_confirmation.get_ok_button().pressed.emit()
	await process_frame
	var live_reboot_save: Dictionary = SAVE_SCRIPT.load_game(live_reboot_path)
	_check(bool(live_reboot_save.get("ok", false)), "The live Reboot caller should persist its transaction to the configured save path. UI feedback: %s" % main.feedback_label.text)
	if bool(live_reboot_save.get("ok", false)):
		var saved_reboot: Dictionary = live_reboot_save["data"]
		_check(saved_reboot["run"]["wave"] == 1 and saved_reboot["run"]["highest_cleared_wave"] == 0 and saved_reboot["run"]["credits"] == 0 and saved_reboot["run"]["recruits"]["breaker"]["level"] == 1, "The live Reboot transaction should persist the reset run state.")
		_check(int(saved_reboot["run"].get("offline_claim_unix", 0)) > 0, "System Reboot saves should reset the offline accrual baseline atomically with the run reset.")
		_check(int(saved_reboot["permanent"]["lifetime_influence"]) == 2 and int(saved_reboot["permanent"]["highest_wave_ever"]) == 50 and int(saved_reboot["permanent"]["research"]["combat"]) == 2 and int(saved_reboot["permanent"]["evolution_materials"]["evolution_data"]) == 5 and saved_reboot["permanent"]["evolution"]["breaker_tier"] == "Adapted Form" and saved_reboot["permanent"]["first_clear_material_claims"] == ["district.undercity"], "The live Reboot transaction should award two Influence and preserve permanent progress/material inventory: %s" % str(saved_reboot["permanent"]))
		_check(saved_reboot["permanent"]["evolution"] == expected_reboot_evolution, "System Reboot should preserve all twelve per-recruit evolution tier records.")
		_check(int(saved_reboot["permanent"]["evolution_materials"].get("evolution_data", -1)) == 5, "System Reboot should preserve the shared Evolution Data balance.")
		_check(main.permanent_state["evolution"] == expected_reboot_evolution and int(main.permanent_state["evolution_materials"].get("evolution_data", -1)) == 5, "The live scene should apply the preserved recruit tiers and shared materials only after the reboot save commits.")
		var saved_recruits: Dictionary = saved_reboot["run"]["recruits"]
		var reboot_hp_matches := true
		for recruit_id in expected_reboot_hp:
			reboot_hp_matches = reboot_hp_matches and is_equal_approx(float(saved_recruits.get(recruit_id, {}).get("hp", -1.0)), float(expected_reboot_hp[recruit_id]))
		_check(reboot_hp_matches and not saved_reboot["run"].has("squad_hp"), "The live Reboot transaction should restore and persist full HP by recruit identity.")
		_check(main.director.lifetime_influence == 2 and main.director.wave == 1 and main.director.highest_cleared_wave == 0 and main.director.economy.credits == 0 and main.director.economy.recruit_level == 1, "The live scene should apply Reboot state only after the save commits.")
		var expected_lifetime_bonus := 0.005 * sqrt(2.0)
		_check(is_equal_approx(main.director.lifetime_power_bonus_fraction, expected_lifetime_bonus), "The live scene should refresh the outgoing damage bonus after Reboot.")
		for ally_index in range(main.director.allies.size()):
			var ally_after_reboot: Dictionary = main.director.allies[ally_index]
			var base_power := float(main.director.player_def["attack_power"]) if bool(ally_after_reboot.get("is_breaker", false)) else float(ally_after_reboot["base_attack_power"])
			_check(is_equal_approx(float(ally_after_reboot["attack_power"]), base_power * (1.0 + expected_lifetime_bonus)), "Reboot should refresh the lifetime modifier on ally slot %d." % ally_index)
			_check(is_equal_approx(float(ally_after_reboot["hp"]), float(saved_recruits.get(str(ally_after_reboot.get("id", "")), {}).get("hp", -1.0))), "Live squad recruit %s should match its saved full HP after Reboot." % str(ally_after_reboot.get("id", "")))
	_check(not main.reboot_confirmation.visible, "Confirming Reboot through the dialog should close the confirmation window after committing.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var artifact_path: String = live_reboot_path + suffix
		if FileAccess.file_exists(artifact_path):
			DirAccess.remove_absolute(artifact_path)
	main.director.economy.credits = int(main.recruitment_profile.get("starting_credits", 0))
	await _test_recruitment_live_ui_and_save(main)
	root_window.size = original_window_size
	main.queue_free()


func _test_recruitment_live_ui_and_save(main: Node) -> void:
	var window := get_root()
	var original_window_size: Vector2i = window.size
	var original_path := str(main.save_path)
	var original_loaded_path := str(main.loaded_save_path)
	var original_permanent: Dictionary = main.permanent_state.duplicate(true)
	var original_run: Dictionary = main.director.snapshot()
	_check(main.director.economy.credits == 600 and _array_has_all(main.permanent_state.get("unlocks", []), ["vector", "spark", "recoil"]), "Fresh live play should start with 600 credits and permanent VECTOR, SPARK, and RECOIL ownership.")
	_check(main.recruitment_rows.size() == 12, "Recruitment UI should create one row for each of the twelve founders.")
	main._show_recruitment_dialog()
	for target_size in [Vector2i(800, 450), Vector2i(1280, 720)]:
		window.size = target_size
		await process_frame
		await process_frame
		var panel := main.recruitment_dialog.find_child("RecruitmentPanel", true, false) as Control
		_check(panel != null, "Recruitment dialog should expose its panel at %dx%d." % [target_size.x, target_size.y])
		if panel == null:
			continue
		var window_size := window.size
		var panel_rect_logical: Rect2 = panel.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, panel.size)
		var stretch_scale := Vector2(float(window_size.x) / 1280.0, float(window_size.y) / 720.0)
		var panel_rect_physical := Rect2(panel_rect_logical.position * stretch_scale, panel_rect_logical.size * stretch_scale)
		var window_rect_physical := Rect2(Vector2.ZERO, Vector2(window_size))
		_check(window_rect_physical.encloses(panel_rect_physical), "Recruitment panel rect %s after canvas scaling exceeds physical window %s at %dx%d." % [str(panel_rect_physical), str(window_rect_physical), target_size.x, target_size.y])
		var roster_scroll: ScrollContainer = main.recruitment_roster_list.get_parent()
		_check(roster_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED and roster_scroll.get_v_scroll_bar().max_value > 0.0, "Recruitment roster should avoid horizontal scrolling and keep all rows reachable at %dx%d." % [target_size.x, target_size.y])
		for recruit_id in RECRUITMENT_SERVICE_SCRIPT.EXPECTED_RECRUIT_IDS:
			var row: Dictionary = main.recruitment_rows.get(recruit_id, {})
			_check(not row.is_empty(), "Recruitment row %s should remain present at %dx%d." % [recruit_id, target_size.x, target_size.y])
			if row.is_empty():
				continue
			var recruit_button: Button = row["recruit_button"]
			var details_label: Label = row["details_label"]
			var name_label := recruit_button.get_parent().get_child(0) as Label
			var button_font: Font = recruit_button.get_theme_font("font")
			var text_width := button_font.get_string_size(recruit_button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, recruit_button.get_theme_font_size("font_size")).x
			var catalog_recruit: Dictionary = main.recruitment_rows[recruit_id]["recruit"]
			_check(name_label != null and name_label.text == str(catalog_recruit["name"]), "Recruitment row %s should show its catalog name at %dx%d." % [recruit_id, target_size.x, target_size.y])
			_check(details_label.text.contains(str(catalog_recruit["rarity"]).to_upper()) and details_label.text.contains(str(catalog_recruit["faction"])) and details_label.text.contains(str(catalog_recruit["roles"])), "Recruitment row %s should show rarity, faction, and roles at %dx%d." % [recruit_id, target_size.x, target_size.y])
			_check(text_width <= recruit_button.size.x - 16.0, "Recruitment action label should fit without clipping at %dx%d (%s)." % [target_size.x, target_size.y, recruit_id])
			if main.permanent_state.get("unlocks", []).has(recruit_id):
				_check(recruit_button.disabled and recruit_button.text == "OWNED", "Owned recruit %s should display as owned at %dx%d." % [recruit_id, target_size.x, target_size.y])
			elif str(catalog_recruit["rarity"]) == "Common":
				_check(not recruit_button.disabled and recruit_button.text == "RECRUIT // 300 CREDITS", "Affordable Common %s should show its trial price at %dx%d." % [recruit_id, target_size.x, target_size.y])
			elif str(catalog_recruit["rarity"]) == "Rare":
				_check(not recruit_button.disabled and recruit_button.text == "RECRUIT // 600 CREDITS", "Affordable Rare %s should show its trial price at %dx%d." % [recruit_id, target_size.x, target_size.y])
			else:
				_check(recruit_button.disabled and recruit_button.text == "NEED 1200 CREDITS", "Unaffordable Epic %s should show the unmet trial price at %dx%d." % [recruit_id, target_size.x, target_size.y])
	var failed_path := ProjectSettings.globalize_path("res://tests/_missing_live_recruitment_%d/save.json" % Time.get_ticks_usec())
	main.save_path = failed_path
	main.loaded_save_path = ""
	var permanent_before_failure: Dictionary = main.permanent_state.duplicate(true)
	var credits_before_failure := int(main.director.economy.credits)
	main._purchase_recruit("stitch")
	_check(main.permanent_state == permanent_before_failure and int(main.director.economy.credits) == credits_before_failure and main.feedback_label.text.contains("save failed"), "A failed recruitment save must leave permanent ownership and live credits unchanged.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		_check(not FileAccess.file_exists(failed_path + suffix), "Failed recruitment save should leave no save or sidecar artifact: %s" % suffix)
	var live_path := ProjectSettings.globalize_path("res://tests/_live_recruitment_%d.json" % Time.get_ticks_usec())
	main.save_path = live_path
	main._purchase_recruit("stitch")
	var saved_recruitment: Dictionary = SAVE_SCRIPT.load_game(live_path)
	_check(int(main.director.economy.credits) == 300 and main.permanent_state.get("unlocks", []).has("stitch"), "A successful live purchase should apply only the saved 300-credit deduction and permanent ownership.")
	_check(bool(saved_recruitment.get("ok", false)) and saved_recruitment["data"]["run"]["credits"] == 300 and saved_recruitment["data"]["permanent"]["unlocks"].has("stitch"), "A successful live purchase should reload with ownership and remaining credits committed together.")
	main._purchase_recruit("stitch")
	_check(int(main.director.economy.credits) == 300 and main.feedback_label.text.contains("already recruited"), "The live caller should reject a duplicate purchase without another deduction.")
	var legacy_path := ProjectSettings.globalize_path("res://tests/_legacy_recruitment_%d.json" % Time.get_ticks_usec())
	var legacy_permanent: Dictionary = original_permanent.duplicate(true)
	legacy_permanent["unlocks"] = ["cipher"]
	var legacy_run: Dictionary = _valid_test_save_payload()["run"].duplicate(true)
	legacy_run["credits"] = 77
	legacy_run["offline_claim_unix"] = int(Time.get_unix_time_from_system())
	legacy_run["squad_hp"] = [120.0, 90.0, 80.0, 110.0, 85.0, 75.0]
	var legacy_save_error: Error = SAVE_SCRIPT.save_game(legacy_permanent, legacy_run, main.settings_state, legacy_path)
	main.save_path = legacy_path
	main._load()
	_check(legacy_save_error == OK and int(main.director.economy.credits) == 77 and _array_has_all(main.permanent_state.get("unlocks", []), ["cipher", "vector", "spark", "recoil"]), "Loading a legacy save should preserve its credits and ownership while adding the starter trio.")
	_check(main.permanent_state.get("unlocks", []).count("vector") == 1 and main.permanent_state.get("unlocks", []).count("spark") == 1 and main.permanent_state.get("unlocks", []).count("recoil") == 1, "Repeated legacy-load migration should not duplicate starter ownership.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		for cleanup_path in [live_path, legacy_path]:
			var artifact: String = cleanup_path + suffix
			if FileAccess.file_exists(artifact):
				DirAccess.remove_absolute(artifact)
	main.save_path = original_path
	main.loaded_save_path = original_loaded_path
	main.permanent_state = original_permanent
	main.director.load_run_state(original_run)
	main._refresh()
	window.size = original_window_size
	main.recruitment_dialog.hide()


func _test_roster_evolution_dialog(main: Node, root_window: Window, original_window_size: Vector2i) -> void:
	var original_permanent: Dictionary = main.permanent_state.duplicate(true)
	var original_save_path: String = main.save_path
	var original_loaded_save_path: String = main.loaded_save_path
	var roster_save_path := ProjectSettings.globalize_path("res://tests/_roster_evolution_%d.json" % Time.get_ticks_usec())
	main.save_path = roster_save_path
	main.loaded_save_path = ""
	main.permanent_state["highest_wave_ever"] = 25
	main.permanent_state["evolution_materials"]["evolution_data"] = 12
	main.permanent_state["evolution"] = {"breaker_tier": "Origin Form"}
	for recruit_value in EVOLUTION_SERVICE_SCRIPT.APPROVED_RECRUIT_IDS:
		var recruit_id := str(recruit_value)
		var tier_key := "%s_tier" % recruit_id
		main.permanent_state["evolution"][tier_key] = "Origin Form"

	main._show_evolution_dialog()
	await process_frame
	var recruit_ids: Array = EVOLUTION_SERVICE_SCRIPT.APPROVED_RECRUIT_IDS
	_check(recruit_ids.size() == 12 and main.evolution_rows.size() == 12, "Evolution dialog should contain exactly twelve founding-recruit rows.")
	var expected_unique_ids: Dictionary = {}
	for recruit_value in recruit_ids:
		var recruit_id := str(recruit_value)
		expected_unique_ids[recruit_id] = true
		var row: Dictionary = main.evolution_rows.get(recruit_id, {})
		_check(not row.is_empty(), "Evolution dialog should expose the canonical %s roster ID." % recruit_id)
		if row.is_empty():
			continue
		var progress_label: Label = row["progress_label"]
		var record_button: Button = row["record_button"]
		_check(progress_label.text.contains("Origin Form → Adapted Form") and progress_label.text.contains("WAVE 25 + DATA 1"), "%s should show its current-to-next tier and approved prototype gate." % recruit_id)
		_check(not record_button.disabled and record_button.text == "RECORD COMBAT GRADE", "%s should be eligible at the shared wave-25/data-1 gate." % recruit_id)
	_check(main.evolution_rows.keys().size() == expected_unique_ids.size(), "Evolution dialog rows should map one-to-one to unique canonical recruit IDs.")
	var evolution_panel := main.evolution_dialog.find_child("EvolutionPanel", true, false) as Control
	_check(evolution_panel != null, "Evolution dialog should expose its centered roster panel for responsive layout review.")
	_check(main.evolution_dialog.visible and not main.research_dialog.visible, "Opening the roster Evolution dialog should leave the existing Research dialog closed.")
	var roster_scroll := main.evolution_dialog.find_child("EvolutionRosterScroll", true, false) as ScrollContainer
	_check(roster_scroll != null, "Evolution roster should expose its scroll container for layout coverage.")
	for target_size in [Vector2i(1280, 720), Vector2i(800, 450)]:
		root_window.size = target_size
		main._apply_responsive_hud_scale()
		await process_frame
		if evolution_panel != null:
			var panel_rect: Rect2 = evolution_panel.get_global_rect()
			var stretch_scale := Vector2(float(target_size.x) / 1280.0, float(target_size.y) / 720.0)
			var physical_panel_rect := Rect2(panel_rect.position * stretch_scale, panel_rect.size * stretch_scale)
			_check(physical_panel_rect.position.x >= 0.0 and physical_panel_rect.position.y >= 0.0 and physical_panel_rect.end.x <= float(target_size.x) and physical_panel_rect.end.y <= float(target_size.y), "Roster Evolution panel should remain inside %s after canvas stretch (rect=%s, scaled=%s)." % [str(target_size), str(panel_rect), str(physical_panel_rect)])
		var ready_row: Dictionary = main.evolution_rows.get("bulwark", {})
		if not ready_row.is_empty():
			var ready_button: Button = ready_row["record_button"]
			var button_font := ready_button.get_theme_font("font")
			var button_font_size := ready_button.get_theme_font_size("font_size")
			var button_text_width := button_font.get_string_size(ready_button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button_font_size).x
			var button_style := ready_button.get_theme_stylebox("normal")
			var button_content_margins := button_style.get_minimum_size().x
			_check(button_text_width + button_content_margins <= ready_button.size.x + 0.5, "Ready action label must fit inside its button at %s (text=%0.1f, insets=%0.1f, width=%0.1f)." % [str(target_size), button_text_width, button_content_margins, ready_button.size.x])
		var progress_label: Label = ready_row.get("progress_label")
		if target_size == Vector2i(800, 450) and progress_label != null:
			var screen_scale := progress_label.get_screen_transform().get_scale().y
			var effective_font_size := float(progress_label.get_theme_font_size("font_size")) * screen_scale
			_check(effective_font_size >= 12.0, "Roster progress text should retain at least its authored 12 px baseline at 800x450 (effective=%0.1f px)." % effective_font_size)
		if roster_scroll != null:
			var horizontal_bar := roster_scroll.get_h_scroll_bar()
			var horizontal_overflow := horizontal_bar.max_value > horizontal_bar.page + 0.5
			_check(not horizontal_overflow and not horizontal_bar.visible, "Roster rows should not overflow horizontally at %s (max=%0.1f, page=%0.1f)." % [str(target_size), horizontal_bar.max_value, horizontal_bar.page])
			var vertical_bar := roster_scroll.get_v_scroll_bar()
			_check(vertical_bar.max_value > vertical_bar.page, "Roster list should retain vertical navigation at %s." % str(target_size))

	for recruit_value in recruit_ids:
		var recruit_id := str(recruit_value)
		var row: Dictionary = main.evolution_rows.get(recruit_id, {})
		if row.is_empty():
			continue
		var record_button: Button = row["record_button"]
		record_button.pressed.emit()
		var tier_key := "%s_tier" % recruit_id
		var expected_remaining := 11 - recruit_ids.find(recruit_id)
		_check(str(main.permanent_state["evolution"].get(tier_key, "")) == "Adapted Form", "%s purchase action should record its unique Adapted Form tier key." % recruit_id)
		_check(int(main.permanent_state["evolution_materials"]["evolution_data"]) == expected_remaining, "%s purchase should consume exactly one shared Evolution Data." % recruit_id)

	var roster_save: Dictionary = SAVE_SCRIPT.load_game(roster_save_path)
	_check(bool(roster_save.get("ok", false)), "Roster evolution purchases should persist through the existing versioned save service.")
	if bool(roster_save.get("ok", false)):
		var saved_permanent: Dictionary = roster_save["data"]["permanent"]
		_check(int(saved_permanent["evolution_materials"]["evolution_data"]) == 0, "Saved roster evolution should contain the full twelve-material deduction.")
		for recruit_value in recruit_ids:
			var recruit_id := str(recruit_value)
			var tier_key := "%s_tier" % recruit_id
			_check(str(saved_permanent["evolution"].get(tier_key, "")) == "Adapted Form", "Save/load should retain the %s per-recruit tier record." % tier_key)
		main.permanent_state["highest_wave_ever"] = 24
		main.permanent_state["evolution_materials"]["evolution_data"] = 12
		var locked_before: Dictionary = main.permanent_state.duplicate(true)
		main._refresh_evolution_dialog()
		var locked_cipher: Dictionary = main.evolution_rows["cipher"]
		_check(locked_cipher["record_button"].disabled and locked_cipher["progress_label"].text.contains("LOCKED: WAVE 75"), "Cipher's next tier should remain locked below its wave-75 gate despite sufficient shared materials.")
		main._evolve_recruit("cipher")
		_check(main.permanent_state == locked_before, "An ineligible evolution request should consume no materials and preserve live progression.")
		var after_locked_attempt: Dictionary = SAVE_SCRIPT.load_game(roster_save_path)
		_check(bool(after_locked_attempt.get("ok", false)) and after_locked_attempt["data"]["permanent"] == saved_permanent, "An ineligible evolution request should leave the committed save unchanged.")
		main.permanent_state["highest_wave_ever"] = 75
		main.permanent_state["evolution_materials"]["evolution_data"] = 2
		main._refresh_evolution_dialog()
		var eligible_cipher: Dictionary = main.evolution_rows["cipher"]
		_check(not eligible_cipher["record_button"].disabled and eligible_cipher["progress_label"].text.contains("READY: WAVE 75 + DATA 2"), "Cipher's Signature Form action should be eligible for the failed-save transaction fixture.")
		var non_breaker_failed_save_baseline: Dictionary = main.permanent_state.duplicate(true)
		var failed_roster_path := ProjectSettings.globalize_path("res://tests/_missing_roster_evolution_%d/save.json" % Time.get_ticks_usec())
		main.save_path = failed_roster_path
		eligible_cipher["record_button"].pressed.emit()
		_check(main.permanent_state == non_breaker_failed_save_baseline and main.feedback_label.text.contains("no materials were consumed"), "A failed non-BREAKER evolution save should preserve every tier and material without applying the purchase.")
		for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
			_check(not FileAccess.file_exists(failed_roster_path + suffix), "A failed non-BREAKER evolution save should leave no partial artifact: %s" % suffix)
		main.save_path = roster_save_path
		var saved_after_failed_non_breaker: Dictionary = SAVE_SCRIPT.load_game(roster_save_path)
		_check(bool(saved_after_failed_non_breaker.get("ok", false)) and saved_after_failed_non_breaker["data"]["permanent"] == saved_permanent, "A failed non-BREAKER evolution save should leave the previously committed save unchanged.")
		eligible_cipher["record_button"].pressed.emit()
		_check(main.permanent_state["evolution"]["cipher_tier"] == "Signature Form" and int(main.permanent_state["evolution_materials"]["evolution_data"]) == 0, "Cipher should advance to Signature Form at wave 75 by consuming exactly two Evolution Data.")
		var military_save: Dictionary = SAVE_SCRIPT.load_game(roster_save_path)
		_check(bool(military_save.get("ok", false)) and military_save["data"]["permanent"]["evolution"].get("cipher_tier", "") == "Signature Form" and int(military_save["data"]["permanent"]["evolution_materials"]["evolution_data"]) == 0, "Save/load should retain Cipher's Signature Form key and material deduction.")
		main.permanent_state["highest_wave_ever"] = 124
		main.permanent_state["evolution_materials"]["evolution_data"] = 3
		main._refresh_evolution_dialog()
		var locked_apex: Dictionary = main.evolution_rows["cipher"]
		_check(locked_apex["record_button"].disabled and locked_apex["progress_label"].text.contains("LOCKED: WAVE 125 + DATA 3"), "Cipher's Requiem Form should remain locked below wave 125 despite sufficient materials.")
		var locked_apex_baseline: Dictionary = main.permanent_state.duplicate(true)
		main._evolve_recruit("cipher")
		_check(main.permanent_state == locked_apex_baseline, "An ineligible Apex request should preserve Cipher's Signature Form tier and all three materials.")
		var save_after_locked_apex: Dictionary = SAVE_SCRIPT.load_game(roster_save_path)
		_check(bool(save_after_locked_apex.get("ok", false)) and save_after_locked_apex["data"]["permanent"] == military_save["data"]["permanent"], "An ineligible Apex request should leave the Signature Form save unchanged.")
		main.permanent_state["highest_wave_ever"] = 125
		main._refresh_evolution_dialog()
		var eligible_apex: Dictionary = main.evolution_rows["cipher"]
		_check(not eligible_apex["record_button"].disabled and eligible_apex["progress_label"].text.contains("READY: WAVE 125 + DATA 3"), "Cipher's Requiem Form action should unlock at wave 125 with three Evolution Data.")
		eligible_apex["record_button"].pressed.emit()
		_check(main.permanent_state["evolution"]["cipher_tier"] == "Requiem Form" and int(main.permanent_state["evolution_materials"]["evolution_data"]) == 0, "Cipher should reach Requiem Form at wave 125 by consuming exactly three Evolution Data.")
		var apex_save: Dictionary = SAVE_SCRIPT.load_game(roster_save_path)
		_check(bool(apex_save.get("ok", false)) and apex_save["data"]["permanent"]["evolution"].get("cipher_tier", "") == "Requiem Form" and int(apex_save["data"]["permanent"]["evolution_materials"]["evolution_data"]) == 0, "Save/load should retain Cipher's Requiem Form key and final material deduction.")
		for recruit_value in recruit_ids:
			var recruit_id := str(recruit_value)
			if recruit_id == "cipher":
				continue
			var tier_key := "%s_tier" % recruit_id
			_check(str(apex_save["data"]["permanent"]["evolution"].get(tier_key, "")) == "Adapted Form", "Cipher's later tiers should preserve %s's earlier saved Adapted Form record." % tier_key)

	main.evolution_dialog.hide()
	main.permanent_state = original_permanent
	main.save_path = original_save_path
	main.loaded_save_path = original_loaded_save_path
	main._refresh()
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var artifact_path: String = roster_save_path + suffix
		if FileAccess.file_exists(artifact_path):
			DirAccess.remove_absolute(artifact_path)
	root_window.size = original_window_size


func _test_wave_clear_autosave_and_recovery() -> void:
	var guard_main = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(guard_main)
	await process_frame
	var protected_path := ProjectSettings.globalize_path("res://tests/_existing_save_guard_%d.json" % Time.get_ticks_usec())
	var sentinel_permanent := {"lifetime_influence": 7, "highest_wave_ever": 9, "evolution_materials": {"evolution_data": 4}, "first_clear_material_claims": [], "research": {}, "research_nodes": {}, "evolution": {"breaker_tier": "Origin Form"}, "unlocks": []}
	var sentinel_run := {"credits": 901, "wave": 10, "highest_cleared_wave": 9, "recruits": {"breaker": {"level": 3}}, "squad_hp": [100.0, 100.0, 100.0, 100.0, 100.0, 100.0], "offline_claim_unix": 1700000000}
	_check(SAVE_SCRIPT.save_game(sentinel_permanent, sentinel_run, {"master_volume": 0.5, "window_mode": "windowed"}, protected_path) == OK, "Existing-save guard fixture should create a valid disposable save.")
	guard_main.save_path = protected_path
	guard_main.loaded_save_path = ""
	guard_main.director.wave_cleared.emit(25, 108, 25, "")
	var protected_after_clear: Dictionary = SAVE_SCRIPT.load_game(protected_path)
	_check(guard_main.feedback_label.text.contains("existing save kept") and guard_main.feedback_label.text.contains("Load or press Save"), "An unloaded existing save should be protected and explain how to enable autosave.")
	_check(bool(protected_after_clear.get("ok", false)) and protected_after_clear["data"]["run"]["credits"] == 901 and protected_after_clear["data"]["permanent"]["lifetime_influence"] == 7, "A wave clear before loading must leave an existing save byte-content equivalent in its important progression fields.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var protected_artifact: String = protected_path + suffix
		if FileAccess.file_exists(protected_artifact):
			DirAccess.remove_absolute(protected_artifact)
	guard_main.queue_free()
	await process_frame

	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var failure_directory := ProjectSettings.globalize_path("res://tests/_missing_autosave_dir_%d" % Time.get_ticks_usec())
	var failure_path := failure_directory.path_join("save.json")
	main.save_path = failure_path
	main.director.wave = 26
	main.director.highest_cleared_wave = 25
	main.director.economy.credits = 300
	main.director.economy.recruit_level = 2
	main.director.wave_cleared.emit(25, 108, 25, "")
	_check(main.feedback_label.text.contains("autosave failed") and main.feedback_label.text.contains("press Save"), "A failed wave-clear autosave should explain that manual Save is needed.")
	_check(int(main.permanent_state.get("evolution_materials", {}).get("evolution_data", 0)) == 2, "Wave-clear rewards should remain available in the current session after disk failure.")
	_check(not FileAccess.file_exists(failure_path), "Failed autosave should not create a partial primary save.")
	var save_path := ProjectSettings.globalize_path("res://tests/_wave_clear_autosave_%d.json" % Time.get_ticks_usec())
	main.save_path = save_path
	main.director.wave = 27
	main.director.highest_cleared_wave = 26
	main.director.wave_cleared.emit(26, 112, 26, "")
	_check(main.feedback_label.text.contains("wave saved"), "A later successful clear should report its automatic save.")
	var committed: Dictionary = SAVE_SCRIPT.load_game(save_path)
	_check(bool(committed.get("ok", false)), "A successful wave-clear autosave should produce a valid save.")
	if bool(committed.get("ok", false)):
		var saved: Dictionary = committed["data"]
		_check(int(saved["permanent"]["evolution_materials"]["evolution_data"]) == 3 and saved["permanent"]["first_clear_material_claims"] == ["district.undercity"], "Autosave must commit repeatable and first-clear material progress together.")
		_check(int(saved["permanent"]["highest_wave_ever"]) == 26, "Autosave must preserve the permanent highest-wave record.")
		_check(int(saved["run"]["wave"]) == 27 and int(saved["run"]["highest_cleared_wave"]) == 26 and int(saved["run"]["credits"]) == 300, "Autosave must persist the new run wave, holding wave, and credits together.")
		_check(int(saved["run"].get("offline_claim_unix", 0)) > 0 and saved["run"].get("active_lineup", []).size() == 6 and not saved["run"].has("squad_hp"), "Autosave must reset the offline baseline and preserve the six-slot identity-based lineup without positional HP.")
		_check(SAVE_SCRIPT._values_match(saved["settings"], main.settings_state), "Wave-clear autosave must retain settings.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var artifact_path: String = save_path + suffix
		if FileAccess.file_exists(artifact_path):
			DirAccess.remove_absolute(artifact_path)
	main.queue_free()
	await process_frame
	print("Wave-clear autosave: successful clear committed run and permanent rewards; failed write retained session state and requested manual Save.")


func _test_offline_earnings_live_load() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var save_path := ProjectSettings.globalize_path("res://tests/_offline_claim_%d.json" % Time.get_ticks_usec())
	var now_unix := int(Time.get_unix_time_from_system())
	var permanent := {"lifetime_influence": 3, "highest_wave_ever": 25, "evolution_materials": {"evolution_data": 2}, "first_clear_material_claims": ["district.undercity"], "research": {"combat": 1}, "evolution": {"breaker_tier": "Origin Form"}, "unlocks": ["breaker"]}
	var run := {"credits": 50, "wave": 40, "highest_cleared_wave": 25, "recruits": {"breaker": {"level": 4}}, "squad_hp": [120.0, 91.0, 83.0, 74.0, 65.0, 56.0], "offline_claim_unix": now_unix - 3600}
	var settings := {"master_volume": 0.45, "window_mode": "windowed"}
	var write_error: Error = SAVE_SCRIPT.save_game(permanent, run, settings, save_path)
	_check(write_error == OK, "Offline claim integration fixture should write a disposable save.")
	if write_error != OK:
		main.queue_free()
		return
	main.save_path = save_path
	main._load()
	_check(main.director.economy.credits == 158, "Returning after one offline hour should grant 108 credits from saved holding wave 25.")
	_check(main.director.wave == 40 and main.director.highest_cleared_wave == 25, "Offline claim load must preserve current and highest-cleared waves without advancing combat.")
	_check(main.director.economy.recruit_level == 4 and int(main.permanent_state["research"]["combat"]) == 1 and SAVE_SCRIPT._values_match(main.settings_state, settings), "Offline claim must preserve recruit level, permanent research, and settings.")
	_check(main.feedback_label.text.contains("+108 offline credits") and main.feedback_label.text.contains("no waves advanced"), "The load feedback should disclose the offline payout and no-wave-advance rule.")
	var claimed_save: Dictionary = SAVE_SCRIPT.load_game(save_path)
	_check(bool(claimed_save.get("ok", false)), "Offline reward should remain loadable after its save-before-apply commit.")
	if bool(claimed_save.get("ok", false)):
		_check(claimed_save["data"]["run"]["credits"] == 158 and claimed_save["data"]["run"]["wave"] == 40, "Committed offline save should include credits while preserving the saved wave.")
		_check(int(claimed_save["data"]["run"]["offline_claim_unix"]) >= now_unix, "Committed offline save should advance the claim timestamp only after payout persistence.")
	var credits_after_first_claim: int = main.director.economy.credits
	main._load()
	_check(main.director.economy.credits == credits_after_first_claim, "A second load must not duplicate an already committed offline claim.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var artifact_path: String = save_path + suffix
		if FileAccess.file_exists(artifact_path):
			DirAccess.remove_absolute(artifact_path)
	var legacy_path := ProjectSettings.globalize_path("res://tests/_offline_legacy_%d.json" % Time.get_ticks_usec())
	var legacy_run := {"credits": 77, "wave": 5, "highest_cleared_wave": 4, "recruits": {"breaker": {"level": 2}}}
	_check(SAVE_SCRIPT.save_game(permanent, legacy_run, settings, legacy_path) == OK, "Legacy save fixture without an offline timestamp should remain writable.")
	main.save_path = legacy_path
	main._load()
	_check(main.director.economy.credits == 77 and main.feedback_label.text.contains("no earlier time was claimed"), "Loading a legacy save should establish a baseline without retroactive earnings.")
	var baseline_save: Dictionary = SAVE_SCRIPT.load_game(legacy_path)
	_check(bool(baseline_save.get("ok", false)) and int(baseline_save.get("data", {}).get("run", {}).get("offline_claim_unix", 0)) >= now_unix, "Legacy baseline migration should persist the current timestamp before starting accrual.")
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var legacy_artifact: String = legacy_path + suffix
		if FileAccess.file_exists(legacy_artifact):
			DirAccess.remove_absolute(legacy_artifact)
	main.queue_free()


func _test_recovered_load_warning_and_offline_claim_deferral() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var now_unix := int(Time.get_unix_time_from_system())
	var backup_payload := _save_test_payload(50)
	backup_payload["run"]["wave"] = 25
	backup_payload["run"]["highest_cleared_wave"] = 25
	backup_payload["run"]["offline_claim_unix"] = now_unix - 3600
	var previous_payload := _save_test_payload(35)
	previous_payload["run"]["wave"] = 25
	previous_payload["run"]["highest_cleared_wave"] = 25
	previous_payload["run"]["offline_claim_unix"] = now_unix - 3600
	var recovery_cases: Array[Dictionary] = [
		{"label": ".bak", "primary_exists": true, "primary": "{corrupt primary", "backup_exists": true, "backup": JSON.stringify(backup_payload), "previous_exists": true, "previous": JSON.stringify(previous_payload), "expected_credits": 50, "warning": "previous valid save"},
		{"label": ".bak.prev", "primary_exists": true, "primary": "{corrupt primary", "backup_exists": true, "backup": "{corrupt backup", "previous_exists": true, "previous": JSON.stringify(previous_payload), "expected_credits": 35, "warning": "older recovery save"},
		{"label": ".bak.prev_missing_primary", "primary_exists": false, "backup_exists": false, "previous_exists": true, "previous": JSON.stringify(previous_payload), "expected_credits": 35, "warning": "primary save was missing; loaded the older recovery save"}
	]
	for recovery_case in recovery_cases:
		var save_path := ProjectSettings.globalize_path("res://tests/_recovered_load_%s_%d.json" % [str(recovery_case["label"]).replace(".", ""), Time.get_ticks_usec()])
		var fixture_files: Dictionary = {
			save_path: {"exists": bool(recovery_case.get("primary_exists", true)), "contents": str(recovery_case.get("primary", ""))},
			save_path + ".bak": {"exists": bool(recovery_case.get("backup_exists", true)), "contents": str(recovery_case.get("backup", ""))},
			save_path + ".bak.prev": {"exists": bool(recovery_case.get("previous_exists", true)), "contents": str(recovery_case.get("previous", ""))}
		}
		var fixture_ok := true
		for artifact_path in fixture_files:
			var artifact: Dictionary = fixture_files[artifact_path]
			if bool(artifact["exists"]):
				fixture_ok = _write_text_fixture(str(artifact_path), str(artifact["contents"])) and fixture_ok
		_check(fixture_ok, "The recovered-load %s fixture should write its primary and recovery files." % str(recovery_case["label"]))
		if fixture_ok:
			main.save_path = save_path
			main.loaded_save_path = ""
			main.feedback_label.text = ""
			main._load()
			_check(int(main.director.economy.credits) == int(recovery_case["expected_credits"]), "A %s recovery load should use the expected save and defer all offline credits." % str(recovery_case["label"]))
			_check(main.feedback_label.text.contains("Recovery copy loaded.") and main.feedback_label.text.contains(str(recovery_case["warning"])), "A %s recovery load should disclose which recovery source was selected." % str(recovery_case["label"]))
			_check(main.feedback_label.text.contains("Automatic offline claim was deferred; recovery did not write to the save set."), "A %s recovery load should explain that its eligible offline claim was deferred." % str(recovery_case["label"]))
			var save_set_unchanged := true
			for artifact_path in fixture_files:
				var artifact: Dictionary = fixture_files[artifact_path]
				if bool(artifact["exists"]):
					save_set_unchanged = save_set_unchanged and FileAccess.file_exists(str(artifact_path)) and FileAccess.get_file_as_string(str(artifact_path)) == str(artifact["contents"])
				else:
					save_set_unchanged = save_set_unchanged and not FileAccess.file_exists(str(artifact_path))
			for suffix in [".tmp", ".bak.tmp", ".bak.prev.tmp"]:
				save_set_unchanged = save_set_unchanged and not FileAccess.file_exists(save_path + suffix)
			_check(save_set_unchanged, "A %s recovery load must preserve existing save files byte-for-byte, keep absent files absent, and create no staging files." % str(recovery_case["label"]))
		for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
			if FileAccess.file_exists(save_path + suffix):
				DirAccess.remove_absolute(save_path + suffix)
	main.queue_free()
	await process_frame


func _test_hud_upgrade_transactions(main, single_button: Button, bulk_button: Button) -> void:
	var director = main.director
	var breaker_index: int = director._find_ally_index("breaker")
	var original_path := str(main.save_path)
	var original_loaded_path := str(main.loaded_save_path)
	var original_permanent: Dictionary = main.permanent_state.duplicate(true)
	var original_lifetime_influence: int = director.lifetime_influence
	var original_snapshot: Dictionary = director.snapshot()
	var fixture := ProjectSettings.globalize_path("res://tests/_upgrade_ui_%d.json" % Time.get_ticks_usec())
	var suffixes := ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]
	main.save_path = fixture
	main.loaded_save_path = fixture
	director.set_lifetime_influence(100)
	director.economy.credits = 19
	director.load_run_state({"credits": 19, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1, "hp": 100.0}}})
	_check(director.upgrade_cost(1) == 20, "The current BREAKER trial definition should price its first individual run-level upgrade at 20 credits.")
	single_button.pressed.emit()
	_check(main.feedback_label.text == "Not enough credits." and director.economy.credits == 19 and director.economy.recruit_level == 1 and is_equal_approx(float(director.allies[breaker_index]["hp"]), 100.0), "One credit below the level-1 cost should leave credits, level, and HP unchanged.")
	_check(not FileAccess.file_exists(fixture), "An unaffordable x1 HUD request should not create a save.")
	director.economy.credits = 20
	single_button.pressed.emit()
	_check(director.economy.credits == 0 and director.economy.recruit_level == 2, "An exact 20-credit x1 budget should buy exactly one level.")
	_check(is_equal_approx(float(director.allies[breaker_index]["hp"]), 109.0) and is_equal_approx(float(director.allies[breaker_index]["max_hp"]), 129.0), "The x1 purchase should add the configured trial HP while preserving the same current-HP increment.")
	_check(is_equal_approx(float(director.allies[breaker_index]["attack_power"]), 21.42), "A run-level purchase should retain the 5% lifetime Influence damage modifier.")
	var single_saved := SAVE_SCRIPT.load_game(fixture)
	_check(bool(single_saved.get("ok", false)), "An exact-budget x1 purchase should persist through SaveService.")
	if bool(single_saved.get("ok", false)):
		var saved_run: Dictionary = single_saved["data"]["run"]
		_check(int(saved_run["credits"]) == 0 and int(saved_run["recruits"]["breaker"]["level"]) == 2 and is_equal_approx(float(saved_run["recruits"]["breaker"]["hp"]), 109.0) and not saved_run.has("squad_hp"), "The x1 save should contain the committed credits, run level, and identity-based BREAKER HP together.")
		_check(int(single_saved["data"]["permanent"]["lifetime_influence"]) == 0, "Run-level upgrades must leave permanent Influence balances unchanged.")
	var expected_costs: Array[int] = []
	var expected_cost_source := {"upgrade_cost_base": 20, "upgrade_cost_growth": 1.12}
	var expected_total := 0
	for level in range(1, 11):
		var trial_cost := roundi(float(expected_cost_source["upgrade_cost_base"]) * pow(float(expected_cost_source["upgrade_cost_growth"]), float(level - 1)))
		expected_costs.append(trial_cost)
		expected_total += trial_cost
	_check(expected_costs == [20, 22, 25, 28, 31, 35, 39, 44, 50, 55] and expected_total == 349, "The current trial formula should yield the Godot roundi cost sequence [20,22,25,28,31,35,39,44,50,55] for ten levels.")	
	var observed_costs: Array[int] = []
	var observed_total := 0
	for level in range(1, 11):
		var observed_cost: int = director.upgrade_cost(level)
		observed_costs.append(observed_cost)
		observed_total += observed_cost
	_check(observed_costs == expected_costs and observed_total == 349, "CombatDirector costs should match the current trial definition under Godot roundi.")
	director.load_run_state({"credits": 349, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1, "hp": 100.0}}})
	bulk_button.pressed.emit()
	_check(director.economy.credits == 0 and director.economy.recruit_level == 11, "An exact 349-credit x10 budget should buy all ten levels and spend the full budget.")
	_check(is_equal_approx(float(director.allies[breaker_index]["hp"]), 190.0) and is_equal_approx(float(director.allies[breaker_index]["max_hp"]), 210.0) and is_equal_approx(float(director.allies[breaker_index]["attack_power"]), 44.1), "The x10 result should apply ten trial stat increments and preserve the lifetime damage modifier.")
	var bulk_saved := SAVE_SCRIPT.load_game(fixture)
	_check(bool(bulk_saved.get("ok", false)) and int(bulk_saved["data"]["run"]["recruits"]["breaker"]["level"]) == 11 and bulk_saved["data"]["run"]["credits"] == 0, "The exact-budget x10 purchase should save the resulting level and credits.")
	director.load_run_state({"credits": 348, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1, "hp": 100.0}}})
	bulk_button.pressed.emit()
	_check(director.economy.recruit_level == 10 and director.economy.credits == 54, "A 348-credit x10 budget should buy the affordable nine-level prefix and leave 54 credits before the tenth cost of 55.")
	_check(is_equal_approx(float(director.allies[breaker_index]["hp"]), 181.0) and is_equal_approx(float(director.allies[breaker_index]["max_hp"]), 201.0), "A nine-level x10 prefix should apply exactly nine trial HP increments.")
	var failed_path := ProjectSettings.globalize_path("res://tests/_missing_upgrade_%d/save.json" % Time.get_ticks_usec())
	main.save_path = failed_path
	director.load_run_state({"credits": 20, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1, "hp": 100.0}}})
	var failed_attack := float(director.allies[breaker_index]["attack_power"])
	single_button.pressed.emit()
	_check(director.economy.credits == 20 and director.economy.recruit_level == 1 and is_equal_approx(float(director.allies[breaker_index]["hp"]), 100.0) and is_equal_approx(float(director.allies[breaker_index]["max_hp"]), 120.0) and is_equal_approx(float(director.allies[breaker_index]["attack_power"]), failed_attack), "A failed SaveService write must leave live credits, level, HP, max HP, and attack unchanged.")
	_check(main.feedback_label.text.contains("were not changed"), "A failed upgrade save should tell the player that the recruit and credits were preserved.")
	var sentinel_path := ProjectSettings.globalize_path("res://tests/_unloaded_upgrade_%d.json" % Time.get_ticks_usec())
	var sentinel_permanent := {"lifetime_influence": 8, "highest_wave_ever": 9, "evolution_materials": {"evolution_data": 2}, "first_clear_material_claims": [], "research": {}, "research_nodes": {}, "evolution": {"breaker_tier": "Origin Form"}, "unlocks": []}
	var sentinel_run := {"credits": 77, "wave": 4, "highest_cleared_wave": 3, "recruits": {"breaker": {"level": 2, "hp": 120.0}}}
	_check(SAVE_SCRIPT.save_game(sentinel_permanent, sentinel_run, {}, sentinel_path) == OK, "The unloaded-save guard test should create a valid sentinel save.")
	var sentinel_bytes := FileAccess.get_file_as_string(sentinel_path)
	main.save_path = sentinel_path
	main.loaded_save_path = ""
	director.load_run_state({"credits": 20, "wave": 1, "highest_cleared_wave": 0, "recruits": {"breaker": {"level": 1, "hp": 100.0}}})
	single_button.pressed.emit()
	_check(main.feedback_label.text.contains("Load it before upgrading") and FileAccess.get_file_as_string(sentinel_path) == sentinel_bytes, "An existing save that has not been loaded should block x1 and keep the sentinel save byte-for-byte unchanged.")
	_check(director.economy.credits == 20 and director.economy.recruit_level == 1 and is_equal_approx(float(director.allies[breaker_index]["hp"]), 100.0), "The unloaded-save guard should preserve the live run state.")
	for path in [fixture, failed_path, sentinel_path]:
		for suffix in suffixes:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(path + suffix)
	main.save_path = original_path
	main.loaded_save_path = original_loaded_path
	main.permanent_state = original_permanent
	director.set_lifetime_influence(original_lifetime_influence)
	director.economy.credits = int(original_snapshot.get("credits", 0))
	director.economy.recruit_level = int(original_snapshot.get("recruit_level", 1))
	director.wave = int(original_snapshot.get("wave", 1))
	director.highest_cleared_wave = int(original_snapshot.get("highest_cleared_wave", 0))
	director.phase = str(original_snapshot.get("phase", "combat"))
	director.player_x = float(original_snapshot.get("player_x", director.player_x))
	director.player_hp = float(original_snapshot.get("player_hp", director.player_hp))
	director.enemy_x = float(original_snapshot.get("enemy_x", director.enemy_x))
	director.enemy_hp = float(original_snapshot.get("enemy_hp", director.enemy_hp))
	director.allies = original_snapshot.get("allies", []).duplicate(true)
	main._refresh()


func _find_descendant_by_type(node: Node, expected_type: Variant) -> Node:
	if is_instance_of(node, expected_type):
		return node
	for child in node.get_children():
		var match_node := _find_descendant_by_type(child, expected_type)
		if match_node != null:
			return match_node
	return null


func _collect_buttons(node: Node, buttons: Array[Button]) -> void:
	if node is Button:
		buttons.append(node)
	for child in node.get_children():
		_collect_buttons(child, buttons)


func _find_speed_controls(node: Node) -> Array[String]:
	var matches: Array[String] = []
	var searchable_text := str(node.name).to_lower()
	if node is Button:
		searchable_text += " " + (node as Button).text.to_lower()
	if node is Control:
		searchable_text += " " + (node as Control).tooltip_text.to_lower()
	var is_interactive_control := node is Button or node is Range or node is LineEdit
	if is_interactive_control and (searchable_text.contains("speed") or searchable_text.contains("pace")):
		matches.append(str(node.get_path()))
	for child in node.get_children():
		matches.append_array(_find_speed_controls(child))
	return matches


func _contains_movement_preference_key(value: Variant) -> bool:
	if typeof(value) == TYPE_DICTIONARY:
		for key in value:
			var normalized_key := str(key).to_lower()
			if normalized_key in ["speed", "move_speed", "movement_speed", "walking_speed", "walk_speed", "pace", "game_speed", "combat_speed"]:
				return true
			if _contains_movement_preference_key(value[key]):
				return true
	elif typeof(value) == TYPE_ARRAY:
		for item in value:
			if _contains_movement_preference_key(item):
				return true
	return false






