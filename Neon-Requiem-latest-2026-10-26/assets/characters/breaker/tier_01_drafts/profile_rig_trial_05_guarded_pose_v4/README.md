# BREAKER guarded-pose rig trial 05 — candidate 05 / refit v4

**Status: ISOLATED FEASIBILITY DRAFT — NOT APPROVED PRODUCTION ART.**

Source is the flattened `BREAKER_T1_guarded_pose_review_candidate_05.png` (1024×1536). Thirteen manually polygon-masked visible layers were exported on the shared canvas. The polygons receive a 4 px boundary expansion, then layers are clipped to the candidate silhouette. This eliminates visible-source coverage gaps and preserves exact static reconstruction. Each of the thirteen inferred underpaint layers samples nearby RGB along manually chosen axes; this is texture extrapolation, not verified anatomy.

Estimated pivots, layer order, and underpaint are documented in `pivot_manifest.json`. The review scale is 256 px across the measured 1466 px visible height. The isolated preview and tests live in `tests/breaker_profile_rig_trial_05_candidate05_contact_preview.tscn` and the associated `candidate05_contact` scripts.

Validation on Godot 4.7.2: neutral composite exact (0 uncovered silhouette pixels); 13 visible and 13 underpaint images load; selected contact test passes 2472 neighborhoods across 206 poses at 60 Hz (observed 136–315 adjacent contact pixels per neighborhood); walk loop passes alternate knee flexion, ankle compensation, arm counter-swing, loop closure, stable ground anchor, and sampled boot-floor contact. Full project suite and 120-frame main-scene headless launch also passed. Godot reports a sandbox-only failure to write `user://logs/godot.log`. A headless Movie Maker capture was attempted but Godot's dummy renderer returned a null texture and crashed; no movie or walk screenshot was produced.

These checks prove only the named static pixel coverage, node/test setup, selected sampled contacts, and authored clip behavior. They do **not** establish hidden anatomy, all-frame seam continuity, artist-accurate pivots, or final canon. No runtime reference was added.
