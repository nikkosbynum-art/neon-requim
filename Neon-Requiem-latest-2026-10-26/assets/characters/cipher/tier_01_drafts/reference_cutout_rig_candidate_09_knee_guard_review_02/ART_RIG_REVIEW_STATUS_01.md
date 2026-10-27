# CIPHER candidate 09B art and rig review status

Reviewed 2026-10-25. Character-specific owner: current roster-wide Character Art and Rigging Review. Candidate remains quarantined; no runtime files were changed.

## Current evidence

- Approved knee-guard boundary and pivot are recorded in `parts_manifest.json`.
- User feedback: the negative-angle test worked as a diagnostic. This is workflow evidence only; it is not approval of CIPHER's deformation quality, all part boundaries, or production/runtime use.
- Godot `Skeleton2D` / textured `Polygon2D` pilot: `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHTED_DEFORMATION_GODOT_04_QUARANTINED.png`.
- Layered OpenRaster source: `krita_authoring_workspace_09b/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_QUARANTINED.ora`.
- Direct pre-Krita export: `krita_export_09b_PRE_ROUNDTRIP_QUARANTINED/`.

## Gate

**PARTIAL PILOT; KRITA SAVE/REOPEN NOT VERIFIED; CANDIDATE REMAINS QUARANTINED.** The displayed Godot bend uses review-only hip placement and test weights. The export came directly from the OpenRaster workspace; a Krita-saved/reopened file has not been verified. The tool path is usable for diagnostic preview, but this evidence does not promote the art or validate the full rig.

## Roster coordination

This review owns CIPHER 09B only. SPECTER and IRONCLAD remain reserved for the active Implementation pass. No shared status/index/staging document was changed while that pass is active.

## 2026-10-25 bounded Krita round-trip attempt

- Created a fresh quarantined copy at `krita_roundtrip_workspace_09b_01_QUARANTINED/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_01_QUARANTINED.ora`; SHA-256: `A54597C5A486B881CC201CC0AE063FB017F0D26331149F3B3829513DFA91B2B8`.
- Copied the existing selection manifest unchanged. It selects only `near_thigh`, `near_shin`, `near_knee_guard`, and `near_boot`; inferred underpaint is excluded.
- Krita was showing the original 09B ORA. The bounded attempt to open the fresh copy failed: accessibility-index input returned “coordinate input geometry is unavailable”; a screenshot showed the Open control, but after clicking it Krita stopped returning accessibility state (“Accessibility state unavailable for window 2687010”).
- No save, reopen, export, or Godot regeneration occurred. `krita_save_reopen` remains **NOT_VERIFIED**; no art or approved boundaries changed. The fresh copy is retained for a later retry when the Krita UI is responsive.

The current project-manager handoff has since released IRONCLAD and SPECTER from the Implementation reservation. Their art candidates still have the individual gates recorded in their own review files.

## 2026-10-25 disposable-copy and knee-gate follow-up

- Fresh disposable workspace copy: `krita_roundtrip_workspace_09b_02_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_02_DISPOSABLE.ora`; SHA-256 before attempted Krita open: `a54597c5a486b881cc201cc0ae063fb017f0d26331149f3b3829513dfa91b2b8`, identical to the preserved source workspace.
- The Krita Open dialog was accepted, but the active document remained the original `...09B_QUARANTINED.ora`; after a further UI interaction Krita reported Not Responding and stayed there. The disposable ORA was not saved or reopened in Krita. No source or candidate art was edited. **Krita save/reopen remains NOT_VERIFIED.**
- Exported the fresh disposable ORA directly with `tools/art/export_reviewed_openraster_parts.py` into `krita_export_09b_ROUNDTRIP_02_QUARANTINED/`. This is a direct exporter reproduction, not a Krita round-trip. All four selected part PNG hashes matched the existing pre-roundtrip export exactly: `near_boot`, `near_knee_guard`, `near_shin`, and `near_thigh`. The inferred underpaint remained excluded. The output manifest records `production_approved=false` and `runtime_integrated=false`.
- Ran the Godot 09B knee underpaint diagnostic with a real renderer. Neutral knee-region reconstruction differed by 0 of 70,000 pixels; the rigid-cutout motion board rendered successfully at `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_MOTION_03_DISPOSABLE_ORA_QUARANTINED.png`. This checks source alignment and the approved knee pivot, not authored animation or deformation.
- Ran the weighted `Skeleton2D`/textured `Polygon2D` diagnostic against the byte-identical disposable-export textures; its quarantined preview is `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHTED_DEFORMATION_GODOT_05_ROUNDTRIP_02_QUARANTINED.png`. Godot rendered the diagnostic. Hip anchor and test weights are estimates; this does not approve deformations, other part boundaries, production, or runtime use.
- **Gate remains partial.** Krita save/reopen could not be verified, and deformation quality remains a review decision. Candidate stays quarantined; no runtime integration or promotion.

## 2026-10-26 duplicate-only Krita retry and ORA structure check

- Preserved source workspace: `krita_authoring_workspace_09b/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_QUARANTINED.ora`; disposable duplicate: `krita_roundtrip_workspace_09b_03_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_03_DISPOSABLE.ora`. Both are 1,198,184 bytes with identical SHA-256 `A54597C5A486B881CC201CC0AE063FB017F0D26331149F3B3829513DFA91B2B8`.
- **Krita round-trip remains NOT VERIFIED.** On the third duplicate-only attempt, Krita displayed `Not Responding` after opening the file picker and remained unresponsive after a 15-second wait. The duplicate was not saved or reopened in Krita. No before/after pixel, alpha, or part-boundary comparison occurred. The original source ORA was not modified.
- Read-only OpenRaster package inspection found a valid ZIP/CRC with 18 entries: `mimetype`, `stack.xml`, the embedded workspace manifest, 13 referenced layer PNGs, merged preview, and thumbnail. Canvas is 330×960. The embedded layer-name list matches all 13 XML layers and all 11 `ART - <part>` names match the candidate part IDs; each layer PNG header reports 330×960. The approved anatomy reference and inferred underpaint layers are hidden; the four-item export sidecar selects `near_thigh`, `near_shin`, `near_knee_guard`, and `near_boot`, excluding underpaint. This verifies package structure only, not rendered pixels or editability in Krita.
- **Unresolved package provenance discrepancy:** the embedded `source_candidate_manifest_sha256` is `43C735DAA7B57D3F214C818151D3ECB24C1D60B3192EF204B668554DE7E1D9E3`; the current neighboring `parts_manifest.json` hashes to `D717FB49E45C4DE79E88F50CF4F406EE343583E354FCF50F05BF2019D707EA16`. The ORA's internal structure is readable, but its recorded pointer does not match the current external candidate manifest. Neither file was repaired; reconcile the provenance before treating the workspace package as current.
- **Disposition:** all workspaces and exports remain quarantined; no production or runtime approval is implied.

## 2026-10-26 bounded knee angle sweep — Godot 4.7.2 review capture

- Rendered `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHT_MAP_ANGLE_SWEEP_GODOT_08_QUARANTINED.png` with the Compatibility renderer. The 1640×500 board shows -20°, -10°, 0°, +10°, and +20° using the current 44 px test half-band, the approved source pivot `[770,665]`, and the four selected disposable-export parts (`near_thigh`, `near_shin`, `near_knee_guard`, `near_boot`). No underpaint is drawn. Hip placement and weights are estimates; angles are illustrative.
- The actual root viewport stays at the project-configured 1280×720, so the capture helper now renders its board into a dedicated 1640×500 SubViewport. This is a QA-helper change only; no project window settings or runtime scene changed.
- Visual inspection shows the parts deform across the sweep. At the extreme poses, seam-edge distortion is visible but cannot be classified from this test as source-boundary gaps versus interior mesh folds/texture shear. No deformation approval is recorded.
- The capture uses `krita_export_09b_ROUNDTRIP_02_QUARANTINED`, exported directly from the disposable ORA. Krita save/reopen remains **NOT VERIFIED**. The ORA's embedded manifest hash still differs from the current neighboring candidate manifest; earlier manifest bytes remain unavailable. This diagnostic does not resolve provenance, validate a full rig or continuous motion, or authorize production/runtime use. Candidate remains quarantined.

## 2026-10-26 source-manifest provenance follow-up

- Read-only inspection of `tools/art/build_cipher_candidate_09b_knee_authoring_workspace.py` confirms the builder computes `source_candidate_manifest_sha256` directly from the bytes of the neighboring `parts_manifest.json` at build time. The recorded `workspace_batch` is `candidate_09b_knee_roundtrip_pilot`.
- Local file timestamps place the builder at `2026-10-25T23:59:46.694Z`, both byte-identical ORAs at `2026-10-25T23:59:50.679Z`, and the current candidate manifest at `2026-10-26T00:39:03.143Z` (39m 12s after the ORAs). The current manifest and its Google Drive-labeled staging copy are byte-identical at SHA-256 `d717fb49e45c4de79e88f50cf4f406ee343583e354fcf50f05bf2019d707ea16`.
- The ORA embeds `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3`, which does not match the current manifest. No local text record or retained manifest copy containing that hash was found, and this checkout has no Git metadata/history. The later manifest timestamp makes a post-build manifest edit plausible, but without the prior bytes it does **not** prove the embedded hash was the manifest version used to build the ORA.
- **Conclusion: provenance remains unresolved and is still a source blocker.** Do not treat either manifest as authoritative based on this evidence; do not rewrite the ORA pointer or current manifest. Resolve only when a preserved earlier manifest or other contemporaneous source record can be compared against the embedded hash.
- The current CIPHER 09B manifest was not changed. No art, pixels, runtime files, or remote sources changed; all candidate files remain quarantined.

## 2026-10-26 provenance recovery and attachment-decision follow-up

A read-only search of the project and labeled local Notion/Drive staging found no historical `parts_manifest.json` bytes with SHA-256 `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3` and no verifiable snapshot/version record binding those bytes to the ORAs. The four byte-identical 09B ORAs still embed that digest; the current neighboring manifest differs. Do not infer prior contents from timestamps or repair either side. Across the 43 Tier I ORAs under `assets/characters/`, 39 have no usable source pointer/hash. Provenance remains unresolved. The user separately approved CIPHER prop identity across the held concept rifle and vertical side-view item as the same prop in different carry states; that decision supplies no cutout boundary or attachment point. All art remains quarantined.
