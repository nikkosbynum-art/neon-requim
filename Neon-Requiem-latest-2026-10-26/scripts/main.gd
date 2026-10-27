extends Node2D

const DIRECTOR_SCRIPT := preload("res://scripts/combat/combat_director.gd")
const ATTACHMENT_ROUTER_SCRIPT := preload("res://scripts/presentation/attachment_event_router.gd")
const ACTOR_SCRIPT := preload("res://scripts/presentation/placeholder_actor.gd")
const BREAKER_SCRIPT := preload("res://scripts/characters/breaker_t1_placeholder_rig.gd")
const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")
const ENVIRONMENT_DIRECTOR_SCRIPT := preload("res://scripts/environment/environment_director.gd")
const REBOOT_SCRIPT := preload("res://scripts/progression/reboot_service.gd")
const MATERIAL_REWARD_SCRIPT := preload("res://scripts/progression/material_reward_service.gd")
const EVOLUTION_SCRIPT := preload("res://scripts/progression/evolution_service.gd")
const OFFLINE_EARNINGS_SCRIPT := preload("res://scripts/progression/offline_earnings_service.gd")
const RESEARCH_SERVICE_SCRIPT := preload("res://scripts/progression/research_service.gd")
const RECRUITMENT_SERVICE_SCRIPT := preload("res://scripts/progression/recruitment_service.gd")
const ROSTER_STATE_SCRIPT := preload("res://scripts/progression/roster_state_service.gd")
const FORMATION_PREFERENCE_SCRIPT := preload("res://scripts/progression/formation_preference_service.gd")
const PROGRESSION_PROFILE_PATH := "res://data/progression/progression_prototype_profile.json"
const RESEARCH_CATALOG_PATH := "res://data/progression/research_catalog.json"
const RECRUITMENT_PROFILE_PATH := "res://data/progression/recruitment_prototype_profile.json"
const FOUNDING_ROSTER_PATH := "res://data/characters/founding_recruits.json"

var director: CombatDirector
var attachment_event_router: Node
var environment_director: Node2D
var breaker_actor: BreakerTierOnePlaceholderRig
var enemy_actor: PlaceholderActor
var allied_actors: Array[Node2D] = []
var ground_shadow_layer: Node2D
var ally_ground_shadows: Array[Polygon2D] = []
var enemy_ground_shadow: Polygon2D
var status_label: Label
var squad_label: Label
var stats_label: Label
var event_label: Label
var feedback_label: Label
var hint_label: Label
var hud_panel: PanelContainer
var reboot_button: Button
var evolution_button: Button
var recruitment_button: Button
var reboot_confirmation: ConfirmationDialog
var reset_save_confirmation: ConfirmationDialog
var recruitment_dialog: Control
var recruitment_balance_label: Label
var recruitment_status_label: Label
var recruitment_roster_list: VBoxContainer
var recruitment_rows: Dictionary = {}
var lineup_controls: Array[OptionButton] = []
var formation_position_controls: Dictionary = {}
var formation_role_controls: Dictionary = {}
var evolution_dialog: Control
var evolution_balance_label: Label
var evolution_roster_list: VBoxContainer
var evolution_rows: Dictionary = {}
var research_dialog: Control
var research_panel: PanelContainer
var research_balance_label: Label
var progression_profile: Dictionary = {}
var research_catalog: Dictionary = {}
var recruitment_profile: Dictionary = {}
var recruitment_catalog: Dictionary = {}
var recruitment_config_error := ""
var recruit_run_states: Dictionary = {}
var active_lineup: Array[String] = []
var legacy_placeholder_hp: Array[float] = []
var save_path := SAVE_SCRIPT.SAVE_PATH
var loaded_save_path := ""
var permanent_state := {"lifetime_influence": 0, "highest_wave_ever": 0, "first_clear_material_claims": [], "evolution_materials": {}, "research": {}, "research_nodes": {}, "evolution": {"breaker_tier": "Origin Form"}, "unlocks": [], "formation_preferences": {}}
var settings_state := {"master_volume": 1.0, "window_mode": "windowed"}


func _ready() -> void:
	_setup_battlefield()
	director = DIRECTOR_SCRIPT.new()
	director.name = "CombatDirector"
	add_child(director)
	attachment_event_router = ATTACHMENT_ROUTER_SCRIPT.new()
	attachment_event_router.name = "AttachmentEventRouter"
	add_child(attachment_event_router)
	director.combat_action_resolved.connect(attachment_event_router.dispatch_combat_event)
	director.set_lifetime_influence(int(permanent_state.get("lifetime_influence", 0)))
	progression_profile = _read_json_dictionary(PROGRESSION_PROFILE_PATH)
	research_catalog = _read_json_dictionary(RESEARCH_CATALOG_PATH)
	director.state_changed.connect(_on_director_state_changed)
	director.event_logged.connect(_on_event)
	director.wave_cleared.connect(_on_wave_cleared)
	director.stalemate_arrival.connect(_on_stalemate_arrival)
	recruitment_profile = _read_json_dictionary(RECRUITMENT_PROFILE_PATH)
	recruitment_catalog = _read_json_dictionary(FOUNDING_ROSTER_PATH)
	var recruitment_validation: Dictionary = RECRUITMENT_SERVICE_SCRIPT.validate_configuration(recruitment_catalog, recruitment_profile)
	if bool(recruitment_validation.get("ok", false)):
		permanent_state = RECRUITMENT_SERVICE_SCRIPT.ensure_starting_recruits(permanent_state, recruitment_profile)
		director.economy.credits = int(recruitment_profile.get("starting_credits", 0))
		var starting_owned: Array = permanent_state.get("unlocks", [])
		var starting_states := ROSTER_STATE_SCRIPT.ensure_owned_recruit_records({"recruits": {"breaker": {"level": director.economy.recruit_level}}}, starting_owned, _max_hp_by_recruit(starting_owned))
		if bool(starting_states.get("ok", false)):
			recruit_run_states = starting_states["run"].get("recruits", {})
		active_lineup = ROSTER_STATE_SCRIPT.build_default_lineup(starting_owned)
		if not director.set_active_lineup(active_lineup, starting_owned, recruit_run_states, true):
			recruitment_config_error = "The starting lineup could not be prepared safely."
	else:
		recruitment_config_error = str(recruitment_validation.get("error", "Recruitment configuration is invalid."))
	_setup_ground_shadows()
	_sync_presentation_actors()
	enemy_actor = ACTOR_SCRIPT.new()
	enemy_actor.name = "Enemy_Placeholder"
	enemy_actor.configure(true)
	add_child(enemy_actor)
	_build_ui()
	_refresh()


func _setup_battlefield() -> void:
	environment_director = ENVIRONMENT_DIRECTOR_SCRIPT.new() as Node2D
	environment_director.name = "EnvironmentDirector"
	add_child(environment_director)
	move_child(environment_director, 0)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	layer.add_child(root)
	hud_panel = PanelContainer.new()
	hud_panel.position = Vector2(22, 18)
	hud_panel.custom_minimum_size = Vector2(520, 220)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#090f19")
	panel_style.bg_color.a = 0.94
	panel_style.border_color = Color("#294458")
	panel_style.set_border_width_all(1)
	panel_style.border_width_top = 3
	panel_style.border_color = Color("#d63d62")
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 12
	hud_panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(hud_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	hud_panel.add_child(column)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 21)
	status_label.add_theme_color_override("font_color", Color("#edf2f8"))
	column.add_child(status_label)
	squad_label = Label.new()
	squad_label.add_theme_color_override("font_color", Color("#61e6d3"))
	column.add_child(squad_label)
	stats_label = Label.new()
	stats_label.add_theme_color_override("font_color", Color("#b6c1ce"))
	column.add_child(stats_label)
	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.add_theme_color_override("font_color", Color("#f0a1b1"))
	column.add_child(event_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 7)
	column.add_child(actions)
	_add_button(actions, "Upgrade x1", func(): _upgrade(1))
	_add_button(actions, "Upgrade x10", func(): _upgrade(10))
	_add_button(actions, "Save", _save)
	_add_button(actions, "Load", _load)
	_add_button(actions, "Research", _show_research_dialog)
	_add_button(actions, "Reset Save", _request_save_reset_confirmation)
	var progression_actions := HBoxContainer.new()
	progression_actions.add_theme_constant_override("separation", 7)
	column.add_child(progression_actions)
	recruitment_button = Button.new()
	recruitment_button.text = "RECRUITS"
	recruitment_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recruitment_button.add_theme_stylebox_override("normal", _button_style(Color("#18232c"), Color("#3f8d84")))
	recruitment_button.add_theme_stylebox_override("hover", _button_style(Color("#203b3d"), Color("#61e6d3")))
	recruitment_button.add_theme_color_override("font_color", Color("#baf3e6"))
	recruitment_button.pressed.connect(_show_recruitment_dialog)
	progression_actions.add_child(recruitment_button)
	evolution_button = Button.new()
	evolution_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	evolution_button.add_theme_stylebox_override("normal", _button_style(Color("#241b2a"), Color("#8d56ad")))
	evolution_button.add_theme_stylebox_override("hover", _button_style(Color("#362344"), Color("#d58bff")))
	evolution_button.add_theme_color_override("font_color", Color("#eedbff"))
	evolution_button.text = "EVOLUTION"
	evolution_button.pressed.connect(_show_evolution_dialog)
	progression_actions.add_child(evolution_button)
	feedback_label = Label.new()
	feedback_label.add_theme_color_override("font_color", Color("#61e6d3"))
	feedback_label.add_theme_font_size_override("font_size", 13)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(feedback_label)
	reboot_button = Button.new()
	reboot_button.text = "SYSTEM REBOOT — LOCKED UNTIL WAVE 25 CLEAR"
	reboot_button.disabled = true
	reboot_button.add_theme_stylebox_override("normal", _button_style(Color("#241521"), Color("#7b3953")))
	reboot_button.add_theme_stylebox_override("hover", _button_style(Color("#3b2032"), Color("#ef5570")))
	reboot_button.add_theme_color_override("font_color", Color("#f2c4d0"))
	reboot_button.pressed.connect(_request_reboot_confirmation)
	column.add_child(reboot_button)
	reboot_confirmation = ConfirmationDialog.new()
	reboot_confirmation.title = "Confirm System Reboot"
	reboot_confirmation.min_size = Vector2i(620, 240)
	reboot_confirmation.size = Vector2i(620, 240)
	reboot_confirmation.dialog_autowrap = true
	reboot_confirmation.dialog_text = "Reboot resets credits, recruit run-levels, and wave progress, and restores squad HP.\n\nPermanent Influence, research, evolution, unlocks, and first-clear milestones remain. Continue?"
	reboot_confirmation.get_label().autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reboot_confirmation.confirmed.connect(_perform_reboot)
	root.add_child(reboot_confirmation)
	reset_save_confirmation = ConfirmationDialog.new()
	reset_save_confirmation.title = "Confirm Save Reset"
	reset_save_confirmation.dialog_text = "Replace the local save with the current session? Unsupported or corrupt save data may become unavailable. Valid current-version recovery copies remain when possible. This cannot be undone."
	reset_save_confirmation.get_ok_button().text = "Replace Save"
	reset_save_confirmation.get_cancel_button().text = "Cancel"
	reset_save_confirmation.confirmed.connect(_perform_confirmed_save_reset)
	root.add_child(reset_save_confirmation)
	_build_recruitment_dialog(root)
	_build_evolution_dialog(root)
	_build_research_dialog(root)
	hint_label = Label.new()
	hint_label.text = "AUTOMATIC COMBAT  •  PROTOTYPE PLACEHOLDERS"
	hint_label.anchor_left = 1.0
	hint_label.anchor_right = 1.0
	hint_label.offset_left = -500
	hint_label.offset_right = -20
	hint_label.offset_top = 22
	hint_label.add_theme_color_override("font_color", Color("#a3a6c6"))
	root.add_child(hint_label)
	get_window().size_changed.connect(_apply_responsive_hud_scale)
	_apply_responsive_hud_scale()


func _apply_responsive_hud_scale() -> void:
	if not is_instance_valid(hud_panel):
		return
	var window_size := get_window().size
	var window_ratio := minf(float(window_size.x) / 1280.0, float(window_size.y) / 720.0)
	var readable_scale := clampf(1.0 / sqrt(maxf(window_ratio, 0.1)), 1.0, 1.16)
	hud_panel.scale = Vector2.ONE * readable_scale
	if is_instance_valid(hint_label):
		hint_label.visible = window_size.x >= 960


func _add_button(parent: HBoxContainer, title: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.add_theme_stylebox_override("normal", _button_style(Color("#151f2c"), Color("#34586b")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#1c3441"), Color("#55c9c0")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#361b2a"), Color("#ef5570")))
	button.add_theme_stylebox_override("focus", _button_style(Color("#151f2c"), Color("#61e6d3")))
	button.add_theme_color_override("font_color", Color("#dbe8ef"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.pressed.connect(callback)
	parent.add_child(button)


func _button_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style


func _process(_delta: float) -> void:
	if is_instance_valid(director):
		var state := director.presentation_snapshot()
		var allies: Array = state["allies"]
		_sync_presentation_actors(allies)
		for index in range(mini(allied_actors.size(), allies.size())):
			var ally: Dictionary = allies[index]
			var ratio := float(ally["hp"]) / maxf(1.0, float(ally["max_hp"]))
			var world_y := 510.0 + float(ally["formation_depth"])
			var foot_contact_offset := 3.0 if bool(ally.get("is_breaker", false)) else 9.0
			ally_ground_shadows[index].position = Vector2(float(ally["x"]), world_y + foot_contact_offset)
			if allied_actors[index] is BreakerTierOnePlaceholderRig:
				(allied_actors[index] as BreakerTierOnePlaceholderRig).present(float(ally["x"]), str(ally["animation"]), ratio, world_y)
			else:
				var actor := allied_actors[index] as PlaceholderActor
				actor.present(float(ally["x"]), str(ally["animation"]), ratio, world_y)
		enemy_actor.present(float(state["enemy_x"]), str(state["enemy_animation"]), float(state["enemy_hp"]) / maxf(1.0, float(state["enemy_max_hp"])))
		enemy_ground_shadow.position = Vector2(float(state["enemy_x"]), 523.0)


func _setup_ground_shadows() -> void:
	ground_shadow_layer = Node2D.new()
	ground_shadow_layer.name = "ActorGroundShadows"
	add_child(ground_shadow_layer)
	enemy_ground_shadow = _make_ground_shadow(24.0, 6.0)
	enemy_ground_shadow.name = "GroundShadow_Enemy"
	ground_shadow_layer.add_child(enemy_ground_shadow)


func _sync_presentation_actors(ally_states: Array = []) -> void:
	if not is_instance_valid(director) or not is_instance_valid(ground_shadow_layer):
		return
	var states: Array = ally_states if not ally_states.is_empty() else director.snapshot().get("allies", [])
	var ids: Array[String] = []
	for ally in states:
		ids.append(str(ally.get("id", "")))
	var current_ids: Array[String] = []
	for actor in allied_actors:
		current_ids.append(str(actor.get_meta("recruit_id", "")))
	if ids == current_ids:
		return
	for actor in allied_actors:
		if is_instance_valid(actor):
			actor.queue_free()
	for shadow in ally_ground_shadows:
		if is_instance_valid(shadow):
			shadow.queue_free()
	allied_actors.clear()
	ally_ground_shadows.clear()
	for index in range(states.size()):
		var ally: Dictionary = states[index]
		var recruit_id := str(ally.get("id", ""))
		var actor: Node2D
		if bool(ally.get("is_breaker", false)):
			var breaker := BREAKER_SCRIPT.new() as Node2D
			breaker.name = "BREAKER_Placeholder"
			breaker.set_tier(1)
			breaker.set_facing_right(true)
			breaker.set_animation_durations(director.player_def.get("animation_durations", {}))
			actor = breaker
			breaker_actor = breaker
		else:
			var placeholder := ACTOR_SCRIPT.new() as PlaceholderActor
			placeholder.name = "RecruitPlaceholder_%s" % recruit_id
			placeholder.configure(false, index)
			placeholder.scale = Vector2.ONE * 0.66
			actor = placeholder
		actor.set_meta("recruit_id", recruit_id)
		add_child(actor)
		allied_actors.append(actor)
		var depth := float(ally.get("formation_depth", 0.0))
		var depth_scale := clampf(1.0 + depth / 400.0, 0.8, 1.2)
		var shadow := _make_ground_shadow(24.0 * depth_scale if bool(ally.get("is_breaker", false)) else 18.0 * depth_scale, 5.0 * depth_scale)
		shadow.name = "GroundShadow_%s" % recruit_id
		ground_shadow_layer.add_child(shadow)
		ally_ground_shadows.append(shadow)


func _make_ground_shadow(radius_x: float, radius_y: float) -> Polygon2D:
	var shadow := Polygon2D.new()
	var points := PackedVector2Array()
	for vertex in range(20):
		var angle := TAU * float(vertex) / 20.0
		points.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	shadow.polygon = points
	shadow.color = Color(0.015, 0.02, 0.045, 0.68)
	return shadow


func _refresh() -> void:
	if not is_instance_valid(director) or not is_instance_valid(status_label):
		return
	var state := director.snapshot()
	status_label.text = "%s  •  Wave %d / %d  •  %s" % [state["district_name"], state["wave"], state["wave_limit"], str(state["phase"]).to_upper()]
	squad_label.text = "SQUAD %d/%d ACTIVE  •  %d placeholder allies" % [state["living_ally_count"], state["squad_size"], state.get("placeholder_ally_count", 0)]
	var lead_name := str(state.get("primary_recruit_id", "none")).to_upper()
	var current_level := int(state["recruit_level"])
	var upgrade_x1_cost := director.upgrade_cost(current_level)
	var upgrade_x10_cost := _upgrade_batch_cost(10, current_level)
	stats_label.text = "Credits %d  |  BREAKER Lv.%d  |  TRIAL UPGRADE COST x1 %s / x10 %s CREDITS\nFIELD LEAD %s HP %.0f/%.0f  |  %s HP %.0f/%.0f\nPERMANENT DAMAGE BONUS +%.1f%%  |  EVOLUTION DATA %d (shared)" % [state["credits"], current_level, String.num_int64(upgrade_x1_cost), String.num_int64(upgrade_x10_cost), lead_name, state["player_hp"], state["player_max_hp"], state["enemy_name"], state["enemy_hp"], state["enemy_max_hp"], float(state["lifetime_power_bonus_fraction"]) * 100.0, int(permanent_state.get("evolution_materials", {}).get("evolution_data", 0))]
	event_label.text = str(state["last_event"])
	if is_instance_valid(reboot_button):
		var eligible := int(state["highest_cleared_wave"]) >= int(progression_profile.get("system_reboot", {}).get("first_eligibility_wave", 25))
		reboot_button.disabled = not eligible
		reboot_button.text = "SYSTEM REBOOT — READY" if eligible else "SYSTEM REBOOT — LOCKED UNTIL WAVE 25 CLEAR"
	if is_instance_valid(evolution_button):
		_refresh_evolution_button()
	if is_instance_valid(recruitment_roster_list):
		_refresh_recruitment_dialog()
	else:
		_refresh_formation_preference_controls()
	if is_instance_valid(evolution_roster_list):
		_refresh_evolution_dialog()


func _upgrade_batch_cost(level_count: int, starting_level: int = -1) -> int:
	var level := director.economy.recruit_level if starting_level < 0 else starting_level
	var total_cost := 0
	for offset in range(maxi(0, level_count)):
		total_cost += director.upgrade_cost(level + offset)
	return total_cost


func _refresh_evolution_button() -> void:
	evolution_button.disabled = false
	evolution_button.text = "EVOLUTION"


func _show_evolution_dialog() -> void:
	if not is_instance_valid(evolution_dialog):
		return
	if is_instance_valid(recruitment_dialog):
		recruitment_dialog.visible = false
	if is_instance_valid(research_dialog):
		research_dialog.visible = false
	_refresh_evolution_dialog()
	evolution_dialog.visible = true


func _show_recruitment_dialog() -> void:
	if not is_instance_valid(recruitment_dialog):
		return
	if is_instance_valid(evolution_dialog):
		evolution_dialog.visible = false
	if is_instance_valid(research_dialog):
		research_dialog.visible = false
	_refresh_recruitment_dialog()
	recruitment_dialog.visible = true


func _build_recruitment_dialog(root: Control) -> void:
	recruitment_dialog = Control.new()
	recruitment_dialog.name = "RecruitmentOverlay"
	recruitment_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	recruitment_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	recruitment_dialog.visible = false
	recruitment_dialog.z_index = 20
	root.add_child(recruitment_dialog)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.015, 0.025, 0.045, 0.84)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	recruitment_dialog.add_child(dimmer)
	var centering := CenterContainer.new()
	centering.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centering.mouse_filter = Control.MOUSE_FILTER_IGNORE
	recruitment_dialog.add_child(centering)
	var panel := PanelContainer.new()
	panel.name = "RecruitmentPanel"
	panel.custom_minimum_size = root.get_viewport_rect().size * Vector2(0.92, 0.90)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0a111b")
	panel_style.border_color = Color("#3f8d84")
	panel_style.set_border_width_all(2)
	panel_style.border_width_top = 4
	panel_style.set_corner_radius_all(5)
	panel_style.content_margin_left = 26
	panel_style.content_margin_right = 26
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	centering.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var title := Label.new()
	title.text = "FOUNDING ROSTER // CREDIT RECRUITMENT"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#edf2f8"))
	content.add_child(title)
	recruitment_balance_label = Label.new()
	recruitment_balance_label.name = "RecruitmentBalance"
	recruitment_balance_label.add_theme_font_size_override("font_size", 20)
	recruitment_balance_label.add_theme_color_override("font_color", Color("#61e6d3"))
	content.add_child(recruitment_balance_label)
	var lineup_heading := Label.new()
	lineup_heading.text = "ACTIVE LINEUP // changes apply between encounters"
	lineup_heading.add_theme_color_override("font_color", Color("#d58bff"))
	lineup_heading.add_theme_font_size_override("font_size", 18)
	content.add_child(lineup_heading)
	var lineup_grid := GridContainer.new()
	lineup_grid.name = "ActiveLineupGrid"
	lineup_grid.columns = 3
	lineup_grid.add_theme_constant_override("h_separation", 8)
	lineup_grid.add_theme_constant_override("v_separation", 5)
	content.add_child(lineup_grid)
	lineup_controls.clear()
	for slot_index in range(6):
		var slot_box := VBoxContainer.new()
		slot_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lineup_grid.add_child(slot_box)
		var slot_label := Label.new()
		slot_label.text = "SLOT %d" % (slot_index + 1)
		slot_label.add_theme_font_size_override("font_size", 14)
		slot_label.add_theme_color_override("font_color", Color("#aeb9c8"))
		slot_box.add_child(slot_label)
		var selector := OptionButton.new()
		selector.name = "LineupSlot_%d" % (slot_index + 1)
		selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		selector.add_theme_font_size_override("font_size", 16)
		selector.add_item("VACANT")
		selector.set_item_metadata(0, "")
		selector.item_selected.connect(_on_lineup_option_changed.bind(slot_index, selector))
		slot_box.add_child(selector)
		lineup_controls.append(selector)
	var scroll := ScrollContainer.new()
	scroll.name = "RecruitmentRosterScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	recruitment_roster_list = VBoxContainer.new()
	recruitment_roster_list.name = "RecruitmentRosterList"
	recruitment_roster_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recruitment_roster_list.add_theme_constant_override("separation", 8)
	scroll.add_child(recruitment_roster_list)
	recruitment_rows.clear()
	var recruits_value: Variant = recruitment_catalog.get("recruits", [])
	if typeof(recruits_value) == TYPE_ARRAY and recruitment_config_error.is_empty():
		for recruit_value in recruits_value:
			if typeof(recruit_value) != TYPE_DICTIONARY:
				continue
			var recruit: Dictionary = recruit_value
			var recruit_id := str(recruit.get("id", ""))
			var row := VBoxContainer.new()
			row.name = "RecruitmentRow_%s" % recruit_id
			row.custom_minimum_size = Vector2(0, 60)
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_theme_constant_override("separation", 3)
			recruitment_roster_list.add_child(row)
			var row_heading := HBoxContainer.new()
			row_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row_heading.add_theme_constant_override("separation", 12)
			row.add_child(row_heading)
			var name_label := Label.new()
			name_label.text = str(recruit.get("name", recruit_id.to_upper()))
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_label.add_theme_font_size_override("font_size", 21)
			name_label.add_theme_color_override("font_color", Color("#e3e9f2"))
			row_heading.add_child(name_label)
			var recruit_button := Button.new()
			recruit_button.name = "Recruit_%s" % recruit_id
			recruit_button.custom_minimum_size = Vector2(300, 42)
			recruit_button.add_theme_font_size_override("font_size", 20)
			recruit_button.add_theme_stylebox_override("normal", _button_style(Color("#172b2a"), Color("#3f8d84")))
			recruit_button.add_theme_stylebox_override("hover", _button_style(Color("#1e3c38"), Color("#61e6d3")))
			recruit_button.add_theme_color_override("font_color", Color("#c8fff0"))
			recruit_button.pressed.connect(_purchase_recruit.bind(recruit_id))
			row_heading.add_child(recruit_button)
			var details_label := Label.new()
			details_label.name = "Details_%s" % recruit_id
			details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			details_label.add_theme_font_size_override("font_size", 16)
			details_label.add_theme_color_override("font_color", Color("#aeb9c8"))
			row.add_child(details_label)
			var preference_row := HBoxContainer.new()
			preference_row.name = "FormationPreference_%s" % recruit_id
			preference_row.add_theme_constant_override("separation", 8)
			row.add_child(preference_row)
			var position_selector := OptionButton.new()
			position_selector.name = "FormationPosition_%s" % recruit_id
			position_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for position in FORMATION_PREFERENCE_SCRIPT.POSITION_VALUES:
				position_selector.add_item("No position preference" if str(position).is_empty() else str(position))
			position_selector.item_selected.connect(_on_formation_preference_changed.bind(recruit_id, position_selector, true))
			preference_row.add_child(position_selector)
			var role_selector := OptionButton.new()
			role_selector.name = "FormationRole_%s" % recruit_id
			role_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for role in FORMATION_PREFERENCE_SCRIPT.ROLE_VALUES:
				role_selector.add_item("No role preference" if str(role).is_empty() else str(role))
			role_selector.item_selected.connect(_on_formation_preference_changed.bind(recruit_id, role_selector, false))
			preference_row.add_child(role_selector)
			formation_position_controls[recruit_id] = position_selector
			formation_role_controls[recruit_id] = role_selector
			recruitment_rows[recruit_id] = {"recruit": recruit.duplicate(true), "details_label": details_label, "recruit_button": recruit_button}
	var notice := Label.new()
	notice.name = "RecruitmentStatus"
	notice.add_theme_font_size_override("font_size", 17)
	notice.text = "Trial prices only • no random draws • ownership persists. Combat deployment remains separate."
	notice.autowrap_mode = TextServer.AUTOWRAP_OFF
	notice.add_theme_color_override("font_color", Color("#e9a8b7"))
	content.add_child(notice)
	recruitment_status_label = notice
	var close_row := HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(close_row)
	var close_button := Button.new()
	close_button.name = "CloseRecruitment"
	close_button.text = "CLOSE"
	close_button.add_theme_font_size_override("font_size", 19)
	close_button.pressed.connect(func(): recruitment_dialog.visible = false)
	close_button.add_theme_stylebox_override("normal", _button_style(Color("#151f2c"), Color("#34586b")))
	close_button.add_theme_stylebox_override("hover", _button_style(Color("#1c3441"), Color("#61e6d3")))
	close_button.add_theme_color_override("font_color", Color("#dbe8ef"))
	close_row.add_child(close_button)
	_refresh_recruitment_dialog()


func _refresh_recruitment_dialog() -> void:
	if not is_instance_valid(recruitment_balance_label) or not is_instance_valid(recruitment_roster_list):
		return
	if not recruitment_config_error.is_empty():
		recruitment_balance_label.text = "RECRUITMENT UNAVAILABLE: %s" % recruitment_config_error
		for row_value in recruitment_rows.values():
			var row: Dictionary = row_value
			var recruit_button: Button = row["recruit_button"]
			recruit_button.text = "UNAVAILABLE"
			recruit_button.disabled = true
		return
	_refresh_lineup_controls()
	_refresh_formation_preference_controls()
	var state: Dictionary = director.snapshot()
	var owned_ids: Array = permanent_state.get("unlocks", [])
	var owned_count := 0
	for recruit_id in RECRUITMENT_SERVICE_SCRIPT.EXPECTED_RECRUIT_IDS:
		if owned_ids.has(recruit_id):
			owned_count += 1
	recruitment_balance_label.text = "CREDITS: %d  •  FOUNDING RECRUITS: %d/12 OWNED" % [int(state["credits"]), owned_count]
	for recruit_id in RECRUITMENT_SERVICE_SCRIPT.EXPECTED_RECRUIT_IDS:
		var row_value: Variant = recruitment_rows.get(recruit_id, null)
		if typeof(row_value) != TYPE_DICTIONARY:
			continue
		var row: Dictionary = row_value
		var details_label: Label = row["details_label"]
		var recruit_button: Button = row["recruit_button"]
		var evaluation: Dictionary = RECRUITMENT_SERVICE_SCRIPT.evaluate_recruitment(permanent_state, {"credits": int(state["credits"])}, recruitment_catalog, recruitment_profile, recruit_id)
		if not bool(evaluation.get("ok", false)):
			details_label.text = "CATALOG ERROR"
			recruit_button.text = "UNAVAILABLE"
			recruit_button.disabled = true
			continue
		var recruit: Dictionary = evaluation["recruit"]
		var cost := int(evaluation["cost"])
		details_label.text = "%s  •  %s  •  %s  •  TRIAL PRICE: %s CREDITS" % [str(recruit["rarity"]).to_upper(), str(recruit["faction"]), str(recruit["roles"]), String.num_int64(cost)]
		if bool(evaluation["owned"]):
			recruit_button.text = "OWNED"
			recruit_button.disabled = true
		elif bool(evaluation["affordable"]):
			recruit_button.text = "RECRUIT // %s CREDITS" % String.num_int64(cost)
			recruit_button.disabled = false
		else:
			recruit_button.text = "NEED %d CREDITS" % cost
			recruit_button.disabled = true


func _refresh_formation_preference_controls() -> void:
	var preferences: Dictionary = permanent_state.get("formation_preferences", {})
	for recruit_id in formation_position_controls:
		var saved: Dictionary = preferences.get(recruit_id, {})
		var position_selector: OptionButton = formation_position_controls[recruit_id]
		var role_selector: OptionButton = formation_role_controls[recruit_id]
		position_selector.set_block_signals(true)
		role_selector.set_block_signals(true)
		position_selector.select(maxi(0, FORMATION_PREFERENCE_SCRIPT.POSITION_VALUES.find(str(saved.get("position", "")))))
		role_selector.select(maxi(0, FORMATION_PREFERENCE_SCRIPT.ROLE_VALUES.find(str(saved.get("role", "")))))
		position_selector.set_block_signals(false)
		role_selector.set_block_signals(false)


func _on_formation_preference_changed(_item_index: int, recruit_id: String, selector: OptionButton, is_position: bool) -> void:
	if _has_unloaded_existing_save():
		feedback_label.text = "Existing save found. Load it before changing formation preferences; no save was overwritten."
		_refresh_formation_preference_controls()
		return
	var position := str(FORMATION_PREFERENCE_SCRIPT.POSITION_VALUES[selector.selected]) if is_position else str(permanent_state.get("formation_preferences", {}).get(recruit_id, {}).get("position", ""))
	var role := str(FORMATION_PREFERENCE_SCRIPT.ROLE_VALUES[selector.selected]) if not is_position else str(permanent_state.get("formation_preferences", {}).get(recruit_id, {}).get("role", ""))
	var update: Dictionary = FORMATION_PREFERENCE_SCRIPT.set_preference(permanent_state, recruit_id, position, role)
	if not bool(update.get("ok", false)):
		feedback_label.text = str(update.get("error", "Formation preference was rejected."))
		_refresh_formation_preference_controls()
		return
	var candidate_permanent: Dictionary = update["permanent"]
	var run := _stamp_offline_claim_time(_make_run_snapshot(director.snapshot()))
	var save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, run, settings_state, save_path)
	if save_error != OK:
		feedback_label.text = "Formation preference save failed (%d); the prior preference remains active." % save_error
		_refresh_formation_preference_controls()
		return
	permanent_state = candidate_permanent
	loaded_save_path = save_path
	feedback_label.text = "Formation preference saved. Selectors do not alter combat movement in this prototype."
	_refresh_formation_preference_controls()


func _refresh_lineup_controls() -> void:
	var can_change := director.phase != "combat"
	var owned_ids: Array = permanent_state.get("unlocks", [])
	for slot_index in range(mini(lineup_controls.size(), 6)):
		var selector := lineup_controls[slot_index]
		selector.set_block_signals(true)
		selector.clear()
		selector.add_item("VACANT")
		selector.set_item_metadata(0, "")
		for recruit_id in RECRUITMENT_SERVICE_SCRIPT.EXPECTED_RECRUIT_IDS:
			if owned_ids.has(recruit_id):
				selector.add_item(str(recruit_id).to_upper())
				selector.set_item_metadata(selector.item_count - 1, recruit_id)
		var selected_index := 0
		if slot_index < active_lineup.size():
			for item_index in range(selector.item_count):
				if str(selector.get_item_metadata(item_index)) == active_lineup[slot_index]:
					selected_index = item_index
					break
		selector.select(selected_index)
		selector.disabled = not can_change
		selector.tooltip_text = "Lineup changes are locked during combat." if not can_change else "Choose an owned recruit or leave this slot vacant."
		selector.set_block_signals(false)


func _on_lineup_option_changed(item_index: int, slot_index: int, selector: OptionButton) -> void:
	if slot_index < 0 or slot_index >= 6 or director.phase == "combat":
		_refresh_lineup_controls()
		return
	var recruit_id := str(selector.get_item_metadata(item_index))
	_change_lineup_slot(slot_index, recruit_id)


func _change_lineup_slot(slot_index: int, recruit_id: String) -> void:
	if _has_unloaded_existing_save():
		feedback_label.text = "Existing save found. Load it before changing the lineup; no save was overwritten."
		_refresh_lineup_controls()
		return
	var owned_ids: Array = permanent_state.get("unlocks", [])
	var run := _make_run_snapshot(director.snapshot())
	var transaction: Dictionary = ROSTER_STATE_SCRIPT.swap_lineup_slot(run, owned_ids, slot_index, recruit_id, director.phase == "combat")
	if not bool(transaction.get("ok", false)):
		feedback_label.text = str(transaction.get("error", "Lineup change was rejected."))
		_refresh_lineup_controls()
		return
	var candidate_run: Dictionary = transaction["run"]
	var candidate_lineup: Array[String] = []
	for id in candidate_run["active_lineup"]:
		candidate_lineup.append(str(id))
	var save_error: Error = SAVE_SCRIPT.save_game(permanent_state, candidate_run, settings_state, save_path)
	if save_error != OK:
		feedback_label.text = "Lineup save failed (%d); the active squad was not changed." % save_error
		_refresh_lineup_controls()
		return
	active_lineup = candidate_lineup
	recruit_run_states = candidate_run.get("recruits", {}).duplicate(true)
	if not director.set_active_lineup(active_lineup, owned_ids, recruit_run_states):
		feedback_label.text = "The saved lineup could not be applied safely; Load will restore it."
	else:
		feedback_label.text = "Lineup saved. Vacant slots remain empty; reserves retain their HP."
	loaded_save_path = save_path
	_refresh()


func _purchase_recruit(recruit_id: String) -> void:
	if _has_unloaded_existing_save():
		feedback_label.text = "Existing save found. Load it before recruiting; no save was overwritten."
		return
	var live_state: Dictionary = director.snapshot()
	var run := _stamp_offline_claim_time(_make_run_snapshot(live_state))
	var transaction: Dictionary = RECRUITMENT_SERVICE_SCRIPT.purchase_recruit(permanent_state, run, recruitment_catalog, recruitment_profile, recruit_id)
	if not bool(transaction.get("ok", false)):
		feedback_label.text = str(transaction.get("error", "Recruitment could not be completed."))
		_refresh_recruitment_dialog()
		return
	var candidate_permanent: Dictionary = transaction["permanent"]
	var candidate_run: Dictionary = transaction["run"]
	var candidate_lineup: Array = candidate_run.get("active_lineup", active_lineup).duplicate(true)
	var fill_result: Dictionary = ROSTER_STATE_SCRIPT.auto_fill_first_open(candidate_lineup, candidate_permanent.get("unlocks", []), recruit_id)
	if not bool(fill_result.get("ok", false)):
		feedback_label.text = str(fill_result.get("error", "Recruit deployment could not be prepared."))
		return
	candidate_run["active_lineup"] = fill_result["lineup"]
	var recruit_records := ROSTER_STATE_SCRIPT.ensure_owned_recruit_records(candidate_run, candidate_permanent.get("unlocks", []), _max_hp_by_recruit(candidate_permanent.get("unlocks", [])))
	if not bool(recruit_records.get("ok", false)):
		feedback_label.text = "Recruitment state could not be prepared: %s" % str(recruit_records.get("error", "invalid recruit state"))
		return
	candidate_run = recruit_records["run"]
	var save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, candidate_run, settings_state, save_path)
	if save_error != OK:
		feedback_label.text = "Recruitment save failed (%d); credits and roster were not changed." % save_error
		return
	permanent_state = candidate_permanent
	recruit_run_states = candidate_run.get("recruits", {}).duplicate(true)
	active_lineup.clear()
	for id in candidate_run["active_lineup"]:
		active_lineup.append(str(id))
	director.economy.credits = int(candidate_run["credits"])
	if not director.set_active_lineup(active_lineup, candidate_permanent.get("unlocks", []), recruit_run_states):
		feedback_label.text = "Recruitment saved, but the saved lineup could not be applied. Load will restore it."
		loaded_save_path = save_path
		return
	loaded_save_path = save_path
	feedback_label.text = "%s recruited. %s" % [recruit_id.to_upper(), "Deployed at the next encounter." if bool(fill_result.get("deployed", false)) else "Six slots are filled; recruit is in reserve."]
	_refresh()


func _build_evolution_dialog(root: Control) -> void:
	evolution_dialog = Control.new()
	evolution_dialog.name = "EvolutionOverlay"
	evolution_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	evolution_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	evolution_dialog.visible = false
	evolution_dialog.z_index = 20
	root.add_child(evolution_dialog)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.015, 0.025, 0.045, 0.84)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	evolution_dialog.add_child(dimmer)
	var centering := CenterContainer.new()
	centering.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centering.mouse_filter = Control.MOUSE_FILTER_IGNORE
	evolution_dialog.add_child(centering)
	var panel := PanelContainer.new()
	panel.name = "EvolutionPanel"
	var viewport_size := root.get_viewport_rect().size
	panel.custom_minimum_size = viewport_size * Vector2(0.92, 0.90)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0a111b")
	panel_style.border_color = Color("#344b61")
	panel_style.set_border_width_all(2)
	panel_style.border_width_top = 4
	panel_style.border_color = Color("#8d56ad")
	panel_style.set_corner_radius_all(5)
	panel_style.content_margin_left = 26
	panel_style.content_margin_right = 26
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	centering.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var title := Label.new()
	title.text = "ROSTER EVOLUTION // PER-RECRUIT PROGRESSION"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#edf2f8"))
	content.add_child(title)
	evolution_balance_label = Label.new()
	evolution_balance_label.name = "EvolutionBalance"
	evolution_balance_label.add_theme_font_size_override("font_size", 20)
	evolution_balance_label.add_theme_color_override("font_color", Color("#61e6d3"))
	content.add_child(evolution_balance_label)
	var scroll := ScrollContainer.new()
	scroll.name = "EvolutionRosterScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	evolution_roster_list = VBoxContainer.new()
	evolution_roster_list.name = "EvolutionRosterList"
	evolution_roster_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	evolution_roster_list.add_theme_constant_override("separation", 8)
	scroll.add_child(evolution_roster_list)
	evolution_rows.clear()
	for recruit_value in EVOLUTION_SCRIPT.APPROVED_RECRUIT_IDS:
		var recruit_id := str(recruit_value)
		var row := VBoxContainer.new()
		row.name = "EvolutionRow_%s" % recruit_id
		row.custom_minimum_size = Vector2(0, 60)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 3)
		evolution_roster_list.add_child(row)
		var row_heading := HBoxContainer.new()
		row_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_heading.add_theme_constant_override("separation", 12)
		row.add_child(row_heading)
		var name_label := Label.new()
		name_label.text = recruit_id.to_upper()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 21)
		name_label.add_theme_color_override("font_color", Color("#e3e9f2"))
		row_heading.add_child(name_label)
		var progress_label := Label.new()
		progress_label.name = "Progress_%s" % recruit_id
		progress_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		progress_label.add_theme_font_size_override("font_size", 18)
		progress_label.add_theme_color_override("font_color", Color("#aeb9c8"))
		row.add_child(progress_label)
		var record_button := Button.new()
		record_button.name = "Record_%s" % recruit_id
		record_button.custom_minimum_size = Vector2(300, 42)
		record_button.add_theme_font_size_override("font_size", 19)
		record_button.add_theme_stylebox_override("normal", _button_style(Color("#241b2a"), Color("#8d56ad")))
		record_button.add_theme_stylebox_override("hover", _button_style(Color("#362344"), Color("#d58bff")))
		record_button.add_theme_color_override("font_color", Color("#eedbff"))
		record_button.pressed.connect(_evolve_recruit.bind(recruit_id))
		row_heading.add_child(record_button)
		evolution_rows[recruit_id] = {"progress_label": progress_label, "record_button": record_button}
	var notice := Label.new()
	notice.text = "Prototype feasibility gates only. Recording a tier does not add stat or art effects."
	notice.add_theme_font_size_override("font_size", 18)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", Color("#e9a8b7"))
	content.add_child(notice)
	var close_row := HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(close_row)
	var close_button := Button.new()
	close_button.text = "CLOSE"
	close_button.add_theme_font_size_override("font_size", 19)
	close_button.pressed.connect(func(): evolution_dialog.visible = false)
	close_button.add_theme_stylebox_override("normal", _button_style(Color("#151f2c"), Color("#34586b")))
	close_button.add_theme_stylebox_override("hover", _button_style(Color("#1c3441"), Color("#61e6d3")))
	close_button.add_theme_color_override("font_color", Color("#dbe8ef"))
	close_row.add_child(close_button)
	_refresh_evolution_dialog()


func _refresh_evolution_dialog() -> void:
	if not is_instance_valid(evolution_balance_label) or not is_instance_valid(evolution_roster_list):
		return
	var available := int(permanent_state.get("evolution_materials", {}).get("evolution_data", 0))
	var high_water := int(permanent_state.get("highest_wave_ever", 0))
	evolution_balance_label.text = "SHARED EVOLUTION DATA: %d  •  HIGHEST WAVE CLEARED: %d" % [available, high_water]
	for recruit_value in EVOLUTION_SCRIPT.APPROVED_RECRUIT_IDS:
		var recruit_id := str(recruit_value)
		var row: Dictionary = evolution_rows.get(recruit_id, {})
		if row.is_empty():
			continue
		var progress_label: Label = row["progress_label"]
		var record_button: Button = row["record_button"]
		var evaluation: Dictionary = EVOLUTION_SCRIPT.evaluate_next_tier(permanent_state, recruit_id, progression_profile)
		if not bool(evaluation.get("ok", false)):
			progress_label.text = "PROFILE ERROR"
			record_button.text = "UNAVAILABLE"
			record_button.disabled = true
			continue
		if bool(evaluation.get("complete", false)):
			progress_label.text = "REQUIEM FORM RECORDED"
			record_button.text = "COMPLETE"
			record_button.disabled = true
			continue
		var requirement: Dictionary = evaluation["requirement"]
		var required_wave := int(requirement.get("minimum_cleared_wave", 0))
		var cost := int(requirement.get("material_costs", {}).get("evolution_data", 0))
		var eligible := bool(evaluation.get("eligible", false))
		var progress_state := "READY" if eligible else "LOCKED"
		progress_label.text = "%s → %s  •  %s: WAVE %d + DATA %d" % [str(evaluation["current_tier"]), str(evaluation["next_tier"]), progress_state, required_wave, cost]
		record_button.text = "RECORD %s" % str(evaluation["next_tier"]).to_upper() if eligible else "LOCKED"
		record_button.disabled = not eligible


func _evolve_breaker() -> void:
	_evolve_recruit("breaker")


func _evolve_recruit(recruit_id: String) -> void:
	if _has_unloaded_existing_save():
		feedback_label.text = "Existing save found. Load it before recording Evolution; no save was overwritten."
		return
	var live_state: Dictionary = director.snapshot()
	var state_for_gate: Dictionary = permanent_state.duplicate(true)
	state_for_gate["highest_wave_ever"] = maxi(int(state_for_gate.get("highest_wave_ever", 0)), int(live_state["highest_cleared_wave"]))
	var result: Dictionary = EVOLUTION_SCRIPT.purchase_next_tier(state_for_gate, recruit_id, progression_profile)
	if not bool(result.get("ok", false)):
		feedback_label.text = str(result.get("error", "Evolution could not be recorded."))
		_refresh()
		return
	var run := _stamp_offline_claim_time(_make_run_snapshot(live_state))
	var candidate_permanent: Dictionary = result["permanent"]
	var save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, run, settings_state, save_path)
	if save_error != OK:
		feedback_label.text = "Evolution save failed (%d); no materials were consumed." % save_error
		_refresh()
		return
	permanent_state = candidate_permanent
	loaded_save_path = save_path
	feedback_label.text = "%s: %s progression recorded. Prototype stat and art effects are not implemented yet." % [recruit_id.to_upper(), str(result["unlocked_tier"])]
	_refresh()


func _on_director_state_changed() -> void:
	if is_instance_valid(director):
		permanent_state["highest_wave_ever"] = maxi(int(permanent_state.get("highest_wave_ever", 0)), int(director.highest_cleared_wave))
		var state: Dictionary = director.snapshot()
		for ally in state.get("allies", []):
			var recruit_id := str(ally.get("id", ""))
			if recruit_id in RECRUITMENT_SERVICE_SCRIPT.EXPECTED_RECRUIT_IDS:
				var recruit_state: Dictionary = recruit_run_states.get(recruit_id, {"level": 1})
				recruit_state["hp"] = float(ally.get("hp", 0.0))
				recruit_run_states[recruit_id] = recruit_state
	if is_instance_valid(director) and is_instance_valid(environment_director):
		environment_director.apply_wave(int(director.snapshot()["wave"]))
	_refresh()


func _on_event(message: String) -> void:
	if is_instance_valid(event_label):
		event_label.text = message


func _on_stalemate_arrival(holding_wave: int, retry_wave: int) -> void:
	var cue := "STALEMATE RETREAT  •  holding wave %d  •  retry wave %d after recovery" % [holding_wave, retry_wave]
	if is_instance_valid(event_label):
		event_label.text = cue
	if is_instance_valid(feedback_label):
		feedback_label.text = "Stalemate trial cue: squad recovered at holding wave %d. The next uncleared wave will retry after the holding-wave clear." % holding_wave


func _on_wave_cleared(wave_number: int, _credit_reward: int, run_high_water: int, boss_id: String) -> void:
	var candidate_permanent: Dictionary = permanent_state.duplicate(true)
	candidate_permanent["highest_wave_ever"] = maxi(int(candidate_permanent.get("highest_wave_ever", 0)), run_high_water)
	var reward_policy: Variant = progression_profile.get("evolution_material_policy", null)
	if typeof(reward_policy) != TYPE_DICTIONARY:
		feedback_label.text = "Evolution material rewards are unavailable: profile policy is missing."
		return
	var reward_result: Dictionary = MATERIAL_REWARD_SCRIPT.apply_wave_clear(candidate_permanent, wave_number, boss_id, reward_policy)
	if not bool(reward_result.get("ok", false)):
		feedback_label.text = "Material reward was not applied: %s" % str(reward_result.get("error", "invalid reward rules"))
		return
	candidate_permanent = reward_result["permanent"]
	var state: Dictionary = director.snapshot()
	var run: Dictionary = _make_run_snapshot(state)
	run = _stamp_offline_claim_time(run)
	# Keep the completed wave/reward playable in memory even if disk fails; the
	# feedback then directs the player to Save. SaveService preserves prior data.
	permanent_state = candidate_permanent
	var reward_text := "+%d Evolution Data" % int(reward_result["total_amount"])
	var claims: Array = reward_result["claimed_ids"]
	if not claims.is_empty():
		reward_text += " (first clear: %s)" % ", ".join(PackedStringArray(claims))
	if _has_unloaded_existing_save():
		reward_text += " • existing save kept; Load or press Save before autosaving"
		feedback_label.text = reward_text
		_refresh()
		return
	var save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, run, settings_state, save_path)
	if save_error == OK:
		loaded_save_path = save_path
		reward_text += " • wave saved"
	else:
		reward_text += " • autosave failed (%d); press Save to persist" % save_error
	feedback_label.text = reward_text
	_refresh()


func _show_research_dialog() -> void:
	if not is_instance_valid(research_dialog):
		return
	if is_instance_valid(recruitment_dialog):
		recruitment_dialog.visible = false
	if is_instance_valid(evolution_dialog):
		evolution_dialog.visible = false
	if is_instance_valid(research_balance_label):
		research_balance_label.text = "SPENDABLE NETWORK INFLUENCE: %d  •  Purchases remain after System Reboot." % int(permanent_state.get("spendable_influence", 0))
	research_dialog.visible = true


func _build_research_dialog(root: Control) -> void:
	research_dialog = Control.new()
	research_dialog.name = "ResearchOverlay"
	research_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	research_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	research_dialog.visible = false
	research_dialog.z_index = 20
	root.add_child(research_dialog)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.015, 0.025, 0.045, 0.84)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	research_dialog.add_child(dimmer)
	var centering := CenterContainer.new()
	centering.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centering.mouse_filter = Control.MOUSE_FILTER_IGNORE
	research_dialog.add_child(centering)
	research_panel = PanelContainer.new()
	research_panel.name = "ResearchPanel"
	research_panel.custom_minimum_size = Vector2(680, 360)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0a111b")
	panel_style.border_color = Color("#344b61")
	panel_style.set_border_width_all(2)
	panel_style.border_width_top = 4
	panel_style.border_color = Color("#c23d62")
	panel_style.set_corner_radius_all(5)
	panel_style.content_margin_left = 22
	panel_style.content_margin_right = 22
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 16
	research_panel.add_theme_stylebox_override("panel", panel_style)
	centering.add_child(research_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	research_panel.add_child(content)
	var title := Label.new()
	title.text = "NETWORK RESEARCH // PERMANENT UPGRADES"
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color("#edf2f8"))
	content.add_child(title)
	research_balance_label = Label.new()
	research_balance_label.name = "ResearchBalance"
	research_balance_label.add_theme_color_override("font_color", Color("#61e6d3"))
	content.add_child(research_balance_label)
	var branch_list := VBoxContainer.new()
	branch_list.name = "ResearchBranchList"
	branch_list.add_theme_constant_override("separation", 7)
	content.add_child(branch_list)
	var branches_value: Variant = research_catalog.get("branches", [])
	if typeof(branches_value) == TYPE_ARRAY:
		for branch_value in branches_value:
			if typeof(branch_value) != TYPE_DICTIONARY:
				continue
			var branch: Dictionary = branch_value
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			branch_list.add_child(row)
			var accent := ColorRect.new()
			accent.custom_minimum_size = Vector2(3, 28)
			accent.color = Color("#c23d62") if branch_list.get_child_count() % 2 == 1 else Color("#61e6d3")
			row.add_child(accent)
			var branch_name := Label.new()
			branch_name.text = str(branch.get("display_name", branch.get("id", "Research branch")))
			branch_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			branch_name.add_theme_color_override("font_color", Color("#e3e9f2"))
			row.add_child(branch_name)
			var nodes_value: Variant = branch.get("nodes", [])
			var node_count: int = nodes_value.size() if typeof(nodes_value) == TYPE_ARRAY else 0
			var branch_state := Label.new()
			branch_state.text = "%d NODES" % node_count if node_count > 0 else "AWAITING DESIGN"
			branch_state.add_theme_font_size_override("font_size", 12)
			branch_state.add_theme_color_override("font_color", Color("#9aa7b8"))
			row.add_child(branch_state)
	var notice := Label.new()
	notice.name = "ResearchStatus"
	notice.text = "Node costs and effects are pending approval. This preview spends no Influence."
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", Color("#e9a8b7"))
	content.add_child(notice)
	var close_row := HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(close_row)
	var close_button := Button.new()
	close_button.text = "CLOSE"
	close_button.pressed.connect(func(): research_dialog.visible = false)
	close_button.add_theme_stylebox_override("normal", _button_style(Color("#151f2c"), Color("#34586b")))
	close_button.add_theme_stylebox_override("hover", _button_style(Color("#1c3441"), Color("#61e6d3")))
	close_button.add_theme_color_override("font_color", Color("#dbe8ef"))
	close_row.add_child(close_button)


func _research_dialog_text() -> String:
	var lines := PackedStringArray(["Permanent purchases use spendable Network Influence.", ""])
	var branches_value: Variant = research_catalog.get("branches", [])
	if typeof(branches_value) != TYPE_ARRAY:
		return "Research catalog is unavailable. No purchases can be made."
	for branch_value in branches_value:
		if typeof(branch_value) != TYPE_DICTIONARY:
			continue
		var branch: Dictionary = branch_value
		var branch_name := str(branch.get("display_name", branch.get("id", "Research branch")))
		var nodes_value: Variant = branch.get("nodes", [])
		var node_count: int = nodes_value.size() if typeof(nodes_value) == TYPE_ARRAY else 0
		lines.append("%s — %s" % [branch_name, "%d configured node(s)" % node_count if node_count > 0 else "node details pending approval"])
	lines.append("")
	lines.append("Research node costs and effects are not set. No Influence is spent in this framework preview.")
	return "\n".join(lines)


func _upgrade(count: int) -> void:
	if _has_unloaded_existing_save():
		feedback_label.text = "Existing save found. Load it before upgrading; no save was overwritten."
		return
	var transaction: Dictionary = director.preview_upgrade_recruit(count)
	var bought := int(transaction.get("bought", 0))
	if bought <= 0:
		feedback_label.text = "Not enough credits."
		_refresh()
		return
	var live_state: Dictionary = director.snapshot()
	var candidate_run := _make_run_snapshot(live_state)
	candidate_run["credits"] = int(transaction["credits"])
	candidate_run["recruits"]["breaker"]["level"] = int(transaction["recruit_level"])
	candidate_run["recruits"]["breaker"]["hp"] = float(transaction["breaker_hp"])
	candidate_run = _stamp_offline_claim_time(candidate_run)
	var candidate_permanent := permanent_state.duplicate(true)
	candidate_permanent["highest_wave_ever"] = maxi(int(candidate_permanent.get("highest_wave_ever", 0)), int(live_state["highest_cleared_wave"]))
	var save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, candidate_run, settings_state, save_path)
	if save_error != OK:
		feedback_label.text = _save_failure_feedback("Upgrade", save_error) + " Recruit level and credits were not changed."
		return
	if not director.apply_upgrade_recruit(transaction):
		feedback_label.text = "Upgrade could not be applied after saving; load the saved run to restore its state."
		return
	permanent_state = candidate_permanent
	loaded_save_path = save_path
	feedback_label.text = "Purchased %d level(s) and saved." % bought
	_refresh()


func _save() -> void:
	_save_current_session(false)


func _request_save_reset_confirmation() -> void:
	if is_instance_valid(reset_save_confirmation):
		reset_save_confirmation.popup_centered()


func _perform_confirmed_save_reset() -> void:	
	_save_current_session(true)


func _save_current_session(confirmed_reset: bool) -> void:
	var state := director.snapshot()
	permanent_state["highest_wave_ever"] = maxi(int(permanent_state.get("highest_wave_ever", 0)), int(state["highest_cleared_wave"]))
	var run: Dictionary = _stamp_offline_claim_time(_make_run_snapshot(state))
	var error_code: Error = SAVE_SCRIPT.save_game_after_confirmed_reset(permanent_state, run, settings_state, save_path, true) if confirmed_reset else SAVE_SCRIPT.save_game(permanent_state, run, settings_state, save_path)
	if error_code == OK:
		loaded_save_path = save_path
	feedback_label.text = "Saved locally." if error_code == OK else _save_failure_feedback("Save", error_code)


func _save_failure_feedback(action: String, error_code: Error) -> String:
	if error_code == SAVE_SCRIPT.SAVE_PROTECTED_ERROR:
		return "%s blocked: incompatible or unrecoverable save data is protected. Use Reset Save only after confirming replacement." % action
	return "%s failed (error %d)." % [action, error_code]


func _load() -> void:
	var result: Dictionary = SAVE_SCRIPT.load_game(save_path)
	if not bool(result.get("ok", false)):
		feedback_label.text = str(result.get("error", "Load failed."))
		return
	var save_data: Dictionary = result["data"]
	var candidate_permanent: Dictionary = save_data["permanent"].duplicate(true)
	if recruitment_config_error.is_empty():
		candidate_permanent = RECRUITMENT_SERVICE_SCRIPT.ensure_starting_recruits(candidate_permanent, recruitment_profile)
	var candidate_settings: Dictionary = save_data["settings"].duplicate(true)
	var saved_run: Dictionary = save_data["run"].duplicate(true)
	candidate_permanent["highest_wave_ever"] = maxi(int(candidate_permanent.get("highest_wave_ever", 0)), int(saved_run.get("highest_cleared_wave", 0)))
	var owned_ids: Array = candidate_permanent.get("unlocks", [])
	var saved_breaker_state: Dictionary = saved_run.get("recruits", {}).get("breaker", {})
	var saved_breaker_level := int(saved_breaker_state.get("level", 1))
	var roster_state_result := ROSTER_STATE_SCRIPT.ensure_owned_recruit_records(saved_run, owned_ids, _max_hp_by_recruit(owned_ids, saved_breaker_level))
	if not bool(roster_state_result.get("ok", false)):
		feedback_label.text = "Load stopped: recruit HP state could not be prepared safely. %s" % str(roster_state_result.get("error", "invalid roster state"))
		return
	var run: Dictionary = roster_state_result["run"]
	var loaded_legacy_placeholder_hp: Array[float] = []
	var legacy_hp_value: Variant = run.get("legacy_placeholder_squad_hp", [])
	if typeof(legacy_hp_value) == TYPE_ARRAY and legacy_hp_value.size() == 5:
		for hp in legacy_hp_value:
			loaded_legacy_placeholder_hp.append(float(hp))
	candidate_permanent["formation_preferences"] = candidate_permanent.get("formation_preferences", {})
	var lineup_was_missing := not run.has("active_lineup")
	if lineup_was_missing:
		var default_lineup := ROSTER_STATE_SCRIPT.build_default_lineup(owned_ids)
		run["active_lineup"] = default_lineup
	var lineup_validation := ROSTER_STATE_SCRIPT.validate_active_lineup(run.get("active_lineup", []), owned_ids)
	if not bool(lineup_validation.get("ok", false)):
		feedback_label.text = "Load stopped: active lineup is invalid. %s" % str(lineup_validation.get("error", "invalid lineup"))
		return
	var candidate_active_lineup: Array[String] = []
	for recruit_id in lineup_validation["lineup"]:
		candidate_active_lineup.append(str(recruit_id))
	var formation_preferences_error := FORMATION_PREFERENCE_SCRIPT.validate(candidate_permanent["formation_preferences"])
	if not formation_preferences_error.is_empty():
		feedback_label.text = "Load stopped: saved formation preferences are invalid. %s" % formation_preferences_error
		return
	var recruit_records_changed := not SAVE_SCRIPT._values_match(saved_run.get("recruits", {}), run.get("recruits", {}))
	var loaded_from_recovery := bool(result.get("recovered_from_backup", false))
	var recovery_feedback := ""
	if loaded_from_recovery:
		recovery_feedback = " Recovery copy loaded. %s" % str(result.get("warning", "The primary save was not used."))
	var offline_feedback := ""
	var offline_result: Dictionary = OFFLINE_EARNINGS_SCRIPT.apply_claim(run, director.wave_def, progression_profile.get("offline_earnings", {}), int(Time.get_unix_time_from_system()))
	if not bool(offline_result.get("ok", false)):
		offline_feedback = " Offline credits were not applied: %s" % str(offline_result.get("error", "invalid offline policy"))
	elif bool(offline_result.get("should_save", false)):
		if loaded_from_recovery:
			offline_feedback = " Automatic offline claim was deferred; recovery did not write to the save set."
		else:
			var offline_run: Dictionary = offline_result["run"]
			var offline_roster_result := ROSTER_STATE_SCRIPT.ensure_owned_recruit_records(offline_run, owned_ids, _max_hp_by_recruit(owned_ids, saved_breaker_level))
			if not bool(offline_roster_result.get("ok", false)):
				feedback_label.text = "Offline claim save blocked: recruit HP state is invalid."
				return
			offline_run = offline_roster_result["run"]
			var offline_save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, offline_run, candidate_settings, save_path)
			if offline_save_error == OK:
				run = offline_run
				match str(offline_result.get("status", "")):
					"claimed":
						offline_feedback = " +%d offline credits from holding wave %d (8-hour cap; no waves advanced)." % [int(offline_result["credits_awarded"]), int(offline_result["holding_wave"])]
					"baseline_created":
						offline_feedback = " Offline credit tracking started; no earlier time was claimed."
					"clock_reset":
						offline_feedback = " Offline clock baseline reset; no credits were claimed."
			else:
				offline_feedback = " Offline claim save failed (%d); no offline credits were applied." % offline_save_error
	var permanent_state_changed := not SAVE_SCRIPT._values_match(save_data["permanent"], candidate_permanent)
	if not loaded_from_recovery and (recruit_records_changed or lineup_was_missing or permanent_state_changed or int(result.get("migrated_from_version", 0)) > 0) and not bool(offline_result.get("should_save", false)):
		var normalized_save_error: Error = SAVE_SCRIPT.save_game(candidate_permanent, run, candidate_settings, save_path)
		if normalized_save_error != OK:
			offline_feedback += " Recruit HP migration is active in memory; saving it failed (%d)." % normalized_save_error
	director.set_lifetime_influence(int(candidate_permanent.get("lifetime_influence", 0)))
	if not director.set_active_lineup(candidate_active_lineup, owned_ids, run.get("recruits", {}), true):
		feedback_label.text = "Load stopped: the validated lineup could not be applied safely."
		return
	var recruits: Dictionary = run.get("recruits", {})
	var breaker: Dictionary = recruits.get("breaker", {})
	director.load_run_state({
		"credits": run.get("credits", 0),
		"wave": run.get("wave", 1),
		"highest_cleared_wave": run.get("highest_cleared_wave", 0),
		"recruit_level": breaker.get("level", 1),
		"recruits": recruits,
		"active_lineup": run.get("active_lineup", []),
		"legacy_placeholder_squad_hp": run.get("legacy_placeholder_squad_hp", []),
		"squad_hp": run.get("squad_hp", [])
	})
	permanent_state = candidate_permanent
	recruit_run_states = run.get("recruits", {}).duplicate(true)
	active_lineup = candidate_active_lineup
	settings_state = candidate_settings
	legacy_placeholder_hp = loaded_legacy_placeholder_hp
	loaded_save_path = save_path
	feedback_label.text = "Loaded versioned local save. Permanent/run/settings sections are separate." + recovery_feedback + offline_feedback
	_refresh()


func _request_reboot_confirmation() -> void:
	if not is_instance_valid(reboot_confirmation) or not is_instance_valid(director):
		return
	var highest_cleared := int(director.snapshot()["highest_cleared_wave"])
	var required_wave := int(progression_profile.get("system_reboot", {}).get("first_eligibility_wave", 25))
	if highest_cleared < required_wave:
		feedback_label.text = "System Reboot requires a first clear of wave %d." % required_wave
		return
	reboot_confirmation.popup_centered()


func _perform_reboot() -> void:
	if not is_instance_valid(director):
		return
	if _has_unloaded_existing_save():
		feedback_label.text = "Existing save found. Load it before System Reboot; no save was overwritten."
		return
	var live_state := director.snapshot()
	permanent_state["highest_wave_ever"] = maxi(int(permanent_state.get("highest_wave_ever", 0)), int(live_state["highest_cleared_wave"]))
	var run := _stamp_offline_claim_time(_make_run_snapshot(live_state))
	var reboot_max_hp := _max_hp_by_recruit(permanent_state.get("unlocks", []), 1)
	var result: Dictionary = REBOOT_SCRIPT.apply_reboot(permanent_state, run, progression_profile, [], reboot_max_hp)
	if not bool(result.get("ok", false)):
		feedback_label.text = str(result.get("error", "System Reboot failed."))
		return
	var reset_permanent: Dictionary = result["permanent"]
	var reset_run: Dictionary = _stamp_offline_claim_time(result["run"])
	var save_error: Error = SAVE_SCRIPT.save_game(reset_permanent, reset_run, settings_state, save_path)
	if save_error != OK:
		feedback_label.text = "Reboot save failed (%d); live run was not reset." % save_error
		return
	permanent_state = reset_permanent.duplicate(true)
	recruit_run_states = reset_run.get("recruits", {}).duplicate(true)
	active_lineup.clear()
	for recruit_id in reset_run.get("active_lineup", []):
		active_lineup.append(str(recruit_id))
	var reset_legacy: Variant = reset_run.get("legacy_placeholder_squad_hp", [])
	legacy_placeholder_hp.clear()
	if typeof(reset_legacy) == TYPE_ARRAY:
		for hp in reset_legacy:
			legacy_placeholder_hp.append(float(hp))
	loaded_save_path = save_path
	director.set_lifetime_influence(int(permanent_state.get("lifetime_influence", 0)))
	if not director.set_active_lineup(active_lineup, permanent_state.get("unlocks", []), recruit_run_states, true):
		feedback_label.text = "Reboot was saved, but its lineup could not be applied safely. Load will restore the saved state."
		return
	var breaker: Dictionary = reset_run.get("recruits", {}).get("breaker", {})
	director.load_run_state({
		"credits": reset_run["credits"],
		"wave": reset_run["wave"],
		"highest_cleared_wave": reset_run["highest_cleared_wave"],
		"recruit_level": breaker.get("level", 1),
		"recruits": reset_run.get("recruits", {}),
		"active_lineup": reset_run.get("active_lineup", []),
		"legacy_placeholder_squad_hp": reset_run.get("legacy_placeholder_squad_hp", [])
	})
	feedback_label.text = "System Reboot complete. +%d Influence; permanent damage bonus +%.1f%%." % [int(result["award"]), director.lifetime_power_bonus_fraction * 100.0]
	_refresh()


func _snapshot_squad_hp(state: Dictionary) -> Array[float]:
	var hp_values: Array[float] = []
	for ally in state.get("allies", []):
		hp_values.append(float(ally.get("hp", 0.0)))
	return hp_values


func _snapshot_ally_ids(state: Dictionary) -> Array[String]:
	var ally_ids: Array[String] = []
	for ally in state.get("allies", []):
		ally_ids.append(str(ally.get("id", "")))
	return ally_ids


func _make_run_snapshot(state: Dictionary) -> Dictionary:
	var squad_hp := _snapshot_squad_hp(state)
	var run: Dictionary = director.economy.make_save_data(
		int(state["wave"]),
		int(state["highest_cleared_wave"]),
		squad_hp,
		recruit_run_states,
		_snapshot_ally_ids(state)
	)
	var recruits: Dictionary = run.get("recruits", {}).duplicate(true)
	for ally in state.get("allies", []):
		var recruit_id := str(ally.get("id", ""))
		if recruit_id not in RECRUITMENT_SERVICE_SCRIPT.EXPECTED_RECRUIT_IDS:
			continue
		var recruit_state: Dictionary = recruits.get(recruit_id, {"level": 1})
		recruit_state["hp"] = float(ally.get("hp", 0.0))
		recruits[recruit_id] = recruit_state
	run["recruits"] = recruits
	if not active_lineup.is_empty():
		run["active_lineup"] = active_lineup.duplicate()
	if legacy_placeholder_hp.size() == 5:
		run["legacy_placeholder_squad_hp"] = legacy_placeholder_hp.duplicate()
	var owned_ids: Array = permanent_state.get("unlocks", [])
	var normalized := ROSTER_STATE_SCRIPT.ensure_owned_recruit_records(run, owned_ids, _max_hp_by_recruit(owned_ids))
	if bool(normalized.get("ok", false)):
		run = normalized["run"]
	return run


func _max_hp_by_recruit(owned_ids: Array, breaker_level_override: int = -1) -> Dictionary:
	var maximums: Dictionary = {}
	var recruit_ids: Array = owned_ids.duplicate()
	if not recruit_ids.has("breaker"):
		recruit_ids.append("breaker")
	var placeholder_stats: Dictionary = director.squad_def.get("placeholder_combat_stats", {}) if is_instance_valid(director) else {}
	for id_value in recruit_ids:
		var recruit_id := str(id_value)
		if recruit_id == "breaker" and is_instance_valid(director):
			var level := breaker_level_override if breaker_level_override > 0 else director.economy.recruit_level
			maximums[recruit_id] = float(director.player_def.get("max_hp", 120.0)) + float(level - 1) * float(director.player_def.get("upgrade_hp_per_level", 9.0))
		else:
			maximums[recruit_id] = float(placeholder_stats.get("max_hp", 70.0))
	return maximums


func _stamp_offline_claim_time(run: Dictionary) -> Dictionary:
	var stamped_run := run.duplicate(true)
	stamped_run["offline_claim_unix"] = int(Time.get_unix_time_from_system())
	return stamped_run


func _has_unloaded_existing_save() -> bool:
	return loaded_save_path != save_path and FileAccess.file_exists(save_path)


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
