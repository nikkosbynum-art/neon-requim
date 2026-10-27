# BREAKER Tier I modular review extraction 01

Status: FAILED source-faithful split attempt; unusable for rigging. Kept quarantined for audit history only.

Source body: `../BREAKER_T1_full_anatomy_trial_03.png` (1024 × 1536 RGBA). The source is one flattened guarded pose with the arms crossing/overlapping the torso and the legs posed together. Hidden anatomy is not present in the pixels, and there are no painted separation boundaries or pivot annotations. A clean, source-faithful modular split with joint overlap margins cannot be made safely from this image without inventing missing anatomy.

The existing `../BREAKER_T1_modular_review_atlas_01.png` was generated as an exploratory 6 × 3 grid and does not preserve the exact source anatomy; it includes substitute/reinterpreted pieces and visible halo/background treatment. The 18 PNGs here are fixed-cell crops of that generated atlas, not valid parts. Each crop is 256 × 341/342; this only proves the grid cell dimensions, not the component scale.

Mapping (row-major): head, hair, torso_vest, pelvis, neck_regulator, spine_cable, upper_arm_l, forearm_l, hand_l, upper_arm_r, forearm_r, fist_r, thigh_l, shin_l, boot_l, thigh_r, shin_r, knee_brace_l.

Read-only checks: 18 files exist; all crops are 256 × 341 or 256 × 342; each crop's four corners have alpha 0. Several visible bounds touch cell edges (including head/hair, arms, torso, and lower limbs). The atlas cannot provide source-faithful component scale, pivots, or overlap seams. No neutral assembly was attempted because the input parts are invalid; the oversized knee brace also conflicts with Tier I.

Do not import into runtime. Do not use these crops for an animation rig. Steps 1 and 2 are failed/incomplete; animation deformation testing is blocked. A usable source must provide a neutral, fully visible anatomy turnaround or separately authored parts with clean joint overlap and explicit pivots. Then establish scale and neutral assembly before animation testing.

## Follow-up source check — 2026-10-24

A newer neutral-pose preview and two generated atlas revisions were checked for a source-faithful crop path. The neutral pose retains 521,187 partially transparent pixels around the character (exact 1024×1536 scan) and cannot serve as clean transparent part art. The refined 18-cell atlas has 0/18 cells with an 8 px alpha-clear margin; cell bounds touch or approach edges and semi-transparent haze reaches cell borders. No new crops or rig were made. The earlier crops in this folder remain failed audit artifacts only.
