# Functional weapon, accessory, and drone contract

**Status: implementation requirements and open questions. Generic resolved-attack events, a tested presentation router, and an unused ability-resolved event hook exist; no character-specific attachment or ability behavior is implemented.**

## Purpose and source boundary

All character equipment must remain legible and correctly attached in combat. Art rigs prepare the transforms, pivots, ownership, layer order, and animation hooks; runtime behavior comes from character data and the authoritative combat simulation. The animation/presentation layer may display events but may not choose targets, deal damage, activate abilities, or invent drone autonomy.

Sources used: the live Founding Recruit Roster (https://app.notion.com/p/40394c5658c8812d849be3d32629920e), the approved individual concept/anatomy references under `docs/visual_qa/`, and the reconstructed offline roster at `migration_package/notion_reconstruction/02_Roster.md`. The offline reconstruction is not a verbatim canonical export. No external Cyberpunk franchise source was needed or used.

## Current technical footing

`CombatDirector.combat_action_resolved` publishes generic attack-resolution events after damage commits and now has a validated `_emit_ability_resolved` hook for callers to use only after an authoritative ability effect commits. Ability and attack events share one monotonic sequence, include explicit source identity, and omit `target_id` for targetless abilities. The hook does not activate abilities or apply effects, and no current ability implementation calls it. `AttachmentEventRouter` can route events by source or target owner and supplies a separate copy to each receiver. The headless Godot suite covers attack routing, instance isolation, targetless ability-event routing, independent SPARK drone receivers, and mutation isolation. The router is connected to the main scene, rejects repeated/out-of-order sequence numbers, and gives each receiver a deep copy. A reusable `AttachmentPresentationReceiver` maps routed event types to explicitly configured animation clips and ignores repeated sequences; no character scene registers it yet. SPARK now has three quarantined static drone cutouts with provisional central-core pivots, but no equipment art nodes are registered. This remains shared transport/presentation infrastructure plus unintegrated review art only.

## Shared attachment data contract

Each authored attachment definition should carry a stable `attachment_role_id`, `owner_character_id`, semantic type, source reference, parent/socket, authored pivot, local transform, depth/draw-order rule, and supported presentation states. At runtime, instantiate a unique `attachment_id` and route it by the owning actor’s `owner_instance_id` (the same identifier used by combat event `source_id` / `target_id`), not by display name or recruit definition alone. This keeps equipment attached to the right slot if recruit instances are duplicated. Weapon items also need authored grip and stow pivots. Drone/decoy items need independent IDs and transforms. Tethers need two explicit endpoints. Cloth and joint armor need their body/joint owner. These values remain unset until an artist authors them from the approved views.

Runtime events (for example, attack, ability activation, target change, hit, defeat) control attachment presentation. Presentation never sends a gameplay command back to combat. If the combat model does not emit an event/state needed by an attachment, record that as an implementation dependency; do not fake it with a visual timer.

| Class | Required function | Required review |
|---|---|---|
| Weapon | Stay aligned to grip/mount, follow facing and authored carry/stow state, present attack/recoil/swing from simulation events | Idle, walk, aim/attack, hit, defeat, facing flip; two-hand poses where applicable |
| Drone or decoy | Keep independent identity, owner, transform and event link; visualize only approved ability behavior | Owner idle/movement/ability/hit/defeat/facing; verify no detached, duplicate, or phantom unit |
| Armor/cyberware | Stay owned by the correct bone/joint and preserve approved silhouette | Joint bend, seam/underpaint, clipping, defeat and facing |
| Cape/coat/strap/cable | Preserve anchored endpoints and readable silhouette; secondary motion is presentation-only | Locomotion, turn/facing, attack, hit, defeat; tether stretch/tearing and body overlap |
| Tool/medical/chem accessory | Remain attached and visually support the roster-described ability without granting effects itself | Carry/use presentation and all connected poses; confirm simulation event drives any ability cue |

## Roster behavior links

| Recruit | Source-backed equipment / behavior link | Unresolved details (do not invent) |
|---|---|---|
| BULWARK | Rifle presentation follows attack events; medical pack/hoses stay connected; Last Protocol cue follows heal event | Rifle behavior and any equipment gameplay effect |
| BREAKER | Approved right shoulder shell overlays biological upper arm; prosthesis begins at elbow; fist follows elbow/wrist chain; Redline cues follow simulation | No added fist effect beyond Redline |
| CIPHER | Hacked rifle optic stays aligned to rifle; Ghost Round cue follows cyberware-disruption event | Rifle cadence and optic behavior |
| SPARK | Exactly three attack-drone identities for Scrap Swarm; each drone is separately owned and event-driven | Formation, flight paths, target assignment, firing cadence, return behavior |
| SPECTER | Blade grip/sheath ownership; Null Trace cloak/priority-strike cue follows ability event | Cloak timing/visual language and blade cadence |
| IRONCLAD | Approved-reference heavy weapon follows grip/mount and simulation events; powered armor remains joint-owned; Lockdown cue follows event | Weapon subtype and exact suppress/anchor mechanics |
| STITCH | Medical/chem kit remains attached; heal, boost, and instability cues follow simulation events | Exact vial use, visual effect, instability presentation |
| RECOIL | Hydraulic prosthesis is a connected joint chain; shotgun cues follow attack events; Breach Charge presentation follows simulation movement/impact | Shot cadence/spread and charge path |
| ECHO | Physical remote drones are sensory extensions; Signal Cascade decoys are distinct entities with independent IDs/transforms | Visible device/decoy mapping and count, formation, paths, and sensory gameplay rules |
| VECTOR | Blade follows grip/sheath; Slipstream multi-target dash follows simulation movement/target events | Dash timing/path and blade cadence |
| DEADLOCK | Marksman rifle follows attack events; System Break uses the simulation-selected target | Rifle subtype/cadence and anti-cyberware effect visuals |
| GLITCH | One rifle is owner-approved in held and back-mounted carry states; Frame Skip presentation follows simulation target-change events; cape/limb armor follow their owners | Rifle boundaries, mounts, pivots, transition, provenance, and cadence; Frame Skip details beyond the roster summary |

## Explicit open items

- ECHO’s Signal Cascade decoys are distinct from the physical sensory devices, per the current local owner decision. Visible device/decoy mapping and count remain unresolved. A reconstructed local rigging note said two sensory drones; the live roster only says plural drones. The approved concept depicts multiple visible units. Keep the count out of hard-coded gameplay/rig definitions until sources and visible identities are reconciled.
- Weapon firing cadence, projectile/impact behavior, attack range, recoil strength, drone formations/flight paths, accessory gameplay effects, and most ability timing details are not defined by the roster. Keep them configurable and provisional if later implementation requires a test value.
- Local owner approval resolves DEADLOCK's depicted held/back-mounted rifle as one weapon in two carry states; it does not specify boundaries, mount coordinates, pivots, or stow transition behavior. A later local owner decision also identifies GLITCH's single weapon as a rifle in held and back-mounted carry states; the roster's older sidearm label is superseded locally. GLITCH boundaries, mounts, pivots, transition, and provenance remain open. Canonical DEADLOCK and GLITCH source reconciliation remains queued.
- Equipment art and OpenRaster workspaces are not runtime behavior. Each character needs both an authored rig/attachment review and simulation-to-presentation integration tests before this contract can be marked implemented.

## Validation gate before runtime integration

1. Inspect each item at 100%; confirm identity, completeness, source ownership, and no duplicates/clips.
2. Author owner, socket, pivot, depth, grip/stow state, and any tether endpoints; do not infer pivots from crop centers.
3. Assemble neutral and test all applicable poses, facing changes, joint seams, silhouette, grounding, and attachment readability.
4. In Godot, feed deterministic combat events into the presentation adapter and assert exactly the expected attachment reacts, including targeted and targetless owner events; assert no visual component changes damage, target, ability, wave, or reward state.
5. For SPARK, assert three separately identified drones. For ECHO, keep count-dependent tests gated until owner-approved data resolves the count; test only a variable-length independent set.
6. Keep each candidate quarantined until both visual/semantic art gates and event-link tests pass. Record actual evidence per character.


## User-confirmed requirement — equipment must function, not only appear

**Status: requirement confirmed; roster-wide behavior implementation is not complete.** Every weapon, cyberware item, accessory, tether, and drone included in a character must be represented in the authored rig and must behave through its source-backed simulation/presentation contract. A visible prop alone does not pass. Gameplay effects stay authoritative in combat simulation; presentation receives committed events and cannot cause gameplay outcomes. The event router now accepts targetless owner events needed by some support/accessory cues, but that transport test does not implement or verify an ability's gameplay effect. Do not invent unresolved cadence, timing, targeting, flight, or attachment transforms. Validate independently per character and equipment item, including correct owner, pose/facing behavior, event routing, no duplicate/phantom units, and no gameplay-state mutation from presentation. This reiterates the existing character map and validation gates; it does not approve art or resolve any open behavior details.
