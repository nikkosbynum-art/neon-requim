extends Node2D

const PANEL_LABELS := ["NEUTRAL / PIVOT BASELINE", "WALK / MID-SWING", "PUNCH / STRIKE SAMPLE", "HIT / RECOIL SAMPLE"]


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#12171d"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 70), Vector2(x, 612), Color(0.18, 0.22, 0.26, 0.25), 1.0)
	for y in range(70, 613, 40):
		draw_line(Vector2(0, y), Vector2(1280, y), Color(0.18, 0.22, 0.26, 0.25), 1.0)
	draw_line(Vector2(0, 612), Vector2(1280, 612), Color("#57dce3"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(30, 42), "BREAKER PROFILE PART TRIAL — MOTION / JOINT REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#e8edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 64), "QUARANTINED MASKS • ESTIMATED PIVOTS • NOT PRODUCTION ART", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#aeb9c4"))
	for index in range(PANEL_LABELS.size()):
		var x := 35.0 + float(index) * 320.0
		draw_string(ThemeDB.fallback_font, Vector2(x, 104), PANEL_LABELS[index], HORIZONTAL_ALIGNMENT_LEFT, 300, 11, Color("#57dce3"))
