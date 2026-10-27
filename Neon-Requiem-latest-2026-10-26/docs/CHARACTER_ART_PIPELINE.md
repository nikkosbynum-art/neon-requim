# Character art intake pipeline

**Status:** Implemented as a local review/intake tool. It does not generate character art, define character anatomy, approve assets, or connect review drafts to runtime scenes.

## Shared contract

- Manifest schema: [`tools/art/character_art_manifest.schema.json`](../tools/art/character_art_manifest.schema.json)
- Starter structure: [`tools/art/character_art_manifest.template.json`](../tools/art/character_art_manifest.template.json). The template intentionally has placeholders and empty required arrays; it must be filled with source-backed measurements before validation.
- Roster and provenance: [`tools/art/character_art_roster.json`](../tools/art/character_art_roster.json), based on the live [Founding Recruit Roster](https://app.notion.com/p/40394c5658c8812d849be3d32629920e), read 2026-10-25.
- Executable image and cross-field checks: `tools/art/validate_character_art_manifest.py`.
- Roster-wide discovery and status report: `tools/art/validate_character_art_roster.py`.

## AI-assisted work orders

Before an AI-assisted character-art task, create a one-character, one-phase packet with `python tools/art/build_character_work_order.py <ID> "<one bounded objective>" <new-project-relative-output.md> --phase <phase>`. The packet collects local plan references, candidate status, constraints, acceptance/evidence fields, and stop rules. Recheck its local planning metadata against current approved sources, then fill the deliverable path and measurable acceptance criteria before handoff. It does not generate art or confer approval; see [`AI_CHARACTER_WORK_ORDERS.md`](AI_CHARACTER_WORK_ORDERS.md).

Each manifest describes one character/tier. `character_id` must exactly match one of the twelve founding roster IDs. `tier_id` is a positive integer. The standard filename is `character_art_manifest.json`; place it under `assets/characters/<lowercase-character-id>/` (normally in that tier's art folder). The roster audit discovers only this standard filename. It ignores legacy `pivot_manifest.json` files unless the roster config explicitly lists them, so archived BREAKER experiments cannot be counted as new submissions.

The roster config requires Tier I (`tier_id: 1`) coverage for each of the twelve recruits. Higher-tier manifests may also be added, but cannot substitute for missing Tier I art. Current completeness is reported separately from structural validity and production readiness.

The v1 manifest contains the approved source reference and optional recorded SHA-256, source canvas dimensions, measured review height, pivot coordinates, parent-first bone hierarchy, ordered RGBA part files, draw order, alpha mode, and five explicit production gates. New manifests should author `ground_pivot` in `pivots_px`; it is optional for backward-compatible v1 structural intake, but required to load the standard-manifest rig preview. Part paths stay inside their manifest folder; source-reference and gate-evidence paths stay inside the project. The Python validator checks image decoding, dimensions, non-empty alpha, pivot bounds, references, draw-order consistency, and measured alpha-union height. A gate set true must have a reviewer, timezone-aware timestamp, project-relative evidence files, and a matching source hash. It reports structural integrity separately from production blockers. Hashes and evidence establish traceability; they do not substitute for human art review.

`review_only`, `production_candidate`, and `production_ready` describe asset workflow state, not game canon. Every production gate starts false in the template. Do not mark a manifest `production_ready` unless all five gates are independently supported by review evidence. A passing validator is not an anatomy or art-quality approval.

## Roster coverage today

The live roster source lists BULWARK, BREAKER, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH. The audit explicitly registers the existing BREAKER Tier I `pivot_manifest.json` as a review-only pilot. The other eleven have **no art manifest submitted**. The pipeline does not create blank manifests or assign provisional art to them.

Source-backed Tier I identity briefs for the other eleven are recorded in [`CHARACTER_ART_INTAKE_11.md`](CHARACTER_ART_INTAKE_11.md). The briefs contain only facts from the live roster and mark missing visual/anatomy details as unresolved. The local class/faction concept board is generic reference material, not an individual design or animation source for those recruits.

## Commands

From the project root:

```powershell
python tools/art/validate_character_art_roster.py
python tools/art/validate_character_art_roster.py --json
python tools/art/validate_character_art_roster.py --require-all
python tools/art/validate_character_art_roster.py --require-production
python -m unittest tests.test_character_art_manifest tests.test_character_art_roster -v
```

Exit codes: `0` means the audit ran without integrity errors; missing Tier I art remains visible as `NOT SUBMITTED` or `INCOMPLETE`. `1` means invalid roster/manifest data. `2` means `--require-all` found a missing required Tier I manifest. `3` means `--require-production` found missing required Tier I manifests or production blockers. These strict modes are release checks, not the normal daily intake command.

## Scope and next use

This pipeline applies the same contract to all twelve characters as art arrives. It does not turn the existing BREAKER sample into production art, and no other recruit receives a placeholder manifest. Future source assets still need provenance, measured canvases, real part files, appropriate anatomy/pivots, independent visual review, and the relevant gate evidence. Combat/runtime systems remain separate from this workflow.

## Rig review workbench

Open tests/art/rig_review_workbench.tscn in Godot and run the current scene to inspect quarantined rig candidates. The workbench currently previews the ten flattened-profile mesh preflights and the CIPHER profile cutout candidate. Other recruits remain listed in the roster selector with an explicit no-adapter status; continue using their existing character-specific review scenes.

Use the pose selector for neutral, idle, walk, attack/aim, hit, and defeat samples; select a bone and move its temporary rotation slider to inspect joints; toggle individual mesh contours or cutout parts; compare the approved anatomy reference in the side panel; and use the six-pose capture button to save a review image and metadata under user://rig_review_captures/.

These are review controls only. Temporary rotations do not modify source manifests or art. A capture and the workbench status do not establish semantic correctness, anatomy, authored pivots, continuous seam quality, animation approval, or production readiness. Keep all candidates quarantined until the existing visual, semantic, pivot, deformation, and explicit approval gates pass. The scene is isolated from the runtime game.

Standard manifests can now be loaded into this same workbench using the project-relative path to `character_art_manifest.json`. The adapter assembles the declared RGBA parts against the authored bone hierarchy and ground pivot; it supports neutral pose only and does not invent animation clips. It confines manifest and part reads to the project. Review scale uses measured visible height at the shared 256 px foot-to-hair reference, with a width limit for unusually wide canvases. Existing mesh/cutout previews use their alpha bounds to approximate the same visible-height scale. This normalization is for comparative review; it does not alter source files or certify dimensions.

Use **Capture selected-joint diagnostic** after selecting a bone. Enter the selected joint's min/max range and an optional context/source note; the workbench captures five evenly spaced neutral-pose samples and a JSON sidecar under `user://rig_review_captures/`. The default -75°/+75° is a generic diagnostic range. Captures are single-joint diagnostics, not combined actions or pass/fail checks; entered ranges are recorded as unverified notes. Inspect seams, overlap, silhouette, and ground contact manually. Six-pose captures remain available for adapted candidates; standard-manifest adapters currently expose neutral only.

For a standard manifest, build one no-overwrite review bundle outside its source candidate folder:

```powershell
python tools/art/build_character_review_bundle.py assets/characters/<id>/tier_01_drafts/<candidate>/character_art_manifest.json docs/visual_qa/<ID>_T1_REVIEW_BUNDLE_01
```

The bundle contains a native-scale named-part checkerboard, back-to-front static assembly, mechanical alpha-union and overlap diagnostics, a JSON report, and a manual checklist. These aids do not assign semantic labels or approve hidden anatomy, pivots, seams, or animation. Existing true gates without valid evidence are called out as blocked. The command refuses to overwrite output; keep generated review evidence in a new, quarantined directory. Add reviewed evidence paths and the exact approved-reference hash only after the corresponding human review actually occurs.

The selected-joint sweep is explicitly a **generic fixed-angle diagnostic**. It must not be used as the character's intended movement/action range or as evidence that `animation_reviewed` passed. Record joint ranges from actual authored clips or reviewed action-pose specifications for that character, and capture the combined poses so simultaneous joint interactions are visible. If the standard-manifest adapter exposes only neutral, leave animation review blocked.

Before an animation gate can pass, capture the assembled candidate in an isolated QA composition using the project's 1280×720 gameplay viewport and inspect it again at 800×450. This check asks whether the character silhouette, equipment/role cues, key action, and ground contact still read at in-game size. The 256 px foot-to-hair comparison normalizes art scale but does not replace this camera-scale check. Keep the QA composition isolated from runtime until all art gates pass.

At semantic intake, use a bounded go/no-go: after the first native-scale contact sheet and ownership review, stop if a required part is missing, clipped, duplicated, ambiguously owned, or unsupported by the approved reference. Record what remains unresolved and what source correction is needed; do not keep generating segmentation variants or proceed to rigging to compensate for missing evidence. Reuse standard anchors only where they fit the character; record anatomy-specific skeleton/part exceptions in its manifest and part plan.

Godot 4.7.2 startup and visible rendering have been checked for the initial BULWARK view. The capture export and other adapters still need a manual exercise before they can be recorded as validated.

## Twelve-character game-scale roster preview

Run tests/art/founding_roster_gameplay_preview.tscn to render all twelve Tier I designs together. The saved local review image is docs/visual_qa/FOUNDING_ROSTER_GAME_SCALE_PREVIEW_01.png. Ten figures use quarantined profile-mesh preflights, CIPHER uses its quarantined cutout candidate, and BREAKER uses its approved static profile reference. The board is a game-scale roster mockup; it is not a 12-unit combat formation or production/runtime art.
