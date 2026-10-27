# BREAKER Tier I modular parts trial 01

**Status: quarantined visual trial; not production-ready and not used by runtime.**

This folder contains twelve user-approved, individually generated 1254×1254 RGBA component previews. Their pixels and alpha channels are preserved as supplied. They are exploratory art inputs, not confirmed final anatomy or tested production exports.

`pivot_manifest.json` records each source file's alpha bounds at threshold `alpha > 32`, an estimated pivot point, a short readiness note, and the isolated review-scene reference. The pivot points and per-part scales are visual estimates; no authored pivots or common native scale were supplied. A strict 8 px fully transparent border is missing from most images because faint nonzero alpha reaches an image edge.

## Review result — 2026-10-24

- The figure fits the 256 px foot-to-hair target and the visual ground root remains fixed.
- The first 2× fit review showed disconnected seams. Estimated pivots and local offsets were adjusted to overlap the neighboring parts at the head/torso, waist/hips, shoulders/elbows, wrist, knees, and ankles.
- Latest 2× neutral, walk, punch, and hit captures were visually inspected. The local joint-contact checks pass, but comparison with the approved Trial 03 model and Tier I concept boards shows a clear pose/silhouette/part mismatch. **Reference fidelity: FAILED.** The open natural hand, claw-like cyber fingers, extended arm pose, and hip/leg assembly do not match the approved brawler model.
- Idle, walk, punch, and hit tracks ran in the Godot harness. Current checks verify loading, intended pivot motion, 12 representative joint alpha contacts, and both boot-to-ground contacts. All passed in the four sampled poses; a failed check now returns a nonzero process exit. The alpha test samples a small neighborhood at each join, so continuous seam integrity/deformation and production animation readiness remain unverified.
- The components were generated independently, their native scales and poses vary, and some joints combine multiple anatomy (including the forearm/hand and cyber arm). The estimated preview transforms are not approved rig data; detailed seam cleanup and authored pivots remain future art work.
- A proportion pass widened the isolated preview body, raised the waist/hip line, lengthened the lower legs, and enlarged the cyber arm/fist while keeping target height and ground anchor. The user reports the result still looks very different from the reference; further transforms will not fix mismatched source anatomy/pose. See `docs/visual_qa/breaker_reference_fidelity_comparison_01.png`. The existing proportion study is concept-only, opaque-background, and not runtime art.
- The files are excluded from runtime scanning by the parent `tier_01_drafts/.gdignore`; the preview harness reads the preserved PNGs directly from disk.

Harness: `res://tests/breaker_parts_trial_01_preview.tscn`  
Current 2× preview captures: `docs/visual_qa/breaker_modular_parts_trial_01_{neutral,walk,punch,hit}_zoom.png`; enlarged neutral crop for visual review: `docs/visual_qa/breaker_modular_parts_trial_01_full_body_detail.png`  
Approved specification: `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md`
