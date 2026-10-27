@tool
extends VBoxContainer

signal bone_selected(bone: Bone2D)
signal bone_weights_changed()

const _BONE_ITEM = preload("uid://csrs6a3hjd027")

@onready var _global := PolyRigPlugin.get_instance()
@onready var _weight_manager: PolyRigWeightManager = %WeightManager
@onready var _weight_chart: PolyRigWeightChart = %WeightChart
@onready var _normalize_check: CheckBox = %WeightNormalCheckBox
@onready var _bone_manager: PolyRigBoneManager = %BoneManager
@onready var boneless_tip: Label = %BonelessTip
@onready var _current_bone_label: Label = %CurrentBoneLabel

var normalize_weights = true
var _disabled: bool = false
var _selected_bone: Bone2D = null
var _bone_item_map: Dictionary = {} # Bone2D -> PolyRigBoneItem

func _ready() -> void:
	_bone_item_map = {}
	if _global:
		_global.polygon_selected.connect(_on_polygon_selected)
		_global.polygon_changed.connect(_on_polygon_changed)
	_disabled = true
	_current_bone_label.text = ""

func get_selected_bone() -> Bone2D:
	return _selected_bone

func select_bone(bone) -> void:
	if _selected_bone == bone:
		_selected_bone = null
		_current_bone_label.text = ""
	else:
		_selected_bone = bone
		_current_bone_label.text = bone.name if bone else ""
	_sync_item_pressed_states()
	bone_selected.emit(_selected_bone)

func _sync_item_pressed_states() -> void:
	for bone in _bone_item_map:
		var item: PolyRigBoneItem = _bone_item_map[bone]
		item.set_pressed_no_signal(bone == _selected_bone)

# --- Signal handlers ---

func _on_polygon_selected(_polygon: Polygon2D, _old_polygon: Polygon2D) -> void:
	_update_list()

func _on_polygon_changed(_polygon: Polygon2D) -> void:
	_update_list()

func _on_bone_manager_bone_data_changed(_data: Array) -> void:
	_update_list()

# func _on_weight_normal_check_box_pressed() -> void:
# 	normalize_weights = _normalize_check.button_pressed

# --- List management ---

func _update_list() -> void:
	var polygon := _global.current_polygon
	if not polygon:
		_clear_items()
		return
	var skeleton := _global.current_skeleton
	if not skeleton:
		polygon.set_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
		_clear_items()
		return

	var bone_data: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	var existing := get_children()
	var count := 0
	_bone_item_map = {}

	boneless_tip.visible = bone_data.size() == 0

	for bp in bone_data:
		var bone: Bone2D = skeleton.get_node_or_null(bp)
		if not bone:
			continue

		var item: PolyRigBoneItem
		if count < existing.size():
			item = existing[count]
		else:
			item = _BONE_ITEM.instantiate()
			add_child(item)
			item.delete_button_pressed.connect(_on_delete.bind(item))
			item.weight_changed.connect(_on_weight_changed)
			item.pressed.connect(func(): select_bone(item.bone))

		item.bone = bone
		item.color = _weight_manager.get_bone_color(bp)
		item.weight = _weight_manager.get_vertex_weight(polygon, _weight_chart.selected_vertex_index, bone) if _weight_chart.selected_vertex_index != -1 else 0.0
		item.button_pressed = (_selected_bone == bone)
		_bone_item_map[bone] = item
		count += 1

	# Remove excess items
	for i in range(count, existing.size()):
		existing[i].queue_free()
	_set_disabled(_disabled)

func _clear_items() -> void:
	for child in get_children():
		child.queue_free()

func _on_delete(item: PolyRigBoneItem) -> void:
	if not _global.current_skeleton: return
	_bone_manager.remove_bone(_global.current_polygon, _global.current_skeleton.get_path_to(item.bone), true)

# --- Vertex selection ---

func _on_weight_chart_vertex_selected(vertex_index: int) -> void:
	var polygon := _global.current_polygon
	if not polygon: return
	_set_disabled(vertex_index == -1)
	for child in get_children():
		child.weight = _weight_manager.get_vertex_weight(polygon, vertex_index, child.bone)

func _set_disabled(val: bool) -> void:
	_disabled = val
	for child in get_children():
		child.set_input_disabled(val)

# --- Weight editing ---

func _on_weight_changed(bone: Bone2D, weight: float) -> void:
	var polygon := _global.current_polygon
	if not polygon: return
	var vi := _weight_chart.selected_vertex_index
	var old_snap := _weight_manager.snapshot_single_vertex_weights(polygon, vi)
	_weight_manager.set_vertex_weight(polygon, vi, bone, weight, normalize_weights)

	for child in get_children():
		if child.bone != bone:
			child.weight = _weight_manager.get_vertex_weight(polygon, vi, child.bone)

	var new_snap := _weight_manager.snapshot_single_vertex_weights(polygon, vi)
	_weight_manager.commit_vertex_weights_undo("Edit vertex weight", polygon, vi, old_snap, new_snap, UndoRedo.MERGE_ENDS)
	bone_weights_changed.emit()

func _on_weight_normal_check_box_toggled(toggled_on: bool) -> void:
	normalize_weights = toggled_on
