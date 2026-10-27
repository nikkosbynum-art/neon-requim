# BREAKER guarded-pose trial 05 v8

**Status: isolated feasibility draft; not approved, not production art, not runtime content.**

This version assigns each visible source pixel to one of 13 full-canvas layers. It removes the duplicated visible-mask ownership that caused ghosting at joints in earlier trials. The 13 corresponding underpaint layers use a 64 px local color-axis extrapolation from a single flattened reference. They are inferred texture fills, not artist-painted or semantically verified anatomy.

The source is `BREAKER_T1_guarded_pose_review_candidate_05.png` (1024×1536 RGBA). Static validation is reproducible with:

```powershell
python tools/art/audit_breaker_guarded_trial05_v8.py
```

The audit checks exclusive visible-pixel ownership, complete target-silhouette coverage, exact neutral reconstruction, and agreement with the inferred-underpaint counts in `pivot_manifest.json`. Godot review harnesses under `tests/` exercise provisional idle, walk, punch, hit, and defeat poses. Those tests check selected joint neighborhoods and transform plumbing; they cannot establish anatomical correctness, continuous deformation, or production readiness.

The conservative walk is the current best isolated preview. The original stronger collapse visibly tears at joints and is rejected. The restrained slump/fade preview is cleaner but weak as a defeat cue and remains a prototype option only. Hands remain part of the forearm images and feet remain part of the boot images. Pivots, segmentation, underpaint, and movement are estimates.

Keep this folder quarantined under `tier_01_drafts/`. No runtime scene references it. See `docs/BREAKER_HIDDEN_ANATOMY_AUDIT.md` for the gate status and limits.
