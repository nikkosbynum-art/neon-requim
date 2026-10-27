extends SceneTree

const CHARACTERS := ["bulwark", "spark", "specter", "ironclad", "stitch", "recoil", "echo", "vector", "deadlock", "glitch"]
const EXPECTED_BONES := ["ground_root", "pelvis", "torso", "neck", "head", "near_shoulder", "near_elbow", "near_wrist", "near_hip", "near_knee", "near_ankle", "near_toe", "far_shoulder", "far_elbow", "far_wrist", "far_hip", "far_knee", "far_ankle", "far_toe"]
const POSES := ["neutral", "idle", "walk", "attack", "hit", "defeat"]

var failures := 0
var profile_count := 0
var mesh_count := 0
var vertex_count := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for character_id in CHARACTERS:
		var rig := FoundingT1ProfileMeshRigCandidate.new()
		root.add_child(rig)
		await process_frame
		_check(rig.build(character_id), "%s profile rig builds (%s)" % [character_id, rig.load_error])
		_check(rig.skeleton != null, "%s has Skeleton2D" % character_id)
		_check(rig.bones.size() == EXPECTED_BONES.size(), "%s exposes complete reusable bone blockout" % character_id)
		for bone_name in EXPECTED_BONES:
			_check(rig.bones.has(bone_name), "%s has bone %s" % [character_id, bone_name])
		_check(not rig.meshes.is_empty(), "%s has triangulated profile mesh contours" % character_id)
		for mesh in rig.meshes:
			mesh_count += 1
			vertex_count += mesh.polygon.size()
			_check(mesh.texture != null and mesh.texture.get_size() == rig.source_image_size, "%s mesh maps to the full profile texture" % character_id)
			_check(mesh.polygons.size() > 0, "%s mesh contour has triangles" % character_id)
			var mesh_coverage: float = float(mesh.get_meta("triangulated_area_px")) / float(mesh.get_meta("outline_area_px"))
			_check(mesh_coverage > 0.90 and mesh_coverage <= 1.05, "%s contour triangulation coverage %.3f" % [character_id, mesh_coverage])
			_check(mesh.get_bone_count() == rig.bones.size(), "%s mesh binds to all rig bones" % character_id)
			var bone_paths_resolve := mesh.skeleton == mesh.get_path_to(rig.skeleton)
			for bone_index in range(mesh.get_bone_count()):
				var bone_path := mesh.get_bone_path(bone_index)
				if rig.skeleton.get_node_or_null(bone_path) == null:
					bone_paths_resolve = false
			_check(bone_paths_resolve, "%s mesh bone paths resolve from its Skeleton2D" % character_id)
			var mesh_weights_normalized := true
			var first_bad_weight := ""
			for vertex_index in range(mesh.polygon.size()):
				var sum := 0.0
				for bone_index in range(mesh.get_bone_count()):
					var weights: PackedFloat32Array = mesh.get_bone_weights(bone_index)
					if vertex_index < weights.size():
						sum += weights[vertex_index]
				if absf(sum - 1.0) >= 0.01:
					mesh_weights_normalized = false
					if first_bad_weight.is_empty():
						first_bad_weight = "vertex=%d sum=%.4f point=%s" % [vertex_index, sum, str(mesh.polygon[vertex_index])]
			_check(mesh_weights_normalized, "%s mesh vertices have normalized bone weights %s" % [character_id, first_bad_weight])
		var anchor := rig.get_ground_anchor()
		for pose in POSES:
			_check(rig.set_pose(pose), "%s accepts %s pose" % [character_id, pose])
			_check(rig.get_ground_anchor().distance_to(anchor) < 0.001, "%s keeps ground root fixed in %s" % [character_id, pose])
		profile_count += 1
		rig.queue_free()
		await process_frame
	if failures == 0:
		print("PASS: %d founding Tier I visible-profile mesh-rig candidates; %d polygon contours; %d weighted vertices; six pose states and fixed root per recruit." % [profile_count, mesh_count, vertex_count])
		print("LIMIT: flattened visible-profile mesh only. Authored pivots, hidden/far-side art, semantic part swaps, character-specific animation quality, and production approval remain unverified.")
		quit(0)
	else:
		push_error("%d founding profile mesh-rig check(s) failed." % failures)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] " + message)
	else:
		failures += 1
		push_error("FOUNDING PROFILE RIG FAILED: " + message)
