# SPECTER Tier I art and rig review status

Reviewed 2026-10-25. Scope: visible profile-side forearm plating only. No artwork, source manifest, or runtime scene was modified in this review.

## Evidence reviewed

- Approved concept: `docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy: `docs/visual_qa/SPECTER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Authoring constraints: `docs/CHARACTER_PART_AUTHORING_GUIDE.md`.

The side profile shows a bright metal forearm shell with red details. The visible wrist ring separates the shell from the glove, but at the upper end the shell adjoins dark sleeve/shoulder equipment and the cape silhouette. The approved views do not include labeled semantic layers or an authored seam map proving which adjoining dark pixels belong to the moving forearm assembly.

## Gate

**NO CUTOUT CANDIDATE CREATED; PART OWNERSHIP REVIEW BLOCKED.** A contour around the whole bracer would have to guess at the upper sleeve/cape boundary; isolating only its bright metal face would split the visibly assembled armor without an authored part plan. No polygon, pivot, hidden surface, or rig ownership was inferred.

**Artist input needed:** provide a source-scale transparent-layer pass naming the forearm shell as one part or identifying its separate plates, plus a seam map that marks the elbow-side and wrist-side boundaries and assigns any overlapping sleeve/cape pixels to their actual owner. Include the side profile and at least one front or back view in the same source canvas. Keep this armor fused to the reference until that input is available.

## Roster coordination

The project manager released the SPECTER and IRONCLAD reservation for this review lane. This note does not alter either character's approved visual direction or production status.
