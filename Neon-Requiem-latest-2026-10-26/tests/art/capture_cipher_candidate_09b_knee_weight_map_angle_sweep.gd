extends "res://tests/art/capture_cipher_candidate_09b_knee_weight_map_feasibility.gd"

## Produces a quarantined visual diagnostic of the existing CIPHER 09B skinned
## parts across a fixed knee-angle sweep. It uses source-derived export layers,
## the approved knee pivot, and the current 44 px test half-band only. It does
## not load, create, or modify underpaint, source ORAs, or runtime assets. The
## mesh builder supplies explicit triangle indices; review boundary seams
## separately from interior triangle folds or texture shear.

const SWEEP_OUTPUT_PATH := "res://docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHT_MAP_ANGLE_SWEEP_GODOT_08_QUARANTINED.png"
const SWEEP_CANVAS_SIZE := Vector2i(1640, 500)
const SWEEP_PANEL_X := [40.0, 370.0, 700.0, 1030.0, 1360.0]
const SWEEP_ANGLES := [-20.0, -10.0, 0.0, 10.0, 20.0]
const SWEEP_PANEL_Y := 105.0
const SWEEP_WEIGHT_BAND := 44.0


func _initialize() -> void:
	root.size = SWEEP_CANVAS_SIZE
	call_deferred("_capture")


func _capture() -> void:
	var candidate_manifest := _read_json(CANDIDATE_ROOT + "parts_manifest.json")
	var export_manifest := _read_json(EXPORT_ROOT + "review_manifest.json")
	_check(not candidate_manifest.is_empty(), "Candidate manifest should load.")
	_check(not export_manifest.is_empty(), "Krita-layer export manifest should load.")
	if candidate_manifest.is_empty() or export_manifest.is_empty():
		quit(1)
		return
	_check(export_manifest.get("status") == "REVIEW CANDIDATE - QUARANTINED", "Export must remain quarantined.")
	_check(export_manifest.get("production_approved", true) == false and export_manifest.get("runtime_integrated", true) == false, "Export cannot be promoted by this capture.")
	var export_canvas: Array = export_manifest.get("canvas_px", [])
	_check(export_canvas.size() == 2 and int(export_canvas[0]) == 330 and int(export_canvas[1]) == 960, "Export must retain the source profile canvas.")
	var source_pivot: Array = candidate_manifest.get("pivot", {}).get("source_xy", [])
	_check(source_pivot.size() == 2 and int(source_pivot[0]) == 770 and int(source_pivot[1]) == 665, "The approved source pivot must be retained.")
	_check(candidate_manifest.get("inferred_underpaint_review", {}).get("runtime_integration", true) == false, "Inferred underpaint must remain out of runtime.")
	_check(not FileAccess.file_exists(SWEEP_OUTPUT_PATH), "Refusing to overwrite an existing angle-sweep review board: " + SWEEP_OUTPUT_PATH)
	if not errors.is_empty() or FileAccess.file_exists(SWEEP_OUTPUT_PATH):
		quit(1)
		return

	var capture_viewport := SubViewport.new()
	capture_viewport.name = "CIPHER09BAngleSweepCaptureViewport"
	capture_viewport.size = SWEEP_CANVAS_SIZE
	capture_viewport.transparent_bg = false
	capture_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture_viewport)
	var board := Node2D.new()
	board.name = "CIPHER09BKneeWeightMapAngleSweep"
	capture_viewport.add_child(board)
	_add_sweep_background(board)
	_add_label(board, 12.0, "CIPHER TIER I • 09B • WEIGHTED KNEE ANGLE SWEEP", Color("#ff76ba"), 1616.0, 12.0, 20)
	for index in range(SWEEP_ANGLES.size()):
		var angle: float = SWEEP_ANGLES[index]
		var angle_label := ("+%.0f°" % angle) if angle > 0.0 else "%.0f°" % angle
		_add_label(board, SWEEP_PANEL_X[index], angle_label, Color("#62e5ed"), PANEL_SIZE.x, 73.0, 16)
		_add_skinned_sweep_panel(board, export_manifest, SWEEP_PANEL_X[index], SWEEP_PANEL_Y, angle, SWEEP_WEIGHT_BAND)
	_add_label(board, 12.0, "Same source-derived parts • approved pivot [770,665] / crop [170,655] • current 44 px half-band test weights", Color("#bac6d8"), 1616.0, 410.0, 13)
	_add_label(board, 12.0, "No underpaint is drawn in any panel. Hip placement and weights remain test estimates; angles are illustrative, not an approved motion range.", Color("#bac6d8"), 1616.0, 432.0, 12)
	_add_label(board, 12.0, "Diagnostic only: separate silhouette-edge gaps from interior triangle folds or texture shear. No full-rig, continuous-motion, art, or runtime approval; candidate remains quarantined.", Color("#bac6d8"), 1616.0, 452.0, 11)
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var frame := capture_viewport.get_texture().get_image()
	_check(frame != null and frame.get_size() == SWEEP_CANVAS_SIZE, "Godot should render the 1640x500 angle-sweep board.")
	if frame != null and frame.get_size() == SWEEP_CANVAS_SIZE:
		_check(frame.save_png(ProjectSettings.globalize_path(SWEEP_OUTPUT_PATH)) == OK, "Godot should save the quarantined angle-sweep board.")
	if errors.is_empty():
		print("PASS: Godot rendered the quarantined CIPHER 09B weighted-knee angle sweep at -20, -10, 0, +10, and +20 degrees using the current 44 px test half-band.")
		print("LIMIT: no underpaint is drawn; the capture does not approve art, a motion range, full-rig behavior, continuous deformation, or runtime use.")
		quit(0)
	else:
		push_error("%d weighted-knee angle-sweep capture check(s) failed." % errors.size())
		quit(1)


func _add_skinned_sweep_panel(board: Node2D, manifest: Dictionary, panel_x: float, panel_y: float, knee_angle_degrees: float, weight_band: float) -> void:
	var container := _make_panel_viewport(board, panel_x, panel_y)
	var viewport := container.get_child(0) as SubViewport
	var pose_root := Node2D.new()
	pose_root.name = "WeightedPose_%s" % str(knee_angle_degrees).replace("-", "minus")
	pose_root.position = -Vector2(CROP.position)
	viewport.add_child(pose_root)

	var skeleton := Skeleton2D.new()
	skeleton.name = "CIPHER_09B_KneeTestSkeleton"
	skeleton.position = APPROVED_KNEE
	pose_root.add_child(skeleton)
	var root_bone := _make_bone("knee_test_root", skeleton, Vector2.ZERO, 155.0)
	var upper := _make_bone("near_thigh", root_bone, HIP_ANCHOR - APPROVED_KNEE, 155.0)
	var knee := _make_bone("near_knee_APPROVED_PIVOT", upper, APPROVED_KNEE - HIP_ANCHOR, SHIN_END_TEST.distance_to(APPROVED_KNEE))
	knee.rotation = deg_to_rad(knee_angle_degrees)
	var mesh_root := Node2D.new()
	mesh_root.name = "SkinnedMeshes"
	pose_root.add_child(mesh_root)

	var layer_order: Array[String] = []
	for part in manifest.get("parts", []):
		if part is Dictionary:
			layer_order.append(str(part.get("part_id", "")))
	for part_id in ["near_thigh", "near_shin", "near_knee_guard", "near_boot"]:
		if not layer_order.has(part_id):
			_check(false, "Krita export must contain %s." % part_id)
			continue
		var part_image := _load_image(EXPORT_ROOT + "parts/" + part_id + ".png")
		if part_image == null:
			continue
		var texture := ImageTexture.create_from_image(part_image)
		var joint_blend: bool = part_id in ["near_thigh", "near_shin"]
		var fixed_to_knee: bool = part_id in ["near_boot", "near_knee_guard"]
		var mesh_count := _add_skinned_texture(mesh_root, skeleton, upper, knee, part_id, texture, part_image, joint_blend, fixed_to_knee, weight_band)
		_check(mesh_count > 0, "%s should produce at least one skinned contour mesh." % part_id)
	_add_pivot_crosshair(viewport)


func _add_sweep_background(board: Node2D) -> void:
	var background := ColorRect.new()
	background.size = Vector2(SWEEP_CANVAS_SIZE)
	background.color = Color("#090d16")
	board.add_child(background)
	for panel_x in SWEEP_PANEL_X:
		var tile := ColorRect.new()
		tile.position = Vector2(panel_x, SWEEP_PANEL_Y)
		tile.size = Vector2(PANEL_SIZE)
		tile.color = Color("#202632")
		board.add_child(tile)
		for y in range(0, PANEL_SIZE.y, 16):
			for x in range(0, PANEL_SIZE.x, 16):
				if ((x / 16) + (y / 16)) % 2 != 0:
					var checker := ColorRect.new()
					checker.position = tile.position + Vector2(x, y)
					checker.size = Vector2(16, 16)
					checker.color = Color("#29313d")
					board.add_child(checker)
