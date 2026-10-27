# GLITCH art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No GLITCH image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved concept: `docs/visual_qa/GLITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/GLITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing flat input: `profile_mesh_rig_candidate_01/GLITCH_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png` and its manifests.
- Equipment-source warning: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

The approved views show a cyberpsycho with long trailing cape panels, cybernetic limb armor, and a long weapon-like object held/back-mounted. The roster equipment contract says sidearm and explicitly flags that the images appear to show a blade-like held object plus a back-mounted long item. The source does not resolve their ownership or carry state. The body input is one flattened raster.

## Gate

**REVIEWED; WEAPON/CAPE RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** There are no semantic limb/cape/weapon layers or authored pivots/tether anchors. A preview would silently choose between conflicting weapon evidence and invent cloth ownership/deformation. Do not reshape the objects to force agreement or apply CIPHER's weighting assumptions. No new Godot preview was built.

Next, reconcile the sidearm-versus-depicted-weapon conflict against canonical sources. Then author separate cape panels with explicit anchors, source-supported limb ownership, and the resolved weapon/grip/sheath parts and pivots before creating a character-specific preview.

## Roster coordination

The project manager released the SPECTER and IRONCLAD reservation for this review lane. No changes were made to their files or to shared project status/index/staging documents.

## Follow-up hip-equipment boundary review — 2026-10-25

**No cutout candidate created.** In the approved front anatomy view, the magenta-lit image-left hip object sits inside or directly against a larger dark holster/pouch assembly. The image does not identify whether the cylinder is a separate item, part of a holstered weapon, or integrated housing; its boundary and moving owner are therefore unresolved. The right-side hip assembly is not a reliable duplicate for labeling it. The existing equipment contract also leaves the depicted weapon identity unresolved, so this review does not call either object a vial, sidearm, or magazine.

**Artist input needed:** provide a source-scale, labeled transparent-layer pass for each hip assembly that separates any independently moving item from its holder, names each part by approved roster/equipment identity, and shows the complete visible item boundary. Include a close-up or alternate view where straps or the holder obscure the seam, and mark the holder's owning body region if it moves with a joint. Until that exists, keep the hip objects fused to the approved reference and out of rig/runtime art.
