# STITCH Tier I equipment and coat review 01

**Status:** SOURCE REVIEW ONLY / QUARANTINED. No semantic cutout, approved art, pivot, mount, or runtime behavior is created by this review.

## Sources inspected

- Approved concept reference: `docs/visual_qa/STITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Approved anatomy turnaround: `docs/visual_qa/STITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Existing profile-mesh candidate: `assets/characters/stitch/tier_01_drafts/profile_mesh_rig_candidate_01/`
- Attachment behavior limits: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`
- Part authoring gates: `docs/CHARACTER_PART_AUTHORING_GUIDE.md`

## Visible evidence

- Both approved views show a separate carried medical case. It appears in different hands/positions between the concept and turnaround, but the images do not establish a carry transition, grip pose, or mount pivot.
- A red vial is visibly held aloft in the concept and in the profile anatomy view. Fingers overlap the vial at its grip; the obscured vial surface and exact hand attachment point are not available in the flattened source.
- The long white coat has visible front panels and a rear panel in the back view. Its front surfaces overlap the torso, belt, and legs; a complete independent sheet and hidden continuation under these occlusions are not supplied.
- The back assembly is visible in all views, with equipment and hoses. Its internal ownership, motion, and full attachment boundaries are not documented by the flattened art alone.
- The existing profile-mesh candidate is a single flattened profile. It does not provide semantic case, vial, coat-panel, harness, or back-assembly layers.

## Intake decision

**Do not extract rigging parts from these flattened references yet.** The case and vial are individually recognizable, but their hand-overlap boundaries hide the grip surfaces needed for complete, usable attachment art. The coat panels and back assembly are also occluded by the body and other gear. A pixel mask can preserve only what is visible; it cannot create complete surfaces behind those overlaps. No additional handheld tool is visible, so none is added.

## Prerequisites before art extraction or rigging

1. Supply complete case and vial layers, including the portions naturally hidden by the hand, with artist-authored grip/mount pivots. Keep these as separate semantic items.
2. Supply front and rear coat layers with an explicit seam/overlap plan and any inferred hidden fill identified as inferred. Preserve the authored coat silhouette.
3. Provide a reviewed ownership map for the back assembly, harness, hoses, and carried containers before splitting layers; record endpoints for any physical hose that is to deform.
4. Confirm the intended supported case-carry state(s) from authored poses. Do not add a tool-use animation or ability cue from appearance alone; any cue must be driven by the simulation event contract.

## Disposition

The revision-02 OpenRaster remains edit-prep with blank layers. No candidate PNG was made, no candidate was promoted, and no rig/runtime status changed. This review is not a pass for visual assembly, animation, or production readiness.
