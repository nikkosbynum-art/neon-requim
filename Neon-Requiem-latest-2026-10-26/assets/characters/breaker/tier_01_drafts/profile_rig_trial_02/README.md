# BREAKER profile rig trial 02

**Status:** quarantined visual feasibility trial; not production art and not used by runtime.

## Provenance

- Parent visual direction: user-approved `BREAKER_T1_profile_rebuild_candidate_01.png`.
- Source for this trial: `../BREAKER_T1_profile_cutout_candidate_02.png`, an image-generation background-removal result derived from the approved profile.
- Source canvas: 1024×1536 RGBA. The exported silhouette uses alpha >=245; transparent background pixels are present. The high-alpha silhouette bounds are x=239..791 and y=46..1472 (1427 px high).
- The generated cutout is a visually close match, but is a separate generated image with small rendering differences. It is not a pixel-preserving edit of candidate 01.

## Export and validation

`tools/art/export_breaker_profile_trial_01.py` now accepts explicit `--source` and `--output` paths; its defaults still point to trial 01. Trial 02 was exported to this new folder. The export reported 13 layers, 1024×1536 canvas, zero uncovered silhouette pixels, and exact neutral reconstruction of the alpha-thresholded trial 02 source.

`tests/breaker_profile_rig_trial_02_preview.tscn` and its Godot harness are an isolated copy of the trial 01 review rig. Idle, walk, punch, hit, and defeat are transform-plumbing samples using estimated pivots. These checks do not validate hidden anatomy, anatomical pivot placement, continuous seams, deformation, or production animation quality.

## Readiness limits

- The 13 hand-estimated masks follow trial 01's visible contour and may not fit generated micro-variations everywhere.
- Anatomy behind overlapping limbs remains unpainted.
- Hand/fist and foot/boot remain combined with adjacent parts.
- Pivots are estimates, not authored source data.
- A clean alpha cutout does not make the image animation-ready.
- Production-art gate remains **NOT PASSED**. Keep all files quarantined and out of runtime.
