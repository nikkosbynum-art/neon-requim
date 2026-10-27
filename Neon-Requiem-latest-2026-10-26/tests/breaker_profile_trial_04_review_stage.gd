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
		draw_string(ThemeDB.fallback_font, Vector2(28, 38), "BREAKER TIER I — TRIAL 04 INFERRED UNDERPAINT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 63), "INFERRED JOINT FILLS • ESTIMATED PIVOTS • QUARANTINED REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
		var labels := ["IDLE", "WALK", "PUNCH", "HIT", "DEFEAT"]
		for index in range(labels.size()):
			var left := float(index) * 256.0
			draw_string(ThemeDB.fallback_font, Vector2(left + 16.0, 96), labels[index], HORIZONTAL_ALIGNMENT_LEFT, 220, 13, Color("#57dce3"))
			if index > 0:
				draw_line(Vector2(left, 110), Vector2(left, GROUND_Y), Color(0.35, 0.43, 0.50, 0.34), 1.0)
	elif view_mode == "joint_stress":
		draw_string(ThemeDB.fallback_font, Vector2(28, 38), "BREAKER TIER I — INFERRED JOINT-FILL STRESS REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 63), "EXAGGERATED PIVOTS TO REVEAL HIDDEN-PIXEL GAPS • NOT FINAL ANIMATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
		var labels := ["CYBER ARM", "HUMAN ARM", "LEFT LEG", "RIGHT LEG", "TORSO / HIPS"]
		for index in range(labels.size()):
			var left := float(index) * 256.0
			draw_string(ThemeDB.fallback_font, Vector2(left + 16.0, 96), labels[index], HORIZONTAL_ALIGNMENT_LEFT, 220, 12, Color("#57dce3"))
			if index > 0:
				draw_line(Vector2(left, 110), Vector2(left, GROUND_Y), Color(0.35, 0.43, 0.50, 0.34), 1.0)
	elif view_mode == "walk_cycle":
		draw_string(ThemeDB.fallback_font, Vector2(28, 38), "BREAKER TIER I — TRIAL 04 WALK CYCLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 63), "0.65 S LOOP • INFERRED UNDERPAINT • QUARANTINED / VISUAL REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
		var times := [0.0, 0.08, 0.1625, 0.245, 0.325, 0.4075, 0.4875, 0.57]
		for index in range(times.size()):
			var left := float(index) * 160.0
			var phase_percent := int(round(times[index] / 0.65 * 100.0)) % 100
			draw_string(ThemeDB.fallback_font, Vector2(left + 10.0, 104), "%02d   %02d%%" % [index + 1, phase_percent], HORIZONTAL_ALIGNMENT_LEFT, 130, 12, Color("#57dce3"))
			if index > 0:
				draw_line(Vector2(left, 118), Vector2(left, GROUND_Y), Color(0.35, 0.43, 0.50, 0.4), 1.0)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(28, 38), "BREAKER TIER I — TRIAL 04 SIX-UNIT READABILITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 63), "INFERRED JOINT FILLS • REVIEW ONLY • NOT A RUNTIME FORMATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
		for index in range(6):
			var left := float(index) * (1280.0 / 6.0)
			draw_string(ThemeDB.fallback_font, Vector2(left + 12.0, 96), "SLOT %02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Color("#57dce3"))
			if index > 0:
				draw_line(Vector2(left, 110), Vector2(left, GROUND_Y), Color(0.35, 0.43, 0.50, 0.34), 1.0)
