# SPARK near-hand candidate art and rig review status 01

**Disposition: one source-pixel-preserving visible hand/glove candidate; keep quarantined.**

## Evidence

- Read `docs/CHARACTER_PART_AUTHORING_GUIDE.md` and reviewed the approved SPARK concept and anatomy turnaround together. Extraction uses only the right-facing side profile in `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- The near hand and fingerless glove form a distinct foreground cluster over the waist gear. The visible glove/hand contour and separated finger silhouettes support one source-only review part. The dark wrist closure remains merged with the glove because its split is not established; the silver forearm guard is excluded.
- Revision 01 was screened on a checkerboard and rejected after an orange equipment sliver appeared along the left edge. Revision 02 narrows that edge and received a second native-scale visual review.
- The revision-02 trace is `tools/art/trace_manifests/SPARK_T1_NEAR_HAND_PROFILE_CANDIDATE_02.json`. The exported PNG is canvas-aligned to the 1536×1024 anatomy source. All opaque pixels were independently checked against the source: 3,603 selected pixels and zero RGB mismatches. Neutral recomposition over the source crop had zero RGB differences. No hidden pixels, underpaint, or pivots were created. The cropped review board is in the task preview; candidate contact and ownership boards are `SPARK_T1_NEAR_HAND_CANDIDATE_02_CONTACT_QUARANTINED.png` and `SPARK_T1_NEAR_HAND_CANDIDATE_02_OWNERSHIP_QUARANTINED.png`.

## Mechanical and semantic limits

The alpha audit passed its provisional mechanical checks: one 4-connected component, 0 external low-alpha pixels, transparent corners, and ample margins. The contact sheet and ownership board show one named part and zero inter-part overlaps. These diagnostics do not establish a complete hand under motion. The hand/wrist pivot, forearm overlap, action pose, animation, and production gates remain open.

This is not a full SPARK part set. The arm segments, head/neck boundary, torso/harness/backpack, pelvis gear, leg/knee/boot boundaries, far-side anatomy, and concealed overlaps still need source-authored ownership or boundary evidence. Keep unresolved regions merged; do not infer hidden parts.

**Status:** static visible-part candidate only; semantic review remains scoped/provisional. `production_approved`, `pivots_authored`, `deformation_reviewed`, and `runtime_integrated` remain false.
