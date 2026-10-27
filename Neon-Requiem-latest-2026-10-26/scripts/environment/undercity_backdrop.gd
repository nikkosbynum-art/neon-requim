extends Node2D
class_name UndercityBackdrop

## Procedural atmosphere for the current Undercity slice; not production environment art.

const SKY := Color("#080a16")
const DISTANT_CITY := Color("#11172a")
const NEAR_CITY := Color("#171b31")
const STREET := Color("#131321")
const CRIMSON := Color("#e73c65")
const CYAN := Color("#45d9d0")
const PURPLE := Color("#ad5ab4")

var ambience_time := 0.0

var zone_id := "undercity_proto_01"
var palette: Dictionary = {}


func configure(zone_definition: Dictionary) -> void:
	zone_id = str(zone_definition.get("zone_id", zone_id))
	var next_palette: Variant = zone_definition.get("palette", {})
	if typeof(next_palette) == TYPE_DICTIONARY:
		palette = next_palette.duplicate(true)
	queue_redraw()


func _palette_color(key: String, fallback: Color) -> Color:
	return Color(str(palette.get(key, fallback.to_html(false))))


func _process(delta: float) -> void:
	ambience_time = fposmod(ambience_time + delta, 4096.0)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var skyline_y := size.y * 0.60
	var ground_y := size.y * 0.708
	_draw_sky(size, skyline_y)
	_draw_city(size, skyline_y)
	_draw_street(size, ground_y)
	_draw_rain(size, ground_y)


func _draw_sky(size: Vector2, skyline_y: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), _palette_color("sky", SKY))
	for band in range(12):
		var y := size.y * 0.20 + float(band) * size.y * 0.033
		var glow := _palette_color("haze", Color("#382442"))
		glow.a = 0.025 + 0.018 * (1.0 - float(band) / 12.0)
		draw_rect(Rect2(0.0, y, size.x, size.y * 0.035), glow)
	var horizon_haze := Color("#a23465")
	horizon_haze.a = 0.12
	draw_rect(Rect2(0.0, skyline_y - 2.0, size.x, 2.0), horizon_haze)


func _draw_city(size: Vector2, skyline_y: float) -> void:
	var segment := size.x / 8.0
	for index in range(10):
		var x := float(index) * segment - segment * 0.5
		var height_factor := float((index * 47 + 83) % 100) / 100.0
		var height := size.y * (0.17 + height_factor * 0.21)
		var width := segment * 0.78
		var top := skyline_y - height
		draw_rect(Rect2(x, top, width, height), _palette_color("distant_city", DISTANT_CITY))
		var roof_edge := Color("#29304a")
		roof_edge.a = 0.72
		draw_rect(Rect2(x, top, width, 2.0), roof_edge)
		for row in range(3):
			for column in range(3):
				var window_color := _palette_color("purple", PURPLE) if (index + row + column) % 4 == 0 else _palette_color("cyan", CYAN)
				var pulse := 0.5 + 0.5 * sin(ambience_time * 0.7 + float(index * 7 + row * 3 + column))
				window_color.a = 0.10 + pulse * 0.10
				var window_x := x + width * 0.16 + float(column) * width * 0.25
				var window_y := top + 12.0 + float(row) * 15.0
				draw_rect(Rect2(window_x, window_y, 5.0, 9.0), window_color)

	for index in range(7):
		var x := float(index) * size.x / 6.0 - 38.0
		var height_factor := float((index * 31 + 17) % 100) / 100.0
		var height := size.y * (0.12 + height_factor * 0.14)
		var top := skyline_y - height * 0.44
		var width := size.x / 13.0
		draw_rect(Rect2(x, top, width, height), _palette_color("near_city", NEAR_CITY))
		for row in range(2):
			for column in range(2):
				var window_color := _palette_color("purple", PURPLE) if (index + row + column) % 3 == 0 else _palette_color("cyan", CYAN)
				window_color.a = 0.52
				draw_rect(Rect2(x + 10.0 + float(column) * 18.0, top + 12.0 + float(row) * 18.0, 6.0, 11.0), window_color)

	var sign_y := size.y * 0.44
	for index in range(5):
		var x := float(index) * size.x / 4.0 + size.x * 0.04
		var sign_color := _palette_color("cyan", CYAN) if index % 2 == 0 else _palette_color("purple", PURPLE)
		sign_color.a = 0.16 + 0.04 * sin(ambience_time * 1.4 + index)
		draw_rect(Rect2(x, sign_y, 2.0, size.y * 0.08), sign_color)


func _draw_street(size: Vector2, ground_y: float) -> void:
	var upper_lane := Color("#0b0c17")
	upper_lane.a = 0.96
	var upper_lane_top := ground_y - size.y * 0.11
	draw_rect(Rect2(0.0, upper_lane_top, size.x, size.y * 0.11), upper_lane)
	draw_rect(Rect2(0.0, ground_y, size.x, size.y - ground_y), _palette_color("street", STREET))
	var walkway_seam := Color("#474258")
	walkway_seam.a = 0.36
	for lane in range(3):
		var seam_y := upper_lane_top + 9.0 + float(lane) * 28.0
		draw_line(Vector2(0.0, seam_y), Vector2(size.x, seam_y), walkway_seam, 1.0)
	var curb_glow := _palette_color("crimson", CRIMSON)
	curb_glow.a = 0.88
	draw_rect(Rect2(0.0, ground_y - 2.0, size.x, 3.0), curb_glow)
	var wet_reflection := _palette_color("cyan", CYAN)
	wet_reflection.a = 0.08 + 0.025 * sin(ambience_time * 0.8)
	for index in range(9):
		var x := float((index * 173) % maxi(1, int(size.x)))
		var width := size.x * (0.06 + float(index % 3) * 0.025)
		draw_rect(Rect2(x, ground_y + 12.0 + float(index % 4) * 9.0, width, 2.0), wet_reflection)

	var vanishing_point := Vector2(size.x * 0.5, ground_y)
	var pavement_line := Color("#3a3652")
	pavement_line.a = 0.48
	var raised_walkway_line := Color("#403d55")
	raised_walkway_line.a = 0.28
	for index in range(-4, 5):
		var lane_x := size.x * 0.5 + float(index) * size.x * 0.11
		draw_line(vanishing_point, Vector2(lane_x, upper_lane_top), raised_walkway_line, 1.0)
	for index in range(-6, 7):
		var x := size.x * 0.5 + float(index) * size.x * 0.105
		draw_line(vanishing_point, Vector2(x, size.y), pavement_line, 1.0)
	for row in range(1, 5):
		var ratio := float(row) / 5.0
		var y := ground_y + pow(ratio, 1.65) * (size.y - ground_y)
		draw_line(Vector2(0.0, y), Vector2(size.x, y), pavement_line, 1.0)


func _draw_rain(size: Vector2, ground_y: float) -> void:
	for index in range(48):
		var speed := 120.0 + float(index % 4) * 27.0
		var y := fposmod(float(index * 61) + ambience_time * speed, ground_y)
		var x := fposmod(float(index * 137) + ambience_time * speed * 0.11, size.x + 24.0) - 12.0
		var drop := Color("#5aa9c0") if index % 5 != 0 else Color("#c25e8a")
		drop.a = 0.12 + float(index % 3) * 0.025
		draw_line(Vector2(x, y), Vector2(x - 7.0, y + 17.0), drop, 1.0)
