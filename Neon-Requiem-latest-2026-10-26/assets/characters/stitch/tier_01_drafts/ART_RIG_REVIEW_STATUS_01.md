# STITCH art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No STITCH image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved concept: `docs/visual_qa/STITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/STITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing semantic/occlusion analysis: `attachment_decomposition_02/EQUIPMENT_REVIEW_01_QUARANTINED.md`.
- Existing flat input: `profile_mesh_rig_candidate_01/STITCH_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png`.
- Attachment rules: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

The references support the medic/chem identity, coat, carried case, and visible red vial. The local equipment review already identifies hand-hidden grip surfaces, coat overlap/hidden continuation, and back assembly/hose ownership as unresolved. The profile mesh is a single flattened raster.

## Gate

**REVIEWED; RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** The case, vial, coat panels, and back assembly do not have complete reviewed semantic layers or authored attachment/joint pivots. The occluded hand grips and hose endpoints cannot be recovered from the flattened source. Do not invent concealed parts or build a weighted preview from the flat image. No new Godot preview was built.

Next, supply artist-authored complete case/vial layers with grip pivots, a coat ownership/overlap plan, and an assembly/hose endpoint map. Reassess the moving joints from those layers before any character-specific rig capture.

## Roster coordination

SPECTER and IRONCLAD remain reserved for the active Implementation pass. No changes were made to their files or to shared project status/index/staging documents.

## 2026-10-25 follow-up: independent STITCH source review

The approved concept and anatomy turnaround were reviewed for another fully visible semantic component. The held red vial and carried case are recognizable, but hand overlap hides their grip surfaces; the coat and back assembly overlap other equipment. No cutout qualifies without artist-authored complete prop layers and pivots. The existing equipment brief in `attachment_decomposition_02/EQUIPMENT_REVIEW_01_QUARANTINED.md` already names the required missing inputs. No STITCH art was changed.

The current project-manager handoff has released SPECTER and IRONCLAD from the Implementation reservation; their separate art gates remain unchanged.
