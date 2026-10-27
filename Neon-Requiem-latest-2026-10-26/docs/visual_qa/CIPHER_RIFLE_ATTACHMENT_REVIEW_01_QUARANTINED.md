# CIPHER Tier I rifle attachment review 01

**Status: QUARANTINED — review evidence only.** No CIPHER rifle art is approved for runtime or rigging from this review.

## Sources inspected

- Approved concept turnaround: `CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png`.
- Approved anatomy turnaround: `CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`.
- Existing cutouts: `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/`.
- Semantic boundaries: `docs/ATTACHMENT_REFERENCE_REVIEW_12.md` and `docs/ATTACHMENT_FUNCTION_CONTRACT.md`.

## Findings

- The concept shows a rifle held across CIPHER's front with an optic mounted on that rifle. It separately shows a head-worn optic. Keep the rifle optic owned by the rifle and the head optic owned by the head; do not merge them.
- `CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png` is a 540×270 transparent review cutout with half-open visible alpha bounds `[75, 93, 470, 197)`. It has no authored pivot or reviewed grip attachment. Its pixels alone do not establish hand placement, a stable side-view pose, or weapon animation.
- `CIPHER_T1_CARRIED_RIFLE_REF_CUTOUT_CANDIDATE_01.png` is 138×476 and has alpha across the full image bounds. It is a crop from the side turnaround, not an isolated transparent weapon layer, so it is not suitable as an independent rig part.
- The existing `parts_manifest.json` has no rifle or rifle-optic entries. Do not infer pivots from the crop bounds or make the isolated rifle cutout part of the body assembly.
- The source images do not specify CIPHER's firing cadence, firing animation, reload, weapon stow/transition, or gameplay effect timing. The function contract remains authoritative for the current source-backed relationship and open behavior questions.

## Next authoring gate

In the quarantined Krita workspace, author a clean rifle assembly as one rigid prop with its optic attached, then separately map the head optic. Preserve the approved source silhouette and do not invent hidden gun surfaces or a hand/grip pivot. Record any inferred pixels and pivot as such. Before export, inspect the prop at 100%, validate its source-color/silhouette relationship, and review a neutral composition and held pose. Keep the asset quarantined until those visual checks pass; production readiness and runtime behavior require their own evidence.

## Follow-up source-shape comparison — quarantined — 2026-10-26 UTC

Viewed the isolated 540×270 rifle candidate alongside the approved concept and anatomy turnarounds at display scale. The candidate is a horizontal prop with a cyan optic and prominent lower grip; the approved concept depicts a rifle held diagonally with red-lit details, while the anatomy side view shows a vertical back item. The views do not establish that these are the same source silhouette or clarify the vertical item’s identity. This is a visual comparison finding, not proof of a canon mismatch or authorization to redesign the prop.

The existing candidate has no authored grip/stow pivot and is absent from the body parts manifest. Keep it quarantined and do not attach it to the body assembly. The next gate is a source-aligned authored rifle boundary/prop and explicit optic ownership, followed by review of a neutral held assembly and artist-authored grip/stow points. No art pixels or runtime files were changed; no automated tests were run for this documentation-only follow-up.

## 2026-10-26 user clarification — prop identity across carry states

The user approved that the rifle held in CIPHER's concept and the vertical item in the side-view reference are the same prop in different carry states. This resolves identity only; it does not validate the existing isolated horizontal cutout, define cutout boundaries, authorize new attachment points, provide grip/stow coordinates or pivots, or approve transition behavior. Keep the optic owned by the rifle and the head optic separately head-owned. Candidate pixels remain quarantined pending source-boundary and pose review.
