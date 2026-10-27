# CIPHER Tier I editable art preparation

Workspace: `attachment_decomposition_02` version 2.

Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.

- Anatomy/target reference: `docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept reference: `docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Concept is embedded as a hidden layer in this workspace.
- Existing candidate: `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/ and assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/`
- Current candidate status: candidate 01 quarantined; candidate 05 mechanically passes but PREVIEW_SCREEN_FAIL; neither is rig input
- Attachment requirements from the current roster work plan:
  - hood/hair/optic and collar overlap
  - backpack mount
  - rifle as detached hand/back attachment
- Blank attachment layers:
  - hacked rifle with its rigidly mounted optic (single weapon assembly; optic stays aligned to rifle)
  - backpack (separate back-owned accessory)
  - hood (separate head-owned accessory where supported by the source)
  - head-mounted optic/device (separate head-owned item; distinct from the rifle-mounted scope in the approved reference)
  - collar accessory (separate only where its boundary is visible in the approved source)
- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.
- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.
- Side A/B labels and all pivot guides are provisional until checked against the approved views.
- The visible reference is flattened concept/anatomy art, not production sprite parts.
- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.
- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.

## 2026-10-26 user clarification

CIPHER's held concept rifle and vertical side-view item are user-approved as the same prop in different carry states. This resolves identity only; do not treat the existing crop as an approved cutout or infer boundaries, attachment points, coordinates, pivots, or transition behavior.
