@tool
class_name PolyRigMeshManager extends Node

# --- Snapshot ---

## Captures the full mesh state of a Polygon2D (polygon, uv, ivc, polygons, bone weights).
static func snapshot(polygon: Polygon2D) -> Dictionary:
	var snap := {
		"polygon": polygon.polygon.duplicate(),
		"uv": polygon.uv.duplicate(),
		"ivc": polygon.internal_vertex_count,
		"polygons": polygon.polygons.duplicate(),
		"bones": {},
	}
	for i in range(polygon.get_bone_count()):
		snap.bones[i] = polygon.get_bone_weights(i).duplicate()
	return snap

# --- Apply ---

## Applies mesh geometry to a Polygon2D. Optionally clears all bone weights.
func apply_mesh_data(target: Polygon2D, p: PackedVector2Array, uv: PackedVector2Array, ivc: int, polys: Array, clear_weights: bool = false) -> void:
	target.polygon = p
	target.uv = uv
	target.internal_vertex_count = ivc
	target.polygons = polys
	if clear_weights:
		PolyRigWeightManager.clear_all_weights(target)
	target.queue_redraw()
	var g := PolyRigPlugin.get_instance()
	if g: g.emit_polygon_changed()

## Applies mesh geometry AND restores bone weights from a snapshot.
func apply_mesh_data_with_weights(target: Polygon2D, p: PackedVector2Array, uv: PackedVector2Array, ivc: int, polys: Array, bone_weights: Dictionary) -> void:
	apply_mesh_data(target, p, uv, ivc, polys)
	for bi in bone_weights:
		if bi < target.get_bone_count():
			target.set_bone_weights(bi, bone_weights[bi])

## Restores a full mesh snapshot (geometry + weights).
func restore_snapshot(target: Polygon2D, snap: Dictionary) -> void:
	apply_mesh_data_with_weights(target, snap.polygon, snap.uv, snap.ivc, snap.polygons, snap.bones)

# --- Undo ---

## Commits an undo action that swaps between two full mesh snapshots.
func commit_mesh_undo(action_name: String, target: Polygon2D, old_snap: Dictionary, new_snap: Dictionary, merge_mode: int = UndoRedo.MERGE_DISABLE) -> void:
	var ur := PolyRigPlugin.get_instance().undo_redo
	ur.create_action(action_name, merge_mode)
	ur.add_do_method(self, "restore_snapshot", target, new_snap)
	ur.add_undo_method(self, "restore_snapshot", target, old_snap)
	ur.commit_action(false)

## Commits an undo action for mesh geometry only (no bone weight restore on do).
## do_data: { "p", "uv", "ivc", "polys", "clear_weights" }
func commit_mesh_geometry_undo(action_name: String, target: Polygon2D, old_snap: Dictionary, p: PackedVector2Array, uv: PackedVector2Array, ivc: int, polys: Array, clear_weights: bool = false) -> void:
	var ur := PolyRigPlugin.get_instance().undo_redo
	ur.create_action(action_name)
	ur.add_do_method(self, "apply_mesh_data", target, p, uv, ivc, polys, clear_weights)
	ur.add_undo_method(self, "restore_snapshot", target, old_snap)
	ur.commit_action()
