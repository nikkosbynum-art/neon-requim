@tool
class_name PolyRigBoneManager extends Node

signal bone_data_changed(data: Array)

@onready var _global := PolyRigPlugin.get_instance()

func _ready() -> void:
	if _global:
		_global.polygon_selected.connect(_on_polygon_selected)

func _on_polygon_selected(polygon: Polygon2D, old_polygon: Polygon2D) -> void:
	sync_bone(polygon)

# --- Public API ---

static func get_bone_data(polygon: Polygon2D) -> Array:
	return polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])

func add_bone(polygon: Polygon2D, bone_path: NodePath, record_undo: bool = false) -> void:
	var data: Array = get_bone_data(polygon).duplicate()
	if data.has(bone_path): return
	var old_data := data.duplicate()
	var old_weights := _snapshot_weights(polygon)
	data.append(bone_path)
	_apply_meta(polygon, data)
	if record_undo:
		_commit_undo("Add bone binding", polygon, old_data, old_weights)

func remove_bone(polygon: Polygon2D, bone_path: NodePath, record_undo: bool = false, remove_bone_weights: bool = true) -> void:
	var data: Array = get_bone_data(polygon).duplicate()
	var old_data := data.duplicate()
	var old_weights := _snapshot_weights(polygon)

	if remove_bone_weights:
		var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.skeleton)
		if skeleton:
			var bone: Bone2D = skeleton.get_node_or_null(bone_path)
			if bone:
				PolyRigWeightManager.clear_bone_weights(polygon, bone)

	data.erase(bone_path)
	_apply_meta(polygon, data)

	if record_undo:
		_commit_undo("Remove bone binding", polygon, old_data, old_weights)

func clear_bone(polygon: Polygon2D):
	_apply_meta(polygon, [])

func toggle_bone(polygon: Polygon2D, bone_path: NodePath, toggled_on: bool) -> void:
	if toggled_on:
		add_bone(polygon, bone_path, true)
	else:
		remove_bone(polygon, bone_path, true)

# Synchronizes polygon bone list with skeleton, preserving existing weights.
func sync_bone(polygon: Polygon2D) -> void:
	if not polygon:
		return
		
	var skeleton_path = polygon.skeleton
	var skeleton:Skeleton2D = polygon.get_node_or_null(skeleton_path)

	if not skeleton:
		return

	var target_bones: Array = get_bone_data(polygon).duplicate()
	# Backup existing weights keyed by path
	var backup: Dictionary = {}
	for i in range(polygon.get_bone_count()):
		backup[polygon.get_bone_path(i)] = polygon.get_bone_weights(i)

	polygon.clear_bones()
	clear_bone(polygon)

	# Re-add all skeleton bones with preserved or fresh weights
	var vert_count := polygon.polygon.size()
	for bi in range(skeleton.get_bone_count()):
		var bone := skeleton.get_bone(bi)
		var bp := skeleton.get_path_to(bone)
		var weights: PackedFloat32Array
		if backup.has(bp):
			weights = backup[bp]
			if weights.size() != vert_count:
				weights.resize(vert_count)
		else:
			weights = PackedFloat32Array()
			weights.resize(vert_count)
			weights.fill(0)
		polygon.add_bone(bp, weights)

		if bp in target_bones:
			add_bone(polygon, bp)

# Forces a bone to refresh its auto-calculated length and angle.
static func update_bone_autocalculate(bone: Bone2D):
	var auto := bone.get_autocalculate_length_and_angle()
	var has_child := PolyRigUtils.has_child_bone(bone)
	
	if has_child:
		bone.set_autocalculate_length_and_angle(true)
		bone.force_update_transform()
	
	var length := bone.get_length()
	var angle := bone.get_bone_angle()

	if has_child:
		bone.set_autocalculate_length_and_angle(auto)
		
	return [length, angle]
	
# --- Internal ---

func _apply_meta(polygon: Polygon2D, data: Array) -> void:
	polygon.set_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, data)
	#sync_bone(polygon)
	bone_data_changed.emit(data)

func _snapshot_weights(polygon: Polygon2D) -> Dictionary:
	var snap := {}
	for i in range(polygon.get_bone_count()):
		snap[i] = polygon.get_bone_weights(i).duplicate()
	return snap

func _commit_undo(action_name: String, polygon: Polygon2D, old_data: Array, old_weights: Dictionary) -> void:
	var new_data: Array = get_bone_data(polygon).duplicate()
	var new_weights := _snapshot_weights(polygon)
	var ur := PolyRigPlugin.get_instance().undo_redo
	ur.create_action(action_name)
	ur.add_do_method(self, "_restore_bone_data", polygon, new_data, new_weights)
	ur.add_undo_method(self, "_restore_bone_data", polygon, old_data, old_weights)
	ur.commit_action(false)

func _apply_bone_data(polygon: Polygon2D, data: Array) -> void:
	_apply_meta(polygon, data.duplicate())
	bone_data_changed.emit(get_bone_data(polygon))

func _restore_bone_data(polygon: Polygon2D, old_data: Array, old_weights: Dictionary) -> void:
	_apply_meta(polygon, old_data.duplicate())
	for bi in old_weights:
		if bi < polygon.get_bone_count():
			polygon.set_bone_weights(bi, old_weights[bi])
	bone_data_changed.emit(get_bone_data(polygon))
