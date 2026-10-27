extends SceneTree

## Static source-to-PolyRig raster check for a quarantined CIPHER rifle image.
## Does not infer placement, grip, pivot, weapon behavior, or production readiness.

const BUILDER := preload("res://tools/art/polyrig_contour_mesh_builder.gd")
const PART_PATH := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png"
const CANVAS_SIZE := Vector2i(1280, 720)
const SOURCE_POS := Vector2i(80, 205)
const MESH_POS := Vector2i(660, 205)
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var image := Image.new()
	_check(image.load(ProjectSettings.globalize_path(PART_PATH)) == OK, "CIPHER rifle candidate source loads.")
	if image.is_empty():
		quit(1)
		return
	var bounds := image.get_used_rect().grow(8).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	_check(bounds.has_area(), "CIPHER rifle cutout has a non-empty native-scale crop.")
	_check(MESH_POS.x + bounds.size.x < CANVAS_SIZE.x and MESH_POS.y + bounds.size.y < CANVAS_SIZE.y, "Native-scale rifle mesh fits the review canvas.")
	if not bounds.has_area():
		quit(1)
		return
	var board := Node2D.new()
	board.name = "CipherRiflePolyRigFidelityDiagnostic"
	root.add_child(board)
	var bg := ColorRect.new()
	bg.size = Vector2(CANVAS_SIZE)
	bg.color = Color("#090d16")
	board.add_child(bg)
	_add_label(board, "CIPHER TIER I — RIFLE CUTOUT / POLYRIG MESH", 16, 14, Color("#ff76ba"), 1248, 18)
	_add_label(board, "Static native-scale render check • quarantined art • no grip, pivot, mounting, behavior, or production approval", 16, 42, Color("#bac6d8"), 1248, 11)
	var crop_texture := ImageTexture.create_from_image(image.get_region(bounds))
	var source := Sprite2D.new()
	source.texture = crop_texture
	source.centered = false
	source.position = Vector2(SOURCE_POS)
	source.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	board.add_child(source)
	var full_texture := ImageTexture.create_from_image(image)
	var mesh_owner := Node2D.new()
	mesh_owner.position = Vector2(MESH_POS - bounds.position)
	mesh_owner.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	board.add_child(mesh_owner)
	var build: Dictionary = BUILDER.append_contour_meshes(image, full_texture, mesh_owner, "cipher_rifle")
	_check(bool(build.get("ok", false)), "CIPHER rifle cutout builds contour meshes: %s" % str(build.get("error", "")))
	_add_label(board, "SOURCE CUTOUT", SOURCE_POS.x, SOURCE_POS.y - 22, Color("#69e3ee"), 500, 11)
	_add_label(board, "POLYRIG CONTOUR RENDER", MESH_POS.x, MESH_POS.y - 22, Color("#69e3ee"), 500, 11)
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var frame := root.get_texture().get_image()
	_check(frame != null and frame.get_size() == CANVAS_SIZE, "Godot produced a 1280x720 render for pixel comparison.")
	var diff_count := 0
	var opaque_interior_diffs := 0
	var sample_count := bounds.size.x * bounds.size.y
	if frame != null and frame.get_size() == CANVAS_SIZE:
		for y in range(bounds.size.y):
			for x in range(bounds.size.x):
				var a := frame.get_pixel(SOURCE_POS.x + x, SOURCE_POS.y + y)
				var b := frame.get_pixel(MESH_POS.x + x, MESH_POS.y + y)
				var delta := absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
				if delta > 0.08:
					diff_count += 1
					var ix := bounds.position.x + x
					var iy := bounds.position.y + y
					if image.get_pixel(ix, iy).a >= 0.99 and not _has_edge_neighbor(image, ix, iy):
						opaque_interior_diffs += 1
	var ratio := float(diff_count) / float(maxi(sample_count, 1))
	var contours := int(build.get("contour_count", 0))
	var polyrig_count := int(build.get("polyrig_count", 0))
	var fallback_count := int(build.get("godot_fallback_count", 0))
	print("CIPHER rifle: %d/%d crop pixels differ (%.5f%%); opaque interior deltas %d; contours %d, PolyRig %d, fallback %d." % [diff_count, sample_count, ratio * 100.0, opaque_interior_diffs, contours, polyrig_count, fallback_count])
	_check(ratio <= 0.01, "CIPHER rifle source and PolyRig static render differ by no more than the provisional 1% diagnostic bound.")
	_check(opaque_interior_diffs == 0, "CIPHER rifle fully opaque interior pixels are preserved.")
	_check(contours > 0 and polyrig_count == contours and fallback_count == 0, "Every rifle contour triangulates through PolyRig without fallback.")
	_add_label(board, "DIFF %.4f%% • %d CONTOUR(S)" % [ratio * 100.0, contours], 16, 520, Color("#b8c6da"), 600, 11)
	_add_label(board, "MECHANICAL MESH FIDELITY ONLY — SEMANTIC OWNERSHIP, SCOPE/RIFLE SOURCE MATCH, GRIP PIVOT, POSE, DEFORMATION, AND RUNTIME ARE UNVERIFIED", 16, 550, Color("#f0c674"), 1248, 10)
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var final_frame := root.get_texture().get_image()
	var out := _next_output()
	_check(not out.is_empty(), "Refuse to overwrite an existing CIPHER rifle diagnostic.")
	if not out.is_empty() and final_frame != null:
		var save_error := final_frame.save_png(ProjectSettings.globalize_path(out))
		_check(save_error == OK, "Save new quarantined CIPHER rifle diagnostic image.")
		if save_error == OK:
			print("Saved: ", out)
	if failures.is_empty():
		print("PASS: CIPHER rifle cutout retains raster appearance through a static PolyRig contour mesh.")
		print("LIMIT: this is not a grip/pivot or pose validation; rifle and optic remain quarantined and no behavior is implemented.")
		quit(0)
	else:
		push_error("%d CIPHER rifle mesh-fidelity check(s) failed." % failures.size())
		quit(1)

func _has_edge_neighbor(image: Image, x: int, y: int) -> bool:
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var point := Vector2i(x, y) + offset
		if point.x >= 0 and point.y >= 0 and point.x < image.get_width() and point.y < image.get_height() and image.get_pixelv(point).a < 0.99:
			return true
	return false

func _add_label(parent: Node2D, value: String, x: int, y: int, color: Color, width: float, font_size: int) -> void:
	var label := Label.new()
	label.position = Vector2(x, y)
	label.size = Vector2(width, 22)
	label.text = value
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)

func _next_output() -> String:
	for index in range(1, 100):
		var candidate := "res://docs/visual_qa/CIPHER_T1_RIFLE_POLYRIG_FIDELITY_%02d_QUARANTINED.png" % index
		if not FileAccess.file_exists(candidate):
			return candidate
	return ""

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("CIPHER RIFLE CHECK FAILED: " + message)
