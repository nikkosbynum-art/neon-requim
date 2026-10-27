# BREAKER Tier I candidate 09 v4 hand-bounded arm split

**Quarantined rig feasibility trial; not production art or runtime content.** Derived from v2. Hand-traced ROIs constrain the skin classifier to the visible upper arm, separating exposed skin from the external shoulder shell while preserving all visible source pixels. The two components share the estimated CyberShoulder bone.

The export and audit prove exact neutral RGBA reconstruction and exclusive visible-pixel ownership only. No skin is reconstructed beneath the opaque shell; concealed anatomy remains **NOT VERIFIED**. Shell-independent movement is intentionally not supported in this trial. Pivots are inherited estimates.

Run `python tools/art/audit_breaker_trial09_canon_v4_manual_skin.py`, then Godot tests `tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin.gd` and `_contacts.gd`.
