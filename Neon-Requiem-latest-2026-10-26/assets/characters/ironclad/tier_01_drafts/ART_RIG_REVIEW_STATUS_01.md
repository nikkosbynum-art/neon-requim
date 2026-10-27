# IRONCLAD Tier I art and rig review status

Reviewed 2026-10-25. Scope: existing visible back-unit cable-loop cutout. No art pixels, source manifests, or runtime files were changed in this review.

## Evidence reviewed

- Approved concept: `docs/visual_qa/IRONCLAD_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Registered side-profile input and trace provenance: `profile_mesh_rig_candidate_01/IRONCLAD_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png`, `attachment_cutout_candidate_01/parts_manifest.json`, and `tools/art/ironclad_back_cable_candidate_01.json`.
- Native-scale comparison: `docs/visual_qa/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01_QUARANTINED.png`.
- Existing focused review: `attachment_cutout_candidate_01/ART_RIG_REVIEW_STATUS_02.md`.

The approved profile and turnaround support one visible U-shaped cable loop beside the back unit. I re-inspected the source/detail board and the isolated loop. The cutout retains exactly 781 opaque source pixels with zero RGB mismatches; `audit_semantic_cutout.py` reports one connected component, clean margins, and no external low-alpha halo. These checks support only the completeness and source fidelity of the visible loop segment.

## Gate

**VISIBLE LOOP SEGMENT REVIEWED; TETHER RIG AND PRODUCTION BLOCKED; CANDIDATE REMAINS QUARANTINED.** In the flattened profile, both loop ends disappear at the back-unit edge. The visible image does not identify the actual sockets, endpoint owners, hidden continuation, or flex range. `pivot_source_xy` remains null. Do not treat the square cutout tips as authored pivots or endpoint placements, and do not load this art in runtime.

**Artist input needed:** author or mark the two cable-to-back-unit socket centers and endpoint owners on the approved source canvas; show any hidden continuation and draw-order overlaps explicitly. Provide the cable layer and endpoint map together with a neutral/back-unit assembly. Then author two endpoint anchors and review representative supported poses before a tether rig is considered.

The handheld heavy weapon and powered-armor plates remain separate unreviewed production items. No weapon subtype, grip/stow state, armor pivots, or animation behavior was added here.

## Roster coordination

The project manager released IRONCLAD and SPECTER from the Implementation reservation for this review lane. This status does not change visual canon or promote any art.
