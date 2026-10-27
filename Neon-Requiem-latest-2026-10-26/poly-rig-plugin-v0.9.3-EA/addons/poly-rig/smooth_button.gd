@tool
extends Button

const ITERATIONS: int = 5
const ALPHA: float = 0.5

@onready var _global := PolyRigPlugin.get_instance()
@onready var _weight_manager: PolyRigWeightManager = %WeightManager
@onready var _bone_item_list = %BoneItemList

func _on_pressed() -> void:
	var polygon := _global.current_polygon
	if not polygon: return
	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	if not skeleton: return
	
	var bone_data: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	if bone_data.is_empty(): return

	var adjacency: Dictionary = _build_adjacency(polygon)
	var vertex_count := polygon.polygon.size()

	#var selected_bone: Bone2D = _bone_item_list.get_selected_bone()

	var old_snap := _weight_manager.snapshot_all_weights(polygon)

	# if selected_bone:
	# 	for _i in range(ITERATIONS):
	# 		_smooth_bone(polygon, skeleton, selected_bone, adjacency, vertex_count)
	# else:
	for _i in range(ITERATIONS):
		for bp in bone_data:
			var bone: Bone2D = skeleton.get_node_or_null(bp)
			if bone:
				_smooth_bone(polygon, skeleton, bone, adjacency, vertex_count)

	for i in range(vertex_count):
		PolyRigWeightManager.ensure_vertex_normalized(polygon, i, bone_data, skeleton)

	var new_snap := _weight_manager.snapshot_all_weights(polygon)
	_weight_manager.commit_all_weights_undo("Smooth weights", polygon, old_snap, new_snap)
	_global.emit_polygon_changed()

func _smooth_bone(polygon: Polygon2D, _skeleton: Skeleton2D, bone: Bone2D, adjacency: Dictionary, vertex_count: int) -> void:
	var bi := bone.get_index_in_skeleton()
	if bi < 0 or bi >= polygon.get_bone_count(): return
	var weights := polygon.get_bone_weights(bi)
	if weights.size() < vertex_count: return

	var new_weights := weights.duplicate()
	for i in range(vertex_count):
		var neighbors: Array = adjacency.get(i, [])
		if neighbors.is_empty():
			continue
		var sum := 0.0
		for nb in neighbors:
			sum += weights[nb]
		var neighbor_avg := sum / neighbors.size()
		# w_new = (1 - α) * w_old + α * avg(neighbors)
		new_weights[i] = lerp(weights[i], neighbor_avg, ALPHA)

	polygon.set_bone_weights(bi, new_weights)

func _build_adjacency(polygon: Polygon2D) -> Dictionary:
	var adjacency: Dictionary = {}
	var triangles: Array = polygon.polygons
	for tri in triangles:
		if tri.size() < 3: continue
		var a: int = tri[0]
		var b: int = tri[1]
		var c: int = tri[2]
		_add_edge(adjacency, a, b)
		_add_edge(adjacency, b, c)
		_add_edge(adjacency, a, c)
	return adjacency

func _add_edge(adjacency: Dictionary, a: int, b: int) -> void:
	if not adjacency.has(a):
		adjacency[a] = []
	if not adjacency.has(b):
		adjacency[b] = []

	if not (b in adjacency[a]):
		adjacency[a].append(b)
	if not (a in adjacency[b]):
		adjacency[b].append(a)
