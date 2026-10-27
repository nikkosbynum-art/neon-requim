extends Node2D

const TIMES := [0.0, 0.08, 0.1625, 0.245, 0.325, 0.4075, 0.4875, 0.57]


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#11171e"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 118), Vector2(x, 612), Color(0.18, 0.23, 0.28, 0.22), 1.0)
	for y in range(118, 613, 40):
		draw_line(Vector2(0, y), Vector2(1280, y), Color(0.18, 0.23, 0.28, 0.22), 1.0)
	draw_line(Vector2(0, 612), Vector2(1280, 612), Color("#57dce3"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(28, 40), "BREAKER PROFILE WALK — FULL 0.65 S GAIT CYCLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#e8edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 65), "KNEE LIFT • BOOT COUNTER-ROTATION • NATURAL ARM COUNTER-SWING • QUARANTINED PARTS / ESTIMATED PIVOTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
	for index in range(TIMES.size()):
		var left := float(index) * 160.0
		var phase_percent := int(round(float(TIMES[index]) / 0.65 * 100.0)) % 100
		draw_string(ThemeDB.fallback_font, Vector2(left + 12.0, 104), "%02d   %02d%%" % [index + 1, phase_percent], HORIZONTAL_ALIGNMENT_LEFT, 130, 12, Color("#57dce3"))
		if index > 0:
			draw_line(Vector2(left, 118), Vector2(left, 612), Color(0.35, 0.43, 0.50, 0.4), 1.0)
