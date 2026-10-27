# SPARK art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No SPARK image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved visual direction: `docs/visual_qa/SPARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy reference: `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Flattened body input: `profile_mesh_rig_candidate_01/SPARK_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png`.
- Three separate front-facing drone cutout candidates: `attachment_cutout_candidate_01/`.
- Provisional authored drone pivots: `attachment_cutout_candidate_01/attachment_pivots_review_01.json` and `docs/visual_qa/SPARK_DRONE_CANDIDATE_01_PIVOT_REVIEW_01_QUARANTINED.png`.
- Roster contract: exactly three attack-drone identities; side-view gameplay orientation, transforms, paths, firing behavior, and formation are not established by the source.

The approved views support three visually distinct drone designs. The separate cutouts preserve those visible front-view pixels, and the source-fidelity/mesh-fidelity diagnostics exist. The pivot coordinates are author-placed candidates, not user-approved rig pivots. The game presentation is side-view, while each drone reference is front-facing.

## Gate

**REVIEWED; BODY DEFORMATION PREVIEW BLOCKED; CANDIDATES REMAIN QUARANTINED.** The existing body input is one flattened image with approximate landmarks and no semantic layers or artist-authored body pivots. The drone candidates have separate ownership and provisional core pivots, but source views do not support side-view orientation, rotor articulation, flight/formation, or movement. Do not use CIPHER's knee setup or infer drone behavior from a whole-sprite rotation. No new weighted Godot preview was built in this pass.

Next, review/author the body semantic layers and pivots from the approved views. Separately obtain an owner decision on the three drone pivot candidates and a source-backed plan for presenting the front-view drone art in the side-view game. Only then make a narrowly scoped Godot review capture; keep flight paths and combat effects unresolved until their source contract supports them.

## Roster coordination

SPECTER and IRONCLAD remain reserved for the active Implementation pass. No changes were made to their files or to shared project status/index/staging documents.
