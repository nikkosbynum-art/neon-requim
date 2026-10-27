# RECOIL art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No RECOIL image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved concept: `docs/visual_qa/RECOIL_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/RECOIL_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing flat input: `profile_mesh_rig_candidate_01/RECOIL_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png` and its `parts_manifest.json` / `rig_manifest.json`.
- Attachment rules: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

Both approved views show RECOIL's signature powered prosthetic arm. The approved references support the visible prosthetic design, but do not supply independently authored arm segments, hidden joint surfaces, or exact pivots. The current profile candidate is a single flattened raster with approximate landmarks; it does not separate the prosthesis from the body.

## Gate

**REVIEWED; PROSTHETIC DEFORMATION PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** A weighted bend without a reviewed shoulder/upper-arm/elbow/forearm/hand ownership map and authored pivots could distort or detach the signature prosthesis. Do not apply CIPHER's knee weighting or assume a normal human limb chain through the mechanical parts. No new Godot preview was built.

Next, author the visible prosthetic as a source-backed connected joint chain, resolve the body/armor ownership at each mechanical seam, and place pivots from the approved views. Then make a RECOIL-specific arm and grip pose review, including the shotgun presentation contract.

## Roster coordination

SPECTER and IRONCLAD remain reserved for the active Implementation pass. No changes were made to their files or to shared project status/index/staging documents.

## 2026-10-25 source-backed follow-up: RECOIL forearm

Reviewed the approved concept and anatomy turnaround and the local part-authoring guide. The front-view silver forearm casing is the strongest next visible component, but a single contour test included a dark elbow-coupler segment at the upper edge. The approved flattened views do not establish whether that seam belongs to the elbow joint or forearm shroud. Per the bounded intake rule, the ambiguous trial cutout and its preview sheets were discarded; no RECOIL art candidate is retained.

**Artist brief:** Provide a source-aligned part-boundary overlay and editable layers that separate the prosthetic upper arm, elbow coupler/housing, forearm casing, wrist cuff, and mechanical hand. Mark the seam owner at elbow and wrist and provide artist-authored pivots for both joints. Use the approved front/profile/back views; if those do not show a complete casing edge, supply a native-scale close-up of the forearm and elbow from the missing angle. Do not fill hidden surfaces or infer pivots from crop bounds. Resume source cutout only after the elbow-coupler/forearm boundary is visually approved.

The project-manager handoff has released SPECTER and IRONCLAD from the Implementation reservation; their art-specific gates remain recorded in their own reviews.
