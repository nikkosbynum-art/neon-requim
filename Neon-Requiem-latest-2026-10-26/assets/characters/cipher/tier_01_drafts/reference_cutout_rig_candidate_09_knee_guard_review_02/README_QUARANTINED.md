# CIPHER Tier I candidate 09B — separate knee guard study

Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. Candidate 08 remains unchanged.

This revision follows the user's approvals to make the visible knee armor a separate `near_knee_guard` part and to place its pivot at the lower hinge. The approved owner split assigns the front armor plate/red optic and upper side lug to the guard; the lower round hinge and wrap straps stay with the leg layers. It reuses source RGB only; the thigh and shin parent masks relinquish the selected region. The approved pivot at source pixel `(770, 665)` is authored as part-local pixel `(77, 115)` and shown in `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_PIVOT_APPROVED_QUARANTINED.png`.

The user approved the exact traced knee-guard boundary after reviewing the source, isolated guard, and reassembled knee board. The user also approved the separate inferred trouser underpaint shown in the isolated patch and 12°/20° rigid-cutout bend comparison. It is recorded in `parts_manifest.json` as an approved review layer, but remains outside the neutral assembly and runtime. The Godot Compatibility renderer captured the source, neutral, 12° and 20° poses in `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_GODOT_MOTION_02_QUARANTINED.png`; the neutral knee crop matched exactly (0/70,000 pixels). This uses rigid `Sprite2D` rotations, not a deforming rig. Other part boundaries, far-side anatomy, and production readiness remain NOT VERIFIED.

The Godot rigid-hinge diagnostic at `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_GUARD_MOTION_07_QUARANTINED.png` verifies exact neutral reconstruction around the approved pivot. Its ±15° rotations are test-only; seam quality, skinning, other pivots, and animation remain unverified.


## Godot approved-underpaint motion capture — 2026-10-25

The approved v04 review layer is shown in the Godot 4.7.2 Compatibility capture docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_GODOT_MOTION_02_QUARANTINED.png at neutral, 12°, and 20° rigid Sprite2D poses. The neutral knee crop matches exactly (0/70,000 differing pixels). This is a rigid cutout proxy, not a deforming/skinned rig. Capture trial 01 remains preserved but is superseded due to rasterization speckle. Candidate remains quarantined and excluded from runtime.


The user also approved the Godot-rendered knee-joint underpaint update shown in the motion-02 capture on 2026-10-25. This approval covers that quarantined review presentation only; it does not approve neutral/runtime integration, deformation, or production readiness.

## Editable-to-Godot pilot — 2026-10-25

The layered OpenRaster workspace is `krita_authoring_workspace_09b/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_QUARANTINED.ora`. Its exported, full-canvas cutouts are in `krita_export_09b_PRE_ROUNDTRIP_QUARANTINED/`; that name is deliberate because a Krita save/reopen has **not** been verified. The exporter read the generated ORA directly. A Godot `Skeleton2D` / textured `Polygon2D` weighted diagnostic at -12° and -20° is shown beside a static exported neutral reference in `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHTED_DEFORMATION_GODOT_04_QUARANTINED.png`; the neutral panel is not a skinned neutral frame. The hip anchor, weights, and sampled mesh are review-only estimates. The pilot validates that the exported cutouts can be skinned and rendered; it does not validate anatomy, deformation quality, neutral runtime assembly, or production readiness. The candidate remains quarantined.
