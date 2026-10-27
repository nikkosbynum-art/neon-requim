extends SceneTree

## Normal-renderer comparison of the quarantined SPARK drone cutouts against
## their Polygon2D contour meshes. No art, pivots, rigs, or behavior are edited.

const BUILDER := preload("res://tools/art/polyrig_contour_mesh_builder.gd")
const CANVAS_SIZE := Vector2i(1280, 720)
const DRONE_FILES := [
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_01_BLUE_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_02_RED_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_03_AMBER_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
]
const DISPLAY_SCALE := 0.45

var errors: Array[String] = []
var results: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_check(DRONE_FILES.size() == 3, "The source-backed SPARK drone review should contain exactly three candidates.")
	for index in range(DRONE_FILES.size()):
		var image := _load_image(DRONE_FILES[index])
		if image == null:
			continue
		var texture := ImageTexture.create_from_image(image)
		var item_result: Dictionary = await _compare_native(image, texture, index + 1)
		results.append(item_result)
	_check(results.size() == 3, "Every SPARK drone should complete a native-scale renderer comparison.")
	if results.size() == 3:
		var board := _build_review_board()
		root.add_child(board)
		await process_frame
		await process_frame
		RenderingServer.force_draw(false)
		var frame := root.get_texture().get_image()
		var valid_frame := frame != null and frame.get_size() == CANVAS_SIZE
		_check(valid_frame, "Godot should render the SPARK comparison board at 1280x720.")
		if valid_frame:
			var out_path := _next_output_path()
			if not out_path.is_empty():
				var save_error := frame.save_png(ProjectSettings.globalize_path(out_path))
				_check(save_error == OK, "Godot should save the quarantined review board.")
				if save_error == OK:
					print("Saved SPARK drone mesh fidelity board: ", out_path)
	if errors.is_empty():
		print("PASS: all three SPARK drone source textures match their contour-mesh renders within the provisional 1% sampled-pixel bound.")
		print("LIMIT: static raster fidelity only; the drone art remains quarantined and side-view adaptation, semantic completeness, pivots, articulation, behavior, and runtime integration remain unverified.")
		quit(0)
	else:
		push_error("%d SPARK contour-mesh render check(s) failed." % errors.size())
		quit(1)


func _compare_native(image: Image, texture: Texture2D, drone_number: int) -> Dictionary:
	var width := image.get_width()
	var height := image.get_height()
	var source_position := Vector2i(64, 120)
	var mesh_position := Vector2i(640, 120)
	var fits := width > 0 and height > 0 and source_position.x + width <= CANVAS_SIZE.x and mesh_position.x + width <= CANVAS_SIZE.x and source_position.y + height <= CANVAS_SIZE.y and mesh_position.y + height <= CANVAS_SIZE.y
	_check(fits, "Drone image should fit the native-scale test viewport: %02d" % drone_number)
	if not fits:
		return {"drone": drone_number, "ok": false}

	var stage := Node2D.new()
	stage.name = "SparkDroneNativeMeshTest_%02d" % drone_number
	root.add_child(stage)
	_add_background(stage, CANVAS_SIZE, Color("#131923"))
	_add_label(stage, "DRONE %02d — SOURCE TEXTURE" % drone_number, 40, 62, Color("#69e3ee"))
	_add_label(stage, "DRONE %02d — POLYRIG CONTOUR MESH" % drone_number, 620, 62, Color("#69e3ee"))
	_add_source_sprite(stage, texture, source_position)
	var mesh_owner := Node2D.new()
	mesh_owner.name = "drone_%02d_mesh_owner" % drone_number
	mesh_owner.position = Vector2(mesh_position)
	mesh_owner.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stage.add_child(mesh_owner)
	var build_result: Dictionary = BUILDER.append_contour_meshes(image, texture, mesh_owner, "drone_%02d" % drone_number)
	_check(bool(build_result.get("ok", false)), "Drone mesh should build with the shared helper: %02d %s" % [drone_number, build_result.get("error", "")])
	_check(int(build_result.get("contour_count", 0)) == 1 and mesh_owner.get_child_count() == 1, "Each source cutout should render as exactly one mesh contour: %02d" % drone_number)
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var frame := root.get_texture().get_image()
	var frame_valid := frame != null and frame.get_size() == CANVAS_SIZE
	_check(frame_valid, "Godot should render the native-scale drone comparison viewport.")
	var diff := {"difference_count": 0, "strong_count": 0, "opaque_interior_count": 0, "sample_count": width * height, "ratio": 1.0}
	if frame_valid:
		diff = _compare_rendered_regions(frame, image, source_position, mesh_position)
		print("SPARK drone %02d native render: %d/%d pixels differ (%.5f%%), strong deltas %d, opaque-interior deltas %d." % [drone_number, diff.difference_count, diff.sample_count, diff.ratio * 100.0, diff.strong_count, diff.opaque_interior_count])
		_check(float(diff.ratio) <= 0.01, "Drone source and contour mesh should differ by no more than 1%% of native samples: %02d (%.5f%%)." % [drone_number, float(diff.ratio) * 100.0])
		_check(int(diff.opaque_interior_count) == 0, "Drone mesh should preserve all fully opaque interior pixels: %02d (%d deltas)." % [drone_number, int(diff.opaque_interior_count)])
	stage.queue_free()
	await process_frame
	return {"drone": drone_number, "ok": frame_valid and float(diff.ratio) <= 0.01 and int(diff.opaque_interior_count) == 0}


func _compare_rendered_regions(frame: Image, source_image: Image, source_position: Vector2i, mesh_position: Vector2i) -> Dictionary:
	var differences := 0
	var strong_differences := 0
	var opaque_interior_differences := 0
	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			var source_color := frame.get_pixel(source_position.x + x, source_position.y + y)
			var mesh_color := frame.get_pixel(mesh_position.x + x, mesh_position.y + y)
			var delta := absf(source_color.r - mesh_color.r) + absf(source_color.g - mesh_color.g) + absf(source_color.b - mesh_color.b)
			if delta > 0.08:
				differences += 1
				if delta > 0.25:
					strong_differences += 1
				if source_image.get_pixel(x, y).a >= 0.99 and not _has_alpha_edge_neighbor(source_image, x, y):
					opaque_interior_differences += 1
	var sample_count := source_image.get_width() * source_image.get_height()
	return {
		"difference_count": differences,
		"strong_count": strong_differences,
		"opaque_interior_count": opaque_interior_differences,
		"sample_count": sample_count,
		"ratio": float(differences) / float(maxi(sample_count, 1)),
	}


func _build_review_board() -> Node2D:
	var board := Node2D.new()
	board.name = "SparkDroneContourFidelityBoard"
	_add_background(board, CANVAS_SIZE, Color("#090d16"))
	_add_label(board, "SPARK ATTACK DRONES — SOURCE TEXTURE / POLYRIG CONTOUR MESH", 0, 16, Color("#ff76ba"), CANVAS_SIZE.x, 18)
	_add_label(board, "Static raster check only • quarantined reference cutouts • no pivots, articulation, or runtime behavior implied", 0, 42, Color("#bac6d8"), CANVAS_SIZE.x, 11)
	for index in range(DRONE_FILES.size()):
		var image := _load_image(DRONE_FILES[index])
		if image == null:
			continue
		var y := 82.0 + float(index) * 204.0
		var source_texture := ImageTexture.create_from_image(image)
		var source_sprite := Sprite2D.new()
		source_sprite.texture = source_texture
		source_sprite.centered = false
		source_sprite.position = Vector2(270.0 - image.get_width() * DISPLAY_SCALE / 2.0, y + 18.0)
		source_sprite.scale = Vector2.ONE * DISPLAY_SCALE
		source_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		board.add_child(source_sprite)
		var mesh_root := Node2D.new()
		mesh_root.position = Vector2(900.0 - image.get_width() * DISPLAY_SCALE / 2.0, y + 18.0)
		mesh_root.scale = Vector2.ONE * DISPLAY_SCALE
		mesh_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		board.add_child(mesh_root)
		var build_result: Dictionary = BUILDER.append_contour_meshes(image, source_texture, mesh_root, "drone_%02d" % (index + 1))
		_check(bool(build_result.get("ok", false)), "Board meshes should build for each SPARK drone.")
		_add_label(board, "DRONE %02d — SOURCE" % (index + 1), 40, int(y), Color("#69e3ee"), 460.0, 12)
		_add_label(board, "DRONE %02d — MESH" % (index + 1), 670, int(y), Color("#69e3ee"), 460.0, 12)
	return board


func _add_source_sprite(parent: Node2D, texture: Texture2D, position_px: Vector2i) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.position = Vector2(position_px)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)


func _add_background(parent: Node2D, size: Vector2i, color: Color) -> void:
	var background := ColorRect.new()
	background.size = Vector2(size)
	background.color = color
	parent.add_child(background)


func _add_label(parent: Node2D, text_value: String, x: int, y: int, color: Color, width: float = 520.0, font_size: int = 14) -> void:
	var label := Label.new()
	label.position = Vector2(x, y)
	label.size = Vector2(width, 22.0)
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)


func _load_image(path: String) -> Image:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(path))
	_check(error == OK, "SPARK drone image should load: " + path.get_file())
	return image if error == OK else null


func _has_alpha_edge_neighbor(image: Image, x: int, y: int) -> bool:
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var neighbor: Vector2i = Vector2i(x, y) + offset
		if neighbor.x >= 0 and neighbor.y >= 0 and neighbor.x < image.get_width() and neighbor.y < image.get_height() and image.get_pixelv(neighbor).a < 0.99:
			return true
	return false


func _next_output_path() -> String:
	for index in range(1, 100):
		var path := "res://docs/visual_qa/SPARK_DRONE_POLYRIG_MESH_FIDELITY_%02d_QUARANTINED.png" % index
		if not FileAccess.file_exists(path):
			return path
	_check(false, "No free output filename available for the review board.")
	return ""


func _check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)
		push_error("CHECK FAILED: " + message)
