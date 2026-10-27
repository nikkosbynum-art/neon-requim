@tool
class_name PolyRigWeightManager extends Node

enum ZeroDistributeMode { FIRST, AVERAGE }

const _GOLDEN_RATIO_CONJUGATE := 0.618033988749895
const WEIGHT_PRUNE_THRESHOLD := 0.05
var _bone_colors: Dictionary = {}
var _hue_pointer: float = randf()

# Returns a deterministic color for a bone path (golden-ratio hue distribution).
func get_bone_color(bone_path: NodePath) -> Color:
	if _bone_colors.has(bone_path):
		return _bone_colors[bone_path]
	_hue_pointer = wrapf(_hue_pointer + _GOLDEN_RATIO_CONJUGATE, 0.0, 1.0)
	var c := Color.from_hsv(_hue_pointer, 0.65, 0.95)
	_bone_colors[bone_path] = c
	return c

# Delegates to get_bone_path in utils.
static func get_bone_path(bone: Bone2D) -> NodePath:
	return PolyRigUtils.get_bone_path(bone)

# --- Single vertex weight access ---

static func get_vertex_weight(polygon: Polygon2D, vertex_index: int, bone: Bone2D) -> float:
	if not bone: return 0.0
	var bi := bone.get_index_in_skeleton()
	if bi < 0 or bi >= polygon.get_bone_count(): return 0.0
	var weights := polygon.get_bone_weights(bi)
	if vertex_index < 0 or vertex_index >= weights.size(): return 0.0
	return weights[vertex_index]

static func set_vertex_weight(polygon: Polygon2D, vertex_index: int, bone: Bone2D, weight: float, normalize_weights:bool = true) -> void:
	if not bone: return
	if normalize_weights:
		set_vertex_weight_normalized(polygon, vertex_index, bone, weight)
		return
	var bi := bone.get_index_in_skeleton()
	if bi < 0 or bi >= polygon.get_bone_count(): return
	var weights := polygon.get_bone_weights(bi)
	if vertex_index < 0 or vertex_index >= weights.size(): return
	weights[vertex_index] = weight
	polygon.set_bone_weights(bi, weights)

# Returns all bone weights for a single vertex as { NodePath: float }.
static func get_vertex_weights(polygon: Polygon2D, vertex_index: int) -> Dictionary:
	var result: Dictionary = {}
	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	if not skeleton: return result
	for bone_path in polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, []):
		var bone: Bone2D = skeleton.get_node_or_null(bone_path)
		if bone:
			result[bone_path] = get_vertex_weight(polygon, vertex_index, bone)
	return result

# --- Normalized weight setting ---

# Sets weight for one bone and redistributes the remainder to other bones.
# Handles non-normalized input by pre-normalizing all weights proportionally.
static func set_vertex_weight_normalized(polygon: Polygon2D, vertex_index: int, bone: Bone2D, new_weight: float, zero_mode: ZeroDistributeMode = ZeroDistributeMode.FIRST) -> void:
	new_weight = clampf(new_weight, 0.0, 1.0)
	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	var bone_data: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	if bone_data.is_empty(): return

	# Pre-normalize: ensure existing weights sum to 1.0 before editing
	ensure_vertex_normalized(polygon, vertex_index, bone_data, skeleton)

	var old_weight := get_vertex_weight(polygon, vertex_index, bone)
	var delta := new_weight - old_weight

	# Sum weights of all other bones (now guaranteed normalized)
	var total_other := 0.0
	for bp in bone_data:
		var tb: Bone2D = skeleton.get_node_or_null(bp)
		if tb != bone:
			total_other += get_vertex_weight(polygon, vertex_index, tb)

	# Apply the new weight
	var bi := bone.get_index_in_skeleton()
	var weights := polygon.get_bone_weights(bi)
	if vertex_index >= weights.size():
		weights.resize(vertex_index + 1)
	weights[vertex_index] = new_weight
	polygon.set_bone_weights(bi, weights)

	if absf(delta) < 0.0001: return

	var remaining := 1.0 - new_weight
	if total_other > 0.0:
		# Redistribute proportionally
		for bp in bone_data:
			var tb: Bone2D = skeleton.get_node_or_null(bp)
			if tb == bone: continue
			var tbi := tb.get_index_in_skeleton()
			var ow := polygon.get_bone_weights(tbi)
			ow[vertex_index] = remaining * (get_vertex_weight(polygon, vertex_index, tb) / total_other)
			polygon.set_bone_weights(tbi, ow)
	else:
		if zero_mode == ZeroDistributeMode.FIRST:
			# Give all remaining weight to the first other bone
			for bp in bone_data:
				var tb: Bone2D = skeleton.get_node_or_null(bp)
				if tb == bone: continue
				var tbi := tb.get_index_in_skeleton()
				var ow := polygon.get_bone_weights(tbi)
				if vertex_index >= ow.size():
					ow.resize(vertex_index + 1)
				ow[vertex_index] = remaining
				polygon.set_bone_weights(tbi, ow)
				break
		else:
			# Distribute evenly
			var count := bone_data.size() - 1
			if count <= 0: return
			var share := remaining / count
			for bp in bone_data:
				var tb: Bone2D = skeleton.get_node_or_null(bp)
				if tb == bone: continue
				var tbi := tb.get_index_in_skeleton()
				var ow := polygon.get_bone_weights(tbi)
				if vertex_index >= ow.size():
					ow.resize(vertex_index + 1)
				ow[vertex_index] = share
				polygon.set_bone_weights(tbi, ow)

# Normalizes all bone weights for a single vertex so they sum to 1.0 (proportionally).
static func ensure_vertex_normalized(polygon: Polygon2D, vertex_index: int, bone_data: Array, skeleton: Skeleton2D) -> void:
	var total := 0.0
	for bp in bone_data:
		var tb: Bone2D = skeleton.get_node_or_null(bp)
		if tb: total += get_vertex_weight(polygon, vertex_index, tb)
	if total < 0.0001 or is_equal_approx(total, 1.0): return
	# Scale all weights proportionally so they sum to 1.0
	var inv := 1.0 / total
	for bp in bone_data:
		var tb: Bone2D = skeleton.get_node_or_null(bp)
		if not tb: continue
		var tbi := tb.get_index_in_skeleton()
		var w := polygon.get_bone_weights(tbi)
		if vertex_index >= w.size(): continue
		w[vertex_index] *= inv
		polygon.set_bone_weights(tbi, w)

## Prunes bone weights below WEIGHT_PRUNE_THRESHOLD and re-normalizes.
## weights_data: { bone_index: PackedFloat32Array }, vertex_count: number of vertices.
static func prune_weights(weights_data: Dictionary, vertex_count: int) -> void:
	for i in range(vertex_count):
		var total := 0.0
		for bi in weights_data:
			if weights_data[bi][i] < WEIGHT_PRUNE_THRESHOLD:
				weights_data[bi][i] = 0.0
			else:
				total += weights_data[bi][i]
		if total > 0.0:
			for bi in weights_data:
				if weights_data[bi][i] > 0.0:
					weights_data[bi][i] /= total

static func clear_all_weights(polygon: Polygon2D) -> void:
	for i in range(polygon.get_bone_count()):
		var w := polygon.get_bone_weights(i)
		w.fill(0.0)
		polygon.set_bone_weights(i, w)

# Clears all weights for a specific bone.
static func clear_bone_weights(polygon: Polygon2D, bone: Bone2D) -> void:
	if not bone: return
	var bone_index := bone.get_index_in_skeleton()
	if bone_index >= 0 and bone_index < polygon.get_bone_count():
		var weights := polygon.get_bone_weights(bone_index)
		weights.fill(0.0)
		polygon.set_bone_weights(bone_index, weights)

# --- Snapshots & Undo ---

static func snapshot_all_weights(polygon: Polygon2D) -> Dictionary:
	var snap := {}
	for i in range(polygon.get_bone_count()):
		snap[i] = polygon.get_bone_weights(i).duplicate()
	return snap

static func snapshot_weights(polygon: Polygon2D, bone_indices: Array[int]) -> Dictionary:
	var snap := {}
	for bi in bone_indices:
		if bi >= 0 and bi < polygon.get_bone_count():
			snap[bi] = polygon.get_bone_weights(bi).duplicate()
	return snap

static func restore_all_weights(polygon: Polygon2D, snapshot: Dictionary) -> void:
	for bi in snapshot:
		if bi < polygon.get_bone_count():
			polygon.set_bone_weights(bi, snapshot[bi])
	var g := PolyRigPlugin.get_instance()
	if g: g.emit_polygon_changed()

static func snapshot_single_vertex_weights(polygon: Polygon2D, vertex_index: int) -> Dictionary:
	var snap := {}
	for i in range(polygon.get_bone_count()):
		var w := polygon.get_bone_weights(i)
		if vertex_index < w.size():
			snap[i] = w[vertex_index]
	return snap

static func restore_single_vertex_weights(polygon: Polygon2D, vertex_index: int, snapshot: Dictionary) -> void:
	for bi in snapshot:
		if bi < polygon.get_bone_count():
			var w := polygon.get_bone_weights(bi)
			if vertex_index < w.size():
				w[vertex_index] = snapshot[bi]
				polygon.set_bone_weights(bi, w)
	var g := PolyRigPlugin.get_instance()
	if g: g.emit_polygon_changed()

func commit_all_weights_undo(action_name: String, polygon: Polygon2D, old_snap: Dictionary, new_snap: Dictionary, merge_mode: int = UndoRedo.MERGE_DISABLE) -> void:
	var ur := PolyRigPlugin.get_instance().undo_redo
	ur.create_action(action_name, merge_mode)
	ur.add_do_method(self, "restore_all_weights", polygon, new_snap)
	ur.add_undo_method(self, "restore_all_weights", polygon, old_snap)
	ur.commit_action(false)

func commit_vertex_weights_undo(action_name: String, polygon: Polygon2D, vertex_index: int, old_snap: Dictionary, new_snap: Dictionary, merge_mode: int = UndoRedo.MERGE_DISABLE) -> void:
	var ur := PolyRigPlugin.get_instance().undo_redo
	ur.create_action(action_name, merge_mode)
	ur.add_do_method(self, "restore_single_vertex_weights", polygon, vertex_index, new_snap)
	ur.add_undo_method(self, "restore_single_vertex_weights", polygon, vertex_index, old_snap)
	ur.commit_action(false)
