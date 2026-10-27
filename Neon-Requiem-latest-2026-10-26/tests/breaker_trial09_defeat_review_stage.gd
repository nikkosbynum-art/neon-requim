extends Node2D

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#12171d"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 70), Vector2(x, 612), Color(0.18, 0.22, 0.26, 0.28), 1.0)
	for y in range(70, 613, 40):
		draw_line(Vector2(160, y), Vector2(1120, y), Color(0.18, 0.22, 0.26, 0.28), 1.0)
	draw_line(Vector2(160, 612), Vector2(1120, 612), Color("#57dce3"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(36, 40), "BREAKER TIER I — DEFEAT FALL REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#e8edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(36, 65), "CANDIDATE 09 ARM OWNERSHIP V2 • QUARANTINED ART • ESTIMATED PIVOTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#9eaab5"))
