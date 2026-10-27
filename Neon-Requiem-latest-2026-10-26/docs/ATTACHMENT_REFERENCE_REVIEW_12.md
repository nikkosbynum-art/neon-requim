# Attachment reference review — all 12 recruits

**Status:** file-based visual comparison of each approved concept and anatomy turnaround completed 2026-10-25. This confirms visible reference details only; it does not create art or approve part boundaries, hidden anatomy, pivots, or rigging.

## Observations and authoring constraints

| Recruit | Visible evidence in the paired refs | Authoring constraint / open issue |
|---|---|---|
| BULWARK | Rifle, back-mounted medical pack/cylinders, multiple hoses, medical markings | User approved the white cross backing as helmet-panel-owned and a side-facing helmet cross in addition to the front-view cross. Require an artist-authored side view; do not reuse the front crop. Exact boundary, side placement, backing split, pivot, pack/hose details, and rifle carry transition remain open. |
| BREAKER | Tier I profile shows the approved external shoulder shell, biological upper arm, elbow-start prosthesis, neural regulator | Preserve the approved elbow boundary; do not infer extra equipment or use the concept board as sprite parts. |
| CIPHER | Rifle-mounted scope and a separate head-worn optic are both visible; hood and back pack are distinct | User approved the held concept rifle and vertical side-view item as the same prop in different carry states (2026-10-26). This resolves identity only; keep rifle scope with the rifle and head optic on its own head-owned item. Cutout boundaries, authored attachment points/pivots, and transition behavior remain open. |
| SPARK | Three distinct drone identities, a wrench-like hand tool, backpack and visible cable routes | Keep the three source-backed drones independent. Candidate 01's static cutouts pass native-scale checkerboard review and carry provisional pivots on each visible central core; they remain quarantined and not animation/runtime-ready. Tool use is presentation-only unless an approved gameplay effect is added. |
| SPECTER | Blade, hood, face mask, broad continuous cape with a ragged silhouette | Keep one main cape sheet. Do not turn torn edges into separate panels; split only at visible seams/independent cloth parts. Null Trace VFX remain unspecified. |
| IRONCLAD | Heavy rotary weapon shown held, powered back unit, joint armor plates | A back-stowed weapon state is approved as art direction; exact mount, overlap, anchors, pivots, and transition evidence remain open. |
| STITCH | Front/back coat, harness, separate carried case and handheld vial | Keep the vial and case separate. The images do not establish another handheld tool or the vial's use animation. |
| RECOIL | Segmented prosthetic arm and shotgun carried at the side | Keep prosthetic segments separate by joint; preserve the approved side. Verify grip/stow pivots before export. |
| ECHO | Several remote orb units and tether lines are depicted; counts vary across the compositions | Signal Cascade decoys are distinct from physical sensory devices. Do not map/count visible spheres as decoys. Count, view identity, attachment mapping, cable count, and routes remain unresolved. |
| VECTOR | Handheld blade, courier bag/straps, limb details | Keep the blade distinct from the bag; split straps/limb overlays only when their visible owner or movement differs. |
| DEADLOCK | Anatomy views show a long rifle on the back; concept pose shows the rifle held | User approved one rifle shown in held and back-mounted states (2026-10-26). Do not duplicate weapon art; approval does not specify cutout boundaries, grip/stow coordinates, pivots, or transition behavior. |
| GLITCH | Continuous torn cape; one long rifle is shown held/back-mounted | The owner approved one rifle in two carry states, replacing the roster's “sidearm” label. Do not duplicate it; semantic boundaries, mounts, pivots, transition behavior, and provenance remain open. |

## Workspace versions

The source review refined attachment labels for CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, DEADLOCK, and GLITCH. These seven have no-overwrite revision-02 workspaces under `attachment_decomposition_02/`. BULWARK, BREAKER, RECOIL, ECHO, and VECTOR remain on `attachment_decomposition_01/`. Earlier workspaces remain preserved. Each file is blank quarantined preparation and must still be opened/reviewed in Krita before painting.

The per-character layer labels and explicit open questions are in `tools/art/rigging_prep_all_12.json` and the corresponding `README_EDIT_PREP.md`. For gameplay/presentation authority, use `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; these images alone do not define behavior.

## Remaining review gates

- DEADLOCK's one-rifle/two-carry-state and GLITCH's one-rifle/two-carry-state identities are resolved by owner approval; authoring still requires reviewed source-aligned boundaries and authored attachment details. ECHO decoys are distinct from physical sensory devices, but visible spheres are not mapped/countable as decoys without source/owner mapping.
- Visually open the current workspace versions in Krita. Current desktop capture is unavailable; do not claim this review passed a Krita round-trip.
- Paint or extract semantic pieces only after 100% visual ownership, margins, overlap, and pivot review. Keep source-hidden fill labeled inferred.
- Validate the assembled parts and attachments in Godot through idle, walk, attack, hit, defeat, and facing changes. Do not connect attachment presentation to gameplay authority.
