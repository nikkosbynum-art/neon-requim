extends Node2D

## Runtime adapter for the standard character_art_manifest.json contract.
## It assembles authored parts and declared pivots; it does not invent poses.

var manifest_path := ""
var character_id := ""
var source_canvas := Vector2.ZERO
var source_ground := Vector2.ZERO
var measured_visible_height := 0.0
var skeleton: Skeleton2D
var bones: Dictionary = {}
var parts: Dictionary = {}
var load_error := ""


func build(path: String) -> bool:
	manifest_path = path.strip_edges()
	var resource_path := manifest_path if manifest_path.begins_with("res://") else "res://" + manifest_path.trim_prefix("/")
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	var project_root := ProjectSettings.globalize_path("res://").simplify_path().trim_suffix("/")
	var normalized_path := absolute_path.simplify_path()
	if normalized_path != project_root and not normalized_path.begins_with(project_root + "/"):
		load_error = "Manifest path must stay inside the project."
		return false
	var file := FileAccess.open(resource_path, FileAccess.READ)
	if file == null:
		load_error = "Could not read manifest: " + resource_path
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		load_error = "Manifest root must be a JSON object."
		return false
	var manifest: Dictionary = parsed
	character_id = String(manifest.get("character_id", ""))
	set_meta("tier_id", int(manifest.get("tier_id", 1)))
	set_meta("source_reference", String(manifest.get("source_reference", "")))
	var canvas: Array = manifest.get("source_canvas_px", [])
	var pivots: Dictionary = manifest.get("pivots_px", {})
	var hierarchy: Array = manifest.get("bone_hierarchy", [])
	var part_records: Array = manifest.get("parts", [])
	if canvas.size() != 2 or pivots.is_empty() or hierarchy.is_empty() or part_records.is_empty():
		load_error = "Manifest needs a canvas, named pivots, bone hierarchy, and parts."
		return false
	source_canvas = Vector2(float(canvas[0]), float(canvas[1]))
	var ground_pivot := String(manifest.get("ground_pivot", ""))
	if not pivots.has(ground_pivot):
		load_error = "Manifest ground_pivot must name an authored pivots_px entry."
		return false
	var ground: Array = pivots[ground_pivot]
	source_ground = Vector2(float(ground[0]), float(ground[1]))
	measured_visible_height = float(manifest.get("measured_visible_height_px", 0))
	var base_dir := resource_path.get_base_dir()
	if not _build_skeleton(hierarchy, pivots):
		return false
	if not _attach_parts(part_records, pivots, base_dir):
		return false
	return true


func _build_skeleton(hierarchy: Array, pivots: Dictionary) -> bool:
	skeleton = Skeleton2D.new()
	skeleton.name = "ManifestSkeleton"
	add_child(skeleton)
	for entry_value in hierarchy:
		if not entry_value is Dictionary:
			load_error = "Every bone_hierarchy record must be an object."
			return false
		var entry: Dictionary = entry_value
		var bone_name := String(entry.get("name", ""))
		var parent_name := String(entry.get("parent", ""))
		var pivot_name := String(entry.get("pivot", ""))
		if bone_name.is_empty() or bones.has(bone_name) or not pivots.has(pivot_name):
			load_error = "Bone names and pivot references must be unique and valid."
			return false
		var parent: Node = skeleton if parent_name.is_empty() else bones.get(parent_name)
		if parent == null:
			load_error = "Bones must be parent-first; missing parent " + parent_name
			return false
		var pivot_point := _pivot(pivots, pivot_name)
		var local_position := pivot_point
		if not parent_name.is_empty():
			var parent_pivot_name := String(entry.get("parent_pivot", ""))
			if not pivots.has(parent_pivot_name):
				load_error = "Bone %s has no valid parent_pivot." % bone_name
				return false
			local_position -= _pivot(pivots, parent_pivot_name)
		var bone := Bone2D.new()
		bone.name = bone_name
		bone.set_autocalculate_length_and_angle(false)
		bone.position = local_position
		parent.add_child(bone)
		bone.rest = bone.transform
		bone.set_length(maxf(local_position.length(), 1.0))
		bone.set_bone_angle(local_position.angle())
		bones[bone_name] = bone
	return true


func _attach_parts(part_records: Array, pivots: Dictionary, base_dir: String) -> bool:
	for record_value in part_records:
		if not record_value is Dictionary:
			load_error = "Every parts record must be an object."
			return false
		var record: Dictionary = record_value
		var part_name := String(record.get("name", ""))
		var bone_name := String(record.get("parent_bone", ""))
		var pivot_name := String(record.get("pivot", ""))
		var file_name := String(record.get("file", ""))
		if part_name.is_empty() or parts.has(part_name) or not bones.has(bone_name) or not pivots.has(pivot_name) or file_name.is_empty():
			load_error = "Part %s has an invalid name, file, bone, or pivot." % part_name
			return false
		var resource_path := base_dir.path_join(file_name)
		var project_root := ProjectSettings.globalize_path("res://").simplify_path().trim_suffix("/")
		var absolute_part_path := ProjectSettings.globalize_path(resource_path).simplify_path()
		if absolute_part_path != project_root and not absolute_part_path.begins_with(project_root + "/"):
			load_error = "Part %s path must stay inside the project." % part_name
			return false
		var image := Image.new()
		var image_error := image.load(absolute_part_path)
		if image_error != OK or image.get_size() != Vector2i(source_canvas):
			load_error = "Part %s could not load at the manifest source-canvas size." % part_name
			return false
		var sprite := Sprite2D.new()
		sprite.name = part_name
		sprite.texture = ImageTexture.create_from_image(image)
		sprite.centered = true
		sprite.position = source_canvas * 0.5 - _pivot(pivots, pivot_name)
		sprite.z_index = int(record.get("draw_order", 0))
		sprite.z_as_relative = false
		(bones[bone_name] as Bone2D).add_child(sprite)
		parts[part_name] = sprite
	return true


func _pivot(pivots: Dictionary, pivot_name: String) -> Vector2:
	var point: Array = pivots[pivot_name]
	return Vector2(float(point[0]), float(point[1]))


func set_pose(pose_name: String) -> bool:
	if pose_name != "neutral":
		return false
	for bone_value in bones.values():
		(bone_value as Bone2D).rotation = 0.0
	return true
