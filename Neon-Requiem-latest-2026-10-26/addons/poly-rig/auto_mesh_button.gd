@tool
class_name PolyRigAutoMeshButton extends Button

@onready var _dialog: AcceptDialog = $AcceptDialog
@onready var _global := PolyRigPlugin.get_instance()
@onready var _polygon_display: Control = %PolygonDisplay
@onready var _polygon_2d: Polygon2D = %Polygon2D
@onready var _only_mesh_check: CheckBox = %OnlyMeshCheckBox
@onready var _density_field: PolyRigNumberInputField = $AcceptDialog/VBoxContainer/DensityInputField
@onready var _padding_field: PolyRigNumberInputField = $AcceptDialog/VBoxContainer/PaddingInputField
@onready var _internal_density_field: PolyRigNumberInputField = $AcceptDialog/VBoxContainer/InternalDensityInputField
@onready var _progress_bar: ProgressBar = %CalculationProgressBar
@export var _mesh_type_button:PolyRigMeshEditTypeButton

const _LLOYD_ITERATIONS := 4
const _POISSON_ATTEMPTS := 30

var _grow_amount: float = 10.0
var _internal_density: float = 0.0
var _density: float = 5.0
var _only_outline: bool = false
var _only_mesh: bool = false
var _is_generating: bool = false
var _task_id: int = -1
var _gen_id: int = 0
var _preview_points: PackedVector2Array  # original texture-space coords for confirmed output
var _rng_seed: int = 0

func _ready() -> void:
	_dialog.hide()
	_update_fields()

# --- Button press ---

func _on_pressed() -> void:
	if not _global.current_polygon or not _global.current_polygon.texture:
		PolyRigUtils.show_warning(self, "Please set a Texture on the Polygon first!", "Warning")
		return
	_rng_seed = randi()
	_mesh_type_button.restore(_global.current_polygon)
	_sync_ui()
	_dialog.popup()
	_update_fields()
	await get_tree().process_frame
	_generate()

# --- Mesh generation ---

func _generate() -> void:
	if _is_generating: return
	var src := _global.current_polygon

	# Path A: re-triangulate only (keep existing vertices)
	if _only_mesh:
		if src.polygon.size() == 0:
			_apply_preview(src.polygon, src.internal_vertex_count, src.polygons)
			return
		_submit_task({
			"mesh_only": true,
			"pts": src.polygon.duplicate(),
			"ivc": src.internal_vertex_count,
		})
		return

	if not src or not src.texture: return

	# Path B: full generation on worker thread
	_submit_task({
		"mesh_only": false,
		"image": src.texture.get_image(),
		"texture": src.texture,
		"density": _density,
		"grow": _grow_amount,
		"outline_only": _only_outline,
		"internal_density": _internal_density,
	})

func _submit_task(params: Dictionary) -> void:
	_gen_id += 1
	params["gen_id"] = _gen_id
	params["rng_seed"] = _rng_seed
	_is_generating = true
	_update_fields()
	_task_id = WorkerThreadPool.add_task(_compute_task.bind(params))

func _compute_task(params: Dictionary) -> void:
	call_deferred("_on_computed", _compute(params))

func _compute(params: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = params["rng_seed"]
	var gen_id: int = params["gen_id"]

	# Path A: re-triangulate only (keep existing vertices)
	if params["mesh_only"]:
		var pts: PackedVector2Array = params["pts"]
		var ivc: int = params["ivc"]
		var outline := pts.slice(0, pts.size() - ivc)
		return {
			"gen_id": gen_id, "valid": true,
			"points": pts, "ivc": ivc, "polygons": PolyRigDelaunay.triangulate_to_indices(pts, outline),
		}

	# Path B: full generation
	var image: Image = params["image"]

	# Detect outline from alpha
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)
	var polys := bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), params["density"])
	if polys.size() == 0:
		return {"gen_id": gen_id, "valid": false}

	# Pick largest contour
	var outline: PackedVector2Array = polys[0]
	for p in polys:
		if p.size() > outline.size():
			outline = p

	# Grow and simplify outline
	var offset := Geometry2D.offset_polygon(outline, params["grow"], Geometry2D.JOIN_SQUARE)
	if offset.size() > 0:
		outline = offset[0]
	outline = PolyRigUtils.simplify_outline(outline)

	# Generate internal points via Poisson + Lloyd relaxation
	var internal_pts := PackedVector2Array()
	if not params["outline_only"]:
		internal_pts = _generate_internal_points(outline, params["internal_density"], rng)

	var all_pts := outline + internal_pts
	return {
		"gen_id": gen_id, "valid": true,
		"points": all_pts,
		"ivc": internal_pts.size(),
		"polygons": PolyRigDelaunay.triangulate_to_indices(all_pts, outline),
		"texture": params["texture"],
	}

func _on_computed(result: Dictionary) -> void:
	if _task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(_task_id)
		_task_id = -1
	if result["gen_id"] != _gen_id: return
	_is_generating = false
	_update_fields()
	if not result["valid"]: return
	_polygon_2d.clear_bones()
	if result.has("texture"):
		_polygon_2d.texture = result["texture"]
	_apply_preview(result["points"], result["ivc"], result["polygons"])

# --- Core algorithms ---

# Generates internal points using Poisson disc sampling + Lloyd relaxation.
# density_value is the raw UI slider value; converted to actual pixel distance internally.
func _generate_internal_points(boundary: PackedVector2Array, density_value: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	if boundary.size() < 3: return PackedVector2Array()
	var diag := PolyRigUtils.get_points_bounding_rect(boundary).size.length()
	var min_dist := diag / (density_value + 4.0)
	min_dist = maxf(min_dist, 4.0)

	# Shrink boundary to keep internal points away from edges
	var shrunk := Geometry2D.offset_polygon(boundary, -min_dist * 0.4)
	if shrunk.is_empty(): return PackedVector2Array()

	var pts := PackedVector2Array()
	for poly in shrunk:
		if PolyRigUtils.polygon_area(poly) < min_dist * min_dist:
			continue
		pts.append_array(PolyRigPoissonDiscSampling.generate_points_for_polygon(poly, min_dist, _POISSON_ATTEMPTS, Vector2.INF, rng))
	if pts.is_empty(): return pts

	# Cap point count to prevent slow Lloyd relaxation
	if pts.size() > 500:
		pts.resize(500)

	# Lloyd relaxation
	var rect := PolyRigDelaunay.calculate_rect(boundary, 500.0)
	for _iter in range(_LLOYD_ITERATIONS):
		var d := PolyRigDelaunay.new(rect)
		for p in boundary: d.add_point(p)
		for p in pts: d.add_point(p)
		var sites := d.make_voronoi(d.triangulate())

		# Build center -> site lookup (make_voronoi may skip incomplete sites)
		var site_map: Dictionary = {}
		for site in sites:
			site_map[site.center] = site

		var new_pts := PackedVector2Array()
		for j in range(pts.size()):
			var site = site_map.get(pts[j])
			if not site:
				new_pts.append(pts[j])
				continue
			var clipped := Geometry2D.intersect_polygons(site.polygon, boundary)
			if clipped.is_empty():
				new_pts.append(pts[j])
				continue
			# Weighted centroid of clipped Voronoi cell
			var csum := Vector2.ZERO
			var asum := 0.0
			for poly in clipped:
				var a := PolyRigUtils.polygon_area(poly)
				csum += PolyRigUtils.polygon_centroid(poly) * a
				asum += a
			new_pts.append(csum / asum if asum > 0.001 else pts[j])
		pts = new_pts
	return pts

# --- Preview & Undo ---

func _apply_preview(points: PackedVector2Array, ivc: int, polys: Array) -> void:
	_preview_points = points
	_polygon_2d.polygon = points
	_polygon_2d.uv = points
	_polygon_2d.internal_vertex_count = ivc
	_polygon_2d.polygons = polys
	_polygon_2d.queue_redraw()
	_refresh_preview_transform()

func _on_polygon_display_resized() -> void:
	_refresh_preview_transform()

func _refresh_preview_transform() -> void:
	if not _polygon_2d: return
	var result := PolyRigUtils.calculate_transform(_polygon_2d, _polygon_display.size)
	if result: _polygon_2d.transform = result[0]

func _on_accept_dialog_confirmed() -> void:
	var target := _global.current_polygon
	if not target: return
	var mm := _global.mesh_manager

	var old_snap := PolyRigMeshManager.snapshot(target)
	mm.commit_mesh_geometry_undo("Auto generate mesh", target,
		old_snap, _preview_points.duplicate(), _preview_points.duplicate(),
		_polygon_2d.internal_vertex_count, _polygon_2d.polygons.duplicate(), not _only_mesh)
	target.queue_redraw()


# --- UI callbacks ---

func _density_to_ui(d: float) -> float:
	return _density_field.max_value - d + 1.0

func _ui_to_density(v: float) -> float:
	return _density_field.max_value - v + 1.0

# Syncs UI controls to current variable values when dialog opens.
func _sync_ui() -> void:
	_padding_field.number = _grow_amount
	_density_field.number = _density_to_ui(_density)
	_internal_density_field.number = _internal_density
	_only_mesh_check.set_pressed_no_signal(_only_mesh)

func _update_fields() -> void:
	var locked := _is_generating or _only_mesh
	_padding_field.disabled = locked
	_density_field.disabled = locked
	_internal_density_field.disabled = locked
	_only_mesh_check.disabled = _is_generating
	_progress_bar.visible = _is_generating

func _on_only_mesh_check_box_toggled(toggled_on: bool) -> void:
	_only_mesh = toggled_on
	_update_fields()
	_generate()

func _on_padding_input_field_value_changed(value: float) -> void:
	_grow_amount = value
	_generate()

func _on_density_input_field_value_changed(value: float) -> void:
	_density = _ui_to_density(value)
	_generate()

func _on_internal_density_input_field_value_changed(value: float) -> void:
	_internal_density = value
	_only_outline = value == 0
	_generate()
