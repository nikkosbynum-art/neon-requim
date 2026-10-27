@tool
class_name PolyRigAutoWeightButton extends Button

signal weights_calculated

@onready var _global := PolyRigPlugin.get_instance()
@export var weight_manager: PolyRigWeightManager

func _on_pressed() -> void:
	if not _global.current_polygon or not _global.current_skeleton:
		PolyRigUtils.show_warning(self, "Please set a Skeleton on the Polygon first!", "Warning")
		return
	var polygon := _global.current_polygon
	var old_snap := weight_manager.snapshot_all_weights(polygon)
	_generate_weights()
	var new_snap := weight_manager.snapshot_all_weights(polygon)
	weight_manager.commit_all_weights_undo("Auto generate weights", polygon, old_snap, new_snap)
	_global.emit_polygon_changed()

# Builds bone segments and delegates IDW calculation to PolyRigInverseDistanceWeighting.
func _generate_weights() -> void:
	var polygon := _global.current_polygon
	var skeleton := _global.current_skeleton

	var bone_paths: Array = polygon.get_meta(PolyRigPlugin.CACHE_KEY_BONE_DATA, [])
	if bone_paths.is_empty(): return

	var valid_bones: Array[Bone2D] = []
	for bp in bone_paths:
		var bone: Bone2D = skeleton.get_node_or_null(bp)
		if bone: valid_bones.append(bone)
	if valid_bones.is_empty(): return

	# Pre-compute bone rest segments (head -> tail) in world space
	var segments: Array = []
	for bone in valid_bones:
		var bone_segments := PolyRigUtils.get_bone_rest_segments(bone, skeleton)
		for seg in bone_segments:
			segments.append({"head": seg[0], "tail": seg[1], "bi": bone.get_index_in_skeleton()})

	# Convert vertices to world space
	var pts := polygon.polygon
	var world_pts := PackedVector2Array()
	world_pts.resize(pts.size())
	for i in range(pts.size()):
		world_pts[i] = polygon.to_global(pts[i])

	# Calculate and apply Geodesic IDW weights
	var weights_data: Dictionary = PolyRigGeodesicPolyRigInverseDistanceWeighting.calculate(segments, world_pts, polygon.polygons)
	for bi in weights_data:
		polygon.set_bone_weights(bi, weights_data[bi])

	weights_calculated.emit()
	_global.emit_polygon_changed()
