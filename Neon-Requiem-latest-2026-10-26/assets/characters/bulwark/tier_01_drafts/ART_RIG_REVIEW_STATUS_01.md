# BULWARK art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No BULWARK artwork, manifests, or runtime scenes were modified in this pass.

## Evidence reviewed

- Approved visual direction: `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy reference: `docs/visual_qa/BULWARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Current flattened mesh input: `profile_mesh_rig_candidate_01/BULWARK_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png`.
- Input and approximate bone metadata: `profile_mesh_rig_candidate_01/parts_manifest.json` and `profile_mesh_rig_candidate_01/rig_manifest.json`.
- Source-backed equipment presentation requirement: `docs/ATTACHMENT_FUNCTION_CONTRACT.md` (rifle follows attack events; medical pack/hoses stay connected; Last Protocol cue follows the heal event).

The concept and anatomy references agree on the visible Tier I identity: armored medic, helmet/visor, rifle, and connected life-support equipment. The references expose multiple views, but they do not supply hidden pixels, authored joints, weapon grip/stow transforms, or hose endpoints.

## Gate

**REVIEWED; MODULAR RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** The existing profile candidate is one flattened raster with approximate landmarks. It has no semantically authored moving parts or artist-authored pivots. Do not treat the existing generic 19-bone preflight as a character-approved deformation preview or production rig. No new Godot weighted preview was built in this pass.

The next admissible art step is a source-preserving, artist-authored semantic layer pass that identifies joint owners and overlap order from the approved views. In particular, rifle ownership/grip and stow pivots, independent armor ownership, and both endpoints/owners for each connected hose need explicit review. Do not infer hidden anatomy or apply CIPHER's knee assumptions to BULWARK. Once those parts and pivots are reviewed, create a character-specific weighted Godot preview and inspect the actual poses before advancing the lane.

## Roster coordination

SPECTER and IRONCLAD remain reserved for the active Implementation pass. No changes were made to their files or to shared project status/index/staging documents.

## 2026-10-25 follow-up: next source-backed step

Inspected the two existing quarantined editable workspaces (`edit_batch_01` and `attachment_decomposition_01`) and their preparation notes. Both remain **EDIT PREP ONLY** with blank semantic layers; neither adds reviewed artwork or pivots. The approved concept and anatomy turnaround provide visible design references, but the flattened profile does not supply hidden surfaces, authored semantic boundaries, or pivots. The rifle grip/stow mounts and hose endpoints still need explicit source-backed ownership/anchor mapping. Next admissible step: an artist authors and reviews named, separate visible parts in the ORA from the approved views, then supplies the grip and hose attachment map. Keep the candidate quarantined and do not start a rig preview from the flat image.

The current project-manager handoff has since released IRONCLAD and SPECTER from the Implementation reservation. Their art candidates still have the individual gates recorded in their own review files.

## 2026-10-25 follow-up: quarantined static candidate

A source-aligned helmet medical-marking panel candidate was added under `medical_cross_cutout_candidate_01/`. Its source-fidelity/mechanical-alpha report passes, but semantic assembly and gameplay-scale readability remain open. It is static detail only; the character remains quarantined with no rig preview or runtime integration. The current manager handoff has released SPECTER and IRONCLAD from the Implementation reservation; their separate art gates remain unchanged.

## 2026-10-26 user clarification — helmet cross backing owner

The user approved that the white backing behind the medical cross belongs to the helmet panel. This settles ownership only. It does not define an additional cutout boundary, how the red marking and backing divide into layers, a side-facing projection, an independent pivot, gameplay readability, or production readiness. Preserve source pixels and the existing front-view evidence; do not project the crop onto the right-facing profile or infer attachment points. Candidate and art remain quarantined.
