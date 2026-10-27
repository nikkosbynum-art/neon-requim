extends SceneTree

const PROTOTYPE_SCENE := preload("res://tests/presentation/zone_transition_prototype_01/zone_transition_prototype.tscn")


func _initialize() -> void:
	_run_prototype_check.call_deferred()


func _run_prototype_check() -> void:
	var stage := PROTOTYPE_SCENE.instantiate()
	root.add_child(stage)
	await process_frame
	if stage.camera_a.get("priority") <= stage.camera_b.get("priority"):
		push_error("Initial camera priority should select FramingA.")
		quit(1)
		return
	if stage.transition_started or stage.transition_finished:
		push_error("The isolated prototype should start before a handoff.")
		quit(1)
		return
	stage.begin_presentation_handoff()
	await process_frame
	if stage.camera_b.get("priority") <= stage.camera_a.get("priority"):
		push_error("Handoff should raise FramingB above FramingA.")
		quit(1)
		return
	if stage.environment_director.active_zone_id != "undercity_proto_02":
		push_error("Handoff should select the existing provisional second palette module.")
		quit(1)
		return
	await create_timer(1.45).timeout
	if not stage.transition_finished:
		push_error("Independent backdrop crossfade did not complete.")
		quit(1)
		return
	print("PASS: isolated Phantom Camera priority handoff and existing environment-module crossfade completed.")
	quit(0)
