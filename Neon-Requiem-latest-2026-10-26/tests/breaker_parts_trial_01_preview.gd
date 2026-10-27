extends Node2D
"""Isolated, presentation-only BREAKER part assembly review.

This is a fit check, not a production rig. All source images remain untouched.
"""

const PARTS_ROOT := "res://assets/characters/breaker/tier_01_drafts/modular_parts_trial_01/"
const GROUND_Y := 590.0
const FIGURE_X := 640.0
const FIT_SCALE := 0.86
const FIT_WIDTH_SCALE := 1.12
var pose_nodes: Dictionary = {}
var animation_player: AnimationPlayer
var loaded_part_count := 0
var test_failure_count := 0
var preview_zoom := 1.0
var ground_y := GROUND_Y

func _ready() -> void:
	var zoom_text := OS.get_environment("BREAKER_TRIAL_ZOOM")
	if not zoom_text.is_empty():
		preview_zoom = clampf(zoom_text.to_float(), 1.0, 2.0)
	if preview_zoom > 1.0:
		ground_y = 640.0
	_render_review_stage()
	_add_character_parts()
	_setup_test_animations()
	_add_review_labels()
	var pose_name := OS.get_environment("BREAKER_TRIAL_POSE").to_lower()
	if not pose_name.is_empty():
		_apply_pose(pose_name)
		_capture_review_frame()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#15191f"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 70), Vector2(x, ground_y), Color(0.18, 0.21, 0.25, 0.3), 1.0)
	for y in range(70, int(ground_y) + 1, 40):
		draw_line(Vector2(260, y), Vector2(1020, y), Color(0.18, 0.21, 0.25, 0.3), 1.0)
	draw_line(Vector2(260, ground_y), Vector2(1020, ground_y), Color("#57dce3"), 2.0)

func _render_review_stage() -> void:
	pass

func _add_character_parts() -> void:
	# This deliberately small hierarchy only tests the pivots supported by the
	# generated parts. It is isolated from the production BREAKER scene.
	var visual_root := Node2D.new()
	visual_root.name = "VisualRoot"
	visual_root.position = Vector2(FIGURE_X, ground_y)
	# The approved full-body reference has a broader silhouette than the first
	# assembly. Widen the preview without changing its 256 px height/ground fit.
	visual_root.scale = Vector2(FIT_SCALE * FIT_WIDTH_SCALE * preview_zoom, FIT_SCALE * preview_zoom)
	add_child(visual_root)
	pose_nodes["visual_root"] = visual_root

	var back_thigh := _make_pivot(visual_root, "back_thigh", "right_thigh.png", Vector2(660, 70), Vector2(28, -170), 0.050, 5)
	(back_thigh.get_child(0) as Sprite2D).scale.x *= 1.16
	var back_knee := _make_pivot(back_thigh, "right_knee", "", Vector2.ZERO, Vector2(0, 52), 1.0, 0)
	var back_shin := _make_part(back_knee, "right_shin.png", Vector2(665, 75), 0.070, 3)
	back_shin.scale.x *= 1.16
	back_shin.scale.y *= 1.14
	var back_ankle := _make_pivot(back_knee, "right_ankle", "", Vector2.ZERO, Vector2(0, 87), 1.0, 0)
	_make_part(back_ankle, "boot.png", Vector2(410, 145), 0.030, 1)
	pose_nodes["back_thigh"] = back_thigh
	pose_nodes["back_knee"] = back_knee
	pose_nodes["back_ankle"] = back_ankle
	pose_nodes["back_thigh_sprite"] = back_thigh.get_child(0)
	pose_nodes["back_shin_sprite"] = back_knee.get_child(0)
	pose_nodes["back_boot_sprite"] = back_ankle.get_child(0)

	var front_thigh := _make_pivot(visual_root, "front_thigh", "left_thigh.png", Vector2(650, 70), Vector2(-28, -170), 0.050, 6)
	(front_thigh.get_child(0) as Sprite2D).scale.x *= 1.16
	var front_knee := _make_pivot(front_thigh, "left_knee", "", Vector2.ZERO, Vector2(0, 52), 1.0, 0)
	var front_shin := _make_part(front_knee, "left_shin.png", Vector2(650, 75), 0.070, 4)
	front_shin.scale.x *= 1.16
	front_shin.scale.y *= 1.14
	var front_ankle := _make_pivot(front_knee, "left_ankle", "", Vector2.ZERO, Vector2(0, 87), 1.0, 0)
	var front_boot := _make_pivot(front_ankle, "mirrored_boot", "boot.png", Vector2(410, 145), Vector2.ZERO, 0.030, 2)
	var front_boot_sprite := front_boot.get_child(0) as Sprite2D
	front_boot_sprite.flip_h = true
	pose_nodes["front_thigh"] = front_thigh
	pose_nodes["front_knee"] = front_knee
	pose_nodes["front_ankle"] = front_ankle
	pose_nodes["front_thigh_sprite"] = front_thigh.get_child(0)
	pose_nodes["front_shin_sprite"] = front_knee.get_child(0)
	pose_nodes["front_boot_sprite"] = front_boot_sprite

	var pelvis_sprite := _make_part(visual_root, "pelvis.png", Vector2(650, 150), 0.043, 7, Vector2(-2, -175))
	pelvis_sprite.scale.x *= 1.16
	var torso_sprite := _make_part(visual_root, "torso_vest.png", Vector2(640, 1150), 0.071, 8, Vector2(-2, -175))
	torso_sprite.scale.x *= 1.24
	torso_sprite.scale.y *= 1.02
	pose_nodes["pelvis_sprite"] = pelvis_sprite
	pose_nodes["torso_sprite"] = torso_sprite
	var neck := _make_pivot(visual_root, "neck", "", Vector2.ZERO, Vector2(-2, -243), 1.0, 0)
	var head_neck_sprite := _make_part(neck, "head_neck.png", Vector2(800, 1135), 0.054, 9)
	pose_nodes["neck"] = neck
	pose_nodes["head_neck_sprite"] = head_neck_sprite

	var human_shoulder := _make_pivot(visual_root, "human_shoulder", "left_upper_arm.png", Vector2(420, 205), Vector2(20, -238), 0.050, 10)
	var human_elbow := _make_pivot(human_shoulder, "human_elbow", "", Vector2.ZERO, Vector2(34, 48), 1.0, 0)
	var human_forearm_sprite := _make_part(human_elbow, "left_forearm_hand.png", Vector2(195, 430), 0.050, 11, Vector2(-4, -4))
	pose_nodes["human_shoulder"] = human_shoulder
	pose_nodes["human_elbow"] = human_elbow
	pose_nodes["human_shoulder_sprite"] = human_shoulder.get_child(0)
	pose_nodes["human_upper_arm_sprite"] = human_shoulder.get_child(0)
	pose_nodes["human_forearm_sprite"] = human_forearm_sprite

	var cyber_shoulder := _make_pivot(visual_root, "cyber_shoulder", "right_cyber_arm.png", Vector2(900, 180), Vector2(-18, -238), 0.072, 12)
	var cyber_wrist := _make_pivot(cyber_shoulder, "cyber_wrist", "", Vector2.ZERO, Vector2(-33, 56), 1.0, 0)
	var cyber_fist_sprite := _make_part(cyber_wrist, "right_fist.png", Vector2(85, 640), 0.054, 13, Vector2(-3, -2))
	pose_nodes["cyber_shoulder"] = cyber_shoulder
	pose_nodes["cyber_wrist"] = cyber_wrist
	pose_nodes["cyber_shoulder_sprite"] = cyber_shoulder.get_child(0)
	pose_nodes["cyber_arm_sprite"] = cyber_shoulder.get_child(0)
	pose_nodes["cyber_fist_sprite"] = cyber_fist_sprite

func _make_pivot(parent: Node2D, node_name: String, part_file: String, pivot: Vector2, position: Vector2, part_scale: float, z: int) -> Node2D:
	var pivot_node := Node2D.new()
	pivot_node.name = node_name
	pivot_node.position = position
	pivot_node.z_index = z
	parent.add_child(pivot_node)
	if not part_file.is_empty():
		_make_part(pivot_node, part_file, pivot, part_scale, 0)
	return pivot_node

func _make_part(parent: Node2D, part_file: String, pivot: Vector2, part_scale: float, z: int, local_position := Vector2.ZERO) -> Sprite2D:
	var path := ProjectSettings.globalize_path(PARTS_ROOT + part_file)
	var image := Image.new()
	var load_error := image.load(path)
	if load_error != OK:
		push_error("Could not read BREAKER review part: " + path)
		return null
	var texture := ImageTexture.create_from_image(image)
	loaded_part_count += 1
	var sprite := Sprite2D.new()
	sprite.name = part_file.get_basename()
	sprite.texture = texture
	sprite.centered = true
	sprite.offset = Vector2(texture.get_width(), texture.get_height()) * 0.5 - pivot
	sprite.position = local_position
	sprite.scale = Vector2.ONE * part_scale
	sprite.z_index = z
	parent.add_child(sprite)
	return sprite

func _apply_pose(pose_name: String) -> void:
	if pose_name == "neutral":
		animation_player.stop()
		return
	if not animation_player.has_animation(pose_name):
		push_warning("Unknown BREAKER review pose: " + pose_name)
		return
	animation_player.play(pose_name)

func _setup_test_animations() -> void:
	animation_player = AnimationPlayer.new()
	animation_player.name = "TrialAnimationPlayer"
	animation_player.root_node = NodePath("..")
	add_child(animation_player)
	var library := AnimationLibrary.new()
	var idle := _new_animation(1.0, true)
	_add_rotation_track(idle, "VisualRoot/neck:rotation", [[0.0, 0.0], [0.5, 0.012], [1.0, 0.0]])
	_add_rotation_track(idle, "VisualRoot/human_shoulder:rotation", [[0.0, 0.0], [0.5, -0.008], [1.0, 0.0]])
	library.add_animation("idle", idle)
	var walk := _new_animation(0.65, true)
	_add_rotation_track(walk, "VisualRoot/front_thigh:rotation", [[0.0, -0.14], [0.325, 0.14], [0.65, -0.14]])
	_add_rotation_track(walk, "VisualRoot/back_thigh:rotation", [[0.0, 0.14], [0.325, -0.14], [0.65, 0.14]])
	_add_rotation_track(walk, "VisualRoot/front_thigh/left_knee:rotation", [[0.0, 0.10], [0.325, 0.0], [0.65, 0.10]])
	_add_rotation_track(walk, "VisualRoot/back_thigh/right_knee:rotation", [[0.0, 0.0], [0.325, 0.12], [0.65, 0.0]])
	_add_rotation_track(walk, "VisualRoot/human_shoulder:rotation", [[0.0, -0.08], [0.325, 0.08], [0.65, -0.08]])
	_add_rotation_track(walk, "VisualRoot/human_shoulder/human_elbow:rotation", [[0.0, 0.04], [0.325, -0.04], [0.65, 0.04]])
	_add_rotation_track(walk, "VisualRoot/cyber_shoulder:rotation", [[0.0, 0.08], [0.325, -0.08], [0.65, 0.08]])
	library.add_animation("walk", walk)
	var punch := _new_animation(0.42, false)
	_add_rotation_track(punch, "VisualRoot/cyber_shoulder:rotation", [[0.0, 0.0], [0.10, -0.10], [0.22, -0.30], [0.42, 0.0]])
	_add_rotation_track(punch, "VisualRoot/cyber_shoulder/cyber_wrist:rotation", [[0.0, 0.0], [0.16, -0.03], [0.24, -0.14], [0.42, 0.0]])
	library.add_animation("punch", punch)
	var hit := _new_animation(0.30, false)
	_add_rotation_track(hit, "VisualRoot/neck:rotation", [[0.0, 0.0], [0.08, 0.10], [0.30, 0.0]])
	_add_rotation_track(hit, "VisualRoot/human_shoulder:rotation", [[0.0, 0.0], [0.10, 0.12], [0.30, 0.0]])
	_add_rotation_track(hit, "VisualRoot/cyber_shoulder:rotation", [[0.0, 0.0], [0.10, 0.14], [0.30, 0.0]])
	library.add_animation("hit", hit)
	animation_player.add_animation_library("", library)
	if Engine.is_editor_hint():
		return
	animation_player.play("idle")

func _new_animation(duration: float, looping: bool) -> Animation:
	var animation := Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR if looping else Animation.LOOP_NONE
	return animation

func _add_rotation_track(animation: Animation, path: String, keys: Array) -> void:
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(path))
	for key in keys:
		animation.track_insert_key(track, float(key[0]), float(key[1]))

func _add_review_labels() -> void:
	var title := Label.new()
	title.text = "BREAKER / TIER I — MODULAR PART FIT REVIEW"
	title.position = Vector2(34, 20)
	title.add_theme_color_override("font_color", Color("#e6edf4"))
	title.add_theme_font_size_override("font_size", 22)
	add_child(title)
	var note := Label.new()
	note.text = "QUARANTINED ART TRIAL 01   •   ESTIMATED PIVOTS / PER-PART SCALE   •   NOT RUNTIME ART"
	note.position = Vector2(34, 49)
	note.add_theme_color_override("font_color", Color("#ff6b75"))
	note.add_theme_font_size_override("font_size", 13)
	add_child(note)
	var ground := Label.new()
	ground.text = "GROUND ANCHOR"
	ground.position = Vector2(650, ground_y + 4)
	ground.add_theme_color_override("font_color", Color("#57dce3"))
	ground.add_theme_font_size_override("font_size", 12)
	add_child(ground)

func _capture_review_frame() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var pose_name := OS.get_environment("BREAKER_TRIAL_POSE").to_lower()
	if pose_name == "walk":
		await get_tree().create_timer(0.30).timeout
	elif pose_name == "punch":
		await get_tree().create_timer(0.22).timeout
	elif pose_name == "hit":
		await get_tree().create_timer(0.10).timeout
	else:
		await get_tree().create_timer(0.25).timeout
	_check(loaded_part_count == 13, "All 12 unique source images should load (boot is reused once).")
	_assert_joint_contact("head/neck to torso", pose_nodes.head_neck_sprite, pose_nodes.torso_sprite, pose_nodes.neck.global_position, 14.0)
	_assert_joint_contact("torso to pelvis", pose_nodes.torso_sprite, pose_nodes.pelvis_sprite, pose_nodes.visual_root.to_global(Vector2(0, -175)), 16.0)
	_assert_joint_contact("pelvis to back thigh", pose_nodes.pelvis_sprite, pose_nodes.back_thigh_sprite, pose_nodes.back_thigh.global_position, 18.0)
	_assert_joint_contact("pelvis to front thigh", pose_nodes.pelvis_sprite, pose_nodes.front_thigh_sprite, pose_nodes.front_thigh.global_position, 18.0)
	_assert_joint_contact("human shoulder", pose_nodes.torso_sprite, pose_nodes.human_shoulder_sprite, pose_nodes.human_shoulder.global_position, 18.0)
	_assert_joint_contact("cyber shoulder", pose_nodes.torso_sprite, pose_nodes.cyber_shoulder_sprite, pose_nodes.cyber_shoulder.global_position, 18.0)
	_assert_joint_contact("back knee", pose_nodes.back_thigh_sprite, pose_nodes.back_shin_sprite, pose_nodes.back_knee.global_position, 18.0)
	_assert_joint_contact("front knee", pose_nodes.front_thigh_sprite, pose_nodes.front_shin_sprite, pose_nodes.front_knee.global_position, 18.0)
	_assert_joint_contact("back ankle", pose_nodes.back_shin_sprite, pose_nodes.back_boot_sprite, pose_nodes.back_ankle.global_position, 16.0)
	_assert_joint_contact("front ankle", pose_nodes.front_shin_sprite, pose_nodes.front_boot_sprite, pose_nodes.front_ankle.global_position, 16.0)
	_assert_joint_contact("human elbow", pose_nodes.human_upper_arm_sprite, pose_nodes.human_forearm_sprite, pose_nodes.human_elbow.global_position, 18.0)
	_assert_joint_contact("cyber wrist", pose_nodes.cyber_arm_sprite, pose_nodes.cyber_fist_sprite, pose_nodes.cyber_wrist.global_position, 18.0)
	_assert_ground_contact("back boot", pose_nodes.back_boot_sprite, ground_y)
	_assert_ground_contact("front boot", pose_nodes.front_boot_sprite, ground_y)
	if pose_name == "walk":
		_check(absf(pose_nodes.front_thigh.rotation) > 0.05, "Walk test animation did not rotate the thigh.")
	elif pose_name == "punch":
		_check(absf(pose_nodes.cyber_shoulder.rotation) > 0.20, "Punch test animation did not extend the cyber arm.")
	elif pose_name == "hit":
		_check(absf(pose_nodes.neck.rotation) > 0.05, "Hit test animation did not apply recoil.")
	_check(is_equal_approx(pose_nodes.visual_root.global_position.y, ground_y), "Visual root left its ground anchor during test animation.")
	var output_dir := "res://docs/visual_qa"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var suffix := "neutral" if pose_name in ["", "neutral"] else pose_name
	var zoom_suffix := "_zoom" if preview_zoom > 1.0 else ""
	var output_path := output_dir + "/breaker_modular_parts_trial_01_%s%s.png" % [suffix, zoom_suffix]
	var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(output_path))
	if error != OK:
		push_error("Could not save BREAKER review capture: %s" % error)
	if test_failure_count > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)

func _assert_joint_contact(label: String, part_a: Sprite2D, part_b: Sprite2D, center: Vector2, radius: float) -> void:
	var points_a := _opaque_pixels_near(part_a, center, radius)
	var points_b := _opaque_pixels_near(part_b, center, radius)
	if points_a.is_empty() or points_b.is_empty():
		_check(false, "No visible pixels at %s for both parts (%s, %s)" % [label, part_a.name, part_b.name])
		return
	var occupied := {}
	for point in points_a:
		occupied[point] = true
	for point in points_b:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if occupied.has(point + Vector2i(dx, dy)):
					print("JOINT_CONTACT_PASS: ", label)
					return
	var nearest_distance_squared := 1000000
	for point_a in points_a:
		for point_b in points_b:
			nearest_distance_squared = mini(nearest_distance_squared, point_a.distance_squared_to(point_b))
	if nearest_distance_squared <= 2:
		print("JOINT_CONTACT_PASS: ", label, " (nearest sampled gap ", sqrt(float(nearest_distance_squared)), " px)")
	else:
		_check(false, "Visible alpha gap at %s: nearest sampled gap is %.2f px" % [label, sqrt(float(nearest_distance_squared))])

func _opaque_pixels_near(sprite: Sprite2D, center: Vector2, radius: float) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var texture_image: Image = sprite.texture.get_image()
	if texture_image == null or texture_image.is_empty():
		return points
	var inverse := sprite.get_global_transform_with_canvas().affine_inverse()
	var extent := int(ceil(radius))
	for y in range(-extent, extent + 1):
		for x in range(-extent, extent + 1):
			var viewport_point := center + Vector2(x + 0.5, y + 0.5)
			var local_point := inverse * viewport_point
			var texture_point := local_point + Vector2(texture_image.get_width(), texture_image.get_height()) * 0.5 - sprite.offset
			var pixel := Vector2i(floori(texture_point.x), floori(texture_point.y))
			if pixel.x < 0 or pixel.y < 0 or pixel.x >= texture_image.get_width() or pixel.y >= texture_image.get_height():
				continue
			if texture_image.get_pixelv(pixel).a >= 0.10:
				points.append(Vector2i(roundi(viewport_point.x), roundi(viewport_point.y)))
	return points

func _assert_ground_contact(label: String, boot_sprite: Sprite2D, baseline_y: float) -> void:
	var points := _opaque_pixels_near(boot_sprite, Vector2(boot_sprite.global_position.x, baseline_y), 60.0)
	if points.is_empty():
		_check(false, "No boot pixels found near the ground for %s" % label)
		return
	var min_gap := 1000000.0
	for point in points:
		min_gap = minf(min_gap, absf(float(point.y) - baseline_y))
	if min_gap <= 3.0:
		print("GROUND_CONTACT_PASS: ", label, " (", min_gap, " px)")
	else:
		_check(false, "%s is %.1f px from the ground anchor" % [label, min_gap])

func _check(condition: bool, message: String) -> void:
	if condition:
		return
	test_failure_count += 1
	push_error("PREVIEW_TEST_FAIL: " + message)
