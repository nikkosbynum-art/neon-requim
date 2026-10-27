# SPECTER blade art and rig review status

Reviewed 2026-10-25. Candidate-specific lane owner: roster-wide Character Art and Rigging Review. Existing cutouts and review boards were inspected and preserved; no art pixels or runtime files were changed.

## Evidence reviewed

- Approved concept: `docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/SPECTER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing traced cutouts: `SPECTER_T1_BLADE_HILT_VISIBLE_CANDIDATE_01.png` and `SPECTER_T1_BLADE_BODY_VISIBLE_CANDIDATE_01.png`.
- Existing native-scale contact/ownership boards: `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_CONTACT_QUARANTINED.png` and `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_OWNERSHIP_QUARANTINED.png`.
- Existing PolyRig raster-fidelity board: `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_03_QUARANTINED.png`.
- Candidate metadata: `parts_manifest.json`; source-backed blade/sheath ownership contract: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

The trace assigns the exposed upper hilt and lower guard/blade pixels to two visible layers sharing one `specter.blade` attachment role. The glove pixels are excluded as the foreground owner; the grip hidden beneath the glove is not fabricated. The existing ownership board reports zero shared pixels between these two traced masks. The cutout manifest leaves both pivots null. Existing Godot diagnostics check static contour-mesh texture fidelity only.

## Gate

**VISIBLE BLADE CUTOUTS REVIEWED; HELD-WEAPON RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** The source supports the visible weapon in the depicted pose, but it does not expose the grip point or establish an artist-authored grip pivot, a complete hidden grip surface, sheath transition, or other held poses. Mesh triangulation and pixel fidelity do not validate weapon placement or arm/hand attachment. No new Godot pose was created and existing blade outputs were not overwritten.

Next, provide a complete artist-authored grip segment behind the glove (or an explicit rigid-assembly overlap plan), plus a reviewed grip pivot derived from the approved visible grip pose. Resolve any intended sheath presentation as its own source-backed attachment before testing held/stowed transitions. Then build a SPECTER-specific hand/blade assembly preview; keep Null Trace timing/behavior under simulation control.

## Roster coordination

This review owns SPECTER's visible blade candidate only. Both blade PNGs, the original trace manifest, existing contact/ownership/fidelity boards, and the profile rig files were left unchanged. Shared project records and staging remain deferred while Implementation updates its clean-launch/save-reload status.
