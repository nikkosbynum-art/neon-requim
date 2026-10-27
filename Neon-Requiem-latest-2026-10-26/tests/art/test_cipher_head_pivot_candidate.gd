extends SceneTree

## Isolated transform smoke test for the quarantined CIPHER head/hood composite.
## This does not validate anatomy, a full-body rig, animation, or art approval.

const ART_PATH := "res://assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/cleanup_working/CIPHER_T1_HEAD_NECK_CLEANED_CANDIDATE_01_QUARANTINED.png"
const PIVOT_PX := Vector2(760.0, 815.0) # provisional neck socket proposal; not production-authored
const REVIEW_SILHOUETTE_HEIGHT := 110.0 # provisional review scale based on the approved profile proportion
const ROTATION_SAMPLES := [-0.08, -0.04, 0.0, 0.04, 0.08]

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(ART_PATH))
	_check(error == OK, "Cleaned quarantined head candidate must load.")
	if error != OK:
		quit(1)
		return
	_check(image.get_size() == Vector2i(1536, 1120), "Candidate dimensions must match the audited export.")
	_check(image.get_format() == Image.FORMAT_RGBA8, "Candidate must retain RGBA transparency.")
	if image.get_size() != Vector2i(1536, 1120):
		quit(1)
		return

	var bounds := _alpha_bounds(image, 32)
	_check(bounds == Rect2i(372, 141, 793, 856), "Threshold-32 silhouette bounds must match the recorded audit.")
	_check(bounds.has_point(Vector2i(roundi(PIVOT_PX.x), roundi(PIVOT_PX.y))), "Provisional neck pivot must sit inside the visible composite bounds.")
	_check(image.get_pixel(0, 0).a == 0.0 and image.get_pixel(1535, 0).a == 0.0 and image.get_pixel(0, 1119).a == 0.0 and image.get_pixel(1535, 1119).a == 0.0, "All four corners must remain transparent.")

	var texture := ImageTexture.create_from_image(image)
	var skeleton := Skeleton2D.new()
	skeleton.name = "CipherRigPreviewSkeleton"
	root.add_child(skeleton)
	var body_root := Bone2D.new()
	body_root.name = "BodyRoot"
	body_root.set_autocalculate_length_and_angle(false)
	body_root.set_length(16.0)
	body_root.rest = body_root.transform
	skeleton.add_child(body_root)
	var neck_bone := Bone2D.new()
	neck_bone.name = "NeckSocket_Provisional"
	neck_bone.position = Vector2(180.0, 310.0)
	neck_bone.set_autocalculate_length_and_angle(false)
	neck_bone.set_length(16.0)
	neck_bone.rest = neck_bone.transform
	body_root.add_child(neck_bone)
	var sprite := Sprite2D.new()
	sprite.name = "QuarantinedHeadComposite"
	sprite.centered = false
	sprite.texture = texture
	var art_scale := REVIEW_SILHOUETTE_HEIGHT / float(bounds.size.y)
	sprite.scale = Vector2.ONE * art_scale
	sprite.position = -PIVOT_PX * art_scale
	neck_bone.add_child(sprite)
	await process_frame

	_check(is_finite(art_scale) and art_scale > 0.0, "Review scale must be finite and positive.")
	_check(is_equal_approx(float(bounds.size.y) * art_scale, REVIEW_SILHOUETTE_HEIGHT), "Silhouette must match the declared review height.")
	for angle in ROTATION_SAMPLES:
		neck_bone.rotation = float(angle)
		await process_frame
		var pivot_world := sprite.to_global(PIVOT_PX)
		var socket_world := neck_bone.to_global(Vector2.ZERO)
		_check(pivot_world.distance_to(socket_world) < 0.01, "The neck pivot must remain fixed at %.2f rad." % float(angle))

	if failures == 0:
		print("PASS: CIPHER head composite loads, matches the alpha-audit bounds, scales to the provisional profile size, and stays attached to the proposed neck pivot across five small rotations.")
		print("LIMIT: this is a head-pivot transform smoke test only; it does not validate a torso seam, body parts, animation quality, or production readiness.")
		quit(0)
	else:
		push_error("%d CIPHER head-pivot test(s) failed." % failures)
		quit(1)


func _alpha_bounds(image: Image, threshold: int) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a * 255.0 < threshold:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CIPHER HEAD PIVOT FAILED: " + message)
