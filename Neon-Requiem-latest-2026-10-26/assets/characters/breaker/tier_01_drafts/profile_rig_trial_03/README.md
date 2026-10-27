# BREAKER profile rig trial 03

**Status:** quarantined image-generation fidelity experiment. Not production art and not used by runtime.

## Source and fidelity

- Candidate 03 is a built-in image-generation edit of the transparent approved-direction cutout candidate 02. It was prompted to extend anatomy behind occlusions while preserving visible art and a transparent background.
- The image is still one flattened full-body image. The hidden regions cannot be independently inspected or proven from this flat composite; this trial must not be described as having verified hidden anatomy.
- `tests/test_breaker_profile_fidelity_03.gd` compares the high-alpha silhouette and visible RGB with candidate 02. The local gate requires silhouette IoU >=0.97, visible RGB mean absolute error <=20/255, and high-alpha bounds within 4 px. Human visual review is still required for identity and detail fidelity.

## Rig trial

The separate 13-layer export uses the existing deterministic profile exporter and estimated pivots. Its neutral composite must reconstruct candidate 03's alpha-thresholded silhouette exactly. `tests/breaker_profile_rig_trial_03_preview.tscn` and associated tests exercise isolated idle, walk, punch, hit, and defeat transform channels at the 256 px visible-height review scale. The six-profile capture repeats this BREAKER art and is a readability fixture, not six distinct recruits or a runtime formation.

## Limits

Visible-shape similarity does not prove the quality or completeness of occluded under-paint. Pivots are estimated; masks reuse the profile contour; the hand/fist, foot/boot, and head/neck remain combined; continuous seams and mesh deformation are not validated. **Production-art gate remains NOT PASSED.** Keep this folder quarantined.

## Hidden-anatomy audit correction — 2026-10-24

The targeted pixel-provenance audit found that all 664,937 opaque pixels across the 13 exported layers reuse RGB from the flattened source at the same coordinates. 173,588 pixels are covered by two or more masks, but that is duplicate source color, not independent hidden under-paint. The script reports **HIDDEN ANATOMY NOT VERIFIED** (expected exit code 2). The generation prompt asked for hidden anatomy; it did not prove it was produced. This trial cannot be considered a correct deformation-ready rig. See `docs/BREAKER_HIDDEN_ANATOMY_AUDIT.md`.
