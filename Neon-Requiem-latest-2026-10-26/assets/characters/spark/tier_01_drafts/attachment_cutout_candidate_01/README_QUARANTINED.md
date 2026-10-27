# SPARK source-derived prop cutout candidate

**Status: REFERENCE-DERIVED REVIEW CANDIDATE / QUARANTINED.** These static cutouts come from a flattened approved visual reference. They are not rig-ready or runtime art.

Source: `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` (SHA-256 in `candidate_manifest.json`).

The extraction keeps foreground pixels connected to explicit object seeds. All three visible silhouettes were reviewed at native scale over a checkerboard; the source-fidelity report records exact visible RGB preservation, zero pairwise mask overlap, clean alpha margins, and one contour per item. Provisional pivots author-placed on each visible central sensor/core are recorded separately in `attachment_pivots_review_01.json`; see `docs/visual_qa/SPARK_DRONE_CANDIDATE_01_PIVOT_REVIEW_01_QUARANTINED.png`. These are still quarantined static cutouts. Hidden surfaces, rotor articulation, flight/formation, combat event mapping, runtime integration, and production approval remain unverified.

## Source alignment and view coverage review — 2026-10-25

An independent comparison against the locally approved anatomy reference reproduced exact RGB correspondence for every nontransparent candidate pixel: zero mismatches for blue, red, and amber, with opaque-pixel counts matching `candidate_manifest.json`. Visual inspection found the complete visible drone silhouettes retained, with no visible crop truncation. The nearest opaque pixel to the source sheet's right edge is 16 px (blue), 31 px (red), and 19 px (amber). These are source-image margins, not added safety padding.

The concept and anatomy references show the three drones in near-frontal views only. They do not establish profile or rear geometry, hidden surfaces, rotor articulation, or other moving-component rules for the game's side-view presentation. Request artist-authored side and rear views plus an articulation note before resolving those questions. This review does not add inferred geometry, validate pivots, or approve animation or production. All candidates remain quarantined and absent from runtime.
