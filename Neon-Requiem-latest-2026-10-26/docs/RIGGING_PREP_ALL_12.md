# Founding roster Tier I rigging preparation

**Status:** In progress. This roster-wide plan tracks reference-backed rigging requirements and existing quarantined candidates. **No character in this plan is marked as a production-approved art rig.**

## Scope

This pass brings all twelve founding recruits into one traceable Tier I rigging workflow. It preserves the current BREAKER and CIPHER pilots and the ten visible-profile mesh preflights. Those candidates are not upgraded to semantic sprite parts, approved animation, or runtime assets by this plan.

Run tests/art/rig_review_workbench.tscn in Godot for a unified interactive review of the ten profile-mesh preflights and the CIPHER cutout candidate. It provides reference viewing, pose selection, temporary bone rotations, per-part visibility, and a six-pose review capture. BREAKER and the other candidates without adapters remain in their existing character-specific review scenes; no candidate status is changed by opening or capturing from this workbench.

Each character record points to the approved concept/anatomy references (or BREAKER's project specification/review material), inventories the existing candidate, and records the character-specific equipment or silhouette that must stay independently readable. Shared required parts and review gates are in [`tools/art/rigging_prep_all_12.json`](../tools/art/rigging_prep_all_12.json).

## Candidate status by character

| Character | Existing work | Main rig-specific review |
|---|---|---|
| BULWARK | Flattened-profile mesh candidate | Medical pack, hoses, rifle attachment |
| BREAKER | Guarded-pose trial and hidden-arm review candidates | Approved shoulder-shell / biological-upper-arm / elbow-start prosthesis; v20 stays quarantined |
| CIPHER | Reference-derived profile cutouts and provisional cutout rig | Hood/collar/backpack overlap, rifle pivot, hidden far-side anatomy |
| SPARK | Flattened-profile mesh candidate | Three detached drones, tools, backpack/cable clearance |
| SPECTER | Flattened-profile mesh candidate | Hood/mask, cape layers, blade |
| IRONCLAD | Flattened-profile mesh candidate | Rigid powered-armor plates, heavy weapon, back unit |
| STITCH | Flattened-profile mesh candidate | Coat panels, harness/case, handheld tools |
| RECOIL | Flattened-profile mesh candidate | Prosthetic side and elbow chain, shotgun |
| ECHO | Flattened-profile mesh candidate | Neural-interface unit, physical sensory devices (visible mapping/count unresolved), distinct Signal Cascade decoys, and connections |
| VECTOR | Flattened-profile mesh candidate | Courier bag/straps, blade, limb cyberware |
| DEADLOCK | Flattened-profile mesh candidate | Rifle grip/attachment, backpack straps, forearm detail |
| GLITCH | Flattened-profile mesh candidate | Cape layers, asymmetric lower-limb cyberware, one owner-approved rifle in held/back-mounted carry states; boundaries, mounts, pivots, transition, and provenance remain open |

The entries are a work plan, not new character canon. Verify handedness and near/far mapping from each approved side view before authoring attachment pivots. ECHO and SPARK's drones are props; the character stays grounded unless an approved ability explicitly supplies a floating reason.

## Shared production gates

1. Read the character's approved concept and anatomy views together.
2. Name semantic parts and sides; keep weapons, capes, drones, and other moving props independent where the references support that separation.
3. Record source bounds, authored pivots, overlap order, and provenance per part. Do not infer these from the center of a crop.
4. Mark every concealed region as source-backed or inferred. Keep inferred anatomy visible as a separate review item.
5. Check full-resolution crops for clipped edges, duplicated anatomy, stray pixels, and semantic ambiguity.
6. Assemble the neutral body and compare its silhouette, proportions, and grounding to the reference turnarounds.
7. In Godot, exercise idle, walk, attack, hit, and defeat; inspect joints and foot contact in rendered frames.
8. Keep each candidate quarantined until visual, semantic, pivot, deformation, and explicit approval gates pass.

## Bounded intake and gameplay-scale review

After the first native-scale semantic contact sheet and ownership review, stop if a required part is missing, clipped, duplicated, ambiguous, or unsupported by the approved reference. Record the unresolved item and source correction before proceeding; do not use more segmentation attempts or a rig to conceal missing evidence. Reuse shared anchors where the anatomy fits, and record character-specific exceptions in that character's part plan and manifest.

Before `animation_reviewed` can pass, review actual combined idle, movement, attack, hit, and defeat poses in isolated QA at 1280×720 and again at 800×450. Check silhouette, role/equipment cues, and ground contact. The workbench's five-sample single-joint range capture is a neutral-pose diagnostic only: its default ±75° is generic, entered ranges are unverified, and it cannot establish action ranges or substitute for combined poses. The camera-scale review remains manual; no automated capture harness is present.

## Validation

Run:

```powershell
python tools/art/audit_rigging_prep_all_12.py
python -m unittest tests.test_rigging_prep_all_12
```

The audit checks all twelve source/candidate paths and attachment contracts, then opens every on-disk OpenRaster archive to verify ZIP integrity, layer-stack/manifest agreement, current attachment-layer coverage, transparent blank authoring layers, reference visibility/embedding, current sidecar open questions, and quarantine flags. It does not validate anatomy pixels, Krita round-trip behavior, or approve a rig.

After semantic layers are painted and reviewed in Krita, use [`export_reviewed_openraster_parts.py`](../tools/art/export_reviewed_openraster_parts.py) with an explicit per-character layer-selection JSON. It exports full-canvas aligned PNG layers to a new folder under that recruit's `tier_01_drafts/`; it refuses blank layers and cannot export to runtime directories. The resulting candidate is still quarantined and needs separate semantic, pivot, deformation, and behavior validation.

## Next implementation milestone

Move from mesh preflight toward semantic Tier I parts in reviewable character-sized batches. BREAKER and CIPHER are the existing pilots; use their findings to standardize underpaint, part naming, pivots, and seam captures before expanding. A character is not complete when the checklist passes: its detached parts, authored attachment points, deformed-pose review, and production status still need direct evidence.


## Functional attachment contract

See [`ATTACHMENT_FUNCTION_CONTRACT.md`](ATTACHMENT_FUNCTION_CONTRACT.md) for per-character weapon, accessory, drone, ability-event, and unresolved-detail requirements. It is an implementation contract, not a claim that attachments or behavior exist in runtime. ECHO drone count remains unresolved.

## Shared manifest review workflow updates — 2026-10-25

As Tier I art is submitted, use the standard-manifest evidence fields, one-command review bundle, and manifest-driven neutral rig preview documented in [CHARACTER_ART_PIPELINE.md](CHARACTER_ART_PIPELINE.md). Compare authored candidates at the shared 256 px visible-height scale and capture per-joint diagnostic sweeps in the workbench. These tools provide traceable review aids only; they do not fill missing roster art, infer anatomy, define production motion ranges, or pass gates. Current formal coverage remains 1/12 with the legacy BREAKER pilot; no standard manifests are submitted. Validation of the workflow-tool changes has not been run.
