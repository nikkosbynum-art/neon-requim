extends Node2D

## Game-scale Tier I roster mockup assembled from approved references and
## quarantined review candidates. This is presentation-only, not runtime art.

const MESH_RIG := preload("res://tests/art/founding_t1_profile_mesh_rig_candidate.gd")
const CIPHER_RIG := preload("res://tests/art/cipher_t1_reference_cutout_rig_candidate.gd")
const BREAKER_REFERENCE := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png"
const OUTPUT_PATH := "res://docs/visual_qa/FOUNDING_ROSTER_GAME_SCALE_PREVIEW_01.png"
const IDS := [
	"BULWARK", "BREAKER", "CIPHER", "SPARK",
	"SPECTER", "IRONCLAD", "STITCH", "RECOIL",
	"ECHO", "VECTOR", "DEADLOCK", "GLITCH",
]
const MESH_IDS := [
	"BULWARK", "SPARK", "SPECTER", "IRONCLAD", "STITCH",
	"RECOIL", "ECHO", "VECTOR", "DEADLOCK", "GLITCH",
]
const CANVAS_SIZE := Vector2i(1280, 720)
const COLUMNS := 4
const CELL_SIZE := Vector2(320, 220)
const FIRST_ROW_Y := 48.0
const TARGET_CHARACTER_HEIGHT := 148.0

var preview_errors: Array[String] = []


func _ready() -> void:
	get_window().title = "Neon Requiem — Tier I Roster Preview (Review Only)"
	await _build_roster()
	queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	_save_preview_image()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, CANVAS_SIZE), Color("#080a12"), true)
	for i in range(30):
		var x := fposmod(float(i * 97 + 11), CANVAS_SIZE.x)
		var y := fposmod(float(i * 151 + 7), CANVAS_SIZE.y)
		draw_line(Vector2(x, y), Vector2(x - 4, y + 15), Color(0.14, 0.58, 0.68, 0.16), 1.0)
	for i in range(COLUMNS):
		var x := float(i) * CELL_SIZE.x
		draw_line(Vector2(x, FIRST_ROW_Y), Vector2(x, CANVAS_SIZE.y), Color(0.18, 0.42, 0.5, 0.16), 1.0)
	for row in range(3):
		var top := FIRST_ROW_Y + float(row) * CELL_SIZE.y
		draw_line(Vector2(0, top), Vector2(CANVAS_SIZE.x, top), Color(0.18, 0.42, 0.5, 0.28), 1.0)
		draw_line(Vector2(0, top + 174.0), Vector2(CANVAS_SIZE.x, top + 174.0), Color(0.08, 0.82, 0.88, 0.44), 1.0)
	draw_line(Vector2(0, CANVAS_SIZE.y - 1), Vector2(CANVAS_SIZE.x, CANVAS_SIZE.y - 1), Color(0.18, 0.42, 0.5, 0.28), 1.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(20, 27), "NEON REQUIEM  /  TIER I ROSTER", HORIZONTAL_ALIGNMENT_LEFT, 900, 20, Color("#ecf5ff"))
	draw_string(font, Vector2(942, 27), "GAME-SCALE REVIEW MOCKUP", HORIZONTAL_ALIGNMENT_RIGHT, 318, 13, Color("#ff5fb3"))
	for index in range(IDS.size()):
		var col := index % COLUMNS
		var row := floori(float(index) / float(COLUMNS))
		var x := float(col) * CELL_SIZE.x
		var y := FIRST_ROW_Y + float(row) * CELL_SIZE.y
		draw_string(font, Vector2(x + 8, y + 19), IDS[index], HORIZONTAL_ALIGNMENT_CENTER, CELL_SIZE.x - 16, 15, Color("#62e5ed"))
		var provenance := "APPROVED LOOK • STATIC REF" if IDS[index] == "BREAKER" else "QUARANTINED RIG CANDIDATE"
		draw_string(font, Vector2(x + 6, y + 211), provenance, HORIZONTAL_ALIGNMENT_CENTER, CELL_SIZE.x - 12, 9, Color(0.72, 0.78, 0.87, 0.76))
	draw_string(font, Vector2(12, CANVAS_SIZE.y - 5), "Tier I references and review candidates only • not production sprites, approved animation, or a 12-unit combat formation", HORIZONTAL_ALIGNMENT_LEFT, CANVAS_SIZE.x - 24, 10, Color("#aab5c8"))


func _build_roster() -> void:
	for index in range(IDS.size()):
		var character_id: String = IDS[index]
		var cell_center := Vector2((index % COLUMNS) * CELL_SIZE.x + CELL_SIZE.x * 0.5, FIRST_ROW_Y + floori(float(index) / float(COLUMNS)) * CELL_SIZE.y + 102.0)
		var ground_y := FIRST_ROW_Y + floori(float(index) / float(COLUMNS)) * CELL_SIZE.y + 174.0
		if MESH_IDS.has(character_id):
			_add_mesh_candidate(character_id, cell_center, ground_y)
		elif character_id == "CIPHER":
			await _add_cipher_candidate(cell_center, ground_y)
		else:
			_add_breaker_reference(cell_center, ground_y)


func _fit_scale(bounds: Rect2i) -> float:
	var height_scale := TARGET_CHARACTER_HEIGHT / maxf(float(bounds.size.y), 1.0)
	var width_scale := CELL_SIZE.x * 0.44 / maxf(float(bounds.size.x), 1.0)
	return minf(height_scale, width_scale)


func _add_mesh_candidate(character_id: String, cell_center: Vector2, ground_y: float) -> void:
	var rig = MESH_RIG.new()
	rig.name = character_id + "_QuarantinedProfileMesh"
	add_child(rig)
	if not rig.build(character_id.to_lower()):
		preview_errors.append(character_id + ": " + rig.load_error)
		return
	rig.set_pose("idle")
	var bounds: Rect2i = rig.texture.get_image().get_used_rect()
	var fit := _fit_scale(bounds)
	rig.scale = Vector2.ONE * fit
	rig.position = Vector2(cell_center.x, ground_y) - rig.source_ground * fit


func _add_cipher_candidate(cell_center: Vector2, ground_y: float) -> void:
	var rig = CIPHER_RIG.new()
	rig.name = "CIPHER_QuarantinedCutout"
	add_child(rig)
	await get_tree().process_frame
	if not rig.load_failures.is_empty():
		preview_errors.append("CIPHER: " + ", ".join(rig.load_failures))
	rig.scale = Vector2.ONE * 0.14
	rig.position = Vector2(cell_center.x, ground_y)
	rig.set_pose("idle")


func _add_breaker_reference(cell_center: Vector2, ground_y: float) -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(BREAKER_REFERENCE))
	if error != OK:
		preview_errors.append("BREAKER: could not load approved profile reference.")
		return
	var texture := ImageTexture.create_from_image(image)
	var sprite := Sprite2D.new()
	sprite.name = "BREAKER_ApprovedProfileReference"
	sprite.texture = texture
	var bounds := image.get_used_rect()
	var fit := _fit_scale(bounds)
	sprite.scale = Vector2.ONE * fit
	var image_ground := float(bounds.position.y + bounds.size.y) - float(image.get_height()) * 0.5
	sprite.position = Vector2(cell_center.x, ground_y - image_ground * fit)
	add_child(sprite)


func _save_preview_image() -> void:
	var image := get_viewport().get_texture().get_image()
	if image.get_size() != CANVAS_SIZE:
		image.resize(CANVAS_SIZE.x, CANVAS_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var path := ProjectSettings.globalize_path(OUTPUT_PATH)
	var save_error := image.save_png(path)
	if save_error != OK:
		push_error("Could not save roster preview: " + path)
		return
	if not preview_errors.is_empty():
		push_warning("Roster preview has missing candidates: " + "; ".join(preview_errors))
	print("Saved review-only roster preview: " + path)
