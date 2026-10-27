# GLITCH Tier I editable art preparation

Workspace: `attachment_decomposition_01` version 1.

Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.

- Anatomy/target reference: `docs/visual_qa/GLITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept reference: `docs/visual_qa/GLITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Concept is embedded as a hidden layer in this workspace.
- Existing candidate: `assets/characters/glitch/tier_01_drafts/profile_mesh_rig_candidate_01/`
- Current candidate status: quarantined flattened profile mesh; not semantic parts
- Attachment requirements from the current roster work plan:
  - large cape as separate back/cloth layers
  - asymmetric cybernetic lower-limb armor
  - sidearm and thigh gear attachments
- Blank attachment layers:
  - cape/cloth panel behind body (one independently moving panel per layer)
  - cybernetic lower-limb armor plate (one layer per owning joint, guided by reference)
  - sidearm (one rigid weapon part; carry/grip mounts are distinct pivots)
  - thigh gear (separate thigh-owned attachment)
- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.
- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.
- Side A/B labels and all pivot guides are provisional until checked against the approved views.
- The visible reference is flattened concept/anatomy art, not production sprite parts.
- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.
- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.
