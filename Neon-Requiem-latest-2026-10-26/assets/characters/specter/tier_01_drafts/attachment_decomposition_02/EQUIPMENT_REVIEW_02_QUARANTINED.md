# SPECTER Tier I equipment and cloth review 02

**Status:** SOURCE REVIEW ONLY / QUARANTINED. No semantic cutout, approved art, pivot, mount, or runtime behavior is created by this review.

## Sources inspected

- Approved concept reference: `docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Approved anatomy turnaround: `docs/visual_qa/SPECTER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Existing profile-mesh candidate: `assets/characters/specter/tier_01_drafts/profile_mesh_rig_candidate_01/SPECTER_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png`
- Attachment behavior limits: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`
- Part authoring gates: `docs/CHARACTER_PART_AUTHORING_GUIDE.md`

## Visible evidence

- The concept shows a long, glowing blade in the forward hand. The blade body and pointed tip are visible, while the glove overlaps the hilt/grip area. The approved anatomy turnaround shows a sheathed-looking handle at the hip in profile; the images do not establish how the held and hip-mounted depictions relate over time.
- Both approved views show a broad, continuous torn cape/cloak. Its outer silhouette is visible, but the cloth crosses over the shoulder, arm and torso. The flattened images do not reveal a complete independent cape boundary, hidden cloth behind the body, or independently moving cape panels.
- The hood and face mask are recognizable, but their lower edges overlap the scarf/cape around the neck. No complete clean separation boundary is supplied for those overlapping surfaces.
- Existing profile mesh is one flattened profile cut from the anatomy view. It is not an equipment source and contains no semantic sword, hood, mask, or cape parts.

## Intake decision

**A small source-visible sword cutout now exists, but it does not clear the ownership/completeness gate.** Candidate 01 contains only the exposed hilt above the glove and the exposed guard/blade body, traced separately from the approved concept. The glove and source-hidden grip remain excluded. The hip handle/sheath relationship is unresolved, so this is not a complete weapon assembly and has no authored grip or sheath pivot. A complete cape still requires resolving concealed surfaces behind the body; hood/mask separation still needs a reviewed neck overlap boundary. A traced visible silhouette alone does not establish a rig-compatible part.

## Prerequisites before art extraction or rigging

1. Obtain an authored SPECTER sheet that shows the sword’s complete grip, guard and blade, plus the hip handle/sheath state, or have an artist confirm which visible depiction is the same weapon and supply the missing pixels.
2. Author the cape as a complete independent layer with the body occlusion resolved. Preserve one continuous torn silhouette; do not split ragged edges into panels. Mark any reconstructed hidden region as inferred and review it at gameplay scale and in poses that expose it.
3. Supply a neck/hood/mask overlap drawing or artist-approved layer boundaries before separating those pieces.
4. After parts exist, author and review weapon grip and sheath pivots, hood/mask ownership and depth, and the cape’s attachment/cloth pose plan. Runtime cues must follow the simulation event contract; no cadence, draw/stow transition, cloak timing, or effect behavior is inferred here.

## Disposition

The revision-02 OpenRaster remains an edit-prep workspace with blank layers. `attachment_cutout_candidate_01/` contains two source-pixel sword fragments and two diagnostic boards; it remains quarantined, partial, and excluded from rigs/runtime. The ownership board shows 0 shared pixels between the two masks. No hidden grip pixels were invented and no pivots were authored. Cape/hood/mask work, held/stowed relationship, attachment motion, and semantic completeness remain unresolved. No candidate was promoted; this review does not pass visual assembly, animation, or production readiness.
