# IRONCLAD Tier I equipment review 01

**Status: QUARANTINED — authoring reference only.** No weapon or armor part has been authored or approved by this review.

## Reference evidence

- Approved concept: `docs/visual_qa/IRONCLAD_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy turnaround: `docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- In both references, the heavy rotary weapon is held in an action pose. The back-mounted power/armor unit is separate from the handheld weapon. The visible armor is distributed across shoulder, elbow, hip, knee, and shin joints.
- The existing profile mesh candidate is a flattened view only; it does not supply semantic armor parts, an independently attachable weapon, or authored pivots.

## Authoring boundaries

- Keep the rotary weapon as one rigid handheld assembly only where the visible reference supports it. Do not add a back-stow socket or a weapon transition; neither is shown or specified.
- Keep the back unit separate and owned by the torso/back anchor. Preserve its visible connection to the armor without inventing cable routes or hidden geometry.
- Keep armor plates owned by their corresponding joints. Confirm each visible plate against the reference before painting; do not infer unseen plate counts or shapes from the broad category labels.
- Weapon grip, exact gameplay-side pose, pivot coordinates, and firing animation are not established by these turnarounds. Mark any review-only inferred placement as provisional and request visual review before export.

## Required review before rig work

Use the blank `IRONCLAD_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` layers. Inspect each authored layer at 100%, then compare the neutral assembly to front/side/back source views. Check weapon ownership, grip, armor seams, and back-unit clearance independently. Only after semantic boundaries and authored pivots are verified should a quarantined Godot pose preview be built. A mesh/alpha pass alone does not approve anatomy, art, or gameplay behavior.

## Visible cable-loop cutout candidate 01 — 2026-10-25

Created `assets/characters/ironclad/tier_01_drafts/attachment_cutout_candidate_01/` with the manually traced visible U-shaped back-unit cable loop from the source-preserving side-profile candidate. The upstream anatomy-turnaround hash and exact profile-crop registration are recorded in `parts_manifest.json`. The cutout keeps source RGB; its 781 nonzero-alpha pixels form one component with bounds `[190, 598, 259, 649)`. Mechanical alpha/margin audit: **PASS**. Checkerboard comparison: `docs/visual_qa/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01_QUARANTINED.png`.

This is a narrow source-pixel trace trial, not a complete cable rig. The two ends meet the back unit in the flattened source and are square in the isolated image; their mounts, pivots, deformation, and behavior remain unverified. The held rotary weapon, back-unit panels, and armor plates have not been authored. Keep the cutout quarantined and do not load it in runtime.
