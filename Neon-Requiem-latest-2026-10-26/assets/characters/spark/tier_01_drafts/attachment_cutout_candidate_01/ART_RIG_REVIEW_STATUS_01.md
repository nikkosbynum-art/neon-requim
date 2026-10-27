# SPARK drone art and rig review status 01

**Status: quarantined reference cutouts; no rig or runtime approval.**

## Scope and evidence

- Compared the three candidate cutouts with the locally approved `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` and `docs/visual_qa/SPARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Independently checked the RGB values of all nontransparent candidate pixels against their source coordinates. Blue, red, and amber each have zero mismatches; their opaque-pixel counts match `candidate_manifest.json`.
- Visual inspection of alpha-composited previews found all currently visible drone silhouettes intact and no visible crop truncation. The nearest opaque pixel to the source sheet's right edge is 16 px for blue, 31 px for red, and 19 px for amber.

## Open art questions

The references show the drones in near-frontal views only. They do not provide authored profile or rear views, establish hidden geometry, or specify which rotors or components articulate in the intended side-view game presentation. Resolve these with artist-authored side and rear references and an articulation note; do not infer missing forms or motion from the cutouts.

## Readiness

- Visible source-pixel fidelity: **PASS**.
- Visible silhouette crop completeness at the shown reference angles: **PASS, visual review**.
- Side/rear design and articulation coverage: **OPEN**.
- Pivot correctness, animation readiness, production approval, and runtime integration: **NOT VERIFIED**.
- Candidate status: **QUARANTINED**.

This record covers local reference files only. It does not claim a live Notion/Drive source read or remote reconciliation.
