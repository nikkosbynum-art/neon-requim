extends SceneTree

const SOURCE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
const BOARD_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.png"
const OUTPUT_DIR := "res://docs/visual_qa"
const SOURCE_ARM_HEIGHT := 422.0
const CANDIDATE_ARM_HEIGHT := 813.0
const DISPLAY_ZOOM := 0.35
const CANDIDATE_SCALE := DISPLAY_ZOOM * SOURCE_ARM_HEIGHT / CANDIDATE_ARM_HEIGHT
const ASSEMBLED_RECT := Rect2i(1357, 17, 376, 813)

var failures := 0


class ScaleReview extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#11171d"), true)
		for x in range(0, 1281, 40):
			draw_line(Vector2(x, 68), Vector2(x, 620), Color(0.18, 0.22, 0.26, 0.30), 1.0)
		for y in range(80, 621, 40):
			draw_line(Vector2(30, y), Vector2(1240, y), Color(0.18, 0.22, 0.26, 0.30), 1.0)
		draw_line(Vector2(30, 620), Vector2(1240, 620), Color("#57dce3"), 2.0)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(34, 45), "BREAKER REFERENCE SCALE CHECK — HEIGHT ONLY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e5eaf0"))
		draw_string(font, Vector2(40, 72), "FULL BODY REFERENCE | 2× 256 PX TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d9e1e8"))
		draw_string(font, Vector2(625, 72), "CANDIDATE 13 | HEIGHT MATCHED AT 0.519×", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d9e1e8"))
		draw_string(font, Vector2(625, 648), "Different pose/orientation; this checks scale only, not profile/silhouette fit.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#8c9aa7"))
		draw_string(font, Vector2(625, 670), "Full-body proportions still need visual approval; estimated pivots and hidden structures are unverified.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#8c9aa7"))
		var expected_height := SOURCE_ARM_HEIGHT * DISPLAY_ZOOM
		draw_line(Vector2(690, 230), Vector2(690, 230 + expected_height), Color("#57dce3"), 2.0)
		draw_line(Vector2(682, 230), Vector2(698, 230), Color("#57dce3"), 2.0)
		draw_line(Vector2(682, 230 + expected_height), Vector2(698, 230 + expected_height), Color("#57dce3"), 2.0)
		draw_string(font, Vector2(705, 310), "148 px", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#57dce3"))


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var source_image := Image.new()
	var source_error := source_image.load(ProjectSettings.globalize_path(SOURCE_PATH))
	_check(source_error == OK and source_image.get_size() == Vector2i(1024, 1536), "Expected candidate 09 full-body reference at 1024x1536.")
	var board_image := Image.new()
	var board_error := board_image.load(ProjectSettings.globalize_path(BOARD_PATH))
	_check(board_error == OK and board_image.get_size() == Vector2i(1774, 887), "Expected candidate 13 arm board at 1774x887.")
	if failures > 0:
		quit(1)
		return

	var stage := ScaleReview.new()
	root.add_child(stage)
	_add_texture(stage, ImageTexture.create_from_image(source_image), Vector2(40.0, 75.0), DISPLAY_ZOOM, 0)
	_add_region(stage, ImageTexture.create_from_image(board_image), ASSEMBLED_RECT, Vector2(760.0, 230.0), CANDIDATE_SCALE, 1)
	await process_frame
	await process_frame
	var rendered := root.get_texture().get_image()
	_check(rendered != null and rendered.get_size() == Vector2i(1280, 720), "Expected a 1280x720 rendered scale review.")
	if rendered == null or rendered.is_empty():
		quit(1)
		return
	var directory := ProjectSettings.globalize_path(OUTPUT_DIR)
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, "Could not create visual QA directory.")
	var path := directory.path_join("breaker_candidate13_reference_scale_1280x720.png")
	if FileAccess.file_exists(path):
		var suffix := 2
		while FileAccess.file_exists(directory.path_join("breaker_candidate13_reference_scale_1280x720_%02d.png" % suffix)):
			suffix += 1
		path = directory.path_join("breaker_candidate13_reference_scale_1280x720_%02d.png" % suffix)
	var save_error := rendered.save_png(path)
	_check(save_error == OK, "Could not save reference scale review.")
	if failures == 0:
		print("PASS: rendered the full-body reference and candidate 13 arm at a matched 422 px source-height ratio (scale %.3f)." % (SOURCE_ARM_HEIGHT / CANDIDATE_ARM_HEIGHT))
		print("LIMIT: height-only comparison; pose, orientation, width, and silhouette fit are not verified.")
		print("Saved reference scale review: %s" % path)
		quit(0)
	else:
		push_error("%d reference scale review check(s) failed." % failures)
		quit(1)


func _add_texture(parent: Node2D, texture: Texture2D, position: Vector2, scale: float, z: int) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.position = position
	sprite.scale = Vector2.ONE * scale
	sprite.z_index = z
	parent.add_child(sprite)


func _add_region(parent: Node2D, texture: Texture2D, region: Rect2i, position: Vector2, scale: float, z: int) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(region)
	sprite.centered = false
	sprite.position = position
	sprite.scale = Vector2.ONE * scale
	sprite.z_index = z
	parent.add_child(sprite)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 13 SCALE REVIEW FAILED: " + message)
