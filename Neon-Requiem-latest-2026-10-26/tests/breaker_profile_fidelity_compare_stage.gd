extends Node2D

const REFERENCE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png"
const EDIT_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_hidden_anatomy_candidate_03.png"
const GROUND_Y := 642.0
const DISPLAY_HEIGHT := 450.0
const SOURCE_VISIBLE_HEIGHT := 1427.0


func _ready() -> void:
	for spec in [
		{"path": REFERENCE_PATH, "x": 320.0, "label": "APPROVED PROFILE / CANDIDATE 01"},
		{"path": EDIT_PATH, "x": 960.0, "label": "HIDDEN-ANATOMY EDIT / CANDIDATE 03"}
	]:
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(str(spec["path"])))
		if error != OK:
			push_error("Fidelity comparison could not load %s." % str(spec["path"]))
			continue
		var sprite := Sprite2D.new()
		sprite.name = str(spec["label"]).replace(" ", "_")
		sprite.texture = ImageTexture.create_from_image(image)
		sprite.centered = false
		sprite.position = Vector2(float(spec["x"]) - 512.0 * DISPLAY_HEIGHT / SOURCE_VISIBLE_HEIGHT, GROUND_Y - 1472.0 * DISPLAY_HEIGHT / SOURCE_VISIBLE_HEIGHT)
		sprite.scale = Vector2.ONE * DISPLAY_HEIGHT / SOURCE_VISIBLE_HEIGHT
		add_child(sprite)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280.0, 720.0)), Color("#171b20"), true)
	var tile := 24
	for y in range(115, int(GROUND_Y), tile):
		for x in range(0, 1280, tile):
			if (x / tile + y / tile) % 2 == 0:
				draw_rect(Rect2(x, y, tile, tile), Color("#22272d"), true)
	draw_line(Vector2(0.0, GROUND_Y), Vector2(1280.0, GROUND_Y), Color("#57dce3"), 2.0)
	draw_line(Vector2(640.0, 105.0), Vector2(640.0, GROUND_Y), Color(0.35, 0.43, 0.50, 0.6), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(28.0, 42.0), "BREAKER TIER I — VISIBLE ART FIDELITY CHECK", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(28.0, 67.0), "SAME 450 PX VISIBLE HEIGHT • SHAPE / COLOR METRICS RUN SEPARATELY", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
	draw_string(ThemeDB.fallback_font, Vector2(115.0, 120.0), "APPROVED PROFILE / CANDIDATE 01", HORIZONTAL_ALIGNMENT_LEFT, 440, 13, Color("#57dce3"))
	draw_string(ThemeDB.fallback_font, Vector2(755.0, 120.0), "HIDDEN-ANATOMY EDIT / CANDIDATE 03", HORIZONTAL_ALIGNMENT_LEFT, 490, 13, Color("#57dce3"))
