@tool
extends Button

@onready var _popup: AcceptDialog = $BoneSetPopup
@onready var _global := PolyRigPlugin.get_instance()

func _on_pressed() -> void:
	var polygon := _global.current_polygon
	if polygon and polygon.get_node_or_null(polygon.get_skeleton()) is Skeleton2D:
		_popup.update_bone_list(polygon)
	else:
		PolyRigUtils.show_warning(self, "Please set a Skeleton on the Polygon first", "Warning")
