extends SceneTree

## Guards the asset-prep contract against PolyRig's current alpha-mesh behavior:
## Auto Mesh selects one contour per texture, so disconnected attachments need
## their own named image/layer and Polygon2D owner.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var image := Image.create(128, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	# A body-like region plus a detached accessory/drone region.
	image.fill_rect(Rect2i(8, 8, 48, 76), Color.WHITE)
	image.fill_rect(Rect2i(86, 22, 24, 20), Color.WHITE)

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)
	var contours := bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), 1.0)
	_assert(contours.size() == 2, "Synthetic body and detached attachment produce two alpha contours")

	var separately_triangulated := 0
	for contour in contours:
		var triangles: Array = PolyRigDelaunay.triangulate_to_indices(contour, contour)
		if not triangles.is_empty():
			separately_triangulated += 1
	_assert(separately_triangulated == 2, "PolyRig can triangulate body and attachment as separate mesh inputs")
	if failures == 0:
		print("PASS: detached body/attachment contours can be triangulated as separate PolyRig mesh inputs.")
		quit(0)
	else:
		quit(1)

var failures := 0

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] ", message)
	else:
		failures += 1
		push_error("[FAIL] " + message)
