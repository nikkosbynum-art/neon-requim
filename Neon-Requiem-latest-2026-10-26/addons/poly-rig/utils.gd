@tool
class_name PolyRigUtils extends Node

# Reference diagonal for a 512x512 bounding box, used to scale pixel values proportionally.
const _REFERENCE_DIAGONAL := 724.0  # sqrt(512^2 + 512^2)

# --- Geometry ---

# Returns the bounding rect of a Polygon2D's points (with offset applied).
static func get_polygon_bounding_rect(poly_node: Polygon2D) -> Rect2:
	if not poly_node or poly_node.polygon.is_empty():
		return Rect2()
	var rect := get_points_bounding_rect(poly_node.polygon)
	rect.position += poly_node.offset
	return rect

# Returns the bounding rect of a PackedVector2Array.
static func get_points_bounding_rect(points: PackedVector2Array) -> Rect2:
	if points.is_empty(): return Rect2()
	var rect := Rect2(points[0], Vector2.ZERO)
	for p in points:
		rect = rect.expand(p)
	return rect

# Computes a fit-to-center transform matrix and uniform scale ratio.
static func calculate_transform(polygon: Polygon2D, dst_size: Vector2) -> Array:
	if not polygon: return [Transform2D.IDENTITY, 1.0]
	var src_rect := get_polygon_bounding_rect(polygon)
	var src_size := src_rect.size
	if src_size.x == 0 or src_size.y == 0: return [Transform2D.IDENTITY, 1.0]
	if dst_size.x == 0 or dst_size.y == 0: return [Transform2D.IDENTITY, 1.0]
	var ratio := minf(dst_size.x / src_size.x, dst_size.y / src_size.y)
	var offset := (dst_size - src_size * ratio) / 2.0 - src_rect.position * ratio
	return [Transform2D(Vector2(ratio, 0), Vector2(0, ratio), offset), ratio]

# Calculates the area of a polygon using the shoelace formula.
static func polygon_area(poly: PackedVector2Array) -> float:
	var area := 0.0
	var count := poly.size()
	for i in range(count):
		var p1 := poly[i]
		var p2 := poly[(i + 1) % count]
		area += p1.x * p2.y - p2.x * p1.y
	return absf(area) * 0.5

# Calculates the centroid of a polygon.
static func polygon_centroid(poly: PackedVector2Array) -> Vector2:
	var centroid := Vector2.ZERO
	var signed_area := 0.0
	var count := poly.size()
	for i in range(count):
		var p1 := poly[i]
		var p2 := poly[(i + 1) % count]
		var cross := p1.x * p2.y - p2.x * p1.y
		signed_area += cross
		centroid += (p1 + p2) * cross
	if is_zero_approx(signed_area):
		var avg := Vector2.ZERO
		for p in poly:
			avg += p
		return avg / count
	return centroid / (3.0 * signed_area)

# Scales a pixel value relative to a 512x512 reference size.
# e.g. scale_to_reference(20.0, points) returns 20.0 for a 512x512 shape,
# 40.0 for a 1024x1024 shape, 10.0 for a 256x256 shape.
static func scale_to_reference(value: float, points: PackedVector2Array) -> float:
	var diag := get_points_bounding_rect(points).size.length()
	if diag < 0.001: return value
	return value * diag / _REFERENCE_DIAGONAL

# Simplifies an outline by removing vertices closer than min_dist (in reference pixels).
static func simplify_outline(outline: PackedVector2Array, min_dist: float = 8.0) -> PackedVector2Array:
	if outline.is_empty(): return outline
	var threshold := scale_to_reference(min_dist, outline)
	var clean := PackedVector2Array()
	clean.append(outline[0])
	for i in range(1, outline.size()):
		if clean[-1].distance_to(outline[i]) >= threshold:
			clean.append(outline[i])
	if clean.size() > 2 and clean[-1].distance_to(clean[0]) < threshold:
		clean.remove_at(clean.size() - 1)
	return clean

# Converts points to local space by subtracting the top-left corner.
static func to_local_points(points: PackedVector2Array) -> PackedVector2Array:
	if points.is_empty(): return PackedVector2Array()
	var rect := get_points_bounding_rect(points)
	var top_left := rect.position
	var result := PackedVector2Array()
	result.resize(points.size())
	for i in range(points.size()):
		result[i] = points[i] - top_left
	return result

# --- Skeleton ---

# Finds the skeleton-relative NodePath for a Bone2D.
static func get_bone_path(bone: Bone2D) -> NodePath:
	var current: Node = bone
	while current:
		if current is Skeleton2D:
			return current.get_path_to(bone)
		current = current.get_parent()
	return NodePath()

# Computes a bone's global rest transform by walking up the parent chain.
static func get_bone_global_rest_transform(bone: Bone2D, skeleton: Skeleton2D) -> Transform2D:
	var xform := bone.rest
	var parent := bone.get_parent()
	while parent is Bone2D:
		xform = parent.rest * xform
		parent = parent.get_parent()
	if parent == skeleton:
		xform = skeleton.global_transform * xform
	return xform

static func has_child_bone(bone:Bone2D) -> bool:
	for child in bone.get_children():
		if child is Bone2D:
			return true
	return false

static func get_child_bones(bone: Bone2D) -> Array[Bone2D]:
	var children: Array[Bone2D] = []
	for child in bone.get_children():
		if child is Bone2D:
			children.append(child)
	return children

# Returns bone segments as [[head, tail], ...] in global rest space.
# Bones with children: one segment per child (head=bone origin, tail=child origin).
# Leaf bones: one segment using the bone's own length and angle.
static func get_bone_rest_segments(bone: Bone2D, skeleton: Skeleton2D) -> Array:
	var rest_xform := get_bone_global_rest_transform(bone, skeleton)
	var head := rest_xform.origin
	var children := get_child_bones(bone)
	var segments: Array = []
	if children.is_empty():
		var length := bone.get_length()
		var angle := bone.get_bone_angle()
		if length <= 0.1: length = 20.0
		var tail := rest_xform * (Vector2.RIGHT.rotated(angle) * length)
		segments.append([head, tail])
	else:
		for child in children:
			var child_xform := get_bone_global_rest_transform(child, skeleton)
			segments.append([head, child_xform.origin])
	return segments

# --- UI ---

# Shows a centered warning dialog.
static func show_warning(parent, message, title) -> void:
	if not parent: return
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	parent.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
