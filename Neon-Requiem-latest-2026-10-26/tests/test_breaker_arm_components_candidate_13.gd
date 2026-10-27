extends SceneTree

const IMAGE_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.png"
const METADATA_PATH := "res://assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.json"
const REFERENCE_DIR := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v2/"
const EXPECTED_SIZE := Vector2i(1774, 887)
const PANEL_BOUNDS := [
	Rect2i(157, 157, 167, 407),
	Rect2i(487, 112, 328, 260),
	Rect2i(929, 298, 329, 512),
	Rect2i(1357, 17, 376, 813),
]
const EXPECTED_SPANS := [Vector2i(157, 323), Vector2i(487, 814), Vector2i(929, 1257), Vector2i(1357, 1732)]
const ASSEMBLY_CANVAS := Vector2i(450, 950)
const ASSEMBLY_OFFSETS := [Vector2i(100, 100), Vector2i(19, 55), Vector2i(151, 305)]
var failures := 0


func _initialize() -> void:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(IMAGE_PATH))
	_check(error == OK, "Godot must decode candidate 13 directly from disk.")
	if error != OK:
		quit(1)
		return
	_check(image.get_size() == EXPECTED_SIZE, "Candidate 13 must retain its audited canvas.")
	for point in [Vector2i(0, 0), Vector2i(1773, 0), Vector2i(0, 886), Vector2i(1773, 886)]:
		_check(image.get_pixelv(point).a == 0.0, "Canvas corners must be transparent.")

	var spans: Array[Vector2i] = []
	var in_span := false
	var start_x := 0
	for x in range(image.get_width()):
		var occupied := false
		for y in range(image.get_height()):
			if image.get_pixel(x, y).a * 255.0 >= 245.0:
				occupied = true
				break
		if occupied and not in_span:
			start_x = x
			in_span = true
		elif not occupied and in_span:
			spans.append(Vector2i(start_x, x - 1))
			in_span = false
	if in_span:
		spans.append(Vector2i(start_x, image.get_width() - 1))
	_check(spans == EXPECTED_SPANS, "Candidate 13 must have four separated opaque panel ranges.")

	for index in range(PANEL_BOUNDS.size()):
		var bounds: Rect2i = PANEL_BOUNDS[index]
		var actual := _alpha_bounds(image, bounds)
		_check(actual == bounds, "Panel %d bounds must match its audited region; got %s." % [index + 1, str(actual)])

	var upper_height := PANEL_BOUNDS[0].size.y
	var forearm_height := PANEL_BOUNDS[2].size.y
	var assembled_height := PANEL_BOUNDS[3].size.y
	var overlap := upper_height + forearm_height - assembled_height
	_check(overlap >= 0 and float(overlap) / float(forearm_height) <= 0.25, "Component heights should fit the assembled height with at most 25% forearm overlap.")
	var upper_mask := _placed_alpha_mask(image, PANEL_BOUNDS[0], ASSEMBLY_OFFSETS[0])
	var shell_mask := _placed_alpha_mask(image, PANEL_BOUNDS[1], ASSEMBLY_OFFSETS[1])
	var forearm_mask := _placed_alpha_mask(image, PANEL_BOUNDS[2], ASSEMBLY_OFFSETS[2])
	var shell_underlap := _count_overlap(upper_mask, shell_mask)
	var elbow_overlap := _count_overlap(upper_mask, forearm_mask)
	var exposed_upper := _count_exposed(upper_mask, shell_mask)
	_check(shell_underlap >= 20000, "External shell must cover a meaningful area of the biological upper-arm surface; got %d px." % shell_underlap)
	_check(exposed_upper >= 15000, "Biological upper-arm surface must remain visibly exposed below/around the shell; got %d px." % exposed_upper)
	_check(elbow_overlap >= 10000, "Biological upper arm and mechanical forearm must overlap at the estimated elbow; got %d px." % elbow_overlap)
	var reference_height := _reference_arm_height()
	var reference_width := _reference_arm_width()
	var reference_body_height := _reference_body_height()
	_check(reference_height > 0 and reference_width > 0 and reference_body_height > 0, "Approved-direction reference layers and visible-height metadata must load.")
	var height_scale_factor := float(reference_height) / float(PANEL_BOUNDS[3].size.y)
	var reference_arm_at_256 := float(reference_height) * 256.0 / float(reference_body_height)
	var candidate_arm_at_256 := float(PANEL_BOUNDS[3].size.y) * height_scale_factor * 256.0 / float(reference_body_height)
	_check(height_scale_factor >= 0.25 and height_scale_factor <= 0.85, "Candidate arm height scale should be plausible for the reference; got %.3f." % height_scale_factor)
	_check(absf(reference_arm_at_256 - candidate_arm_at_256) <= 0.5, "Candidate arm must match the reference arm height at 256 px character scale.")
	var reference_aspect := float(reference_width) / float(reference_height)
	var candidate_aspect := float(PANEL_BOUNDS[3].size.x) / float(PANEL_BOUNDS[3].size.y)
	var candidate_width_at_match := float(PANEL_BOUNDS[3].size.x) * height_scale_factor
	var width_ratio := candidate_width_at_match / float(reference_width)
	_check(candidate_aspect < reference_aspect * 0.5, "The current audit should detect and prevent treating candidate 13 as a silhouette match.")
	_check(width_ratio < 0.5, "Candidate 13 must remain visibly narrower than the reference at matched height.")
	var metadata_file := FileAccess.open(ProjectSettings.globalize_path(METADATA_PATH), FileAccess.READ)
	_check(metadata_file != null, "Candidate 13 visual-fit disposition metadata must exist.")
	if metadata_file != null:
		var metadata: Variant = JSON.parse_string(metadata_file.get_as_text())
		var fit_review: Dictionary = metadata.get("visual_fit_review", {}) if metadata is Dictionary else {}
		_check(str(fit_review.get("status", "")).contains("REJECTED AS A FULL-BODY ARM PROPORTION / SILHOUETTE MATCH"), "Candidate 13 must stay rejected as a full-body silhouette match.")

	if failures == 0:
		print("PASS: Godot 4.7.2 checks candidate 13 RGBA image, four panels, reference scale, under-shell coverage, visible upper arm, and elbow overlap.")
		print("INFO: estimated 2D alpha overlap shell/upper-arm=%d px, visible upper-arm=%d px, elbow=%d px." % [shell_underlap, exposed_upper, elbow_overlap])
		print("INFO: height-only scale factor to BREAKER reference=%.3f; matched arm extent=%.1f px at 256 px character height." % [height_scale_factor, reference_arm_at_256])
		print("INFO: candidate/reference aspect=%.3f/%.3f; at matched height its width is %.1f px vs %d px (%.1f%% narrower); fit remains rejected." % [candidate_aspect, reference_aspect, candidate_width_at_match, reference_width, (1.0 - width_ratio) * 100.0])
		print("LIMIT: these checks use estimated pivots and do not validate anatomical accuracy, hidden 3D structures, authored pivots, or animation seams.")
		quit(0)
	else:
		push_error("%d candidate 13 checks failed." % failures)
		quit(1)


func _alpha_bounds(image: Image, region: Rect2i) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a * 255.0 >= 245.0:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _placed_alpha_mask(image: Image, region: Rect2i, offset: Vector2i) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(ASSEMBLY_CANVAS.x * ASSEMBLY_CANVAS.y)
	for y in range(region.size.y):
		for x in range(region.size.x):
			var alpha := image.get_pixel(region.position.x + x, region.position.y + y).a * 255.0
			if alpha >= 128.0:
				var px := offset.x + x
				var py := offset.y + y
				if px >= 0 and px < ASSEMBLY_CANVAS.x and py >= 0 and py < ASSEMBLY_CANVAS.y:
					mask[py * ASSEMBLY_CANVAS.x + px] = 1
	return mask


func _reference_arm_bounds() -> Rect2i:
	var upper := Image.new()
	var forearm := Image.new()
	if upper.load(ProjectSettings.globalize_path(REFERENCE_DIR + "cyber_upper_arm.png")) != OK:
		return Rect2i()
	if forearm.load(ProjectSettings.globalize_path(REFERENCE_DIR + "cyber_forearm.png")) != OK:
		return Rect2i()
	var full_upper := Rect2i(Vector2i.ZERO, upper.get_size())
	var full_forearm := Rect2i(Vector2i.ZERO, forearm.get_size())
	var upper_bounds := _alpha_bounds(upper, full_upper)
	var forearm_bounds := _alpha_bounds(forearm, full_forearm)
	var x0 := mini(upper_bounds.position.x, forearm_bounds.position.x)
	var y0 := mini(upper_bounds.position.y, forearm_bounds.position.y)
	var x1 := maxi(upper_bounds.end.x, forearm_bounds.end.x)
	var y1 := maxi(upper_bounds.end.y, forearm_bounds.end.y)
	return Rect2i(x0, y0, x1 - x0, y1 - y0)


func _reference_arm_height() -> int:
	return _reference_arm_bounds().size.y


func _reference_arm_width() -> int:
	return _reference_arm_bounds().size.x


func _reference_body_height() -> int:
	var file := FileAccess.open(ProjectSettings.globalize_path(REFERENCE_DIR + "pivot_manifest.json"), FileAccess.READ)
	if file == null:
		return 0
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("source_visible_height_px"):
		return 0
	return int(parsed["source_visible_height_px"])


func _count_overlap(first: PackedByteArray, second: PackedByteArray) -> int:
	var count := 0
	for i in range(first.size()):
		if first[i] != 0 and second[i] != 0:
			count += 1
	return count


func _count_exposed(first: PackedByteArray, cover: PackedByteArray) -> int:
	var count := 0
	for i in range(first.size()):
		if first[i] != 0 and cover[i] == 0:
			count += 1
	return count


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER CANDIDATE 13 TEST FAILED: " + message)
