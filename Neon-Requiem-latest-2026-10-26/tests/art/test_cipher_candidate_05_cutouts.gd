extends SceneTree

const CANDIDATE_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/"
const ASSEMBLY_FILE := "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_05_QUARANTINED.png"

var failures := 0


func _initialize() -> void:
	var root_dir := "res://assets/characters/cipher/tier_01_drafts/"
	_check(FileAccess.file_exists(root_dir + ".gdignore"), "Draft root must be excluded from automatic imports.")
	var manifest_path := CANDIDATE_ROOT + "parts_manifest.json"
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	_check(file != null, "Could not read candidate manifest.")
	if file == null:
		quit(1)
		return
	var manifest: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_check(manifest is Dictionary, "Candidate manifest is not a JSON object.")
	if not manifest is Dictionary:
		quit(1)
		return
	_check(manifest.get("status", "").contains("QUARANTINED"), "Candidate must remain quarantined.")
	_check(manifest.get("semantic_review_status", "") == "PREVIEW_SCREEN_FAIL", "Candidate 05 preliminary semantic screen failure must remain recorded.")
	_check(manifest.get("semantic_review_evidence", "") == "docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_05_QUARANTINED.png", "Candidate must retain its review evidence path.")
	_check(manifest.get("production_approved", false) == false, "Candidate must never claim production approval.")
	var parts: Variant = manifest.get("parts", {})
	_check(parts is Dictionary and parts.size() == 10, "Expected ten named profile cutouts.")
	if parts is Dictionary:
		for semantic: String in parts:
			var filename := str(parts[semantic].get("file", ""))
			var image := Image.new()
			var image_path := ProjectSettings.globalize_path(CANDIDATE_ROOT + filename)
			var error := image.load(image_path)
			_check(error == OK, "Godot could not read cutout %s (error %d)." % [semantic, error])
			if error == OK:
				_check(image.get_width() > 0 and image.get_height() > 0, "Cutout has empty dimensions: %s" % semantic)
				_check(image.get_pixel(0, 0).a == 0.0, "Cutout safety corner is not transparent: %s" % semantic)
	var assembly := Image.new()
	var assembly_error := assembly.load(ProjectSettings.globalize_path(CANDIDATE_ROOT + ASSEMBLY_FILE))
	_check(assembly_error == OK, "Godot could not read the neutral assembly.")
	if assembly_error == OK:
		_check(assembly.get_size() == Vector2i(330, 960), "Neutral assembly must preserve the approved profile crop size.")
	if failures == 0:
		print("PASS: Godot reads all ten quarantined candidate-05 PNG parts and the 330x960 neutral assembly; alpha corners and review-only manifest gates are intact.")
		print("LIMIT: this is raw-file intake validation only; semantic labels, hidden anatomy, pivots, and deformation remain unverified. No rig was built.")
		quit(0)
	else:
		push_error("%d candidate-05 intake check(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CIPHER CANDIDATE 05 FAILED: " + message)
