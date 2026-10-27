# I-03a — Spatial formation evidence map

**Status:** Read-only decision support; spatial movement rules remain unapproved.  
**Prepared:** 2026-10-26 America/Chicago.  
**Runtime/tests/art:** No spatial runtime, data, test, or art changes were made for this audit.  
**Working-source limits:** The live Notion readbacks cited below were fetched on 2026-10-26 and report `verification.state=unverified`. The offline `migration_package/notion_reconstruction/` files are explicitly reconstructed summaries, not verbatim exports. Consult the live page again before canonical sync.

## Approved contract

- Combat remains automatic: allies choose targets and activate eligible abilities without manual target overrides or player-triggered skills.
- The approved preference contract has an optional soft Front/Middle/Rear position band and optional Vanguard/Assault/Support/Control role. There is no per-band recruit limit; the position band takes precedence when it conflicts with the selected role. A selected role guides movement within its selected band, or guides movement when no band is selected. Preferences are configured outside combat and persist per recruit through System Reboot.
- The user approved selector storage and persistence without spatial behavior as the current implementation scope. The preferences do not currently change movement, targeting, combat outcomes, coordinates, or formation placement.
- **Geometry approval (2026-10-26):** the user selected fixed battlefield depth plus enemy-relative distance. Depth bands stay fixed as combat advances. **Working interpretation:** measure distance from the enemy's current position as it moves; no contrary source/user wording was found. Exact ranges remain open. This interpretation does not authorize spatial implementation.
- **Partial spacing/pathing approvals (2026-10-26):** units in the same band use ordered positions, with founding-roster order as the working stable order; collision/pathing uses local avoidance while preserving the preferred band. Exact offsets/spacing and obstacle/boundary handling remain open; these directions do not authorize spatial implementation.
- **Regroup trigger approval (2026-10-26):** restore preferred arrangement after target changes or when movement becomes safe. The definition of “safe” and interruption behavior during attacks, defeat, or active abilities remain open.
- **Role movement and attack-start approved (2026-10-26):** Vanguard/Assault are non-ranged/contact-start; favor the enemy-facing side of a selected band, close to melee contact without a band, and attack at contact. Support/Control are ranged-start; favor the rear/outer side of a selected band and attack at their configured ranged engagement distance when possible; without a band, hold and attack there.
- **Optional-role fallback assumption:** if no role is selected, preserve the character's existing attack-range configuration. This is a conservative fallback pending contrary user instruction. Band-vs-attack-start priority remains open.
- Separately, the user approved background-controlled unit-specific walking speeds, ranged units holding their configured engagement distance, melee units closing to contact distance, and grounded presentation by default. A character may float only when its design gives it a clear ability or in-world reason. These statements do not define band geometry or override priorities.
- The BREAKER production spec says six squad members may visually overlap neighbors only while staying readable, not hiding the UI, and avoiding unusable collision. This is a presentation/collision constraint, not a spacing algorithm.

## Current prototype behavior — not canon

| Behavior | Observed implementation | Boundary |
|---|---|---|
| Encounter start | `CombatDirector._begin_encounter()` sets each ally's X to `190 + formation_start_offset_x`. The Undercity six-slot fixture contains prototype offsets from -96 to +144. | Slot offsets are fixture values; they are not derived from saved preference bands. |
| Depth/presentation | Each ally retains a fixed `formation_depth`; `main.gd` maps it to screen Y and a scaled ground shadow. Fixture depths range from -80 to +80. | Depth does not change during combat; it is neither a preference mapping nor a navigation lane. |
| Ally movement | Fixed 0.05-second simulation step. Living allies move only along X toward the single enemy at their configured `move_speed`, stopping at their engagement distance. Static fixture X/depth offsets produce a starting spread. | No dynamic spacing enforcement between allies, collision avoidance, pathfinding, lateral/vertical steering, re-forming, or regrouping was found. |
| Engagement | The prototype derives melee engagement from contact distance; ranged engagement uses a configured stand-off distance clamped to attack range. Combat style, start offset, depth, and speed are read from the six-slot prototype's slot entry (BREAKER also uses its character definition for stats). | These are placeholder slot rules, not per-recruit class contracts. Changing lineup order can pair a recruit with a different placeholder slot's melee/ranged and movement settings. How these settings interact with future band/role movement is unresolved. |
| Enemy targeting | The enemy selects the nearest living ally by absolute X distance; ties follow current array order because the comparison is strict `<`. | Formation preferences are not read by target selection. Keep this as existing prototype behavior, not an approved priority rule. |
| Role/position preferences | `formation_preference_service.gd` validates and saves selector values; `main.gd` builds and refreshes the selectors. No combat or presentation code reads `formation_preferences`. | Current scope is persistence only. |
| Grounding | Presentation draws a shadow at each ally's configured depth and uses a fixed ground anchor in the placeholder actors. | User-approved grounded default is a presentation constraint; float-capable exceptions need character-specific justification. |

## Evidence references

- Live [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de): retrieved 2026-10-26; last edited `2026-10-26T03:12:05.596Z`; cached as `Notion/Live Readbacks/01_Game_Design_and_Progression.md`; fetch state unverified. Establishes automatic policy and says spacing/position parameters need prototyping. Its older implementation-status sentence is stale relative to the current local combat simulation.
- Live [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d): retrieved 2026-10-26; last edited `2026-10-26T03:12:02.885Z`; cached as `Notion/Live Readbacks/07_Decision_Log_and_Change_Control.md`; fetch state unverified. Establishes the later soft position/role preference contract and Reboot persistence.
- Local `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md`, “Six-unit squad constraints”: permits neighbor overlap only while keeping characters legible, UI unobscured, and collision usable. The spec is an offline local handoff reference; no new Drive read was made for this audit.
- Local source trace: `scripts/progression/formation_preference_service.gd`, `scripts/main.gd`, `scripts/combat/combat_director.gd`, and `data/squads/undercity_six_slot.json`.
- Existing gap record: `docs/AUTOMATIC_ABILITIES_AND_FORMATION_SOURCE_AUDIT_2026-10-26.md` and `docs/OPEN_QUESTIONS.md`.

## Decisions still required before spatial behavior changes

The source establishes preference meanings but supplies no executable spatial mapping. Do not infer concrete values from the six-slot Undercity fixture. The user needs to specify:

1. **Band geometry — partly resolved:** the depth axis is fixed to the battlefield and depth bands stay fixed as combat advances; the distance axis is enemy-relative. Working interpretation: evaluate against the enemy's current position as it moves. Exact band ranges and coordinate mapping remain open; no numeric values are approved.
2. **Spacing and occupancy — partly resolved:** assign ordered positions within a shared band, using founding-roster order as the working stable order. Exact inter-unit spacing, world-space offsets/layout, and how to handle less readable constrained formations remain open.
3. **Collision and pathing — partly resolved:** use local avoidance while preserving a recruit's preferred band. Specify battlefield bounds, obstacle classes, permitted route behavior around allies/enemies, and what to do if local avoidance cannot find a route.
4. **Cohesion and regrouping — partly resolved:** regroup after target changes or when movement becomes safe. Define what counts as safe and whether/how attacks, defeat, and active abilities interrupt or delay the regroup.
5. **Role movement and attack-start — mapped, priority open:** Vanguard/Assault favor the enemy-facing side within a band, close to melee contact with no band, and attack at contact. Support/Control favor the rear/outer side within a band and attack at configured ranged engagement when possible; with no band, they hold and attack at that distance. If no role is set, the conservative fallback is the character's existing attack-range configuration. Exact positions and what wins when band placement conflicts with attack-start distance remain open.
6. **Priority conflicts:** what movement rule wins when band/role guidance conflicts with ranged stand-off, melee contact, enemy approach, an obstacle, or the battlefield edge. Preserve the approved automatic target/ability policy and do not make preference selection a targeting override.
7. **Default/exception grounding:** grounded is the default. Name which characters or abilities, if any, justify floating before authoring floating placement; none are derived by this audit.

Per-character walking speed remains a hidden implementation parameter; no speed selector or player-facing pace control is approved. Existing per-slot speeds are prototype tuning only.

## Safe next step

Keep the current preference selectors and persistence only. Ask for the missing spatial values as one design contract before adding preference-driven movement. The selected post-layout-testing tuning sequence does not authorize a test scaffold or define its scope; record that prerequisite separately and do not create/run one until approved. Until the spatial contract is approved, do not wire preferences into `CombatDirector`, change placeholder slot offsets/depths/speeds, or alter automatic targeting. This audit is not implementation or validation evidence.
