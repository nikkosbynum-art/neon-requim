extends Node2D

const GROUND_Y := 612.0
const LABELS := ["IDLE / NEUTRAL", "WALK / MID-SWING", "PUNCH / STRIKE", "HIT / RECOIL", "DEFEAT / COLLAPSE"]

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#12171d"), true)
    for x in range(0, 1281, 40):
        draw_line(Vector2(x, 70), Vector2(x, GROUND_Y), Color(0.18, 0.22, 0.26, 0.25), 1.0)
    for y in range(70, int(GROUND_Y) + 1, 40):
        draw_line(Vector2(0, y), Vector2(1280, y), Color(0.18, 0.22, 0.26, 0.25), 1.0)
    draw_line(Vector2(0, GROUND_Y), Vector2(1280, GROUND_Y), Color("#57dce3"), 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(30, 42), "BREAKER TIER I — CANDIDATE 07 CANON REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#e8edf2"))
    draw_string(ThemeDB.fallback_font, Vector2(30, 64), "QUARANTINED LAYERS • TRANSFERRED PIVOTS • INFERRED UNDERPAINT • REVIEW ONLY", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#aeb9c4"))
    for index in range(LABELS.size()):
        var x := float(index) * 256.0 + 10.0
        draw_string(ThemeDB.fallback_font, Vector2(x, 104), LABELS[index], HORIZONTAL_ALIGNMENT_LEFT, 235, 11, Color("#57dce3"))
        if index > 0:
            draw_line(Vector2(float(index) * 256.0, 112), Vector2(float(index) * 256.0, GROUND_Y), Color(0.35, 0.43, 0.50, 0.34), 1.0)
