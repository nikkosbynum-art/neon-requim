extends Resource
class_name PolyRigDelaunay

# ==== CLASSES ====

class Edge:
	var a: Vector2
	var b: Vector2
	
	func _init(a_: Vector2, b_: Vector2) -> void:
		self.a = a_
		self.b = b_
		
	func equals(edge: Edge) -> bool:
		return (a == edge.a && b == edge.b) || (a == edge.b && b == edge.a)
	
	func length() -> float:
		return a.distance_to(b)
	
	func center() -> Vector2:
		return (a + b) * 0.5
	

class Triangle:
	var a: Vector2
	var b: Vector2
	var c: Vector2
	
	var edge_ab: Edge
	var edge_bc: Edge
	var edge_ca: Edge
	
	var center: Vector2
	var radius_sqr: float
	
	func _init(a_: Vector2, b_: Vector2, c_: Vector2) -> void:
		self.a = a_
		self.b = b_
		self.c = c_
		edge_ab = Edge.new(a,b)
		edge_bc = Edge.new(b,c)
		edge_ca = Edge.new(c,a)
		recalculate_circumcircle()
	
	
	func recalculate_circumcircle() -> void:
		var ab: float = a.length_squared()
		var cd: float = b.length_squared()
		var ef: float = c.length_squared()
		
		var cmb: Vector2 = c - b
		var amc: Vector2 = a - c
		var bma: Vector2 = b - a
		
		var denom_x: float = a.x * cmb.y + b.x * amc.y + c.x * bma.y
		var denom_y: float = a.y * cmb.x + b.y * amc.x + c.y * bma.x
		
		if is_zero_approx(denom_x) or is_zero_approx(denom_y):
			center = (a + b + c) / 3.0
			radius_sqr = INF
			return
	
		var circum: Vector2 = Vector2(
			(ab * cmb.y + cd * amc.y + ef * bma.y) / denom_x,
			(ab * cmb.x + cd * amc.x + ef * bma.x) / denom_y
		)
	
		center = circum * 0.5
		radius_sqr = a.distance_squared_to(center)
	
	func is_point_inside_circumcircle(point: Vector2) -> bool:
		if point == a or point == b or point == c:
			return false
		return center.distance_squared_to(point) < radius_sqr
	
	func is_corner(point: Vector2) -> bool:
		return point == a || point == b || point == c
	
	func get_corner_opposite_edge(corner: Vector2) -> Edge:
		if corner == a:
			return edge_bc
		elif corner == b:
			return edge_ca
		elif corner == c:
			return edge_ab
		else:
			return null

class VoronoiSite:
	var center: Vector2
	var polygon: PackedVector2Array # points in absolute position, clockwise
	var source_triangles: Array[Triangle] # Triangles that create this site internally
	var neighbours: Array[VoronoiEdge]
	
	func _init(center_: Vector2) -> void:
		self.center = center_
		
	func _sort_source_triangles(a: Triangle, b: Triangle) -> bool:
		var da: float = center.direction_to(a.center).angle()
		var db: float = center.direction_to(b.center).angle()
		return da < db # clockwise sort
	
	func get_relative_polygon() -> PackedVector2Array: # return points in relative position to center
		var polygon_local: PackedVector2Array
		for point: Vector2 in polygon:
			polygon_local.append(point - center)
		return polygon_local
	
	func get_boundary() -> Rect2:
		var rect: Rect2 = Rect2(polygon[0], Vector2.ZERO)
		for point: Vector2 in polygon:
			rect = rect.expand(point)
		return rect


class VoronoiEdge:
	var a: Vector2
	var b: Vector2
	var this: VoronoiSite
	var other: VoronoiSite
	
	func equals(edge: VoronoiEdge) -> bool:
		return (a == edge.a && b == edge.b) || (a == edge.b && b == edge.a)
	
	func length() -> float:
		return a.distance_to(b)
	
	func center() -> Vector2:
		return (a + b) * 0.5
	
	func normal() -> Vector2:
		return a.direction_to(b).orthogonal()


# ==== PUBLIC STATIC FUNCTIONS ====

# calculates rect that contains all given points
static func calculate_rect(all_points: PackedVector2Array, padding: float = 0.0) -> Rect2:
	var rect : Rect2 = Rect2(all_points[0], Vector2.ZERO)
	for point: Vector2 in all_points:
		rect = rect.expand(point)
	return rect.grow(padding)


# ==== PUBLIC VARIABLES ====
var points: PackedVector2Array


# ==== PRIVATE VARIABLES ====
var _rect: Rect2
var _rect_super: Rect2
var _rect_super_corners: Array[Vector2]
var _rect_super_triangle1: Triangle
var _rect_super_triangle2: Triangle


# ==== CONSTRUCTOR ====
func _init(rect : Rect2 = Rect2()) -> void:
	if (rect.has_area()):
		set_rectangle(rect)


# ==== PUBLIC FUNCTIONS ====
func add_point(point: Vector2) -> void:
	points.append(point)


func set_rectangle(rect: Rect2) -> void:
	_rect = rect # save original rect
	
	# we expand rect to super rect to make sure
	# all future points won't be too close to broder
	var rect_max_size: float = max(_rect.size.x, _rect.size.y)
	_rect_super = _rect.grow(rect_max_size * 1)
	
	# calcualte and cache triangles for super rectangle
	_rect_super_corners.clear()
	var c0: Vector2 = Vector2(_rect_super.position)
	var c1: Vector2 = Vector2(_rect_super.position + Vector2(_rect_super.size.x,0))
	var c2: Vector2 = Vector2(_rect_super.position + Vector2(0,_rect_super.size.y))
	var c3: Vector2 = Vector2(_rect_super.end)
	_rect_super_corners.append_array([c0,c1,c2,c3])
	_rect_super_triangle1 = Triangle.new(c0,c1,c2)
	_rect_super_triangle2 = Triangle.new(c1,c2,c3)


func is_border_triangle(triangle: Triangle) -> bool:
	return _rect_super_corners.has(triangle.a) || _rect_super_corners.has(triangle.b) || _rect_super_corners.has(triangle.c)


func remove_border_triangles(triangulation: Array[Triangle]) -> void:
	var border_triangles: Array[Triangle]
	for triangle: Triangle in triangulation:
		if is_border_triangle(triangle):
			border_triangles.append(triangle)
	for border_triangle: Triangle in border_triangles:
		triangulation.erase(border_triangle)


func is_border_site(site: VoronoiSite) -> bool:
	return !_rect.encloses(site.get_boundary())

### XN: Helper function to get the site polygons or if the site is a border site, get the clipped polygon.
func get_polygon_site(site: VoronoiSite) -> PackedVector2Array:
	if !is_border_site(site):
		return site.polygon

	# reconstruct the bounding rectangle into polygon
	var bound_rect: PackedVector2Array = PackedVector2Array([
		_rect.position, 
		_rect.position + Vector2(_rect.size.x, 0),
		_rect.end,
		_rect.position + Vector2(0, _rect.size.y),
		])
	
	var intersects: Array[PackedVector2Array] = Geometry2D.intersect_polygons(site.polygon, bound_rect)
	if intersects.size() > 1 : 
		print_debug("Warning: more than 1 intersect areas, return the first intersect area")
	
	return intersects[0]

func remove_border_sites(sites: Array[VoronoiSite]) -> void:
	var border_sites: Array[VoronoiSite]
	for site: VoronoiSite in sites:
		if is_border_site(site):
			border_sites.append(site)
	for border_site: VoronoiSite in border_sites:
		sites.erase(border_site)


func triangulate() -> Array[Triangle]:
	var triangulation: Array[Triangle]
	
	# calculate rectangle if none
	if !(_rect.has_area()):
		set_rectangle(calculate_rect(points))
	
	triangulation.append(_rect_super_triangle1)
	triangulation.append(_rect_super_triangle2)
	
	var bad_triangles: Array[Triangle]
	var polygon: Array[Edge]
	
	for point: Vector2 in points:
		bad_triangles.clear()
		polygon.clear()
	
		_find_bad_triangles(point, triangulation, bad_triangles)
		for bad_tirangle: Triangle in bad_triangles:
			triangulation.erase(bad_tirangle)
	
		_make_outer_polygon(bad_triangles, polygon)
		for edge: Edge in polygon:
			triangulation.append(Triangle.new(point, edge.a, edge.b))
	
	return triangulation


# ==== CDT (Constrained PolyRigDelaunay Triangulation) ====

## Constrained PolyRigDelaunay Triangulation.
## All vertices must be added via add_point() before calling.
## constraint_edges: edges that must be preserved in the final triangulation.
## Returns full triangulation (including super rectangle; use remove_border_triangles() to strip).
func triangulate_constrained(constraint_edges: Array[Edge]) -> Array[Triangle]:
	var triangulation := triangulate()
	
	# Split constraint edges at collinear intermediate vertices
	var all_constraints: Array[Edge] = []
	for constraint in constraint_edges:
		all_constraints.append_array(_cdt_split_constraint(constraint))
	
	# Build edge→triangles adjacency map for O(1) lookups
	var adj_map: Dictionary = {}
	for tri in triangulation:
		_adj_map_add_tri(adj_map, tri)
	
	# Build constraint set for O(1) constraint checks
	var constraint_set: Dictionary = {}
	for c in all_constraints:
		constraint_set[_edge_key(c)] = true
	
	# Insert each constraint edge via edge flipping (Sloan 1993)
	for c in all_constraints:
		_cdt_insert_edge(triangulation, c, adj_map)
	
	# Restore PolyRigDelaunay property for non-constraint edges
	_cdt_restore_delaunay(triangulation, adj_map, constraint_set)
	return triangulation


## CDT + boundary clipping. Automatically removes exterior triangles (including super rectangle).
## boundary: ordered closed polygon vertices; missing points are auto-added.
## Returns only triangles inside the boundary.
func triangulate_with_boundary(boundary: PackedVector2Array) -> Array[Triangle]:
	for p in boundary:
		if not points.has(p):
			add_point(p)
	
	var constraints: Array[Edge] = []
	for i in range(boundary.size()):
		constraints.append(Edge.new(boundary[i], boundary[(i + 1) % boundary.size()]))
	
	var triangulation := triangulate_constrained(constraints)
	
	# Use split constraints for exterior removal — original edges may have been
	# split at collinear intermediate vertices inside triangulate_constrained,
	# so the original edges no longer exist in the triangulation.
	var split_constraints: Array[Edge] = []
	for c in constraints:
		split_constraints.append_array(_cdt_split_constraint(c))
	_cdt_remove_exterior(triangulation, split_constraints)
	return triangulation


func make_voronoi(triangulation: Array[Triangle]) -> Array[VoronoiSite]:
	var sites: Array[VoronoiSite]

	var completion_counter: Array[Vector2] # no PackedVector2Array to allow more oeprations
	var triangle_usage: Dictionary # Dictionary[Triangle, Array] # of Array[VoronoiSite], used for neighbour scan
	for triangle: Triangle in triangulation:
		triangle_usage[triangle] = []
		
	for point: Vector2 in points:
		var site: VoronoiSite = VoronoiSite.new(point)
		
		completion_counter.clear()
		
		for triangle: Triangle in triangulation:
			if !triangle.is_corner(point):
				continue
			
			site.source_triangles.append(triangle)
			
			var edge: Edge = triangle.get_corner_opposite_edge(point)
			completion_counter.erase(edge.a)
			completion_counter.erase(edge.b)
			completion_counter.append(edge.a)
			completion_counter.append(edge.b)
		
		var is_complete: bool = completion_counter.size() == site.source_triangles.size()
		if !is_complete:
			continue # do not add sites without complete polygon, usually only corner sites than come from Rect boundary
		
		var sort_func: Callable = Callable(site, "_sort_source_triangles")
		sort_func.bind(site.source_triangles)
		site.source_triangles.sort_custom(sort_func)
		
		var polygon: PackedVector2Array
		for triangle: Triangle in site.source_triangles:
			polygon.append(triangle.center)
			triangle_usage[triangle].append(site)
		
		site.polygon = polygon
		sites.append(site)
	
	# scan for neighbours
	for site: VoronoiSite in sites:
		for triangle: Triangle in site.source_triangles:
			var posibilities: Array[VoronoiSite]
			posibilities.assign(triangle_usage[triangle])
			var neighbour: VoronoiEdge = _find_voronoi_neighbour(site, triangle, posibilities)
			if neighbour != null:
				site.neighbours.append(neighbour)
	
	return sites


# ==== PRIVATE FUNCTIONS ====	
func _make_outer_polygon(triangles: Array[Triangle], out_polygon: Array[Edge]) -> void:
	var duplicates: Array[Edge]
	
	for triangle: Triangle in triangles:
		out_polygon.append(triangle.edge_ab)
		out_polygon.append(triangle.edge_bc)
		out_polygon.append(triangle.edge_ca)
	
	for edge1: Edge in out_polygon:
		for edge2: Edge in out_polygon:
			if edge1 != edge2 && edge1.equals(edge2):
				duplicates.append(edge1)
				duplicates.append(edge2)
	
	for edge: Edge in duplicates:
		out_polygon.erase(edge)


func _find_bad_triangles(point: Vector2, triangles: Array[Triangle], out_bad_triangles: Array[Triangle]) -> void:
	for triangle: Triangle in triangles:
		if triangle.is_point_inside_circumcircle(point):
			out_bad_triangles.append(triangle)


func _find_voronoi_neighbour(site: VoronoiSite, triangle: Triangle, possibilities: Array[VoronoiSite]) -> VoronoiEdge:
	var triangle_index: int = site.source_triangles.find(triangle)
	var next_triangle_index: int = triangle_index + 1
	if next_triangle_index == site.source_triangles.size():
		next_triangle_index = 0
	var next_triangle: Triangle = site.source_triangles[next_triangle_index]
	
	var opposite_edge: Edge = triangle.get_corner_opposite_edge(site.center)
	var opposite_edge_next: Edge = next_triangle.get_corner_opposite_edge(site.center)
	var common_point: Vector2 = opposite_edge.a
	if common_point != opposite_edge_next.a && common_point != opposite_edge_next.b:
		common_point = opposite_edge.b
	
	for pos_site: VoronoiSite in possibilities:
		if pos_site.center != common_point:
			continue
		
		var edge: VoronoiEdge = VoronoiEdge.new()
		edge.a = triangle.center
		edge.b = next_triangle.center
		edge.this = site
		edge.other = pos_site
		return edge
	
	return null


# super triangle is not used since this method was giving worse results than super rectangle
# but I'm leaving this function because it works if someone needs it
func _calculate_super_triangle() -> Triangle:
	# calculate super rectangle
	var minp: Vector2 = points[0]
	var maxp: Vector2 = points[0]
	for point: Vector2 in points:
		minp.x = min(minp.x, point.x)
		minp.y = min(minp.y, point.y)
		maxp.x = max(maxp.x, point.x)
		maxp.y = max(maxp.y, point.y)
	
	# add extra safe space padding
	minp = minp - (maxp - minp) * 0.25
	maxp = maxp + (maxp - minp) * 0.25
	
	# extend rectangle to square
	var a: float = maxp.x - minp.x
	var b: float = maxp.y - minp.y
	var hd: float = abs(a - b) * 0.5
	if a > b:
		minp.y = minp.y - hd
		maxp.y = maxp.y + hd
		b = a
	elif a < b:
		minp.x = minp.x - hd
		maxp.x = maxp.x + hd
		a = b
	
	# make equilateral triangle that contains such square
	var b2: float = b * 0.5
	var a4: float = a * 0.25
	
	var p1: Vector2 = Vector2((minp.x + maxp.x) * 0.5, minp.y - b2)
	var p2: Vector2 = Vector2(minp.x - a4, maxp.y)
	var p3: Vector2 = Vector2(maxp.x + a4, maxp.y)
	
	return Triangle.new(p1, p2, p3)


# ==== CDT INTERNAL FUNCTIONS ====

## Tests if two segments strictly intersect (shared endpoints don't count).
static func _segments_properly_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var result = Geometry2D.segment_intersects_segment(p1, p2, p3, p4)
	if result == null:
		return false
	var pt: Vector2 = result
	if pt.is_equal_approx(p1) or pt.is_equal_approx(p2) or pt.is_equal_approx(p3) or pt.is_equal_approx(p4):
		return false
	return true


## Tests if point p lies strictly on segment (a, b), excluding endpoints.
static func _point_on_segment(p: Vector2, a: Vector2, b: Vector2, epsilon: float = 0.001) -> bool:
	var closest := Geometry2D.get_closest_point_to_segment(p, a, b)
	if p.distance_to(closest) > epsilon:
		return false
	return p.distance_to(a) > epsilon and p.distance_to(b) > epsilon


## Splits a constraint edge into sub-edges at collinear intermediate vertices.
func _cdt_split_constraint(constraint: Edge) -> Array[Edge]:
	var intermediates: Array[Vector2] = []
	for p in points:
		if p == constraint.a or p == constraint.b:
			continue
		if _point_on_segment(p, constraint.a, constraint.b):
			intermediates.append(p)
	if intermediates.is_empty():
		var result: Array[Edge] = []
		result.append(constraint)
		return result
	intermediates.sort_custom(func(a_pt: Vector2, b_pt: Vector2) -> bool:
		return constraint.a.distance_squared_to(a_pt) < constraint.a.distance_squared_to(b_pt)
	)
	var result: Array[Edge] = []
	var prev := constraint.a
	for p in intermediates:
		result.append(Edge.new(prev, p))
		prev = p
	result.append(Edge.new(prev, constraint.b))
	return result


## Adds a triangle's 3 edges to the adjacency map.
func _adj_map_add_tri(adj_map: Dictionary, tri: Triangle) -> void:
	for edge in [tri.edge_ab, tri.edge_bc, tri.edge_ca]:
		var key := _edge_key(edge)
		if not adj_map.has(key):
			adj_map[key] = []
		adj_map[key].append(tri)


## Removes a triangle's 3 edges from the adjacency map.
func _adj_map_remove_tri(adj_map: Dictionary, tri: Triangle) -> void:
	for edge in [tri.edge_ab, tri.edge_bc, tri.edge_ca]:
		var key := _edge_key(edge)
		if adj_map.has(key):
			adj_map[key].erase(tri)
			if adj_map[key].is_empty():
				adj_map.erase(key)


## Returns the vertex of a triangle opposite to the given edge.
static func _cdt_opposite_vertex(tri: Triangle, edge: Edge) -> Vector2:
	if tri.a != edge.a and tri.a != edge.b:
		return tri.a
	if tri.b != edge.a and tri.b != edge.b:
		return tri.b
	return tri.c




## Inserts a constraint edge by flipping intersecting edges (Sloan algorithm).
func _cdt_insert_edge(triangulation: Array[Triangle], constraint: Edge, adj_map: Dictionary) -> void:
	var ckey := _edge_key(constraint)
	if adj_map.has(ckey) and not adj_map[ckey].is_empty():
		return
	
	# Collect all triangulation edges that strictly intersect the constraint
	var intersecting: Array[Edge] = []
	var checked: Dictionary = {}
	for key in adj_map:
		if checked.has(key):
			continue
		checked[key] = true
		var tris: Array = adj_map[key]
		if tris.is_empty():
			continue
		var edge: Edge = tris[0].edge_ab
		for e in [tris[0].edge_ab, tris[0].edge_bc, tris[0].edge_ca]:
			if _edge_key(e) == key:
				edge = e
				break
		if _segments_properly_intersect(constraint.a, constraint.b, edge.a, edge.b):
			intersecting.append(edge)
	
	# Iteratively flip edges until the constraint edge appears
	var max_iter := intersecting.size() * intersecting.size() + 100
	var iter := 0
	while not intersecting.is_empty() and iter < max_iter:
		iter += 1
		var edge: Edge = intersecting.pop_front()
		
		var ekey := _edge_key(edge)
		var adj: Array = adj_map.get(ekey, [])
		if adj.size() != 2:
			continue
		
		var tri_a: Triangle = adj[0]
		var tri_b: Triangle = adj[1]
		var p1 := _cdt_opposite_vertex(tri_a, edge)
		var p2 := _cdt_opposite_vertex(tri_b, edge)
		
		# Convexity check: do the two diagonals strictly intersect (i.e. quadrilateral is convex)
		if _segments_properly_intersect(edge.a, edge.b, p1, p2):
			# Perform the flip: remove old triangles, add new ones, update adj_map
			_adj_map_remove_tri(adj_map, tri_a)
			_adj_map_remove_tri(adj_map, tri_b)
			triangulation.erase(tri_a)
			triangulation.erase(tri_b)
			var t1 := Triangle.new(p1, p2, edge.a)
			var t2 := Triangle.new(p1, p2, edge.b)
			triangulation.append(t1)
			triangulation.append(t2)
			_adj_map_add_tri(adj_map, t1)
			_adj_map_add_tri(adj_map, t2)
			var flipped := Edge.new(p1, p2)
			if not flipped.equals(constraint):
				if _segments_properly_intersect(constraint.a, constraint.b, flipped.a, flipped.b):
					intersecting.append(flipped)
		else:
			# Non-convex, defer processing
			intersecting.append(edge)
	
	if iter >= max_iter:
		push_warning("CDT: max iterations reached inserting constraint edge")


## Restores PolyRigDelaunay property for non-constraint edges (flips edges violating empty circle).
func _cdt_restore_delaunay(triangulation: Array[Triangle], adj_map: Dictionary, constraint_set: Dictionary) -> void:
	var max_passes := triangulation.size() * 3
	for _pass in range(max_passes):
		var flipped_any := false
		
		# Collect non-constraint edges from adj_map keys
		var edge_keys: Array = adj_map.keys()
		
		for key in edge_keys:
			if constraint_set.has(key):
				continue
			if not adj_map.has(key):
				continue
			var adj: Array = adj_map[key]
			if adj.size() != 2:
				continue
			var tri_a: Triangle = adj[0]
			var tri_b: Triangle = adj[1]
			var edge: Edge = tri_a.edge_ab
			for e in [tri_a.edge_ab, tri_a.edge_bc, tri_a.edge_ca]:
				if _edge_key(e) == key:
					edge = e
					break
			var p1 := _cdt_opposite_vertex(tri_a, edge)
			var p2 := _cdt_opposite_vertex(tri_b, edge)
			# Check empty circle property
			if tri_a.is_point_inside_circumcircle(p2):
				if _segments_properly_intersect(edge.a, edge.b, p1, p2):
					_adj_map_remove_tri(adj_map, tri_a)
					_adj_map_remove_tri(adj_map, tri_b)
					triangulation.erase(tri_a)
					triangulation.erase(tri_b)
					var t1 := Triangle.new(p1, p2, edge.a)
					var t2 := Triangle.new(p1, p2, edge.b)
					triangulation.append(t1)
					triangulation.append(t2)
					_adj_map_add_tri(adj_map, t1)
					_adj_map_add_tri(adj_map, t2)
					flipped_any = true
					break
		
		if not flipped_any:
			break


## Flood-fills from super rectangle border to remove all triangles outside the constraint boundary.
func _cdt_remove_exterior(triangulation: Array[Triangle], constraints: Array[Edge]) -> void:
	# Build edge -> adjacent triangles lookup for O(1) neighbour queries
	var adj_map: Dictionary = {}  # edge_key -> Array[Triangle]
	for tri in triangulation:
		for edge in [tri.edge_ab, tri.edge_bc, tri.edge_ca]:
			var key := _edge_key(edge)
			if not adj_map.has(key):
				adj_map[key] = []
			adj_map[key].append(tri)

	# Build constraint edge set for O(1) lookup
	var constraint_set: Dictionary = {}
	for c in constraints:
		constraint_set[_edge_key(c)] = true

	var visited: Dictionary = {}
	var queue: Array[Triangle] = []

	# Start from triangles containing super rectangle vertices (guaranteed exterior)
	for tri in triangulation:
		if is_border_triangle(tri) and not visited.has(tri):
			queue.append(tri)
			visited[tri] = true

	while not queue.is_empty():
		var current: Triangle = queue.pop_front()
		# Expand to adjacent triangles via non-constraint edges
		for edge in [current.edge_ab, current.edge_bc, current.edge_ca]:
			var key := _edge_key(edge)
			if constraint_set.has(key):
				continue
			if not adj_map.has(key):
				continue
			for tri in adj_map[key]:
				if not visited.has(tri):
					visited[tri] = true
					queue.append(tri)

	# Remove all visited (exterior) triangles
	var i := triangulation.size() - 1
	while i >= 0:
		if visited.has(triangulation[i]):
			triangulation.remove_at(i)
		i -= 1


## Returns a canonical string key for an edge (order-independent).
static func _edge_key(edge: Edge) -> String:
	var sa := str(edge.a)
	var sb := str(edge.b)
	return sa + "|" + sb if sa < sb else sb + "|" + sa

## Constrained PolyRigDelaunay triangulation with boundary clipping.
## Returns Array of PackedInt32Array, each containing 3 indices into all_pts.
static func triangulate_to_indices(all_pts: PackedVector2Array, outline: PackedVector2Array) -> Array:
	var d := PolyRigDelaunay.new(PolyRigDelaunay.calculate_rect(all_pts, 100.0))
	for p in all_pts: d.add_point(p)
	var tris := d.triangulate_with_boundary(outline)
	# Pre-build point→index lookup for O(1) instead of O(n) per query
	var idx_map := {}
	for i in range(all_pts.size()):
		idx_map[all_pts[i]] = i
	var result := []
	for tri in tris:
		var i1: int = idx_map.get(tri.a, -1)
		var i2: int = idx_map.get(tri.b, -1)
		var i3: int = idx_map.get(tri.c, -1)
		if i1 >= 0 and i2 >= 0 and i3 >= 0:
			result.append(PackedInt32Array([i1, i2, i3]))
	return result

func _find_point_index(points: PackedVector2Array, target: Vector2) -> int:
	for i in range(points.size()):
		if points[i] == target:
			return i
	return -1

static func triangulate_polygon(polygon: Polygon2D, apply: bool = false) -> Array:
	var pts := polygon.polygon
	var ivc := polygon.internal_vertex_count
	var outline := pts.slice(0, pts.size() - ivc) if ivc > 0 else pts
	var polys := PolyRigDelaunay.triangulate_to_indices(pts, outline)
	if apply:
		polygon.polygons = polys
		polygon.uv = pts
		polygon.queue_redraw()
	return polys
