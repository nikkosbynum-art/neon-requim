extends SceneTree

## Cross-process persistence check against a disposable user:// subdirectory.
## The wrapper runs this in a project copy with a unique application name, so the
## real Neon Requiem user-data directory and default save are never addressed.

const SAVE_SCRIPT := preload("res://scripts/persistence/save_service.gd")
const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROBE_ROOT := "user://isolated_save_probe"
const PERMANENT := {
	"lifetime_influence": 41,
	"spendable_influence": 7,
	"highest_wave_ever": 25,
	"research": {"combat_protocols": 2},
	"evolution_materials": {"evolution_data": 3},
	"first_clear_material_claims": ["district.undercity"],
	"evolution": {"breaker_tier": "Origin Form"},
	"unlocks": ["breaker"],
}
const RUN := {
	"credits": 0,
	"wave": 14,
	"highest_cleared_wave": 13,
	"recruits": {"breaker": {"level": 2}},
	"squad_hp": [109.0, 70.0, 70.0, 70.0, 64.0, 55.0],
}
const SETTINGS := {"master_volume": 0.65, "window_mode": "windowed"}
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[0] in ["write", "read"]:
		_fail("Usage: -- write|read <unique-id>")
		quit(2)
		return
	var probe_id := _safe_id(args[1])
	if failures > 0:
		quit(2)
		return
	var probe_dir := "%s/%s" % [PROBE_ROOT, probe_id]
	var save_path := "%s/save.json" % probe_dir
	if args[0] == "write":
		_write_probe(probe_dir, save_path)
	else:
		_read_probe(probe_dir, save_path)
	quit(1 if failures > 0 else 0)


func _write_probe(probe_dir: String, save_path: String) -> void:
	var absolute_dir := ProjectSettings.globalize_path(probe_dir)
	if DirAccess.dir_exists_absolute(absolute_dir) or _has_probe_file(save_path):
		_fail("Refusing to overwrite an existing isolated probe directory or save.")
		return
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mkdir_error != OK:
		_fail("Could not create isolated user:// test directory (error %d)." % mkdir_error)
		return
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	main.save_path = save_path
	main.loaded_save_path = ""
	main.permanent_state = PERMANENT.duplicate(true)
	main.settings_state = SETTINGS.duplicate(true)
	main.director.set_lifetime_influence(int(PERMANENT["lifetime_influence"]))
	main.director.load_run_state({"credits": 20, "wave": 14, "highest_cleared_wave": 13, "recruits": {"breaker": {"level": 1}}, "squad_hp": [100.0, 91.0, 82.0, 73.0, 64.0, 55.0]})
	main._refresh()
	var upgrade_button := _find_button(main, "Upgrade x1")
	if upgrade_button == null:
		_fail("Main scene did not expose the x1 upgrade button.")
		main.queue_free()
		return
	upgrade_button.pressed.emit()
	if main.director.economy.recruit_level != 2 or main.director.economy.credits != 0 or not is_equal_approx(float(main.director.allies[0]["hp"]), 109.0):
		_fail("The real x1 HUD upgrade did not commit its expected level, credits, and HP.")
		main.queue_free()
		return
	var loaded := SAVE_SCRIPT.load_game(save_path)
	if not bool(loaded.get("ok", false)) or not _matches_probe_payload(loaded.get("data", {})):
		print("PROBE_READBACK=", str(loaded.get("data", {})))
		_fail("Same-process readback differed before cross-process verification, or the purchase did not stamp its offline baseline.")
		main.queue_free()
		return
	print("ISOLATED_USER_DATA_DIR=", OS.get_user_data_dir())
	print("ISOLATED_SAVE=", ProjectSettings.globalize_path(save_path))
	print("PASS: real x1 HUD upgrade committed and validated; writer process complete.")
	main.queue_free()


func _read_probe(probe_dir: String, save_path: String) -> void:
	if not FileAccess.file_exists(save_path):
		_fail("Fresh Godot process could not find the isolated user:// save.")
	else:
		var loaded := SAVE_SCRIPT.load_game(save_path)
		if not bool(loaded.get("ok", false)):
			_fail("Fresh process could not load the isolated save: %s" % str(loaded.get("error", "unknown error")))
		elif not _matches_probe_payload(loaded.get("data", {})):
			_fail("Fresh process restored state that differs from the isolated save payload.")
		else:
			print("ISOLATED_USER_DATA_DIR=", OS.get_user_data_dir())
			print("PASS: fresh Godot process restored permanent progression, x1-upgraded run, squad HP, and settings.")
	_cleanup_probe(probe_dir, save_path)


func _matches_probe_payload(payload: Variant) -> bool:
	if typeof(payload) != TYPE_DICTIONARY:
		return false
	var permanent: Dictionary = payload.get("permanent", {})
	var run: Dictionary = payload.get("run", {})
	var settings: Dictionary = payload.get("settings", {})
	if int(payload.get("save_version", -1)) != SAVE_SCRIPT.SAVE_VERSION:
		return false
	for key in PERMANENT:
		if not permanent.has(key) or not SAVE_SCRIPT._values_match(permanent[key], PERMANENT[key]):
			return false
	if int(run.get("credits", -1)) != 0 or int(run.get("wave", -1)) != 14 or int(run.get("highest_cleared_wave", -1)) != 13:
		return false
	if not SAVE_SCRIPT._values_match(run.get("recruits", {}), RUN["recruits"]) or not SAVE_SCRIPT._values_match(run.get("squad_hp", []), RUN["squad_hp"]):
		return false
	if int(run.get("offline_claim_unix", 0)) <= 0:
		return false
	for key in SETTINGS:
		if not settings.has(key) or not SAVE_SCRIPT._values_match(settings[key], SETTINGS[key]):
			return false
	return true


func _safe_id(value: String) -> String:
	if value.is_empty():
		_fail("Probe ID must not be empty.")
		return "invalid"
	for character in value:
		if not character.is_valid_identifier() and not (character.length() == 1 and character >= "0" and character <= "9"):
			_fail("Probe ID may contain only letters, digits, and underscores.")
			return "invalid"
	return value


func _find_button(node: Node, label: String) -> Button:
	if node is Button and (node as Button).text == label:
		return node as Button
	for child in node.get_children():
		var match_button := _find_button(child, label)
		if match_button != null:
			return match_button
	return null


func _has_probe_file(save_path: String) -> bool:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		if FileAccess.file_exists(save_path + suffix):
			return true
	return false


func _cleanup_probe(probe_dir: String, save_path: String) -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".bak.prev", ".bak.prev.tmp"]:
		var absolute_file := ProjectSettings.globalize_path(save_path + suffix)
		if FileAccess.file_exists(absolute_file):
			var remove_error := DirAccess.remove_absolute(absolute_file)
			if remove_error != OK:
				_fail("Could not remove the disposable probe file (error %d)." % remove_error)
	var absolute_dir := ProjectSettings.globalize_path(probe_dir)
	if DirAccess.dir_exists_absolute(absolute_dir):
		var remove_dir_error := DirAccess.remove_absolute(absolute_dir)
		if remove_dir_error != OK:
			_fail("Could not remove the isolated disposable probe directory (error %d)." % remove_dir_error)


func _fail(message: String) -> void:
	failures += 1
	push_error("ISOLATED SAVE PROBE FAILED: " + message)
