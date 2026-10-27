extends Node2D
class_name CipherTierOneReferenceCutoutRigCandidate

## Quarantined CIPHER Tier I rig candidate assembled from visible pixels in the
## approved side turnaround. Inferred hidden anatomy and pivots are provisional.

const PART_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/"
const ART_SCALE := 0.30
const SOURCE_GROUND := Vector2(182.0, 954.0)

var skeleton: Skeleton2D
var bones: Dictionary = {}
var parts: Dictionary = {}
var load_failures: Array[String] = []
var current_pose := "neutral"

const PARTS := {
	"head": {"file": "CIPHER_T1_HEAD_HOOD_HAIR_FACE_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(205, 193), "parent": "neck_socket", "z": 6},
	"backpack": {"file": "CIPHER_T1_BACKPACK_MOUNT_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(175, 610), "parent": "torso", "z": -3},
	"torso": {"file": "CIPHER_T1_TORSO_JACKET_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(175, 610), "parent": "torso", "z": 1},
	"pelvis": {"file": "CIPHER_T1_PELVIS_BELT_GEAR_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(175, 610), "parent": "torso", "z": 2},
	"upper_arm": {"file": "CIPHER_T1_NEAR_UPPER_ARM_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(160, 220), "parent": "near_shoulder", "z": 3},
	"forearm": {"file": "CIPHER_T1_NEAR_FOREARM_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(148, 338), "parent": "near_elbow", "z": 4},
	"hand": {"file": "CIPHER_T1_NEAR_HAND_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(146, 417), "parent": "near_wrist", "z": 5},
	"thigh": {"file": "CIPHER_T1_NEAR_THIGH_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(168, 640), "parent": "near_hip", "z": 0},
	"shin": {"file": "CIPHER_T1_NEAR_SHIN_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(173, 810), "parent": "near_knee", "z": 0},
	"boot": {"file": "CIPHER_T1_NEAR_BOOT_REF_CUTOUT_CANDIDATE_01.png", "pivot": Vector2(160, 880), "parent": "near_ankle", "z": 1},
	"rifle": {"file": "CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png", "pivot": Vector2(250, 140), "parent": "near_wrist", "z": 4},
}


func _ready() -> void:
	position = Vector2(560.0, 610.0)
	scale = Vector2.ONE * ART_SCALE
	_build_rig()
	_attach_parts()
	set_pose("neutral")


func _make_bone(id: String, parent: Node, local_position: Vector2) -> Bone2D:
	var bone := Bone2D.new()
	bone.name = id
	bone.set_autocalculate_length_and_angle(false)
	bone.position = local_position
	bone.rest = bone.transform
	parent.add_child(bone)
	bones[id] = bone
	return bone


func _build_rig() -> void:
	skeleton = Skeleton2D.new()
	skeleton.name = "CipherSkeleton"
	skeleton.position = -SOURCE_GROUND
	add_child(skeleton)
	var root := _make_bone("ground_root", skeleton, Vector2.ZERO)
	var torso := _make_bone("torso", root, Vector2(175, 610))
	_make_bone("neck_socket", torso, Vector2(30, -417))
	var shoulder := _make_bone("near_shoulder", torso, Vector2(-15, -390))
	var elbow := _make_bone("near_elbow", shoulder, Vector2(-12, 118))
	_make_bone("near_wrist", elbow, Vector2(-2, 79))
	var hip := _make_bone("near_hip", torso, Vector2(-7, 30))
	var knee := _make_bone("near_knee", hip, Vector2(5, 170))
	_make_bone("near_ankle", knee, Vector2(-13, 70))
	var far_shoulder := _make_bone("far_shoulder", torso, Vector2(-18, -390))
	var far_elbow := _make_bone("far_elbow", far_shoulder, Vector2(-12, 118))
	_make_bone("far_wrist", far_elbow, Vector2(-2, 79))
	var far_hip := _make_bone("far_hip", torso, Vector2(-10, 30))
	var far_knee := _make_bone("far_knee", far_hip, Vector2(5, 170))
	_make_bone("far_ankle", far_knee, Vector2(-13, 70))


func _attach_parts() -> void:
	for part_id: String in PARTS:
		var data: Dictionary = PARTS[part_id]
		var image := Image.new()
		var image_error := image.load(ProjectSettings.globalize_path(PART_ROOT + data.file))
		if image_error != OK:
			load_failures.append(part_id + ":" + data.file)
			continue
		var texture := ImageTexture.create_from_image(image)
		var sprite := Sprite2D.new()
		sprite.name = part_id
		sprite.texture = texture
		sprite.centered = true
		sprite.z_index = int(data.z)
		var pivot: Vector2 = data.pivot
		var source_center := Vector2(texture.get_size()) * 0.5
		var source_origin: Vector2 = Vector2(PARTS_SOURCE_ORIGIN.get(part_id, Vector2.ZERO))
		sprite.position = source_center + source_origin - pivot
		if part_id == "rifle":
			# Keep the receiver over the palm while its barrel stays level in aim pose.
			sprite.position = Vector2(20, 45)
		(bones[String(data.parent)] as Bone2D).add_child(sprite)
		parts[part_id] = sprite


const PARTS_SOURCE_ORIGIN := {
	"head": Vector2(13, -48), "backpack": Vector2(-31, -27), "torso": Vector2(66, 90),
	"pelvis": Vector2(46, 446), "upper_arm": Vector2(46, 94), "forearm": Vector2(45, 260),
	"hand": Vector2(49, 354), "thigh": Vector2(41, 576), "shin": Vector2(46, 725), "boot": Vector2(22, 801),
	"rifle": Vector2.ZERO,
}


func set_pose(pose_name: String) -> bool:
	if not bones.has("torso"):
		return false
	for bone in bones.values():
		(bone as Bone2D).rotation = 0.0
	current_pose = pose_name
	match pose_name:
		"neutral", "idle":
			bones["torso"].rotation = 0.008 if pose_name == "idle" else 0.0
			bones["neck_socket"].rotation = -0.008 if pose_name == "idle" else 0.0
		"walk":
			bones["near_hip"].rotation = -0.15
			bones["near_shoulder"].rotation = 0.14
			bones["far_hip"].rotation = 0.14
			bones["far_knee"].rotation = 0.0
			bones["far_shoulder"].rotation = -0.10
			bones["far_elbow"].rotation = 0.05
		"aim_fire":
			bones["near_shoulder"].rotation = -1.20
		"hit":
			bones["torso"].rotation = -0.07
			bones["neck_socket"].rotation = 0.06
		"defeat":
			bones["torso"].rotation = 0.20
			bones["near_hip"].rotation = 0.31
			bones["far_hip"].rotation = -0.14
		_:
			return false
	if parts.has("rifle"):
		var rifle: Sprite2D = parts["rifle"]
		rifle.visible = pose_name == "aim_fire"
		rifle.rotation = -(rifle.get_parent() as Node2D).global_rotation
	return true


func get_ground_anchor() -> Vector2:
	return global_position


func get_provisional_source_ground() -> Vector2:
	return SOURCE_GROUND
