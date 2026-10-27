# SPARK near-hand candidate art and rig review status 01

**Disposition: rejected extraction history; keep quarantined and do not use.**

## Evidence

- Read the character-part authoring guide and reviewed the approved SPARK concept and anatomy turnaround together. The body-part trace uses only the right-facing side profile in `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- The visible near hand and fingerless glove form a distinct foreground cluster over the belt/pouch. The visible hand/glove contour, open finger gaps, and wrist interface support one source-only review part. The dark wrist closure is conservatively merged with it; the separate silver forearm guard is excluded.
- The single trace is in `tools/art/trace_manifests/SPARK_T1_NEAR_HAND_PROFILE_CANDIDATE_01.json`. It preserves selected source RGB, but the first native-scale checkerboard screen found adjacent orange equipment included on the hand's left edge. This candidate is rejected. The revised trace is in `tools/art/trace_manifests/SPARK_T1_NEAR_HAND_PROFILE_CANDIDATE_02.json`; see the revision-02 candidate review record.

## Open gates

This rejected candidate does not establish a full hand under deformation, a wrist pivot, forearm overlap, or an action pose. The arm, head/neck boundary, torso and harness, backpack, pelvis gear, leg/knee/boot boundaries, far-side anatomy, and hidden surfaces still lack a complete artist-authored semantic split. Keep inseparable regions merged and list their missing ownership/boundary evidence rather than forcing further cuts.

**Readiness:** source-pixel correspondence alone did not prevent semantic contamination. Revision 01 is rejected. Pivot, deformation, animation, production, and runtime gates remain false. No runtime scene or other character asset changed.
