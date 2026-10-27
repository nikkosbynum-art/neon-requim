# DEADLOCK art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No DEADLOCK image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved concept: `docs/visual_qa/DEADLOCK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/DEADLOCK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing flat input: `profile_mesh_rig_candidate_01/DEADLOCK_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png` and its manifests.
- Equipment-source warning: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

Both references show a marksman with a held rifle and a long item mounted on the back. They do not establish if these are one weapon in carry/stow states or two separate items. The contract explicitly leaves rifle count and transition unresolved. The body candidate is one flattened raster with approximate landmarks.

## Gate

**REVIEWED; RIG AND RIFLE ATTACHMENT PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** There are no semantic body/weapon layers or authored weapon grip/stow pivots. Building a rifle pose now would silently choose a weapon count and carry state. Do not duplicate or reinterpret the item to match the references. No new Godot preview was built.

Next, reconcile the held/back-mounted rifle relationship with the canonical visual/roster sources, then author the body, weapon, sling/mount ownership, grip/stow pivots, and pose-supported overlaps. Create a rig/attachment preview only after that decision is recorded.

## Roster coordination

The project manager released the SPECTER and IRONCLAD reservation for this review lane. No changes were made to their files or to shared project status/index/staging documents.

## Follow-up accessory boundary review — 2026-10-25

**Antenna cutout trial rejected; candidate is unusable.** A single source-coordinate contour trial for the visible blue-lit backpack antenna retained pale source-background pixels beside the rod and adjacent backpack/strap pixels around the lower socket. The approved profile establishes the visible antenna silhouette, but the flattened source does not provide a clean semantic boundary where the antenna meets the backpack socket. The trial PNG, trace manifest, and QA boards remain on disk as explicitly rejected quarantine evidence because automatic review blocked their deletion under the project rule against removing assets without authorization. Do not use or promote them. No pivot or hidden continuation was inferred.

**Artist input needed:** provide the antenna and upper mount collar as a separately authored transparent layer, or provide a native-resolution marked mask/paintover that identifies the antenna boundary and explicitly assigns the socket seam to the antenna or backpack. Include the approved profile view at source scale. Until then, keep the accessory fused to the source reference; do not use it in a rig or runtime scene.

## 2026-10-26 user clarification — one rifle, two states

The user approved that DEADLOCK has one rifle shown held and back-mounted in different states. This resolves weapon identity/count and carry-state interpretation only; it does not authorize duplicate art, define a cutout boundary, provide grip/stow coordinates or pivots, or approve a transition. The rejected antenna mask remains unusable and all art remains quarantined.
