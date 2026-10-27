extends Node
class_name CombatDirector

signal state_changed
signal event_logged(message: String)
## Emitted once after the victory credit grant, run high-water, next-wave/cap, and intermission state are committed.
signal wave_cleared(wave_number: int, credit_reward: int, run_high_water: int, boss_id: String)
## Simulation-owned resolved attacks for presentation (weapons/effects). Listeners must not mutate combat.
signal combat_action_resolved(event: Dictionary)
signal stalemate_arrival(holding_wave: int, retry_wave: int)

const FIXED_STEP := 0.05
const PLAYER_DATA_PATH := "res://data/characters/breaker_t1.json"
const ENEMY_DATA_PATH := "res://data/enemies/undercity_grunt.json"
const WAVE_DATA_PATH := "res://data/waves/undercity_prototype.json"
const SQUAD_DATA_PATH := "res://data/squads/undercity_six_slot.json"
const RECRUIT_ROSTER_PATH := "res://data/characters/founding_recruits.json"
const COMBAT_TRIAL_PATH := "res://data/combat/hybrid_combat_trial.json"
const ABILITY_TRIAL_PATH := "res://data/combat/ability_trial.json"
const ECONOMY_SCRIPT := preload("res://scripts/progression/economy.gd")
const PROGRESSION_RULES := preload("res://scripts/progression/progression_rules.gd")
const ROSTER_STATE_SERVICE := preload("res://scripts/progression/roster_state_service.gd")
const PROGRESSION_PROFILE_PATH := "res://data/progression/progression_prototype_profile.json"

var player_def: Dictionary
var enemy_def: Dictionary
var wave_def: Dictionary
var squad_def: Dictionary
var recruit_roster: Dictionary = {}
var economy: PrototypeEconomy
var allies: Array[Dictionary] = []
## Optional trial-only target fixtures for multi-target ability simulation. Production waves still supply one enemy.
var additional_enemy_targets: Array[Dictionary] = []
var active_lineup: Array[String] = []
var pending_active_lineup: Array[String] = []
var recruit_run_states: Dictionary = {}
var accumulator := 0.0
var sim_time := 0.0
var combat_action_sequence := 0
var phase := "combat"
var phase_timer := 0.0
var wave := 1
var highest_cleared_wave := 0
var player_x := 190.0
var enemy_x := 600.0
var player_hp := 0.0
var enemy_hp := 0.0
var player_attack_elapsed := 0.0
var enemy_attack_elapsed := 0.0
var player_animation := "idle"
var enemy_animation := "idle"
var last_event := ""
var wave_limit_reached := false
var render_previous_ally_x: Array[float] = []
var render_previous_enemy_x := 600.0
var lifetime_influence := 0
var lifetime_power_bonus_fraction := 0.0
var lifetime_power_bonus_rule: Dictionary = {}
var combat_trial_def: Dictionary = {}
var ability_trial_def: Dictionary = {}
var combat_model := "direct_damage"
var ability_trial_enabled := false
var ability_trial_valid := false
var ability_cooldown_until: Dictionary = {}
var ability_effects: Dictionary = {}
var enemy_ability_state: Dictionary = {}
var echo_decoy: Dictionary = {}
var deferred_ability_attack_events: Array[Dictionary] = []
var encounter_seed_base := 2601026
var encounter_index := 0
var encounter_seed := 0
var encounter_rng: RandomNumberGenerator
var enemy_max_hp := 0.0
var encounter_elapsed := 0.0
var no_progress_elapsed := 0.0
var last_terminal_reason := ""
var last_timer_expiry_primary := ""
var last_timer_expiry_also: Array[String] = []
var stalemate_arrival_pending := false
var stalemate_arrival_shown := false
var _last_impact_payload: Dictionary = {}
var _progress_effect_seen_this_step := false
var _qualifying_progress_pending := false
var _inside_fixed_combat_step := false


func _ready() -> void:
	player_def = _read_definition(PLAYER_DATA_PATH)
	enemy_def = _read_definition(ENEMY_DATA_PATH)
	wave_def = _read_definition(WAVE_DATA_PATH)
	squad_def = _read_definition(SQUAD_DATA_PATH)
	recruit_roster = _read_definition(RECRUIT_ROSTER_PATH)
	combat_trial_def = _read_definition(COMBAT_TRIAL_PATH)
	ability_trial_def = _read_definition(ABILITY_TRIAL_PATH)
	encounter_seed_base = int(combat_trial_def.get("seed_base", encounter_seed_base))
	for argument in OS.get_cmdline_user_args():
		if argument == "--neon-hybrid-trial":
			combat_model = "hybrid_trial"
		elif argument == "--neon-ability-trial":
			ability_trial_enabled = true
		elif str(argument).begins_with("--neon-combat-seed="):
			var parsed_seed := str(argument).trim_prefix("--neon-combat-seed=").to_int()
			if parsed_seed > 0:
				encounter_seed_base = parsed_seed
	if not _validate_combat_trial_definition():
		combat_model = "direct_damage"
	ability_trial_valid = _validate_ability_trial_definition()
	if not ability_trial_valid:
		ability_trial_enabled = false
	economy = ECONOMY_SCRIPT.new()
	var progression_profile: Variant = JSON.parse_string(FileAccess.get_file_as_string(PROGRESSION_PROFILE_PATH)) if FileAccess.file_exists(PROGRESSION_PROFILE_PATH) else null
	if typeof(progression_profile) == TYPE_DICTIONARY:
		lifetime_power_bonus_rule = progression_profile.get("lifetime_influence_benefit", {})
	_build_squad()
	set_lifetime_influence(0)
	_begin_encounter()
	if combat_model == "hybrid_trial":
		_log("Hybrid combat trial enabled (trial-only values; encounter seed %d)." % encounter_seed)
	if ability_trial_enabled:
		_log("Automatic recruit ability trial enabled (owner-delegated playtest values; not canon).")




func _read_definition(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing data definition: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON object in %s" % path)
		return {}
	return parsed


func _validate_combat_trial_definition() -> bool:
	var score: Variant = combat_trial_def.get("power_score", null)
	var likelihood: Variant = combat_trial_def.get("likelihood", null)
	var impact: Variant = combat_trial_def.get("impact", null)
	var timers: Variant = combat_trial_def.get("timers", null)
	if str(combat_trial_def.get("status", "")) != "PROVISIONAL_TRIAL_VALUES_NOT_CANON" or str(combat_trial_def.get("default_model", "")) != "direct_damage":
		push_warning("Hybrid combat trial must remain provisional and default to direct damage.")
		return false
	if typeof(score) != TYPE_DICTIONARY or typeof(likelihood) != TYPE_DICTIONARY or typeof(impact) != TYPE_DICTIONARY or typeof(timers) != TYPE_DICTIONARY:
		push_warning("Hybrid combat trial profile is incomplete; direct damage remains active.")
		return false
	for key in ["current_hp_weight", "max_hp_weight", "attack_power_weight", "cadence_weight"]:
		if not _finite_nonnegative(float(score.get(key, -1.0))):
			push_warning("Hybrid combat trial power weights must be finite and non-negative; direct damage remains active.")
			return false
	if float(score.get("current_hp_weight", 0.0)) + float(score.get("max_hp_weight", 0.0)) + float(score.get("attack_power_weight", 0.0)) + float(score.get("cadence_weight", 0.0)) <= 0.0:
		push_warning("Hybrid combat trial requires at least one positive power weight; direct damage remains active.")
		return false
	for key in ["max_hp_reference", "attack_power_reference", "cadence_reference_seconds", "minimum_attack_interval"]:
		if not _finite_positive(float(score.get(key, 0.0))):
			push_warning("Hybrid combat trial power score is invalid; direct damage remains active.")
			return false
	var minimum_likelihood := float(likelihood.get("minimum_high_impact_probability", -1.0))
	var maximum_likelihood := float(likelihood.get("maximum_high_impact_probability", 2.0))
	if not is_finite(minimum_likelihood) or not is_finite(maximum_likelihood) or minimum_likelihood <= 0.0 or maximum_likelihood >= 1.0 or minimum_likelihood >= 0.5 or maximum_likelihood <= 0.5 or minimum_likelihood >= maximum_likelihood:
		push_warning("Hybrid combat trial probability bounds must straddle 0.5 and stay inside (0, 1); direct damage remains active.")
		return false
	var low_impact := float(impact.get("low_multiplier", 0.0))
	var high_impact := float(impact.get("high_multiplier", 0.0))
	if not _finite_positive(low_impact) or not _finite_positive(high_impact) or high_impact <= low_impact:
		push_warning("Hybrid combat trial impact multipliers are invalid; direct damage remains active.")
		return false
	if not _finite_positive(float(timers.get("maximum_encounter_seconds", 0.0))) or not _finite_positive(float(timers.get("no_progress_seconds", 0.0))):
		push_warning("Hybrid combat trial timer thresholds are invalid; direct damage remains active.")
		return false
	if not _is_positive_integer_number(combat_trial_def.get("seed_base", null)) or not _is_positive_integer_number(combat_trial_def.get("seed_stride", null)):
		push_warning("Hybrid combat trial seed and stride must be positive integers; direct damage remains active.")
		return false
	return true


func _validate_ability_trial_definition() -> bool:
	if str(ability_trial_def.get("status", "")) != "OWNER_DELEGATED_PLAYTEST_DEFAULTS_NOT_CANON" or bool(ability_trial_def.get("enabled_by_default", true)):
		push_warning("Recruit ability profile must remain opt-in and non-canonical.")
		return false
	var abilities: Variant = ability_trial_def.get("abilities", null)
	if typeof(abilities) != TYPE_DICTIONARY:
		push_warning("Recruit ability profile is incomplete; abilities remain disabled.")
		return false
	var recruit_ids := ["bulwark", "breaker", "cipher", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]
	for recruit_id in recruit_ids:
		var ability: Variant = abilities.get(recruit_id, null)
		if typeof(ability) != TYPE_DICTIONARY or str(ability.get("ability_id", "")).is_empty() or not _finite_positive(float(ability.get("cooldown_seconds", 0.0))):
			push_warning("Recruit ability profile lacks a valid entry for %s; abilities remain disabled." % recruit_id)
			return false
	var positive_fields := {
		"bulwark": ["heal_amount"],
		"breaker": ["attack_multiplier", "strain_interval_add_seconds", "strain_duration_seconds"],
		"cipher": ["precision_multiplier"],
		"spark": ["drone_damage_multiplier"],
		"specter": ["strike_multiplier", "cloak_duration_seconds"],
		"ironclad": ["anchor_duration_seconds", "suppression_duration_seconds", "suppression_attack_multiplier"],
		"stitch": ["heal_amount", "team_attack_multiplier", "team_boost_duration_seconds", "self_interval_add_seconds", "instability_duration_seconds"],
		"recoil": ["strike_multiplier"],
		"echo": ["decoy_durability", "decoy_duration_seconds"],
		"vector": ["strike_multiplier"],
		"glitch": ["burst_duration_seconds"]
	}
	for profile_recruit_id in positive_fields:
		var profile_ability: Dictionary = abilities[profile_recruit_id]
		for field in positive_fields[profile_recruit_id]:
			if not _finite_positive(float(profile_ability.get(field, 0.0))):
				push_warning("Recruit ability profile has an invalid %s value for %s; abilities remain disabled." % [field, profile_recruit_id])
				return false
	for threshold_entry in [{"id": "bulwark", "field": "emergency_hp_ratio"}, {"id": "stitch", "field": "heal_threshold_ratio"}]:
		var ratio := float(abilities[threshold_entry["id"]].get(threshold_entry["field"], -1.0))
		if not is_finite(ratio) or ratio < 0.0 or ratio > 1.0:
			push_warning("Recruit ability profile has an invalid healing threshold; abilities remain disabled.")
			return false
	for count_entry in [{"id": "spark", "field": "drone_attack_count"}, {"id": "recoil", "field": "target_limit"}, {"id": "vector", "field": "target_limit"}]:
		if not _is_positive_integer_number(abilities[count_entry["id"]].get(count_entry["field"], null)):
			push_warning("Recruit ability profile has an invalid action count; abilities remain disabled.")
			return false
	var enemy_capabilities: Variant = ability_trial_def.get("enemy_trial_capabilities", null)
	if typeof(enemy_capabilities) != TYPE_DICTIONARY:
		push_warning("Recruit ability profile lacks enemy trial capabilities; abilities remain disabled.")
		return false
	for enemy_id in enemy_capabilities:
		var capability: Variant = enemy_capabilities[enemy_id]
		if typeof(capability) != TYPE_DICTIONARY:
			push_warning("Recruit ability profile has invalid enemy capability data; abilities remain disabled.")
			return false
		for modifier_field in ["cyberware_attack_multiplier", "implant_attack_multiplier"]:
			if capability.has(modifier_field) and not _finite_positive(float(capability[modifier_field])):
				push_warning("Recruit ability profile has an invalid enemy modifier; abilities remain disabled.")
				return false
		if capability.has("implant_strength") and not _finite_nonnegative(float(capability["implant_strength"])):
			push_warning("Recruit ability profile has an invalid implant strength; abilities remain disabled.")
			return false
		for capability_flag in ["functional_cyberware", "functional_implants"]:
			if capability.has(capability_flag) and typeof(capability[capability_flag]) != TYPE_BOOL:
				push_warning("Recruit ability profile has an invalid capability flag; abilities remain disabled.")
				return false
	return true


func configure_ability_trial(enabled: bool) -> bool:
	if enabled and not ability_trial_valid:
		return false
	if ability_trial_enabled == enabled:
		return true
	ability_trial_enabled = enabled
	_clear_ability_encounter_state()
	if is_inside_tree() and phase == "combat":
		_log("Automatic recruit ability trial %s." % ("enabled" if enabled else "disabled"))
		state_changed.emit()
	return true


func _finite_positive(value: float) -> bool:
	return is_finite(value) and value > 0.0


func _finite_nonnegative(value: float) -> bool:
	return is_finite(value) and value >= 0.0


func _is_positive_integer_number(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var numeric_value := float(value)
	return is_finite(numeric_value) and numeric_value >= 1.0 and floorf(numeric_value) == numeric_value


func configure_combat_model(model: String, seed_base: int = -1) -> bool:
	if model not in ["direct_damage", "hybrid_trial"]:
		return false
	if model == "hybrid_trial" and not _validate_combat_trial_definition():
		return false
	combat_model = model
	if seed_base > 0:
		encounter_seed_base = seed_base
		encounter_index = 0
	if is_inside_tree() and not allies.is_empty():
		_begin_encounter()
	return true


func notify_qualifying_progress_effect() -> void:
	if combat_model == "hybrid_trial" and phase == "combat":
		if _inside_fixed_combat_step:
			_progress_effect_seen_this_step = true
		else:
			_qualifying_progress_pending = true


func _physics_process(delta: float) -> void:
	accumulator += minf(delta, 0.25)
	while accumulator >= FIXED_STEP:
		accumulator -= FIXED_STEP
		_step(FIXED_STEP)


func _step(dt: float) -> void:
	_capture_presentation_origin()
	sim_time += dt
	if phase == "intermission":
		phase_timer -= dt
		if phase_timer <= 0.0:
			if wave_limit_reached:
				phase = "prototype_complete"
				player_animation = "idle"
				enemy_animation = "defeated"
				_log("Prototype progression fixture complete at wave %d." % int(wave_def.get("last_wave", 125)))
			else:
				_begin_encounter()
		_store_recruit_hp()
		state_changed.emit()
		return
	if phase == "retreat":
		phase_timer -= dt
		if phase_timer <= 0.0:
			var show_stalemate_arrival := stalemate_arrival_pending and not stalemate_arrival_shown
			stalemate_arrival_pending = false
			_begin_encounter(true)
			if show_stalemate_arrival and phase == "combat":
				stalemate_arrival_shown = true
				stalemate_arrival.emit(wave, highest_cleared_wave + 1)
				_log("One-time stalemate arrival cue: holding wave %d; next uncleared wave %d will retry after its clear." % [wave, highest_cleared_wave + 1])
		_store_recruit_hp()
		state_changed.emit()
		return
	if phase != "combat":
		return
	_advance_ability_effects()
	if combat_model == "hybrid_trial":
		encounter_elapsed += dt
	_progress_effect_seen_this_step = _qualifying_progress_pending
	_qualifying_progress_pending = false
	_inside_fixed_combat_step = true
	var hp_before_step := _encounter_hp_values()
	if _simulate_allies(dt):
		_inside_fixed_combat_step = false
		_sync_breaker_fields()
		_store_recruit_hp()
		state_changed.emit()
		return
	_simulate_enemy(dt)
	_inside_fixed_combat_step = false
	if phase == "combat" and combat_model == "hybrid_trial":
		if _progress_effect_seen_this_step or _encounter_hp_changed(hp_before_step):
			no_progress_elapsed = 0.0
		else:
			no_progress_elapsed += dt
		# All fixed-step actions resolve before either terminal timer is checked.
		_resolve_combat_timers()
	_sync_breaker_fields()
	_store_recruit_hp()
	state_changed.emit()


func _encounter_hp_values() -> Array[float]:
	var values: Array[float] = [enemy_hp]
	for target in additional_enemy_targets:
		values.append(float(target.get("hp", 0.0)))
	for ally in allies:
		values.append(float(ally.get("hp", 0.0)))
	return values


func _encounter_hp_changed(before: Array[float]) -> bool:
	var after := _encounter_hp_values()
	if before.size() != after.size():
		return true
	for index in range(after.size()):
		if absf(after[index] - before[index]) > 0.000001:
			return true
	return false


func _clear_ability_encounter_state() -> void:
	ability_cooldown_until.clear()
	ability_effects.clear()
	enemy_ability_state.clear()
	echo_decoy.clear()
	deferred_ability_attack_events.clear()


func _advance_ability_effects() -> void:
	if not ability_trial_enabled:
		return
	for recruit_id in ability_effects.keys():
		var effects: Dictionary = ability_effects[recruit_id]
		for effect_id in effects.keys():
			var effect: Dictionary = effects[effect_id]
			if float(effect.get("expires_at", INF)) <= sim_time:
				effects.erase(effect_id)
		ability_effects[recruit_id] = effects
	if not echo_decoy.is_empty() and float(echo_decoy.get("expires_at", INF)) <= sim_time:
		_remove_echo_decoy("decoy_expired")


func _set_timed_ability_effect(owner_id: String, effect_id: String, duration_seconds: float, value: Variant = true) -> void:
	if duration_seconds <= 0.0:
		return
	var effects: Dictionary = ability_effects.get(owner_id, {})
	effects[effect_id] = {"expires_at": sim_time + duration_seconds, "value": value}
	ability_effects[owner_id] = effects


func _active_ability_effect(owner_id: String, effect_id: String, fallback: Variant = null) -> Variant:
	var effects: Variant = ability_effects.get(owner_id, {})
	if typeof(effects) != TYPE_DICTIONARY:
		return fallback
	var effect: Variant = effects.get(effect_id, null)
	if typeof(effect) != TYPE_DICTIONARY or float(effect.get("expires_at", -1.0)) <= sim_time:
		return fallback
	return effect.get("value", fallback)


func _resolve_combat_timers() -> void:
	if phase != "combat":
		return
	var timers: Dictionary = combat_trial_def.get("timers", {})
	var maximum_expired := encounter_elapsed >= float(timers.get("maximum_encounter_seconds", INF))
	var no_progress_expired := no_progress_elapsed >= float(timers.get("no_progress_seconds", INF))
	if not maximum_expired and not no_progress_expired:
		return
	last_timer_expiry_primary = "maximum_timeout" if maximum_expired else "no_progress"
	last_timer_expiry_also.clear()
	if maximum_expired and no_progress_expired:
		last_timer_expiry_also.append("no_progress")
		_log("Hybrid trial timer expiry: maximum timeout is primary; no-progress also expired.")
	else:
		_log("Hybrid trial timer expiry: %s resolves as defeat." % last_timer_expiry_primary)
	_squad_defeated(last_timer_expiry_primary)


func _simulate_allies(dt: float) -> bool:
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		if float(ally["hp"]) <= 0.0:
			continue
		var recruit_id := str(ally.get("id", ""))
		var frame_skip_active := bool(_active_ability_effect(recruit_id, "frame_skip", false))
		var frame_skip_target := str(_active_ability_effect(recruit_id, "frame_skip_last_target", ""))
		var target_id := _select_ally_target_id(recruit_id, frame_skip_target if frame_skip_active else "")
		if not target_id.is_empty():
			var target_state := _enemy_target_snapshot(target_id)
			var target_x := float(target_state.get("x", enemy_x))
			var distance := target_x - float(ally["x"])
			var approach_distance := float(ally["engagement_distance"])
			if distance > approach_distance:
				if bool(_active_ability_effect(recruit_id, "anchored", false)):
					ally["animation"] = "idle"
				else:
					ally["animation"] = "walk"
					ally["x"] = float(ally["x"]) + minf(float(ally["move_speed"]) * dt, distance - approach_distance)
			else:
				ally["animation"] = "idle"
		else:
			ally["animation"] = "idle"
		# Preserve normal cadence except for the three profile-defined global support actions.
		var in_range := false
		if not target_id.is_empty():
			in_range = float(_enemy_target_snapshot(target_id).get("x", enemy_x)) - float(ally.get("x", 0.0)) <= float(ally.get("engagement_distance", 0.0))
		var squad_support_boundary := ability_trial_enabled and recruit_id in ["bulwark", "stitch", "echo"]
		if in_range or squad_support_boundary:
			ally["attack_elapsed"] = float(ally.get("attack_elapsed", 0.0)) + dt
		var action_ready := (in_range or squad_support_boundary) and float(ally["attack_elapsed"]) >= _effective_ally_attack_interval(ally)
		allies[index] = ally
		if not action_ready:
			continue
		var glitch_ready := ability_trial_enabled and recruit_id == "glitch" and _ability_is_ready(recruit_id) and _living_enemy_ids().size() >= 2
		if _try_resolve_ability(index, _select_ally_target_id(recruit_id)):
			allies[index]["attack_elapsed"] = 0.0
			if _living_enemy_ids().is_empty():
				_enemy_defeated()
				return true
			continue
		if not in_range:
			# A global support skill with no eligible recipient/target remains ready;
			# it does not consume the actor's action boundary.
			continue
		allies[index]["attack_elapsed"] = 0.0
		target_id = _select_ally_target_id(recruit_id, frame_skip_target if frame_skip_active else "")
		if not target_id.is_empty() and _resolve_ally_attack(index, target_id, float(allies[index].get("attack_power", 0.0))):
			if glitch_ready and not _living_enemy_ids().is_empty():
				_start_frame_skip(index, target_id)
			elif frame_skip_active:
				_set_frame_skip_progress(recruit_id, target_id, 0)
			if _living_enemy_ids().is_empty():
				_enemy_defeated()
				return true
	return false


func _simulate_enemy(dt: float) -> void:
	var target_ids := _living_enemy_ids()
	for enemy_id in target_ids:
		var enemy := _enemy_target_snapshot(enemy_id)
		var target_index := _select_enemy_target_for_x(float(enemy.get("x", enemy_x)))
		if target_index < 0:
			if not echo_decoy.is_empty():
				target_index = -2
			else:
				_squad_defeated()
				return
		if not echo_decoy.is_empty():
			_set_enemy_attack_elapsed(enemy_id, _enemy_attack_elapsed_for(enemy_id) + dt)
			if _enemy_attack_elapsed_for(enemy_id) >= float(enemy_def.get("attack_interval", 1.05)):
				_set_enemy_attack_elapsed(enemy_id, 0.0)
				var decoy_damage := _enemy_attack_power_for(enemy_id) * _enemy_attack_multiplier(enemy_id)
				decoy_damage = _committed_attack_damage(decoy_damage, "enemy")
				echo_decoy["durability"] = maxf(0.0, float(echo_decoy.get("durability", 0.0)) - decoy_damage)
				var decoy_event := _last_impact_payload.duplicate(true)
				decoy_event["target_kind"] = "abstract_decoy"
				decoy_event["target_defeated"] = false
				_emit_combat_action(enemy_id, "enemy", str(echo_decoy.get("token_id", "echo_decoy")), "melee", decoy_damage, float(echo_decoy["durability"]), decoy_event)
				if float(echo_decoy["durability"]) <= 0.0:
					_remove_echo_decoy("decoy_destroyed")
			continue
		var target: Dictionary = allies[target_index]
		var distance := float(enemy.get("x", enemy_x)) - float(target["x"])
		var enemy_range := float(enemy_def.get("attack_range", 46.0))
		var desired_engagement := float(enemy_def.get("melee_contact_distance", 4.0)) if str(enemy_def.get("combat_style", "melee")) == "melee" else float(enemy_def.get("engagement_distance", enemy_range))
		var engagement_distance := minf(maxf(0.0, desired_engagement), enemy_range)
		if distance > engagement_distance:
			_set_enemy_target_property(enemy_id, "animation", "walk")
			_set_enemy_target_property(enemy_id, "x", float(enemy.get("x", enemy_x)) - minf(float(enemy_def.get("move_speed", 25.0)) * dt, distance - engagement_distance))
		else:
			_set_enemy_target_property(enemy_id, "animation", "idle")
			_set_enemy_attack_elapsed(enemy_id, _enemy_attack_elapsed_for(enemy_id) + dt)
			if _enemy_attack_elapsed_for(enemy_id) >= float(enemy_def.get("attack_interval", 1.05)):
				_set_enemy_attack_elapsed(enemy_id, 0.0)
				_set_enemy_target_property(enemy_id, "animation", "punch")
				var attack_damage := _enemy_attack_power_for(enemy_id) * _enemy_attack_multiplier(enemy_id)
				attack_damage = _committed_attack_damage(attack_damage, "enemy")
				target["hp"] = maxf(0.0, float(target["hp"]) - attack_damage)
				target["animation"] = "hit" if float(target["hp"]) > 0.0 else "defeated"
				allies[target_index] = target
				_emit_combat_action(enemy_id, "enemy", str(target["id"]), str(enemy_def.get("combat_style", "melee")), attack_damage, float(target["hp"]), _last_impact_payload)
				_log("Enemy hits %s for %.0f. HP %.0f." % [target["display_name"], attack_damage, float(target["hp"])] )
				if _living_ally_count() == 0:
					_squad_defeated()
					return


func _select_enemy_target() -> int:
	return _select_enemy_target_for_x(enemy_x)


func _select_enemy_target_for_x(target_x: float) -> int:
	var target_index := -1
	var nearest_distance := INF
	var has_uncloaked_ally := false
	for ally in allies:
		if float(ally.get("hp", 0.0)) > 0.0 and not bool(_active_ability_effect(str(ally.get("id", "")), "cloaked", false)):
			has_uncloaked_ally = true
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		if float(ally["hp"]) <= 0.0:
			continue
		if has_uncloaked_ally and bool(_active_ability_effect(str(ally.get("id", "")), "cloaked", false)):
			continue
		var distance := absf(target_x - float(ally["x"]))
		if distance < nearest_distance:
			nearest_distance = distance
			target_index = index
	return target_index


func _living_enemy_ids() -> Array[String]:
	var ids: Array[String] = []
	if enemy_hp > 0.0:
		ids.append(str(enemy_def.get("id", "undercity_grunt")))
	for target in additional_enemy_targets:
		if float(target.get("hp", 0.0)) > 0.0:
			ids.append(str(target.get("id", "")))
	return ids


func _enemy_target_snapshot(target_id: String) -> Dictionary:
	if target_id == str(enemy_def.get("id", "undercity_grunt")):
		return {"id": target_id, "hp": enemy_hp, "max_hp": enemy_max_hp, "x": enemy_x, "attack_elapsed": enemy_attack_elapsed}
	for target in additional_enemy_targets:
		if str(target.get("id", "")) == target_id:
			return target.duplicate(true)
	return {}


func _set_enemy_target_property(target_id: String, property_name: String, value: Variant) -> void:
	if target_id == str(enemy_def.get("id", "undercity_grunt")):
		match property_name:
			"hp":
				enemy_hp = float(value)
				if enemy_hp <= 0.0:
					enemy_ability_state.erase(target_id)
			"x": enemy_x = float(value)
			"attack_elapsed": enemy_attack_elapsed = float(value)
			"animation": enemy_animation = str(value)
		return
	for index in range(additional_enemy_targets.size()):
		if str(additional_enemy_targets[index].get("id", "")) == target_id:
			additional_enemy_targets[index][property_name] = value
			if property_name == "hp" and float(value) <= 0.0:
				enemy_ability_state.erase(target_id)
			return


func _enemy_attack_elapsed_for(target_id: String) -> float:
	return float(_enemy_target_snapshot(target_id).get("attack_elapsed", enemy_attack_elapsed))


func _set_enemy_attack_elapsed(target_id: String, value: float) -> void:
	_set_enemy_target_property(target_id, "attack_elapsed", value)


func _enemy_attack_power_for(target_id: String) -> float:
	var target := _enemy_target_snapshot(target_id)
	var base_power := float(target.get("attack_power", _enemy_attack_power()))
	if not ability_trial_enabled:
		return base_power
	var capabilities := _enemy_capabilities(target_id)
	var state: Dictionary = enemy_ability_state.get(target_id, {})
	if bool(capabilities.get("functional_cyberware", false)) and not bool(state.get("cyberware_disabled", false)):
		base_power *= float(capabilities.get("cyberware_attack_multiplier", 1.0))
	if bool(capabilities.get("functional_implants", false)) and not bool(state.get("implants_disabled", false)):
		base_power *= float(capabilities.get("implant_attack_multiplier", 1.0))
	return base_power


func _enemy_capabilities(target_id: String) -> Dictionary:
	var capability_map: Dictionary = ability_trial_def.get("enemy_trial_capabilities", {})
	var configured: Variant = capability_map.get(target_id, null)
	if typeof(configured) == TYPE_DICTIONARY:
		return configured
	var target := _enemy_target_snapshot(target_id)
	var local_capabilities: Variant = target.get("capabilities", {})
	return local_capabilities if typeof(local_capabilities) == TYPE_DICTIONARY else {}


func _enemy_attack_multiplier(target_id: String) -> float:
	var state: Dictionary = enemy_ability_state.get(target_id, {})
	var multiplier := float(state.get("suppression_multiplier", 1.0)) if sim_time < float(state.get("suppressed_until", -1.0)) else 1.0
	return multiplier


func _select_ally_target_id(recruit_id: String, avoid_id: String = "", require_attack_range: bool = false) -> String:
	var living := _living_enemy_ids()
	if living.is_empty():
		return ""
	var actor_index := _find_ally_index(recruit_id)
	var actor_x := float(allies[actor_index].get("x", 0.0)) if actor_index >= 0 else 0.0
	var selected := ""
	var nearest := INF
	for target_id in living:
		if target_id == avoid_id and living.size() > 1:
			continue
		var target := _enemy_target_snapshot(target_id)
		var forward_distance := float(target.get("x", enemy_x)) - actor_x
		if require_attack_range and (actor_index < 0 or forward_distance > float(allies[actor_index].get("engagement_distance", 0.0))):
			continue
		var distance := absf(forward_distance)
		if distance < nearest or (is_equal_approx(distance, nearest) and (selected.is_empty() or target_id < selected)):
			nearest = distance
			selected = target_id
	return selected


func set_trial_enemy_fixture(targets: Array[Dictionary]) -> bool:
	if not ability_trial_enabled or not ability_trial_valid or combat_action_sequence > 0 or targets.size() > 5:
		return false
	var validated: Array[Dictionary] = []
	var seen := {str(enemy_def.get("id", "undercity_grunt")): true}
	for target in targets:
		var target_id := str(target.get("id", "")).strip_edges()
		var hp := float(target.get("hp", 0.0))
		var target_x := float(target.get("x", 0.0))
		if target_id.is_empty() or seen.has(target_id) or not _finite_positive(hp) or not is_finite(target_x):
			return false
		seen[target_id] = true
		var entry := target.duplicate(true)
		if entry.has("capabilities") and typeof(entry["capabilities"]) != TYPE_DICTIONARY:
			return false
		entry["hp"] = hp
		var max_hp := float(target.get("max_hp", hp))
		if not _finite_positive(max_hp) or max_hp < hp:
			return false
		if target.has("attack_power") and (not is_finite(float(target["attack_power"])) or float(target["attack_power"]) < 0.0):
			return false
		if target.has("attack_interval") and not _finite_positive(float(target["attack_interval"])):
			return false
		entry["max_hp"] = max_hp
		entry["attack_elapsed"] = 0.0
		entry["animation"] = "idle"
		validated.append(entry)
	additional_enemy_targets = validated
	return true


func _ability_is_ready(recruit_id: String) -> bool:
	return ability_trial_enabled and ability_trial_valid and sim_time >= float(ability_cooldown_until.get(recruit_id, 0.0))


func _commit_ability_cooldown(recruit_id: String, ability: Dictionary) -> void:
	ability_cooldown_until[recruit_id] = sim_time + float(ability.get("cooldown_seconds", 0.0))


func _try_resolve_ability(ally_index: int, fallback_target_id: String) -> bool:
	if not ability_trial_enabled or ally_index < 0 or ally_index >= allies.size():
		return false
	var recruit_id := str(allies[ally_index].get("id", ""))
	if not _ability_is_ready(recruit_id):
		return false
	var abilities: Dictionary = ability_trial_def.get("abilities", {})
	var ability: Dictionary = abilities.get(recruit_id, {})
	var ability_id := str(ability.get("ability_id", ""))
	var target_id := fallback_target_id
	var committed := false
	match recruit_id:
		"bulwark":
			var heal_amount := float(ability.get("heal_amount", 0.0))
			var threshold := float(ability.get("emergency_hp_ratio", 0.0))
			var healed_ids: Array[String] = []
			var healed_amounts: Dictionary = {}
			for index in range(allies.size()):
				var ally: Dictionary = allies[index]
				if float(ally.get("hp", 0.0)) <= 0.0 or float(ally.get("max_hp", 0.0)) <= 0.0 or float(ally["hp"]) / float(ally["max_hp"]) > threshold:
					continue
				var ally_hp_before := float(ally["hp"])
				var bulwark_healed := minf(float(ally["max_hp"]), ally_hp_before + heal_amount)
				if bulwark_healed > ally_hp_before:
					ally["hp"] = bulwark_healed
					allies[index] = ally
					var healed_recruit_id := str(ally.get("id", ""))
					healed_ids.append(healed_recruit_id)
					healed_amounts[healed_recruit_id] = bulwark_healed - ally_hp_before
			if not healed_ids.is_empty():
				notify_qualifying_progress_effect()
				_commit_ability_cooldown(recruit_id, ability)
				_emit_ability_resolved(recruit_id, "ally", ability_id, "", "team_emergency_heal", {"affected_recruits": healed_ids, "heal_amounts": healed_amounts})
				committed = true
		"breaker":
			if not target_id.is_empty():
				var redline_damage := float(allies[ally_index].get("attack_power", 0.0)) * float(ability.get("attack_multiplier", 1.0))
				if _resolve_ally_attack(ally_index, target_id, redline_damage, ability_id):
					_set_timed_ability_effect(recruit_id, "attack_interval_add", float(ability.get("strain_duration_seconds", 0.0)), float(ability.get("strain_interval_add_seconds", 0.0)))
					_commit_ability_cooldown(recruit_id, ability)
					_flush_deferred_ability_attack_events()
					_emit_ability_resolved(recruit_id, "ally", ability_id, target_id, "redline_punch")
					committed = true
		"cipher":
			var cyberware_target := _select_enemy_with_capability("functional_cyberware", "", false, ally_index)
			if cyberware_target.is_empty():
				cyberware_target = target_id
			if not cyberware_target.is_empty():
				var cipher_damage := float(allies[ally_index].get("attack_power", 0.0)) * float(ability.get("precision_multiplier", 1.0))
				if _resolve_ally_attack(ally_index, cyberware_target, cipher_damage, ability_id, str(ability.get("attack_style", "precision"))):
					var target_capabilities := _enemy_capabilities(cyberware_target)
					var target_state: Dictionary = enemy_ability_state.get(cyberware_target, {})
					var cipher_effect := "ordinary_precision_fallback"
					if bool(target_capabilities.get("functional_cyberware", false)) and _living_enemy_ids().has(cyberware_target):
						target_state["cyberware_disabled"] = true
						enemy_ability_state[cyberware_target] = target_state
						notify_qualifying_progress_effect()
						cipher_effect = "precision_and_cyberware_disable"
					elif bool(target_capabilities.get("functional_cyberware", false)):
						cipher_effect = "precision_target_defeated"
					_commit_ability_cooldown(recruit_id, ability)
					_flush_deferred_ability_attack_events()
					_emit_ability_resolved(recruit_id, "ally", ability_id, cyberware_target, cipher_effect)
					committed = true
		"spark":
			var hit_ids: Array[String] = []
			for hit_index in range(int(ability.get("drone_attack_count", 0))):
				var next_target := _select_ally_target_id(recruit_id, "", true)
				if next_target.is_empty():
					break
				var spark_damage := float(allies[ally_index].get("attack_power", 0.0)) * float(ability.get("drone_damage_multiplier", 1.0))
				if _resolve_ally_attack(ally_index, next_target, spark_damage, ability_id, "drone"):
					hit_ids.append(next_target)
			if not hit_ids.is_empty():
				_commit_ability_cooldown(recruit_id, ability)
				_flush_deferred_ability_attack_events()
				_emit_ability_resolved(recruit_id, "ally", ability_id, hit_ids[0], "sequential_drone_attacks", {"target_ids": hit_ids})
				committed = true
		"specter":
			var power_target := _select_highest_power_enemy(ally_index)
			if not power_target.is_empty():
				var specter_damage := float(allies[ally_index].get("attack_power", 0.0)) * float(ability.get("strike_multiplier", 1.0))
				if _resolve_ally_attack(ally_index, power_target, specter_damage, ability_id):
					_set_timed_ability_effect(recruit_id, "cloaked", float(ability.get("cloak_duration_seconds", 0.0)))
					_commit_ability_cooldown(recruit_id, ability)
					_flush_deferred_ability_attack_events()
					_emit_ability_resolved(recruit_id, "ally", ability_id, power_target, "strike_then_cloak")
					committed = true
		"ironclad":
			if not target_id.is_empty():
				_set_timed_ability_effect(recruit_id, "anchored", float(ability.get("anchor_duration_seconds", 0.0)))
				var ironclad_state: Dictionary = enemy_ability_state.get(target_id, {})
				ironclad_state["suppression_multiplier"] = float(ability.get("suppression_attack_multiplier", 1.0))
				ironclad_state["suppressed_until"] = sim_time + float(ability.get("suppression_duration_seconds", 0.0))
				enemy_ability_state[target_id] = ironclad_state
				notify_qualifying_progress_effect()
				_commit_ability_cooldown(recruit_id, ability)
				_emit_ability_resolved(recruit_id, "ally", ability_id, target_id, "anchor_and_suppress", {"anchor_duration_seconds": float(ability.get("anchor_duration_seconds", 0.0)), "suppression_duration_seconds": float(ability.get("suppression_duration_seconds", 0.0)), "suppression_attack_multiplier": float(ability.get("suppression_attack_multiplier", 1.0))})
				committed = true
		"stitch":
			var patient_index := _lowest_ratio_ally_below(float(ability.get("heal_threshold_ratio", 0.0)))
			if patient_index >= 0:
				var patient: Dictionary = allies[patient_index]
				var hp_before := float(patient["hp"])
				var stitch_healed := minf(float(patient["max_hp"]), hp_before + float(ability.get("heal_amount", 0.0)))
				if stitch_healed > float(patient["hp"]):
					patient["hp"] = stitch_healed
					allies[patient_index] = patient
					for ally in allies:
						if float(ally.get("hp", 0.0)) > 0.0:
							_set_timed_ability_effect(str(ally.get("id", "")), "team_attack_multiplier", float(ability.get("team_boost_duration_seconds", 0.0)), float(ability.get("team_attack_multiplier", 1.0)))
					_set_timed_ability_effect(recruit_id, "attack_interval_add", float(ability.get("instability_duration_seconds", 0.0)), float(ability.get("self_interval_add_seconds", 0.0)))
					notify_qualifying_progress_effect()
					_commit_ability_cooldown(recruit_id, ability)
					_emit_ability_resolved(recruit_id, "ally", ability_id, str(patient.get("id", "")), "heal_and_team_boost", {"heal_amount": stitch_healed - hp_before})
					committed = true
		"recoil", "vector":
			var target_ids := _targets_nearest_first(recruit_id, int(ability.get("target_limit", 1)), true)
			var resolved: Array[String] = []
			for strike_target in target_ids:
				var area_damage := float(allies[ally_index].get("attack_power", 0.0)) * float(ability.get("strike_multiplier", 1.0))
				if _resolve_ally_attack(ally_index, strike_target, area_damage, ability_id):
					resolved.append(strike_target)
			if not resolved.is_empty():
				_commit_ability_cooldown(recruit_id, ability)
				_flush_deferred_ability_attack_events()
				_emit_ability_resolved(recruit_id, "ally", ability_id, resolved[0], "ordered_multi_target_strikes", {"target_ids": resolved})
				committed = true
		"echo":
			if _living_ally_count() > 0 and not _living_enemy_ids().is_empty():
				echo_decoy = {"token_id": "echo_decoy", "durability": float(ability.get("decoy_durability", 0.0)), "expires_at": sim_time + float(ability.get("decoy_duration_seconds", 0.0))}
				notify_qualifying_progress_effect()
				_commit_ability_cooldown(recruit_id, ability)
				_emit_ability_resolved(recruit_id, "ally", ability_id, "", "abstract_enemy_lure", {"physical_actor": false})
				committed = true
		"deadlock":
			var implant_target := _select_enemy_with_capability("functional_implants", "implant_strength", true, ally_index)
			if not implant_target.is_empty():
				var deadlock_state: Dictionary = enemy_ability_state.get(implant_target, {})
				deadlock_state["implants_disabled"] = true
				enemy_ability_state[implant_target] = deadlock_state
				notify_qualifying_progress_effect()
				_commit_ability_cooldown(recruit_id, ability)
				_emit_ability_resolved(recruit_id, "ally", ability_id, implant_target, "disable_implant_modifiers")
				committed = true
		"glitch":
			# The current ordinary attack resolves first. Frame Skip is committed by
			# _start_frame_skip only after that hit succeeds.
			return false
	return committed


func _resolve_ally_attack(ally_index: int, target_id: String, base_damage: float, ability_id: String = "", attack_style: String = "") -> bool:
	if ally_index < 0 or ally_index >= allies.size() or target_id.is_empty() or not _living_enemy_ids().has(target_id):
		return false
	var recruit_id := str(allies[ally_index].get("id", ""))
	var multiplier := float(_active_ability_effect(recruit_id, "team_attack_multiplier", 1.0))
	var damage := _committed_attack_damage(base_damage * multiplier, "ally")
	var target := _enemy_target_snapshot(target_id)
	var hp_after := maxf(0.0, float(target.get("hp", 0.0)) - damage)
	_set_enemy_target_property(target_id, "hp", hp_after)
	if target_id == str(enemy_def.get("id", "undercity_grunt")):
		enemy_animation = "hit" if hp_after > 0.0 else "defeated"
	else:
		_set_enemy_target_property(target_id, "animation", "hit" if hp_after > 0.0 else "defeated")
	allies[ally_index]["animation"] = "punch"
	var event_payload := _last_impact_payload.duplicate(true)
	if not ability_id.is_empty():
		event_payload["ability_id"] = ability_id
	if ability_id == "redline":
		event_payload["redline_multiplier"] = float(ability_trial_def.get("abilities", {}).get("breaker", {}).get("attack_multiplier", 1.0))
	var style := attack_style if not attack_style.is_empty() else str(allies[ally_index].get("combat_style", "melee"))
	if ability_id.is_empty():
		_emit_combat_action(recruit_id, "ally", target_id, style, damage, hp_after, event_payload)
	else:
		var event := {
			"source_id": recruit_id,
			"target_id": target_id,
			"attack_style": style,
			"damage": damage,
			"target_hp_after": hp_after,
			"extra_payload": event_payload.duplicate(true)
		}
		deferred_ability_attack_events.append(event)
	notify_qualifying_progress_effect()
	_log("%s hits %s for %.0f. HP %.0f." % [str(allies[ally_index].get("display_name", recruit_id)), str(target.get("display_name", target_id)), damage, hp_after])
	return true


func _flush_deferred_ability_attack_events() -> void:
	for event in deferred_ability_attack_events:
		_emit_combat_action(
			str(event.get("source_id", "")),
			"ally",
			str(event.get("target_id", "")),
			str(event.get("attack_style", "")),
			float(event.get("damage", 0.0)),
			float(event.get("target_hp_after", 0.0)),
		event.get("extra_payload", {})
		)
	deferred_ability_attack_events.clear()


func _effective_ally_attack_interval(ally: Dictionary) -> float:
	var recruit_id := str(ally.get("id", ""))
	var interval_add := float(_active_ability_effect(recruit_id, "attack_interval_add", 0.0))
	return maxf(0.1, float(ally.get("attack_interval", 1.0)) + interval_add)


func _lowest_ratio_ally_below(threshold: float) -> int:
	var selected := -1
	var lowest := INF
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		if float(ally.get("hp", 0.0)) <= 0.0 or float(ally.get("max_hp", 0.0)) <= 0.0:
			continue
		var ratio := float(ally["hp"]) / float(ally["max_hp"])
		if ratio <= threshold and ratio < lowest:
			selected = index
			lowest = ratio
	return selected


func _targets_nearest_first(recruit_id: String, limit: int, require_attack_range: bool = false) -> Array[String]:
	var result: Array[String] = []
	var actor_index := _find_ally_index(recruit_id)
	var actor_x := float(allies[actor_index].get("x", 0.0)) if actor_index >= 0 else 0.0
	var candidates := _living_enemy_ids()
	if require_attack_range:
		var legal_candidates: Array[String] = []
		for candidate_id in candidates:
			var forward_distance := float(_enemy_target_snapshot(candidate_id).get("x", enemy_x)) - actor_x
			if actor_index >= 0 and forward_distance <= float(allies[actor_index].get("engagement_distance", 0.0)):
				legal_candidates.append(candidate_id)
		candidates = legal_candidates
	candidates.sort_custom(func(a: String, b: String) -> bool:
		var distance_a := absf(float(_enemy_target_snapshot(a).get("x", enemy_x)) - actor_x)
		var distance_b := absf(float(_enemy_target_snapshot(b).get("x", enemy_x)) - actor_x)
		if is_equal_approx(distance_a, distance_b):
			return a < b
		return distance_a < distance_b
	)
	for target_id in candidates.slice(0, mini(maxi(0, limit), candidates.size())):
		result.append(str(target_id))
	return result


func _select_highest_power_enemy(ally_index: int) -> String:
	var selected := ""
	var selected_power := -INF
	for target_id in _living_enemy_ids():
		var target := _enemy_target_snapshot(target_id)
		if ally_index < 0 or float(target.get("x", enemy_x)) - float(allies[ally_index].get("x", 0.0)) > float(allies[ally_index].get("engagement_distance", 0.0)):
			continue
		var power := _actor_power(
			float(target.get("hp", 0.0)),
			float(target.get("max_hp", enemy_max_hp)),
			_enemy_attack_power_for(target_id) * _enemy_attack_multiplier(target_id),
			float(target.get("attack_interval", enemy_def.get("attack_interval", 1.05)))
		)
		if power > selected_power or (is_equal_approx(power, selected_power) and (selected.is_empty() or target_id < selected)):
			selected_power = power
			selected = target_id
	return selected


func _select_enemy_with_capability(capability_key: String, ranking_key: String, rank_by_strength: bool, ally_index: int) -> String:
	var selected := ""
	var selected_rank := -INF
	for target_id in _living_enemy_ids():
		var target := _enemy_target_snapshot(target_id)
		if ally_index < 0 or float(target.get("x", enemy_x)) - float(allies[ally_index].get("x", 0.0)) > float(allies[ally_index].get("engagement_distance", 0.0)):
			continue
		var capabilities := _enemy_capabilities(target_id)
		if not bool(capabilities.get(capability_key, false)):
			continue
		var state: Dictionary = enemy_ability_state.get(target_id, {})
		if capability_key == "functional_cyberware" and bool(state.get("cyberware_disabled", false)):
			continue
		if capability_key == "functional_implants" and bool(state.get("implants_disabled", false)):
			continue
		var rank := float(capabilities.get(ranking_key, 0.0)) if rank_by_strength else -absf(float(target.get("x", enemy_x)) - float(allies[ally_index].get("x", 0.0)))
		if selected.is_empty() or rank > selected_rank or (is_equal_approx(rank, selected_rank) and target_id < selected):
			selected = target_id
			selected_rank = rank
	return selected


func _start_frame_skip(ally_index: int, target_id: String) -> void:
	var recruit_id := str(allies[ally_index].get("id", "glitch"))
	var ability: Dictionary = ability_trial_def.get("abilities", {}).get("glitch", {})
	var cooldown := float(ability_cooldown_until.get(recruit_id, 0.0))
	if sim_time < cooldown or _living_enemy_ids().is_empty():
		return
	_set_timed_ability_effect(recruit_id, "frame_skip", float(ability.get("burst_duration_seconds", 0.0)))
	_set_timed_ability_effect(recruit_id, "frame_skip_last_target", float(ability.get("burst_duration_seconds", 0.0)), target_id)
	_commit_ability_cooldown(recruit_id, ability)
	notify_qualifying_progress_effect()
	_emit_ability_resolved(recruit_id, "ally", str(ability.get("ability_id", "frame_skip")), target_id, "retarget_after_each_attack", {"current_attack_first": true})


func _remove_echo_decoy(reason: String) -> void:
	if echo_decoy.is_empty():
		return
	echo_decoy.clear()
	_emit_ability_resolved("echo", "ally", "signal_cascade", "", reason)


func _set_frame_skip_progress(recruit_id: String, target_id: String, _unused_remaining: int) -> void:
	if bool(_active_ability_effect(recruit_id, "frame_skip", false)):
		var effect: Dictionary = ability_effects.get(recruit_id, {})
		var burst: Dictionary = effect.get("frame_skip", {})
		effect["frame_skip_last_target"] = {"expires_at": float(burst.get("expires_at", sim_time)), "value": target_id}
		ability_effects[recruit_id] = effect


func _living_ally_count() -> int:
	var count := 0
	for ally in allies:
		if float(ally["hp"]) > 0.0:
			count += 1
	return count


func _sync_breaker_fields() -> void:
	var breaker_index := _find_ally_index("breaker")
	var primary_index := breaker_index if breaker_index >= 0 else (0 if not allies.is_empty() else -1)
	if primary_index < 0:
		return
	var breaker: Dictionary = allies[primary_index]
	player_x = float(breaker["x"])
	player_hp = float(breaker["hp"])
	player_attack_elapsed = float(breaker["attack_elapsed"])
	player_animation = str(breaker["animation"])


func _build_squad(lineup: Array = []) -> void:
	allies.clear()
	var defaults: Dictionary = squad_def.get("placeholder_combat_stats", {})
	for index in range(int(squad_def.get("active_slots", 6))):
		var slot: Dictionary = squad_def.get("slots", [])[index]
		var recruit_id := str(lineup[index]) if lineup.size() == int(squad_def.get("active_slots", 6)) else str(slot.get("id", "placeholder_%02d" % (index + 1)))
		if recruit_id.is_empty():
			continue
		var is_breaker := recruit_id == "breaker"
		var character: Dictionary = player_def if is_breaker else defaults
		var combat_style := str(slot.get("combat_style", character.get("combat_style", defaults.get("combat_style", "melee"))))
		var attack_range := float(character.get("attack_range", defaults.get("attack_range", 74.0)))
		var engagement_distance := minf(maxf(0.0, _ally_engagement_distance(slot, character, defaults)), attack_range)
		var base_attack_power := float(character.get("attack_power", defaults.get("attack_power", 8.0)))
		var saved_recruit_state: Variant = recruit_run_states.get(recruit_id, {})
		var saved_hp := float(saved_recruit_state.get("hp", character.get("max_hp", defaults.get("max_hp", 70.0)))) if typeof(saved_recruit_state) == TYPE_DICTIONARY else float(character.get("max_hp", defaults.get("max_hp", 70.0)))
		allies.append({
			"id": recruit_id,
			"display_name": _recruit_display_name(recruit_id, slot),
			"prototype_placeholder": not is_breaker,
			"is_breaker": is_breaker,
			"formation_depth": float(slot.get("formation_depth", 0.0)),
			"formation_start_offset_x": float(slot.get("formation_start_offset_x", 0.0)),
			"combat_style": combat_style,
			"engagement_distance": engagement_distance,
			"x": 190.0,
			"hp": saved_hp,
			"max_hp": float(character.get("max_hp", defaults.get("max_hp", 70.0))),
			"base_attack_power": base_attack_power,
			"attack_power": _effective_attack_power(base_attack_power),
			"move_speed": float(slot.get("move_speed", character.get("move_speed", defaults.get("move_speed", 48.0)))),
			"attack_range": attack_range,
			"attack_interval": float(character.get("attack_interval", defaults.get("attack_interval", 1.0))),
			"attack_elapsed": 0.0,
			"animation": "idle"
		})
	_capture_presentation_origin()
	_store_recruit_hp()


func set_active_lineup(lineup_value: Variant, owned_ids: Array, saved_recruits: Dictionary = {}, force_apply: bool = false) -> bool:
	var validation := ROSTER_STATE_SERVICE.validate_active_lineup(lineup_value, owned_ids)
	if not bool(validation.get("ok", false)):
		return false
	var candidate: Array[String] = []
	for recruit_id in validation["lineup"]:
		candidate.append(str(recruit_id))
	recruit_run_states = saved_recruits.duplicate(true)
	if phase == "combat" and not force_apply:
		pending_active_lineup = candidate
		return true
	active_lineup = candidate
	pending_active_lineup.clear()
	_build_squad(active_lineup)
	if force_apply and combat_action_sequence == 0 and highest_cleared_wave == 0:
		# Main installs the initial owned roster after this node's _ready; treat
		# that as encounter one so an explicit playtest seed is directly readable.
		encounter_index = 0
	if phase not in ["intermission", "retreat", "prototype_complete"] or force_apply:
		_begin_encounter()
	else:
		state_changed.emit()
	return true


func _recruit_display_name(recruit_id: String, fallback_slot: Dictionary) -> String:
	for recruit_value in recruit_roster.get("recruits", []):
		if typeof(recruit_value) == TYPE_DICTIONARY and str(recruit_value.get("id", "")) == recruit_id:
			return str(recruit_value.get("name", recruit_id.to_upper()))
	return str(fallback_slot.get("display_name", recruit_id.to_upper()))


func _store_recruit_hp() -> void:
	for ally in allies:
		var recruit_id := str(ally.get("id", ""))
		if not ROSTER_STATE_SERVICE.CANONICAL_RECRUIT_IDS.has(recruit_id):
			continue
		var recruit_state: Dictionary = recruit_run_states.get(recruit_id, {"level": economy.recruit_level if recruit_id == "breaker" else 1})
		recruit_state["hp"] = float(ally.get("hp", 0.0))
		recruit_run_states[recruit_id] = recruit_state


func _capture_presentation_origin() -> void:
	render_previous_enemy_x = enemy_x
	render_previous_ally_x.clear()
	for ally in allies:
		render_previous_ally_x.append(float(ally["x"]))


func _player_attack_power() -> float:
	var base_power := float(player_def.get("attack_power", 18.0)) + float(economy.recruit_level - 1) * float(player_def.get("upgrade_attack_per_level", 2.4))
	return _effective_attack_power(base_power)


func _effective_attack_power(base_power: float) -> float:
	return base_power * (1.0 + lifetime_power_bonus_fraction)


func set_lifetime_influence(value: Variant) -> bool:
	if typeof(value) != TYPE_INT or int(value) < 0:
		return false
	var bonus: Dictionary = PROGRESSION_RULES.calculate_lifetime_power_bonus(value, lifetime_power_bonus_rule)
	if not bool(bonus.get("ok", false)):
		return false
	lifetime_influence = int(value)
	lifetime_power_bonus_fraction = float(bonus["bonus_fraction"])
	for ally in allies:
		if bool(ally.get("is_breaker", false)):
			ally["attack_power"] = _player_attack_power()
		else:
			ally["attack_power"] = _effective_attack_power(float(ally.get("base_attack_power", ally.get("attack_power", 0.0))))
	return true


func _player_max_hp() -> float:
	return float(player_def.get("max_hp", 120.0)) + float(economy.recruit_level - 1) * float(player_def.get("upgrade_hp_per_level", 9.0))


func _enemy_attack_power() -> float:
	return float(enemy_def.get("attack_power_base", 8.0)) + float(maxi(0, wave - 1)) * float(enemy_def.get("attack_per_wave", 0.7))


func _committed_attack_damage(base_damage: float, source_side: String) -> float:
	_last_impact_payload.clear()
	if combat_model != "hybrid_trial":
		return base_damage
	var source_power := _team_power(source_side)
	var opposing_power := _team_power("enemy" if source_side == "ally" else "ally")
	var total_power := source_power + opposing_power
	var relative_power := 0.5 if total_power <= 0.0 else clampf(source_power / total_power, 0.0, 1.0)
	var likelihood: Dictionary = combat_trial_def.get("likelihood", {})
	var minimum_probability := float(likelihood.get("minimum_high_impact_probability", 0.15))
	var maximum_probability := float(likelihood.get("maximum_high_impact_probability", 0.85))
	var high_impact_probability := lerpf(minimum_probability, maximum_probability, relative_power)
	var roll := encounter_rng.randf()
	var impact: Dictionary = combat_trial_def.get("impact", {})
	var is_high_impact := roll < high_impact_probability
	var multiplier := float(impact.get("high_multiplier", 1.30)) if is_high_impact else float(impact.get("low_multiplier", 0.70))
	_last_impact_payload = {
		"combat_model": combat_model,
		"encounter_seed": encounter_seed,
		"source_effective_power": source_power,
		"target_effective_power": opposing_power,
		"relative_power": relative_power,
		"high_impact_probability": high_impact_probability,
		"impact_roll": roll,
		"impact_band": "high" if is_high_impact else "low",
		"impact_multiplier": multiplier
	}
	return base_damage * multiplier


func _team_power(side: String) -> float:
	if side == "ally":
		var total := 0.0
		for ally in allies:
			var recruit_id := str(ally.get("id", ""))
			var effective_attack := float(ally.get("attack_power", 0.0)) * float(_active_ability_effect(recruit_id, "team_attack_multiplier", 1.0))
			total += _actor_power(float(ally.get("hp", 0.0)), float(ally.get("max_hp", 0.0)), effective_attack, _effective_ally_attack_interval(ally))
		return total
	var total_enemy_power := 0.0
	for target_id in _living_enemy_ids():
		var target := _enemy_target_snapshot(target_id)
		total_enemy_power += _actor_power(
			float(target.get("hp", 0.0)),
			float(target.get("max_hp", enemy_max_hp)),
			_enemy_attack_power_for(target_id) * _enemy_attack_multiplier(target_id),
			float(target.get("attack_interval", enemy_def.get("attack_interval", 1.05)))
		)
	return total_enemy_power


func _actor_power(current_hp: float, maximum_hp: float, attack_power: float, attack_interval: float) -> float:
	if current_hp <= 0.0 or maximum_hp <= 0.0:
		return 0.0
	var score: Dictionary = combat_trial_def.get("power_score", {})
	var hp_fraction := clampf(current_hp / maximum_hp, 0.0, 1.0)
	var hp_component := hp_fraction * (maximum_hp / float(score.get("max_hp_reference", 100.0)))
	var attack_component := maxf(0.0, attack_power) / float(score.get("attack_power_reference", 10.0))
	var interval_floor := float(score.get("minimum_attack_interval", 0.1))
	var cadence_component := float(score.get("cadence_reference_seconds", 1.0)) / maxf(interval_floor, attack_interval)
	return hp_component * float(score.get("current_hp_weight", 1.0)) + (maximum_hp / float(score.get("max_hp_reference", 100.0))) * float(score.get("max_hp_weight", 1.0)) + attack_component * float(score.get("attack_power_weight", 1.0)) + cadence_component * float(score.get("cadence_weight", 1.0))


func _begin_encounter(recover_squad: bool = false) -> void:
	_clear_ability_encounter_state()
	if not pending_active_lineup.is_empty():
		active_lineup = pending_active_lineup.duplicate()
		pending_active_lineup.clear()
		_build_squad(active_lineup)
	wave = maxi(1, wave)
	var wave_hp := float(maxi(0, wave - 1)) * float(enemy_def.get("hp_per_wave", 9.0))
	var squad_bonus := float(allies.size()) * float(squad_def.get("prototype_enemy_hp_per_active_ally_bonus", 0.0))
	enemy_max_hp = float(enemy_def.get("max_hp_base", 48.0)) + squad_bonus + wave_hp
	enemy_hp = enemy_max_hp
	for target_index in range(additional_enemy_targets.size()):
		var fixture: Dictionary = additional_enemy_targets[target_index]
		var fixture_max_hp := float(fixture.get("max_hp", fixture.get("hp", enemy_max_hp)))
		fixture["max_hp"] = fixture_max_hp
		fixture["hp"] = fixture_max_hp
		fixture["attack_elapsed"] = 0.0
		fixture["animation"] = "idle"
		additional_enemy_targets[target_index] = fixture
	for ally in allies:
		var maximum_hp := _ally_max_hp(ally)
		ally["max_hp"] = maximum_hp
		var saved_recruit_state: Variant = recruit_run_states.get(str(ally.get("id", "")), {})
		var saved_hp := float(saved_recruit_state.get("hp", ally.get("hp", maximum_hp))) if typeof(saved_recruit_state) == TYPE_DICTIONARY else float(ally.get("hp", maximum_hp))
		ally["hp"] = maximum_hp if recover_squad else clampf(saved_hp, 0.0, maximum_hp)
		if bool(ally.get("is_breaker", false)):
			ally["attack_power"] = _player_attack_power()
		else:
			ally["attack_power"] = _effective_attack_power(float(ally.get("base_attack_power", ally.get("attack_power", 0.0))))
		ally["x"] = 190.0 + float(ally.get("formation_start_offset_x", 0.0))
		ally["attack_elapsed"] = 0.0
		ally["animation"] = "defeated" if float(ally["hp"]) <= 0.0 else "idle"
	_sync_breaker_fields()
	if allies.is_empty():
		phase = "awaiting_deployment"
		phase_timer = 0.0
		_capture_presentation_origin()
		state_changed.emit()
		return
	enemy_x = 600.0
	player_attack_elapsed = 0.0
	enemy_attack_elapsed = 0.0
	player_animation = "idle"
	enemy_animation = "idle"
	phase = "combat"
	phase_timer = 0.0
	wave_limit_reached = false
	encounter_index += 1
	encounter_elapsed = 0.0
	no_progress_elapsed = 0.0
	last_terminal_reason = ""
	last_timer_expiry_primary = ""
	last_timer_expiry_also.clear()
	encounter_seed = encounter_seed_base + (encounter_index - 1) * int(combat_trial_def.get("seed_stride", 104729))
	encounter_rng = RandomNumberGenerator.new()
	encounter_rng.seed = encounter_seed
	_capture_presentation_origin()
	_store_recruit_hp()
	_log("Undercity wave %d begins." % wave)
	state_changed.emit()


func _enemy_defeated() -> void:
	_clear_ability_encounter_state()
	_store_recruit_hp()
	var cleared_wave := wave
	var reward := economy.grant_encounter_reward(cleared_wave, wave_def)
	highest_cleared_wave = maxi(highest_cleared_wave, cleared_wave)
	last_terminal_reason = "clear"
	enemy_animation = "defeated"
	_log("Wave %d cleared. +%d credits." % [cleared_wave, reward])
	if cleared_wave >= int(wave_def.get("last_wave", 25)):
		wave_limit_reached = true
	else:
		wave = cleared_wave + 1
	phase = "intermission"
	phase_timer = 1.1
	wave_cleared.emit(cleared_wave, reward, highest_cleared_wave, str(enemy_def.get("boss_id", "")))


func _squad_defeated(reason: String = "squad_defeat") -> void:
	_clear_ability_encounter_state()
	for ally in allies:
		if float(ally["hp"]) <= 0.0 or reason in ["maximum_timeout", "no_progress"]:
			ally["animation"] = "defeated"
	var holding_wave := maxi(1, highest_cleared_wave)
	_store_recruit_hp()
	wave = holding_wave
	phase = "retreat"
	phase_timer = 1.4
	last_terminal_reason = reason
	if reason in ["maximum_timeout", "no_progress"]:
		stalemate_arrival_pending = true
	var cause_text := "Stalemate timer expired. " if reason in ["maximum_timeout", "no_progress"] else "Squad defeated. "
	_log("%sRetreating to highest cleared holding wave %d." % [cause_text, holding_wave])


func _ally_max_hp(ally: Dictionary) -> float:
	return _player_max_hp() if bool(ally.get("is_breaker", false)) else float(ally.get("max_hp", 70.0))


func _find_ally_index(recruit_id: String) -> int:
	for index in range(allies.size()):
		if str(allies[index].get("id", "")) == recruit_id:
			return index
	return -1


func _ally_engagement_distance(slot: Dictionary, character: Dictionary, defaults: Dictionary) -> float:
	var combat_style := str(slot.get("combat_style", character.get("combat_style", defaults.get("combat_style", "melee"))))
	if combat_style == "melee":
		return float(slot.get("melee_contact_distance", character.get("melee_contact_distance", defaults.get("melee_contact_distance", 4.0))))
	return float(slot.get("engagement_distance", character.get("engagement_distance", defaults.get("engagement_distance", character.get("attack_range", defaults.get("attack_range", 74.0))))))


func upgrade_recruit(bulk_count: int) -> int:
	var transaction := preview_upgrade_recruit(bulk_count)
	if int(transaction.get("bought", 0)) > 0:
		apply_upgrade_recruit(transaction)
	return int(transaction.get("bought", 0))


func preview_upgrade_recruit(bulk_count: int) -> Dictionary:
	var purchase := economy.preview_purchase_levels(player_def, bulk_count)
	var bought := int(purchase["bought"])
	if bought <= 0:
		return purchase
	var next_level := int(purchase["recruit_level"])
	var next_max_hp := float(player_def.get("max_hp", 120.0)) + float(next_level - 1) * float(player_def.get("upgrade_hp_per_level", 9.0))
	var breaker_index := _find_ally_index("breaker")
	var breaker_state: Variant = recruit_run_states.get("breaker", {})
	var current_hp := float(allies[breaker_index]["hp"]) if breaker_index >= 0 else (float(breaker_state.get("hp", next_max_hp)) if typeof(breaker_state) == TYPE_DICTIONARY else next_max_hp)
	var next_hp := minf(next_max_hp, current_hp + float(bought) * float(player_def.get("upgrade_hp_per_level", 9.0)))
	purchase["breaker_max_hp"] = next_max_hp
	var next_base_attack_power := float(player_def.get("attack_power", 18.0)) + float(next_level - 1) * float(player_def.get("upgrade_attack_per_level", 2.4))
	purchase["breaker_attack_power"] = _effective_attack_power(next_base_attack_power)
	purchase["breaker_hp"] = next_hp
	return purchase


func apply_upgrade_recruit(transaction: Dictionary) -> bool:
	var bought := int(transaction.get("bought", 0))
	if bought <= 0 or int(transaction.get("recruit_level", economy.recruit_level)) <= economy.recruit_level:
		return false
	economy.credits = int(transaction["credits"])
	economy.recruit_level = int(transaction["recruit_level"])
	var breaker_state: Dictionary = recruit_run_states.get("breaker", {"level": 1})
	breaker_state["level"] = economy.recruit_level
	breaker_state["hp"] = float(transaction["breaker_hp"])
	recruit_run_states["breaker"] = breaker_state
	var breaker_index := _find_ally_index("breaker")
	if breaker_index >= 0:
		allies[breaker_index]["max_hp"] = float(transaction["breaker_max_hp"])
		allies[breaker_index]["attack_power"] = float(transaction["breaker_attack_power"])
		allies[breaker_index]["hp"] = float(transaction["breaker_hp"])
		_sync_breaker_fields()
	_log("BREAKER upgraded to run level %d." % economy.recruit_level)
	state_changed.emit()
	return true


func upgrade_cost(current_level: int) -> int:
	return economy.upgrade_cost(player_def, current_level)


func load_run_state(saved: Dictionary) -> void:
	economy.load_run_state(saved)
	highest_cleared_wave = clampi(int(saved.get("highest_cleared_wave", 0)), 0, int(wave_def.get("last_wave", 25)))
	wave = clampi(int(saved.get("wave", maxi(1, highest_cleared_wave))), 1, int(wave_def.get("last_wave", 25)))
	var saved_recruits: Variant = saved.get("recruits", {})
	if typeof(saved_recruits) == TYPE_DICTIONARY:
		recruit_run_states = saved_recruits.duplicate(true)
	var saved_squad_hp: Variant = saved.get("squad_hp", null)
	if typeof(saved_squad_hp) == TYPE_ARRAY and saved_squad_hp.size() == allies.size():
		for index in range(allies.size()):
			if (typeof(saved_squad_hp[index]) == TYPE_INT or typeof(saved_squad_hp[index]) == TYPE_FLOAT) and is_finite(float(saved_squad_hp[index])):
				allies[index]["hp"] = clampf(float(saved_squad_hp[index]), 0.0, _ally_max_hp(allies[index]))
	else:
		for index in range(allies.size()):
			var ally: Dictionary = allies[index]
			var recruit_state: Variant = saved_recruits.get(str(ally.get("id", "")), {}) if typeof(saved_recruits) == TYPE_DICTIONARY else {}
			if typeof(recruit_state) == TYPE_DICTIONARY and recruit_state.has("hp") and (typeof(recruit_state["hp"]) == TYPE_INT or typeof(recruit_state["hp"]) == TYPE_FLOAT) and is_finite(float(recruit_state["hp"])):
				ally["hp"] = clampf(float(recruit_state["hp"]), 0.0, _ally_max_hp(ally))
			else:
				ally["hp"] = _ally_max_hp(ally)
			allies[index] = ally
	_begin_encounter()


func snapshot() -> Dictionary:
	_store_recruit_hp()
	var primary_index := _find_ally_index("breaker")
	if primary_index < 0 and not allies.is_empty():
		primary_index = 0
	var breaker: Dictionary = allies[primary_index] if primary_index >= 0 else {}
	var primary_max_hp := _player_max_hp() if str(breaker.get("id", "")) == "breaker" else float(breaker.get("max_hp", 0.0))
	var ally_states: Array[Dictionary] = []
	var placeholder_ally_count := 0
	for ally in allies:
		ally_states.append(ally.duplicate(true))
		if bool(ally.get("prototype_placeholder", false)):
			placeholder_ally_count += 1
	return {
		"phase": phase,
		"wave": wave,
		"highest_cleared_wave": highest_cleared_wave,
		"recruit_level": economy.recruit_level,
		"credits": economy.credits,
		"player_x": float(breaker.get("x", player_x)),
		"enemy_x": enemy_x,
		"player_hp": float(breaker.get("hp", player_hp)),
		"player_max_hp": primary_max_hp,
		"primary_recruit_id": str(breaker.get("id", "none")),
		"lifetime_influence": lifetime_influence,
		"lifetime_power_bonus_fraction": lifetime_power_bonus_fraction,
		"combat_model": combat_model,
		"encounter_seed": encounter_seed,
		"encounter_elapsed": encounter_elapsed,
		"no_progress_elapsed": no_progress_elapsed,
		"last_terminal_reason": last_terminal_reason,
		"last_timer_expiry_primary": last_timer_expiry_primary,
		"last_timer_expiry_also": last_timer_expiry_also.duplicate(),
		"enemy_hp": enemy_hp,
		"player_animation": str(breaker.get("animation", player_animation)),
		"allies": ally_states,
		"active_lineup": active_lineup.duplicate(),
		"recruit_states": recruit_run_states.duplicate(true),
		"squad_size": allies.size(),
		"placeholder_ally_count": placeholder_ally_count,
		"living_ally_count": _living_ally_count(),
		"enemy_animation": enemy_animation,
		"last_event": last_event,
		"district_name": _display_location_name(),
		"enemy_name": str(enemy_def.get("display_name", "Enemy")),
		"enemy_max_hp": enemy_max_hp,
		"upgrade_cost": upgrade_cost(economy.recruit_level),
		"wave_limit": int(wave_def.get("last_wave", 25))
	}


func _display_location_name() -> String:
	if wave <= int(wave_def.get("content_end_wave", 25)):
		return str(wave_def.get("display_name", "Undercity Prototype"))
	return str(wave_def.get("post_content_display_name", "Progression Test Fixture"))


## Presentation-only snapshot interpolated between the last fixed step and current state.
## Combat rules and persistence continue to use snapshot() and authoritative simulation state.
func presentation_snapshot() -> Dictionary:
	var state := snapshot()
	if render_previous_ally_x.size() != allies.size():
		return state
	var alpha := clampf(accumulator / FIXED_STEP, 0.0, 1.0)
	state["enemy_x"] = lerpf(render_previous_enemy_x, enemy_x, alpha)
	var rendered_allies: Array = state["allies"]
	for index in range(rendered_allies.size()):
		var ally: Dictionary = rendered_allies[index]
		ally["x"] = lerpf(render_previous_ally_x[index], float(allies[index]["x"]), alpha)
		rendered_allies[index] = ally
	state["allies"] = rendered_allies
	return state


## Emit resolved attack data only after authoritative damage has been applied.
## Presentation listeners receive a deep copy and cannot affect simulation state.
func _emit_combat_action(source_id: String, source_side: String, target_id: String, attack_style: String, damage: float, target_hp_after: float, extra_payload: Dictionary = {}) -> void:
	combat_action_sequence += 1
	var event := {
		"sequence": combat_action_sequence,
		"event_type": "attack_resolved",
		"wave_number": wave,
		"simulation_time": sim_time,
		"source_id": source_id,
		"source_side": source_side,
		"target_id": target_id,
		"attack_style": attack_style,
		"damage": damage,
		"target_hp_after": target_hp_after,
		"target_defeated": target_hp_after <= 0.0
	}
	for key in extra_payload:
		event[key] = extra_payload[key]
	combat_action_resolved.emit(event.duplicate(true))


## Publish an ability presentation event only after its authoritative effect has committed.
## This method does not activate abilities or apply their effects.
func _emit_ability_resolved(source_id: String, source_side: String, ability_id: String, target_id: String = "", effect_id: String = "", extra_payload: Dictionary = {}) -> void:
	var clean_source_id := source_id.strip_edges()
	var clean_source_side := source_side.strip_edges()
	var clean_ability_id := ability_id.strip_edges()
	if clean_source_id.is_empty() or clean_ability_id.is_empty() or clean_source_side not in ["ally", "enemy"]:
		return
	combat_action_sequence += 1
	var event := {
		"sequence": combat_action_sequence,
		"event_type": "ability_resolved",
		"wave_number": wave,
		"simulation_time": sim_time,
		"source_id": clean_source_id,
		"source_side": clean_source_side,
		"ability_id": clean_ability_id
	}
	var clean_target_id := target_id.strip_edges()
	var clean_effect_id := effect_id.strip_edges()
	if not clean_target_id.is_empty():
		event["target_id"] = clean_target_id
	if not clean_effect_id.is_empty():
		event["effect_id"] = clean_effect_id
	for key in extra_payload:
		event[key] = extra_payload[key]
	combat_action_resolved.emit(event.duplicate(true))


func _log(message: String) -> void:
	last_event = message
	event_logged.emit(message)
