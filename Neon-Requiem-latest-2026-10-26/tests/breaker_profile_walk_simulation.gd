extends Node2D
"""Standalone walking preview. Translation and speed are review fixtures only."""

const RIG_SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
const GROUND_Y := 590.0
const START_X := 390.0
const END_X := 890.0
const REVIEW_TRAVEL_SPEED := 44.0

var rig: Variant
var elapsed := 0.0
var travel_x := START_X
var moving_right := true


func _ready() -> void:
	rig = load(RIG_SCENE_PATH).instantiate()
	rig.draw_review_stage = false
	add_child(rig)
	rig.visual_root.position = Vector2(START_X, GROUND_Y)
	rig.play_pose("walk")


func _process(delta: float) -> void:
	elapsed += delta
	var distance := END_X - START_X
	var phase := fposmod(elapsed * REVIEW_TRAVEL_SPEED, distance * 2.0)
	moving_right = phase <= distance
	travel_x = START_X + (phase if moving_right else distance * 2.0 - phase)
	rig.visual_root.position = Vector2(travel_x, GROUND_Y)
	rig.visual_root.scale.x = 1.0 if moving_right else -1.0
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#12171d"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 70), Vector2(x, GROUND_Y), Color(0.18, 0.22, 0.26, 0.28), 1.0)
	for y in range(70, int(GROUND_Y) + 1, 40):
		draw_line(Vector2(260, y), Vector2(1020, y), Color(0.18, 0.22, 0.26, 0.28), 1.0)
	draw_line(Vector2(260, GROUND_Y), Vector2(1020, GROUND_Y), Color("#57dce3"), 2.0)
	draw_line(Vector2(START_X, GROUND_Y + 10), Vector2(END_X, GROUND_Y + 10), Color("#c23d62", 0.7), 2.0)
	draw_circle(Vector2(travel_x, GROUND_Y + 10), 5.0, Color("#f06b87"))
	draw_string(ThemeDB.fallback_font, Vector2(36, 44), "BREAKER TIER I — WALKING SIMULATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#e8edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(36, 72), "ISOLATED RIG REVIEW / PROVISIONAL PIVOTS / NOT RUNTIME MOVEMENT TUNING", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#aeb9c4"))
	draw_string(ThemeDB.fallback_font, Vector2(36, 102), "Walk cycle: 0.65 s  |  Preview travel: %.0f px/s  |  Ground anchor: %.0f px" % [REVIEW_TRAVEL_SPEED, GROUND_Y], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#57dce3"))


func get_rig() -> Variant:
	return rig
