# Tier I OpenRaster source provenance audit 01

**Reviewed:** 2026-10-26 UTC  
**Scope:** All `.ora` workspaces under `assets/characters/` (43 files across 12 Tier I characters). Read-only archive and embedded JSON inspection.  
**Disposition:** No ORA or manifest was edited. All artwork remains quarantined.

## Results

| Classification | Count | Meaning |
|---|---:|---|
| Mismatch | 4 | All four CIPHER 09B files embed the same digest, which differs from the current referenced `parts_manifest.json`. The four files have identical bytes; this is one provenance discrepancy copied three times, not four independent source states. |
| Unverifiable | 39 | No embedded source-manifest digest or usable source-manifest path exists to compare. Some legacy CIPHER workspaces have a neighboring manifest, but the ORA does not record a digest/reference to it. |
| Match | 0 | No ORA contains a verifiable matching source-manifest digest. |

All 43 ORA ZIP CRC checks passed. Embedded JSON metadata was present in 37 files; the remaining six older CIPHER authoring ORAs had no embedded JSON manifest. The ordinary filesystem modification times are not embedded provenance attestations.

### Mismatch — CIPHER 09B

All four following ORAs have identical bytes (SHA-256 `a54597c5a486b881cc201cc0ae063fb017f0d26331149f3b3829513dfa91b2b8`), embed `source_candidate_manifest_sha256` `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3`, and reference the CIPHER 09B candidate folder. The current neighboring `parts_manifest.json` hashes to `d717fb49e45c4de79e88f50cf4f406ee343583e354fcf50f05bf2019d707ea16`. The preserved ORA timestamp is `2026-10-25T23:59:50.679Z`; the current manifest timestamp is `2026-10-26T00:39:03.143Z`. The current manifest may have changed after workspace creation, but no earlier manifest bytes are available to prove that the embedded digest belonged to that prior version. The mismatch remains unresolved; neither artifact is assigned authority. Full provenance notes are in the [CIPHER candidate review status](../assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/ART_RIG_REVIEW_STATUS_01.md).

- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_authoring_workspace_09b/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_01_QUARANTINED/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_01_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_02_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_02_DISPOSABLE.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_03_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_03_DISPOSABLE.ora`

### Unverifiable — no embedded source pointer/hash

For every file below, inspection found no source-manifest hash or source-manifest path in the ORA metadata. The ORA's presence beside a candidate or a current manifest elsewhere in the tree does not establish that it was built from that manifest.

| Character | ORA workspaces |
|---|---|
| BREAKER | `assets/characters/breaker/tier_01_drafts/attachment_decomposition_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/breaker/tier_01_drafts/edit_batch_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| BULWARK | `assets/characters/bulwark/tier_01_drafts/attachment_decomposition_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/bulwark/tier_01_drafts/edit_batch_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| CIPHER | `assets/characters/cipher/tier_01_drafts/attachment_decomposition_01/CIPHER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/attachment_decomposition_02/CIPHER_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/edit_batch_01/CIPHER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/krita_authoring_workspace_01/CIPHER_T1_PART_AUTHORING_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_03/krita_authoring_workspace_03/CIPHER_T1_PART_AUTHORING_WORKSPACE_03_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04/krita_authoring_workspace_04/CIPHER_T1_PART_AUTHORING_WORKSPACE_04_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/krita_authoring_workspace_05/CIPHER_T1_PART_AUTHORING_WORKSPACE_05_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/CIPHER_T1_PART_AUTHORING_WORKSPACE_06_QUARANTINED.ora`; `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07/CIPHER_T1_PART_AUTHORING_WORKSPACE_07_QUARANTINED.ora` |
| DEADLOCK | `assets/characters/deadlock/tier_01_drafts/attachment_decomposition_01/DEADLOCK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/deadlock/tier_01_drafts/attachment_decomposition_02/DEADLOCK_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/deadlock/tier_01_drafts/edit_batch_01/DEADLOCK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| ECHO | `assets/characters/echo/tier_01_drafts/attachment_decomposition_01/ECHO_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/echo/tier_01_drafts/edit_batch_01/ECHO_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/echo/tier_01_drafts/edit_batch_02/ECHO_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` |
| GLITCH | `assets/characters/glitch/tier_01_drafts/attachment_decomposition_01/GLITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/glitch/tier_01_drafts/attachment_decomposition_02/GLITCH_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/glitch/tier_01_drafts/edit_batch_01/GLITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| IRONCLAD | `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_01/IRONCLAD_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_02/IRONCLAD_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_02/IRONCLAD_T1_ART_EDIT_WORKSPACE_02_REVIEW_01_QUARANTINED.ora`; `assets/characters/ironclad/tier_01_drafts/edit_batch_01/IRONCLAD_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| RECOIL | `assets/characters/recoil/tier_01_drafts/attachment_decomposition_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/recoil/tier_01_drafts/edit_batch_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| SPARK | `assets/characters/spark/tier_01_drafts/attachment_decomposition_01/SPARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/spark/tier_01_drafts/attachment_decomposition_02/SPARK_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/spark/tier_01_drafts/edit_batch_01/SPARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| SPECTER | `assets/characters/specter/tier_01_drafts/attachment_decomposition_01/SPECTER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/specter/tier_01_drafts/attachment_decomposition_02/SPECTER_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/specter/tier_01_drafts/edit_batch_01/SPECTER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| STITCH | `assets/characters/stitch/tier_01_drafts/attachment_decomposition_01/STITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/stitch/tier_01_drafts/attachment_decomposition_02/STITCH_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`; `assets/characters/stitch/tier_01_drafts/edit_batch_01/STITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |
| VECTOR | `assets/characters/vector/tier_01_drafts/attachment_decomposition_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`; `assets/characters/vector/tier_01_drafts/edit_batch_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` |

The six CIPHER candidate workspaces under candidate directories 01 and 03–07 each have a current adjacent `parts_manifest.json`, but none embeds a digest or path to tie that ORA to the current manifest. Their classification therefore remains **unverifiable**, not match. The other no-pointer workspaces have no candidate `parts_manifest.json` in their workspace directory/parent chain to compare.

## Method and limits

- Enumerated every `.ora` below `assets/characters/`; inspected archive CRCs and JSON metadata entries without extracting or changing image content.
- Compared only explicit source-manifest hash fields against the referenced/current neighboring manifest. A filename, directory, workspace batch label, or file timestamp is not treated as a provenance link.
- No manifest was repaired, no authority inferred, no art pixels inspected or changed, no runtime files changed, no tests run, and no remote source read/write/upload performed.
- Reconcile these findings with canonical art/source records during the grouped sync at `docs/REMOTE_SYNC_QUEUE.md`.
