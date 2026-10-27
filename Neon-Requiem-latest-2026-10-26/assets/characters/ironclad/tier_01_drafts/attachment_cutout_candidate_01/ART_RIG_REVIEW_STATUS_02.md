# IRONCLAD cable art and rig review status

Reviewed 2026-10-25. Candidate-specific lane owner: roster-wide Character Art and Rigging Review. Existing cable cutout and preview were inspected and preserved; no art pixels or runtime files were changed.

## Evidence reviewed

- Approved concept: `docs/visual_qa/IRONCLAD_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Source-backed profile: `../profile_mesh_rig_candidate_01/IRONCLAD_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png`.
- Existing quarantined cutout: `IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01.png`.
- Existing review board: `docs/visual_qa/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01_QUARANTINED.png`.
- Candidate metadata: `parts_manifest.json`; attachment constraints: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

The references show the visible U-shaped power cable loop on the back unit. The current trace retains that visible loop as one separately named source-pixel cutout. Its two connection ends disappear behind the back assembly in the profile view; their hidden continuation and exact socket positions are not visible. The manifest leaves `pivot_source_xy` null. The cable/tether contract requires explicit endpoints.

## Gate

**VISIBLE CABLE CUTOUT REVIEWED; TETHER RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** The image is useful as a static visible segment, but it does not establish both endpoints, hidden cable routing, attachment owners, pivots, flex range, or pose behavior. The broader character input is still one flattened profile without reviewed semantic body layers or authored body pivots. No new cable geometry or Godot pose was created.

Next, an artist must map both cable endpoints to explicit source-backed back-unit sockets and provide the hidden continuation/overlap plan. Then author the two endpoint anchors and review the cable with the back assembly in source-supported poses. Do not infer the endpoints from the cutout tips or treat static source fidelity as tether readiness.

## Roster coordination

This review owns IRONCLAD's back-cable candidate only. The cable PNG, original trace manifest, existing review board, and profile rig files were left unchanged. Shared project records and staging remain deferred while Implementation updates its clean-launch/save-reload status.
