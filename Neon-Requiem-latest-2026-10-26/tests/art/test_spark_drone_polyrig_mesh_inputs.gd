extends SceneTree

## Mechanical PolyRig preflight for the three quarantined SPARK drone cutouts.
## This confirms each candidate texture can be split into independently
## triangulated alpha contours; it does not validate semantic completeness,
## pivots, hidden surfaces, or animation readiness.

const DRONE_PATHS := [
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_01_BLUE_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_02_RED_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
	"res://assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_03_AMBER_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png",
]

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in DRONE_PATHS:
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(path))
		_assert(error == OK, "%s loads from disk" % path.get_file())
		if error != OK:
			continue
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(image)
		var contours := bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), 1.0)
		_assert(not contours.is_empty(), "%s contains at least one alpha contour" % path.get_file())
		var triangulated := 0
		for contour in contours:
			var triangles: Array = PolyRigDelaunay.triangulate_to_indices(contour, contour)
			if not triangles.is_empty():
				triangulated += 1
		print("[INFO] %s: %d alpha contours, %d triangulated independently" % [path.get_file(), contours.size(), triangulated])
		_assert(triangulated == contours.size(), "%s: each disconnected contour triangulates independently" % path.get_file())
	if failures == 0:
		print("PASS: all quarantined SPARK drone candidate contours are independently triangulable PolyRig inputs.")
		quit(0)
	else:
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] ", message)
	else:
		failures += 1
		push_error("[FAIL] " + message)
