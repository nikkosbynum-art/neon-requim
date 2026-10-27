# VECTOR art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No VECTOR image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved concept: `docs/visual_qa/VECTOR_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/VECTOR_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing flat input: `profile_mesh_rig_candidate_01/VECTOR_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png` and its manifests.
- Attachment rules: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

The references support the blade-skirmisher silhouette, a short blade, and long red scarf/tail shapes. The blade grip and sheath state, scarf attachment/continuation under occlusion, and exact cloth ownership during movement are not established as separate artwork by the flattened images. The current profile candidate is a single raster with approximate landmarks.

## Gate

**REVIEWED; CLOTH/WEAPON RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** There are no semantic body/cloth/weapon layers or artist-authored pivots. A weighted preview could fold the long scarf into the body or detach the blade without validating its actual owner and endpoints. Do not borrow other characters' deformation assumptions or invent a dash pose from the signature ability name. No new Godot preview was built.

Next, author the scarf panels as separate source-backed cloth pieces with reviewed anchors, plus a distinct blade and grip/sheath pivot. Then review neutral, movement, attack, hit, defeat, and facing poses against the authored action sources before any rig preview.

## Roster coordination

The project manager released the SPECTER and IRONCLAD reservation for this review lane. No changes were made to their files or to shared project status/index/staging documents.

## 2026-10-25 bounded profile knee-plate review

Created one source-coordinate trial for the visibly gray knee armor plate in the approved right-facing profile. Its opaque pixels preserve the source RGB exactly; the mechanical alpha audit passed (one connected component, clean margin). The source-ownership board reports no overlap with other declared parts, but it cannot evaluate the semantic edge against the flattened source.

**Semantic boundary review failed; candidate is rejected and remains quarantined.** The detail comparison shows adjacent dark pants/leg pixels attached around the plate, especially along its side and lower contour. No pivot, bone owner, hidden underpaint, or deformation behavior was assigned. No second extraction variant was created. The cutout, trace manifest, and visual boards remain available as explicitly rejected evidence; do not use or promote them.

**Artist input needed:** provide a native-scale transparent layer for the profile-facing knee plate, or a painted source overlay that marks the exact plate edge against the dark trouser/leg shell and identifies which piece owns the surrounding black rim. Also mark whether the plate follows a single knee owner or spans the thigh/shin seam. Author the pivot and any flex-exposed underpaint separately; these are not established by this cutout review.
