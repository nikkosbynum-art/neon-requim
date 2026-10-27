# SPARK Tier I near-hand profile cutout candidate

**Status: QUARANTINED REVIEW CANDIDATE. Not rig input, runtime art, or production-approved.**

## Scope

This candidate contains one canvas-aligned cutout: `near_hand_glove`, traced from the near-side hand in the approved right-facing anatomy profile. It groups the visible hand, fingerless glove, and attached dark wrist closure into one static semantic unit. The separate silver forearm guard and adjacent belt/pouch pixels are excluded. The approved concept sheet was used only as visual-direction context; no concept-sheet pixels were extracted.

Revision 01's checkerboard review exposed a sliver of neighboring orange equipment along the left edge. Revision 02 narrows that boundary; revision 01 is retained as rejected extraction history. The cutout preserves source RGB for every selected pixel. It contains only currently visible source pixels: no hidden hand, palm, finger, arm surface, or underpaint was added.

## Review limits and blockers

- This is a single-part intake, not a complete SPARK semantic part set.
- The wrist pivot, forearm seam, deformation, and action pose are not authored or approved.
- The second hand, shoulder/elbow parts, torso/harness/backpack, lower-body parts, far-side anatomy, and concealed overlaps remain unresolved. Do not split them from this flattened reference by guesswork.
- Source-pixel equality and a clean alpha screen do not establish full semantic completeness, animation readiness, or production suitability.

Polygon provenance, source hashes, dimensions, alpha bounds, and the null pivot are recorded in `parts_manifest.json`. The source trace is `tools/art/trace_manifests/SPARK_T1_NEAR_HAND_PROFILE_CANDIDATE_02.json`. See `ART_RIG_REVIEW_STATUS_01.md` for the scoped review. The parent Tier I draft folder and this candidate are excluded from Godot import.
