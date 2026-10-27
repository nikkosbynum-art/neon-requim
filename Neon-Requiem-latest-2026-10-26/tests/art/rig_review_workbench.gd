extends Node2D

## Interactive, quarantined review surface for existing Tier I rig candidates.
## It does not author character data or mark production gates as passed.

const MESH_RIG := preload("res://tests/art/founding_t1_profile_mesh_rig_candidate.gd")
const CIPHER_RIG := preload("res://tests/art/cipher_t1_reference_cutout_rig_candidate.gd")
const MANIFEST_RIG := preload("res://tests/art/manifest_character_rig_preview.gd")
const PLAN_PATH := "res://tools/art/rigging_prep_all_12.json"
const CHARACTER_IDS := [
	"BULWARK", "BREAKER", "CIPHER", "SPARK", "SPECTER", "IRONCLAD",
	"STITCH", "RECOIL", "ECHO", "VECTOR", "DEADLOCK", "GLITCH",
]
const MESH_IDS := [
	"bulwark", "spark", "specter", "ironclad", "stitch",
	"recoil", "echo", "vector", "deadlock", "glitch",
]
const MESH_POSES := ["neutral", "idle", "walk", "attack", "hit", "defeat"]
const CIPHER_POSES := ["neutral", "idle", "walk", "aim_fire", "hit", "defeat"]
const REVIEW_WIDTH := 920
const REVIEW_HEIGHT := 720
const REFERENCE_HEIGHT := 256.0
const GENERIC_SWEEP_MIN := -75.0
const GENERIC_SWEEP_MAX := 75.0

var preview: Node2D
var character_picker: OptionButton
var pose_picker: OptionButton
var bone_picker: OptionButton
var joint_slider: HSlider
var candidate_status: Label
var reference_view: TextureRect
var reference_alpha: HSlider
var part_list: VBoxContainer
var manifest_path_input: LineEdit
var sweep_context_input: LineEdit
var sweep_min_input: SpinBox
var sweep_max_input: SpinBox
var controls_layer: CanvasLayer
var active_bones: Dictionary = {}
var active_parts: Dictionary = {}
var active_poses: Array[String] = []
var current_character := ""
var show_pivots := true
var refreshing := false


func _ready() -> void:
	_build_interface()
	_build_ground_guide()
	_load_character("BULWARK")


func _process(_delta: float) -> void:
	if show_pivots:
		queue_redraw()


func _draw() -> void:
	draw_line(Vector2(18, 620), Vector2(REVIEW_WIDTH - 18, 620), Color(0.2, 0.82, 0.86, 0.65), 1.0)
	if not show_pivots:
		return
	for bone_value in active_bones.values():
		var bone := bone_value as Bone2D
		if is_instance_valid(bone):
			var point := to_local(bone.global_position)
			draw_circle(point, 4.0, Color(1.0, 0.28, 0.68, 0.95))
			draw_line(point + Vector2(-7, 0), point + Vector2(7, 0), Color.WHITE, 1.0)
			draw_line(point + Vector2(0, -7), point + Vector2(0, 7), Color.WHITE, 1.0)


func _build_ground_guide() -> void:
	queue_redraw()


func _build_interface() -> void:
	controls_layer = CanvasLayer.new()
	controls_layer.name = "WorkbenchControls"
	add_child(controls_layer)
	var panel := PanelContainer.new()
	panel.name = "WorkbenchPanel"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -350.0
	panel.offset_right = -12.0
	panel.offset_top = 12.0
	panel.offset_bottom = -12.0
	controls_layer.add_child(panel)

	var scroll := ScrollContainer.new()
	panel.add_child(scroll)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 310.0
	scroll.add_child(column)

	var title := Label.new()
	title.text = "RIG REVIEW WORKBENCH"
	title.add_theme_font_size_override("font_size", 19)
	column.add_child(title)
	var caveat := Label.new()
	caveat.text = "QUARANTINED CANDIDATES — review aid only"
	caveat.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(caveat)

	column.add_child(_section_label("Character"))
	character_picker = OptionButton.new()
	for character_id in CHARACTER_IDS:
		character_picker.add_item(character_id)
	character_picker.item_selected.connect(_on_character_selected)
	column.add_child(character_picker)
	var manifest_row := HBoxContainer.new()
	manifest_path_input = LineEdit.new()
	manifest_path_input.placeholder_text = "assets/.../character_art_manifest.json"
	manifest_path_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	manifest_row.add_child(manifest_path_input)
	var manifest_load_button := Button.new()
	manifest_load_button.text = "Load manifest"
	manifest_load_button.pressed.connect(_on_load_manifest_pressed)
	manifest_row.add_child(manifest_load_button)
	column.add_child(manifest_row)

	candidate_status = Label.new()
	candidate_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(candidate_status)

	column.add_child(_section_label("Pose preview"))
	pose_picker = OptionButton.new()
	pose_picker.item_selected.connect(_on_pose_selected)
	column.add_child(pose_picker)

	column.add_child(_section_label("Joint inspection"))
	bone_picker = OptionButton.new()
	bone_picker.item_selected.connect(_on_bone_selected)
	column.add_child(bone_picker)
	joint_slider = HSlider.new()
	joint_slider.min_value = -75.0
	joint_slider.max_value = 75.0
	joint_slider.step = 1.0
	joint_slider.value_changed.connect(_on_joint_value_changed)
	column.add_child(joint_slider)
	var joint_hint := Label.new()
	joint_hint.text = "Temporary rotation only. Fixed sweeps are diagnostics, not approved action ranges."
	joint_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(joint_hint)
	var sweep_context := Label.new()
	sweep_context.text = "Optional action/range source note for this single-joint diagnostic"
	sweep_context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(sweep_context)
	sweep_context_input = LineEdit.new()
	sweep_context_input.placeholder_text = "e.g. walk pose sheet; authored plan path"
	column.add_child(sweep_context_input)
	var range_row := HBoxContainer.new()
	sweep_min_input = SpinBox.new()
	sweep_min_input.min_value = -360.0
	sweep_min_input.max_value = 360.0
	sweep_min_input.step = 1.0
	sweep_min_input.value = GENERIC_SWEEP_MIN
	sweep_min_input.prefix = "Min ° "
	range_row.add_child(sweep_min_input)
	sweep_max_input = SpinBox.new()
	sweep_max_input.min_value = -360.0
	sweep_max_input.max_value = 360.0
	sweep_max_input.step = 1.0
	sweep_max_input.value = GENERIC_SWEEP_MAX
	sweep_max_input.prefix = "Max ° "
	range_row.add_child(sweep_max_input)
	column.add_child(range_row)

	var pivot_toggle := CheckButton.new()
	pivot_toggle.text = "Show pivot landmarks"
	pivot_toggle.button_pressed = true
	pivot_toggle.toggled.connect(_on_pivot_toggled)
	column.add_child(pivot_toggle)
	var reset_button := Button.new()
	reset_button.text = "Reset to neutral"
	reset_button.pressed.connect(_reset_pose)
	column.add_child(reset_button)
	var capture_button := Button.new()
	capture_button.text = "Capture six-pose review sheet"
	capture_button.pressed.connect(_capture_pose_sheet)
	column.add_child(capture_button)
	var sweep_button := Button.new()
	sweep_button.text = "Capture selected-joint diagnostic"
	sweep_button.pressed.connect(_capture_joint_sweep)
	column.add_child(sweep_button)

	column.add_child(_section_label("Visible parts"))
	var part_scroll := ScrollContainer.new()
	part_scroll.custom_minimum_size = Vector2(300, 110)
	column.add_child(part_scroll)
	part_list = VBoxContainer.new()
	part_scroll.add_child(part_list)

	column.add_child(_section_label("Approved anatomy reference"))
	reference_view = TextureRect.new()
	reference_view.custom_minimum_size = Vector2(300, 190)
	reference_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reference_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(reference_view)
	var reference_hint := Label.new()
	reference_hint.text = "Side-by-side reference. Compare identity, silhouette, overlap, and grounding by eye."
	reference_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(reference_hint)
	reference_alpha = HSlider.new()
	reference_alpha.min_value = 0.15
	reference_alpha.max_value = 1.0
	reference_alpha.step = 0.05
	reference_alpha.value = 1.0
	reference_alpha.value_changed.connect(_on_reference_alpha_changed)
	column.add_child(reference_alpha)


func _section_label(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", 15)
	return label


func _on_character_selected(index: int) -> void:
	if refreshing:
		return
	_load_character(CHARACTER_IDS[index])


func _on_load_manifest_pressed() -> void:
	_load_manifest(manifest_path_input.text)


func _load_manifest(path: String) -> void:
	var rig = MANIFEST_RIG.new()
	if not rig.build(path):
		candidate_status.text = "Manifest preview unavailable: " + rig.load_error
		rig.queue_free()
		return
	if is_instance_valid(preview):
		preview.queue_free()
	preview = rig
	add_child(preview)
	current_character = rig.character_id
	var fit := minf(
		REFERENCE_HEIGHT / maxf(rig.measured_visible_height, 1.0),
		680.0 / maxf(rig.source_canvas.x, 1.0)
	)
	preview.scale = Vector2.ONE * fit
	preview.position = Vector2(470, 620) - rig.source_ground * fit
	active_bones = rig.bones
	active_parts = rig.parts
	active_poses.assign(["neutral"])
	candidate_status.text = "%s Tier %d standard manifest; preview scale uses the measured visible height. Semantic and production review remain required." % [rig.character_id, int(rig.get_meta("tier_id", 1))]
	var source_path := String(rig.get_meta("source_reference", ""))
	reference_view.texture = load("res://" + source_path) as Texture2D if not source_path.is_empty() else null
	_rebuild_pose_picker("neutral")
	_rebuild_bone_picker()
	_rebuild_part_list()
	_set_picker_to_character(rig.character_id)
	queue_redraw()


func _load_character(character_id: String) -> void:
	current_character = character_id
	if is_instance_valid(preview):
		preview.queue_free()
		preview = null
	active_bones.clear()
	active_parts.clear()
	_clear_part_list()
	pose_picker.clear()
	bone_picker.clear()
	reference_view.texture = null
	var record := _find_plan_record(character_id)
	_load_reference(record)

	if MESH_IDS.has(character_id.to_lower()):
		var rig := MESH_RIG.new()
		preview = rig
		add_child(preview)
		if not rig.build(character_id.to_lower()):
			candidate_status.text = "Preview could not load. Candidate remains quarantined."
			return
		rig.set_pose("neutral")
		var bounds: Rect2i = rig.texture.get_image().get_used_rect()
		var fit := minf(
			REFERENCE_HEIGHT / maxf(float(bounds.size.y), 1.0),
			680.0 / maxf(float(bounds.size.x), 1.0)
		)
		preview.scale = Vector2.ONE * fit
		preview.position = Vector2(470, 620) - rig.source_ground * fit
		active_bones = rig.bones
		for mesh in rig.meshes:
			active_parts[mesh.name] = mesh
		active_poses.assign(MESH_POSES)
		candidate_status.text = "Flattened profile mesh preflight. Far-side bones and pivots are provisional; this is not semantic-part or production approval."
	elif character_id == "CIPHER":
		var rig := CIPHER_RIG.new()
		preview = rig
		add_child(preview)
		await get_tree().process_frame
		preview.scale = Vector2.ONE * 0.24
		preview.position = Vector2(470, 620) - rig.get_provisional_source_ground() * preview.scale.x
		active_bones = rig.bones
		active_parts = rig.parts
		active_poses.assign(CIPHER_POSES)
		rig.set_pose("neutral")
		candidate_status.text = "Visible-profile cutout candidate. Semantic boundaries, underpaint, far-side anatomy, and pivots remain unresolved."
	else:
		candidate_status.text = "No workbench adapter for this candidate yet. Existing character-specific review scenes and quarantine status remain authoritative."
		active_poses.assign(["reference_only"])
		pose_picker.add_item("reference_only")
		_set_picker_to_character(character_id)
		_rebuild_bone_picker()
		_rebuild_part_list()
		return

	_set_picker_to_character(character_id)
	_rebuild_pose_picker("neutral")
	_rebuild_bone_picker()
	_rebuild_part_list()
	queue_redraw()


func _find_plan_record(character_id: String) -> Dictionary:
	var file := FileAccess.open(PLAN_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	for record in parsed.get("characters", []):
		if String(record.get("id", "")) == character_id:
			return record
	return {}


func _load_reference(record: Dictionary) -> void:
	var path := String(record.get("anatomy_reference", ""))
	if path.contains(" and "):
		path = ""
	if path.begins_with("docs/") and FileAccess.file_exists("res://" + path):
		reference_view.texture = load("res://" + path) as Texture2D


func _set_picker_to_character(character_id: String) -> void:
	refreshing = true
	for index in range(character_picker.item_count):
		if character_picker.get_item_text(index) == character_id:
			character_picker.select(index)
			refreshing = false
			return
	refreshing = false


func _rebuild_pose_picker(selected_pose: String) -> void:
	refreshing = true
	pose_picker.clear()
	for pose in active_poses:
		pose_picker.add_item(pose)
	for index in range(pose_picker.item_count):
		if pose_picker.get_item_text(index) == selected_pose:
			pose_picker.select(index)
			refreshing = false
			return
	refreshing = false


func _rebuild_bone_picker() -> void:
	refreshing = true
	bone_picker.clear()
	for bone_name in active_bones:
		bone_picker.add_item(String(bone_name))
	if bone_picker.item_count > 0:
		bone_picker.select(0)
		refreshing = false
		_update_joint_slider()
	else:
		refreshing = false
		joint_slider.editable = false


func _rebuild_part_list() -> void:
	_clear_part_list()
	for part_name in active_parts:
		var check := CheckButton.new()
		check.text = String(part_name)
		check.button_pressed = (active_parts[part_name] as CanvasItem).visible
		check.toggled.connect(_on_part_toggled.bind(String(part_name)))
		part_list.add_child(check)


func _clear_part_list() -> void:
	for child in part_list.get_children():
		child.queue_free()


func _on_part_toggled(visible: bool, part_name: String) -> void:
	if active_parts.has(part_name):
		(active_parts[part_name] as CanvasItem).visible = visible


func _on_pose_selected(index: int) -> void:
	if refreshing or preview == null or index < 0 or index >= active_poses.size():
		return
	var pose := active_poses[index]
	if preview.has_method("set_pose"):
		preview.call("set_pose", pose)
	_update_joint_slider()
	queue_redraw()


func _on_bone_selected(_index: int) -> void:
	_update_joint_slider()


func _update_joint_slider() -> void:
	if active_bones.is_empty() or bone_picker.selected < 0:
		joint_slider.editable = false
		return
	joint_slider.editable = true
	var bone_name := bone_picker.get_item_text(bone_picker.selected)
	if active_bones.has(bone_name):
		refreshing = true
		joint_slider.value = rad_to_deg((active_bones[bone_name] as Bone2D).rotation)
		refreshing = false


func _on_joint_value_changed(value: float) -> void:
	if refreshing or active_bones.is_empty() or bone_picker.selected < 0:
		return
	var bone_name := bone_picker.get_item_text(bone_picker.selected)
	if active_bones.has(bone_name):
		(active_bones[bone_name] as Bone2D).rotation = deg_to_rad(value)
		queue_redraw()


func _on_pivot_toggled(enabled: bool) -> void:
	show_pivots = enabled
	queue_redraw()


func _on_reference_alpha_changed(value: float) -> void:
	reference_view.modulate.a = value


func _reset_pose() -> void:
	if preview != null and preview.has_method("set_pose"):
		preview.call("set_pose", "neutral")
		_rebuild_pose_picker("neutral")
		_update_joint_slider()
	queue_redraw()


func _capture_pose_sheet() -> void:
	if preview == null or not preview.has_method("set_pose") or active_poses.is_empty():
		candidate_status.text = "No rig adapter is loaded; there is no pose sheet to capture."
		return
	var original_pose := pose_picker.get_item_text(maxi(pose_picker.selected, 0))
	var original_bone_name := ""
	var original_bone_rotations: Dictionary = {}
	for bone_name in active_bones:
		original_bone_rotations[bone_name] = (active_bones[bone_name] as Bone2D).rotation
	if bone_picker.selected >= 0:
		original_bone_name = bone_picker.get_item_text(bone_picker.selected)
	var captures: Array[Image] = []
	controls_layer.visible = false
	for pose in active_poses:
		preview.call("set_pose", pose)
		await get_tree().process_frame
		var frame := get_viewport().get_texture().get_image()
		frame.crop(REVIEW_WIDTH, REVIEW_HEIGHT)
		captures.append(frame)
	var cell_w := REVIEW_WIDTH
	var cell_h := REVIEW_HEIGHT
	var sheet := Image.create(cell_w * 3, cell_h * 2, false, Image.FORMAT_RGBA8)
	for index in range(captures.size()):
		sheet.blit_rect(captures[index], Rect2i(0, 0, cell_w, cell_h), Vector2i((index % 3) * cell_w, floori(float(index) / 3.0) * cell_h))
	var dir_path := ProjectSettings.globalize_path("user://rig_review_captures")
	DirAccess.make_dir_recursive_absolute(dir_path)
	var output_path := "user://rig_review_captures/" + current_character.to_lower() + "_six_pose_review.png"
	var save_error := sheet.save_png(ProjectSettings.globalize_path(output_path))
	var metadata := {
		"character_id": current_character,
		"pose_order": active_poses,
		"asset_status": "quarantined review capture",
		"limits": "Contact sheet supports visual review only; it does not approve semantic parts, anatomy, pivots, deformation, or production readiness."
	}
	var metadata_file := FileAccess.open(output_path.get_basename() + ".json", FileAccess.WRITE)
	if metadata_file != null:
		metadata_file.store_string(JSON.stringify(metadata, "\t"))
	controls_layer.visible = true
	preview.call("set_pose", original_pose)
	for bone_name in original_bone_rotations:
		if active_bones.has(bone_name):
			(active_bones[bone_name] as Bone2D).rotation = original_bone_rotations[bone_name]
	if not original_bone_name.is_empty():
		for index in range(bone_picker.item_count):
			if bone_picker.get_item_text(index) == original_bone_name:
				bone_picker.select(index)
				break
	_rebuild_pose_picker(original_pose)
	_update_joint_slider()
	candidate_status.text = "Capture saved to %s%s" % [output_path, " (write error)." if save_error != OK else ". Review capture only; candidate remains quarantined."]
	queue_redraw()


func _capture_joint_sweep() -> void:
	if preview == null or bone_picker.selected < 0:
		candidate_status.text = "Select a loaded rig and a bone before capturing a joint sweep."
		return
	var bone_name := bone_picker.get_item_text(bone_picker.selected)
	if not active_bones.has(bone_name):
		candidate_status.text = "The selected bone is unavailable."
		return
	var min_degrees := sweep_min_input.value
	var max_degrees := sweep_max_input.value
	if min_degrees >= max_degrees:
		candidate_status.text = "Diagnostic minimum must be less than its maximum."
		return
	var degrees_samples: Array[float] = []
	for fraction in [0.0, 0.25, 0.5, 0.75, 1.0]:
		degrees_samples.append(lerpf(min_degrees, max_degrees, fraction))
	var original_pose := pose_picker.get_item_text(maxi(pose_picker.selected, 0))
	var original_rotations: Dictionary = {}
	for name in active_bones:
		original_rotations[name] = (active_bones[name] as Bone2D).rotation
	var captures: Array[Image] = []
	controls_layer.visible = false
	for degrees in degrees_samples:
		if preview.has_method("set_pose"):
			preview.call("set_pose", "neutral")
		for name in active_bones:
			(active_bones[name] as Bone2D).rotation = 0.0
		(active_bones[bone_name] as Bone2D).rotation = deg_to_rad(degrees)
		await get_tree().process_frame
		await get_tree().process_frame
		var frame := get_viewport().get_texture().get_image()
		frame.crop(REVIEW_WIDTH, REVIEW_HEIGHT)
		captures.append(frame)
	var sheet := Image.create(REVIEW_WIDTH * captures.size(), REVIEW_HEIGHT, false, Image.FORMAT_RGBA8)
	for index in range(captures.size()):
		sheet.blit_rect(captures[index], Rect2i(0, 0, REVIEW_WIDTH, REVIEW_HEIGHT), Vector2i(index * REVIEW_WIDTH, 0))
	var safe_bone_name := bone_name.to_snake_case()
	var min_tag := str(int(min_degrees)).replace("-", "m")
	var max_tag := str(int(max_degrees)).replace("-", "m")
	var output_path := "user://rig_review_captures/%s_%s_joint_range_%s_%s_diagnostic.png" % [current_character.to_lower(), safe_bone_name, min_tag, max_tag]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://rig_review_captures"))
	var save_error := sheet.save_png(ProjectSettings.globalize_path(output_path))
	var metadata := {
		"character_id": current_character,
		"bone": bone_name,
		"angles_degrees": degrees_samples,
		"range_degrees": [min_degrees, max_degrees],
		"action_context_note": sweep_context_input.text.strip_edges(),
		"range_source_verified": false,
		"capture_kind": "single_joint_neutral_pose_diagnostic",
		"review_status": "HUMAN_SEAM_AND_GROUND_CONTACT_REVIEW_REQUIRED",
		"production_approved": false,
		"limits": "This is a single-joint neutral-pose diagnostic, not a combined action capture. The entered range is not independently verified and does not approve animation or deformation."
	}
	var metadata_file := FileAccess.open(output_path.get_basename() + ".json", FileAccess.WRITE)
	if metadata_file != null:
		metadata_file.store_string(JSON.stringify(metadata, "\t"))
	controls_layer.visible = true
	if preview.has_method("set_pose"):
		preview.call("set_pose", original_pose)
	for name in original_rotations:
		if active_bones.has(name):
			(active_bones[name] as Bone2D).rotation = original_rotations[name]
	_update_joint_slider()
	candidate_status.text = "Single-joint diagnostic saved to %s%s" % [output_path, " (write error)." if save_error != OK else ". Range note is unverified; capture actual combined action poses separately. No quality gate was passed."]
	queue_redraw()
