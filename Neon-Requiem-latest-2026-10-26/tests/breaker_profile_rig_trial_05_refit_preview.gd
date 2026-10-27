extends Node2D
"""Isolated presentation rig built from the user-approved BREAKER profile.

All art and provisional pivots stay outside the runtime character scene.
"""

const ART_DIR := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v2/"
const MANIFEST_PATH := ART_DIR + "pivot_manifest.json"
const DISPLAY_HEIGHT := 256.0
const SOURCE_VISIBLE_HEIGHT := 1477.0
const STAGE_GROUND := Vector2(640.0, 590.0)

var visual_root: Node2D
var skeleton: Skeleton2D
var animation_player: AnimationPlayer
var pivot_px: Dictionary = {}
var bones: Dictionary = {}
var sprites: Dictionary = {}
var underpaint_sprites: Dictionary = {}
var loaded_part_count := 0
var loaded_underpaint_count := 0
var load_failures := 0
var draw_review_stage := true


func _ready() -> void:
	_read_pivots()
	_build_rig()
	_build_test_animations()


func _draw() -> void:
	if not draw_review_stage:
		return
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#12171d"), true)
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 70), Vector2(x, STAGE_GROUND.y), Color(0.18, 0.22, 0.26, 0.28), 1.0)
	for y in range(70, int(STAGE_GROUND.y) + 1, 40):
		draw_line(Vector2(260, y), Vector2(1020, y), Color(0.18, 0.22, 0.26, 0.28), 1.0)
	draw_line(Vector2(260, STAGE_GROUND.y), Vector2(1020, STAGE_GROUND.y), Color("#57dce3"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(36, 48), "BREAKER PROFILE RIG TRIAL 05 — GUARDED POSE / INFERRED PIVOTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e8edf2"))


func _read_pivots() -> void:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open BREAKER profile pivot manifest.")
		load_failures += 1
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("pivots_px"):
		push_error("BREAKER profile pivot manifest has no pivots_px object.")
		load_failures += 1
		return
	var values: Dictionary = parsed["pivots_px"]
	for key in values:
		var xy: Array = values[key]
		pivot_px[str(key)] = Vector2(float(xy[0]), float(xy[1]))


func _build_rig() -> void:
	visual_root = Node2D.new()
	visual_root.name = "VisualRoot"
	visual_root.position = STAGE_GROUND
	add_child(visual_root)

	skeleton = Skeleton2D.new()
	skeleton.name = "VisualSkeleton"
	# Match the written 256 px feet-to-hair target using the measured alpha bounds,
	# rather than fitting the full transparent 1536 px canvas to 256 px.
	var fit := DISPLAY_HEIGHT / SOURCE_VISIBLE_HEIGHT
	skeleton.scale = Vector2.ONE * fit
	visual_root.add_child(skeleton)

	var ground := _pivot("ground_anchor")
	var root_bone := Bone2D.new()
	root_bone.name = "GroundRoot"
	root_bone.position = Vector2.ZERO
	root_bone.set_autocalculate_length_and_angle(false)
	skeleton.add_child(root_bone)
	bones["GroundRoot"] = root_bone

	var pelvis_bone := _add_bone(root_bone, "Pelvis", "pelvis", ground)
	_add_part(pelvis_bone, "pelvis", "pelvis", 6)

	var torso_bone := _add_bone(pelvis_bone, "Torso", "torso", _pivot("pelvis"))
	_add_part(torso_bone, "torso", "torso", 7)
	var head_bone := _add_bone(torso_bone, "HeadNeck", "head_neck", _pivot("torso"))
	_add_part(head_bone, "head_neck", "head_neck", 8)

	var cyber_shoulder := _add_bone(torso_bone, "CyberShoulder", "cyber_shoulder", _pivot("torso"))
	_add_part(cyber_shoulder, "cyber_upper_arm", "cyber_shoulder", 9)
	var cyber_elbow := _add_bone(cyber_shoulder, "CyberElbow", "cyber_elbow", _pivot("cyber_shoulder"))
	_add_part(cyber_elbow, "cyber_forearm", "cyber_elbow", 10)

	var natural_shoulder := _add_bone(torso_bone, "NaturalShoulder", "natural_shoulder", _pivot("torso"))
	_add_part(natural_shoulder, "natural_upper_arm", "natural_shoulder", 11)
	var natural_elbow := _add_bone(natural_shoulder, "NaturalElbow", "natural_elbow", _pivot("natural_shoulder"))
	_add_part(natural_elbow, "natural_forearm", "natural_elbow", 12)

	var left_hip := _add_bone(pelvis_bone, "LeftHip", "left_hip", _pivot("pelvis"))
	_add_part(left_hip, "left_thigh", "left_hip", 3)
	var left_knee := _add_bone(left_hip, "LeftKnee", "left_knee", _pivot("left_hip"))
	_add_part(left_knee, "left_shin", "left_knee", 4)
	var left_ankle := _add_bone(left_knee, "LeftAnkle", "left_ankle", _pivot("left_knee"))
	_add_part(left_ankle, "left_boot", "left_ankle", 5)

	var right_hip := _add_bone(pelvis_bone, "RightHip", "right_hip", _pivot("pelvis"))
	_add_part(right_hip, "right_thigh", "right_hip", 0)
	var right_knee := _add_bone(right_hip, "RightKnee", "right_knee", _pivot("right_hip"))
	_add_part(right_knee, "right_shin", "right_knee", 1)
	var right_ankle := _add_bone(right_knee, "RightAnkle", "right_ankle", _pivot("right_knee"))
	_add_part(right_ankle, "right_boot", "right_ankle", 2)

	# Bone2D.rest defaults to an all-zero transform when nodes are created in code.
	# Capture the assembled neutral hierarchy so Skeleton2D can compute valid poses.
	for bone_variant in bones.values():
		var bone := bone_variant as Bone2D
		bone.set_autocalculate_length_and_angle(false)
		bone.rest = bone.transform
		bone.set_length(maxf(bone.position.length(), 1.0))
		bone.set_bone_angle(bone.position.angle())


func _add_bone(parent: Bone2D, bone_name: String, pivot_name: String, parent_pivot: Vector2) -> Bone2D:
	var bone := Bone2D.new()
	bone.name = bone_name
	bone.position = _pivot(pivot_name) - parent_pivot
	bone.set_autocalculate_length_and_angle(false)
	parent.add_child(bone)
	bones[bone_name] = bone
	return bone


func _add_part(parent: Bone2D, part_name: String, pivot_name: String, z: int) -> void:
	var underpaint_path := ProjectSettings.globalize_path(ART_DIR + "underpaint_" + part_name + ".png")
	var underpaint_image := Image.new()
	var underpaint_error := underpaint_image.load(underpaint_path)
	if underpaint_error != OK:
		push_error("Could not load inferred underpaint %s (%d)." % [part_name, underpaint_error])
		load_failures += 1
	else:
		var underpaint_sprite := Sprite2D.new()
		underpaint_sprite.name = "Underpaint_" + part_name
		underpaint_sprite.texture = ImageTexture.create_from_image(underpaint_image)
		underpaint_sprite.centered = false
		underpaint_sprite.position = -_pivot(pivot_name)
		underpaint_sprite.z_index = 1
		underpaint_sprite.z_as_relative = false
		underpaint_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		parent.add_child(underpaint_sprite)
		underpaint_sprites[part_name] = underpaint_sprite
		loaded_underpaint_count += 1

	var path := ProjectSettings.globalize_path(ART_DIR + part_name + ".png")
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("Could not load profile part %s (%d)." % [part_name, error])
		load_failures += 1
		return
	var sprite := Sprite2D.new()
	sprite.name = part_name
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.position = -_pivot(pivot_name)
	sprite.z_index = z + 2
	sprite.z_as_relative = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(sprite)
	sprites[part_name] = sprite
	loaded_part_count += 1


func _build_test_animations() -> void:
	animation_player = AnimationPlayer.new()
	animation_player.name = "TrialAnimationPlayer"
	animation_player.root_node = NodePath("..")
	add_child(animation_player)
	var library := AnimationLibrary.new()
	library.add_animation("idle", _make_animation(1.0, true, [
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso", [[0.0, 0.0], [0.5, 0.012], [1.0, 0.0]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/HeadNeck", [[0.0, 0.0], [0.5, -0.008], [1.0, 0.0]]]
	]))
	library.add_animation("walk", _make_animation(0.65, true, [
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis:position", _gait_pelvis_position_keys()],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis:rotation", _gait_keys([-0.018, 0.012, 0.018, -0.012, -0.018])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso", _gait_keys([0.0, 0.018, 0.0, -0.018, 0.0])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/HeadNeck", _gait_keys([0.0, -0.012, 0.0, 0.012, 0.0])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/LeftHip", _gait_keys([-0.20, -0.08, 0.18, 0.08, -0.20])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/LeftHip/LeftKnee", _gait_keys([0.04, 0.27, 0.03, 0.05, 0.04])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/LeftHip/LeftKnee/LeftAnkle", _gait_keys([0.10, -0.19, -0.21, -0.10, 0.10])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/RightHip", _gait_keys([0.20, 0.10, -0.18, -0.08, 0.20])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/RightHip/RightKnee", _gait_keys([0.04, 0.04, 0.03, 0.27, 0.04])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/RightHip/RightKnee/RightAnkle", _gait_keys([-0.24, -0.14, 0.15, -0.19, -0.24])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/NaturalShoulder", _gait_keys([0.10, 0.06, -0.10, -0.06, 0.10])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/NaturalShoulder/NaturalElbow", _gait_keys([-0.25, -0.31, -0.23, -0.18, -0.25])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/CyberShoulder", _gait_keys([-0.09, -0.05, 0.08, 0.05, -0.09])],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/CyberShoulder/CyberElbow", _gait_keys([-0.16, -0.11, -0.20, -0.25, -0.16])]
	]))
	library.add_animation("punch", _make_animation(0.42, false, [
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/CyberShoulder", [[0.0, 0.0], [0.10, -0.08], [0.22, -0.22], [0.42, 0.0]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/CyberShoulder/CyberElbow", [[0.0, 0.0], [0.16, -0.05], [0.24, -0.18], [0.42, 0.0]]]
	]))
	library.add_animation("hit", _make_animation(0.30, false, [
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso", [[0.0, 0.0], [0.08, 0.055], [0.30, 0.0]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/HeadNeck", [[0.0, 0.0], [0.08, -0.07], [0.30, 0.0]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/NaturalShoulder", [[0.0, 0.0], [0.08, 0.08], [0.30, 0.0]]]
	]))
	library.add_animation("defeat", _make_animation(0.95, false, [
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis", [[0.0, 0.0], [0.24, 0.05], [0.55, 0.16], [0.95, 0.12]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso", [[0.0, 0.0], [0.24, -0.10], [0.55, -0.58], [0.95, -0.78]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/HeadNeck", [[0.0, 0.0], [0.24, 0.04], [0.55, 0.22], [0.95, 0.28]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/LeftHip", [[0.0, 0.0], [0.24, -0.08], [0.55, -0.26], [0.95, -0.38]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/LeftHip/LeftKnee", [[0.0, 0.0], [0.24, 0.05], [0.55, 0.28], [0.95, 0.52]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/RightHip", [[0.0, 0.0], [0.24, 0.04], [0.55, 0.12], [0.95, 0.20]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/RightHip/RightKnee", [[0.0, 0.0], [0.24, 0.0], [0.55, 0.08], [0.95, 0.15]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/NaturalShoulder", [[0.0, 0.0], [0.24, 0.12], [0.55, 0.35], [0.95, 0.22]]],
		["VisualRoot/VisualSkeleton/GroundRoot/Pelvis/Torso/CyberShoulder", [[0.0, 0.0], [0.24, -0.05], [0.55, -0.32], [0.95, -0.26]]]
	]))
	animation_player.add_animation_library("", library)


func _make_animation(duration: float, looped: bool, tracks: Array) -> Animation:
	var animation := Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	for track_data in tracks:
		var track := animation.add_track(Animation.TYPE_VALUE)
		var track_path := str(track_data[0])
		if not track_path.contains(":"):
			track_path += ":rotation"
		animation.track_set_path(track, NodePath(track_path))
		animation.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)
		for key_data in track_data[1]:
			animation.track_insert_key(track, float(key_data[0]), key_data[1])
	return animation


func _gait_keys(values: Array) -> Array:
	var times := [0.0, 0.1625, 0.325, 0.4875, 0.65]
	var keys: Array = []
	for index in range(times.size()):
		keys.append([times[index], values[index]])
	return keys


func _gait_pelvis_position_keys() -> Array:
	var base_position := _pivot("pelvis") - _pivot("ground_anchor")
	# Settle the pelvis a little at the opposite contact point; pass-through beats rise subtly.
	var offsets := [0.0, -4.0, 17.0, -4.0, 0.0]
	var keys: Array = []
	var times := [0.0, 0.1625, 0.325, 0.4875, 0.65]
	for index in range(times.size()):
		keys.append([times[index], base_position + Vector2(0.0, offsets[index])])
	return keys


func play_pose(pose: String) -> void:
	for bone in bones.values():
		(bone as Bone2D).rotation = 0.0
	animation_player.stop()
	if pose != "neutral":
		animation_player.play(pose)


func has_pose(pose: String) -> bool:
	return animation_player.has_animation(pose)


func get_bone_rotation(bone_name: String) -> float:
	return (bones[bone_name] as Bone2D).rotation


func get_anchor_global_position() -> Vector2:
	return visual_root.global_position


func check_neutral_alignment(tolerance: float = 0.05) -> bool:
	var expected_origin := skeleton.to_global(-_pivot("ground_anchor"))
	for sprite in sprites.values():
		if (sprite as Sprite2D).global_transform.origin.distance_to(expected_origin) > tolerance:
			return false
	return true


func _pivot(name: String) -> Vector2:
	return pivot_px.get(name, Vector2.ZERO)
