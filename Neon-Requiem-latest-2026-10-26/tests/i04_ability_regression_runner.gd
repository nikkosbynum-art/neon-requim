extends SceneTree

const DIRECTOR_SCRIPT := preload("res://scripts/combat/combat_director.gd")
const MAIN_SCENE := preload("res://scenes/main.tscn")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var director: Node = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	await process_frame
	_check(director.combat_model == "direct_damage", "Direct damage must remain the default combat model.")
	_check(not director.ability_trial_enabled and director.ability_trial_valid, "The ability trial profile should validate but remain disabled by default.")
	_check(director.configure_ability_trial(true), "A valid ability trial profile should opt in successfully.")
	var valid_profile: Dictionary = director.ability_trial_def.duplicate(true)
	director.ability_trial_def["abilities"]["echo"]["cooldown_seconds"] = 0.0
	_check(not director._validate_ability_trial_definition(), "An invalid cooldown must fail profile validation.")
	director.ability_trial_def = valid_profile
	director.ability_trial_valid = director._validate_ability_trial_definition()
	director.queue_free()
	await process_frame

	await _test_bulwark_and_no_revive()
	await _test_breaker_commit_and_cleanup()
	await _test_cipher_target_and_fallback()
	await _test_spark_sequence()
	await _test_specter_priority_and_cloak()
	await _test_ironclad_and_stitch()
	await _test_recoil_vector_order()
	await _test_echo_decoy()
	await _test_deadlock_and_progress()
	await _test_glitch_readiness_and_retarget()
	await _test_no_target_readiness_matrix()
	await _test_action_boundary_dispatch_all_recruits()
	await _test_cipher_equal_distance_tie()
	await _test_echo_timer_expiry()
	await _test_target_bound_status_cleanup()
	await _test_heal_caps()
	await _test_save_state_non_mutation()
	await _test_all_terminal_cleanup()

	if failures == 0:
		print("All focused I-04 ability regressions passed.")
		quit(0)
	else:
		push_error("%d focused I-04 ability regression(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("TEST FAILED: " + message)


func _new_director(skill_id: String) -> Node:
	var director: Node = DIRECTOR_SCRIPT.new()
	root.add_child(director)
	await process_frame
	var lineup := ["breaker", "bulwark", "cipher", "spark", "specter", "ironclad"]
	if skill_id not in lineup:
		lineup[5] = skill_id
	director._build_squad(lineup)
	director._begin_encounter()
	director.configure_ability_trial(true)
	for index in range(director.allies.size()):
		director.allies[index]["x"] = 500.0
		director.allies[index]["engagement_distance"] = 200.0
		director.allies[index]["attack_elapsed"] = 0.0
	return director


func _idx(director: Node, recruit_id: String) -> int:
	return director._find_ally_index(recruit_id)


func _events_for(director: Node) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	director.combat_action_resolved.connect(func(event: Dictionary) -> void: events.append(event))
	return events


func _set_allies_down_except(director: Node, recruit_id: String) -> void:
	for index in range(director.allies.size()):
		if str(director.allies[index].get("id", "")) != recruit_id:
			director.allies[index]["hp"] = 0.0


func _test_bulwark_and_no_revive() -> void:
	var director: Node = await _new_director("bulwark")
	var bulwark_index := _idx(director, "bulwark")
	var breaker_index := _idx(director, "breaker")
	var breaker: Dictionary = director.allies[breaker_index]
	breaker["hp"] = 10.0
	director.allies[breaker_index] = breaker
	var downed_index := _idx(director, "cipher")
	director.allies[downed_index]["hp"] = 0.0
	var committed: bool = director._try_resolve_ability(bulwark_index, "undercity_grunt")
	_check(committed and float(director.allies[breaker_index]["hp"]) > 10.0, "BULWARK should heal qualifying living allies.")
	_check(float(director.allies[downed_index]["hp"]) == 0.0, "BULWARK must not revive a defeated ally.")
	_check(director.ability_cooldown_until.has("bulwark"), "BULWARK cooldown should begin on its committed heal.")
	director.queue_free()
	await process_frame


func _test_breaker_commit_and_cleanup() -> void:
	var director: Node = await _new_director("breaker")
	_set_allies_down_except(director, "breaker")
	var breaker_index := _idx(director, "breaker")
	var events := _events_for(director)
	var before_hp: float = float(director.enemy_hp)
	_check(director._try_resolve_ability(breaker_index, "undercity_grunt"), "BREAKER should commit Redline with a legal target.")
	_check(director.enemy_hp < before_hp and float(director._active_ability_effect("breaker", "attack_interval_add", 0.0)) > 0.0, "Redline should damage first and then apply temporary strain.")
	_check(events.size() == 2 and events[0].get("event_type") == "attack_resolved" and events[1].get("event_type") == "ability_resolved", "Redline should publish its committed attack before its ability event.")
	_check(director.ability_cooldown_until.has("breaker"), "Redline cooldown should start on the attack commit.")
	director._begin_encounter()
	_check(director.ability_cooldown_until.is_empty() and director.ability_effects.is_empty(), "Encounter start should clear ability cooldowns and temporary effects.")
	director.queue_free()
	await process_frame


func _test_cipher_target_and_fallback() -> void:
	var director: Node = await _new_director("cipher")
	_set_allies_down_except(director, "cipher")
	var cipher_index := _idx(director, "cipher")
	var events := _events_for(director)
	_check(director._try_resolve_ability(cipher_index, "undercity_grunt"), "CIPHER should commit a legal cyberware attack.")
	_check(bool(director.enemy_ability_state.get("undercity_grunt", {}).get("cyberware_disabled", false)), "CIPHER should disable functional cyberware on its selected target.")
	_check(events.size() == 2 and events[0].get("attack_style") == "precision" and events[1].get("effect_id") == "precision_and_cyberware_disable", "CIPHER should emit its precision shot before the disable event.")
	director.queue_free()
	await process_frame

	director = await _new_director("cipher")
	_set_allies_down_except(director, "cipher")
	director.enemy_hp = 0.0
	var ordinary_fixture: Array[Dictionary] = [{"id": "ordinary_target", "hp": 300.0, "max_hp": 300.0, "x": 520.0}]
	_check(director.set_trial_enemy_fixture(ordinary_fixture), "CIPHER ordinary-target fixture should be accepted.")
	events = _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "cipher"), "ordinary_target"), "CIPHER should consume Ghost Round on its ordinary precision fallback.")
	_check(events.size() == 2 and events[1].get("effect_id") == "ordinary_precision_fallback" and director.ability_cooldown_until.has("cipher"), "CIPHER fallback should emit its event and start cooldown.")
	director.queue_free()
	await process_frame


func _test_spark_sequence() -> void:
	var director: Node = await _new_director("spark")
	_set_allies_down_except(director, "spark")
	var fixture: Array[Dictionary] = [
		{"id": "spark_a", "hp": 5.0, "max_hp": 5.0, "x": 510.0, "attack_power": 1.0},
		{"id": "spark_b", "hp": 5.0, "max_hp": 5.0, "x": 520.0, "attack_power": 1.0}
	]
	_check(director.set_trial_enemy_fixture(fixture), "SPARK multi-target fixture should be accepted in the opted-in trial.")
	var events := _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "spark"), "undercity_grunt"), "SPARK should commit when its first drone attack lands.")
	var attacks: Array[Dictionary] = events.filter(func(event: Dictionary) -> bool: return event.get("event_type") == "attack_resolved")
	_check(attacks.size() == 3, "SPARK should emit up to three sequential committed drone attacks.")
	_check(attacks.size() == 3 and attacks[0].get("target_id") == "spark_a" and attacks[1].get("target_id") == "spark_b", "SPARK should retarget after each defeated fixture enemy.")
	_check(events.size() == 4 and events[3].get("event_type") == "ability_resolved", "SPARK should batch its ability event after all committed attack events.")
	director.queue_free()
	await process_frame


func _test_specter_priority_and_cloak() -> void:
	var director: Node = await _new_director("specter")
	_set_allies_down_except(director, "specter")
	var fixture: Array[Dictionary] = [
		{"id": "power_a", "hp": 100.0, "max_hp": 100.0, "x": 520.0, "attack_power": 100.0, "attack_interval": 0.2},
		{"id": "power_b", "hp": 100.0, "max_hp": 100.0, "x": 530.0, "attack_power": 100.0, "attack_interval": 0.2}
	]
	director.set_trial_enemy_fixture(fixture)
	var events := _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "specter"), "undercity_grunt"), "SPECTER should commit its priority strike.")
	_check(events.size() == 2 and events[0].get("target_id") == "power_a" and bool(director._active_ability_effect("specter", "cloaked", false)), "SPECTER should break equal-power ties by stable ID and cloak after its strike.")
	director.allies[_idx(director, "breaker")]["hp"] = float(director.allies[_idx(director, "breaker")]["max_hp"])
	_check(director._select_enemy_target_for_x(500.0) == _idx(director, "breaker"), "Enemy targeting should exclude cloaked SPECTER when another living ally is available.")
	director.queue_free()
	await process_frame


func _test_ironclad_and_stitch() -> void:
	var director: Node = await _new_director("ironclad")
	_set_allies_down_except(director, "ironclad")
	var ironclad_index := _idx(director, "ironclad")
	_check(director._try_resolve_ability(ironclad_index, "undercity_grunt"), "IRONCLAD should commit Lockdown against a legal target.")
	_check(bool(director._active_ability_effect("ironclad", "anchored", false)) and float(director._enemy_attack_multiplier("undercity_grunt")) < 1.0, "Lockdown should anchor IRONCLAD and suppress the target.")
	director.queue_free()
	await process_frame

	director = await _new_director("stitch")
	_set_allies_down_except(director, "stitch")
	var stitch_index := _idx(director, "stitch")
	var breaker_index := _idx(director, "breaker")
	director.allies[breaker_index]["hp"] = 10.0
	var dead_index := _idx(director, "cipher")
	director.allies[dead_index]["hp"] = 0.0
	_check(director._try_resolve_ability(stitch_index, "undercity_grunt"), "STITCH should commit when a living ally is below threshold.")
	_check(float(director.allies[breaker_index]["hp"]) > 10.0 and float(director._active_ability_effect("breaker", "team_attack_multiplier", 1.0)) > 1.0, "STITCH should heal the lowest-ratio living ally and boost living allies.")
	_check(director._active_ability_effect("cipher", "team_attack_multiplier", 1.0) == 1.0, "STITCH must not buff a defeated ally.")
	_check(float(director._active_ability_effect("stitch", "attack_interval_add", 0.0)) > 0.0, "STITCH should apply its temporary instability cost.")
	director.queue_free()
	await process_frame


func _test_recoil_vector_order() -> void:
	for recruit_id in ["recoil", "vector"]:
		var director: Node = await _new_director(recruit_id)
		_set_allies_down_except(director, recruit_id)
		var fixture: Array[Dictionary] = [
			{"id": "near", "hp": 500.0, "max_hp": 500.0, "x": 510.0},
			{"id": "far", "hp": 500.0, "max_hp": 500.0, "x": 540.0}
		]
		director.set_trial_enemy_fixture(fixture)
		var events := _events_for(director)
		_check(director._try_resolve_ability(_idx(director, recruit_id), "undercity_grunt"), "%s should commit its multi-target attack sequence." % recruit_id)
		var attacks: Array[Dictionary] = events.filter(func(event: Dictionary) -> bool: return event.get("event_type") == "attack_resolved")
		_check(attacks.size() == 3 and attacks[0].get("target_id") == "near" and attacks[1].get("target_id") == "far", "%s attacks should follow nearest-first fixture order." % recruit_id)
		_check(events.size() == 4 and events[3].get("event_type") == "ability_resolved", "%s should publish the sequence summary after its attack events." % recruit_id)
		director.queue_free()
		await process_frame


func _test_echo_decoy() -> void:
	var director: Node = await _new_director("echo")
	_set_allies_down_except(director, "echo")
	var events := _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "echo"), "undercity_grunt"), "ECHO should register an abstract decoy when a living enemy exists.")
	_check(not director.echo_decoy.is_empty() and events.size() == 1 and events[0].get("effect_id") == "abstract_enemy_lure" and events[0].get("physical_actor") == false, "ECHO should present only an abstract token, with no physical actor mapping.")
	var echo_index := _idx(director, "echo")
	var echo_hp_before := float(director.allies[echo_index]["hp"])
	director.echo_decoy["durability"] = 1.0
	director._simulate_enemy(1.1)
	_check(float(director.allies[echo_index]["hp"]) == echo_hp_before and director.echo_decoy.is_empty(), "Enemy attacks should consume decoy durability without defeating a recruit.")
	director.queue_free()
	await process_frame


func _test_deadlock_and_progress() -> void:
	var director: Node = await _new_director("deadlock")
	_set_allies_down_except(director, "deadlock")
	_check(director.configure_combat_model("hybrid_trial", 731), "DEADLOCK progress-hook fixture should enable the valid I-05 trial model.")
	var fixture: Array[Dictionary] = [
		{"id": "implant_low", "hp": 100.0, "max_hp": 100.0, "x": 520.0, "capabilities": {"functional_implants": true, "implant_strength": 1.0}},
		{"id": "implant_high", "hp": 100.0, "max_hp": 100.0, "x": 530.0, "capabilities": {"functional_implants": true, "implant_strength": 4.0}}
	]
	director.set_trial_enemy_fixture(fixture)
	director._qualifying_progress_pending = false
	var events := _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "deadlock"), "undercity_grunt"), "DEADLOCK should disable the strongest eligible implant target.")
	_check(bool(director.enemy_ability_state.get("implant_high", {}).get("implants_disabled", false)) and events.size() == 1 and director._qualifying_progress_pending, "DEADLOCK should disable its selected target, emit the event, and report qualifying progress.")
	director.queue_free()
	await process_frame


func _test_glitch_readiness_and_retarget() -> void:
	var director: Node = await _new_director("glitch")
	_set_allies_down_except(director, "glitch")
	var glitch_index := _idx(director, "glitch")
	var glitch: Dictionary = director.allies[glitch_index]
	glitch["attack_elapsed"] = director._effective_ally_attack_interval(glitch)
	director.allies[glitch_index] = glitch
	var events := _events_for(director)
	director._simulate_allies(director.FIXED_STEP)
	_check(not director.ability_cooldown_until.has("glitch") and not director._active_ability_effect("glitch", "frame_skip", false), "GLITCH should stay ready with only one living enemy.")
	director.queue_free()
	await process_frame

	director = await _new_director("glitch")
	_set_allies_down_except(director, "glitch")
	glitch_index = _idx(director, "glitch")
	var fixture: Array[Dictionary] = [{"id": "alternate", "hp": 500.0, "max_hp": 500.0, "x": 520.0, "attack_power": 1.0}]
	director.set_trial_enemy_fixture(fixture)
	glitch = director.allies[glitch_index]
	glitch["attack_elapsed"] = director._effective_ally_attack_interval(glitch)
	director.allies[glitch_index] = glitch
	events = _events_for(director)
	director._simulate_allies(director.FIXED_STEP)
	var first_target := str(events[0].get("target_id", "")) if not events.is_empty() else ""
	glitch = director.allies[glitch_index]
	glitch["attack_elapsed"] = director._effective_ally_attack_interval(glitch)
	director.allies[glitch_index] = glitch
	director._simulate_allies(director.FIXED_STEP)
	var attack_targets: Array[String] = []
	for event in events:
		if event.get("event_type") == "attack_resolved":
			attack_targets.append(str(event.get("target_id", "")))
	_check(attack_targets.size() >= 2 and attack_targets[0] == "alternate" and attack_targets[1] == "undercity_grunt", "GLITCH should alternate to the nearest other legal target after the current attack.")
	_check(first_target == "alternate" and director.ability_cooldown_until.has("glitch"), "GLITCH should start its cooldown only after the current attack commits with two enemies present.")
	var glitch_effects: Dictionary = director.ability_effects.get("glitch", {})
	var glitch_burst: Dictionary = glitch_effects.get("frame_skip", {})
	director.sim_time = float(glitch_burst.get("expires_at", 0.0))
	director._advance_ability_effects()
	_check(not director._active_ability_effect("glitch", "frame_skip", false), "GLITCH should restore ordinary targeting after the burst simulation timer expires.")
	director.queue_free()
	await process_frame


func _test_no_target_readiness_matrix() -> void:
	var recruit_ids := ["bulwark", "breaker", "cipher", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock"]
	for recruit_id in recruit_ids:
		var director: Node = await _new_director(recruit_id)
		if recruit_id == "deadlock":
			director.enemy_ability_state["undercity_grunt"] = {"implants_disabled": true}
		else:
			director.enemy_hp = 0.0
			director.additional_enemy_targets.clear()
		var events := _events_for(director)
		var committed: bool = director._try_resolve_ability(_idx(director, recruit_id), "")
		_check(not committed and events.is_empty(), "%s should stay ready and emit no event when its contract has no legal target/recipient." % recruit_id)
		_check(not director.ability_cooldown_until.has(recruit_id) and director._ability_is_ready(recruit_id), "%s must not start cooldown when its ability cannot commit." % recruit_id)
		director.queue_free()
		await process_frame

	var glitch_director: Node = await _new_director("glitch")
	_set_allies_down_except(glitch_director, "glitch")
	var glitch_index := _idx(glitch_director, "glitch")
	var glitch: Dictionary = glitch_director.allies[glitch_index]
	glitch["attack_elapsed"] = glitch_director._effective_ally_attack_interval(glitch)
	glitch_director.allies[glitch_index] = glitch
	var glitch_events := _events_for(glitch_director)
	glitch_director._simulate_allies(glitch_director.FIXED_STEP)
	_check(not glitch_director.ability_cooldown_until.has("glitch") and not glitch_director._active_ability_effect("glitch", "frame_skip", false), "GLITCH should stay ready with one living enemy and no alternative target.")
	_check(glitch_events.size() == 1 and glitch_events[0].get("event_type") == "attack_resolved", "Ineligible GLITCH should continue ordinary behavior without an ability event.")
	glitch_director.queue_free()
	await process_frame


func _test_action_boundary_dispatch_all_recruits() -> void:
	var recruit_ids := ["bulwark", "breaker", "cipher", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]
	for recruit_id in recruit_ids:
		var director: Node = await _new_director(recruit_id)
		_set_allies_down_except(director, recruit_id)
		if recruit_id in ["bulwark", "stitch"]:
			var patient_index := _idx(director, "breaker")
			director.allies[patient_index]["hp"] = 10.0
		if recruit_id == "glitch":
			var fixture: Array[Dictionary] = [{"id": "alternate", "hp": 500.0, "max_hp": 500.0, "x": 520.0, "attack_power": 1.0}]
			_check(director.set_trial_enemy_fixture(fixture), "GLITCH action-boundary fixture should be accepted.")
		var actor_index := _idx(director, recruit_id)
		var actor: Dictionary = director.allies[actor_index]
		actor["attack_elapsed"] = director._effective_ally_attack_interval(actor)
		director.allies[actor_index] = actor
		var events := _events_for(director)
		director._simulate_allies(director.FIXED_STEP)
		var ability_events: Array[Dictionary] = events.filter(func(event: Dictionary) -> bool:
			return event.get("event_type") == "ability_resolved" and event.get("source_id") == recruit_id
		)
		_check(ability_events.size() == 1, "%s should dispatch exactly one ability check at its normal action boundary." % recruit_id)
		_check(float(director.allies[actor_index].get("attack_elapsed", -1.0)) == 0.0, "%s should consume the committed ability action boundary." % recruit_id)
		if recruit_id in ["bulwark", "ironclad", "stitch", "echo", "deadlock"]:
			var source_attacks: Array[Dictionary] = events.filter(func(event: Dictionary) -> bool:
				return event.get("event_type") == "attack_resolved" and event.get("source_id") == recruit_id
			)
			_check(source_attacks.is_empty(), "%s must not start a second ordinary attack in the same boundary after a non-attack ability commits." % recruit_id)
		director.queue_free()
		await process_frame


func _test_cipher_equal_distance_tie() -> void:
	var director: Node = await _new_director("cipher")
	_set_allies_down_except(director, "cipher")
	var fixture: Array[Dictionary] = [
		{"id": "cipher_tie_b", "hp": 400.0, "max_hp": 400.0, "x": 520.0, "capabilities": {"functional_cyberware": true}},
		{"id": "cipher_tie_a", "hp": 400.0, "max_hp": 400.0, "x": 520.0, "capabilities": {"functional_cyberware": true}}
	]
	_check(director.set_trial_enemy_fixture(fixture), "CIPHER equal-distance fixture should be accepted.")
	var events := _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "cipher"), "undercity_grunt"), "CIPHER should commit against an eligible equal-distance target.")
	_check(not events.is_empty() and events[0].get("target_id") == "cipher_tie_a", "CIPHER should break equal-distance cyberware target ties by stable actor ID.")
	director.queue_free()
	await process_frame


func _test_echo_timer_expiry() -> void:
	var director: Node = await _new_director("echo")
	_set_allies_down_except(director, "echo")
	var events := _events_for(director)
	_check(director._try_resolve_ability(_idx(director, "echo"), "undercity_grunt"), "ECHO should commit before its expiry check.")
	var expiry_time := float(director.echo_decoy.get("expires_at", -1.0))
	director.sim_time = expiry_time
	director._advance_ability_effects()
	_check(expiry_time > 0.0 and director.echo_decoy.is_empty(), "ECHO should remove its token when simulation time reaches its expiry.")
	_check(events.size() == 2 and events[1].get("effect_id") == "decoy_expired", "ECHO should emit the expiry result after removing the token.")
	director.queue_free()
	await process_frame


func _test_target_bound_status_cleanup() -> void:
	for recruit_id in ["cipher", "ironclad", "deadlock"]:
		var director: Node = await _new_director(recruit_id)
		_set_allies_down_except(director, recruit_id)
		var target_id := "undercity_grunt"
		_check(director._try_resolve_ability(_idx(director, recruit_id), target_id), "%s should commit its target-bound effect before the target is defeated." % recruit_id)
		_check(director.enemy_ability_state.has(target_id), "%s should establish target-bound state before target defeat." % recruit_id)
		director._set_enemy_target_property(target_id, "hp", 0.0)
		_check(not director.enemy_ability_state.has(target_id), "%s target-bound state should be removed when its target is defeated." % recruit_id)
		director.queue_free()
		await process_frame


func _test_heal_caps() -> void:
	var director: Node = await _new_director("bulwark")
	var bulwark_ability: Dictionary = director.ability_trial_def["abilities"]["bulwark"]
	bulwark_ability["emergency_hp_ratio"] = 1.0
	bulwark_ability["heal_amount"] = 100.0
	director.ability_trial_def["abilities"]["bulwark"] = bulwark_ability
	var breaker_index := _idx(director, "breaker")
	director.allies[breaker_index]["hp"] = float(director.allies[breaker_index]["max_hp"]) - 1.0
	_check(director._try_resolve_ability(_idx(director, "bulwark"), "undercity_grunt"), "BULWARK should commit its cap-boundary heal.")
	_check(is_equal_approx(float(director.allies[breaker_index]["hp"]), float(director.allies[breaker_index]["max_hp"])), "BULWARK healing must cap at max HP.")
	director.queue_free()
	await process_frame

	director = await _new_director("stitch")
	var stitch_ability: Dictionary = director.ability_trial_def["abilities"]["stitch"]
	stitch_ability["heal_threshold_ratio"] = 1.0
	stitch_ability["heal_amount"] = 100.0
	director.ability_trial_def["abilities"]["stitch"] = stitch_ability
	breaker_index = _idx(director, "breaker")
	director.allies[breaker_index]["hp"] = float(director.allies[breaker_index]["max_hp"]) - 1.0
	_check(director._try_resolve_ability(_idx(director, "stitch"), "undercity_grunt"), "STITCH should commit its cap-boundary heal.")
	_check(is_equal_approx(float(director.allies[breaker_index]["hp"]), float(director.allies[breaker_index]["max_hp"])), "STITCH healing must cap at max HP.")
	director.queue_free()
	await process_frame


func _test_save_state_non_mutation() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	var director: Node = main.director
	var base_run: Dictionary = main._make_run_snapshot(director.snapshot())
	director.ability_cooldown_until["echo"] = director.sim_time + 5.0
	director.ability_effects["echo"] = {"decoy_visual": {"expires_at": director.sim_time + 5.0, "value": true}}
	director.enemy_ability_state["undercity_grunt"] = {"cyberware_disabled": true, "implants_disabled": true}
	director.echo_decoy = {"token_id": "echo_decoy", "durability": 5.0, "expires_at": director.sim_time + 5.0}
	var ability_state_run: Dictionary = main._make_run_snapshot(director.snapshot())
	_check(base_run == ability_state_run, "Ability cooldown/effect state must not alter the serialized run snapshot.")
	for forbidden_key in ["ability_cooldown_until", "ability_effects", "enemy_ability_state", "echo_decoy"]:
		_check(not ability_state_run.has(forbidden_key), "Serialized run data must not contain %s." % forbidden_key)
	main.queue_free()
	await process_frame


func _test_all_terminal_cleanup() -> void:
	for terminal in ["victory", "defeat", "retreat"]:
		var director: Node = await _new_director("echo")
		director.ability_cooldown_until["echo"] = director.sim_time + 10.0
		director.ability_effects["echo"] = {"test_effect": {"expires_at": director.sim_time + 10.0, "value": true}}
		director.enemy_ability_state["undercity_grunt"] = {"suppressed_until": director.sim_time + 10.0, "suppression_multiplier": 0.5}
		director.echo_decoy = {"token_id": "echo_decoy", "durability": 5.0, "expires_at": director.sim_time + 10.0}
		if terminal == "victory":
			director._enemy_defeated()
		elif terminal == "retreat":
			director._squad_defeated("maximum_timeout")
		else:
			director._squad_defeated("squad_defeat")
		_check(director.ability_cooldown_until.is_empty() and director.ability_effects.is_empty() and director.enemy_ability_state.is_empty() and director.echo_decoy.is_empty(), "Ability state should clear on encounter %s." % terminal)
		director.queue_free()
		await process_frame

