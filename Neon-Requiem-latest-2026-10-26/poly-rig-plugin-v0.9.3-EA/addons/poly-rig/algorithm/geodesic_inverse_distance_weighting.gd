@tool
class_name PolyRigGeodesicPolyRigInverseDistanceWeighting

const DEFAULT_FALLOFF_POWER := 3.0

## Computes Geodesic IDW weights for each vertex against bone segments.
## Uses shortest paths along mesh edges instead of Euclidean distance,
## producing better weights at joints and concave regions.
## segments: Array of {"head": Vector2, "tail": Vector2, "bi": int}
## points_world: world-space positions of each vertex.
## triangles: Array of PackedInt32Array from polygon.polygons.
## Falls back to Euclidean IDW if no triangulation is available.
static func calculate(segments: Array, points_world: PackedVector2Array, triangles: Array, falloff: float = DEFAULT_FALLOFF_POWER) -> Dictionary:
	if triangles.is_empty():
		return PolyRigInverseDistanceWeighting.calculate(segments, points_world, falloff)

	var vc := points_world.size()
	if vc == 0: return {}

	# Build adjacency list from triangulation
	var adj := _build_adjacency(vc, points_world, triangles)

	# Group segments by bone index
	var bone_segs: Dictionary = {}
	for seg in segments:
		if not bone_segs.has(seg.bi):
			bone_segs[seg.bi] = []
		bone_segs[seg.bi].append(seg)

	# Init result arrays
	var weights_data: Dictionary = {}
	for bi in bone_segs:
		var arr := PackedFloat32Array()
		arr.resize(vc)
		weights_data[bi] = arr

	# Compute geodesic distances per bone
	var geo_dists: Dictionary = {}
	for bi in bone_segs:
		geo_dists[bi] = _geodesic_from_bone(points_world, adj, bone_segs[bi], triangles)

	# Compute normalized IDW weights using geodesic distances
	for i in range(vc):
		var total := 0.0
		var raw: Dictionary = {}
		for bi in bone_segs:
			var d: float = geo_dists[bi][i]
			var w := 1.0 / pow(d + 0.0001, falloff)
			raw[bi] = w
			total += w
		for bi in raw:
			weights_data[bi][i] = raw[bi] / total if total > 0.0 else 0.0

	PolyRigWeightManager.prune_weights(weights_data, vc)
	return weights_data

## Builds adjacency list from triangulation.
## Returns adj[v] = [[neighbor_index, edge_length], ...]
static func _build_adjacency(vc: int, points: PackedVector2Array, triangles: Array) -> Array:
	var adj: Array = []
	adj.resize(vc)
	for i in range(vc):
		adj[i] = []

	var seen: Dictionary = {}
	for tri in triangles:
		var n: int = tri.size()
		for j in range(n):
			var a: int = tri[j]
			var b: int = tri[(j + 1) % n]
			var key := Vector2i(mini(a, b), maxi(a, b))
			if not seen.has(key):
				seen[key] = true
				var d := points[a].distance_to(points[b])
				adj[a].append([b, d])
				adj[b].append([a, d])
	return adj

## Computes geodesic distances from a set of bone segments to all vertices.
## 1) Seeds vertices in triangles that intersect the bone with Euclidean distance.
## 2) Propagates shortest distances along mesh edges via Dijkstra.
static func _geodesic_from_bone(points: PackedVector2Array, adj: Array, segs: Array, triangles: Array) -> PackedFloat32Array:
	var vc := points.size()
	var dist := PackedFloat32Array()
	dist.resize(vc)
	for i in range(vc):
		dist[i] = INF

	# Seed: vertices of triangles that intersect any bone segment
	for tri in triangles:
		var tri_pts := PackedVector2Array()
		tri_pts.resize(tri.size())
		for j in range(tri.size()):
			tri_pts[j] = points[tri[j]]

		for seg in segs:
			if _segment_touches_triangle(seg.head, seg.tail, tri_pts):
				for j in range(tri.size()):
					var idx: int = tri[j]
					var closest := Geometry2D.get_closest_point_to_segment(points[idx], seg.head, seg.tail)
					dist[idx] = minf(dist[idx], points[idx].distance_to(closest))

	# Fallback: if no triangle was intersected, seed the nearest vertex per segment
	var any_seeded := false
	for i in range(vc):
		if dist[i] < INF:
			any_seeded = true
			break
	if not any_seeded:
		for seg in segs:
			var best_v := -1
			var best_d := INF
			for i in range(vc):
				var closest := Geometry2D.get_closest_point_to_segment(points[i], seg.head, seg.tail)
				var d := points[i].distance_to(closest)
				if d < best_d:
					best_d = d
					best_v = i
			if best_v >= 0:
				dist[best_v] = minf(dist[best_v], best_d)

	# Dijkstra — O(V^2) linear scan, fast enough for typical 2D mesh sizes
	var visited := PackedByteArray()
	visited.resize(vc)

	for _iter in range(vc):
		var u := -1
		var min_d: float = INF
		for v in range(vc):
			if visited[v] == 0 and dist[v] < min_d:
				min_d = dist[v]
				u = v
		if u == -1 or min_d == INF:
			break
		visited[u] = 1

		for edge in adj[u]:
			var n: int = edge[0]
			var elen: float = edge[1]
			if visited[n] == 1:
				continue
			var nd := dist[u] + elen
			if nd < dist[n]:
				dist[n] = nd

	return dist

## Checks if a line segment intersects or lies within a triangle/polygon.
static func _segment_touches_triangle(seg_a: Vector2, seg_b: Vector2, tri: PackedVector2Array) -> bool:
	if Geometry2D.is_point_in_polygon(seg_a, tri):
		return true
	if Geometry2D.is_point_in_polygon(seg_b, tri):
		return true
	var n := tri.size()
	for i in range(n):
		if Geometry2D.segment_intersects_segment(seg_a, seg_b, tri[i], tri[(i + 1) % n]) != null:
			return true
	return false
