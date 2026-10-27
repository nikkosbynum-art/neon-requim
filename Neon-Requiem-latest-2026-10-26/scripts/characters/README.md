# Character controllers and presentation

`breaker_t1_placeholder_rig.gd` builds a runtime `Skeleton2D`/`Bone2D` tree with polygon stand-ins for the approved BREAKER Tier I identity anchors. It exposes a prototype presentation contract with ground, neck, and signature fist effect markers. Its experimental `set_head_art` hook attaches one texture at a declared pivot and display height; the main scene does not call it. Regression tests cover root/facing separation, head-pivot transform plumbing, and ensure presentation actions do not mutate combat position or health. This is not production artwork or a tested reusable production rig; full-body transparent sprite exports, assembled viewport review, full animation clips/effects, combat-synchronized impact events, and evolution-compatible tier swaps remain unimplemented. `placeholder_actor.gd` remains the generic enemy stand-in.


## Attachment presentation status

The combat director emits structured generic `attack_resolved` events and exposes a validated `_emit_ability_resolved` hook for use only after an authoritative ability effect commits. Both share a monotonic event sequence and route through `scripts/presentation/attachment_event_router.gd`, which filters by actor instance/source or target. No gameplay ability currently calls the new hook, and no character-specific equipment nodes are registered. Do not trigger damage, targeting, ability activation, or autonomous drone actions from an attachment receiver. Use `docs/ATTACHMENT_FUNCTION_CONTRACT.md` for each character's source-backed behavior and open questions.
