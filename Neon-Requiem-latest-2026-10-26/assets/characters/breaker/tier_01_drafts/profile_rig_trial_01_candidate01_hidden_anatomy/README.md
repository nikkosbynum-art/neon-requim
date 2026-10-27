# Candidate01 hidden-arm anatomy review — QUARANTINED

Reference: `../BREAKER_T1_profile_rebuild_candidate_01.png` is the approved Tier I appearance target. The live BREAKER specification describes a mostly-human athletic silhouette. The user-approved arm boundary is an external shoulder shell over a biological upper arm, with the mechanical prosthesis beginning at the elbow.

` shell_off_anatomy_study_v1.png` (without the leading space in its filename) is a generated shell-off study from candidate01. `hidden_biological_upper_arm_candidate01_v2.png` is a 21,108-pixel connected skin cutout. `hidden_biological_upper_arm_candidate01_v3_compact72.png` is a narrower 72%-width hypothesis. Both are clipped to a hand-traced upper-arm silhouette. The deterministic builder verifies exact shell-on source reconstruction at alpha threshold 245 and one connected union with the existing mechanical forearm. Godot registration tests attach each underlay behind the original upper-arm part on the shared shoulder bone and sample 206 frames.

These studies are generated/inferred and not final artwork. The visible source part currently combines shoulder shell and skin; this work does not yet create a separate external-shell sprite. The old Trial 01 extracted layers have polygon-mask holes, so shell-off composites rendered from that stack are not valid visual proof. Keep all files out of runtime. Production art remains NOT PASSED pending review, independent shell extraction, authoring cleanup, and full seam/deformation checks.

## Corrected elbow-boundary fit options — 2026-10-25 UTC

The visible arm boundary is approved. Current review files add a more complete anatomy trial: `isolated_upper_arm_generated_fit_study.png` is a generated source study; `candidate01_fitted_underarm_slim_affinefix_v2_review.png` and `candidate01_fitted_underarm_broad_affinefix_v2_review.png` are derived, quarantined hypotheses. `cyber_forearm.png` contains shoulder-shell overlap above the provisional y=495 elbow pivot, so the corrected setup moves that region with the shell and leaves only pixels at/below the pivot on the elbow-driven prosthesis.

The deterministic builder and Godot fit test are documented in the project status/asset manifest. Both widths preserve shell-on pixels and pass 2D continuity and transform-registration checks. Previous fitted donor images/boards from the incorrect nonuniform affine mapping are superseded; use only the `affinefix_v2` boards. Neither underarm width is accepted as production art, and none is referenced by runtime scenes.

Godot 4.7.2 contact validation now measures the transformed donor and elbow-start forearm masks in the actual trial rig for 206 pose samples per width. Both widths retain 8-neighbor contact in every sampled pose (slim minimum 463, broad minimum 800). This supports sampled elbow continuity only; visual style acceptance and continuous all-frame seams remain open.

## Contextual cutaway study — 2026-10-25 UTC

`candidate01_upper_arm_cutaway_study_v1.png` was generated from the approved candidate01 arm crop to illustrate the approved external shoulder shell over biological upper arm, with prosthesis starting at the elbow. It is quarantined and not rig-tested. Manual review rejects it as a proportion/style reference because the revealed upper arm is too bulky and the armor panels differ from the approved profile. Keep it out of runtime and production exports.

## 2026-10-25 follow-up

The approved canon is external shoulder shell over a biological upper arm, with the mechanical prosthesis starting at the elbow. The hidden contour is still an art choice. Latest compact source-texture v4 uses an 84%-width vector silhouette plus 8% same-source texture. Godot passes shell-on fidelity and 206 sampled contact frames (186–374 contact pixels); the full prototype tests pass. Shell-off art review still rejects it as vector-like with visible texture streaks. All underlays and generated trials remain quarantined; no runtime art is approved. See root `docs/BREAKER_T1_HIDDEN_ANATOMY_ART_BRIEF.md` and `docs/visual_qa/BREAKER_T1_underarm_review_options_v4_2026-10-25.png`.

## Constrained painted underlay v7 — 2026-10-25 UTC

`candidate01_upper_arm_constrained_painted_underlay_v7.png` is a quarantined paint study clipped to the compact silhouette. Godot 4.7.2 passes sampled shoulder/elbow contact and exact shell-on layer coverage. OpenGL review at gameplay scale preserves the source appearance; native-scale shell-off review rejects the candidate for a jagged shoulder-wrap fragment and ambiguous join. It is not production art, not a runtime asset, and not approved for upload. The generated isolated-arm follow-up was also rejected and was not copied here. See root `docs/BREAKER_T1_HIDDEN_ANATOMY_ART_BRIEF.md` for gates and limits.

## Source-mask cleanup and torso connection v8–v10 — 2026-10-25 UTC

V8/v9 source pixel reclassification preserved the exact flattened shoulder composite but did not improve the shell-off view. V10 extends the v7 paint study behind the torso; the Python audit confirms 1,410 opaque pixels overlap the torso layer. Godot's focused test includes torso, shell, skin and prosthesis occlusion and passes the candidate with zero shell-on exposure plus sampled elbow contact. At 256 px gameplay height, shell-off reads connected; native detail still shows stretched paint, so v10 remains provisional and quarantined. No runtime reference or production export was added.

### Generated donor fit v12–v15 — quarantined review

- `candidate01_upper_arm_source_edit_v12_shell_on.png`: rejected as a source replacement because the prosthesis and other pixels drift.
- `candidate01_upper_arm_source_edit_v13_shell_off.png`: oversized shell-off anatomy; retained only as donor provenance.
- `candidate01_generated_skin_fitted_underlay_v14.png`: shell-on hidden, but expected-reject elbow contact in defeat (10 px).
- `candidate01_generated_skin_fitted_underlay_v15.png`: tapered fitted donor; zero shell-on exposure and 104–268 elbow-contact pixels across 206 sampled frames. Shell-off axilla/shoulder edge remains unapproved.
- OpenGL review captures are in `docs/visual_qa/BREAKER_T1_candidate01_v15_generated_skin_underlay_*`. Neither underlay is runtime art or production-ready.
