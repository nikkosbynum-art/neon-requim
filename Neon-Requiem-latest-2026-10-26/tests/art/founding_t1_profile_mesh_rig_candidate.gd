extends Node2D
class_name FoundingT1ProfileMeshRigCandidate

## PolyRig-compatible visible-profile mesh rig for approved Tier I references.
## This keeps the flattened source appearance intact at rest; it is a quarantined
## deformation experiment, not a modular production character.

const ROOT := "res://assets/characters/"
const LANDMARK_PADDING_DELTA := Vector2(64.0, 64.0)
const GRID_STEP := 42.0
const MIN_CONTOUR_AREA := 18.0

const DISPLAY_NAMES := {
	"bulwark": "BULWARK", "spark": "SPARK", "specter": "SPECTER", "ironclad": "IRONCLAD",
	"stitch": "STITCH", "recoil": "RECOIL", "echo": "ECHO", "vector": "VECTOR",
	"deadlock": "DEADLOCK", "glitch": "GLITCH",
}

const JOINTS := {
	"bulwark": {"root": [266, 1008], "pelvis": [264, 692], "torso": [265, 520], "neck": [280, 260], "head": [320, 150], "shoulder": [300, 365], "elbow": [325, 500], "wrist": [333, 610], "hip": [260, 700], "knee": [270, 850], "ankle": [260, 960], "toe": [320, 1000]},
	"spark": {"root": [220, 1012], "pelvis": [220, 690], "torso": [220, 495], "neck": [235, 265], "head": [280, 155], "shoulder": [245, 350], "elbow": [255, 485], "wrist": [260, 600], "hip": [215, 700], "knee": [230, 850], "ankle": [220, 960], "toe": [280, 1000]},
	"specter": {"root": [250, 1011], "pelvis": [245, 688], "torso": [245, 500], "neck": [260, 265], "head": [295, 150], "shoulder": [270, 350], "elbow": [290, 490], "wrist": [300, 605], "hip": [240, 700], "knee": [250, 850], "ankle": [245, 960], "toe": [300, 1000]},
	"ironclad": {"root": [250, 998], "pelvis": [245, 680], "torso": [245, 490], "neck": [250, 260], "head": [300, 145], "shoulder": [260, 350], "elbow": [285, 485], "wrist": [295, 600], "hip": [235, 690], "knee": [245, 845], "ankle": [245, 950], "toe": [300, 990]},
	"stitch": {"root": [245, 1028], "pelvis": [245, 700], "torso": [245, 505], "neck": [245, 265], "head": [290, 150], "shoulder": [265, 355], "elbow": [280, 500], "wrist": [290, 615], "hip": [235, 710], "knee": [245, 865], "ankle": [245, 980], "toe": [300, 1020]},
	"recoil": {"root": [240, 992], "pelvis": [235, 670], "torso": [235, 480], "neck": [240, 255], "head": [290, 145], "shoulder": [255, 345], "elbow": [260, 480], "wrist": [260, 600], "hip": [225, 680], "knee": [235, 835], "ankle": [230, 945], "toe": [290, 985]},
	"echo": {"root": [250, 1014], "pelvis": [250, 700], "torso": [250, 500], "neck": [255, 265], "head": [300, 150], "shoulder": [275, 350], "elbow": [285, 490], "wrist": [290, 610], "hip": [240, 710], "knee": [250, 855], "ankle": [245, 965], "toe": [300, 1005]},
	"vector": {"root": [210, 1015], "pelvis": [210, 700], "torso": [210, 500], "neck": [220, 270], "head": [255, 150], "shoulder": [225, 350], "elbow": [235, 490], "wrist": [240, 610], "hip": [205, 710], "knee": [210, 860], "ankle": [205, 970], "toe": [260, 1010]},
	"deadlock": {"root": [250, 1012], "pelvis": [245, 690], "torso": [245, 495], "neck": [255, 265], "head": [295, 145], "shoulder": [265, 350], "elbow": [285, 495], "wrist": [295, 615], "hip": [235, 700], "knee": [245, 855], "ankle": [245, 965], "toe": [300, 1005]},
	"glitch": {"root": [220, 1020], "pelvis": [220, 700], "torso": [220, 505], "neck": [225, 260], "head": [255, 145], "shoulder": [235, 350], "elbow": [245, 495], "wrist": [250, 610], "hip": [215, 710], "knee": [220, 865], "ankle": [220, 975], "toe": [270, 1015]},
}

var character_id := ""
var display_name := ""
var skeleton: Skeleton2D
var bones: Dictionary = {}
var meshes: Array[Polygon2D] = []
var source_image_size := Vector2.ZERO
var source_ground := Vector2.ZERO
var load_error := ""


func build(candidate_id: String) -> bool:
	character_id = candidate_id.to_lower()
	if not DISPLAY_NAMES.has(character_id) or not JOINTS.has(character_id):
		load_error = "Unknown founding character id: " + candidate_id
		return false
	display_name = DISPLAY_NAMES[character_id]
	var image_path := ROOT + character_id + "/tier_01_drafts/profile_mesh_rig_candidate_01/" + display_name + "_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png"
	var image := Image.new()
	var image_error := image.load(ProjectSettings.globalize_path(image_path))
	if image_error != OK:
		load_error = "Could not load profile texture: " + image_path
		return false
	source_image_size = Vector2(image.get_size())
	source_ground = _point(JOINTS[character_id], "root")
	texture = ImageTexture.create_from_image(image)
	_build_skeleton()
	_build_meshes(image)
	return not meshes.is_empty()


var texture: ImageTexture


func _make_bone(id: String, parent: Node, local_position: Vector2) -> Bone2D:
	var bone := Bone2D.new()
	bone.name = id
	bone.set_autocalculate_length_and_angle(false)
	bone.position = local_position
	bone.rest = bone.transform
	parent.add_child(bone)
	bones[id] = bone
	return bone


func _build_skeleton() -> void:
	skeleton = Skeleton2D.new()
	skeleton.name = display_name + "ProfileSkeleton"
	# Both the Skeleton2D origin and mesh node sit at the source ground landmark.
	# Bone rest points and mesh vertices are expressed relative to that origin.
	skeleton.position = source_ground
	add_child(skeleton)
	var points: Dictionary = JOINTS[character_id]
	var root_bone := _make_bone("ground_root", skeleton, Vector2.ZERO)
	var pelvis := _make_bone("pelvis", root_bone, _point(points, "pelvis") - source_ground)
	var torso := _make_bone("torso", pelvis, _point(points, "torso") - _point(points, "pelvis"))
	var neck := _make_bone("neck", torso, _point(points, "neck") - _point(points, "torso"))
	_make_bone("head", neck, _point(points, "head") - _point(points, "neck"))
	var shoulder := _make_bone("near_shoulder", torso, _point(points, "shoulder") - _point(points, "torso"))
	var elbow := _make_bone("near_elbow", shoulder, _point(points, "elbow") - _point(points, "shoulder"))
	_make_bone("near_wrist", elbow, _point(points, "wrist") - _point(points, "elbow"))
	var hip := _make_bone("near_hip", pelvis, _point(points, "hip") - _point(points, "pelvis"))
	var knee := _make_bone("near_knee", hip, _point(points, "knee") - _point(points, "hip"))
	var ankle := _make_bone("near_ankle", knee, _point(points, "ankle") - _point(points, "knee"))
	_make_bone("near_toe", ankle, _point(points, "toe") - _point(points, "ankle"))
	# The flattened reference shows only one side. Far-side bone chains are
	# blockout placeholders with no source art bound to them.
	var far_shoulder := _make_bone("far_shoulder", torso, _point(points, "shoulder") - _point(points, "torso") + Vector2(-18, 0))
	var far_elbow := _make_bone("far_elbow", far_shoulder, _point(points, "elbow") - _point(points, "shoulder"))
	_make_bone("far_wrist", far_elbow, _point(points, "wrist") - _point(points, "elbow"))
	var far_hip := _make_bone("far_hip", pelvis, _point(points, "hip") - _point(points, "pelvis") + Vector2(-15, 0))
	var far_knee := _make_bone("far_knee", far_hip, _point(points, "knee") - _point(points, "hip"))
	var far_ankle := _make_bone("far_ankle", far_knee, _point(points, "ankle") - _point(points, "knee"))
	_make_bone("far_toe", far_ankle, _point(points, "toe") - _point(points, "ankle"))
	# Capture the completed hierarchical rest pose, matching the established
	# Godot rig setup used elsewhere in the project.
	for bone_variant in bones.values():
		var bone := bone_variant as Bone2D
		bone.set_autocalculate_length_and_angle(false)
		bone.rest = bone.transform
		bone.set_length(maxf(bone.position.length(), 1.0))
		bone.set_bone_angle(bone.position.angle())


func _point(points: Dictionary, key: String) -> Vector2:
	var raw: Array = points[key]
	return Vector2(float(raw[0]), float(raw[1])) + LANDMARK_PADDING_DELTA


func _build_meshes(image: Image) -> void:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, 0.12)
	var contours: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, source_image_size), 5.0)
	var mesh_root := Node2D.new()
	mesh_root.name = "PolyRigMeshes"
	add_child(mesh_root)
	var contour_index := 0
	for outline in contours:
		var area := absf(_area(outline))
		if area < MIN_CONTOUR_AREA or outline.size() < 3:
			continue
		var source_points := outline.duplicate()
		source_points.append_array(_interior_points(outline))
		var points := _offset_points(source_points, -source_ground)
		var local_outline := _offset_points(outline, -source_ground)
		var triangles: Array = PolyRigDelaunay.triangulate_to_indices(points, local_outline)
		if triangles.is_empty():
			triangles = _fallback_triangulate(points, local_outline)
		if triangles.is_empty():
			continue
		var compacted := _compact_mesh(points, triangles)
		points = compacted.points
		triangles = compacted.triangles
		var polygon := Polygon2D.new()
		polygon.name = "ProfileContour_%02d" % contour_index
		polygon.texture = texture
		polygon.polygon = points
		polygon.uv = _offset_points(points, source_ground)
		polygon.polygons = triangles
		polygon.position = source_ground
		polygon.position = source_ground
		polygon.set_meta("outline_area_px", area)
		polygon.set_meta("triangulated_area_px", _triangle_area(points, triangles))
		mesh_root.add_child(polygon)
		polygon.skeleton = polygon.get_path_to(skeleton)
		var weights: Dictionary = PolyRigGeodesicPolyRigInverseDistanceWeighting.calculate(
			_get_bone_segments(), points, triangles
		)
		_normalize_weight_rows(weights, points, _get_bone_segments())
		for bone_index in range(skeleton.get_bone_count()):
			var bone := skeleton.get_bone(bone_index)
			var bone_weights: PackedFloat32Array = weights.get(bone_index, PackedFloat32Array())
			if bone_weights.is_empty():
				bone_weights.resize(points.size())
				bone_weights.fill(0.0)
			# Polygon2D bone paths are resolved relative to its Skeleton2D node,
			# matching PolyRigBoneManager.sync_bone().
			polygon.add_bone(skeleton.get_path_to(bone), bone_weights)
		meshes.append(polygon)
		contour_index += 1


func _fallback_triangulate(points: PackedVector2Array, outline: PackedVector2Array) -> Array:
	# Godot's Delaunay triangulation provides a fallback for contours PolyRig's
	# constrained triangulator rejects. Retain only triangles fully inside the
	# source contour so they cannot bridge concave cape/coat gaps.
	var raw := Geometry2D.triangulate_delaunay(points)
	var accepted: Array = []
	for i in range(0, raw.size() - 2, 3):
		var a := points[raw[i]]
		var b := points[raw[i + 1]]
		var c := points[raw[i + 2]]
		var samples := [(a + b + c) / 3.0, (a + b) * 0.5, (b + c) * 0.5, (c + a) * 0.5]
		var inside := true
		for sample in samples:
			if not Geometry2D.is_point_in_polygon(sample, outline):
				inside = false
				break
		if inside:
			accepted.append(PackedInt32Array([raw[i], raw[i + 1], raw[i + 2]]))
	return accepted


func _compact_mesh(points: PackedVector2Array, triangles: Array) -> Dictionary:
	var remap := {}
	var compact_points := PackedVector2Array()
	for triangle in triangles:
		for old_index in triangle:
			if not remap.has(old_index):
				remap[old_index] = compact_points.size()
				compact_points.append(points[old_index])
	var compact_triangles: Array = []
	for triangle in triangles:
		compact_triangles.append(PackedInt32Array([
			remap[triangle[0]], remap[triangle[1]], remap[triangle[2]]
		]))
	return {"points": compact_points, "triangles": compact_triangles}


func _normalize_weight_rows(weights: Dictionary, points: PackedVector2Array, segments: Array) -> void:
	# PolyRig's geodesic solver may leave disconnected contour islands with zero
	# influence. Assign only those rows to the nearest bone segment; preserve and
	# normalize the plugin's geodesic result everywhere else.
	for vertex_index in range(points.size()):
		var total := 0.0
		for bone_index in weights:
			var row: PackedFloat32Array = weights[bone_index]
			total += row[vertex_index]
		if total <= 0.000001:
			var nearest_index := -1
			var nearest_distance := INF
			for segment in segments:
				var closest := Geometry2D.get_closest_point_to_segment(points[vertex_index], segment.head, segment.tail)
				var distance := points[vertex_index].distance_squared_to(closest)
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_index = segment.bi
			for bone_index in weights:
				var row: PackedFloat32Array = weights[bone_index]
				row[vertex_index] = 1.0 if bone_index == nearest_index else 0.0
				weights[bone_index] = row
		else:
			for bone_index in weights:
				var row: PackedFloat32Array = weights[bone_index]
				row[vertex_index] /= total
				weights[bone_index] = row


func _get_bone_segments() -> Array:
	var points: Dictionary = JOINTS[character_id]
	var pairs := [
		["ground_root", "root", "pelvis"], ["pelvis", "pelvis", "torso"],
		["torso", "torso", "neck"], ["neck", "neck", "head"],
		["head", "head", "head"], ["near_shoulder", "shoulder", "elbow"],
		["near_elbow", "elbow", "wrist"], ["near_wrist", "wrist", "wrist"],
		["near_hip", "hip", "knee"], ["near_knee", "knee", "ankle"],
		["near_ankle", "ankle", "toe"], ["near_toe", "toe", "toe"],
	]
	var result := []
	for pair: Array in pairs:
		var bone: Bone2D = bones[pair[0]]
		result.append({
				"head": _point(points, pair[1]) - source_ground,
				"tail": _point(points, pair[2]) - source_ground,
			"bi": bone.get_index_in_skeleton(),
		})
	return result


func _interior_points(outline: PackedVector2Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	var bounds := Rect2(outline[0], Vector2.ZERO)
	for point in outline:
		bounds = bounds.expand(point)
	var y := bounds.position.y + GRID_STEP * 0.5
	while y < bounds.end.y:
		var x := bounds.position.x + GRID_STEP * 0.5
		while x < bounds.end.x:
			var candidate := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(candidate, outline):
				points.append(candidate)
			x += GRID_STEP
		y += GRID_STEP
	return points


func _area(points: PackedVector2Array) -> float:
	var area := 0.0
	for index in range(points.size()):
		area += points[index].cross(points[(index + 1) % points.size()])
	return area * 0.5


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	result.resize(points.size())
	for index in range(points.size()):
		result[index] = points[index] + offset
	return result


func _triangle_area(points: PackedVector2Array, triangles: Array) -> float:
	var total := 0.0
	for triangle in triangles:
		var a: Vector2 = points[triangle[0]]
		var b: Vector2 = points[triangle[1]]
		var c: Vector2 = points[triangle[2]]
		total += absf((b - a).cross(c - a)) * 0.5
	return total


func set_pose(pose_name: String) -> bool:
	if bones.is_empty():
		return false
	for bone: Bone2D in bones.values():
		bone.rotation = 0.0
	match pose_name:
		"neutral":
			pass
		"idle":
			bones["torso"].rotation = 0.012
			bones["neck"].rotation = -0.008
		"walk":
			bones["near_hip"].rotation = -0.14
			bones["near_knee"].rotation = 0.08
			bones["near_shoulder"].rotation = 0.14
			bones["far_hip"].rotation = 0.14
			bones["far_shoulder"].rotation = -0.10
		"attack":
			bones["near_shoulder"].rotation = -0.35
			bones["near_elbow"].rotation = -0.18
		"hit":
			bones["torso"].rotation = -0.06
			bones["neck"].rotation = 0.04
		"defeat":
			bones["torso"].rotation = 0.16
			bones["near_hip"].rotation = 0.18
			bones["far_hip"].rotation = -0.10
		_:
			return false
	return true


func get_ground_anchor() -> Vector2:
	return to_global(source_ground)
