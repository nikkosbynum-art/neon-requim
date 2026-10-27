@tool
class_name PolyRigTriangulateButton extends Button

@onready var _global := PolyRigPlugin.get_instance()
@export var _mesh_type_button: PolyRigMeshEditTypeButton

func _on_pressed() -> void:
	var src := _global.current_polygon
	if not src or src.polygon.size() == 0:
		PolyRigUtils.show_warning(self, "No polygon vertices to triangulate!", "Warning")
		return
	_mesh_type_button.restore(src)

	var mm := _global.mesh_manager
	var old_snap := PolyRigMeshManager.snapshot(src)
	var polys := PolyRigDelaunay.triangulate_polygon(src)

	mm.commit_mesh_geometry_undo("Triangulate mesh", src,
		old_snap, src.polygon.duplicate(), src.polygon.duplicate(),
		src.internal_vertex_count, polys)
