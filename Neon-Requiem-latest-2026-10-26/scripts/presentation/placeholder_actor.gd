extends Node2D
class_name PlaceholderActor

## Temporary block-polygon assembly. This is a visual stand-in, not a production rig.

var enemy_actor := false
var animation_state := "idle"
var hp_ratio := 1.0
var base_y := 510.0
var anim_clock := 0.0
var parts: Dictionary = {}
var base_color := Color("#ba3149")
var accent_color := Color("#45e7e4")


func configure(is_enemy: bool, variant_index: int = 0) -> void:
	enemy_actor = is_enemy
	if is_enemy:
		base_color = Color("#673b83")
		accent_color = Color("#f45b9e")
	elif variant_index > 0:
		var placeholder_palettes := [Color("#a63853"), Color("#3d6378"), Color("#62523d"), Color("#425e50"), Color("#58436e")]
		base_color = placeholder_palettes[(variant_index - 1) % placeholder_palettes.size()]
		accent_color = Color("#45e7e4") if variant_index % 2 == 1 else Color("#ee648e")


func _ready() -> void:
	_build_part("torso", PackedVector2Array([Vector2(-17, -74), Vector2(17, -74), Vector2(20, -35), Vector2(-20, -35)]), base_color)
	_build_part("head", PackedVector2Array([Vector2(-13, -100), Vector2(13, -100), Vector2(15, -77), Vector2(-15, -77)]), Color("#c58b83"))
	_build_part("visor", PackedVector2Array([Vector2(-12, -94), Vector2(12, -94), Vector2(12, -87), Vector2(-12, -87)]), accent_color)
	_build_part("upper_arm", PackedVector2Array([Vector2(-6, -8), Vector2(6, -8), Vector2(7, 26), Vector2(-7, 26)]), base_color)
	_build_part("lower_arm", PackedVector2Array([Vector2(-5, -5), Vector2(5, -5), Vector2(6, 24), Vector2(-6, 24)]), Color("#8d9ba8"))
	_build_part("upper_leg", PackedVector2Array([Vector2(-7, -6), Vector2(7, -6), Vector2(8, 23), Vector2(-8, 23)]), Color("#4a5867"))
	_build_part("lower_leg", PackedVector2Array([Vector2(-6, -4), Vector2(6, -4), Vector2(7, 24), Vector2(-7, 24)]), Color("#343b4c"))
	parts["upper_arm"].position = Vector2(-24, -57)
	parts["lower_arm"].position = Vector2(-25, -31)
	parts["upper_leg"].position = Vector2(-9, -34)
	parts["lower_leg"].position = Vector2(-9, -11)
	if enemy_actor:
		scale.x = -1.0


func _build_part(part_name: String, polygon: PackedVector2Array, color: Color) -> void:
	var part := Polygon2D.new()
	part.name = part_name
	part.polygon = polygon
	part.color = color
	add_child(part)
	parts[part_name] = part


func present(world_x: float, state: String, health_ratio: float, world_y: float = 510.0) -> void:
	position = Vector2(world_x, world_y)
	base_y = world_y
	animation_state = state
	hp_ratio = clampf(health_ratio, 0.0, 1.0)
	queue_redraw()


func _process(delta: float) -> void:
	anim_clock += delta
	var bob := sin(anim_clock * 5.0) * 2.0 if animation_state == "idle" else 0.0
	if animation_state == "walk":
		bob = sin(anim_clock * 11.0) * 5.0
	position.y = base_y + bob
	var upper_arm: Polygon2D = parts["upper_arm"]
	var lower_arm: Polygon2D = parts["lower_arm"]
	upper_arm.rotation = 0.0
	lower_arm.rotation = 0.0
	if animation_state == "punch":
		upper_arm.rotation = 1.15
		lower_arm.rotation = 0.25
	elif animation_state == "hit":
		upper_arm.rotation = -0.6
	if animation_state == "defeated":
		rotation = -0.95 if not enemy_actor else 0.95
	else:
		rotation = 0.0


func _draw() -> void:
	var bar_width := 46.0
	draw_rect(Rect2(Vector2(-bar_width / 2.0, -116), Vector2(bar_width, 5)), Color("#1a1725"))
	draw_rect(Rect2(Vector2(-bar_width / 2.0, -116), Vector2(bar_width * hp_ratio, 5)), Color("#ff4765" if hp_ratio < 0.3 else "#48e4cf"))
