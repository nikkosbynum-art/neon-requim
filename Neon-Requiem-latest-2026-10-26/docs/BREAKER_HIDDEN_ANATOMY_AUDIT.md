# BREAKER Trial 03 hidden-anatomy audit — 2026-10-24

**Historical status note:** The dated sections below originally described the Tier I arm boundary as unresolved. The user approved the visible reading on 2026-10-25: external shoulder shell over a biological upper arm; the mechanical prosthesis begins at the elbow. That design choice is resolved. Hidden anatomy and production animation remain unverified.

## Result: NOT VERIFIED — production-art gate fails

The user asked for direct verification of hidden anatomy. Candidate 03 is a flattened RGBA image. Its 13-layer trial was produced by the deterministic mask exporter, which copies RGB from that flattened image and expands each layer's alpha mask while clipping it to the source silhouette. That method creates mask overlap, but cannot author the missing underside of a limb or body part.

`tools/art/audit_breaker_trial_03_hidden_anatomy.py` checked all 13 layers at the full 1024×1536 shared canvas:

- Opaque layer pixels checked: **664,937**
- Layer pixels whose RGB differs from the flattened source at the same coordinate: **0**
- Layer pixels outside the source alpha≥245 silhouette: **0**
- Pixels covered by two or more layer masks: **173,588** (40.62% of the source silhouette)
- Pixels covered by three or more masks: **55,279**

The overlap percentage is **not** evidence of correct under-paint: these are repeated source pixels, not separately reconstructed anatomy. The 60 Hz contact test confirms only that selected opaque pixels meet near 12 pivots in its sampled poses. It does not check a complete seam, anatomical continuity, or deformation quality.

## What remains trustworthy

- Candidate 03 visually resembles the user-approved candidate 01; the separate fidelity test and comparison screenshot remain valid for visible-art similarity.
- The isolated trial demonstrates that Godot loads the 13 shared-canvas layers and evaluates the provisional animation channels.
- Runtime art and gameplay were not changed.

## What is required to pass

Create genuine layered source art: each limb/body component needs independently painted pixels continuing beneath its neighboring component, plus authored pivots and explicit front/back order. Then validate complete joint regions across the entire animation timeline at the target 256 px visible height, including the fist, wrist, elbows, shoulders, pelvis/hips, knees, ankles, and boot contacts. A flattened reference alone is insufficient to verify those occluded pixels. The source or component artwork must be redrawn/painted; merely enlarging masks cannot pass this gate.

## Reproduction

```powershell
python tools/art/audit_breaker_trial_03_hidden_anatomy.py
```

The script returns exit code 2 when the current layers contain no independent RGB under-paint. That is the expected result for trial 03; it is a failure of the hidden-anatomy readiness gate, not a failed execution of the audit.

## Source availability check

A local recursive search for layered art formats (`.psd`, `.kra`, `.ora`, `.aseprite`, `.ase`, `.xcf`) found no source file in this workspace. The candidate is a flattened PNG, so there is no hidden layer data to inspect. Without a layered authoring source or newly painted, reviewed under-paint, the concealed anatomy cannot be confirmed from available files.

## Validation rerun after status correction — 2026-10-24

- `python tools/art/audit_breaker_trial_03_hidden_anatomy.py`: executed successfully as an audit; result **NOT VERIFIED** (expected readiness-gate exit code 2), 664,937 layer pixels checked, 0 independently colored pixels.
- Godot 4.7.2 isolated trial-03 rig structure/action test: PASS; all 13 parts loaded, anchors and five pose channels exercised.
- Godot 4.7.2 full project test runner at fixed 60 Hz: PASS (`All Neon Requiem prototype tests passed.`).
- Godot emitted its known non-fatal `user://logs/godot.log` permission warning. No runtime references to trial 03 were found. Workspace has no `.git` metadata.

## Trial 04 inferred-underpaint result — 2026-10-24

The user authorized an inferred local draft after no layered original was found. Trial 04 adds 120,693 pixels of local color extrapolation at joint neighborhoods; 120,589 sample colors differ from the same-coordinate flattened source. The source-pixel visible parts and trial 03 are unchanged. Static composition audit passes exactly. Godot structural/action and 2,472 sampled contact checks pass; the full suite and 120-frame main scene also pass. However, the exaggerated joint-stress screenshot retains visible artifacts. This method creates useful test underlays but does not establish correct anatomy. Trial 04 status remains **INFERRED / NOT VERIFIED / NOT PRODUCTION-READY**. See its local README and `docs/IMPLEMENTATION_STATUS.md`.

## Canon/art review rerun — 2026-10-24

The local flattened source and BREAKER production specification were compared again. The approved profile candidate remains the appearance authority. Its relaxed arms are weaker than the spec's explicit boxer-stance identity anchor, so a separate guarded-pose interpretation was generated for review, not substituted. `BREAKER_T1_guarded_pose_review_candidate_01.png` retains the recognizable face/scars, undercut, small red neck regulator, sleeveless dark vest, enlarged crimson-lit right cyber arm/fist, dark cargo trousers, and black boots. The left arm stays human and unarmored; no clear Tier II/III/IV armor was added. The pose is grounded and reads as a compact guard. Its bent-arm/wider stance changes the silhouette as expected, and it is not pixel-identical or user-approved. Side-by-side evidence: `docs/visual_qa/BREAKER_T1_guarded_pose_canon_review_01.png`.

Candidate structural audit passed: 1024×1536 RGBA, alpha extrema 0–254, transparent canvas corners, and a 1478 px high figure bound. The checker verifies file structure only; it cannot certify visual canon or anatomy. The draft remains under `tier_01_drafts/` and has no runtime references.

Validation rerun: `python tools/art/audit_breaker_guarded_pose_candidate.py` passed. `python tools/art/audit_breaker_profile_trial_04_underpaint.py` passed exact neutral composite/underpaint checks. `python tools/art/audit_breaker_trial_03_hidden_anatomy.py` returned its expected exit code 2 (**NOT VERIFIED**) because pixel provenance is not semantic anatomy evidence. Godot 4.7.2 console, `--headless --fixed-fps 60`: full `tests/test_runner.gd`, trial-04 structure, 2,472 selected contact samples across 206 authored poses, and the dedicated 0.65-second walk-gait regression all passed. Godot printed the known non-fatal `user://logs/godot.log` write warning. Manual view of the eight-phase walk capture found no obvious detached parts in the authored gait; the exaggerated stress capture still visibly breaks at extreme leg/ankle poses.

**Final status remains NOT VERIFIED for semantic hidden anatomy and NOT PASSED for production art.** The current clip-range preview is testable and readable, but its 13 joint fills are extrapolated texture, the pivots are estimated, parts remain combined at hands/feet/head/neck, and extreme stress reveals failure. The guarded candidate helps satisfy the visual pose anchor, but it is only a draft interpretation. No source image, trial 04, runtime scene, combat logic, or approved design decision was changed. A flattened concept plus inferred pixels cannot prove concealed anatomy; artist-authored layered parts and joint-paint review are still required for that claim.

The audit also produced a second, specification-scale view. Both reference and draft are scaled to 256 px visible height and share the same ground baseline (`docs/visual_qa/BREAKER_T1_guarded_pose_256px_review_01.png`). Visual inspection at this target retained face, regulator, sleeveless vest, asymmetric cyber fist, and grounded boots. The draft is wider because it is posed with bent arms and staggered feet; this is an intentional pose change and still awaits human approval.

## Candidate01 elbow-contact and shell-on render checks — 2026-10-25

The user-approved arm boundary is external shoulder shell over a biological upper arm, with the mechanical prosthesis beginning at the elbow. Candidate01 v20 remains a quarantined inferred underlay. The focused Godot arm suite now requires at least 100 source-pixel neighborhood contacts at the elbow; v20 passes with 104–267 contacts across 206 sampled poses (20 variants / 4,120 total samples; v14 and v19 are expected rejects). A Godot zoom capture is available at `docs/visual_qa/BREAKER_T1_candidate01_v20_elbow_join_zoom.png`.

OpenGL shell-on comparison also passes its bounded-edge guard across 206 stable poses (peak 37 pixels / 83 channel levels), while the separate opaque-source audit reports 21,434 donor pixels covered and zero changed opaque pixels. These checks strengthen registration and visible-source preservation evidence but do not authenticate hidden anatomy, prove continuous deformations, or pass the production-art gate. A generated side-by-side anatomy study was rejected as a source asset because it changes unrelated design details and exaggerates the isolated bicep. The production-art gate remains **NOT PASSED**.

## Candidate 05 / rig trial 05 v4 status — 2026-10-24

The user authorized continuing with locally reconstructed assets after no layered source was found. Candidate 05 is a generated guarded-pose review draft based on the approved visual-direction image. At 256 px visible height, manual review finds its major Tier I identity anchors legible and its boxer pose grounded. This is only a visual-draft review; the candidate remains quarantined and is not final user-approved artwork.

Trial 05 v4 contains 13 estimated parts and 13 local-color extrapolation underpaint layers. `python tools/art/audit_breaker_guarded_trial05_v4.py` passes exact neutral composite reconstruction over the alpha>=245 silhouette with 0 uncovered pixels. It counts 89,272 underpaint pixels and 89,218 RGB changes against the flattened source at the same coordinate. These changed colors show inferred fill, not independently painted or anatomically authenticated body surfaces.

Godot 4.7.2 passed isolated rig structure, selected joint neighborhood tests (2,472 samples / 206 poses / 60 Hz; 136–315 adjacent contact pixels), and a 0.65 s walk test including planted-sole samples. The complete project test runner and 120-frame main-scene headless launch also passed. The headless Movie Maker attempt failed with a null texture on the dummy renderer before writing a preview; there is no Godot walk capture.

**Result remains: HIDDEN ANATOMY NOT VERIFIED; PRODUCTION-ART GATE NOT PASSED.** The source remains a single flattened PNG, pivots are inferred, and the underpaint method cannot verify anatomical correctness or all-frame seams. All trial files stay quarantined and runtime-independent. Godot’s log-file write warning is non-fatal. See `assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_05_README.md` and the trial v4 README for reproduction details.

## Trial 05 v8 update — 2026-10-24

The user asked to verify hidden anatomy and ensure the result is correct. A local search found no layered source artwork. The user authorized reconstructing locally if the original could not be found, so trial 05's underpaint is an explicitly quarantined reconstruction experiment from the flattened candidate, not recovered source data.

`python tools/art/audit_breaker_guarded_trial05_v8.py` passes exclusive visible-layer ownership (no duplicate ownership), complete silhouette coverage, and exact neutral composite. It reports 297,312 underpaint pixels; 296,989 change RGB relative to the source at the same coordinates. These values prove that local extrapolated pixels exist. They do **not** prove those pixels depict the correct anatomy. The v8 Godot structure test, sampled joint test (2,472 checks / 206 poses at 60 Hz), conservative walk regression, full project test runner, and 120-frame main-scene launch all pass in their stated scopes. A v10 fade test verifies alpha 1.00 → 0.72 → 0.00 while preserving the ground anchor.

Visual evidence is mixed: the v8 conservative walk reads connected in the retained contact sheet at 256 px; the stronger v8 defeat collapse tears at joints and **fails** visual review. The v9 slump is cleaner but too weak as a defeat cue. v10 adds a fade; its effect is mechanically tested but remains an unapproved design option. See `docs/visual_qa/BREAKER_T1_trial05_defeat_options.png`.

**Final gate: NOT VERIFIED / NOT PASSED.** No test in this handoff can certify hidden anatomy from a flattened image. Independent hands/feet, authored pivots, full seam/deformation quality, and art approval remain outstanding. Keep every trial quarantined and out of runtime. Do not claim this visual result is fully correct or production-ready.
## Candidate 07 static anatomy/canon review — 2026-10-24

Candidate 07 has a single coherent static figure with visible shoulder-to-arm, elbow, hip, knee, ankle, and boot contours. The structural audit confirms clean RGBA transparency, uncut bounds, and a projected 5.09 px boot-baseline difference at 256 px visible height. Manual art review finds no obvious detached visible body parts in this one pose, and the localized knee support is low profile.

This is a static visible-anatomy review only. Candidate 07 is flattened and has not been animated; no test can infer its occluded limb surfaces or certify joints under motion. The prior candidate 05 v8 walking rig tests are not transferable to candidate 07. Hidden/deformed anatomy remains NOT VERIFIED.

Historical at the time of this review (superseded by the 2026-10-25 user approval): candidate 07 followed the written forearm-only Tier I scope and candidate 05 retained more of the approved profile's shoulder silhouette. See the same-scale review docs/visual_qa/BREAKER_T1_canon_candidate_07_comparison.png; both candidates remain quarantined.
## Candidate 07 static anatomy/canon review — 2026-10-24

Candidate 07 has a single coherent static figure with visible shoulder-to-arm, elbow, hip, knee, ankle, and boot contours. The structural audit confirms clean RGBA transparency, uncut bounds, and a projected 5.09 px boot-baseline difference at 256 px visible height. Manual art review finds no obvious detached visible body parts in this one pose, and the localized knee support is low profile.

This is a static visible-anatomy review only. Candidate 07 is flattened and has not been animated; no test can infer its occluded limb surfaces or certify joints under motion. The prior candidate 05 v8 walking rig tests are not transferable to candidate 07. Hidden/deformed anatomy remains NOT VERIFIED.

Historical at the time of this review (superseded by the 2026-10-25 user approval): candidate 07 followed the written forearm-only Tier I scope and candidate 05 retained more of the approved profile's shoulder silhouette. See the same-scale review docs/visual_qa/BREAKER_T1_canon_candidate_07_comparison.png; both candidates remain quarantined.

## Candidate 07 rig feasibility retest — 2026-10-24

Historical status at the time: the live BREAKER Tier I specification and Decision Log had not resolved the visible arm boundary; neither candidate was promoted.

Candidate 07's single-owner extraction audit passed exact neutral reconstruction (0 uncovered, outside, or multiply-owned visible pixels) across 13 layers. Local underpaint has 294,771 inferred pixels / 294,395 changed RGB pixels, but those values are extrapolated texture, not anatomical reconstruction. Godot 4.7.2 passes the isolated structure test, 2,472 selected joint-neighborhood samples across 206 poses (72–488 adjacent contacts), and the conservative walk regression. The rendered eight-phase walk and five-action sheets were visually inspected at 256 px visible height. Idle, walk, punch, and hit read connected at those samples; defeat reads as a dynamic fall. These results support sampled clip readability only; semantic hidden anatomy, artist-authored pivots, all-frame seam continuity, and production deformation remain **NOT VERIFIED**. The production-art gate is **NOT PASSED**. Candidate 07 remains quarantined and has no runtime links.


## Anatomy inspection board candidate 10 — 2026-10-25 UTC

Manual full-size review finds the component distinction readable: shoulder shell, underlying human upper-arm volume, and mechanical forearm/fist are shown separately. This is a generated illustration board, not a hidden-anatomy test. Its cutaway is not evidence, and added wraps/underlayers must not be treated as canon. It supplies no original layers, pivots, rig, or motion samples. The arm-boundary sentence was superseded by the user's 2026-10-25 approval. Hidden anatomy remains **NOT VERIFIED** and production art remains **NOT PASSED**.


## Candidate 05 v8 right upper-arm mask audit — 2026-10-25 UTC

Live Notion was re-fetched on 2026-10-25: the BREAKER page still specifies a mostly human Tier I figure with a mechanical right forearm/fist, while its approved profile image visibly carries shoulder machinery; the Decision Log has no later arm-boundary resolution.

`python tools/art/audit_breaker_trial05_v8_arm_masks.py` checks the v8 source-mask ownership and builds `docs/visual_qa/BREAKER_T1_trial05_v8_arm_mask_ownership_audit.png`. It reports 3,115 warm-skin-color heuristic pixels in a manually bounded shoulder/upper-arm ROI owned by `cyber_upper_arm`, and 0 in `natural_upper_arm`. Manual inspection confirms those pixels are the exposed skin patch beneath/adjacent to the shoulder shell. This supports reading the shell as external armor over a human upper arm, with the mechanical forearm beginning at the elbow. It does not prove anatomy hidden behind the shell.

Godot 4.7.2 structure/five-pose, 2,472 selected contact samples, and walk-gait regressions passed for the isolated v8 draft; the candidate 09 image checks and full prototype test runner also passed. Manual review of the existing low-scale walk/punch/hit samples found no obvious detached right-arm part; defeat pose remains visually weak. The shell and exposed skin remain fused into one moving upper-arm texture, underpaint remains inferred, and full-frame deformation is not validated. Hidden anatomy remains **NOT VERIFIED**; production art remains **NOT PASSED**.


## User decision and arm-surface split outcome — 2026-10-25 UTC

Canon boundary now resolved by the user: external shoulder armor overlays a biological upper arm; the mechanical prosthesis begins at the elbow. This is the governing Tier I art rule. The decision does not mean hidden anatomy has been recovered.

The v1 pixel split round-trips the original flattened upper-arm layer exactly, but the isolated skin-classified output is visually fragmented and fails as a standalone arm surface. Its green light is only pixel ownership/reconstruction; do not rig or promote it. A continuous arm surface still needs to be authored or reconstructed, with the shell as its own visual layer. The source remains flattened; covered anatomy and full-frame deformation remain **NOT VERIFIED**.

## Arm-boundary integration review and rejected alpha experiment — 2026-10-25

- User-approved canon is now explicit: the external shoulder shell sits over a biological upper arm; the mechanical right prosthesis begins at the elbow. This resolves the prior conflict between profile art and the written forearm description. It does not approve any current image as production art.
- Candidate 09 visually communicates the approved boundary at review scale. Its static Python audit and Godot decode test pass: 1024×1536 RGBA, solid visible bounds `(153, 32)–(950, 1492)`, 1,460 px visible height, projected boot delta 5.44 px at a 256 px review height. Hidden anatomy, rig pivots, motion and continuous seams remain NOT VERIFIED.
- Re-ran the full Godot prototype suite, candidate 09 static-image test, trial 05 v8 rig test, and 2,472 sampled contact checks across 206 poses at 60 Hz; all passed within their stated scope. The candidate 09, guarded-pose layer ownership and arm-mask audits also passed. The known non-fatal Godot user-log write warning persists.
- Evaluated the latest generated alpha-cleanup experiment without importing it. It retained 1024×1536 RGBA and the same alpha maximum (254); although its threshold silhouette IoU with candidate 09 is 0.995424, 1,370,832 RGBA pixels differ and 543,709 visible RGB pixels changed. It did not establish a clean cutout or preserve the source faithfully. REJECTED; no project art was replaced or added.
- Production-art gate remains NOT PASSED. The v8 split remains QA-only and is not a standalone arm asset. Continue art development from the approved candidate/reference direction with separate visible-pose and anatomy/rig gates.

## Candidate 03 / candidate 09 v2 anatomy verification — 2026-10-25 UTC

The user-approved visible boundary is external shoulder shell over biological upper arm, with the mechanical prosthesis beginning at the elbow. Candidate 03 passes the visible-fidelity regression against candidate 02 (silhouette IoU 0.9761, visible RGB MAE 17.65/255, maximum bounds drift 3 px). Candidate 09 v2 passes exclusive visible-layer ownership, exact neutral reconstruction, and the approved arm ROI check (5,796 warm-skin pixels on `cyber_upper_arm`; 0 on `cyber_forearm`). These results confirm visible fidelity and visible ownership only.

The hidden-anatomy audit for candidate 03 checks 664,937 layer pixels and finds **0 independently differing RGB pixels** against its flattened source. Candidate 09 v2 metadata records 297,686 underpaint pixels created by local color-axis extrapolation (64 px radius, 22 px sample offset) and explicitly marks `hidden_anatomy_verified: false`. Extrapolated color does not authenticate anatomy. Godot structure/contact tests do not alter this conclusion.

**Result: visible canon/fidelity checks PASS; hidden anatomy NOT VERIFIED; production-art gate NOT PASSED.** To close this gate, author real layered arm/shoulder components with anatomy continuing beneath the shell, separate pivots and overlap surfaces, then visually inspect continuous seams across the intended animation clips. Keep the current trials quarantined.

## Candidate 12 component board — 2026-10-25 UTC

Candidate 12 is a four-panel visual study with a biological upper arm, an isolated shell, a mechanical forearm/fist, and an assembled view. Manual inspection reads the approved shell-over-human-upper-arm / elbow-start-prosthesis boundary correctly. Its Python and Godot checks pass only RGBA/canvas/corner and panel-gutter structure (four high-alpha panel ranges). The board does not provide independent sprite files, pivots, hidden surfaces, or animation frames; it does not change the provenance result above. Full-body proportion matching still needs review. Hidden anatomy remains **NOT VERIFIED** and production art remains **NOT PASSED**.

## Latest evidence — 2026-10-25 UTC

The user's canon choice is explicit: an external shoulder shell sits over BREAKER's biological right upper arm; the mechanical prosthesis starts at the elbow.

Candidate 09 v4 separates visible skin from the shell and passes the source ROI audit: 5,796 warm-skin-classified pixels belong to the biological upper-arm layer, with zero in the shell or forearm. Fourteen exclusive layers reconstruct the thresholded source exactly. Godot structure/action and sampled-contact tests pass five actions and 206 neutral/60 Hz samples.

Candidate 09 v5 adds an inferred under-shell skin donor from a shell-removed generated study. The donor contains 18,066 selected skin pixels beneath the unchanged source shell, and adding it below the visible layers preserves the exact neutral composite. Its Godot test confirms registration to the bicep and shell through the same 206 samples. The shell-off board reveals a continuous human upper-arm volume, but its deltoid is rounder than the reference and source fragments remain around the cutaway. It requires visual review and must stay quarantined. The unrestricted generated image changed 1,382,917 pixels across the full 1024×1536 canvas and is rejected as replacement art.

**Conclusion:** visible canon boundary and source fidelity pass within scope. The concealed surface is reconstructed, not independently sourced or artist-authored. Biology accuracy, independent shell fit, pivots, continuous deformation, and production alpha remain **NOT VERIFIED**. Production-art/rig gate: **NOT PASSED**. No runtime references or remote binary uploads.

## BREAKER Tier I arm continuity audit — 2026-10-25 UTC

The user's approved boundary is implemented as a review-only layer assembly: external shoulder shell over a biological upper arm; the mechanical prosthesis begins at the elbow. Repeated Python audits pass the v4 14-layer exact neutral reconstruction and classify the bicep ROI as 5,796 skin pixels on the biological layer, zero on shell/forearm. The v5 donor contains 18,066 hidden-skin pixels beneath the original shell and keeps the neutral composite pixel-identical.

A new 8-connected mask audit joins the visible and inferred biological skin into a 27,550-pixel largest component; both substantial visible-skin regions (>=100 pixels) belong to that component. The generated QA overlay is 1120x674 RGB; two consecutive runs produced identical SHA-256 `C3343A9C46CF9C47F04887CE569BC52B4DD172F0ECFDB67CDD28695A871CF42A`.

Godot 4.7.2 passes the v4 layer/pose test, the 206-sample contact/registration test, the v5 hidden-donor registration test, and the full prototype `tests/test_runner.gd`. All report the known non-fatal `user://logs/godot.log` write warning. This verifies 2D mask connectivity and shared-bone registration only; it does not verify biological accuracy, independent shell deformation, pivots, full animation seams, or production alpha. The donor remains a quarantined hypothesis, the shell-off proportion review is unresolved, and the production-art gate remains **NOT PASSED**. No runtime references were added.

Local QA preview: `docs/visual_qa/BREAKER_T1_candidate09_v5_connected_anatomy_overlay.png`. Local Google Drive staging contains a review copy only; no remote binary upload is claimed.

## BREAKER candidate 09 underpaint fit trials v6–v9 — 2026-10-25 UTC

The approved visible arm canon remains external shoulder shell over biological upper arm, with the mechanical prosthesis starting at the elbow. The flattened candidate 09 shell-on composite remains exactly reconstructable; v4 assigns 5,796 classified bicep-skin pixels to the biological layer and zero to shell/forearm. The v5 inferred donor also preserves the thresholded visible composition and joins the major visible skin regions.

Four local trials attempted to improve the shell-off anatomical contour. v6 used a constrained generated edit and yielded 15,993 underpaint pixels (versus v5's 18,066); manual review still sees an inflated rounded deltoid and residual image fragments. v7 contracted the mask horizontally by 8%, retained exact shell-on compositing and connected visible regions (23,625-pixel largest component), but visual review rejected it because the contour change was insufficient and edges fragmented. v8 filled 591 pixels around the v6 mask; the 25,592-pixel connected surface passes, but the visual silhouette did not materially improve. v9 builds a continuous underlayer from visible v4 skin and v6 pixels beneath the existing shell/straps; it adds 698 hidden pixels, yields a 26,226-pixel connected surface, and preserves the exact visible composition. Manual review still does not accept its shell-off fit.

Godot 4.7.2 passes v4 structure/pose, v4 206-sample registration, v5 206-sample registration, v9 206-sample registration, and the full prototype suite. The repeated non-fatal `user://logs/godot.log` write failure remains. Python audits pass source fidelity/connectivity; review-board output is deterministic. All v5–v9 drafts remain in `.gdignore`d folders and none are referenced by runtime scenes/scripts/data.

The 2×2 review board is `docs/visual_qa/BREAKER_T1_underpaint_visual_review_matrix.png` (1328×1598 RGB; SHA-256 `17BA6693ED7D1E9E63E8BB7BF811A3CA6A8D0ED3453134D8109F4F5BD99587FA`). Current result: the shell-on candidate matches the approved visible direction and arm boundary; hidden surfaces remain inferred, shell-off shape is not accepted, and production-art/rig gate remains **NOT PASSED**. These experiments do not alter canon or runtime content.


## Trial 09 v13 generated shoulder-underlay — 2026-10-25 UTC

After v5–v9 shell-off studies were rejected for a bulbous shoulder and texture fragments, a new full-body shell-off reference study was generated using the approved candidate 09. Only 16,407 skin-classified pixels within the original v4 shell's opaque mask and upper-arm ROI were extracted. The shell-on reference composite remains pixel-identical under the project's alpha threshold. The combined visible and inferred biological skin has a 25,738-pixel largest 8-connected component.

Godot 4.7.2 confirms the v13 donor shares the bicep/shell transform across 206 neutral/60 Hz samples spanning idle, walk, punch, hit, and defeat. This is a registration test, not evidence of anatomical correctness or independent shell behavior.

The new shell-off board still contains inferred texture and shape and requires visual review. Keep v13 quarantined; hidden anatomy and production-art gate remain **NOT VERIFIED / NOT PASSED** until the donor is artistically accepted, its surfaces are authorable, and pivot/deformation/seam criteria pass. QA: `docs/visual_qa/BREAKER_T1_candidate09_v13_shoulder_donor_review.png`.


### v13 connected-mask refinement and independent-shell stress — 2026-10-25 UTC

A deterministic mask refinement selects the largest generated skin component within the arm ROI before clipping it to the opaque source shell. The resulting `hidden_biological_upper_arm_donor_v2.png` contains 16,464 pixels; exact thresholded shell-on composite passes, and visible+hidden skin's largest 8-connected component is 25,957 pixels. Godot confirms shared-bone registration at 206 neutral/60 Hz samples.

A separate OpenGL capture applies a 12-source-pixel shell shift, a 0.16-radian shell rotation, and shell hiding. Captures were produced with a stable ground anchor. They are stress diagnostics, not approved animation. Visual gaps and hidden-surface proportions still require review; the donor remains quarantined and production gate NOT PASSED. Preview: `docs/visual_qa/BREAKER_T1_v13_shell_independent_motion_stress.png`.


### v13 full-shell-mask underlay — 2026-10-25 UTC

A separate variant fills all 25,942 opaque pixels of the candidate 09 v4 shoulder-shell layer from the quarantined shell-off generated study. Python confirms exact thresholded shell-on reconstruction. Godot 4.7.2 registration passes 206 neutral/60 Hz samples; the OpenGL shell-offset capture passes anchor stability for baseline, +12 source pixels, 0.16-radian rotation, and shell-hidden views.

Full mask coverage is a stronger test of reveal coverage but can expose generated pixels that are not skin. The shell-off shoulder remains a visual hypothesis. No anatomy, motion style, or production asset has been approved from these results; keep the donor quarantined and the art gate NOT PASSED pending review. Preview: `docs/visual_qa/BREAKER_T1_v13_full_shell_independent_motion_stress.png`.


### v13 v5 generated correction recheck — 2026-10-25 UTC

The new correction is clipped to the complete opaque shell mask and leaves the visible source composite pixel-identical under the existing alpha threshold. It follows the same CyberShoulder transform as visible skin and shell in 206 neutral/60 Hz samples for idle, walk, punch, hit, and defeat. The full suite and OpenGL stress capture also pass.

Manual art review still rejects the exposed shape: it reads as an oversized, round shoulder relative to approved candidate 09. It therefore does not resolve the hidden-anatomy issue. The generated source and v5 donor remain quarantined; no production-art approval is claimed. See `docs/visual_qa/BREAKER_T1_v13_v5_shoulder_zoom_stress.png`.


### v13 v6 compact proportion trial — 2026-10-25 UTC

The v6 skin-classified donor is a diagnostic 82%-width hypothesis. Python verifies ROI/shell clipping and exact visible source reconstruction. Godot registration passes 206 samples and independent-shell OpenGL stress capture keeps the ground anchor stable. The narrower contour reduces bulk in the shell-hidden comparison, but generated texture seams remain and the visual direction has not been accepted. Keep quarantined and out of runtime. Preview: `docs/visual_qa/BREAKER_T1_v13_shoulder_shape_options.png`.


#### v6 continuity measurement

Combined visible skin and v6 donor: 20,723 classified pixels, 58 components, largest 20,505 pixels (98.9%). The result misses the prior 25,000-pixel threshold and includes detached flecks. This does not satisfy the current continuity screen; retain the v6 concept as review-only.


## Approved candidate01 hidden-arm reconstruction — 2026-10-25 UTC

The art authority is the user-approved `BREAKER_T1_profile_rebuild_candidate_01.png`, consistent with the live BREAKER Tier I mostly-human athletic description. The candidate09/v13 shoulder trials came from a non-approved reconciliation study and do not govern the final silhouette. The explicit arm boundary remains external shell over biological upper arm; the mechanical prosthesis starts at the elbow.

Candidate01 generated shell-off study yielded two quarantined cutouts. v2: one connected 21,108-pixel skin component with 6,383 opaque-pixel overlap to the mechanical forearm. v3: compact 72%-width, 15,219 pixels, 4,732 overlap. Both produce a single binary-alpha union with the mechanical forearm, preserve the source shell-on composite exactly under the 245 alpha threshold, and pass 206 Godot pose-registration samples.

These are generated/inferred surfaces, not artist-authored anatomy. The v3 contour is narrower and is the stronger proportion candidate, but review is still needed. Existing Trial 01 extracted sprites have known polygon-mask holes; their assembled shell-off diagnostic is not proof of visual fit. Separate shell art, authored pivots, independent motion, deformation and all-frame seam review remain unverified. Production gate **NOT PASSED**.

## Candidate01 elbow-boundary review addendum — 2026-10-25

New technical review found the old shell-off setup left shoulder-shell pixels inside `cyber_forearm.png`. The source layers have now been partitioned at the provisional y=495 elbow pivot for review: pixels above that row move with the shoulder shell; pixels at/below remain on the elbow-driven prosthesis. Two corrected generated underarm fits (slim/broad) pass exact neutral assembly and 2D elbow connectivity checks; Godot reports 412 sampled transforms passing. The old affine preview boards were incorrectly mapped and are superseded. The new fit options remain quarantined, with art acceptance pending.

### Godot elbow-contact validation addendum — 2026-10-25

`tests/test_breaker_profile_rig_trial_01_candidate01_fitted_arm_options.gd` now transforms opaque skin and forearm masks through the actual trial rig and checks 8-neighbor contact in an elbow region for each frame sample. Slim passes with 463–1,282 contact points across 206 frames; broad passes with 800–1,849 across 206 frames. Bone ownership and anchor checks pass for both. The full prototype suite passes as well. This is pose-sampled continuity evidence, not art-style approval, full interpolation coverage, deformation, or production readiness.

## Visual review disposition — 2026-10-25 UTC

Manual inspection of the corrected crop and 256 px full-body boards rejects both slim and broad fits. The exposed donor has visible texture/cutout seams and an oversized, style-mismatched contour compared with the approved candidate01 source. The technical connectivity checks are not art acceptance. Keep both variants quarantined; no shell-off hidden anatomy is approved. The approved visible rule remains external shoulder shell over biological upper arm, with the mechanical prosthesis starting at the elbow. A replacement must match the existing art style and be reviewed before rig promotion.
