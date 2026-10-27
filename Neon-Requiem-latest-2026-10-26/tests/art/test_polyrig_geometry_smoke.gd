extends SceneTree

## Headless feasibility smoke test for the installed PolyRig 0.9.3 algorithms.
## This checks mesh triangulation and normalized weights only; it does not
## approve any character art, pivots, or deformation.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var boundary := PackedVector2Array([
		Vector2(0, 0), Vector2(100, 0), Vector2(100, 200), Vector2(0, 200)
	])
	var points := boundary + PackedVector2Array([
		Vector2(50, 45), Vector2(50, 100), Vector2(50, 155)
	])
	var triangles: Array = PolyRigDelaunay.triangulate_to_indices(points, boundary)
	_assert(not triangles.is_empty(), "PolyRig triangulates a body-like silhouette mesh")

	var segments := [
		{"head": Vector2(50, 15), "tail": Vector2(50, 90), "bi": 0},
		{"head": Vector2(50, 90), "tail": Vector2(50, 185), "bi": 1},
	]
	var weights: Dictionary = PolyRigGeodesicPolyRigInverseDistanceWeighting.calculate(
		segments, points, triangles
	)
	_assert(weights.has(0) and weights.has(1), "PolyRig calculates weights for both bones")
	if weights.has(0) and weights.has(1):
		for vertex_index in range(points.size()):
			var sum := float(weights[0][vertex_index]) + float(weights[1][vertex_index])
			_assert(absf(sum - 1.0) < 0.001, "vertex %d has normalized bone weights" % vertex_index)
	print("PolyRig geometry smoke test complete")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] ", message)
	else:
		push_error("[FAIL] " + message)
		quit(1)
