@tool
class_name PolyRigPlugin extends EditorPlugin

signal polygon_selected(polygon: Polygon2D, old_polygon: Polygon2D)
# on polygon mesh or weight changed
signal polygon_changed(polygon: Polygon2D)
# on polygon draw event
signal polygon_draw(polygon: Polygon2D)

static var current_polygon: Polygon2D = null
static var current_skeleton: Skeleton2D = null
static var _current_transform: Transform2D = Transform2D.IDENTITY
static var _instance: PolyRigPlugin

var undo_redo: EditorUndoRedoManager = get_undo_redo()
var _mesh_tool_box: PolyRigMeshToolBox
var _dock # EditorDock
var _editor_content: Control
var _bottom_panel_button:Button

var mesh_manager:PolyRigMeshManager
var weight_manager:PolyRigWeightManager
var bone_manager:PolyRigBoneManager
var drag_manager:PolyRigDragManager

const CACHE_KEY_BONE_DATA := "POLY_RIG_EDITOR_CACHE_BONE_DATA"
const CACHE_KEY := "POLY_RIG_EDITOR_CACHE"
const DOCK_TITLE := "Weights"

static func get_instance() -> PolyRigPlugin:
	return _instance

# --- Polygon management ---

func set_current_polygon(polygon: Polygon2D) -> void:
	var old_polygon := current_polygon
	if current_polygon:
		current_polygon.draw.disconnect(_on_polygon_draw)
	current_polygon = polygon
	current_skeleton = polygon.get_node_or_null(polygon.get_skeleton()) if current_polygon else null
	if current_polygon:
		current_polygon.draw.connect(_on_polygon_draw)
	if old_polygon != polygon:
		polygon_selected.emit(polygon, old_polygon)
	if current_polygon:
		polygon_changed.emit(current_polygon)

func emit_polygon_changed() -> void:
	if current_polygon:
		polygon_changed.emit(current_polygon)

func _on_polygon_draw() -> void:
	if not current_polygon: return
	var new_skel := current_polygon.get_node_or_null(current_polygon.get_skeleton())
	var new_xform := current_polygon.get_global_transform()
	if new_skel != current_skeleton or new_xform != _current_transform:
		current_skeleton = new_skel
		_current_transform = new_xform
	polygon_changed.emit(current_polygon)
	polygon_draw.emit(current_polygon)

# --- Plugin lifecycle ---

func _enter_tree() -> void:
	_instance = self
	_mesh_tool_box = preload("uid://d01nejus786oa").instantiate()
	_mesh_tool_box.hide()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, _mesh_tool_box)
	
	_editor_content = preload("uid://btq5hlktjtdxa").instantiate()

	mesh_manager = _editor_content.get_node("MeshManager")
	weight_manager = _editor_content.get_node("WeightManager")
	bone_manager = _editor_content.get_node("BoneManager")
	drag_manager = _editor_content.get_node("DragManager")

	var version := Engine.get_version_info()
	if (version.major == 4 and version.minor >= 6) or version.major >= 5:
		if ClassDB.can_instantiate("EditorDock"):
			_dock = ClassDB.instantiate("EditorDock") 
			_dock.title = DOCK_TITLE
			_dock.default_slot = ClassDB.class_get_integer_constant("EditorDock", "DOCK_SLOT_BOTTOM")

			_dock.add_child(_editor_content)
			#add_dock(_dock)
			self.call("add_dock", _dock)
			_dock.close()
	else:
		_bottom_panel_button = add_control_to_bottom_panel(_editor_content, DOCK_TITLE)
		_bottom_panel_button.hide()

	print("[PolyRig] Plugin loaded (v0.9.2 Early Access)")
	
func _exit_tree() -> void:
	if _mesh_tool_box:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, _mesh_tool_box)
		_mesh_tool_box.queue_free()

	if _dock:
		self.call("remove_dock", _dock)
		_dock.queue_free() 
	elif _bottom_panel_button:
		remove_control_from_bottom_panel(_editor_content)
		_editor_content.queue_free()
		
	if _instance == self:
		_instance = null
		
func _handles(object: Object) -> bool:
	return object is Polygon2D

func _edit(object: Object) -> void:
	if object is Polygon2D:
		set_current_polygon(object)

func _make_visible(vis: bool) -> void:
	if not _mesh_tool_box: return
	_mesh_tool_box.visible = vis

	if vis:
		if _dock:
			_dock.open()
		else:
			_bottom_panel_button.show()
			make_bottom_panel_item_visible(_editor_content)
		polygon_changed.emit(current_polygon)
	else:
		if _dock:
			_dock.close()
		else:
			_bottom_panel_button.hide()
			hide_bottom_panel()
		set_current_polygon(null)
