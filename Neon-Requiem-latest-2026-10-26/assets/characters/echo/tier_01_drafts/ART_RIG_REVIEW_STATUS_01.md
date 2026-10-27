# ECHO art and rig review status

Reviewed 2026-10-25. Character-specific owner for this review lane: current roster-wide Character Art and Rigging Review. No ECHO image, manifest, or runtime scene was modified in this pass.

## Evidence reviewed

- Approved concept: `docs/visual_qa/ECHO_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/ECHO_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing flat input: `profile_mesh_rig_candidate_01/ECHO_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png` and its manifests.
- Drone/decoy source boundary: `docs/ATTACHMENT_FUNCTION_CONTRACT.md` and `docs/CHARACTER_ART_INTAKE_11.md`.

The references show multiple spherical devices on cable tethers and a cybernetic leg. The live roster relationship between sensory drones and Signal Cascade decoys, exact drone count, cable routes/endpoints, and movement are unresolved; the offline roster is reconstructed and cannot settle those gaps. The body candidate is one flattened profile image.

## Gate

**REVIEWED; CHARACTER RIG PREVIEW BLOCKED; CANDIDATE REMAINS QUARANTINED.** No semantic body layers or authored body pivots exist. The visible cable endpoints are insufficient to establish complete deforming tethers, and no source-backed rule resolves drone/decoy ownership or count. Do not set a fixed number, split cables by guess, or reuse another character's joint weights. No new Godot preview was built.

Next, reconcile the drone/decoy count and ownership with the canonical roster when access returns, then author source-backed body, cybernetic-leg, tether, and device layers with explicit endpoint and pivot maps. Only after those gates can a character-specific rig preview be scoped.

## Roster coordination

SPECTER and IRONCLAD remain reserved for the active Implementation pass. No changes were made to their files or to shared project status/index/staging documents.

## 2026-10-25 follow-up: next source-backed step

Inspected `edit_batch_01` and `edit_batch_02` preparation notes and their quarantined OpenRaster workspaces. Both are **EDIT PREP ONLY** with blank semantic layers; no body, drone, decoy, tether, or backpack art/pivots have been authored. The approved concept and anatomy turnaround support visual review, but not the exact drone count or drone/Signal Cascade decoy ownership. The offline reconstructed note suggests two sensory drones while the current local roster work plan leaves count unresolved; live canonical reconciliation is still required before fixing count or mapping gameplay ownership. Next admissible step: reconcile that canonical decision when connector access returns, then have an artist author named body/device/tether layers and explicit tether endpoints from approved source views. Keep the candidate quarantined; no rig preview from the flattened image.

The current project-manager handoff has since released IRONCLAD and SPECTER from the Implementation reservation. Their art candidates still have the individual gates recorded in their own review files.

## 2026-10-25 source-backed review: ECHO visible drone callout

Reviewed the approved concept and anatomy turnaround at native resolution. The ECHO anatomy sheet includes a standalone blue-lens spherical device callout, making this the strongest next static component candidate. A bounded seeded cutout trial was mechanically source-faithful, but visual inspection showed the crop cutting through the lower connector/visible lead. It was discarded; no candidate art is retained. The callout also does not establish whether this visual unit is a sensory drone or a Signal Cascade decoy, or how many units the game uses.

**Artist brief:** Author one complete, isolated blue-lens spherical-device body layer from the approved turnaround, including a finished lower socket/connector boundary. Keep any physical tether on its own layer and show its full route and both endpoints in an approved view. Provide a source-backed attachment pivot at the sphere's cable socket (and a separate tether endpoint map); do not use crop center or infer hidden cable length. Reconcile the canonical sensory-drone versus decoy visual identity/count before assigning a runtime role. The current flattened callout is insufficient to create a complete, unambiguous cutout, so no extraction variant or rig preview should follow until these inputs exist.

## 2026-10-25 bounded cybernetic-leg review

Reviewed the approved concept and anatomy turnarounds together, including the side profile at detail scale. The cybernetic leg is visually identifiable in the front and rear views, but the side-view leg is substantially overlapped by the natural foreground leg and hanging coat panels. The approved views do not establish a complete gameplay-facing silhouette or the boundaries and overlap order for its thigh, knee housing, shin, and ankle/boot sections. The visible knee-side hardware does not supply the concealed joint surfaces or prove which plates move with each segment.

**No leg cutout candidate or rig preview created.** An isolated contour from the oblique front plate or rear hardware would not serve as a complete side-view rig part and would silently choose seams and hidden continuation.

**Artist input needed:** provide a source-scale, gameplay-facing neutral profile of the cybernetic leg with foreground leg and coat panels held clear, plus named transparent layers (or a painted seam map) for the upper-leg section, knee housing/side hinge, shin assembly, ankle, and boot. Mark the actual segment owners, overlaps, and authored knee/ankle pivots; keep any hidden continuation labeled as inferred underpaint. Use this as a quarantined art review only until the component boundaries and pose deformation pass separate approval.
