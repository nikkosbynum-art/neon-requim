extends Node2D

var view_mode := "actions"
const GROUND_Y := 612.0


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#11171e"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 110), Vector2(x, GROUND_Y), Color(0.18, 0.23, 0.28, 0.2), 1.0)
	for y in range(110, int(GROUND_Y) + 1, 40):
		draw_line(Vector2(0, y), Vector2(1280, y), Color(0.18, 0.23, 0.28, 0.2), 1.0)
	draw_line(Vector2(0, GROUND_Y), Vector2(1280, GROUND_Y), Color("#57dce3"), 2.0)
	if view_mode == "actions":
		draw_string(ThemeDB.fallback_font, Vector2(28, 38), "BREAKER TIER I — ART / RIG GATE REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 63), "256 PX VISIBLE HEIGHT • ESTIMATED PIVOTS • QUARANTINED PROFILE PARTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
		var labels := ["IDLE", "WALK", "PUNCH", "HIT", "DEFEAT"]
		for index in range(labels.size()):
			var left := float(index) * 256.0
			draw_string(ThemeDB.fallback_font, Vector2(left + 16.0, 96), labels[index], HORIZONTAL_ALIGNMENT_LEFT, 220, 13, Color("#57dce3"))
			if index > 0:
				draw_line(Vector2(left, 110), Vector2(left, GROUND_Y), Color(0.35, 0.43, 0.50, 0.34), 1.0)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(28, 38), "BREAKER TIER I — SIX-UNIT READABILITY REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 63), "SIX FULL-SIZE PROFILES • STAGGERED WALK PHASES • NOT A RUNTIME FORMATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
		for index in range(6):
			var left := float(index) * (1280.0 / 6.0)
			draw_string(ThemeDB.fallback_font, Vector2(left + 12.0, 96), "SLOT %02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Color("#57dce3"))
			if index > 0:
				draw_line(Vector2(left, 110), Vector2(left, GROUND_Y), Color(0.35, 0.43, 0.50, 0.34), 1.0)
