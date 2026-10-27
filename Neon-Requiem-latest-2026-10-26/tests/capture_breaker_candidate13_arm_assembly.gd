extends SceneTree

const IMAGE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.png"
const OUTPUT_DIR := "res://docs/visual_qa"
const ARM_SCALE := 0.32
const UPPER_RECT := Rect2i(157, 157, 167, 407)
const SHELL_RECT := Rect2i(487, 112, 328, 260)
const FOREARM_RECT := Rect2i(929, 298, 329, 512)
const ASSEMBLED_RECT := Rect2i(1357, 17, 376, 813)
const ELBOW_OVERLAP := 151.0
const UPPER_ELBOW_X := 80.0
const FOREARM_ELBOW_X := 29.0
const FOREARM_ELBOW_Y := 51.0

var failures := 0


class ReviewStage extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#11171d"), true)
		for x in range(0, 1281, 40):
			draw_line(Vector2(x, 72), Vector2(x, 620), Color(0.18, 0.22, 0.26, 0.32), 1.0)
		for y in range(80, 621, 40):
			draw_line(Vector2(25, y), Vector2(1255, y), Color(0.18, 0.22, 0.26, 0.32), 1.0)
		draw_line(Vector2(25, 620), Vector2(1255, 620), Color("#57dce3"), 2.0)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(26, 66), "ASSEMBLED REFERENCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d9e1e8"))
		draw_string(font, Vector2(340, 66), "SHELL ON / NEUTRAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d9e1e8"))
		draw_string(font, Vector2(645, 66), "SHELL OFF / UNDER-ARM", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d9e1e8"))
		draw_string(font, Vector2(980, 66), "ELBOW FLEX", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d9e1e8"))
		draw_string(font, Vector2(25, 670), "Candidate 13 | alpha overlap test | estimated pivots | 2D review only; hidden 3D anatomy/all-frame seams unverified", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#8c9aa7"))


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(IMAGE_PATH))
	_check(error == OK, "Could not load candidate 13 board.")
	if error != OK:
		quit(1)
		return
	var texture := ImageTexture.create_from_image(image)
	var stage := ReviewStage.new()
	root.add_child(stage)
	_add_region(stage, texture, ASSEMBLED_RECT, Vector2(25.0, 120.0), Vector2(ARM_SCALE, ARM_SCALE), 0)
	var neutral := _build_part_assembly(stage, texture, Vector2(340.0, 120.0), 0.0, true)
	var under_arm := _build_part_assembly(stage, texture, Vector2(655.0, 120.0), 0.0, false)
	var flexed := _build_part_assembly(stage, texture, Vector2(970.0, 120.0), 0.30, true)
	await process_frame
	_check(neutral != null and under_arm != null and flexed != null, "Neutral, shell-off, and elbow-flex trial assemblies must exist.")
	await process_frame
	if failures == 0:
		_save_view("breaker_candidate13_arm_component_anatomy_1280x720.png")
	if failures == 0:
		print("PASS: captured assembled reference, shell-on neutral, shell-off under-arm surface, and elbow-flex review poses.")
		print("LIMIT: this is a manually aligned 2D review harness; anatomical accuracy, hidden 3D structure, and animation seams remain unverified.")
		quit(0)
	else:
		push_error("%d candidate 13 assembly capture check(s) failed." % failures)
		quit(1)


func _build_part_assembly(parent: Node2D, texture: Texture2D, top: Vector2, elbow_rotation: float, include_shell: bool = true) -> Node2D:
	var shoulder := Node2D.new()
	shoulder.position = top
	shoulder.scale = Vector2.ONE * ARM_SCALE
	parent.add_child(shoulder)
	_add_region(shoulder, texture, UPPER_RECT, Vector2.ZERO, Vector2.ONE, 0)
	if include_shell:
		_add_region(shoulder, texture, SHELL_RECT, Vector2(-81.0, -45.0), Vector2.ONE, 1)
	var elbow := Node2D.new()
	elbow.position = Vector2(UPPER_ELBOW_X, UPPER_RECT.size.y - ELBOW_OVERLAP)
	shoulder.add_child(elbow)
	var forearm := _add_region(elbow, texture, FOREARM_RECT, Vector2(-FOREARM_ELBOW_X, -FOREARM_ELBOW_Y), Vector2.ONE, 2)
	elbow.rotation = elbow_rotation
	_check(forearm.region_rect.size == Vector2(FOREARM_RECT.size), "Forearm must use the intended isolated atlas region.")
	return shoulder


func _add_region(parent: Node2D, texture: Texture2D, rect: Rect2i, position: Vector2, scale: Vector2, z: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(rect)
	sprite.centered = false
	sprite.position = position
	sprite.scale = scale
	sprite.z_index = z
	parent.add_child(sprite)
	return sprite


func _save_view(filename: String) -> void:
	var image := root.get_texture().get_image()
	_check(image != null and image.get_size() == Vector2i(1280, 720), "Expected a 1280x720 rendered assembly/anatomy comparison.")
	if image == null or image.is_empty():
		return
	var directory := ProjectSettings.globalize_path(OUTPUT_DIR)
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, "Could not create visual QA directory.")
	var path := directory.path_join(filename)
	if FileAccess.file_exists(path):
		var suffix := 2
		while FileAccess.file_exists(directory.path_join("%s_%02d.png" % [filename.get_basename(), suffix])):
			suffix += 1
		path = directory.path_join("%s_%02d.png" % [filename.get_basename(), suffix])
	_check(image.save_png(path) == OK, "Could not save assembly comparison image.")
	if FileAccess.file_exists(path):
		print("Saved assembly comparison: %s" % path)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 13 ASSEMBLY FAILED: " + message)
