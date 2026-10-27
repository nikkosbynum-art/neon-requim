@tool
extends EditorScript

## Test script for PolyRigDelaunay triangulation and Poisson disc sampling.
## Attach to a Node in a scene and run the scene, or call run_all_tests() from editor.

func _run() -> void:
	run_all_tests()


func run_all_tests() -> void:
	print("===== START ALGORITHM TESTS =====")
	
	# PolyRigDelaunay / CDT tests
	_test_triangle_circumcircle()
	_test_edge_equals()
	_test_basic_triangulation()
	_test_triangulation_point_count()
	_test_triangulate_constrained_preserves_edge()
	_test_triangulate_with_boundary()
	_test_remove_border_triangles()
	_test_voronoi_sites()
	_test_collinear_points_triangulation()
	_test_segments_properly_intersect()
	_test_point_on_segment()
	_test_cdt_split_constraint()
	
	# Robustness tests
	_test_collinear_circumcircle_guard()
	_test_set_rectangle_repeated()
	
	# Poisson disc sampling tests
	_test_poisson_circle_basic()
	_test_poisson_polygon_basic()
	_test_poisson_min_distance()
	_test_poisson_points_inside_circle()
	_test_poisson_points_inside_polygon()
	_test_poisson_seed_in_output()
	_test_poisson_invalid_start_point()
	
	# CDT optimization stress tests
	_test_cdt_adj_map_consistency()
	_test_cdt_all_constraints_present()
	_test_cdt_triangle_validity()
	_test_cdt_complex_polygon_stress()
	_test_cdt_with_collinear_internal_point()
	
	# IDW / Geodesic IDW tests
	_test_idw_weights_normalized()
	_test_idw_closest_bone_wins()
	_test_idw_on_bone_segment()
	_test_idw_equidistant()
	_test_geodesic_fallback_to_euclidean()
	_test_geodesic_weights_normalized()
	_test_geodesic_adjacency_build()
	_test_geodesic_segment_touches_triangle()
	_test_geodesic_concave_differs_from_euclidean()
	
	print("===== ALL TESTS FINISHED =====")


# ========== HELPERS ==========

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("  [PASS] ", message)
	else:
		push_error("[FAIL] " + message)
		print("  [FAIL] ", message)


func _assert_approx(a: float, b: float, message: String, epsilon: float = 0.01) -> void:
	_assert(abs(a - b) < epsilon, message + " (got %.4f, expected %.4f)" % [a, b])


# ========== DELAUNAY TESTS ==========

func _test_triangle_circumcircle() -> void:
	print("[Test] Triangle circumcircle")
	# Right triangle at origin: (0,0), (4,0), (0,3) => circumcenter at (2, 1.5), radius = 2.5
	var tri := PolyRigDelaunay.Triangle.new(Vector2(0, 0), Vector2(4, 0), Vector2(0, 3))
	_assert_approx(tri.center.x, 2.0, "circumcenter x")
	_assert_approx(tri.center.y, 1.5, "circumcenter y")
	_assert_approx(sqrt(tri.radius_sqr), 2.5, "circumradius")
	
	# Point inside circumcircle
	_assert(tri.is_point_inside_circumcircle(Vector2(2, 1)), "point (2,1) inside circumcircle")
	# Point outside circumcircle
	_assert(not tri.is_point_inside_circumcircle(Vector2(10, 10)), "point (10,10) outside circumcircle")
	# Corner should NOT be considered inside
	_assert(not tri.is_point_inside_circumcircle(Vector2(0, 0)), "corner not inside circumcircle")


func _test_edge_equals() -> void:
	print("[Test] Edge equals")
	var e1 := PolyRigDelaunay.Edge.new(Vector2(0, 0), Vector2(1, 1))
	var e2 := PolyRigDelaunay.Edge.new(Vector2(1, 1), Vector2(0, 0))
	var e3 := PolyRigDelaunay.Edge.new(Vector2(0, 0), Vector2(2, 2))
	_assert(e1.equals(e2), "reversed edge equals")
	_assert(not e1.equals(e3), "different edge not equals")
	_assert_approx(e1.length(), sqrt(2), "edge length")
	_assert(e1.center() == Vector2(0.5, 0.5), "edge center")


func _test_basic_triangulation() -> void:
	print("[Test] Basic triangulation")
	var d := PolyRigDelaunay.new()
	# Simple square
	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)
	])
	for p in pts:
		d.add_point(p)
	var triangulation := d.triangulate()
	d.remove_border_triangles(triangulation)
	
	# 4 points in a square => 2 triangles
	_assert(triangulation.size() == 2, "square produces 2 triangles (got %d)" % triangulation.size())
	
	# All triangle vertices should be from our point set
	for tri in triangulation:
		_assert(pts.has(tri.a) and pts.has(tri.b) and pts.has(tri.c),
			"triangle vertices are from input points")


func _test_triangulation_point_count() -> void:
	print("[Test] Triangulation with more points")
	var d := PolyRigDelaunay.new()
	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(5, 0), Vector2(10, 0),
		Vector2(0, 5), Vector2(5, 5), Vector2(10, 5),
		Vector2(0, 10), Vector2(5, 10), Vector2(10, 10),
	])
	for p in pts:
		d.add_point(p)
	var triangulation := d.triangulate()
	d.remove_border_triangles(triangulation)
	
	# 9 points in a 3x3 grid => should produce 8 triangles (each of 4 sub-squares splits into 2)
	_assert(triangulation.size() >= 8, "3x3 grid produces >= 8 triangles (got %d)" % triangulation.size())
	
	# Each triangle should cover non-zero area
	for tri in triangulation:
		var area: float = abs((tri.b - tri.a).cross(tri.c - tri.a)) * 0.5
		_assert(area > 0.0, "triangle has non-zero area")


func _test_triangulate_constrained_preserves_edge() -> void:
	print("[Test] CDT preserves constraint edge")
	# Sub-test A: force diagonal on a simple square (no intermediate vertices)
	var d := PolyRigDelaunay.new()
	var pts_a := PackedVector2Array([
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)
	])
	for p in pts_a:
		d.add_point(p)
	var constraint_a := PolyRigDelaunay.Edge.new(Vector2(0, 0), Vector2(10, 10))
	var constraints_a: Array[PolyRigDelaunay.Edge] = [constraint_a]
	var tri_a := d.triangulate_constrained(constraints_a)
	d.remove_border_triangles(tri_a)
	var found_a := false
	for tri in tri_a:
		if tri.edge_ab.equals(constraint_a) or tri.edge_bc.equals(constraint_a) or tri.edge_ca.equals(constraint_a):
			found_a = true
			break
	_assert(found_a, "constraint edge (0,0)-(10,10) present in triangulation")
	
	# Sub-test B: constraint through intermediate vertex (5,5) -> split into sub-edges
	var pts_b := PackedVector2Array([
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10), Vector2(5, 5)
	])
	var d2 := PolyRigDelaunay.new()
	for p in pts_b:
		d2.add_point(p)
	var constraint_b := PolyRigDelaunay.Edge.new(Vector2(0, 0), Vector2(10, 10))
	var sub_edges := d2._cdt_split_constraint(constraint_b)
	_assert(sub_edges.size() == 2, "constraint (0,0)-(10,10) split into 2 sub-edges at (5,5) (got %d)" % sub_edges.size())
	if sub_edges.size() == 2:
		var constraints_b: Array[PolyRigDelaunay.Edge] = [constraint_b]
		var tri_b := d2.triangulate_constrained(constraints_b)
		d2.remove_border_triangles(tri_b)
		var found_sub0 := false
		var found_sub1 := false
		for tri in tri_b:
			for edge in [tri.edge_ab, tri.edge_bc, tri.edge_ca]:
				if edge.equals(sub_edges[0]): found_sub0 = true
				if edge.equals(sub_edges[1]): found_sub1 = true
		_assert(found_sub0 and found_sub1, "both sub-edges present in triangulation")


func _test_triangulate_with_boundary() -> void:
	print("[Test] Triangulate with boundary")
	var d := PolyRigDelaunay.new()
	# Add an interior point
	d.add_point(Vector2(5, 5))
	
	# L-shaped boundary
	var boundary := PackedVector2Array([
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 5),
		Vector2(5, 5), Vector2(5, 10), Vector2(0, 10)
	])
	
	var triangulation := d.triangulate_with_boundary(boundary)
	
	_assert(triangulation.size() > 0, "boundary triangulation produces triangles (got %d)" % triangulation.size())
	
	# All triangle centroids should be inside or on the boundary
	for tri in triangulation:
		var centroid := (tri.a + tri.b + tri.c) / 3.0
		var inside := Geometry2D.is_point_in_polygon(centroid, boundary)
		_assert(inside, "triangle centroid inside boundary (centroid=%s)" % str(centroid))


func _test_remove_border_triangles() -> void:
	print("[Test] Remove border triangles")
	var d := PolyRigDelaunay.new()
	var pts := PackedVector2Array([Vector2(1, 1), Vector2(5, 1), Vector2(3, 5)])
	for p in pts:
		d.add_point(p)
	var triangulation := d.triangulate()
	var total := triangulation.size()
	d.remove_border_triangles(triangulation)
	_assert(triangulation.size() < total, "border triangles removed (%d -> %d)" % [total, triangulation.size()])
	_assert(triangulation.size() == 1, "single triangle remains (got %d)" % triangulation.size())


func _test_voronoi_sites() -> void:
	print("[Test] Voronoi sites")
	var d := PolyRigDelaunay.new()
	# 5 points with a center point - should produce at least 1 complete Voronoi cell
	var pts := PackedVector2Array([
		Vector2(5, 5),
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)
	])
	for p in pts:
		d.add_point(p)
	var triangulation := d.triangulate()
	var sites := d.make_voronoi(triangulation)
	
	_assert(sites.size() > 0, "voronoi produces sites (got %d)" % sites.size())
	
	# Each site should have a polygon
	for site in sites:
		_assert(site.polygon.size() >= 3, "site polygon has >= 3 vertices (got %d)" % site.polygon.size())


func _test_collinear_points_triangulation() -> void:
	print("[Test] Collinear points triangulation")
	var d := PolyRigDelaunay.new()
	# 3 collinear + 1 off-line point
	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(5, 0), Vector2(10, 0), Vector2(5, 5)
	])
	for p in pts:
		d.add_point(p)
	var triangulation := d.triangulate()
	d.remove_border_triangles(triangulation)
	# Should still produce valid triangles
	_assert(triangulation.size() >= 2, "collinear + offset point produces triangles (got %d)" % triangulation.size())


func _test_segments_properly_intersect() -> void:
	print("[Test] Segments properly intersect")
	# Crossing segments
	_assert(
		PolyRigDelaunay._segments_properly_intersect(Vector2(0,0), Vector2(10,10), Vector2(10,0), Vector2(0,10)),
		"crossing diagonals intersect"
	)
	# Shared endpoint should NOT count
	_assert(
		not PolyRigDelaunay._segments_properly_intersect(Vector2(0,0), Vector2(5,5), Vector2(5,5), Vector2(10,0)),
		"shared endpoint not a proper intersection"
	)
	# Parallel segments
	_assert(
		not PolyRigDelaunay._segments_properly_intersect(Vector2(0,0), Vector2(10,0), Vector2(0,1), Vector2(10,1)),
		"parallel segments don't intersect"
	)
	# Non-crossing segments
	_assert(
		not PolyRigDelaunay._segments_properly_intersect(Vector2(0,0), Vector2(1,0), Vector2(5,5), Vector2(6,5)),
		"distant segments don't intersect"
	)


func _test_point_on_segment() -> void:
	print("[Test] Point on segment")
	_assert(
		PolyRigDelaunay._point_on_segment(Vector2(5, 0), Vector2(0, 0), Vector2(10, 0)),
		"midpoint on horizontal segment"
	)
	_assert(
		not PolyRigDelaunay._point_on_segment(Vector2(0, 0), Vector2(0, 0), Vector2(10, 0)),
		"endpoint not strictly on segment"
	)
	_assert(
		not PolyRigDelaunay._point_on_segment(Vector2(5, 1), Vector2(0, 0), Vector2(10, 0)),
		"off-segment point"
	)


func _test_cdt_split_constraint() -> void:
	print("[Test] CDT split constraint at collinear vertices")
	var d := PolyRigDelaunay.new()
	d.add_point(Vector2(0, 0))
	d.add_point(Vector2(5, 0))
	d.add_point(Vector2(10, 0))
	
	var edge := PolyRigDelaunay.Edge.new(Vector2(0, 0), Vector2(10, 0))
	var splits := d._cdt_split_constraint(edge)
	_assert(splits.size() == 2, "edge split into 2 sub-edges (got %d)" % splits.size())
	if splits.size() == 2:
		_assert(splits[0].a == Vector2(0, 0) and splits[0].b == Vector2(5, 0), "first sub-edge correct")
		_assert(splits[1].a == Vector2(5, 0) and splits[1].b == Vector2(10, 0), "second sub-edge correct")


# ========== POISSON DISC SAMPLING TESTS ==========

func _test_poisson_circle_basic() -> void:
	print("[Test] Poisson circle basic")
	var points := PolyRigPoissonDiscSampling.generate_points_for_circle(
		Vector2(50, 50), 40.0, 8.0, 30
	)
	_assert(points.size() > 0, "circle sampling produces points (got %d)" % points.size())


func _test_poisson_polygon_basic() -> void:
	print("[Test] Poisson polygon basic")
	var polygon := PackedVector2Array([
		Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)
	])
	var points := PolyRigPoissonDiscSampling.generate_points_for_polygon(
		polygon, 10.0, 30
	)
	_assert(points.size() > 0, "polygon sampling produces points (got %d)" % points.size())


func _test_poisson_min_distance() -> void:
	print("[Test] Poisson minimum distance guarantee")
	var poisson_radius := 10.0
	var points := PolyRigPoissonDiscSampling.generate_points_for_circle(
		Vector2(50, 50), 40.0, poisson_radius, 30
	)
	var violation := false
	for i in range(points.size()):
		for j in range(i + 1, points.size()):
			if points[i].distance_to(points[j]) < poisson_radius - 0.01:
				violation = true
				break
		if violation:
			break
	_assert(not violation, "no two points closer than poisson_radius (%.1f)" % poisson_radius)


func _test_poisson_points_inside_circle() -> void:
	print("[Test] Poisson points inside circle")
	var center := Vector2(50, 50)
	var radius := 40.0
	var points := PolyRigPoissonDiscSampling.generate_points_for_circle(center, radius, 8.0, 30)
	var all_inside := true
	for p in points:
		if p.distance_to(center) > radius + 0.01:
			all_inside = false
			break
	_assert(all_inside, "all points within circle radius")


func _test_poisson_points_inside_polygon() -> void:
	print("[Test] Poisson points inside polygon")
	var polygon := PackedVector2Array([
		Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)
	])
	var points := PolyRigPoissonDiscSampling.generate_points_for_polygon(polygon, 10.0, 30)
	var all_inside := true
	for p in points:
		if not Geometry2D.is_point_in_polygon(p, polygon):
			all_inside = false
			break
	_assert(all_inside, "all points inside polygon")


func _test_poisson_seed_in_output() -> void:
	print("[Test] Poisson seed point in output")
	var start := Vector2(50, 50)
	var points := PolyRigPoissonDiscSampling.generate_points_for_circle(
		Vector2(50, 50), 40.0, 8.0, 30, start
	)
	_assert(points.size() > 0, "produces points")
	_assert(points[0] == start, "seed point is first output point (got %s)" % str(points[0]))


func _test_collinear_circumcircle_guard() -> void:
	print("[Test] Collinear triangle circumcircle guard")
	# 3 collinear points should not crash (division by zero)
	var tri := PolyRigDelaunay.Triangle.new(Vector2(0, 0), Vector2(5, 0), Vector2(10, 0))
	_assert(tri.radius_sqr == INF, "collinear triangle has INF radius_sqr")
	# Any point should be considered inside (INF radius)
	_assert(tri.is_point_inside_circumcircle(Vector2(5, 5)), "point inside degenerate circumcircle")


func _test_set_rectangle_repeated() -> void:
	print("[Test] set_rectangle repeated call")
	var d := PolyRigDelaunay.new()
	d.set_rectangle(Rect2(0, 0, 100, 100))
	d.set_rectangle(Rect2(0, 0, 200, 200))
	_assert(d._rect_super_corners.size() == 4, "corners not accumulated (got %d)" % d._rect_super_corners.size())


func _test_poisson_invalid_start_point() -> void:
	# NOTE: This test intentionally triggers a push_error() — the ERROR in the console is expected.
	print("[Test] Poisson invalid start point (expect one ERROR below — this is intentional)")
	var points := PolyRigPoissonDiscSampling.generate_points_for_circle(
		Vector2(50, 50), 40.0, 8.0, 30, Vector2(999, 999)
	)
	_assert(points.size() == 0, "invalid start point returns empty array")


# ========== CDT OPTIMIZATION STRESS TESTS ==========

# Helper: build edge->triangle count map and verify consistency
func _verify_adj_map(triangulation: Array[PolyRigDelaunay.Triangle], label: String) -> bool:
	var edge_count: Dictionary = {}  # edge_key -> int (triangle count)
	for tri in triangulation:
		for edge in [tri.edge_ab, tri.edge_bc, tri.edge_ca]:
			var key := PolyRigDelaunay._edge_key(edge)
			edge_count[key] = edge_count.get(key, 0) + 1
	var ok := true
	for key in edge_count:
		if edge_count[key] > 2:
			print("  [DIAG:%s] edge %s shared by %d triangles (max should be 2)" % [label, key, edge_count[key]])
			ok = false
	return ok


# Helper: check all constraint edges exist in triangulation
func _verify_constraints_present(triangulation: Array[PolyRigDelaunay.Triangle], constraints: Array[PolyRigDelaunay.Edge], label: String) -> bool:
	var tri_edges: Dictionary = {}
	for tri in triangulation:
		for edge in [tri.edge_ab, tri.edge_bc, tri.edge_ca]:
			tri_edges[PolyRigDelaunay._edge_key(edge)] = true
	var ok := true
	for c in constraints:
		var key := PolyRigDelaunay._edge_key(c)
		if not tri_edges.has(key):
			print("  [DIAG:%s] MISSING constraint edge %s" % [label, key])
			ok = false
	return ok


# Helper: check all triangle centroids are inside boundary
func _verify_centroids_inside(triangulation: Array[PolyRigDelaunay.Triangle], boundary: PackedVector2Array, label: String) -> bool:
	var ok := true
	var outside_count := 0
	for tri in triangulation:
		var centroid := (tri.a + tri.b + tri.c) / 3.0
		if not Geometry2D.is_point_in_polygon(centroid, boundary):
			outside_count += 1
			ok = false
	if outside_count > 0:
		print("  [DIAG:%s] %d/%d triangles have centroid outside boundary" % [label, outside_count, triangulation.size()])
	return ok


func _test_cdt_adj_map_consistency() -> void:
	print("[Test] CDT adj_map consistency")
	# Simple square + center point
	var d := PolyRigDelaunay.new()
	var boundary := PackedVector2Array([Vector2(0,0), Vector2(100,0), Vector2(100,100), Vector2(0,100)])
	for p in boundary: d.add_point(p)
	d.add_point(Vector2(50, 50))
	var tris := d.triangulate_with_boundary(boundary)
	_assert(tris.size() > 0, "produces triangles (got %d)" % tris.size())
	_assert(_verify_adj_map(tris, "square+center"), "no edge shared by >2 triangles")


func _test_cdt_all_constraints_present() -> void:
	print("[Test] CDT all constraints present after insertion")
	# L-shaped boundary with interior point
	var d := PolyRigDelaunay.new()
	var boundary := PackedVector2Array([
		Vector2(0,0), Vector2(60,0), Vector2(60,40),
		Vector2(30,40), Vector2(30,80), Vector2(0,80)
	])
	for p in boundary: d.add_point(p)
	d.add_point(Vector2(15, 20))
	d.add_point(Vector2(45, 20))
	
	var constraints: Array[PolyRigDelaunay.Edge] = []
	for i in range(boundary.size()):
		constraints.append(PolyRigDelaunay.Edge.new(boundary[i], boundary[(i + 1) % boundary.size()]))
	
	# Get split constraints (what actually exists in triangulation)
	var split: Array[PolyRigDelaunay.Edge] = []
	for c in constraints:
		split.append_array(d._cdt_split_constraint(c))
	
	var tris := d.triangulate_with_boundary(boundary)
	_assert(tris.size() > 0, "L-shape produces triangles (got %d)" % tris.size())
	_assert(_verify_constraints_present(tris, split, "L-shape"), "all split constraints present")
	_assert(_verify_centroids_inside(tris, boundary, "L-shape"), "all centroids inside boundary")


func _test_cdt_triangle_validity() -> void:
	print("[Test] CDT triangle validity (no degenerate triangles)")
	var d := PolyRigDelaunay.new()
	var boundary := PackedVector2Array([
		Vector2(0,0), Vector2(80,0), Vector2(80,60), Vector2(0,60)
	])
	for p in boundary: d.add_point(p)
	# Add grid of internal points
	for x in range(20, 80, 20):
		for y in range(20, 60, 20):
			d.add_point(Vector2(x, y))
	var tris := d.triangulate_with_boundary(boundary)
	_assert(tris.size() > 0, "grid produces triangles (got %d)" % tris.size())
	var degenerate := 0
	for tri in tris:
		var area :float = abs((tri.b - tri.a).cross(tri.c - tri.a)) * 0.5
		if area < 0.001:
			degenerate += 1
	_assert(degenerate == 0, "no degenerate triangles (got %d)" % degenerate)
	_assert(_verify_adj_map(tris, "grid"), "adj consistency")


func _test_cdt_complex_polygon_stress() -> void:
	print("[Test] CDT complex polygon stress (star shape x10 runs)")
	# Star-shaped polygon (concave)
	var boundary := PackedVector2Array()
	for i in range(10):
		var angle := i * PI / 5.0
		var r := 100.0 if i % 2 == 0 else 40.0
		boundary.append(Vector2(150 + cos(angle) * r, 150 + sin(angle) * r))
	
	var fail_count := 0
	var total_tris := 0
	for run in range(10):
		var d := PolyRigDelaunay.new()
		for p in boundary: d.add_point(p)
		# Add random internal points
		var internal_pts := PolyRigPoissonDiscSampling.generate_points_for_polygon(boundary, 20.0, 30)
		for p in internal_pts: d.add_point(p)
		var tris := d.triangulate_with_boundary(boundary)
		if tris.size() == 0:
			fail_count += 1
			print("  [FAIL] run #%d: 0 triangles! (internal_pts=%d)" % [run, internal_pts.size()])
		else:
			total_tris += tris.size()
			if not _verify_centroids_inside(tris, boundary, "star#%d" % run):
				fail_count += 1
	_assert(fail_count == 0, "all 10 star runs produced valid triangulations (fails=%d, avg_tris=%d)" % [fail_count, total_tris / max(10 - fail_count, 1)])


func _test_cdt_with_collinear_internal_point() -> void:
	print("[Test] CDT with internal point ON boundary edge (split constraint scenario)")
	# Square boundary, with a point exactly on one edge
	var boundary := PackedVector2Array([
		Vector2(0,0), Vector2(100,0), Vector2(100,100), Vector2(0,100)
	])
	var d := PolyRigDelaunay.new()
	for p in boundary: d.add_point(p)
	# This point is exactly on the edge (0,0)-(100,0)
	d.add_point(Vector2(50, 0))
	# This point is inside
	d.add_point(Vector2(50, 50))
	
	var tris := d.triangulate_with_boundary(boundary)
	_assert(tris.size() > 0, "produces triangles with collinear point (got %d)" % tris.size())
	_assert(_verify_centroids_inside(tris, boundary, "collinear"), "all centroids inside")
	_assert(_verify_adj_map(tris, "collinear"), "adj consistency")
	
	# Verify the split happened: edge (0,0)-(100,0) should be split into (0,0)-(50,0) and (50,0)-(100,0)
	var constraints: Array[PolyRigDelaunay.Edge] = []
	for i in range(boundary.size()):
		constraints.append(PolyRigDelaunay.Edge.new(boundary[i], boundary[(i + 1) % boundary.size()]))
	var split: Array[PolyRigDelaunay.Edge] = []
	for c in constraints:
		split.append_array(d._cdt_split_constraint(c))
	var split_count := split.size() - constraints.size()
	print("  [INFO] original constraints=%d, split constraints=%d (splits=%d)" % [constraints.size(), split.size(), split_count])
	_assert(split.size() > constraints.size(), "constraint was split at collinear point (split=%d, orig=%d)" % [split.size(), constraints.size()])
	_assert(_verify_constraints_present(tris, split, "collinear-split"), "all split constraints present")


# ========== IDW TESTS ==========

# Helper: make a bone segment dict
func _seg(head: Vector2, tail: Vector2, bi: int) -> Dictionary:
	return {"head": head, "tail": tail, "bi": bi}


func _test_idw_weights_normalized() -> void:
	print("[Test] IDW weights normalized to 1.0")
	var segs := [_seg(Vector2(0,0), Vector2(0,50), 0), _seg(Vector2(100,0), Vector2(100,50), 1)]
	var pts := PackedVector2Array([Vector2(30,25), Vector2(70,25), Vector2(50,25)])
	var result := PolyRigInverseDistanceWeighting.calculate(segs, pts)
	var ok := true
	for i in range(pts.size()):
		var sum := 0.0
		for bi in result:
			sum += result[bi][i]
		if abs(sum - 1.0) > 0.01:
			print("  [DIAG] vertex %d weight sum=%.4f" % [i, sum])
			ok = false
	_assert(ok, "all vertex weights sum to ~1.0")


func _test_idw_closest_bone_wins() -> void:
	print("[Test] IDW closest bone gets highest weight")
	var segs := [_seg(Vector2(0,0), Vector2(0,50), 0), _seg(Vector2(100,0), Vector2(100,50), 1)]
	# Point at (10,25) is much closer to bone 0
	var pts := PackedVector2Array([Vector2(10, 25)])
	var result := PolyRigInverseDistanceWeighting.calculate(segs, pts)
	_assert(result[0][0] > result[1][0], "bone 0 weight (%.3f) > bone 1 weight (%.3f)" % [result[0][0], result[1][0]])
	_assert(result[0][0] > 0.9, "bone 0 weight > 0.9 (got %.3f)" % result[0][0])


func _test_idw_on_bone_segment() -> void:
	print("[Test] IDW vertex on bone segment gets ~1.0 weight")
	var segs := [_seg(Vector2(0,0), Vector2(0,50), 0), _seg(Vector2(100,0), Vector2(100,50), 1)]
	# Point exactly on bone 0
	var pts := PackedVector2Array([Vector2(0, 25)])
	var result := PolyRigInverseDistanceWeighting.calculate(segs, pts)
	_assert(result[0][0] > 0.99, "on-bone weight ~1.0 (got %.4f)" % result[0][0])


func _test_idw_equidistant() -> void:
	print("[Test] IDW equidistant vertex gets equal weights")
	var segs := [_seg(Vector2(0,25), Vector2(0,25), 0), _seg(Vector2(100,25), Vector2(100,25), 1)]
	# Point exactly in the middle
	var pts := PackedVector2Array([Vector2(50, 25)])
	var result := PolyRigInverseDistanceWeighting.calculate(segs, pts)
	_assert(abs(result[0][0] - result[1][0]) < 0.01, "equal weights (bone0=%.3f, bone1=%.3f)" % [result[0][0], result[1][0]])


# ========== GEODESIC IDW TESTS ==========

func _test_geodesic_fallback_to_euclidean() -> void:
	print("[Test] Geodesic IDW falls back to Euclidean when no triangles")
	var segs := [_seg(Vector2(0,0), Vector2(0,50), 0), _seg(Vector2(100,0), Vector2(100,50), 1)]
	var pts := PackedVector2Array([Vector2(30,25)])
	var geo := PolyRigGeodesicPolyRigInverseDistanceWeighting.calculate(segs, pts, [])
	var euc := PolyRigInverseDistanceWeighting.calculate(segs, pts)
	_assert(abs(geo[0][0] - euc[0][0]) < 0.001, "geodesic == euclidean when no triangles (geo=%.4f, euc=%.4f)" % [geo[0][0], euc[0][0]])


func _test_geodesic_weights_normalized() -> void:
	print("[Test] Geodesic IDW weights normalized")
	# Square mesh: 4 corners + center, 4 triangles
	var pts := PackedVector2Array([
		Vector2(0,0), Vector2(100,0), Vector2(100,100), Vector2(0,100), Vector2(50,50)
	])
	var tris: Array = [
		PackedInt32Array([0,1,4]), PackedInt32Array([1,2,4]),
		PackedInt32Array([2,3,4]), PackedInt32Array([3,0,4])
	]
	var segs := [_seg(Vector2(0,50), Vector2(0,50), 0), _seg(Vector2(100,50), Vector2(100,50), 1)]
	var result := PolyRigGeodesicPolyRigInverseDistanceWeighting.calculate(segs, pts, tris)
	var ok := true
	for i in range(pts.size()):
		var sum := 0.0
		for bi in result:
			sum += result[bi][i]
		if abs(sum - 1.0) > 0.01:
			print("  [DIAG] vertex %d weight sum=%.4f" % [i, sum])
			ok = false
	_assert(ok, "all vertex weights sum to ~1.0")


func _test_geodesic_adjacency_build() -> void:
	print("[Test] Geodesic adjacency build")
	# Single triangle: 3 vertices, 3 edges
	var pts := PackedVector2Array([Vector2(0,0), Vector2(10,0), Vector2(5,10)])
	var tris: Array = [PackedInt32Array([0,1,2])]
	var adj := PolyRigGeodesicPolyRigInverseDistanceWeighting._build_adjacency(3, pts, tris)
	_assert(adj.size() == 3, "3 adjacency lists")
	_assert(adj[0].size() == 2, "vertex 0 has 2 neighbors (got %d)" % adj[0].size())
	_assert(adj[1].size() == 2, "vertex 1 has 2 neighbors (got %d)" % adj[1].size())
	_assert(adj[2].size() == 2, "vertex 2 has 2 neighbors (got %d)" % adj[2].size())
	# Check edge length v0-v1 = 10
	var found_len := false
	for edge in adj[0]:
		if edge[0] == 1:
			_assert_approx(edge[1], 10.0, "edge 0-1 length")
			found_len = true
	_assert(found_len, "edge 0-1 found in adjacency")


func _test_geodesic_segment_touches_triangle() -> void:
	print("[Test] Geodesic segment touches triangle")
	var tri := PackedVector2Array([Vector2(0,0), Vector2(10,0), Vector2(5,10)])
	# Segment inside triangle
	_assert(
		PolyRigGeodesicPolyRigInverseDistanceWeighting._segment_touches_triangle(Vector2(5,3), Vector2(5,5), tri),
		"segment inside triangle"
	)
	# Segment crossing triangle edge
	_assert(
		PolyRigGeodesicPolyRigInverseDistanceWeighting._segment_touches_triangle(Vector2(-5,5), Vector2(10,5), tri),
		"segment crossing edge"
	)
	# Segment completely outside
	_assert(
		not PolyRigGeodesicPolyRigInverseDistanceWeighting._segment_touches_triangle(Vector2(20,20), Vector2(30,30), tri),
		"segment outside triangle"
	)


func _test_geodesic_concave_differs_from_euclidean() -> void:
	print("[Test] Geodesic differs from Euclidean on L-shaped mesh")
	# L-shaped mesh: bone on left arm, vertex on bottom arm
	# Geodesic path must go around the corner, Euclidean goes straight
	#
	#  0---1---2
	#  |       |
	#  3---4   5
	#      |   |
	#      6---7
	#
	var pts := PackedVector2Array([
		Vector2(0,0), Vector2(50,0), Vector2(100,0),    # 0,1,2
		Vector2(0,50), Vector2(50,50), Vector2(100,50), # 3,4,5
		Vector2(50,100), Vector2(100,100)                # 6,7
	])
	var tris: Array = [
		PackedInt32Array([0,1,3]), PackedInt32Array([1,4,3]),  # top-left
		PackedInt32Array([1,2,4]), PackedInt32Array([2,5,4]),  # top-right
		PackedInt32Array([4,5,6]), PackedInt32Array([5,7,6]),  # bottom-right
	]
	# Bone 0 at top-left, Bone 1 at bottom-right
	var segs := [_seg(Vector2(0,25), Vector2(0,25), 0), _seg(Vector2(100,100), Vector2(100,100), 1)]
	
	var geo := PolyRigGeodesicPolyRigInverseDistanceWeighting.calculate(segs, pts, tris)
	var euc := PolyRigInverseDistanceWeighting.calculate(segs, pts)
	
	# Vertex 6 (50,100): geodesic from bone 0 must go around the L
	# So geodesic should give bone 0 LESS weight than Euclidean would
	var geo_w0 :float= geo[0][6]
	var euc_w0 :float= euc[0][6]
	print("  [INFO] vertex 6: geo_bone0=%.3f euc_bone0=%.3f" % [geo_w0, euc_w0])
	_assert(abs(geo_w0 - euc_w0) > 0.001, "geodesic and euclidean give different weights (diff=%.4f)" % abs(geo_w0 - euc_w0))
