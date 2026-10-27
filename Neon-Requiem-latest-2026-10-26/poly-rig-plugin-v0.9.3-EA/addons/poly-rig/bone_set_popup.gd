@tool
extends AcceptDialog

@onready var _list: VBoxContainer = $ScrollContainer/VBoxContainer
@export var _bone_manager: PolyRigBoneManager

const _INDENT_PX := 20

var _polygon: Polygon2D

# Populates the bone list and shows the popup.
func update_bone_list(polygon: Polygon2D) -> void:
	_polygon = polygon
	var skeleton: Skeleton2D = polygon.get_node_or_null(polygon.get_skeleton())
	for child in _list.get_children():
		child.queue_free()
	if not skeleton:
		#PolyRigUtils.show_warning(self, "Please set a Skeleton on the Polygon first.", "Warning")
		return
	popup_centered()
	_build_tree(skeleton, 0, skeleton)

# Recursively creates indented checkboxes for each Bone2D.
func _build_tree(node: Node, depth: int, skeleton: Skeleton2D) -> void:
	for child in node.get_children():
		if child is Bone2D:
			_add_checkbox(skeleton, child, depth)
			_build_tree(child, depth + 1, skeleton)

func _add_checkbox(skeleton: Skeleton2D, bone: Bone2D, depth: int) -> void:
	var wrapper := MarginContainer.new()
	wrapper.add_theme_constant_override("margin_left", depth * _INDENT_PX)
	var cb := CheckBox.new()
	var bp := skeleton.get_path_to(bone)
	cb.text = bone.name
	cb.set_meta("bone_path", bp)
	cb.button_pressed = PolyRigBoneManager.get_bone_data(_polygon).has(bp)
	cb.toggled.connect(func(on: bool): _bone_manager.toggle_bone(_polygon, bp, on))
	wrapper.add_child(cb)
	_list.add_child(wrapper)
