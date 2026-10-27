@tool
class_name PolyRigInverseDistanceWeighting

const DEFAULT_FALLOFF_POWER := 4.0

## Computes IDW weights for each vertex against bone segments.
## segments: Array of {"head": Vector2, "tail": Vector2, "bi": int}
## points_world: world-space positions of each vertex.
## Returns Dictionary { bone_index: PackedFloat32Array of normalized weights }.
static func calculate(segments: Array, points_world: PackedVector2Array, falloff: float = DEFAULT_FALLOFF_POWER) -> Dictionary:
	var vc := points_world.size()
	var weights_data: Dictionary = {}
	for seg in segments:
		var arr := PackedFloat32Array()
		arr.resize(vc)
		weights_data[seg.bi] = arr

	for i in range(vc):
		var pos := points_world[i]
		var raw_per_bone: Dictionary = {}
		var total := 0.0

		for seg in segments:
			var closest := Geometry2D.get_closest_point_to_segment(pos, seg.head, seg.tail)
			var w := 1.0 / pow(pos.distance_to(closest) + 0.0001, falloff)
			raw_per_bone[seg.bi] = raw_per_bone.get(seg.bi, 0.0) + w
			total += w

		for bi in raw_per_bone:
			weights_data[bi][i] = raw_per_bone[bi] / total if total > 0 else 0.0

	PolyRigWeightManager.prune_weights(weights_data, vc)
	return weights_data
