# BULWARK Tier I helmet medical-marking panel — candidate 01 review

**Status: SOURCE-PIXEL REVIEW CANDIDATE / QUARANTINED.** This is a static visible surface-detail cutout, not an independent rig piece, production art, or runtime asset.

## Source and visual evidence

- Reviewed the approved Tier I concept and anatomy turnaround together: `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` and `docs/visual_qa/BULWARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- The front helmet view contains one fully visible, clearly readable red medical cross on its small light helmet panel. The candidate preserves only the source pixels in this visible marking region; it adds no hidden surface, backplate, or pivot.
- Candidate image: `BULWARK_T1_HELMET_MEDICAL_CROSS_DECAL_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png`.
- Source selection rectangle: `[315, 58, 355, 98]`; nontransparent bounds map to source `[325, 66, 346, 88]`.
- Candidate manifest records null pivot and all production, animation, and runtime gates false.

## Validation and limits

`source_fidelity_report.json` reports PASS for source hash, exact RGB preservation (`0` mismatches), one main connected region plus a separate four-pixel lower-edge detail, transparent safety margin, and no external alpha halo. The small detached lower-edge detail is retained because it is visible in the source; the report does not decide its semantic meaning. This review confirms only the visual source-pixel mapping. The decal-versus-helmet-panel construction and gameplay-scale readability still need human art review. Keep quarantined and attach it to the helmet surface if later authored; do not give this static marking its own invented pivot.

## 2026-10-25 bounded source-context review

Compared the quarantined cutout with the approved concept and anatomy turnaround at source scale. The red medical marking is visible on the helmet in the approved source, and the existing source-fidelity report records zero RGB mismatches. The candidate is a static surface detail, not an independently moving rig part; the flattened view does not establish whether its white backing is a decal or part of the helmet panel, so no separate pivot or component movement is supported.

The opaque bounds are 21×22 source pixels. At a nominal 256/1536 scale this is about 3.5×3.7 pixels; this is a calculation from the shared reference-height target, not an in-context gameplay capture. The crop alone cannot establish gameplay readability. **Disposition remains partial and quarantined:** if the front-view mark is retained, first map it to a side-facing authored helmet layer or explicitly keep it front-view only; then review an assembled neutral pose at 1280×720 and 800×450. The source does not support placing the front-view crop onto the right-facing profile. No source or candidate art was changed; no pivot or production/runtime gate was set.

## 2026-10-25 front-view context-scale review

Created two quarantined reference boards using only the approved front-view anatomy reference and the existing candidate: `BULWARK_T1_HELMET_MEDICAL_MARK_CONTEXT_REVIEW_01_1280x720_QUARANTINED.png` and `BULWARK_T1_HELMET_MEDICAL_MARK_CONTEXT_REVIEW_01_800x450_QUARANTINED.png`. Both boards normalize the reference figure to 256 px high before fitting the board to the named canvas. The existing opaque mark bounds are 21×22 source pixels, which scale to approximately 5.8×6.1 px on the 1280×720 board and 3.6×3.8 px on its 800×450 downscale. The inset is an 8× inspection view and is explicitly not viewport scale.

This is a reference-context scale check, not an assembled in-game capture or gameplay-readability pass. At this size, the mark occupies only a few pixels; this board cannot establish whether it remains legible in motion or against runtime rendering. It uses the front view only and does not project the marking onto the right-facing profile. Decal-versus-panel ownership and gameplay-facing surface visibility remain unresolved. Candidate pixels, source art, pivot, manifest readiness, and runtime assets were not changed; the candidate remains quarantined.

## Right-facing gameplay-camera comparison

Also compared the candidate's front-view source region with the existing right-facing neutral profile capture `docs/visual_qa/founding_t1_mesh_rig_pose_capture_candidate_01/bulwark_neutral.png`. The approved reference supports the front-facing helmet cross, but the side profile/capture does not establish a matching visible helmet-mark surface for the in-game facing. Treat the cutout as a front-view source detail only; do not add it to the right-facing runtime profile or infer a projection/placement from this crop. A side-facing authored helmet layer or explicit multi-view mapping would be required before a gameplay-scale readability review. The candidate remains quarantined.

## 2026-10-26 ownership clarification

The user approved that the white backing behind the medical cross belongs to the helmet panel. This supersedes the earlier unresolved decal-versus-panel question for the backing only. It does not set the semantic cutout boundary or define a red-mark/backing layer split, profile projection, independent pivot, or production status. The existing crop remains quarantined; do not project it onto the right-facing profile without source-backed authored mapping.
