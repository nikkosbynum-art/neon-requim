# BREAKER Tier I rig contract

**Status:** Local prototype interface contract. Derived from the approved BREAKER Tier I specification in the offline reconstruction package; live Notion and Drive have not been re-read. This contract does not make the polygon stand-in or generated atlas drafts production assets.

## Responsibility boundary

- The combat director owns world position, health, target selection, attacks, damage, and defeat. It sends presentation state to BREAKER; presentation never decides a combat result.
- The root `Node2D` position is the simulation-provided ground/contact anchor. It must not shift when facing or changing an animation.
- `VisualSkeleton` owns visible character transforms and is the only node mirrored for left-facing presentation. Gameplay coordinates and actor ownership remain outside the skeleton.
- The visual rig owns no combat collision shapes and no persistent combat state. Effects may read named visual anchors; they may not feed outcomes back into combat.

## Stable presentation API

| Interface | Contract |
|---|---|
| `present(world_x, state, health_ratio, world_y)` | Receives a simulation snapshot and updates actor anchor, visual state, and health display only. |
| `set_facing_right(value)` | Mirrors `VisualSkeleton`; does not change the root position, hit points, collision coordinates, or simulation state. |
| `play_action(name)` | Requests a visual action. Current actions are `punch`, `hit`, and `defeated` (with `defeat` accepted as an alias). Animation timing is presentation-only. |
| `set_tier(tier)` | Tier I is currently supported. Unsupported tiers return `false` and do not imply art exists. |
| `set_overload(value)` | Clamps a presentation parameter to 0–1 for the fist LED. It does not apply damage or grant an ability. |
| `get_anchor_global_position(name)` | Returns the position of a presentation effect marker, or zero for an unknown marker. |
| `set_head_art(texture, pivot_px, display_height)` | Experimental art-trial hook: attaches one head texture under the head bone using an explicit pixel pivot and requested world-space display height. Rejects missing textures and out-of-bounds pivots. It is not called by the main scene. |

## Required markers and visual identity

- `fx_anchor_ground`: attached to the unflipped rig root at local `(0, 0)`.
- `fx_anchor_neck`: attached to the torso/neck-regulator visual region.
- `fx_anchor_fist_r`: attached to the signature right cybernetic fist and mirrored with the visual skeleton.
- Preserve the Tier I identity anchors in the written spec: scarred human face, messy undercut, boxer stance, asymmetric enlarged right cybernetic fist, matte black/gunmetal with controlled crimson, neck regulator, subtle left knee brace, and combat boots.
- Keep named semantic bones/parts in the rig internal. A future replacement must map equivalent semantic parts without changing the presentation API or simulation boundary. Exact pivots and offsets belong to the art/rig import data and require validation before they become defaults.

## Asset acceptance gate

Do not connect an art draft to runtime until it has individual transparent PNG part exports, a consistent 256 px foot-to-hair reference height, declared pivots/neutral pose, clean joint overlap, no clipped extremities, and an assembled neutral pose that preserves the ground marker. Verify facing flip and six-unit readability with the exported parts. Generated sheets and concept boards remain quarantined references.

The two original atlas drafts do **not** pass this gate: they are sheets of exploration parts with no documented part bounds, common scale, pivots, or validated joint seams. Keep them outside runtime scenes until cleaned and tested. A single component may be trialed separately only after it meets the same alpha, scale, pivot, and seam checks.

## BREAKER production import workflow

This character-specific contract uses the shared intake pipeline in [`CHARACTER_ART_PIPELINE.md`](CHARACTER_ART_PIPELINE.md) and [`CHARACTER_PART_AUTHORING_GUIDE.md`](CHARACTER_PART_AUTHORING_GUIDE.md). The pipeline's manifest validator, review bundle, and isolated rig workbench are review/import-preflight tools. None copies draft art into runtime or grants production approval.

| Gate | Required evidence | Pass condition |
|---|---|---|
| Approved source and provenance | The approved `BREAKER_T1_profile_rebuild_candidate_01.png`, its SHA-256 recorded in the candidate manifest, the approved elbow boundary, and the Tier I production spec | The source is unchanged; the external shoulder shell remains over biological upper-arm pixels, and the right mechanical prosthesis begins at the elbow. Do not infer the hidden arm contour from rejected studies. |
| Semantic part intake | One transparent, canvas-aligned file per independently moving part; named contact sheet; source ownership overlay; part provenance and draw order | Every required part is complete, uniquely owned, unclipped, correctly named, and reviewed at 100%. The production-board PNGs and generated atlases are not runtime inputs. Any unresolved or unsupported boundary stops intake. |
| Manifest and mechanical checks | `character_art_manifest.json` using `tools/art/character_art_manifest.schema.json`, with source hash, 256 px visible-height target and measurement, authored pivots, parent-first bones, parts, draw order, and all five production gates initially false | `python tools/art/validate_character_art_manifest.py <candidate>/character_art_manifest.json` reports structural integrity separately from production blockers. `python tools/art/build_character_review_bundle.py ... <new-output-dir>` produces a no-overwrite native-scale review packet. These checks do not decide anatomy or visual quality. |
| Neutral assembly and scale | Back-to-front assembly against the approved profile, alpha/overlap diagnostics, ground marker, 1280×720 gameplay view, and 800×450 downscale | The source-visible silhouette and identity remain intact, no part is cropped or detached, the foot baseline stays fixed, and BREAKER remains legible in a six-unit lineup. Hidden pixels are separately labeled `inferred` and need their own visual acceptance. |
| Rig and action validation | Isolated Godot rig using the stable API above; visible captures for grounded idle, walk, punch, hit, and defeat; frame-sampled joint and foot-contact checks | Every authored action stays within its reviewed character-specific pose range. Shell, biological upper arm, and elbow-start prosthesis retain their approved ownership and draw order; no visible gaps, detached pixels, or ground-anchor drift occur. A generic single-joint sweep or sampled-contact count alone is not an animation pass. |
| Production handoff | Five evidence-backed gates: `visible_art_approved`, `hidden_anatomy_authored`, `pivots_authored`, `joint_seams_reviewed`, and `animation_reviewed` | Set `production_ready` only after all five gates have valid evidence in the manifest, native/game-scale review passes, and the user accepts the visual result. Until then keep the complete candidate under `tier_01_drafts/`; the runtime character continues using its placeholder. |

Use the explicit OpenRaster layer exporter only after semantic layers have been authored and reviewed: `python tools/art/export_reviewed_openraster_parts.py <workspace.ora> <selection.json> <new-candidate-dir>`. It exports selected layers to quarantine and leaves pivots, animation, production approval, and runtime integration false. A `pivot_manifest.json` from an older profile trial does not substitute for the shared `character_art_manifest.json`; do not create an empty production manifest to make roster coverage appear complete.

**Current intake state:** No BREAKER Tier I `character_art_manifest.json` or complete semantic part set has been submitted. Existing profile-rig trials and candidate 01 underarm fits remain quarantined. Candidate 01 v20 preserves the approved shell-on view and passes its scoped source-mask/contact checks, but its shell-off hidden-arm appearance has not been accepted. The whole-character production-art gate therefore remains **NOT PASSED**.

## Current verification scope

`tests/test_runner.gd` checks the current placeholder against the stable boundary: skeleton and identity markers exist, no collision shapes are owned by the visual rig, visual facing leaves the root/ground anchor fixed while fist FX follows the mirror, animation requests leave simulation position/health unchanged, and Tier I/action state remains configurable. It also loads the quarantined BREAKER head candidate, checks transparent/opaque samples, mounts it in an isolated rig through `set_head_art`, verifies its declared pivot maps to the head-bone origin, and checks that the overlay leaves simulation state untouched. These tests validate file and transform plumbing only, not assembled graphical quality, deformation, authored clips, impact-event synchronization, or the final reusable four-tier rig.

## Isolated profile-art gate update — 2026-10-24

`tests/test_breaker_art_gate.gd` and `tests/capture_breaker_production_gate_qa.gd` exercise the quarantined profile masks at the 256 px visible-height spec and sample idle/walk/punch/hit/defeat plus six full-size copies. They provide a review harness only. The art contract is still **NOT PASSED**: the 13 masks have estimated pivots and no hidden anatomy fill, forearms include hands, boots include feet, and continuous seam/deformation validation is absent. Do not connect these masks to the runtime character.

## Sources

- Offline reconstruction: `migration_package/notion_reconstruction/03_Breaker.md` (reconstructed, not a verbatim Notion export).
- Detailed approved visual/rig specification: `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md`.
- Canonical Notion page to re-check when access returns: https://app.notion.com/p/40394c5658c881edb7fae758125174f1
