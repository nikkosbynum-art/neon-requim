extends Node2D

@export_enum("bulwark", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch")
var character_id := "bulwark"

var rig: FoundingT1ProfileMeshRigCandidate

func _ready() -> void:
	rig = FoundingT1ProfileMeshRigCandidate.new()
	rig.name = "QuarantinedProfileMeshRig"
	# The texture includes a 128 px transparent border. Center its full canvas in
	# the 1280×720 review viewport so the whole profile remains visible.
	rig.scale = Vector2.ONE * 0.38
	add_child(rig)
	if not rig.build(character_id):
		push_error("Could not build profile mesh rig candidate: " + rig.load_error)
		return
	rig.position = Vector2(640, 660) - rig.source_ground * rig.scale.x
	rig.set_pose("neutral")
