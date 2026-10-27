# BREAKER Tier I Hidden-Arm Art Brief

**Status:** Provisional production brief. This document does not approve any generated study or define new canon for anatomy concealed by the armor.

## Authority

- Approved visual target: `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png` (1024×1536).
- Current approved arm boundary: the external right shoulder shell sits over a biological upper arm; the mechanical right prosthesis begins at the elbow and includes the forearm/fist. This was explicitly approved by the user on 2026-10-25 and is recorded in `docs/DESIGN_DECISIONS.md`.
- Written character specification: [Notion — BREAKER Character & Sprite Specification](https://app.notion.com/p/40394c5658c881edb7fae758125174f1).
- Production constraints: `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md`.
- The current candidate01 shell-off fits and the 2026-10-25 contextual cutaway study are rejected; they are quarantined reference studies only.

## Required result

Create a separate, transparent biological upper-arm part and a separate external shoulder-shell part that assemble over the approved candidate01 image without changing any unrelated pixels or silhouette. The biological arm must continue from the visible shoulder area to a clean elbow boundary; the mechanical forearm and fist begin at that elbow. Preserve BREAKER's approved paint style, contour quality, skin palette, lighting, scale, pose, and shell design.

Do not infer exact hidden anatomy proportions from the rejected generated studies. Use the approved image as the visual authority and keep the hidden shape marked as an art implementation choice until explicitly accepted. Do not redraw the face, vest, torso, pelvis, opposite arm, legs, boots, shell panels, or cybernetic forearm.

## Review gates

| Gate | Evidence required | Pass condition |
|---|---|---|
| Canon boundary | Full-body and arm-crop review | External shell is over biological upper-arm anatomy; mechanical prosthesis starts at the elbow. |
| Shell-on fidelity | Pixel overlay against candidate01 | The original visible composite and silhouette are preserved; no unrelated regions change. |
| Shell-off anatomy | Close crop at native scale and at 256 px gameplay height | A continuous biological upper arm is visible, with no generated texture seams, stray fragments, oversized contour, or ambiguous elbow transition. |
| Part readiness | Transparent PNGs and pivot metadata | Shell and upper arm are independent, clean-alpha parts on the 1024×1536 canvas with consistent source alignment. |
| Rig continuity | Godot captures/tests for idle, walk, punch, hit, and defeat | Shoulder shell follows shoulder motion; biological arm stays behind it; mechanical forearm starts at elbow; no visible gaps or detached pixels; ground anchor remains stable. |

Automated pixel, connectivity, and pose tests are necessary but not sufficient. A failed style/proportion review rejects the art even if those tests pass. A passing internal review remains a candidate until the user approves the visual result.

## Current evidence and disposition

- The explicit canon boundary is resolved and confirmed in the live Notion page on 2026-10-25.
- Candidate01 visible skin/shell layer partition reconstructs the source at the documented alpha threshold; it does not prove hidden anatomy.
- Slim and broad fitted underarms pass source reconstruction and sampled elbow-contact tests but fail visual fit because of generated-texture seams and mismatched proportions.
- `candidate01_upper_arm_cutaway_study_v1.png` depicts the boundary but changes shell details and exaggerates the upper-arm mass; it is not rig-tested.
- Two later isolated anatomy generations (one arm-only, one conditioned on both the full-body reference and arm crop) were rejected for oversized, bodybuilder-like proportions and style mismatch. Neither was imported into the project or rigged.
- A hand-authored SVG underlay trial is source-aligned and fully hidden by approved source layers when assembled. It passes 206 sampled elbow-contact frames and keeps shell-on appearance unchanged. Shell-off styling and proportions are awaiting visual review; do not promote it yet.
- No candidate currently passes all five gates. The production-art gate remains **NOT PASSED**.

## Latest underlay review — 2026-10-25 UTC

The user-approved boundary is explicit: external shoulder shell over a biological upper arm; prosthesis begins at elbow and includes forearm/fist. Candidate01 vector v1 and 18%-opacity source-texture v2 underlays both fail shell-off visual review. V1 reads flat/detached; v2 remains swollen/detached and shows stray/doubled texture marks. Their shell-on composite remains visually unchanged, and Godot sampled contact/registration tests pass, but neither result establishes artistic correctness. Both remain quarantined. No candidate passes the complete review gates; production art remains **NOT PASSED**.

## Candidate01 contour direction remains unresolved — 2026-10-25 UTC

The canon boundary is settled; the hidden contour is not. A compact vector v2 passes shell-on source fidelity and sampled elbow contact but looks too flat and does not convincingly join the visible shoulder skin and prosthetic elbow. Same-source skin v1 is too narrow/detached; source-texture v3 adds streaks; generated studies are oversized and style-mismatched. All remain quarantined. The comparison board is `docs/visual_qa/BREAKER_T1_underarm_review_options_2026-10-25.png`. Seven Godot variants pass scoped checks over 1,442 pose samples and the full prototype suite passes, but the art gate remains **NOT PASSED**.

## Compact v4 follow-up — 2026-10-25 UTC

A narrower 84%-width contour with low-opacity same-character skin texture is the latest provisional option. It passes shell-on pixel fidelity and 206 sampled rig/contact frames (186–374 contact pixels), but shell-off visual review still fails due to vector-like rendering and visible texture streaking. The approved arm boundary remains settled; no hidden contour is approved. Keep the trial in the ignored draft folder and out of runtime. The updated comparison board is `docs/visual_qa/BREAKER_T1_underarm_review_options_v4_2026-10-25.png`.

## Mapped texture v5–v6 — 2026-10-25 UTC

The compact silhouette now has two generated-texture mappings. v5 remains too smooth; v6 distorts the anatomy with crosswise shading. Both are rejected and quarantined. Godot passes ten alternatives across 2,060 sampled pose checks, with exact shell-on image coverage; the full prototype suite passes. This does not certify shell-off visual quality. The approved arm boundary remains unchanged; hidden-arm proportions/art remain open. See `docs/visual_qa/BREAKER_T1_underarm_review_options_v6_2026-10-25.png`.

## Constrained painted underlay v7 — 2026-10-25 UTC

V7 combines the compact v2 silhouette with generated paint constrained to that silhouette. It preserves exact shell-on source coverage and passed sampled shoulder/elbow contact across 206 frames per variant. Godot's full prototype suite passes. Native-scale shell-off review nevertheless reveals a jagged shoulder-wrap fragment and an ambiguous biological-arm join. V7 is rejected as production art and stays quarantined. A subsequent standalone generated arm also overshoots the target scale/style and was not imported. The headless capture attempt cannot provide visual evidence because the dummy renderer has no viewport texture; existing OpenGL captures are the visual source. The arm boundary is approved, while hidden anatomy proportions, clean parts, and continuous animation deformation remain open.

## Source-mask and torso attachment review — v8–v10, 2026-10-25 UTC

The v8 main-component split and v9 warm-skin split preserve the original source composite exactly, but they do not clean the connected upper edge enough to change shell-off readability. A shell-toggle comparison exposed a 60–80 source-pixel gap between the underarm and torso. V10 widens the underlay under the torso: a Python audit reports 1,410 opaque overlap pixels; the Godot focused suite now checks torso coverage as part of shell-on fidelity and passes v10 with zero exposed pixels. Twelve variants pass 2,472 sampled pose frames; v10 retains 191–370 contact pixels. OpenGL captures pass five poses and the ground-anchor check. Gameplay-scale rendering reads connected, but the close-up still shows stretched paint. V10 remains provisional and quarantined pending visual acceptance; none of these files are production art or runtime assets.

## V10 close-up rejection — 2026-10-25 UTC

V10 closes the torso gap in a gameplay-scale capture, but close-up visual review rejects its shape: row-wise stretching warps the muscle planes, creates a sharp inward kink, leaves colored edge specks, and does not remove the elbow seam. Its structural tests remain valid but do not pass artistic review. Keep v10 quarantined and do not promote it. No current candidate passes all art gates.

## Under-vest socket v11 rejection — 2026-10-25 UTC

V11 keeps v7's arm silhouette and extends its inner edge to the torso using adjacent edge samples. The Python audit reports 11,148 added pixels and no shell-on exposure; Godot passes 2,678 sampled contacts/registrations across 13 variants, and the full prototype suite passes. Native-scale shell-off review shows conspicuous horizontal texture streaks. Reject v11 as art. Structural tests remain useful only for coverage, bone ownership, and sampled elbow contact. No candidate passes the full art gate.

## Generated donor fit v12–v15 — 2026-10-25 UTC

The localized v12 shell-on edit drifts from the approved prosthesis and source pixels; reject it as replacement art. The v13 shell-off edit overstates upper-arm mass; use only its painted skin as donor material. Fitted v14 is shell-on occluded but loses elbow contact in defeat (10 px vs. 25 px minimum). Tapered v15 passes sampled contact (104–268 px across 206 frames), exact underlay occlusion, five-pose OpenGL capture, and full prototype tests. Visual review still flags the shell-off shoulder/axilla join for owner/art review. Neither v14 nor v15 is approved production art; no runtime references were added.
