# BREAKER Tier I arm split — feasibility v1

**Rejected as a standalone arm asset. Preserved only as a reproducible mask-ownership QA fixture. Not production art or runtime content.**

The 2026-10-25 user-approved canon reading is an external shoulder shell over a biological upper arm, with the mechanical prosthesis beginning at the elbow. This experiment splits visible warm-skin pixels from the shell/hardware in the flattened candidate 05 upper-arm composite.

Python and Godot checks pass exact neutral reconstruction: 4,178 pixels are classified as skin surface, 22,564 as shell/hardware, with zero overlap and zero visible reconstruction differences. Manual review at game scale fails the standalone-surface criterion: the skin-only layer is fragmented/sparse and does not provide a coherent independent upper arm. It is not suitable for rigging.

Run `python tools/art/build_breaker_t1_arm_split_v1.py` to reproduce the pixel split and `tests/test_breaker_trial05_v8_arm_split_v1.gd` for Godot's exact visible-pixel round-trip. Hidden anatomy and motion are not tested.
