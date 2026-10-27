# Attachment decomposition batch — all 12 recruits

**Status:** blank authoring preparation only; quarantined; no production art, rig, or attachment behavior is implemented.

## Current workspaces

Current workspace paths are per-character; five remain on version 01 and seven have a source-reviewed version 02. See [`ATTACHMENT_REFERENCE_REVIEW_12.md`](ATTACHMENT_REFERENCE_REVIEW_12.md) for the split and unresolved visual details.

| Recruit | Workspace | Canvas |
|---|---|---|
| BULWARK | `assets/characters/bulwark/tier_01_drafts/attachment_decomposition_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | 1536×1024 |
| BREAKER | `assets/characters/breaker/tier_01_drafts/attachment_decomposition_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | 1024×1536 |
| CIPHER | `assets/characters/cipher/tier_01_drafts/attachment_decomposition_02/CIPHER_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |
| SPARK | `assets/characters/spark/tier_01_drafts/attachment_decomposition_02/SPARK_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |
| SPECTER | `assets/characters/specter/tier_01_drafts/attachment_decomposition_02/SPECTER_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |
| IRONCLAD | `assets/characters/ironclad/tier_01_drafts/attachment_decomposition_02/IRONCLAD_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |
| STITCH | `assets/characters/stitch/tier_01_drafts/attachment_decomposition_02/STITCH_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |
| RECOIL | `assets/characters/recoil/tier_01_drafts/attachment_decomposition_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | 1536×1024 |
| ECHO | `assets/characters/echo/tier_01_drafts/attachment_decomposition_01/ECHO_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | 1536×1024 |
| VECTOR | `assets/characters/vector/tier_01_drafts/attachment_decomposition_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | 1536×1024 |
| DEADLOCK | `assets/characters/deadlock/tier_01_drafts/attachment_decomposition_02/DEADLOCK_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |
| GLITCH | `assets/characters/glitch/tier_01_drafts/attachment_decomposition_02/GLITCH_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | 1536×1024 |

The original edit batches and the initial decomposition batch are preserved. Workspace creation refuses to overwrite an existing file. The approved visible references and character-specific layer labels are recorded in [`tools/art/rigging_prep_all_12.json`](../tools/art/rigging_prep_all_12.json) and repeated in each `README_EDIT_PREP.md` sidecar. All 12 current files opened read-only in Krita on 2026-10-25 without repair prompts; no file was saved or edited. This confirms application import only, not a save/reopen round-trip.

SPARK's three separate source-derived drone cutouts and provisional central-core pivots are stored outside these blank OpenRaster workspaces in `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/`. The cutouts remain quarantined, static, and unintegrated; this does not change the blank/edit-prep status of any of the 12 workspaces.

## Layer rules

- One independently moving semantic item per `ATTACHMENT -` layer.
- Split joint-owned armor, separate weapons and accessories, each drone identity, independently moving cloth panels, and separate cable routes.
- Keep a rigid assembly together only when the approved source supports it. CIPHER's optic remains attached to its rifle; the rifle has distinct grip/stow pivots rather than duplicated artwork.
- A layer label is an authoring prompt, not proof of source visibility, anatomy, ownership, pivot, or gameplay behavior. Verify its owner and boundaries against the approved views before painting or exporting.
- Do not infer exact cable or ECHO drone/decoy counts. SPARK's three attack drones are source-backed. The combat simulation remains authoritative for all behavior and event timing.
- PolyRig Auto Mesh accepts one contour per texture. Do not combine independent islands or owners in one mesh input. Where one semantic item has disconnected art, author and validate separate meshes with shared owner/role metadata.
- Keep every workspace and export candidate quarantined until native-scale semantic review, pivot/owner mapping, static reference comparison, pose/deformation checks, and required human review pass.

## Per-character focus

| Recruit | Separate authoring focus |
|---|---|
| BULWARK | Backpack, each physical hose/cable route, rifle, insignia, other visible life-support items |
| BREAKER | Shoulder shell, biological upper arm, mechanical forearm, fist, regulator, back accessories, cables |
| CIPHER | Rifle with mounted optic as one rigid assembly, backpack, source-supported hood/head optic/collar items |
| SPARK | Three separately identified attack drones, tool/weapon item, backpack, cable route |
| SPECTER | Blade, one continuous main cape sheet; add another cloth piece only at a visible independent seam, hood, mask |
| IRONCLAD | Weapon, shoulder/elbow/hip/knee/shin armor plates, back unit |
| STITCH | Front/back coat panels, harness, carried case, each distinct handheld vial/tool item |
| RECOIL | Separate prosthetic shoulder/upper arm, elbow, forearm, and hand segments; shotgun |
| ECHO | Reusable drone unit art, separate decoy visual, neural interface, each cable route, backpack; counts unresolved |
| VECTOR | Courier bag, separately owned straps, blade, limb-owned cyberware overlays |
| DEADLOCK | Rifle, backpack, separately anchored straps, forearm detail |
| GLITCH | One continuous main cape sheet; add another cloth piece only at a visible independent seam, joint-owned lower-limb armor, weapon identity unresolved, thigh gear |

These are work-plan labels drawn from the existing local roster and approved visual references. Any item not actually supported by the visible reference must be marked unresolved rather than invented. The file-based evidence and specific conflicts are in [`ATTACHMENT_REFERENCE_REVIEW_12.md`](ATTACHMENT_REFERENCE_REVIEW_12.md). See [`docs/ATTACHMENT_FUNCTION_CONTRACT.md`](ATTACHMENT_FUNCTION_CONTRACT.md) for gameplay authority and behavior boundaries.

## Validation evidence

- Focused workspace/exporter regression: **21 passed**.
- Full Python regression: **88 passed**; `tools/art/audit_rigging_prep_all_12.py`: **PASS**; Godot 4.7.2 headless suite: **PASS**.
- Approved reference images for all 12 characters were visually compared; see `ATTACHMENT_REFERENCE_REVIEW_12.md`.
- Krita read-only open check: **PASS for all 12 current workspaces** on 2026-10-25; no repair prompts and canvas/reference presentation matched the plan. A save/reopen round-trip remains untested; semantic art and rig gates remain open.
- Remote Notion/Drive reconciliation and upload: pending; no remote change is claimed.
