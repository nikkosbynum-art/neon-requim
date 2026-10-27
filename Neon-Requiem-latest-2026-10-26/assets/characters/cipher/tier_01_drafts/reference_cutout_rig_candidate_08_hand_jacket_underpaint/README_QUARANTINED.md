# CIPHER Tier I candidate 08 — inferred hand/jacket continuity study

Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. Candidate 07 is unchanged.

Candidate 07 already assigns visible hand pixels exclusively to `near_hand`; a read-only source-alpha overlap check found no shared hand pixels in `pelvis_belt_gear` or `torso_jacket`. Candidate 08 preserves those source-derived parts and adds a separate flat charcoal underpaint only beneath the current hand silhouette. The fill is labeled inferred because the approved source is flattened. It uses a neutral charcoal fallback (RGB 38,39,43), not copied source pixels. It contains no authored texture and does not establish deformation coverage. It is hidden in the neutral assembly.

The user accepts this approach for now at the expected display scale. Static 256 px reference-height previews and native semantic review boards are listed in `parts_manifest.json`. The overlapping knee guard remains an open ownership decision; no leg pixels were changed. Candidate 08 remains quarantined. Gameplay motion review, hidden surface shape, pivots, deformation, far-side anatomy, and production readiness remain NOT VERIFIED.
