# BREAKER profile rig trial 01 — QUARANTINED RIG TRIAL

## Manifest-driven review harness — 2026-10-25

`pivot_manifest.json` is now treated as version 1 data for this isolated BREAKER review rig. The Godot reader instantiates its declared parent-first bone hierarchy and RGBA parts, applies the declared draw order, and fits the declared visible-height target. This keeps the review fixture's assembly metadata in one source of truth and provides a starting schema for a future import tool.

Validate the manifest structure and source/part images from the project root:

```powershell
python tools/art/validate_character_art_manifest.py assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/pivot_manifest.json
python -m unittest tests.test_character_art_manifest -v
godot --headless --path . --script res://tests/test_breaker_profile_rig_trial_01.gd
```

**Validation state:** Python schema/image validation, malformed-data tests, and the Godot hierarchy/pose smoke test pass. The manifest's `asset_status` remains `review_only`; visible approval, concealed anatomy, authored pivots, joint review, and animation review gates remain incomplete. Passing these tools does not mean these masks are clean production parts or approve them for runtime use. The Godot scene under `tests/` is a review harness, not a production character scene.

**Current status:** Static neutral extraction **PASS**; Godot hierarchy/animation smoke test **PASS**; user-reviewed sampled visual coherence **PASS**; strict scale conformance, authored pivots, full-frame seam continuity, and deformation **NOT VALIDATED**. Keep all parts quarantined and out of runtime.

## Explicit validation summary — 2026-10-24

| Check | Evidence / result | Limit |
|---|---|---|
| Canvas and review scale | Source and all 13 part PNGs are 1024×1536. The updated isolated gate preview uses `scale = 256 / 1427` so the measured alpha silhouette is 256 px feet-to-hair. | Earlier user-reviewed preview used 256 px full-canvas fit (~238 px visible). The new exact visible-height presentation has not yet received a separate visual approval and does not approve final pivots. |
| Pivot placement | `pivot_manifest.json` provides the ground, pelvis, torso, head/neck, shoulder/elbow, hip/knee/ankle points. Godot neutral alignment, tracked pivot rotation, and fixed ground-anchor checks passed. | Every point is a hand-estimated source-pose coordinate, not an authored/artist-verified joint. Only transform plumbing is validated. |
| Neutral seams | The 13 layers cover the thresholded visible silhouette with zero uncovered pixels and recreate the neutral source composite exactly. The user reports coherent connections in neutral/walk/punch/hit sample previews. The 60 FPS Godot walk capture showed no major detached joint in 20 visually sampled poses. | Exact neutral reconstruction and sampled visual continuity do not prove all-pixel seam continuity across every frame. Some foot glide is visible in the translating walk fixture. |
| Deformation and part granularity | Bone2D pivots rotate rigid Sprite2D layers; the 210-frame walk scene rendered successfully. | No mesh/skinned deformation or hidden joint anatomy is present. `head_neck` is combined; each forearm image includes its hand/fist, and each boot image includes the foot. Hands, wrists, ankles, and fingers cannot be animated/swapped independently. |

## Tier I five-pose art gate — 2026-10-24

Godot 4.7.2 now samples idle, walk, punch, hit, and defeat at the exact 256 px visible-height target and captures a full-size six-BREAKER lineup. The isolated regression checks 13 shared 1024×1536 RGBA layers, transparent corners, manifest pivot bounds, facing flip, stable ground anchor, and expected bone motion. Latest review captures are `docs/visual_qa/breaker_production_gate_actions_1280x720.png` and `docs/visual_qa/breaker_production_gate_six_unit_1280x720.png`.

**Gate outcome: REVIEW HARNESS PASS; ART PRODUCTION GATE NOT PASSED.** All pivots remain hand-estimated. Hidden anatomy under overlaps is absent, arms/hands and boots/feet are combined, and the screenshots are sampled poses rather than all-frame seam validation or mesh deformation. Keep all 13 layers quarantined and out of runtime. The generated redraw/background-removal attempts were not accepted because they changed the pose or retained an opaque background; no generated output was staged as a replacement.

The user-reviewed 256 px configuration is a visual-coherence result, not production scale/pivot approval. Deformation readiness remains **NOT VALIDATED**.

The user approved the parent `BREAKER_T1_profile_rebuild_candidate_01.png` as the Tier I visual direction. This experiment applies hand-estimated polygon masks to that approved image and exports shared-canvas part PNGs. The source image remains unchanged.

The assembled preview is `assembled_neutral.png`. Visual inspection found large retained background polygons, angular cuts, and incorrect clipping through the face/arm. `silhouette_mask.png` also self-intersects. These outputs do **not** demonstrate clean transparent parts, connected seams, valid pivots, or an animation-ready rig. Do not import them into the runtime. `tools/art/export_breaker_profile_trial_01.py` documents the failed mask points for audit and must not be treated as a production exporter.

No Godot scene was changed and no Godot tests were run. The next art pass needs carefully traced part masks and painted joint overlap/hidden anatomy, followed by a fresh assembled preview and seam checks.

## Alpha-cutout and source-pixel assembly refinement — 2026-10-24

The user approved the parent profile image. Its alpha matte separates the character core (~250 alpha) from most of the background glow (below 245), so the exporter now thresholds that matte and clips all part masks to the resulting silhouette. The neutral composite is substantially cleaner than the first polygon pass and retains the approved figure's proportions. Export verification loaded all 13 part PNGs at 1024×1536. The coverage test still finds 16,148 silhouette pixels missing and exact reconstruction is **FAIL**; `uncovered_mask.png` and `assembly_difference.png` record the gaps. Keep the files quarantined. No pivots, hidden joint anatomy, or animation deformation are validated, and no Godot tests ran.

## Owner-assigned overlap export — neutral reconstruction pass 03 — 2026-10-24

Refined the 13 part masks into a single-owner segmentation map, then grew each component by a small seam margin and clipped it to the candidate's alpha-derived silhouette. This keeps source pixels in one component before adding the local overlap. The export script now fails if any silhouette pixels are uncovered or the composite differs from the thresholded source. Latest run passed: 13 PNGs at 1024×1536, zero uncovered silhouette pixels, and exact neutral reconstruction. The user-approved appearance is preserved in `assembled_neutral.png`; individual parts and `parts_sheet_preview.png` remain review-only. Hidden anatomy at covered joints is not reconstructed, pivots are provisional/unset, and no deformed poses or Godot rig have been tested. Do not promote to runtime yet.

## Godot structural rig smoke test — 2026-10-24

The isolated preview in `tests/breaker_profile_rig_trial_01_preview.tscn` reads this trial's pivot manifest and builds a Bone2D hierarchy without touching the runtime character. Godot 4.7.2 headless test passed after capturing each Bone2D neutral rest transform and setting explicit provisional lengths. It loaded all 13 part textures, checked shared-canvas origin alignment, verified intended pivot rotation during idle/walk/punch/hit, and confirmed a stable ground anchor. Only the known sandbox log-file permission warning remained. This is not a visual seam or continuous-deformation pass; parts remain quarantined and not production-ready.
