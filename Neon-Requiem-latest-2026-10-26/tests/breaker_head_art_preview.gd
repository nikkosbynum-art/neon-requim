extends Node2D

const BREAKER_RIG := preload("res://scripts/characters/breaker_t1_placeholder_rig.gd")
const HEAD_ART_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_head_candidate_01.png"
const HEAD_PIVOT := Vector2(571.0, 1156.0)
const HEAD_DISPLAY_HEIGHT := 29.0


func _ready() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(HEAD_ART_PATH))
	if image == null:
		push_error("Could not load the quarantined BREAKER head candidate.")
		return
	var head_texture := ImageTexture.create_from_image(image)
	for index in range(2):
		var rig = BREAKER_RIG.new()
		add_child(rig)
		rig.present(430.0 + index * 390.0, "idle", 1.0, 600.0)
		rig.set_facing_right(index == 0)
		if not rig.set_head_art(head_texture, HEAD_PIVOT, HEAD_DISPLAY_HEIGHT):
			push_error("Could not mount the BREAKER head candidate in the preview rig.")
	var right_label := Label.new()
	right_label.text = "RIGHT FACING"
	right_label.position = Vector2(350.0, 395.0)
	right_label.add_theme_font_size_override("font_size", 18)
	add_child(right_label)
	var left_label := Label.new()
	left_label.text = "LEFT FACING"
	left_label.position = Vector2(740.0, 395.0)
	left_label.add_theme_font_size_override("font_size", 18)
	add_child(left_label)
	var status_label := Label.new()
	status_label.text = "BREAKER TIER I — ISOLATED HEAD ART TRIAL  |  NOT IN MAIN SCENE"
	status_label.position = Vector2(36.0, 28.0)
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_color", Color("#67e8e3"))
	add_child(status_label)
	var note_label := Label.new()
	note_label.text = "Polygon body + generated head candidate  •  visual fit only  •  no combat simulation"
	note_label.position = Vector2(36.0, 62.0)
	note_label.add_theme_font_size_override("font_size", 15)
	note_label.add_theme_color_override("font_color", Color("#aeb8c9"))
	add_child(note_label)
	await get_tree().create_timer(0.5).timeout
	var capture := get_viewport().get_texture().get_image()
	var capture_path := ProjectSettings.globalize_path("res://docs/visual_qa/breaker_head_candidate_preview_1280x720.png")
	var save_error := capture.save_png(capture_path)
	if save_error != OK:
		push_error("Could not save the BREAKER head trial viewport capture: %s" % error_string(save_error))


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("#0c1018"))
	draw_rect(Rect2(Vector2(0.0, 440.0), Vector2(viewport_size.x, 280.0)), Color("#171c25"))
	draw_line(Vector2(0.0, 600.0), Vector2(viewport_size.x, 600.0), Color("#56616e"), 2.0)
	for x in range(0, int(viewport_size.x), 80):
		draw_line(Vector2(x, 600.0), Vector2(x - 34.0, 720.0), Color("#242a33"), 1.0)
	for y in [470.0, 525.0, 580.0]:
		draw_line(Vector2(0.0, y), Vector2(viewport_size.x, y), Color("#151b23"), 1.0)
