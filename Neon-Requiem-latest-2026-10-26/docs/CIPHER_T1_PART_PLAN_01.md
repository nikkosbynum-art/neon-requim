# CIPHER Tier I semantic part plan 01

## Updated status after alpha cleanup and pivot smoke test — 2026-10-25 UTC

Candidate 01's original PNG remains unchanged and still fails the original alpha/margin intake. A separate Krita cleanup export now passes the mechanical cutout audit; see `docs/IMPLEMENTATION_STATUS.md` and `docs/ASSET_MANIFEST.md`. A Godot 4.7.2 transform smoke test uses a provisional neck socket at `(760,815)` on the cleaned 1536×1120 canvas and passes five small rotations. This only validates transform math. It does not prove that the pivot is final, the collar seam is acceptable, or the art can deform in a complete body rig.

**Full rigging gate: NOT READY.** The single composite has no separate torso/backpack, jacket/pelvis, arm, leg, or weapon assets. Keep all CIPHER art quarantined until the complete part set has an explicit semantic map, overlap order, and reviewed pivots.

**Status:** Provisional production plan for a quarantined pilot; not canon beyond the approved CIPHER concept and anatomy references. Created 2026-10-25.

## User-approved hand/jacket occlusion interpretation — 2026-10-25 UTC

For candidate 07, the visible near hand is a separate foreground `near_hand` part. The jacket is understood to continue behind it; visible hand pixels should not be owned by `pelvis_belt_gear`. Any jacket pixels needed beneath the hand for articulation are inferred underpaint, not pixels established by the flattened source, and must be labeled accordingly. Maintain the hand-over-jacket draw order. This resolves semantic intent only; it does not create the hidden pixels, pass the full semantic review, or approve the quarantined candidate.

## Candidate 08 — hand ownership and inferred jacket underpaint study — 2026-10-25 UTC

Created `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_08_hand_jacket_underpaint/` from candidate 07 without modifying candidate 07 or the approved references. Candidate 07 already assigns the visible hand exclusively to `near_hand`; a read-only source-alpha check finds zero shared hand pixels with `pelvis_belt_gear` or `torso_jacket`. Candidate 08 preserves those source-derived parts and adds a separate flat-charcoal underpaint at the exact hand silhouette, behind the hand in draw order. The underpaint is labeled inferred because the flattened turnaround occludes that surface; it carries no authored texture or deformation claim. Its neutral pose is fully hidden by the foreground hand.

The candidate includes a neutral assembly and manifest, remains quarantined, and is not rig input. Visual review of the neutral assembly confirms the source silhouette still reads consistently; this does not validate exposed underpaint during motion, final semantic boundaries, pivots, deformation, far-side anatomy, or production readiness. The script `tools/art/build_cipher_candidate_08_hand_jacket_underpaint.py` recreates the candidate from 07 and refuses overwrite.

**User review disposition — accepted for now:** The hand-over-jacket interpretation and conservative underpaint approach work at the expected display scale, where the user expects the fill to be nearly invisible. This is scoped approval of the review approach only. The 1280×720 / 800×450 gameplay-scale capture and motion exposure review have not yet been recorded; candidate 08 remains quarantined and is not production art or rig input.

## Candidate 08 scale and semantic review — 2026-10-25 UTC

Created static isolated scale previews using a 256 px visible-height CIPHER reference: `docs/visual_qa/CIPHER_T1_CANDIDATE_08_ISOLATED_SCALE_1280x720_QUARANTINED.png` and its 800×450 downscale. This is a neutral static composition, not an in-engine capture, motion review, or measured in-combat placement.

The candidate-08 native-scale contact sheet and ownership map are `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_08_QUARANTINED.png` and `CIPHER_T1_PART_OWNERSHIP_MAP_08_QUARANTINED.png`. A read-only source-alpha comparison confirms zero overlap between `near_hand` and either `pelvis_belt_gear` or `torso_jacket`; candidate 07 already had that separation. The narrow rear strip in `torso_jacket` follows the visible jacket rim in the approved side profile and remains with that garment layer.

The user approved an independent `near_knee_guard` part anchored at the knee. The front armor plate/red optic and upper side lug belong to it; the lower round hinge and wrap straps stay with the leg layers. Candidate 09B implements this semantic boundary using source RGB only, and its neutral assembly is pixel-identical to candidate 08. The user approved the traced raster edge after reviewing the source, isolated guard, and reassembled knee board. The user requested and approved inferred trouser underpaint for the flex-exposed gap; the narrow flat fill is isolated in `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_ISOLATED_04_QUARANTINED.png` and shown in the 12°/20° rigid-cutout bend board at `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_BEND_REVIEW_04_QUARANTINED.png`. Approval applies to this labeled quarantined review layer and pose range; it remains excluded from the neutral assembly/runtime and the proxy does not validate production deformation. The user approved the pivot at source pixel `(770, 665)`, aligned to the leg-owned lower hinge; it is authored at part-local pixel `(77, 115)` in `parts_manifest.json`. Review evidence: `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_PIVOT_APPROVED_QUARANTINED.png`. The first candidate-09 attempt is preserved but superseded by `reference_cutout_rig_candidate_09_knee_guard_review_02/`.

## Source of truth

- Approved visual reference: `docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy reference: `docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- In case of drift, follow the approved concept for appearance; use the turnaround to guide visible anatomy and proportions. Neither is a source of hidden pixels or pivots.

## Pilot view and scope

The first part-authoring proof is a right-facing side-view head/neck composite, matching the profile view in the approved anatomy sheet. This is a scoped art-input test only; no 2D rig or runtime scene is implied. Preserve the hood, visible face, long dark hair, red-magenta optic over the visible eye, high dark collar, charcoal materials, and restrained cyan/magenta rim accents. Do not add equipment, new markings, or facial/cyberware details absent from the approved design.

## Semantic part 01: `head_hood_hair_neck`

- One complete head, hood, visible hair, facial/optic assembly, and short neck connection as a single semantic art part.
- Keep the lower neck/collar contact robust enough to overlap the torso collar during small head turns; do not crop the hood, hair tips, optic, chin, or neck edge.
- No torso, shoulders, arms, weapon, backpack, labels, shadows, floor, UI, frame, or neighboring anatomy.
- Transparent background; one centered object, consistent detail scale, full silhouette visible with clear empty margin on all sides.
- This first asset tests whether separate-image generation preserves identity and completeness. It does not establish final pixel scale, pivots, hidden anatomy, or production acceptance.

## Candidate 01 disposition

`assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/CIPHER_T1_HEAD_NECK_CANDIDATE_01_QUARANTINED.png` matches the hood/face/hair/optic identity cues and yields one connected component at alpha threshold 32. It fails the transparent-margin gate: the thresholded component bounds are `(372, 93)–(1165, 949)` on a 1536×1024 canvas, below the planned 15% top/bottom margin; nonzero diffuse magenta/cyan haze extends outside the physical silhouette. A targeted image edit did not remove that halo. Keep this single image and its numbered crop quarantined. Do not rig or use at runtime.

## Remaining planned semantic parts

To be authored and individually reviewed only after the head/neck intake proves workable:

1. torso rear layer/backpack mount;
2. jacket torso and pelvis/belt assembly;
3. near/far upper arms and forearms/hands as separate semantic pieces;
4. near/far thighs and shins/boots as separate pieces;
5. rifle and carried equipment as independent attachments.

Exact splits, side labels, overlaps, and pivots must be confirmed against the references before generating those pieces. Do not turn this list into a submitted character manifest or rig until each part has been reviewed and the full assembly is checked.

## Reference-derived profile rig candidate 01 — 2026-10-25 UTC

The user asked to move this toward a full art rig. A first review candidate now exists under `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/`. It has ten separately named cutouts derived from visible source pixels, a provisional rifle attachment, 60 px transparent margins, and a machine-readable source-bounds manifest. The approved turnaround remains unchanged and out of runtime. The pose sheet is `docs/visual_qa/CIPHER_T1_RIG_POSE_REVIEW_CANDIDATE_01.png`.

This clears the earlier **missing body-part set** blocker for the visible side profile only. It does not clear the full-body production gate: far-side anatomy is not authored; only the `near_knee_guard` pivot has explicit user approval; other pivots and hidden overlap remain unverified; the rifle is a local prototype; and the pose values avoid substantial elbow/knee flex. Keep all parts quarantined.


## Candidate 09B knee review — Godot capture evidence — 2026-10-25 UTC

The user-approved v04 inferred underpaint is visible in Godot Compatibility poses at neutral, 12°, and 20° in docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_GODOT_MOTION_02_QUARANTINED.png. Neutral knee-region reconstruction is exact (0/70,000 differing pixels). This uses rigid Sprite2D transforms and does not establish deformation, skinning, or production readiness; the candidate remains quarantined.
