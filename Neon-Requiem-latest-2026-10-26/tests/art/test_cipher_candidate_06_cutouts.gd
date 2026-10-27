extends SceneTree

const CANDIDATE_ROOT := "res://assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/"
const ASSEMBLY_FILE := "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_06_QUARANTINED.png"

var failures := 0


func _initialize() -> void:
	_check(FileAccess.file_exists("res://assets/characters/cipher/tier_01_drafts/.gdignore"), "Draft root must stay excluded from automatic runtime imports.")
	var file := FileAccess.open(CANDIDATE_ROOT + "parts_manifest.json", FileAccess.READ)
	_check(file != null, "Could not read candidate-06 manifest.")
	if file == null:
		quit(1)
		return
	var manifest: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_check(manifest is Dictionary, "Candidate-06 manifest is not a JSON object.")
	if not manifest is Dictionary:
		quit(1)
		return
	_check(str(manifest.get("status", "")).contains("QUARANTINED"), "Candidate must remain quarantined.")
	_check(manifest.get("semantic_review_status", "") == "NOT_VERIFIED", "Candidate 06 semantic review must remain unverified.")
	_check(manifest.get("production_approved", true) == false, "Candidate must never claim production approval.")
	var parts: Variant = manifest.get("parts", {})
	_check(parts is Dictionary and parts.size() == 10, "Expected ten named profile cutouts.")
	if parts is Dictionary:
		for semantic: String in parts:
			var filename := str(parts[semantic].get("file", ""))
			var image := Image.new()
			var error := image.load(ProjectSettings.globalize_path(CANDIDATE_ROOT + filename))
			_check(error == OK, "Godot could not read candidate cutout %s (error %d)." % [semantic, error])
			if error == OK:
				_check(image.get_width() > 0 and image.get_height() > 0, "Cutout has empty dimensions: %s" % semantic)
				_check(image.get_pixel(0, 0).a == 0.0, "Cutout safety corner is not transparent: %s" % semantic)
	var assembly := Image.new()
	var assembly_error := assembly.load(ProjectSettings.globalize_path(CANDIDATE_ROOT + ASSEMBLY_FILE))
	_check(assembly_error == OK, "Godot could not read the candidate-06 neutral assembly.")
	if assembly_error == OK:
		_check(assembly.get_size() == Vector2i(330, 960), "Assembly must preserve the approved profile crop size.")
	if failures == 0:
		print("PASS: Godot reads all ten quarantined candidate-06 PNG parts and the 330x960 source-aligned assembly; alpha corners and review-only gates are intact.")
		print("LIMIT: raw-file intake only; the CIPHER parts have no authored pivots, hidden anatomy, deformation, runtime references, or production approval.")
		quit(0)
	else:
		push_error("%d candidate-06 intake check(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("CIPHER CANDIDATE 06 FAILED: " + message)
