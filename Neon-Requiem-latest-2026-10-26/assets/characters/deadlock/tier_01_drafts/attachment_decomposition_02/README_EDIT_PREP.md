# DEADLOCK Tier I editable art preparation

Workspace: `attachment_decomposition_02` version 2.

Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.

- Anatomy/target reference: `docs/visual_qa/DEADLOCK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept reference: `docs/visual_qa/DEADLOCK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Concept is embedded as a hidden layer in this workspace.
- Existing candidate: `assets/characters/deadlock/tier_01_drafts/profile_mesh_rig_candidate_01/`
- Current candidate status: quarantined flattened profile mesh; not semantic parts
- Attachment requirements from the current roster work plan:
  - precision rifle as detached hand/back attachment
  - backpack and shoulder straps
  - forearm suppression/cyberware detail
- Blank attachment layers:
  - precision rifle (one authored weapon part; hand/back positions appear across references, but item count and transition are unverified)
  - backpack (separate back-owned accessory)
  - shoulder strap segment (separate when its anchor differs from the backpack)
  - forearm suppression/cyberware detail (separate forearm-owned overlay)
- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.
- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.
- Side A/B labels and all pivot guides are provisional until checked against the approved views.
- The visible reference is flattened concept/anatomy art, not production sprite parts.
- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.
- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.
- Open questions:
  - The approved anatomy views show a long weapon on the back while the concept pose shows a rifle in the hands and another long weapon on the back. The images do not establish whether this is one rifle in different states or two weapons. Do not duplicate weapon art or implement a stow transition until the source is reconciled.

## 2026-10-26 user clarification

DEADLOCK has one rifle shown held and back-mounted in different states by user approval. This resolves identity/count only. Do not duplicate the weapon or infer cutout boundaries, attachment points/coordinates, pivots, or transition behavior.
