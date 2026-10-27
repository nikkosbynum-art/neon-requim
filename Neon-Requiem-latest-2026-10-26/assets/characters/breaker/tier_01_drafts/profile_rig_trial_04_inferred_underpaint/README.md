# BREAKER profile rig trial 04 — inferred under-paint

**Status: quarantined test draft. Inferred, not canon; hidden anatomy is not verified. Not used by runtime.**

This sibling trial was created after the user authorized inferred reconstruction because the project folder contains no original layered artwork. It preserves all trial-03 visible masks and adds 13 joint-local underpaint images. The added colors are sampled from nearby pixels along manually inferred segment axes. All underpaint follows its corresponding bone and renders beneath every visible source-pixel layer.

The additions are not artist-authored hidden anatomy. Texture extrapolation can smear, anatomy behind opaque clothing cannot be confirmed from this reference, pivots remain estimated, and joint-stress capture shows visible artifacts under exaggerated poses. The stress poses are diagnostic and are not production animation clips.

## Evidence

- `tools/art/audit_breaker_profile_trial_04_underpaint.py` — checks 13 layer dimensions/corners, that inferred pixels exist, and that static compositing exactly preserves candidate 03. A pass does **not** verify anatomy.
- `tests/test_breaker_profile_rig_trial_04_underpaint.gd` — isolated Godot layer load, common-bone attachment, z-order, scale, anchor and action-channel checks.
- `tests/test_breaker_profile_rig_trial_04_joint_contacts.gd` — 12 selected joint neighborhoods sampled through five clips at 60 Hz; still not full seam or anatomy certification.
- `tests/capture_breaker_trial_04_joint_stress_qa.gd` — intentionally exaggerated pivot review used to expose possible underpaint/gap problems.
- `docs/visual_qa/breaker_profile_trial_04_inferred_underpaint_actions_1280x720_02.png`
- `docs/visual_qa/breaker_profile_trial_04_joint_stress_1280x720_02.png`

## Reproduction

```powershell
python tools/art/audit_breaker_profile_trial_04_underpaint.py
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_profile_rig_trial_04_underpaint.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --fixed-fps 60 --path . --script res://tests/test_breaker_profile_rig_trial_04_joint_contacts.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_breaker_trial_04_joint_stress_qa.gd
```

## Intended action-range verification — 2026-10-24

The isolated trial passes the current clip-specific tests: 2,472 selected joint-neighborhood samples across 206 poses at fixed 60 Hz have at least 15 adjacent opaque contacts (minimum observed 35); the dedicated walk-gait regression passes; and the eight-phase review sheet shows connected walk samples at the 256 px target height. The extreme joint-stress sheet is deliberately outside the current clip ranges and continues to reveal limits. Trial 04 is working only within the isolated authored clip range; the underpaint is still inferred, and production readiness is NOT PASSED.
