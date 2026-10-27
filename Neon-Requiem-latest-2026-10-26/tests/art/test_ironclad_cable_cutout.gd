extends SceneTree

const SOURCE_PATH := "res://assets/characters/ironclad/tier_01_drafts/profile_mesh_rig_candidate_01/IRONCLAD_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png"
const CUTOUT_PATH := "res://assets/characters/ironclad/tier_01_drafts/attachment_cutout_candidate_01/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01.png"
const EXPECTED_COUNT := 781
const EXPECTED_BOUNDS := Rect2i(190, 598, 69, 51)


func _initialize() -> void:
	var source := Image.new()
	var source_error := source.load(ProjectSettings.globalize_path(SOURCE_PATH))
	if source_error != OK:
		_fail("could not load source profile: %s" % error_string(source_error))
		return
	var cutout := Image.new()
	var cutout_error := cutout.load(ProjectSettings.globalize_path(CUTOUT_PATH))
	if cutout_error != OK:
		_fail("could not load cable candidate: %s" % error_string(cutout_error))
		return
	if source.get_size() != cutout.get_size():
		_fail("cutout is not canvas-aligned to its source")
		return

	var count := 0
	var min_x := cutout.get_width()
	var min_y := cutout.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(cutout.get_height()):
		for x in range(cutout.get_width()):
			var pixel := cutout.get_pixel(x, y)
			if pixel.a <= 0.0:
				continue
			count += 1
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
			var original := source.get_pixel(x, y)
			var output_rgb := pixel.to_rgba32() & 0x00ffffff
			var source_rgb := original.to_rgba32() & 0x00ffffff
			if output_rgb != source_rgb:
				_fail("cutout RGB differs from source at (%d, %d)" % [x, y])
				return

	var bounds := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	if count != EXPECTED_COUNT or bounds != EXPECTED_BOUNDS:
		_fail("unexpected visible pixels/bounds: %d, %s" % [count, bounds])
		return
	print("PASS: IRONCLAD cable cutout loads in Godot; %d source-RGB pixels, bounds %s." % [count, bounds])
	print("LIMIT: static quarantined cutout only; mounts, pivot, flex, semantics, and gameplay behavior remain unverified.")
	quit(0)


func _fail(message: String) -> void:
	push_error("IRONCLAD cable cutout test failed: " + message)
	quit(1)
