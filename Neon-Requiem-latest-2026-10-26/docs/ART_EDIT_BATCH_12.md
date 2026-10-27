# Tier I art edit batch — twelve recruits

**Status — current workspaces opened read-only in Krita on 2026-10-25:** All 12 current `attachment_decomposition_01` / `_02` workspaces opened without repair prompts. Their anatomy references and canvas dimensions matched the per-character plan; concept references remain hidden, and the blank layer state is confirmed by the all-12 archive audit. No workspace was edited or saved. This is an application-open check, not a save/reopen round-trip. All `.ora` files remain quarantined edit prep, not finished sprite art or production rigs. Semantic anatomy, part ownership, pivots, deformation, and rig compatibility remain unverified. The current workspace paths and layer guidance are in [`ATTACHMENT_DECOMPOSITION_BATCH_12.md`](ATTACHMENT_DECOMPOSITION_BATCH_12.md); first-pass equipment notes below are historical and superseded where those documents differ.

**Round-trip observations:** All 12 original `edit_batch_01` workspaces (ECHO's later `edit_batch_02`) opened in Krita. The 11 1536×1024 workspaces displayed their expected turnaround reference. BREAKER opened at its listed 1024×1536 canvas and displayed the profile rebuild reference; the concept production board remains a separate file because its dimensions differ. No repair prompt appeared. Do not interpret this open check as art approval or a completed save/reopen round trip.

**Current workspace pointer (2026-10-25):** The original edit batches and first attachment-decomposition batch are preserved. Seven characters now use reviewed version-02 workspaces; the other five use version 01. Use the per-character path table in [`ATTACHMENT_DECOMPOSITION_BATCH_12.md`](ATTACHMENT_DECOMPOSITION_BATCH_12.md) and the paired-reference observations in [`ATTACHMENT_REFERENCE_REVIEW_12.md`](ATTACHMENT_REFERENCE_REVIEW_12.md). Every current file is still blank authoring prep and remains quarantined; the current batch has not passed a Krita round-trip.

## Repeatable preflight

Before an art-edit session, run `tools/art/validate_character_art_pipeline.ps1` from the project root. It runs the preflighted Python suite, verifies all twelve OpenRaster workspaces and source/attachment plans, then runs Godot's headless regression suite. The Godot suite includes ten flattened profile-mesh preflights plus the CIPHER candidate-07 and SPARK drone review-input checks.

A passing result means the files, manifests, workspace layers, and test mesh inputs are structurally usable. It does **not** pass the semantic-art, hidden-anatomy, pivot, deformation, attachment-behavior, or production gates. Keep candidates quarantined until the corresponding visual and rig reviews pass. The full roster mapping of source-backed attachment behavior and unresolved details is in [`ATTACHMENT_FUNCTION_CONTRACT.md`](ATTACHMENT_FUNCTION_CONTRACT.md); consult it before assigning attachment event triggers or claiming that an item functions.

## Batch workflow

1. Open each listed `.ora` in Krita. Confirm it opens without a repair warning, canvas dimensions match, the anatomy reference is visible, concept reference is hidden/available, and no blank `ART -` or `ATTACHMENT -` layer contains pixels.
2. Inspect the reference at 100% and fit-to-canvas. Confirm source identity, left/right orientation, and which gear is on-body, hand-held, stowed, tethered, or independently moving. Record discrepancies before painting.
3. Work on the named semantic body/equipment layers. Keep unsupported hidden anatomy or pivots explicitly provisional. Do not turn a concept detail into an unapproved mechanic.
4. Save edited work as a new `.kra` alongside the source with suffix `_WORKING_01.kra`; never save over the `.ora`, reference PNGs, or quarantined candidates. If a layer cannot pass visual review, keep the `.kra` quarantined and record the issue.
5. After art edits, export transparent parts separately and update the per-character manifest with source, size, alpha bounds, owner instance/role, authored anchor/pivot, draw order, and status. Then assemble and test in Godot.

## Historical workspace inventory and character-specific attachment review

The following paths document the preserved original batch. Use the current paths in [`ATTACHMENT_DECOMPOSITION_BATCH_12.md`](ATTACHMENT_DECOMPOSITION_BATCH_12.md) for the next art session.

### BULWARK

- Workspace: `assets/characters/bulwark/tier_01_drafts/edit_batch_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/BULWARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Concept embedding: hidden reference layer in the workspace.
- Blank equipment layers:
  - medical backpack as separate body attachment
  - medical hoses/cables with explicit endpoints and no joint tearing
  - carried rifle with hand/back mount and tested grip
  - medical insignia and life-support gear as separate visual overlays
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### BREAKER

- Workspace: `assets/characters/breaker/tier_01_drafts/edit_batch_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1024×1536
- Anatomy/target: `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png`
- Concept: `migration_package/drive_assets/concept_art/04_breaker_production_board.png`
- Concept embedding: not included because canvas size differs; open separately in Krita: `migration_package/drive_assets/concept_art/04_breaker_production_board.png`.
- Blank equipment layers:
  - external right shoulder shell over biological upper arm
  - biological right upper arm ending at the elbow boundary
  - mechanical right forearm and signature fist starting at the elbow
  - neck neural regulator, spine/back accessories, and cables
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### CIPHER

- Workspace: `assets/characters/cipher/tier_01_drafts/edit_batch_01/CIPHER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - hacked rifle and optics as a detached hand/back attachment
  - backpack mount as a separate back attachment
  - hood/optic/collar equipment separated only where the source supports it
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.
- Additional CIPHER review iteration: `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/` contains ten source-derived profile cutouts, a source-aligned neutral assembly, and `CIPHER_T1_PART_AUTHORING_WORKSPACE_06_QUARANTINED.ora`. Candidate 06 adds source-pixel overlap at the thigh/shin and shin/boot seams (3,520 and 1,800 shared thresholded pixels). The ORA opens in Krita; candidate parts start hidden. Native-scale contact sheet: `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_06_QUARANTINED.png`; ownership overlay: `docs/visual_qa/CIPHER_T1_PART_OWNERSHIP_MAP_06_QUARANTINED.png`. The 882px torso island tracks the rear jacket outline and remains provisionally mapped to `torso_jacket`; semantic approval, pivots, hidden anatomy, deformation, and production approval remain open.
- Current knee-guard review iteration: `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/`. The user approved the visible guard owner/boundary and lower-hinge pivot `(770,665)` source / `(77,115)` part-local. Godot's rigid diagnostic is `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_GUARD_MOTION_07_QUARANTINED.png`; neutral knee-region composition matches exactly. This is not an authored animation or full rig. Remaining part pivots, hidden/far-side anatomy, other seams, and production status remain open.

### SPARK

- Workspace: `assets/characters/spark/tier_01_drafts/edit_batch_01/SPARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/SPARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - attack drone 01 as an independent articulated attachment
  - attack drone 02 as an independent articulated attachment
  - attack drone 03 as an independent articulated attachment
  - engineer tool/weapon attachment
  - backpack and cable clearances
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.
- Separate static prop review candidate: `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/` contains three source-derived drone cutouts. Their alpha screens pass; semantic completeness, pivots, articulation, Krita review, and runtime behavior remain unverified. The blank ORA layers remain the editable source workspace.

### SPECTER

- Workspace: `assets/characters/specter/tier_01_drafts/edit_batch_01/SPECTER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/SPECTER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - blade attachment with hand and sheath/back pivots
  - one continuous main cape/cloak sheet; add a separate cloth part only at a visible independent seam
  - hood and mask as separately reviewable components
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### IRONCLAD

- Workspace: `assets/characters/ironclad/tier_01_drafts/edit_batch_01/IRONCLAD_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/IRONCLAD_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - heavy rotary weapon as a detached hand attachment
  - shoulder, elbow, hip, knee, and shin armor plates as joint-owned layers
  - back-mounted armor/power unit
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### STITCH

- Workspace: `assets/characters/stitch/tier_01_drafts/edit_batch_01/STITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/STITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/STITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - long coat front and back panels as separate cloth layers
  - medical harness and carried case as separate body attachments
  - handheld vial/tool as a detached hand attachment
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### RECOIL

- Workspace: `assets/characters/recoil/tier_01_drafts/edit_batch_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/RECOIL_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/RECOIL_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - hydraulic prosthetic shoulder/upper-arm, elbow, forearm, and hand segments; side label provisional
  - shotgun as a detached hand attachment with a tested grip
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### ECHO

- Current workspace: `assets/characters/echo/tier_01_drafts/edit_batch_02/ECHO_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` (v2; the earlier `edit_batch_01` archive is preserved as historical edit prep)
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/ECHO_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/ECHO_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers in v2:
  - reusable sensory drone unit art, with no fixed runtime count
  - Signal Cascade decoy presentation, separate from sensory drones; appearance and count unresolved
  - neural-interface tether endpoints/cable segments, with no fixed object count
  - backpack mount and cable clearance
- Visual/behavior open item: Exact drone count and drone-to-decoy relationship are unresolved. The reconstructed local note mentions two sensory drones, while the live roster says drones (plural) and the approved visual reference depicts multiple visible units. Do not bake an exact count into gameplay or rig data until reconciled. The OpenRaster archive itself preserves that older note; the adjacent README and current functional contract explicitly supersede the estimate.

The v2 workspace changes only blank layer organization. No image pixels, runtime drone behavior, count, decoy look, formation, target selection, or ability timing were added. Both versions remain quarantined; v2 is the current editing workspace.

### VECTOR

- Workspace: `assets/characters/vector/tier_01_drafts/edit_batch_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/VECTOR_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/VECTOR_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - courier bag and straps as separate back/torso attachments
  - blade attachment with hand and sheath/back pivots
  - reflex/cyberware details at limbs as separate overlays
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### DEADLOCK

- Workspace: `assets/characters/deadlock/tier_01_drafts/edit_batch_01/DEADLOCK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/DEADLOCK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/DEADLOCK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - precision rifle as a detached hand/back attachment with an authored grip pivot
  - backpack and shoulder straps as separate layers
  - forearm suppression/cyberware detail as a separate overlay
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

### GLITCH

- Workspace: `assets/characters/glitch/tier_01_drafts/edit_batch_01/GLITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora`
- Canvas: 1536×1024
- Anatomy/target: `docs/visual_qa/GLITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`
- Concept: `docs/visual_qa/GLITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`
- Blank equipment layers:
  - one continuous main cape sheet behind the body; add a separate cloth part only at a visible independent seam
  - asymmetric cybernetic lower-limb armor as joint-owned plates
  - sidearm and thigh gear as separate attachments
- Visual/behavior open item: author handedness, anchors, pivots, and behavior detail from approved sources; do not infer unspecified gameplay.

## Pass criteria

- All 12 OpenRaster files open and preserve their expected canvas, visible reference, layer names/order, visibility, and transparency.
- Each weapon/tool/accessory is correctly owned and remains readable through idle, walk, attack, hit, defeat, and applicable facing changes.
- Each independent weapon/drone/decoy/cable/cloth/armor element has a source-checked owner, anchor/pivot, and depth order before export.
- SPARK has exactly three separately authored attack-drone identities. ECHO drone count and drone/decoy relationship remain unresolved; do not hard-code them.
- Combat-event presentation is wired through the tested main-scene router, but the router has no production attachment receivers yet. Art validation does not prove that weapon or drone gameplay works.
- Files remain quarantined until semantic parts, transparent bounds, hidden overlap, pivots, deformation, and event integration pass their separate gates.

## Current evidence

- The latest full validation passed Python **86/86**, the all-12 read-only OpenRaster/reference/layer/attachment/quarantine audit, and the Godot 4.7.2 headless suite. The audit verifies every workspace has its planned blank attachment layers; this is structural readiness, not painted equipment or functioning runtime behavior. The exporter still refuses blank layers, so no art has been exported from these workspaces.
- Godot 4.7.2 checks generic attack/ability event routing and the CIPHER 09B approved-pivot metadata. Krita opened all 12 workspaces read-only with no repair warnings; no edited `.kra` round-trip, production attachment receiver, or character-specific weapon/drone behavior is complete.
- No remote Notion/Drive write or binary upload is claimed; the labeled folders in this checkout are staging copies.
