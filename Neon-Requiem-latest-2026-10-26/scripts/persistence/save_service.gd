extends RefCounted
class_name SaveService

const ROSTER_STATE_SERVICE := preload("res://scripts/progression/roster_state_service.gd")
const FORMATION_PREFERENCE_SERVICE := preload("res://scripts/progression/formation_preference_service.gd")
const EVOLUTION_SERVICE := preload("res://scripts/progression/evolution_service.gd")
const SAVE_PATH := "user://neon_requiem_save.json"
const SAVE_VERSION := 2
const MIGRATABLE_SAVE_VERSION := 1
const MAX_PROTOTYPE_WAVE := 125
const TEMP_SUFFIX := ".tmp"
const BACKUP_SUFFIX := ".bak"
const BACKUP_PREVIOUS_SUFFIX := ".bak.prev"
const SAVE_PROTECTED_ERROR := ERR_UNAUTHORIZED


class _DiskFileOps extends RefCounted:
	func file_exists(path: String) -> bool:
		return FileAccess.file_exists(path)


	func open_write(path: String) -> FileAccess:
		return FileAccess.open(path, FileAccess.WRITE)


	func open_error() -> Error:
		return FileAccess.get_open_error()


	func read_text(path: String) -> Dictionary:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return {"ok": false, "error": "Could not open save file (error %d)." % FileAccess.get_open_error()}
		var contents := file.get_as_text()
		var read_error := file.get_error()
		file.close()
		if read_error != OK and read_error != ERR_FILE_EOF:
			return {"ok": false, "error": "Could not read save file (error %d)." % read_error}
		return {"ok": true, "contents": contents}


	func read_bytes(path: String) -> Dictionary:
		if not FileAccess.file_exists(path):
			return {"ok": false, "error": "File does not exist."}
		return {"ok": true, "bytes": FileAccess.get_file_as_bytes(path)}


	func remove_file(path: String) -> Error:
		if not FileAccess.file_exists(path):
			return OK
		return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


	func copy_file(from_path: String, to_path: String) -> Error:
		return DirAccess.copy_absolute(ProjectSettings.globalize_path(from_path), ProjectSettings.globalize_path(to_path))


static func save_game(permanent: Dictionary, run: Dictionary, settings: Dictionary, path: String = SAVE_PATH) -> Error:
	return _save_game_with_file_ops(permanent, run, settings, path, _DiskFileOps.new())


static func save_game_after_confirmed_reset(permanent: Dictionary, run: Dictionary, settings: Dictionary, path: String = SAVE_PATH, confirmed: bool = false) -> Error:
	if not confirmed:
		return SAVE_PROTECTED_ERROR
	return _save_game_with_file_ops(permanent, run, settings, path, _DiskFileOps.new(), true)


static func _save_game_with_file_ops(permanent: Dictionary, run: Dictionary, settings: Dictionary, path: String, file_ops: Object, confirmed_reset: bool = false) -> Error:
	var existing_save_state := _inspect_save_set(path, file_ops)
	var unsupported_sidecars: Array = existing_save_state.get("unsupported_sidecars", [])
	if not confirmed_reset and (bool(existing_save_state.get("blocked", false)) or not unsupported_sidecars.is_empty()):
		return SAVE_PROTECTED_ERROR
	var payload := {
		"save_version": SAVE_VERSION,
		"permanent": permanent,
		"run": run,
		"settings": settings
	}
	if not confirmed_reset:
		payload = _preserve_unknown_fields(existing_save_state.get("preservation_source", {}), payload)
	var payload_text := JSON.stringify(payload, "\t")
	var staged_validation := _parse_and_validate(payload_text)
	if not bool(staged_validation.get("ok", false)):
		return ERR_INVALID_DATA

	var temporary_path := path + TEMP_SUFFIX
	var backup_path := path + BACKUP_SUFFIX
	var backup_stage_path := backup_path + TEMP_SUFFIX
	var backup_previous_path := path + BACKUP_PREVIOUS_SUFFIX
	var backup_previous_stage_path := backup_previous_path + TEMP_SUFFIX
	var file: Object = file_ops.call("open_write", temporary_path)
	if file == null:
		return file_ops.call("open_error")
	file.call("store_string", payload_text)
	file.call("flush")
	var write_error: Error = file.call("get_error")
	file.call("close")
	if write_error != OK:
		file_ops.call("remove_file", temporary_path)
		return write_error

	# Verify the bytes on disk before moving the active save out of the way.
	var temporary_validation := _read_validated_save(temporary_path, file_ops)
	if not _validated_save_matches(temporary_validation, payload):
		file_ops.call("remove_file", temporary_path)
		return ERR_INVALID_DATA

	var reset_quarantine: Dictionary = {}
	var reset_primary_snapshot_path := ""
	var reset_primary_snapshot_hash := ""
	var reset_had_primary: bool = bool(file_ops.call("file_exists", path))
	var primary_bytes_result: Dictionary = {}
	if confirmed_reset:
		if reset_had_primary:
			primary_bytes_result = file_ops.call("read_bytes", path)
			if not bool(primary_bytes_result.get("ok", false)):
				file_ops.call("remove_file", temporary_path)
				return ERR_FILE_CANT_READ
		var quarantine_result := _quarantine_unsupported_sidecars(existing_save_state.get("unsupported_sidecars", []), file_ops)
		if not bool(quarantine_result.get("ok", false)):
			file_ops.call("remove_file", temporary_path)
			return int(quarantine_result.get("error", ERR_CANT_CREATE))
		reset_quarantine = quarantine_result.get("paths", {})
		if reset_had_primary:
			var primary_bytes: PackedByteArray = primary_bytes_result.get("bytes", PackedByteArray())
			reset_primary_snapshot_hash = _sha256_bytes(primary_bytes)
			reset_primary_snapshot_path = "%s.confirmed-reset-rollback-%s" % [path, reset_primary_snapshot_hash]
			if file_ops.call("file_exists", reset_primary_snapshot_path):
				var existing_snapshot: Dictionary = file_ops.call("read_bytes", reset_primary_snapshot_path)
				var existing_snapshot_bytes: PackedByteArray = existing_snapshot.get("bytes", PackedByteArray())
				if not bool(existing_snapshot.get("ok", false)) or existing_snapshot_bytes != primary_bytes or _sha256_bytes(existing_snapshot_bytes) != reset_primary_snapshot_hash:
					file_ops.call("remove_file", temporary_path)
					return ERR_ALREADY_EXISTS
			else:
				var snapshot_copy_error: Error = file_ops.call("copy_file", path, reset_primary_snapshot_path)
				var snapshot_result: Dictionary = file_ops.call("read_bytes", reset_primary_snapshot_path) if snapshot_copy_error == OK else {"ok": false}
				var snapshot_bytes: PackedByteArray = snapshot_result.get("bytes", PackedByteArray())
				if snapshot_copy_error != OK or not bool(snapshot_result.get("ok", false)) or snapshot_bytes != primary_bytes or _sha256_bytes(snapshot_bytes) != reset_primary_snapshot_hash:
					if file_ops.call("file_exists", reset_primary_snapshot_path):
						file_ops.call("remove_file", reset_primary_snapshot_path)
					file_ops.call("remove_file", temporary_path)
					return snapshot_copy_error if snapshot_copy_error != OK else ERR_FILE_CORRUPT

	var primary_exists: bool = file_ops.call("file_exists", path)
	var primary_validation := _read_validated_save(path, file_ops) if primary_exists else {"ok": false}
	if primary_exists and bool(primary_validation.get("ok", false)) and not confirmed_reset:
		# Stage and verify replacements before touching an existing backup. If
		# promotion fails, the older backup remains loadable at .bak.prev.
		for stale_path in [backup_stage_path, backup_previous_stage_path]:
			if file_ops.call("file_exists", stale_path):
				var stale_remove_error: Error = file_ops.call("remove_file", stale_path)
				if stale_remove_error != OK:
					file_ops.call("remove_file", temporary_path)
					return stale_remove_error
		var backup_error: Error = file_ops.call("copy_file", path, backup_stage_path)
		if backup_error != OK:
			file_ops.call("remove_file", backup_stage_path)
			file_ops.call("remove_file", temporary_path)
			return backup_error
		var backup_stage_validation := _read_validated_save(backup_stage_path, file_ops)
		if not _validated_save_matches(backup_stage_validation, primary_validation["data"]):
			file_ops.call("remove_file", backup_stage_path)
			file_ops.call("remove_file", temporary_path)
			return ERR_INVALID_DATA

		# Preserve an existing valid recovery copy before promoting the new one.
		# If replacing .bak fails later, load_game() can recover from .bak.prev.
		var previous_backup_validation := _read_validated_save(backup_path, file_ops) if file_ops.call("file_exists", backup_path) else {"ok": false}
		var has_valid_previous_backup := bool(previous_backup_validation.get("ok", false))
		if has_valid_previous_backup:
			var preserve_error: Error = file_ops.call("copy_file", backup_path, backup_previous_stage_path)
			if preserve_error == OK:
				var previous_stage_validation := _read_validated_save(backup_previous_stage_path, file_ops)
				if not _validated_save_matches(previous_stage_validation, previous_backup_validation["data"]):
					preserve_error = ERR_INVALID_DATA
			if preserve_error == OK and file_ops.call("file_exists", backup_previous_path):
				preserve_error = file_ops.call("remove_file", backup_previous_path)
			if preserve_error == OK:
				preserve_error = file_ops.call("copy_file", backup_previous_stage_path, backup_previous_path)
			if preserve_error == OK:
				var preserved_validation := _read_validated_save(backup_previous_path, file_ops)
				if not _validated_save_matches(preserved_validation, previous_backup_validation["data"]):
					preserve_error = ERR_INVALID_DATA
			file_ops.call("remove_file", backup_previous_stage_path)
			if preserve_error != OK:
				file_ops.call("remove_file", backup_stage_path)
				file_ops.call("remove_file", temporary_path)
				return preserve_error

		if file_ops.call("file_exists", backup_path):
			var remove_backup_error: Error = file_ops.call("remove_file", backup_path)
			if remove_backup_error != OK:
				file_ops.call("remove_file", backup_stage_path)
				file_ops.call("remove_file", temporary_path)
				return remove_backup_error
		backup_error = file_ops.call("copy_file", backup_stage_path, backup_path)
		var promoted_backup_validation := _read_validated_save(backup_path, file_ops) if backup_error == OK else {"ok": false}
		if not _validated_save_matches(promoted_backup_validation, primary_validation["data"]):
			if backup_error == OK:
				backup_error = ERR_INVALID_DATA
			if file_ops.call("file_exists", backup_path):
				file_ops.call("remove_file", backup_path)
			# Keep the verified previous backup sidecar if restoring it fails.
			if has_valid_previous_backup and file_ops.call("file_exists", backup_previous_path):
				var restore_backup_error: Error = file_ops.call("copy_file", backup_previous_path, backup_path)
				if restore_backup_error == OK:
					var restored_backup_validation := _read_validated_save(backup_path, file_ops)
					if not _validated_save_matches(restored_backup_validation, previous_backup_validation["data"]):
						restore_backup_error = ERR_INVALID_DATA
				if restore_backup_error == OK:
					file_ops.call("remove_file", backup_previous_path)
			file_ops.call("remove_file", backup_stage_path)
			file_ops.call("remove_file", temporary_path)
			return backup_error
		file_ops.call("remove_file", backup_stage_path)
		if file_ops.call("file_exists", backup_previous_path):
			file_ops.call("remove_file", backup_previous_path)

	# Windows sandboxed AppData can reject rename operations. Copy the validated
	# staged bytes after preserving a known-good backup, then verify the committed
	# primary and roll back from the backup if the copy or verification fails.
	if file_ops.call("file_exists", path):
		var remove_primary_error: Error = file_ops.call("remove_file", path)
		if remove_primary_error != OK:
			file_ops.call("remove_file", temporary_path)
			if confirmed_reset and reset_had_primary:
				var restore_after_remove_error: Error = _restore_raw_snapshot(reset_primary_snapshot_path, path, reset_primary_snapshot_hash, file_ops)
				if restore_after_remove_error != OK:
					return restore_after_remove_error
				file_ops.call("remove_file", reset_primary_snapshot_path)
			return remove_primary_error
	var commit_error: Error = file_ops.call("copy_file", temporary_path, path)
	if commit_error == OK:
		var committed_validation := _read_validated_save(path, file_ops)
		if not _validated_save_matches(committed_validation, payload):
			commit_error = ERR_INVALID_DATA
	if commit_error != OK:
		var rollback_error: Error = OK
		if confirmed_reset:
			if file_ops.call("file_exists", path):
				rollback_error = file_ops.call("remove_file", path)
			if rollback_error == OK and reset_had_primary:
				rollback_error = _restore_raw_snapshot(reset_primary_snapshot_path, path, reset_primary_snapshot_hash, file_ops)
		elif file_ops.call("file_exists", path):
			rollback_error = file_ops.call("remove_file", path)
		if rollback_error == OK and not confirmed_reset:
			var found_recovery_source := false
			var recovery_error: Error = ERR_FILE_NOT_FOUND
			for recovery_path: String in [backup_path, backup_previous_path]:
				if not file_ops.call("file_exists", recovery_path):
					continue
				found_recovery_source = true
				recovery_error = _restore_verified_save(recovery_path, path, file_ops)
				if recovery_error == OK:
					break
			if found_recovery_source and recovery_error != OK:
				rollback_error = recovery_error
		file_ops.call("remove_file", temporary_path)
		if rollback_error != OK:
			return rollback_error
		if confirmed_reset and reset_had_primary:
			file_ops.call("remove_file", reset_primary_snapshot_path)
		return commit_error
	if confirmed_reset:
		var sidecar_cleanup_error := _remove_quarantined_sidecars(reset_quarantine, file_ops)
		if sidecar_cleanup_error != OK:
			var reset_rollback_error: Error = OK
			for active_path: String in reset_quarantine:
				if file_ops.call("file_exists", active_path):
					continue
				var quarantine_path: String = str(reset_quarantine[active_path])
				var restore_sidecar_error: Error = file_ops.call("copy_file", quarantine_path, active_path)
				if reset_rollback_error == OK and restore_sidecar_error != OK:
					reset_rollback_error = restore_sidecar_error
			var remove_new_primary_error: Error = OK
			if file_ops.call("file_exists", path):
				remove_new_primary_error = file_ops.call("remove_file", path)
			if reset_rollback_error == OK and remove_new_primary_error != OK:
				reset_rollback_error = remove_new_primary_error
			if reset_had_primary:
				var restore_primary_error: Error = _restore_raw_snapshot(reset_primary_snapshot_path, path, reset_primary_snapshot_hash, file_ops)
				if reset_rollback_error == OK and restore_primary_error != OK:
					reset_rollback_error = restore_primary_error
			file_ops.call("remove_file", temporary_path)
			if reset_rollback_error != OK:
				return reset_rollback_error
			if reset_had_primary:
				file_ops.call("remove_file", reset_primary_snapshot_path)
			return sidecar_cleanup_error
		file_ops.call("remove_file", temporary_path)
		if reset_had_primary and file_ops.call("file_exists", reset_primary_snapshot_path):
			file_ops.call("remove_file", reset_primary_snapshot_path)
		return OK
	file_ops.call("remove_file", temporary_path)
	return OK


static func _inspect_save_set(path: String, file_ops: Object) -> Dictionary:
	var any_save_file_exists := false
	var has_unsupported_version := false
	var unsupported_sidecars: Array[String] = []
	var preservation_source: Dictionary = {}
	for candidate_path: String in [path, path + BACKUP_SUFFIX, path + BACKUP_PREVIOUS_SUFFIX]:
		if not bool(file_ops.call("file_exists", candidate_path)):
			continue
		any_save_file_exists = true
		var version_result := _read_save_version(candidate_path, file_ops)
		var validation := _read_validated_save(candidate_path, file_ops)
		var supported_schema := bool(version_result.get("ok", false)) and int(version_result.get("version", -1)) in [SAVE_VERSION, MIGRATABLE_SAVE_VERSION]
		if bool(version_result.get("ok", false)) and not supported_schema:
			has_unsupported_version = true
		if candidate_path != path and (not supported_schema or not bool(validation.get("ok", false))):
			unsupported_sidecars.append(candidate_path)
		if preservation_source.is_empty() and bool(validation.get("ok", false)):
			preservation_source = validation["data"].duplicate(true)
	if has_unsupported_version:
		return {"blocked": true, "reason": "unsupported_version", "preservation_source": preservation_source, "unsupported_sidecars": unsupported_sidecars}
	if any_save_file_exists and preservation_source.is_empty():
		return {"blocked": true, "reason": "no_valid_save", "preservation_source": {}, "unsupported_sidecars": unsupported_sidecars}
	return {"blocked": false, "preservation_source": preservation_source, "unsupported_sidecars": unsupported_sidecars}


static func _quarantine_unsupported_sidecars(sidecar_paths: Array, file_ops: Object) -> Dictionary:
	var quarantined: Dictionary = {}
	for sidecar_path_value in sidecar_paths:
		var sidecar_path := str(sidecar_path_value)
		var source_result: Dictionary = file_ops.call("read_bytes", sidecar_path)
		if not bool(source_result.get("ok", false)):
			return {"ok": false, "error": ERR_FILE_CANT_READ}
		var source_bytes: PackedByteArray = source_result.get("bytes", PackedByteArray())
		var digest := _sha256_bytes(source_bytes)
		var quarantine_path := "%s.unsupported-quarantine-%s" % [sidecar_path, digest]
		if file_ops.call("file_exists", quarantine_path):
			var existing_result: Dictionary = file_ops.call("read_bytes", quarantine_path)
			if not bool(existing_result.get("ok", false)) or existing_result.get("bytes", PackedByteArray()) != source_bytes or _sha256_bytes(existing_result.get("bytes", PackedByteArray())) != digest:
				return {"ok": false, "error": ERR_ALREADY_EXISTS}
		else:
			var copy_error: Error = file_ops.call("copy_file", sidecar_path, quarantine_path)
			if copy_error != OK:
				return {"ok": false, "error": copy_error}
			var copied_result: Dictionary = file_ops.call("read_bytes", quarantine_path)
			var copied_bytes: PackedByteArray = copied_result.get("bytes", PackedByteArray())
			if not bool(copied_result.get("ok", false)) or copied_bytes != source_bytes or _sha256_bytes(copied_bytes) != digest:
				file_ops.call("remove_file", quarantine_path)
				return {"ok": false, "error": ERR_FILE_CORRUPT}
		quarantined[sidecar_path] = quarantine_path
	return {"ok": true, "paths": quarantined}


static func _remove_quarantined_sidecars(quarantined: Dictionary, file_ops: Object) -> Error:
	for active_path: String in quarantined:
		var remove_error: Error = file_ops.call("remove_file", active_path)
		if remove_error != OK:
			return remove_error
	return OK


static func _restore_raw_snapshot(snapshot_path: String, target_path: String, expected_hash: String, file_ops: Object) -> Error:
	if not file_ops.call("file_exists", snapshot_path):
		return ERR_FILE_NOT_FOUND
	var snapshot_result: Dictionary = file_ops.call("read_bytes", snapshot_path)
	var snapshot_bytes: PackedByteArray = snapshot_result.get("bytes", PackedByteArray())
	if not bool(snapshot_result.get("ok", false)) or _sha256_bytes(snapshot_bytes) != expected_hash:
		return ERR_FILE_CORRUPT
	if file_ops.call("file_exists", target_path):
		var remove_error: Error = file_ops.call("remove_file", target_path)
		if remove_error != OK:
			return remove_error
	var copy_error: Error = file_ops.call("copy_file", snapshot_path, target_path)
	if copy_error != OK:
		return copy_error
	var restored_result: Dictionary = file_ops.call("read_bytes", target_path)
	var restored_bytes: PackedByteArray = restored_result.get("bytes", PackedByteArray())
	if not bool(restored_result.get("ok", false)) or restored_bytes != snapshot_bytes or _sha256_bytes(restored_bytes) != expected_hash:
		return ERR_FILE_CORRUPT
	return OK


static func _sha256_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	context.update(bytes)
	return context.finish().hex_encode()


static func _read_save_version(path: String, file_ops: Object) -> Dictionary:
	var read_result: Dictionary = file_ops.call("read_text", path)
	if not bool(read_result.get("ok", false)):
		return {"ok": false}
	var parser := JSON.new()
	if parser.parse(str(read_result.get("contents", ""))) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false}
	var version: Variant = parser.data.get("save_version", null)
	if not _is_integer(version):
		return {"ok": false}
	return {"ok": true, "version": int(version)}


static func _preserve_unknown_fields(source: Dictionary, destination: Dictionary, path: String = "") -> Dictionary:
	var merged := destination.duplicate(true)
	var known_fields := _known_fields_for_path(path)
	for key in source:
		if not merged.has(key):
			if not known_fields.has(str(key)):
				merged[key] = source[key].duplicate(true) if typeof(source[key]) in [TYPE_DICTIONARY, TYPE_ARRAY] else source[key]
			continue
		if typeof(source[key]) == TYPE_DICTIONARY and typeof(merged[key]) == TYPE_DICTIONARY:
			merged[key] = _preserve_unknown_fields(source[key], merged[key], _child_path(path, str(key)))
	return merged


static func _known_fields_for_path(path: String) -> Array[String]:
	if path == "run.recruits" or path.begins_with("run.recruits."):
		return ["level", "hp"]
	match path:
		"": return ["save_version", "permanent", "run", "settings"]
		"permanent": return ["lifetime_influence", "spendable_influence", "highest_wave_ever", "research", "research_nodes", "evolution", "evolution_materials", "first_clear_material_claims", "unlocks", "formation_preferences"]
		"run": return ["credits", "wave", "highest_cleared_wave", "offline_claim_unix", "recruits", "squad_hp", "active_lineup", "legacy_placeholder_squad_hp"]
		"settings": return ["master_volume", "window_mode"]
		_: return []

static func _child_path(parent: String, child: String) -> String:
	return child if parent.is_empty() else parent + "." + child


static func load_game(path: String = SAVE_PATH) -> Dictionary:
	return _load_game_with_file_ops(path, _DiskFileOps.new())


static func _load_game_with_file_ops(path: String, file_ops: Object) -> Dictionary:
	if not file_ops.call("file_exists", path):
		var backup_path := path + BACKUP_SUFFIX
		if file_ops.call("file_exists", backup_path):
			var backup_result := _read_validated_save(backup_path, file_ops)
			if bool(backup_result.get("ok", false)):
				backup_result["recovered_from_backup"] = true
				backup_result["warning"] = "The primary save was missing; loaded the previous valid save."
				return _migrate_loaded_v1_save(backup_result, path, file_ops, true)
		var previous_backup_path := path + BACKUP_PREVIOUS_SUFFIX
		if file_ops.call("file_exists", previous_backup_path):
			var previous_backup_result := _read_validated_save(previous_backup_path, file_ops)
			if bool(previous_backup_result.get("ok", false)):
				previous_backup_result["recovered_from_backup"] = true
				previous_backup_result["warning"] = "The primary save was missing; loaded the older recovery save."
				return _migrate_loaded_v1_save(previous_backup_result, path, file_ops, true)
		return {"ok": false, "error": "No valid save file exists."}

	var result := _read_validated_save(path, file_ops)
	if bool(result.get("ok", false)):
		return _migrate_loaded_v1_save(result, path, file_ops)

	# A crash between rotating the primary save and committing the staged save
	# can leave only the prior save in the backup sidecar.
	var backup_path := path + BACKUP_SUFFIX
	if file_ops.call("file_exists", backup_path):
		var backup_result := _read_validated_save(backup_path, file_ops)
		if bool(backup_result.get("ok", false)):
			backup_result["recovered_from_backup"] = true
			backup_result["warning"] = "The primary save was invalid; loaded the previous valid save."
			return _migrate_loaded_v1_save(backup_result, path, file_ops, true)
	var previous_backup_path := path + BACKUP_PREVIOUS_SUFFIX
	if file_ops.call("file_exists", previous_backup_path):
		var previous_backup_result := _read_validated_save(previous_backup_path, file_ops)
		if bool(previous_backup_result.get("ok", false)):
			previous_backup_result["recovered_from_backup"] = true
			previous_backup_result["warning"] = "The primary save and current backup were invalid; loaded the older recovery save."
			return _migrate_loaded_v1_save(previous_backup_result, path, file_ops, true)
	return result


static func _migrate_loaded_v1_save(load_result: Dictionary, path: String, file_ops: Object, recovered: bool = false) -> Dictionary:
	var data: Dictionary = load_result.get("data", {})
	if int(data.get("save_version", 0)) != MIGRATABLE_SAVE_VERSION:
		return _normalize_evolution_labels_in_result(load_result)
	var candidate := data.duplicate(true)
	candidate["permanent"] = _canonicalize_evolution_tier_labels(candidate.get("permanent", {}))
	var run_result := ROSTER_STATE_SERVICE.migrate_legacy_slot_hp(candidate.get("run", {}))
	if not bool(run_result.get("ok", false)):
		return {"ok": false, "error": "Version-1 roster migration was rejected; the original save remains untouched.", "details": run_result.get("error", "Invalid legacy HP.")}
	candidate["run"] = run_result["run"]
	candidate["save_version"] = SAVE_VERSION
	var validation := _parse_and_validate(JSON.stringify(candidate))
	if not bool(validation.get("ok", false)):
		return {"ok": false, "error": "Version-1 roster migration failed validation; the original save remains untouched.", "details": validation.get("error", "Invalid migrated save.")}
	if not recovered:
		var commit_error: Error = _save_game_with_file_ops(candidate["permanent"], candidate["run"], candidate["settings"], path, file_ops)
		if commit_error != OK:
			return {"ok": false, "error": "Version-1 roster migration could not be committed; the original save remains authoritative.", "save_error": commit_error}
	var migrated_result := {"ok": true, "data": candidate, "migrated_from_version": MIGRATABLE_SAVE_VERSION}
	for field in ["recovered_from_backup", "warning"]:
		if load_result.has(field):
			migrated_result[field] = load_result[field]
	return migrated_result


static func _normalize_evolution_labels_in_result(load_result: Dictionary) -> Dictionary:
	if not bool(load_result.get("ok", false)) or typeof(load_result.get("data", null)) != TYPE_DICTIONARY:
		return load_result
	var data: Dictionary = load_result["data"]
	var permanent := _canonicalize_evolution_tier_labels(data.get("permanent", {}))
	if permanent == data.get("permanent", {}):
		return load_result
	var normalized := load_result.duplicate(true)
	var normalized_data: Dictionary = data.duplicate(true)
	normalized_data["permanent"] = permanent
	normalized["data"] = normalized_data
	normalized["evolution_labels_migrated"] = true
	return normalized


static func _canonicalize_evolution_tier_labels(permanent_value: Variant) -> Dictionary:
	if typeof(permanent_value) != TYPE_DICTIONARY:
		return {}
	var permanent: Dictionary = permanent_value.duplicate(true)
	var evolution_value: Variant = permanent.get("evolution", {})
	if typeof(evolution_value) != TYPE_DICTIONARY:
		return permanent
	var evolution: Dictionary = evolution_value.duplicate(true)
	for key in evolution.keys():
		if typeof(evolution[key]) == TYPE_STRING:
			evolution[key] = EVOLUTION_SERVICE.canonical_tier_label(evolution[key])
	permanent["evolution"] = evolution
	return permanent


static func _read_validated_save(path: String, file_ops: Object) -> Dictionary:
	var read_result: Dictionary = file_ops.call("read_text", path)
	if not bool(read_result.get("ok", false)):
		return {"ok": false, "error": str(read_result.get("error", "Could not read save file."))}
	return _parse_and_validate(str(read_result.get("contents", "")))


static func _restore_verified_save(source_path: String, destination_path: String, file_ops: Object) -> Error:
	var source_validation := _read_validated_save(source_path, file_ops)
	if not bool(source_validation.get("ok", false)):
		return ERR_INVALID_DATA
	var copy_error: Error = file_ops.call("copy_file", source_path, destination_path)
	if copy_error != OK:
		if file_ops.call("file_exists", destination_path):
			file_ops.call("remove_file", destination_path)
		return copy_error
	var restored_validation := _read_validated_save(destination_path, file_ops)
	if not _validated_save_matches(restored_validation, source_validation["data"]):
		if file_ops.call("file_exists", destination_path):
			file_ops.call("remove_file", destination_path)
		return ERR_INVALID_DATA
	return OK


static func _validated_save_matches(validation: Dictionary, expected: Dictionary) -> bool:
	return bool(validation.get("ok", false)) and _values_match(validation.get("data", {}), expected)


static func _values_match(actual: Variant, expected: Variant) -> bool:
	var actual_type := typeof(actual)
	var expected_type := typeof(expected)
	if actual_type in [TYPE_INT, TYPE_FLOAT] and expected_type in [TYPE_INT, TYPE_FLOAT]:
		return float(actual) == float(expected)
	if actual_type != expected_type:
		return false
	if actual_type == TYPE_DICTIONARY:
		if actual.size() != expected.size():
			return false
		for key in actual:
			if not expected.has(key) or not _values_match(actual[key], expected[key]):
				return false
		return true
	if actual_type == TYPE_ARRAY:
		if actual.size() != expected.size():
			return false
		for index in range(actual.size()):
			if not _values_match(actual[index], expected[index]):
				return false
		return true
	return actual == expected


static func _parse_and_validate(contents: String) -> Dictionary:
	var parser := JSON.new()
	var parse_error := parser.parse(contents)
	if parse_error != OK:
		return {
			"ok": false,
			"error": "Malformed save JSON at line %d: %s" % [parser.get_error_line(), parser.get_error_message()]
		}
	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Save file is not a JSON object."}
	if not _is_integer(parsed.get("save_version", null)):
		return {"ok": false, "error": "Save version is missing or invalid."}
	var save_version := int(parsed["save_version"])
	if save_version not in [MIGRATABLE_SAVE_VERSION, SAVE_VERSION]:
		return {"ok": false, "error": "Unsupported save version."}
	for section in ["permanent", "run", "settings"]:
		if typeof(parsed.get(section, null)) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Save section is missing or invalid: %s" % section}

	var validation_error := _validate_permanent(parsed["permanent"])
	if not validation_error.is_empty():
		return {"ok": false, "error": validation_error}
	validation_error = _validate_run(parsed["run"])
	if not validation_error.is_empty():
		return {"ok": false, "error": validation_error}
	if save_version == MIGRATABLE_SAVE_VERSION and (parsed["run"].has("active_lineup") or parsed["run"].has("legacy_placeholder_squad_hp")):
		return {"ok": false, "error": "Version-1 save contains unsupported roster fields."}
	if parsed["run"].has("active_lineup"):
		var lineup_error := _validate_active_lineup(parsed["run"], parsed["permanent"])
		if not lineup_error.is_empty():
			return {"ok": false, "error": lineup_error}
	validation_error = _validate_settings(parsed["settings"])
	if not validation_error.is_empty():
		return {"ok": false, "error": validation_error}
	return {"ok": true, "data": parsed}


static func _validate_permanent(permanent: Dictionary) -> String:
	if permanent.has("lifetime_influence") and not _is_nonnegative_integer(permanent["lifetime_influence"]):
		return "Permanent lifetime_influence must be a non-negative integer."
	if permanent.has("spendable_influence") and not _is_nonnegative_integer(permanent["spendable_influence"]):
		return "Permanent spendable_influence must be a non-negative integer."
	if permanent.has("highest_wave_ever") and (not _is_nonnegative_integer(permanent["highest_wave_ever"]) or float(permanent["highest_wave_ever"]) > MAX_PROTOTYPE_WAVE):
		return "Permanent highest_wave_ever must be a non-negative integer within the current prototype wave cap."
	if permanent.has("research") and typeof(permanent["research"]) != TYPE_DICTIONARY:
		return "Permanent research must be an object."
	if permanent.has("research_nodes"):
		if typeof(permanent["research_nodes"]) != TYPE_DICTIONARY:
			return "Permanent research_nodes must be an object."
		for node_id in permanent["research_nodes"]:
			if typeof(node_id) != TYPE_STRING or str(node_id).strip_edges().is_empty() or str(node_id).strip_edges() != str(node_id) or not _is_nonnegative_integer(permanent["research_nodes"][node_id]):
				return "Permanent research node IDs and ranks must be canonical strings and non-negative integers."
	if permanent.has("evolution") and typeof(permanent["evolution"]) != TYPE_DICTIONARY:
		return "Permanent evolution must be an object."
	if permanent.has("evolution_materials"):
		if typeof(permanent["evolution_materials"]) != TYPE_DICTIONARY:
			return "Permanent evolution_materials must be an object."
		for material_id in permanent["evolution_materials"]:
			if typeof(material_id) != TYPE_STRING or str(material_id).strip_edges().is_empty() or str(material_id).strip_edges() != str(material_id) or not _is_nonnegative_integer(permanent["evolution_materials"][material_id]):
				return "Permanent evolution material IDs must be canonical strings with non-negative integer counts."
	if permanent.has("first_clear_material_claims"):
		var claims: Variant = permanent["first_clear_material_claims"]
		if typeof(claims) != TYPE_ARRAY:
			return "Permanent first_clear_material_claims must be an array."
		var seen_claims: Dictionary = {}
		for claim_id in claims:
			if typeof(claim_id) != TYPE_STRING or str(claim_id).strip_edges().is_empty() or str(claim_id).strip_edges() != str(claim_id) or seen_claims.has(claim_id):
				return "Permanent first-clear claim IDs must be unique non-empty strings."
			seen_claims[claim_id] = true
	if permanent.has("unlocks") and typeof(permanent["unlocks"]) != TYPE_ARRAY:
		return "Permanent unlocks must be an array."
	if permanent.has("formation_preferences"):
		var preference_error := FORMATION_PREFERENCE_SERVICE.validate(permanent["formation_preferences"])
		if not preference_error.is_empty():
			return preference_error
	return ""


static func _validate_run(run: Dictionary) -> String:
	for field in ["credits", "wave", "highest_cleared_wave"]:
		if not run.has(field) or not _is_integer(run[field]):
			return "Run %s must be an integer." % field
	if float(run["credits"]) < 0.0:
		return "Run credits cannot be negative."
	if float(run["wave"]) < 1.0:
		return "Run wave must be at least 1."
	if float(run["wave"]) > MAX_PROTOTYPE_WAVE:
		return "Run wave cannot exceed the current prototype wave cap."
	if float(run["highest_cleared_wave"]) < 0.0:
		return "Run highest_cleared_wave cannot be negative."
	if float(run["highest_cleared_wave"]) > MAX_PROTOTYPE_WAVE:
		return "Run highest_cleared_wave cannot exceed the current prototype wave cap."
	if run.has("offline_claim_unix") and not _is_nonnegative_integer(run["offline_claim_unix"]):
		return "Run offline_claim_unix must be a non-negative integer."
	var recruits: Variant = run.get("recruits", null)
	if typeof(recruits) != TYPE_DICTIONARY:
		return "Run recruits must be an object."
	var breaker: Variant = recruits.get("breaker", null)
	if typeof(breaker) != TYPE_DICTIONARY:
		return "Run recruits.breaker must be an object."
	if not breaker.has("level") or not _is_integer(breaker["level"]) or float(breaker["level"]) < 1.0:
		return "Run recruits.breaker.level must be a positive integer."
	for recruit_id in recruits:
		if typeof(recruits[recruit_id]) != TYPE_DICTIONARY:
			return "Run recruit state must be an object for %s." % str(recruit_id)
		var recruit_state: Dictionary = recruits[recruit_id]
		if recruit_state.has("level") and (not _is_integer(recruit_state["level"]) or float(recruit_state["level"]) < 1.0):
			return "Run recruit level must be a positive integer for %s." % str(recruit_id)
		if recruit_state.has("hp") and not _is_nonnegative_number(recruit_state["hp"]):
			return "Run recruit HP must be a finite non-negative number for %s." % str(recruit_id)
	if run.has("squad_hp"):
		var squad_hp: Variant = run["squad_hp"]
		if typeof(squad_hp) != TYPE_ARRAY or squad_hp.size() != 6:
			return "Run squad_hp must contain six ally health values."
		for ally_hp in squad_hp:
			if (typeof(ally_hp) != TYPE_INT and typeof(ally_hp) != TYPE_FLOAT) or not is_finite(float(ally_hp)) or float(ally_hp) < 0.0:
				return "Run squad_hp values must be finite non-negative numbers."
	if run.has("legacy_placeholder_squad_hp"):
		var legacy_placeholder_hp: Variant = run["legacy_placeholder_squad_hp"]
		if typeof(legacy_placeholder_hp) != TYPE_ARRAY or legacy_placeholder_hp.size() != 5:
			return "Run legacy_placeholder_squad_hp must preserve five legacy values."
		for hp in legacy_placeholder_hp:
			if not _is_nonnegative_number(hp):
				return "Run legacy placeholder HP values must be finite and non-negative."
	if run.has("active_lineup"):
		if typeof(run["active_lineup"]) != TYPE_ARRAY or run["active_lineup"].size() != 6:
			return "Run active_lineup must contain six slots."
		for recruit_id in run["active_lineup"]:
			if typeof(recruit_id) != TYPE_STRING:
				return "Run active_lineup slots must be strings."
	return ""


static func _validate_active_lineup(run: Dictionary, permanent: Dictionary) -> String:
	var owned_value: Variant = permanent.get("unlocks", null)
	if typeof(owned_value) != TYPE_ARRAY:
		return "Run active_lineup requires a permanent unlock list."
	var check := ROSTER_STATE_SERVICE.validate_active_lineup(run["active_lineup"], owned_value)
	return "" if bool(check.get("ok", false)) else str(check.get("error", "Run active_lineup is invalid."))


static func _validate_settings(settings: Dictionary) -> String:
	if settings.has("master_volume"):
		var volume: Variant = settings["master_volume"]
		if typeof(volume) != TYPE_INT and typeof(volume) != TYPE_FLOAT:
			return "Settings master_volume must be a number."
		if float(volume) < 0.0 or float(volume) > 1.0:
			return "Settings master_volume must be between 0 and 1."
	if settings.has("window_mode") and typeof(settings["window_mode"]) != TYPE_STRING:
		return "Settings window_mode must be a string."
	return ""


static func _is_nonnegative_integer(value: Variant) -> bool:
	return _is_integer(value) and float(value) >= 0.0


static func _is_nonnegative_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value)) and float(value) >= 0.0


static func _is_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) != TYPE_FLOAT or not is_finite(value):
		return false
	return value == floor(value)


