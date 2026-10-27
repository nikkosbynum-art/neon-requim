# BULWARK Tier I editable art preparation

Workspace: `attachment_decomposition_01` version 1.

Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.

- Anatomy/target reference: `docs/visual_qa/BULWARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept reference: `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Concept is embedded as a hidden layer in this workspace.
- Existing candidate: `assets/characters/bulwark/tier_01_drafts/profile_mesh_rig_candidate_01/`
- Current candidate status: quarantined flattened profile mesh; not semantic parts
- Attachment requirements from the current roster work plan:
  - medical backpack and hose connections
  - shoulder and torso medical insignia
  - carried rifle; attachment ownership/pivot unresolved
- Blank attachment layers:
  - medical backpack (one torso/back-owned part)
  - medical hose or cable (one authored physical route per layer; count and routing follow source review)
  - primary rifle (one rigid weapon part; hand/back mounts are separate pivots, not duplicated weapon art)
  - medical insignia (separate overlay)
  - life-support equipment other than the backpack (separate item layers; identify each from the reference)
- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.
- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.
- Side A/B labels and all pivot guides are provisional until checked against the approved views.
- The visible reference is flattened concept/anatomy art, not production sprite parts.
- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.
- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.

## 2026-10-26 user clarification

The white backing behind BULWARK's helmet medical cross is user-approved as helmet-panel-owned. This resolves ownership only; do not infer a cutout/layer boundary, profile projection, pivot, or new attachment point. Preserve the existing candidate quarantine.
