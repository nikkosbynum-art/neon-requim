# BREAKER candidate 09 v13 compact shoulder-underlay study

**Quarantined generated hypothesis only.** The generated shell-off image is preserved for audit. The exported donor contains only skin-classified pixels inside the opaque v4 shoulder-shell mask and approved arm ROI. No original visible pixels are replaced.

Python verifies exact thresholded shell-on reconstruction. The shell-off comparison is diagnostic and requires manual art review. Generated/inferred anatomy, pivots, independent shell deformation, continuous animation seams, and production readiness remain unverified. The trial is not referenced by runtime scenes.


## v13 v5 correction study — 2026-10-25

A second generated shell-off study was retained as `shell_off_anatomy_study_v2.png`, with `hidden_biological_upper_arm_donor_v5_full_shell.png` extracted over the complete opaque source shell mask. The new study slightly tightens the contour but the shell-off shoulder remains oversized relative to candidate 09. Exact shell-on reconstruction and Godot 206-sample registration pass. The independent-motion capture is diagnostic only; hidden anatomy remains visually unaccepted and all files remain quarantined. Rebuild with `tools/art/build_breaker_trial09_v13_v5_full_shell_underpaint.py`; the builder refuses overwrite.


## v13 v6 proportion trial — 2026-10-25

An additional 82%-width hypothesis (`hidden_biological_upper_arm_donor_v6_compact_82.png`) was derived from the generated v5 study. It reduces shoulder width but retains generated seams. Python shell-on preservation and Godot pose registration/stress checks pass. It remains quarantined pending review of `docs/visual_qa/BREAKER_T1_v13_shoulder_shape_options.png`; it is not accepted anatomy or runtime art.
