# CIPHER Tier I rigging preparation 01

**Status:** quarantined rigging-prep pilot. The current work clears a first head-pivot transform smoke test; it does not constitute a full CIPHER rig or production-art approval.

## QA blockout result

Added the isolated `tests/art/cipher_t1_rig_blockout_preview.tscn` with a 16-bone proposed hierarchy, 15 generic placeholder shapes, and the quarantined head candidate. The Godot 4.7.2 headless blockout test passed six static pose transform checks and verified the head pivot and ground anchor remain stable. These are structure/transform checks, not finished animations or anatomical seam validation. The preview is test-only and not included in the runtime scene.

Two generated torso drafts were reviewed and rejected before being copied into the project: one was too three-quarter, and the targeted revision retained a raised collar and failed the alpha/margin gate. No torso part is accepted.

## Sources and constraints

- Approved visual direction: `docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved visible anatomy/proportions reference: `docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- The approved references guide visible appearance and anatomy only. Hidden surfaces, exact part boundaries, pivots, deformation, and production readiness remain separately unverified.
- Candidate image: `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/cleanup_working/CIPHER_T1_HEAD_NECK_CLEANED_CANDIDATE_01_QUARANTINED.png`.

## Head-pivot pilot

At thumbnail and profile scale, the candidate preserves the approved hood, right-facing profile, dark hair, face, magenta optic, and high-collar cues. It is a single head/hood/hair/collar composite; those elements cannot articulate independently. The alpha cleanup preserves the source RGB and passes only the mechanical cutout audit.

For a transform smoke test, `tests/art/test_cipher_head_pivot_candidate.gd` uses the **provisional** source-canvas pivot `(760, 815)` and scales the audited 856 px silhouette to 110 review pixels. This places the upper silhouette near a 256 px full-character guide height when the socket is positioned about 146 px above the ground anchor. These are review-fit assumptions, not approved production dimensions or authored final pivots. The collar/hair-to-torso seam cannot be judged until the torso part exists.

## Proposed skeleton map for the first full-body blockout

```text
ground_root
└── pelvis
    ├── rear_hip → rear_knee → rear_ankle → rear_foot
    └── torso
        ├── neck_socket → head_hood_hair_collar (current composite; provisional)
        ├── rear_shoulder → rear_elbow → rear_wrist
        ├── front_shoulder → front_elbow → front_wrist
        └── rifle_attachment (independent hand/back mount)
```

This is an implementation proposal following the approved hybrid modular skeletal approach. The side labels must be confirmed against the approved profile, and the rifle must remain a separate attachment. Do not invent underpaint or hidden anatomy from the flattened reference.

## Asset readiness

| Semantic item | Status | Blocking detail |
|---|---|---|
| `head_hood_hair_collar` | Alpha audit passed; quarantine review candidate | Independent collar boundary and neck overlap are not authored; pivot is provisional |
| `torso_back` / backpack mount | Missing | Needs clean transparent part with overlap behind torso and head |
| `torso_front` / jacket | Missing | Needs underlap around shoulders, waist, and collar |
| `pelvis_belt` | Missing | Needs seam overlap with jacket and both upper legs |
| Arms and hands | Missing | Each side needs complete semantic pieces, side labels, and elbow/wrist overlaps |
| Legs and boots | Missing | Each side needs complete semantic pieces, knee/ankle overlaps, and stable ground contact |
| Rifle and attachments | Missing | Needs independent hand/back mount pivot and no baked glow/background |

## Entry gate for full-body rigging

Do not build the full-body character rig until every required Tier I part is separately reviewable, mapped to the profile, and has documented source-canvas pivots and overlap order. Then assemble the neutral pose at a shared provisional 256 px visible character height, compare it to the approved front/profile/back references, and stress-test seams in idle, walk, aim/fire, hit, and defeat poses. The 256 px scale is borrowed as a prototype guide from the BREAKER production spec; it is not yet a CIPHER-specific canonical scale.

The isolated pivot test may be run with:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/art/test_cipher_head_pivot_candidate.gd
```

Passing this test proves texture loading and transform math only. It does not clear any art gate.

## Visible-profile cutout rig candidate 01 — 2026-10-25 UTC

**Status: quarantined art-rig candidate; not production-ready or runtime-integrated.**

The approved anatomy sheet's right-facing side view was isolated to a new local candidate. Ten transparent source-derived layers and a separate hand-authored rifle attachment are listed in `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/parts_manifest.json`. A 15-bone test rig and six pose names run in `tests/art/cipher_t1_reference_cutout_rig_preview.tscn`. The neutral profile retains the reference's hood, optic, backpack, jacket equipment, armored pants, and boots; the review sheet is `docs/visual_qa/CIPHER_T1_RIG_POSE_REVIEW_CANDIDATE_01.png`.

The rig uses a provisional 0.30 source-to-review scale and mask-derived pivots. Some poses keep limb chains rigid because the flattened profile contains no hidden joint underpaint. Far-side anatomy, a finished grip pose, independent elbow/knee bending, and continuous deformation are unresolved. These boundaries are engineering proposals only; do not mark the candidate as approved production artwork or connect it to runtime yet.

Godot 4.7.2 headless test command:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/art/test_cipher_reference_cutout_rig.gd
```

The test validates texture decoding, declared art/bone counts, pose acceptance, transparent corner safety, and stable ground anchor. It does not validate rendered animation; the dummy renderer prevents a Godot viewport screenshot in this environment.


## Krita authoring workspace 01 - 2026-10-25

A non-destructive `.ora` workspace now holds the approved side-profile source as a visible reference, ten individually aligned candidate body cutouts hidden by default, and a blank inferred-underpaint layer. Krita opened it successfully. Existing focused Python (5/5) and Godot 4.7.2 rig checks pass. The workspace is a convenient editing container, not proof that the parts are complete or production-ready. The far-side, pivots, and deformation remain open. An extra unmapped rifle crop with zero safety margin is excluded from the workspace and rig.


## Semantic remap review update - 2026-10-25

The candidate-01 pose test and alpha checks passed, but contact-sheet inspection found semantic contamination: head/shoulder and backpack/arm pixels overlap across labels, and the current lower-limb mapping/pivots need review. Candidate 02 is rejected (96.25% source silhouette coverage). Candidate 03 removes the mutual head/backpack gap and reaches 99.63% alpha silhouette coverage; all ten part cutouts pass the mechanical margin check. It remains quarantined pending individual 100% Krita review, hidden/far-side art, authored pivots, and a candidate-03 rendered rig test.


## Candidate 04 mechanical coverage update - 2026-10-25

Candidate 04 extends the four measured missed source regions from candidate 03. Mechanical audit: 10/10 part alpha/margin passes, 100% source-core coverage, zero extra pixels. This does not prove semantic separation or art quality. The candidate 04 `.ora` and part contact sheet are prepared for Krita review after 5 p.m. Chicago time. Do not use in runtime pending semantic review, far-side/hidden-surface work, pivots, and rendered rig validation.
