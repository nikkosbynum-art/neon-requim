extends Node2D
class_name CipherTierOneRigBlockout

## QA-only Skeleton2D blockout. Placeholder polygons are not character art.
## The quarantined head composite is used only to test the neck-socket transform.

const ART_PATH := "res://assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/cleanup_working/CIPHER_T1_HEAD_NECK_CLEANED_CANDIDATE_01_QUARANTINED.png"
const HEAD_PIVOT_PX := Vector2(760.0, 815.0) # provisional review value
const HEAD_DISPLAY_HEIGHT := 110.0 # provisional visible-silhouette height

const CARBON := Color("#22252c")
const JACKET := Color("#30343d")
const EDGE := Color("#555d69")
const PLACEHOLDER := Color("#b34a55")

var skeleton: Skeleton2D
var bones: Dictionary = {}
var parts: Dictionary = {}
var head_sprite: Sprite2D
var head_image_bounds := Rect2i(372, 141, 793, 856)
var load_failures := 0
var current_pose := "neutral"


func _ready() -> void:
	_build_skeleton()
	_build_body_blockout()
	_attach_head_candidate()
	set_pose("neutral")


func _make_bone(bone_id: String, parent: Node, offset: Vector2, length: float = 18.0) -> Bone2D:
	var bone := Bone2D.new()
	bone.name = bone_id
	bone.set_autocalculate_length_and_angle(false)
	bone.set_length(length)
	bone.position = offset
	bone.rest = bone.transform
	parent.add_child(bone)
	bones[bone_id] = bone
	return bone


func _make_polygon(part_id: String, parent: Node, points: PackedVector2Array, color: Color, z_order: int = 0) -> Polygon2D:
	var shape := Polygon2D.new()
	shape.name = part_id
	shape.polygon = points
	shape.color = color
	shape.z_index = z_order
	parent.add_child(shape)
	parts[part_id] = shape
	return shape


func _build_skeleton() -> void:
	var visual_root := Node2D.new()
	visual_root.name = "VisualRoot"
	add_child(visual_root)
	skeleton = Skeleton2D.new()
	skeleton.name = "CipherSkeleton"
	visual_root.add_child(skeleton)
	var root_bone := _make_bone("ground_root", skeleton, Vector2.ZERO, 1.0)
	var pelvis := _make_bone("pelvis", root_bone, Vector2(0.0, -69.0), 28.0)
	var torso := _make_bone("torso", pelvis, Vector2(0.0, -5.0), 58.0)
	_make_bone("neck_socket", torso, Vector2(0.0, -67.0), 14.0)

	var rear_hip := _make_bone("rear_hip", pelvis, Vector2(-10.0, 1.0), 30.0)
	var rear_knee := _make_bone("rear_knee", rear_hip, Vector2(0.0, 28.0), 29.0)
	_make_bone("rear_ankle", rear_knee, Vector2(0.0, 28.0), 12.0)
	var front_hip := _make_bone("front_hip", pelvis, Vector2(9.0, 1.0), 30.0)
	var front_knee := _make_bone("front_knee", front_hip, Vector2(0.0, 28.0), 29.0)
	_make_bone("front_ankle", front_knee, Vector2(0.0, 28.0), 12.0)

	var rear_shoulder := _make_bone("rear_shoulder", torso, Vector2(-17.0, -52.0), 24.0)
	var rear_elbow := _make_bone("rear_elbow", rear_shoulder, Vector2(0.0, 23.0), 22.0)
	_make_bone("rear_wrist", rear_elbow, Vector2(0.0, 22.0), 10.0)
	var front_shoulder := _make_bone("front_shoulder", torso, Vector2(17.0, -52.0), 24.0)
	var front_elbow := _make_bone("front_elbow", front_shoulder, Vector2(0.0, 23.0), 22.0)
	_make_bone("front_wrist", front_elbow, Vector2(0.0, 22.0), 10.0)


func _build_body_blockout() -> void:
	var pelvis: Bone2D = bones["pelvis"]
	var torso: Bone2D = bones["torso"]
	_make_polygon("placeholder_pelvis", pelvis, PackedVector2Array([Vector2(-17, -4), Vector2(17, -4), Vector2(19, 14), Vector2(-19, 14)]), PLACEHOLDER)
	_make_polygon("placeholder_torso", torso, PackedVector2Array([Vector2(-20, -4), Vector2(-18, -63), Vector2(13, -67), Vector2(22, -56), Vector2(20, -5)]), JACKET)
	_make_polygon("placeholder_backpack", torso, PackedVector2Array([Vector2(-29, -57), Vector2(-17, -61), Vector2(-16, -13), Vector2(-28, -10)]), EDGE, -2)

	for side in ["rear", "front"]:
		var shade := CARBON if side == "rear" else JACKET
		var hip: Bone2D = bones[side + "_hip"]
		var knee: Bone2D = bones[side + "_knee"]
		var ankle: Bone2D = bones[side + "_ankle"]
		_make_polygon("placeholder_%s_thigh" % side, hip, PackedVector2Array([Vector2(-9, -2), Vector2(9, -2), Vector2(10, 31), Vector2(-10, 31)]), shade, -1 if side == "rear" else 1)
		_make_polygon("placeholder_%s_shin" % side, knee, PackedVector2Array([Vector2(-8, -2), Vector2(8, -2), Vector2(9, 31), Vector2(-9, 31)]), EDGE if side == "rear" else shade, -1 if side == "rear" else 1)
		_make_polygon("placeholder_%s_boot" % side, ankle, PackedVector2Array([Vector2(-9, -2), Vector2(8, -2), Vector2(15, 6), Vector2(-10, 8)]), CARBON, -1 if side == "rear" else 1)

	for side in ["rear", "front"]:
		var shade := CARBON if side == "rear" else JACKET
		var shoulder: Bone2D = bones[side + "_shoulder"]
		var elbow: Bone2D = bones[side + "_elbow"]
		var wrist: Bone2D = bones[side + "_wrist"]
		var z_order := -2 if side == "rear" else 2
		_make_polygon("placeholder_%s_upper_arm" % side, shoulder, PackedVector2Array([Vector2(-7, -2), Vector2(7, -2), Vector2(8, 26), Vector2(-8, 26)]), shade, z_order)
		_make_polygon("placeholder_%s_forearm" % side, elbow, PackedVector2Array([Vector2(-6, -2), Vector2(6, -2), Vector2(7, 25), Vector2(-7, 25)]), EDGE if side == "front" else shade, z_order)
		_make_polygon("placeholder_%s_hand" % side, wrist, PackedVector2Array([Vector2(-6, -2), Vector2(6, -2), Vector2(7, 9), Vector2(-7, 9)]), PLACEHOLDER, z_order)


func _attach_head_candidate() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(ART_PATH))
	if error != OK or image.get_size() != Vector2i(1536, 1120):
		load_failures += 1
		return
	var texture := ImageTexture.create_from_image(image)
	head_sprite = Sprite2D.new()
	head_sprite.name = "QuarantinedHeadComposite"
	head_sprite.centered = false
	head_sprite.texture = texture
	var art_scale := HEAD_DISPLAY_HEIGHT / float(head_image_bounds.size.y)
	head_sprite.scale = Vector2.ONE * art_scale
	head_sprite.position = -HEAD_PIVOT_PX * art_scale
	head_sprite.z_index = 3
	(bones["neck_socket"] as Bone2D).add_child(head_sprite)


func set_pose(pose_name: String) -> bool:
	if not bones.has("torso"):
		return false
	current_pose = pose_name
	for bone in bones.values():
		(bone as Bone2D).rotation = 0.0
	match pose_name:
		"neutral", "idle":
			bones["torso"].rotation = 0.01 if pose_name == "idle" else 0.0
			bones["neck_socket"].rotation = 0.025 if pose_name == "idle" else 0.0
		"walk":
			bones["rear_hip"].rotation = -0.22
			bones["front_hip"].rotation = 0.22
			bones["rear_knee"].rotation = 0.28
			bones["front_knee"].rotation = -0.18
			bones["rear_shoulder"].rotation = 0.14
			bones["front_shoulder"].rotation = -0.14
		"aim_fire":
			bones["front_shoulder"].rotation = -0.62
			bones["front_elbow"].rotation = 0.28
			bones["rear_shoulder"].rotation = -0.42
		"hit":
			bones["torso"].rotation = -0.06
			bones["neck_socket"].rotation = 0.08
		"defeat":
			bones["torso"].rotation = 0.3
			bones["rear_hip"].rotation = 0.28
			bones["front_hip"].rotation = 0.42
		_:
			return false
	return true


func get_ground_anchor() -> Vector2:
	return global_position
