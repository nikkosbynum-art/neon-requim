# BREAKER Tier I candidate 09 rig trial — canon arm v2

**Quarantined feasibility trial; not production art and not runtime content.** The source is the flattened candidate 09 review image. The v1 polygon extraction exactly reconstructed its neutral silhouette but assigned much of the visible bicep to the cyber forearm. This v2 transfers a bounded, skin-color-classified region from the forearm layer to the shoulder/upper-arm layer. Source RGB and the neutral composite are unchanged.

The user-approved boundary is a biological right upper arm beneath an external shoulder shell, with the mechanical prosthesis beginning at the elbow. This trial tests semantic layer ownership for the visible pose only. The shoulder shell is still fused into the upper-arm texture. Hidden surfaces, authored pivots, continuous deformation, and production readiness remain unverified.

The isolated Godot review harness now uses stronger punch and hit keyframes to make the action samples easier to distinguish. This tuning is provisional and does not modify runtime character/combat scenes. The walk remains deliberately restrained and still needs visual review.

Run `python tools/art/audit_breaker_guarded_trial09_canon_v2.py` and Godot tests `tests/test_breaker_profile_rig_trial_09_canon_v2.gd`, `tests/test_breaker_profile_rig_trial_09_canon_v2_contacts.gd`, and `tests/test_breaker_profile_trial_09_canon_v2_defeat_fade.gd`. `tools/art/export_breaker_trial09_canon_v2.py` refuses to overwrite its existing output directory; it is a new-trial exporter, not an in-place rebuild command.
