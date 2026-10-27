extends SceneTree

const SCENE_PATH := "res://tests/breaker_profile_rig_trial_07_candidate07_canon_preview.tscn"
const STAGE_SCRIPT := preload("res://tests/breaker_profile_trial_07_candidate07_canon_action_stage.gd")
const OUTPUT_DIR := "res://docs/visual_qa"
const PANELS := [
    {"pose": "neutral", "time": 0.0, "bone": "Torso"},
    {"pose": "walk", "time": 0.1625, "bone": "LeftKnee"},
    {"pose": "punch", "time": 0.22, "bone": "CyberShoulder"},
    {"pose": "hit", "time": 0.08, "bone": "Torso"},
    {"pose": "defeat", "time": 0.75, "bone": "Torso"}
]
var failures := 0
var rigs: Array[Variant] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(SCENE_PATH) as PackedScene
    _check(packed != null, "Candidate 07 review rig scene must load.")
    if packed == null:
        quit(1)
        return
    var stage := Node2D.new()
    stage.set_script(STAGE_SCRIPT)
    root.add_child(stage)
    for index in range(PANELS.size()):
        var rig: Variant = packed.instantiate()
        rig.draw_review_stage = false
        stage.add_child(rig)
        await process_frame
        _check(rig.load_failures == 0 and rig.loaded_part_count == 13 and rig.loaded_underpaint_count == 13, "Every sampled pose must load all visible and inferred layers.")
        var panel: Dictionary = PANELS[index]
        rig.visual_root.position = Vector2(128.0 + float(index) * 256.0, 612.0)
        var start_anchor: Vector2 = rig.get_anchor_global_position()
        _check(rig.has_pose(str(panel["pose"])) or str(panel["pose"]) == "neutral", "Missing action pose %s." % str(panel["pose"]))
        if str(panel["pose"]) != "neutral":
            rig.play_pose(str(panel["pose"]))
            rig.animation_player.seek(float(panel["time"]), true)
            rig.animation_player.advance(0.0)
            rig.animation_player.pause()
            await process_frame
        var angle: float = rig.get_bone_rotation(str(panel["bone"]))
        _check(is_finite(angle), "%s must have finite pivot transforms." % str(panel["pose"]))
        _check(rig.get_anchor_global_position().distance_to(start_anchor) < 0.001, "%s must preserve its world ground anchor." % str(panel["pose"]))
        print("Candidate 07 action capture %s: %s %.3f rad; ground anchor stable." % [str(panel["pose"]), str(panel["bone"]), angle])
        rigs.append(rig)
    await process_frame
    var image := root.get_texture().get_image() if root.get_texture() != null else null
    _check(image != null and image.get_size() == Vector2i(1280, 720), "Expected 1280×720 display-rendered action sheet.")
    if image != null and not image.is_empty():
        var dir := ProjectSettings.globalize_path(OUTPUT_DIR)
        DirAccess.make_dir_recursive_absolute(dir)
        var path := dir.path_join("BREAKER_T1_candidate_07_canon_actions.png")
        var suffix := 2
        while FileAccess.file_exists(path):
            path = dir.path_join("BREAKER_T1_candidate_07_canon_actions_%02d.png" % suffix)
            suffix += 1
        var error := image.save_png(path)
        _check(error == OK, "Could not save action review sheet (error %d)." % error)
        if error == OK:
            print("Captured candidate 07 action sheet: %s" % path)
    for rig in rigs:
        rig.queue_free()
    stage.queue_free()
    await process_frame
    if failures == 0:
        print("PASS: candidate 07 idle/walk/punch/hit/defeat preview captured; visual result remains review-only and does not verify hidden anatomy.")
        quit(0)
    else:
        push_error("%d candidate 07 action capture check(s) failed." % failures)
        quit(1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error("BREAKER CANDIDATE 07 ACTION CAPTURE FAILED: " + message)
