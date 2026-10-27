extends Node2D

## Isolated presentation harness. It deliberately has no CombatDirector or wave dependency.

const PHANTOM_CAMERA_SCRIPT := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_2d.gd")
const PHANTOM_HOST_SCRIPT := preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")
const PHANTOM_TWEEN_SCRIPT := preload("res://addons/phantom_camera/scripts/resources/tween_resource.gd")
const PHANTOM_MANAGER_SCRIPT := preload("res://addons/phantom_camera/scripts/managers/phantom_camera_manager.gd")
const ENVIRONMENT_DIRECTOR_SCRIPT := preload("res://scripts/environment/environment_director.gd")

var presentation_target: Node2D
var environment_layer: CanvasLayer
var environment_director: Node2D
var camera_a: Node2D
var camera_b: Node2D
var status_label: Label
var transition_started := false
var transition_finished := false


class TargetMarker extends Node2D:
	func _draw() -> void:
		draw_circle(Vector2.ZERO, 16.0, Color("#10151e"))
		draw_circle(Vector2.ZERO, 10.0, Color("#45d9d0"))
		draw_circle(Vector2.ZERO, 4.0, Color("#f2f5fb"))
		draw_line(Vector2(-24.0, 0.0), Vector2(24.0, 0.0), Color("#f2f5fb"), 1.0)
		draw_line(Vector2(0.0, -24.0), Vector2(0.0, 24.0), Color("#f2f5fb"), 1.0)


class ParallaxSkyline extends Node2D:
	func _draw() -> void:
		for index in range(15):
			var width := 86.0 + float((index * 13) % 43)
			var height := 105.0 + float((index * 31) % 90)
			var x := float(index) * 112.0
			var rect := Rect2(Vector2(x, 525.0 - height), Vector2(width, height))
			draw_rect(rect, Color("#171b33"))
			var sign_color := Color("#45d9d0") if index % 2 == 0 else Color("#eb4f7b")
			sign_color.a = 0.34
			draw_rect(Rect2(Vector2(x + 12.0, rect.position.y + 20.0), Vector2(8.0, 24.0)), sign_color)


func _ready() -> void:
	_build_presentation_only_stage()


func _build_presentation_only_stage() -> void:
	_ensure_phantom_camera_manager()
	# A screen-space background layer transitions independently of the world camera.
	environment_layer = CanvasLayer.new()
	environment_layer.layer = -1
	add_child(environment_layer)
	environment_director = ENVIRONMENT_DIRECTOR_SCRIPT.new()
	environment_director.name = "IsolatedEnvironmentDirector"
	environment_layer.add_child(environment_director)
	var parallax_layer := Parallax2D.new()
	parallax_layer.name = "PrototypeFarLayer"
	parallax_layer.scroll_scale = Vector2(0.28, 1.0)
	parallax_layer.repeat_size = Vector2(1680.0, 0.0)
	add_child(parallax_layer)
	parallax_layer.add_child(ParallaxSkyline.new())

	# World lane and marker stand in only for moving presentation targets.
	presentation_target = TargetMarker.new()
	presentation_target.name = "PresentationTargetMarker"
	presentation_target.position = Vector2(310.0, 510.0)
	add_child(presentation_target)
	queue_redraw()

	var camera := Camera2D.new()
	camera.name = "PrototypeCamera2D"
	camera.position = presentation_target.position
	camera.zoom = Vector2.ONE
	add_child(camera)
	camera.make_current()

	var host := Node.new()
	host.name = "PrototypePhantomCameraHost"
	host.set_script(PHANTOM_HOST_SCRIPT)
	camera.add_child(host)

	camera_a = _make_phantom_camera("FramingA", 10, Vector2(0.0, -36.0), false)
	camera_b = _make_phantom_camera("FramingB", 0, Vector2(120.0, -54.0), true)
	add_child(camera_a)
	add_child(camera_b)

	var ui := CanvasLayer.new()
	ui.layer = 2
	add_child(ui)
	status_label = Label.new()
	status_label.position = Vector2(28.0, 24.0)
	status_label.add_theme_color_override("font_color", Color("#f4f0f5"))
	status_label.add_theme_color_override("font_shadow_color", Color("#080a12"))
	status_label.add_theme_constant_override("shadow_offset_x", 2)
	status_label.add_theme_constant_override("shadow_offset_y", 2)
	status_label.text = "ZONE HANDOFF LAB 01  |  TEST ONLY\nThe marker triggers the handoff automatically.\nThe 1→13 Undercity palette change is a QA fixture, not pacing."
	ui.add_child(status_label)


func _ensure_phantom_camera_manager() -> void:
	# The normal editor plugin registers this autoload. This keeps the standalone
	# prototype scene runnable from a command line without changing project.godot.
	if get_tree().root.has_node("PhantomCameraManager"):
		return
	var manager := Node.new()
	manager.name = "PhantomCameraManager"
	manager.set_script(PHANTOM_MANAGER_SCRIPT)
	get_tree().root.add_child(manager)


func _make_phantom_camera(node_name: String, next_priority: int, offset: Vector2, use_long_tween: bool) -> Node2D:
	var phantom_camera := Node2D.new()
	phantom_camera.name = node_name
	phantom_camera.set_script(PHANTOM_CAMERA_SCRIPT)
	phantom_camera.set("follow_target", presentation_target)
	phantom_camera.set("follow_mode", 2) # SIMPLE
	phantom_camera.set("follow_offset", offset)
	phantom_camera.set("follow_damping", true)
	phantom_camera.set("priority", next_priority)
	phantom_camera.set("tween_on_load", false)
	var tween_resource: Resource = PHANTOM_TWEEN_SCRIPT.new()
	tween_resource.set("duration", 1.25 if use_long_tween else 0.0)
	tween_resource.set("transition", 1) # SINE
	tween_resource.set("ease", 2) # EASE_IN_OUT
	phantom_camera.set("tween_resource", tween_resource)
	return phantom_camera


func _process(delta: float) -> void:
	if not is_instance_valid(presentation_target) or transition_started:
		return
	presentation_target.position.x += 80.0 * delta
	if presentation_target.position.x >= 1040.0:
		begin_presentation_handoff()
	queue_redraw()


func _draw() -> void:
	# Continuous lane markings conceal the palette module seam in this fixture.
	var ground_y := 525.0
	draw_rect(Rect2(Vector2(0.0, ground_y), Vector2(3000.0, 260.0)), Color("#080b12"))
	draw_line(Vector2(0.0, ground_y), Vector2(3000.0, ground_y), Color("#8b3e64"), 3.0)
	for index in range(31):
		var x := 60.0 + float(index) * 100.0
		draw_line(Vector2(x, ground_y + 36.0), Vector2(x + 36.0, ground_y + 36.0), Color(0.26, 0.28, 0.37, 0.55), 2.0)


func begin_presentation_handoff() -> void:
	if transition_started:
		return
	transition_started = true
	if is_instance_valid(camera_a):
		camera_a.set("priority", 0)
	if is_instance_valid(camera_b):
		camera_b.set("priority", 20)

	if is_instance_valid(environment_director):
		# Wave 13 is only the existing QA fixture used to select a second palette.
		environment_director.apply_wave(13)
		var environment_tween := create_tween()
		environment_tween.tween_interval(1.1)
		environment_tween.finished.connect(_finish_backdrop_handoff)

	if is_instance_valid(status_label):
		status_label.text = "ZONE HANDOFF LAB 01  |  TEST ONLY\nCamera framing + existing palette crossfade started.\nWave 13 is a QA fixture; no combat state changed."


func _finish_backdrop_handoff() -> void:
	transition_finished = true
	if is_instance_valid(status_label):
		status_label.text = "ZONE HANDOFF LAB 01  |  TEST ONLY\nTransition complete. Current modules remain provisional.\nCamera/environment presentation did not access combat state."
