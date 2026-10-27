# BREAKER Tier I editable art preparation

Workspace: `attachment_decomposition_01` version 1.

Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.

- Anatomy/target reference: `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png`
- Concept reference: `migration_package/drive_assets/concept_art/04_breaker_production_board.png`
- Concept is NOT embedded because its canvas differs; open the source separately in Krita: `migration_package/drive_assets/concept_art/04_breaker_production_board.png`.
- Existing candidate: `assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v4/ and assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/`
- Current candidate status: isolated review rigs; hidden arm candidate v20 remains quarantined
- Attachment requirements from the current roster work plan:
  - approved external shoulder shell over biological upper arm
  - prosthesis starts at elbow
  - preserve elbow contact and source-matched visible arm boundary
- Blank attachment layers:
  - external right shoulder shell (separate overlay over the biological upper arm)
  - biological right upper arm ending at the elbow boundary
  - mechanical right forearm starting at the elbow
  - signature fist/hand on its wrist-owned part
  - neck neural regulator (separate head/neck-owned accessory)
  - spine/back accessory item (one item per independently moving part, identified from reference)
  - cable (one authored physical route per layer; do not merge separate cables)
- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.
- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.
- Side A/B labels and all pivot guides are provisional until checked against the approved views.
- The visible reference is flattened concept/anatomy art, not production sprite parts.
- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.
- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.
