# NEON REQUIEM — BREAKER: Tier I Production & Godot Rig Specification

Status: Approved visual direction / implementation-ready specification. Concept sheet is a visual reference, **not** extracted transparent animation assets or a tested Godot rig.

## Identity and design rules
- Character: Breaker; faction The Fractured; class Brawler / Cyberpsycho; Epic; former prizefighter.
- Style: gritty side-view cyberpunk, industrial streetwear, worn gunmetal, matte black, controlled crimson accents.
- Permanent anchors: short messy undercut, facial scars, boxer stance, enlarged right cybernetic fist, red light accents.
- Tier I: human face and torso, dark sleeveless vest, mechanical right forearm, small neck neural regulator, subtle left knee brace, black combat boots.
- Tier II builds on Tier I: larger hydraulic right fist, left forearm plating, upgraded neck regulator and spinal support.
- Tier III builds on Tier II: powered torso harness, arm reinforcement, leg hydraulics, partial jaw guard.
- Tier IV builds on Tier III: enlarged full-body armored chassis, heavy mechanical legs, enormous right fist; retain partially visible scarred face.
- Do not abruptly replace the character's silhouette, clothing language, or signature arm between tiers.

## Rendering targets
- Godot 4.x; side-view 2.5D presentation with 2D skeletal sprite rig; no fal.ai dependency.
- Design at reference height 256 px from foot baseline to hair top for Tier I. Render in-world at consistent pixels-per-unit. Tier II ~1.05x, Tier III ~1.18x, Tier IV ~1.35x apparent height; keep the same ground anchor.
- Facing default RIGHT. For facing left, flip the visual rig horizontally, not gameplay collision coordinates.
- Separate sprite art from the animation skeleton and hitboxes. No painted background in sprite parts.
- Alpha-transparent PNG parts, identical art scale, consistent pivot placement, avoid baked lighting or motion trails.
- Asset exports should be checked for clean alpha, no cropping at extremities, and alignment in the same neutral pose.

## Suggested folder structure
res://characters/breaker/
  breaker.tscn
  breaker.gd
  rig/breaker_skeleton.tscn
  art/tier_01/{head,hair,torso,pelvis,upper_arm_l,forearm_l,hand_l,upper_arm_r,forearm_r,hand_r,thigh_l,shin_l,foot_l,thigh_r,shin_r,foot_r,neck_regulator,knee_brace}.png
  art/tier_02/...
  art/tier_03/...
  art/tier_04/...
  fx/{punch_impact,hydraulic_burst,red_overload}.png
  data/breaker_tiers.tres

## Modular layers (back to front)
1. Back accessory and spine/neck cables
2. Rear arm and leg
3. Pelvis, torso and vest/chassis
4. Front leg
5. Head, hair, jaw, regulator
6. Front arm and signature right fist
7. Emissive LED overlays, heat vents and combat effects

## Skeleton / pivots
Root2D (ground anchor at feet midpoint)
- pelvis: hips
  - torso: waist
    - neck -> head -> hair/face gear
    - shoulder_l -> upper_arm_l -> elbow_l -> forearm_l -> wrist_l -> hand_l
    - shoulder_r -> upper_arm_r -> elbow_r -> forearm_r -> wrist_r -> hand_r
    - spine_accessory
  - hip_l -> thigh_l -> knee_l -> shin_l -> ankle_l -> foot_l
  - hip_r -> thigh_r -> knee_r -> shin_r -> ankle_r -> foot_r
- fx_anchor_fist_r, fx_anchor_ground, fx_anchor_neck
- VisualRoot should be independent of CollisionShape2D and CharacterBody2D.

## Animations and first-pass timing (60 FPS animation authoring; adjustable)
- idle: 1.0s looping; weight shifts, breathing, right-fist servo twitch.
- walk: 0.65s looping; grounded heavy boxer stride.
- punch_light: 0.42s; anticipation 0.10, strike 0.10, recovery 0.22; impact event on strike.
- punch_heavy: 0.78s; anticipation 0.24, impact 0.12, recovery 0.42; small camera shake on impact.
- hit: 0.30s; recoil without root displacement.
- defeat: 0.95s; stagger, drop to knee, collapse; one-shot.
- skill_redline: 1.10s; fist LEDs brighten, hydraulic burst, powerful blow; one-shot.
- victory: 1.25s; fist clench and guarded stance, optional reusable in-engine sequence.
- Tier I should be completed and tested before applying tier-swapped art.

## Runtime interfaces
- `set_tier(tier: int)` loads a consistent part set (1..4), retains skeleton and animation names.
- `set_facing_right(value: bool)` flips visuals only.
- `play_action(name: StringName)` triggers state and gameplay animation events.
- `set_overload(value: float)` drives crimson emissive intensity and optional particles.
- All tiers share animation timeline/event names; tier-specific offset overrides are permitted for larger fists.
- Combat resolution is driven by game logic; animation events are visual synchronization, not the source of authoritative wave outcomes.

## Six-unit squad constraints
- Ground anchor and navigation footprint remain stable across tiers; visual art can exceed hitbox.
- Character can overlap neighbors visually but must not hide UI or create unusable collision.
- LOD: when zoomed out, disable tiny cables/sparks and reduce particle counts.
- Keep effects pooled, avoid new texture allocations each attack, batch atlas textures when feasible.

## Art production sequence
1. Draw Tier I neutral side-view with alpha, front-facing RIGHT, consistent 256px reference scale.
2. Split Tier I into labeled transparent parts; inspect seam overlaps at joints.
3. Assemble Godot Skeleton2D/Bone2D or equivalent node-transform rig and test idle/walk/punch.
4. Add hit, heavy, defeat, skill, victory; wire animation events and reusable VFX.
5. Test on target mobile aspect ratios and in a six-unit lineup.
6. Create Tier II replacements and validate hot-swap without rebuilding animations.
7. Repeat for III and IV; tune silhouette sizes and fist hit FX.

## Acceptance criteria
- Breaker recognizable in all four stages and visually progresses incrementally.
- Tier I art exports as clean transparent separate PNG components with documented pivots.
- Same rig supports all four tiers; all named animations play without detached seams.
- Ground anchor does not jump on evolution or animation changes.
- Six Breaker-sized characters remain legible in the mobile combat camera.
- No paid services required; no fal.ai calls or dependency.

## Current implementation status
- Visual direction: approved.
- Four-tier concept reference: generated in chat.
- Sprite part exports: not yet created.
- Godot rig and animation test: not yet executed; requires actual source assets/project workspace.
