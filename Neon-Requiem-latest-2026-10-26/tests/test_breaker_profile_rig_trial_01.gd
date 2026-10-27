extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_01_preview.tscn"
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Could not load isolated BREAKER profile rig scene.")
	if packed == null:
		quit(1)
		return
	var rig: Variant = packed.instantiate()
	rig.draw_review_stage = false
	root.add_child(rig)
	await process_frame
	_check(rig.load_failures == 0, "One or more part textures or pivots failed to load.")
	_check(rig.loaded_part_count == 13, "Expected 13 modular part textures; got %d." % rig.loaded_part_count)
	_check(rig.art_manifest.get("asset_status") == "review_only", "Preview did not retain the manifest review-only status.")
	_check(rig.art_manifest.get("production_gates", {}).values().all(func(value: Variant) -> bool: return value == false), "Review manifest unexpectedly declares a complete production gate.")
	_check(rig.bones.size() == rig.art_manifest.get("bone_hierarchy", []).size(), "Rig bone count does not match the manifest hierarchy.")
	_check(rig.sprites.size() == rig.art_manifest.get("parts", []).size(), "Rig part count does not match the manifest parts.")
	_check(is_equal_approx(rig.skeleton.scale.x, float(rig.art_manifest["target_visible_height_px"]) / float(rig.art_manifest["measured_visible_height_px"])), "Rig display scale is not derived from manifest visible-height values.")
	for part in rig.art_manifest.get("parts", []):
		var part_name := str(part.get("name", ""))
		var sprite: Sprite2D = rig.sprites.get(part_name)
		_check(sprite != null, "Manifest part was not instantiated: %s." % part_name)
		if sprite != null:
			_check(sprite.z_index == int(part.get("draw_order", -1)), "Manifest draw order was not applied to %s." % part_name)
			_check(sprite.get_parent().name == str(part.get("parent_bone", "")), "Manifest parent bone was not applied to %s." % part_name)
	_check(rig.check_neutral_alignment(), "Neutral part origins do not align to one shared source canvas.")
	var anchor: Vector2 = rig.get_anchor_global_position()
	for pose in ["idle", "walk", "punch", "hit"]:
		_check(rig.has_pose(pose), "Missing preview animation: %s." % pose)
		rig.play_pose(pose)
		var tracked_bone := "Torso" if pose == "idle" or pose == "hit" else "CyberShoulder" if pose == "punch" else "LeftHip"
		await create_timer(0.12).timeout
		_check(absf(rig.get_bone_rotation(tracked_bone)) > 0.001, "%s did not animate its expected pivot." % pose)
		_check(rig.get_anchor_global_position().distance_to(anchor) < 0.001, "Visual pose moved the ground anchor during %s." % pose)
		_check(rig.loaded_part_count == 13, "Part texture count changed during %s." % pose)
		print("Godot rig test pose: %s; pivot animated; ground anchor stable; 13 parts loaded." % pose)
	if failures == 0:
		print("PASS: BREAKER profile rig trial 01 structural/pose smoke test.")
		quit(0)
	else:
		push_error("%d BREAKER profile rig test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("BREAKER PROFILE RIG TEST FAILED: " + message)
