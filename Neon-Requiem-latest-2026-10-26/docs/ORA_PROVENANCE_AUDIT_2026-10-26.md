# Tier I ORA provenance inventory — 2026-10-26

**Scope:** Read-only inventory of all `.ora` workspaces under `assets/characters/`. This reports embedded metadata/manifests and whole-file hashes only. No artwork was extracted or pixel-inspected. All candidates remain quarantined.

## Findings

| Classification | Count | Result |
|---|---:|---|
| Verifiable source-manifest matches | 0 | No ORA contains a source-manifest pointer/hash that matches its referenced current manifest or a hash in the approved local source index. |
| Source-manifest hash mismatches | 4 | The four CIPHER 09B ORAs below share byte-identical archive content and the same embedded hash; this is one unresolved discrepancy copied four times. |
| Missing usable source pointer/hash | 39 | Thirty-three contain JSON metadata but no source-manifest provenance pointer/hash; six have no embedded JSON manifest. Reference-image paths alone do not bind an ORA to exact source bytes. |

All 43 archives passed ZIP CRC checks. The 24 entries in `TIER_I_APPROVED_VISUAL_SOURCE_INDEX_01.md` (23 approved PNG references and the BREAKER production specification) still match their recorded local SHA-256 values. None of the embedded ORA source-manifest hashes matches an approved-index hash.

### Hash mismatch — CIPHER 09B

All four ORAs embed `source_candidate_manifest_sha256` `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3`. The current neighboring `parts_manifest.json` hashes to `d717fb49e45c4de79e88f50cf4f406ee343583e354fcf50f05bf2019d707ea16`. Each ORA has SHA-256 `a54597c5a486b881cc201cc0ae063fb017f0d26331149f3b3829513dfa91b2b8`.

- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_authoring_workspace_09b/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_01_QUARANTINED/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_01_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_02_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_02_DISPOSABLE.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_03_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_03_DISPOSABLE.ora`

The earlier manifest bytes are unavailable. Timestamps cannot prove whether the embedded hash belonged to a prior version; neither artifact is declared authoritative.

### Missing usable source pointer/hash — 39 ORAs

**BREAKER (2)**

- `assets/characters/breaker/tier_01_drafts/attachment_decomposition_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/breaker/tier_01_drafts/edit_batch_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**BULWARK (2)**

- `assets/characters/bulwark/tier_01_drafts/attachment_decomposition_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/bulwark/tier_01_drafts/edit_batch_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**CIPHER (9)**

- `assets/characters/cipher/tier_01_drafts/attachment_decomposition_01/CIPHER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/attachment_decomposition_02/CIPHER_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/edit_batch_01/CIPHER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/krita_authoring_workspace_01/CIPHER_T1_PART_AUTHORING_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_03/krita_authoring_workspace_03/CIPHER_T1_PART_AUTHORING_WORKSPACE_03_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04/krita_authoring_workspace_04/CIPHER_T1_PART_AUTHORING_WORKSPACE_04_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/krita_authoring_workspace_05/CIPHER_T1_PART_AUTHORING_WORKSPACE_05_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/CIPHER_T1_PART_AUTHORING_WORKSPACE_06_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07/CIPHER_T1_PART_AUTHORING_WORKSPACE_07_QUARANTINED.ora`

**DEADLOCK (3)**

- `assets/characters/deadlock/tier_01_drafts/attachment_decomposition_01/DEADLOCK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/deadlock/tier_01_drafts/attachment_decomposition_02/DEADLOCK_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/deadlock/tier_01_drafts/edit_batch_01/DEADLOCK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**ECHO (3)**

- `assets/characters/echo/tier_01_drafts/attachment_decomposition_01/ECHO_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/echo/tier_01_drafts/edit_batch_01/ECHO_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/echo/tier_01_drafts/edit_batch_02/ECHO_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`

**GLITCH (3)**

- `assets/characters/glitch/tier_01_drafts/attachment_decomposition_01/GLITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/glitch/tier_01_drafts/attachment_decomposition_02/GLITCH_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/glitch/tier_01_drafts/edit_batch_01/GLITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**IRONCLAD (4)**

- `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_01/IRONCLAD_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_02/IRONCLAD_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_02/IRONCLAD_T1_ART_EDIT_WORKSPACE_02_REVIEW_01_QUARANTINED.ora`
- `assets/characters/ironclad/tier_01_drafts/edit_batch_01/IRONCLAD_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**RECOIL (2)**

- `assets/characters/recoil/tier_01_drafts/attachment_decomposition_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/recoil/tier_01_drafts/edit_batch_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**SPARK (3)**

- `assets/characters/spark/tier_01_drafts/attachment_decomposition_01/SPARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/spark/tier_01_drafts/attachment_decomposition_02/SPARK_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/spark/tier_01_drafts/edit_batch_01/SPARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**SPECTER (3)**

- `assets/characters/specter/tier_01_drafts/attachment_decomposition_01/SPECTER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/specter/tier_01_drafts/attachment_decomposition_02/SPECTER_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/specter/tier_01_drafts/edit_batch_01/SPECTER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**STITCH (3)**

- `assets/characters/stitch/tier_01_drafts/attachment_decomposition_01/STITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/stitch/tier_01_drafts/attachment_decomposition_02/STITCH_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora`
- `assets/characters/stitch/tier_01_drafts/edit_batch_01/STITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

**VECTOR (2)**

- `assets/characters/vector/tier_01_drafts/attachment_decomposition_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/vector/tier_01_drafts/edit_batch_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`

### Missing embedded JSON manifest — six of the 39

These CIPHER authoring ORAs contain no JSON manifest. Their XML layer stack does not provide source-manifest provenance.

- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/krita_authoring_workspace_01/CIPHER_T1_PART_AUTHORING_WORKSPACE_01_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_03/krita_authoring_workspace_03/CIPHER_T1_PART_AUTHORING_WORKSPACE_03_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04/krita_authoring_workspace_04/CIPHER_T1_PART_AUTHORING_WORKSPACE_04_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/krita_authoring_workspace_05/CIPHER_T1_PART_AUTHORING_WORKSPACE_05_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/CIPHER_T1_PART_AUTHORING_WORKSPACE_06_QUARANTINED.ora`
- `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07/CIPHER_T1_PART_AUTHORING_WORKSPACE_07_QUARANTINED.ora`

## Method and limits

- Enumerated all `.ora` files under `assets/characters/`, checked ZIP CRCs, read embedded JSON/XML metadata, and computed whole-ORA SHA-256 values. Image payloads were not extracted or inspected.
- Compared explicit embedded source-manifest hashes with the current neighboring manifest where present, and compared embedded hashes/reference metadata with the approved local source index. A path, timestamp, filename, or byte-identical duplicate is not proof of source-version provenance.
- The 39 missing-pointer ORAs remain unverifiable even when their metadata names approved concept/anatomy images or a neighboring candidate manifest. Earlier manifest bytes for CIPHER 09B are unavailable.
- No ORA, artwork, candidate status, or runtime asset was changed. No tests or remote reads/writes/uploads occurred. Reconcile this local evidence against canonical sources during the next grouped remote sync.
