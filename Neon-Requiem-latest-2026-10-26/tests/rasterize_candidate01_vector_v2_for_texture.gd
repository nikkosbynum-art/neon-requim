extends SceneTree

const SVG := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_vector_underlay_v2.svg"
const OUT := "res://assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_vector_base_v2.png"

func _initialize() -> void:
	var svg := FileAccess.get_file_as_string(SVG)
	var image := Image.new()
	var err := image.load_svg_from_string(svg, 1.0)
	if err != OK:
		push_error("Could not rasterize vector v2: %s" % error_string(err))
		quit(1)
		return
	err = image.save_png(ProjectSettings.globalize_path(OUT))
	if err != OK:
		push_error("Could not save rasterized vector v2: %s" % error_string(err))
		quit(1)
		return
	print("PASS: rasterized vector v2 at %s" % OUT)
	quit(0)
