extends Node2D
class_name BreakerTierOnePlaceholderRig

## Skeleton-backed polygon stand-in based on the approved BREAKER Tier I visual spec.
## It is not production art, extracted sprite parts, or a final animation rig.

const ANIMATION_DEFAULTS := {"idle": 1.0, "walk": 0.65, "punch": 0.42, "hit": 0.30, "defeated": 0.95}
const ACTION_DURATIONS := {"punch": 0.42, "hit": 0.30, "defeated": 0.95}
const POSE_TRANSITION_DURATION := 0.085

var skeleton: Skeleton2D
var bones: Dictionary = {}
var parts: Dictionary = {}
var anchors: Dictionary = {}
var head_art_sprite: Sprite2D
var animation_state := "idle"
var incoming_state := "idle"
var action_time_left := 0.0
var animation_clock := 0.0
var hp_ratio := 1.0
var tier := 1
var overload := 0.0
var animation_durations: Dictionary = ANIMATION_DEFAULTS.duplicate()
var right_facing := true
var pose_transition_from: Dictionary = {}
var pose_transition_elapsed := POSE_TRANSITION_DURATION

const CARBON := Color("#252831")
const VEST := Color("#171a21")
const METAL := Color("#59616c")
const DARK_METAL := Color("#343a44")
const SKIN := Color("#a97164")
const RED := Color("#b72e3b")
const LED := Color("#f0444f")


func _ready() -> void:
	skeleton = Skeleton2D.new()
	skeleton.name = "VisualSkeleton"
	add_child(skeleton)
	var root_bone := _make_bone("root", skeleton, Vector2.ZERO)
	_build_breaker_tier_one(root_bone)
	_add_anchor("fx_anchor_ground", self, Vector2.ZERO)
	_add_anchor("fx_anchor_neck", bones["torso"], Vector2(0.0, -36.0))
	_add_anchor("fx_anchor_fist_r", bones["signature_right_fist"], Vector2.ZERO)
	set_facing_right(true)


func _make_bone(bone_id: String, parent: Node, offset: Vector2) -> Bone2D:
	var bone := Bone2D.new()
	bone.name = bone_id.capitalize()
	bone.set_autocalculate_length_and_angle(false)
	bone.set_length(16.0)
	bone.position = offset
	bone.rest = bone.transform
	parent.add_child(bone)
	bones[bone_id] = bone
	return bone


func _make_part(part_id: String, parent: Node, points: PackedVector2Array, color: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.name = part_id.capitalize()
	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)
	parts[part_id] = polygon
	return polygon


func _add_anchor(anchor_id: String, parent: Node, offset: Vector2) -> Marker2D:
	var anchor := Marker2D.new()
	anchor.name = anchor_id
	anchor.position = offset
	parent.add_child(anchor)
	anchors[anchor_id] = anchor
	return anchor


func get_anchor_global_position(anchor_id: StringName) -> Vector2:
	var anchor: Marker2D = anchors.get(String(anchor_id))
	if not is_instance_valid(anchor):
		return Vector2.ZERO
	return anchor.global_position


func set_head_art(texture: Texture2D, pivot_px: Vector2, display_height: float) -> bool:
	var head_bone: Bone2D = bones.get("head")
	if texture == null or not is_instance_valid(head_bone) or display_height <= 0.0:
		return false
	var texture_size := Vector2(texture.get_size())
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or pivot_px.x < 0.0 or pivot_px.y < 0.0 or pivot_px.x > texture_size.x or pivot_px.y > texture_size.y:
		return false
	if not is_instance_valid(head_art_sprite):
		head_art_sprite = Sprite2D.new()
		head_art_sprite.name = "HeadArtSprite"
		head_art_sprite.centered = false
		head_art_sprite.z_index = 20
		head_bone.add_child(head_art_sprite)
	var art_scale := display_height / texture_size.y
	head_art_sprite.texture = texture
	head_art_sprite.scale = Vector2.ONE * art_scale
	head_art_sprite.position = -pivot_px * art_scale
	for part_id in ["face", "undercut_hair", "hair_undercut", "brow", "facial_scars"]:
		if parts.has(part_id):
			(parts[part_id] as Polygon2D).visible = false
	return true


func _build_breaker_tier_one(root_bone: Bone2D) -> void:
	var pelvis := _make_bone("pelvis", root_bone, Vector2(0, -44))
	_make_part("pelvis_armor", pelvis, PackedVector2Array([Vector2(-13, -8), Vector2(13, -8), Vector2(12, 8), Vector2(-12, 8)]), DARK_METAL)

	# Rear leg is drawn first; the front leg has the subtle Tier I knee brace.
	var leg_back := _make_bone("thigh_left", pelvis, Vector2(-12, 0))
	_make_part("thigh_left", leg_back, PackedVector2Array([Vector2(-7, -1), Vector2(7, -1), Vector2(8, 22), Vector2(-8, 22)]), CARBON)
	var knee_back := _make_bone("knee_left", leg_back, Vector2(0, 21))
	_make_part("shin_left", knee_back, PackedVector2Array([Vector2(-6, 0), Vector2(6, 0), Vector2(7, 21), Vector2(-7, 21)]), DARK_METAL)
	_make_part("left_knee_brace", knee_back, PackedVector2Array([Vector2(-8, 4), Vector2(8, 4), Vector2(7, 10), Vector2(-7, 10)]), METAL)
	var ankle_back := _make_bone("ankle_left", knee_back, Vector2(0, 20))
	_make_part("boot_left", ankle_back, PackedVector2Array([Vector2(-6, -3), Vector2(7, -3), Vector2(13, 4), Vector2(-8, 4)]), Color("#17191f"))

	var leg_front := _make_bone("thigh_right", pelvis, Vector2(9, 0))
	_make_part("thigh_right", leg_front, PackedVector2Array([Vector2(-7, -1), Vector2(7, -1), Vector2(8, 22), Vector2(-8, 22)]), Color("#343944"))
	var knee_front := _make_bone("knee_right", leg_front, Vector2(0, 21))
	_make_part("shin_right", knee_front, PackedVector2Array([Vector2(-6, 0), Vector2(6, 0), Vector2(7, 21), Vector2(-7, 21)]), CARBON)
	var ankle_front := _make_bone("ankle_right", knee_front, Vector2(0, 20))
	_make_part("boot_right", ankle_front, PackedVector2Array([Vector2(-6, -3), Vector2(8, -3), Vector2(14, 4), Vector2(-8, 4)]), Color("#17191f"))

	var torso := _make_bone("torso", pelvis, Vector2(0, -7))
	# Rear arm sits behind the vest. The right forearm and signature fist sit in front.
	var left_shoulder := _make_bone("shoulder_left", torso, Vector2(-15, -26))
	_make_part("upper_arm_left", left_shoulder, PackedVector2Array([Vector2(-5, -1), Vector2(5, -1), Vector2(6, 18), Vector2(-6, 18)]), SKIN)
	var left_elbow := _make_bone("elbow_left", left_shoulder, Vector2(0, 17))
	_make_part("forearm_left", left_elbow, PackedVector2Array([Vector2(-5, 0), Vector2(5, 0), Vector2(6, 18), Vector2(-6, 18)]), Color("#73564f"))
	var left_hand := _make_bone("hand_left", left_elbow, Vector2(0, 17))
	_make_part("fist_left", left_hand, PackedVector2Array([Vector2(-6, -2), Vector2(7, -2), Vector2(8, 7), Vector2(-5, 8)]), SKIN)

	_make_part("torso", torso, PackedVector2Array([Vector2(-16, -34), Vector2(-10, -39), Vector2(10, -39), Vector2(17, -33), Vector2(18, 0), Vector2(-18, 0)]), SKIN)
	_make_part("sleeveless_vest", torso, PackedVector2Array([Vector2(-14, -34), Vector2(-8, -37), Vector2(8, -37), Vector2(14, -32), Vector2(12, -3), Vector2(-12, -3)]), VEST)
	_make_part("vest_seam", torso, PackedVector2Array([Vector2(-1, -35), Vector2(1, -35), Vector2(2, -4), Vector2(0, -4)]), METAL)
	_make_part("shoulder_harness", torso, PackedVector2Array([Vector2(-15, -31), Vector2(-9, -38), Vector2(-5, -36), Vector2(-11, -25)]), DARK_METAL)
	_make_part("neck_regulator", torso, PackedVector2Array([Vector2(-5, -40), Vector2(5, -40), Vector2(6, -33), Vector2(-6, -33)]), METAL)
	_make_part("regulator_light", torso, PackedVector2Array([Vector2(-2, -39), Vector2(2, -39), Vector2(2, -35), Vector2(-2, -35)]), RED)

	var head := _make_bone("head", torso, Vector2(0, -37))
	_make_part("face", head, PackedVector2Array([Vector2(-10, -24), Vector2(8, -24), Vector2(12, -17), Vector2(10, -3), Vector2(-9, -2), Vector2(-13, -9)]), SKIN)
	_make_part("undercut_hair", head, PackedVector2Array([Vector2(-13, -20), Vector2(-15, -27), Vector2(-9, -24), Vector2(-7, -31), Vector2(-2, -25), Vector2(3, -30), Vector2(5, -24), Vector2(12, -25), Vector2(11, -20), Vector2(4, -18), Vector2(-8, -18)]), Color("#17191f"))
	_make_part("hair_undercut", head, PackedVector2Array([Vector2(-13, -19), Vector2(-8, -19), Vector2(-9, -9), Vector2(-13, -10)]), Color("#282a30"))
	_make_part("brow", head, PackedVector2Array([Vector2(2, -17), Vector2(10, -18), Vector2(9, -16), Vector2(2, -15)]), Color("#211a1c"))
	_make_part("facial_scars", head, PackedVector2Array([Vector2(-8, -12), Vector2(-6, -14), Vector2(1, -9), Vector2(0, -7), Vector2(-2, -8), Vector2(-7, -11)]), RED)

	var right_shoulder := _make_bone("shoulder_right", torso, Vector2(15, -27))
	_make_part("upper_arm_right", right_shoulder, PackedVector2Array([Vector2(-6, -2), Vector2(6, -2), Vector2(8, 16), Vector2(-7, 19)]), SKIN)
	var right_elbow := _make_bone("elbow_right", right_shoulder, Vector2(0, 16))
	_make_part("cyber_forearm_right", right_elbow, PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(10, 17), Vector2(7, 24), Vector2(-8, 22)]), DARK_METAL)
	_make_part("forearm_plate", right_elbow, PackedVector2Array([Vector2(-7, 3), Vector2(7, 2), Vector2(8, 12), Vector2(-6, 14)]), METAL)
	_make_part("forearm_led", right_elbow, PackedVector2Array([Vector2(-6, 6), Vector2(-3, 5), Vector2(-3, 9), Vector2(-6, 10)]), LED)
	var right_fist := _make_bone("signature_right_fist", right_elbow, Vector2(0, 22))
	_make_part("giant_right_fist", right_fist, PackedVector2Array([Vector2(-10, -3), Vector2(10, -3), Vector2(14, 4), Vector2(12, 15), Vector2(-11, 15), Vector2(-14, 7)]), Color("#292d36"))
	_make_part("fist_knuckle_plate", right_fist, PackedVector2Array([Vector2(-10, 0), Vector2(11, 0), Vector2(12, 7), Vector2(-11, 8)]), METAL)
	var fist_light := _make_part("fist_red_led", right_fist, PackedVector2Array([Vector2(7, 2), Vector2(11, 2), Vector2(11, 5), Vector2(7, 5)]), LED)
	parts["fist_led"] = fist_light


func set_animation_durations(values: Dictionary) -> void:
	for animation in ANIMATION_DEFAULTS:
		animation_durations[animation] = maxf(0.05, float(values.get(animation, ANIMATION_DEFAULTS[animation])))


func set_tier(value: int) -> bool:
	if value != 1:
		return false
	tier = 1
	return true


func set_facing_right(value: bool) -> void:
	right_facing = value
	if is_instance_valid(skeleton):
		skeleton.scale.x = 1.0 if value else -1.0


func set_overload(value: float) -> void:
	overload = clampf(value, 0.0, 1.0)
	if parts.has("fist_led"):
		parts["fist_led"].color = LED.lerp(Color("#ffb24a"), overload)


func play_action(action: StringName) -> void:
	var action_name := String(action)
	if action_name == "defeat":
		action_name = "defeated"
	if action_name in ACTION_DURATIONS:
		_begin_pose_transition()
		animation_state = action_name
		action_time_left = float(animation_durations.get(action_name, ACTION_DURATIONS[action_name]))


func present(world_x: float, state: String, health_ratio: float, world_y: float = 510.0) -> void:
	position = Vector2(world_x, world_y)
	hp_ratio = clampf(health_ratio, 0.0, 1.0)
	if state != incoming_state:
		incoming_state = state
		if state in ["punch", "hit", "defeated"]:
			play_action(StringName(state))
		elif action_time_left <= 0.0:
			if animation_state != state:
				_begin_pose_transition()
			animation_state = state
	queue_redraw()


func _process(delta: float) -> void:
	animation_clock += delta
	if action_time_left > 0.0:
		action_time_left = maxf(0.0, action_time_left - delta)
		if action_time_left == 0.0 and animation_state != "defeated":
			var next_state := incoming_state if incoming_state in ["idle", "walk"] else "idle"
			if animation_state != next_state:
				_begin_pose_transition()
			animation_state = next_state
	_pose_idle()
	var phase := animation_clock * TAU
	if animation_state == "walk":
		var walk_period: float = float(animation_durations.get("walk", 0.65))
		var gait_phase := phase / walk_period
		var stride := sin(gait_phase)
		var knee_lift_left := maxf(0.0, sin(gait_phase + 0.8)) * 0.25
		var knee_lift_right := maxf(0.0, -sin(gait_phase + 0.8)) * 0.25
		bones["pelvis"].rotation = sin(gait_phase * 2.0) * 0.018
		bones["torso"].rotation = -0.025 + sin(gait_phase + PI * 0.5) * 0.018
		bones["head"].rotation = -bones["torso"].rotation * 0.45
		bones["thigh_left"].rotation = stride * 0.22
		bones["thigh_right"].rotation = -stride * 0.22
		bones["knee_left"].rotation = knee_lift_left
		bones["knee_right"].rotation = knee_lift_right
		# Counter-rotate each ankle against its leg so the boots stay near level.
		bones["ankle_left"].rotation = -bones["thigh_left"].rotation * 0.72 - knee_lift_left * 0.65
		bones["ankle_right"].rotation = -bones["thigh_right"].rotation * 0.72 - knee_lift_right * 0.65
		# BREAKER keeps a compact guard; the natural arm counter-swings while the heavier cyber arm moves less.
		bones["shoulder_left"].rotation = 0.1 - stride * 0.14
		bones["elbow_left"].rotation = -0.45 - maxf(0.0, stride) * 0.05
		bones["shoulder_right"].rotation = 0.06 + stride * 0.045
		bones["elbow_right"].rotation = -0.14 - maxf(0.0, -stride) * 0.035
	elif animation_state == "punch":
		var progress := 1.0 - action_time_left / float(animation_durations["punch"])
		var strike := sin(clampf(progress, 0.0, 1.0) * PI)
		bones["shoulder_right"].rotation = -1.1 * strike
		bones["elbow_right"].rotation = -0.48 * strike
	elif animation_state == "hit":
		var recoil := sin((1.0 - action_time_left / float(animation_durations["hit"])) * PI)
		bones["torso"].rotation = -0.12 * recoil
		bones["shoulder_right"].rotation = -0.34 * recoil
	elif animation_state == "defeated":
		var collapse := clampf(1.0 - action_time_left / float(animation_durations["defeated"]), 0.0, 1.0)
		bones["pelvis"].rotation = 0.18 * collapse
		bones["torso"].rotation = -0.72 * collapse
		bones["head"].rotation = 0.35 * collapse
	_apply_pose_transition(delta)
	queue_redraw()


func _pose_idle() -> void:
	var breath := sin(animation_clock * TAU) * 0.018
	bones["pelvis"].rotation = 0.0
	bones["torso"].rotation = breath
	bones["head"].rotation = -breath * 0.4
	bones["shoulder_left"].rotation = 0.1
	bones["elbow_left"].rotation = -0.45
	bones["shoulder_right"].rotation = 0.06 + sin(animation_clock * 8.0) * 0.035
	bones["elbow_right"].rotation = -0.14
	bones["thigh_left"].rotation = 0.04
	bones["thigh_right"].rotation = -0.04
	bones["knee_left"].rotation = 0.0
	bones["knee_right"].rotation = 0.0


func _begin_pose_transition() -> void:
	pose_transition_from.clear()
	for bone_id in bones:
		var bone := bones[bone_id] as Bone2D
		if is_instance_valid(bone):
			pose_transition_from[bone_id] = bone.rotation
	pose_transition_elapsed = 0.0


func _apply_pose_transition(delta: float) -> void:
	if pose_transition_from.is_empty():
		return
	pose_transition_elapsed = minf(POSE_TRANSITION_DURATION, pose_transition_elapsed + delta)
	var progress := pose_transition_elapsed / POSE_TRANSITION_DURATION
	var eased_progress := progress * progress * (3.0 - 2.0 * progress)
	for bone_id in pose_transition_from:
		var bone := bones[bone_id] as Bone2D
		if is_instance_valid(bone):
			bone.rotation = lerp_angle(float(pose_transition_from[bone_id]), bone.rotation, eased_progress)
	if progress >= 1.0:
		pose_transition_from.clear()


func _draw() -> void:
	var bar_width := 54.0
	draw_rect(Rect2(Vector2(-bar_width / 2.0, -160), Vector2(bar_width, 6)), Color("#191820"))
	draw_rect(Rect2(Vector2(-bar_width / 2.0, -160), Vector2(bar_width * hp_ratio, 6)), Color("#ff4765" if hp_ratio < 0.3 else "#48e4cf"))
