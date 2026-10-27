# STITCH Tier I editable art preparation

Workspace: `attachment_decomposition_02` version 2.

Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.

- Anatomy/target reference: `docs/visual_qa/STITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept reference: `docs/visual_qa/STITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Concept is embedded as a hidden layer in this workspace.
- Existing candidate: `assets/characters/stitch/tier_01_drafts/profile_mesh_rig_candidate_01/`
- Current candidate status: quarantined flattened profile mesh; not semantic parts
- Attachment requirements from the current roster work plan:
  - long coat front/back panels
  - medical harness and carried case
  - handheld vial/tool attachment
- Blank attachment layers:
  - long coat front panel (separate cloth part)
  - long coat back panel (separate cloth part)
  - medical harness (separate torso-owned accessory)
  - carried case (separate body attachment)
  - handheld vial (separate hand attachment; any additional tool must be visible in source before authoring)
- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.
- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.
- Side A/B labels and all pivot guides are provisional until checked against the approved views.
- The visible reference is flattened concept/anatomy art, not production sprite parts.
- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.
- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.
- Open questions:
  - The approved views clearly show a handheld vial and a separate carried case. They do not establish a separate handheld tool or its use animation; do not add a tool prop without source support.
