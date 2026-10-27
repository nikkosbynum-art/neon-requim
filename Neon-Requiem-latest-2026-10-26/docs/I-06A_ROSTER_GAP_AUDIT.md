# I-06a — Founding Recruit Data and Source Gap Audit

## Owner-selected scope follow-up — 2026-10-26 America/Chicago

Keep the functional level purchase/stat-growth path BREAKER-only until individualized combat and economy evidence supports expansion. Preserve all-twelve recruitment and evolution records. This is a scope decision only: final stats, costs, curves, and caps remain unapproved. No runtime or test change is recorded here.

**Status:** COMPLETE — read-only audit, 2026-10-26 America/Chicago. No runtime code, game data, tests, art, or user saves were changed.

## Evidence reviewed

- data/characters/founding_recruits.json — twelve IDs, names, factions, broad roles, rarities; no individual combat statistics, ability rules, or equipment configuration.
- data/characters/breaker_t1.json — only individual recruit combat definition; values and evolution/skill notes are explicitly marked prototype/reference-only.
- data/squads/undercity_six_slot.json and data/enemies/undercity_grunt.json — generic squad/enemy prototype fixtures and numeric values explicitly marked placeholders.
- scripts/combat/combat_director.gd and scripts/main.gd — BREAKER uses the BREAKER definition; all other active IDs receive shared placeholder stats and generic placeholder actors.
- scripts/progression/economy.gd; scripts/main.gd; data/progression/recruitment_prototype_profile.json — BREAKER has the credit-based x1/x10 run-level path. The other eleven have no individual upgrade purchase path. The profile's 300/600/1,200 rarity prices and 600 starting credits are explicitly trial-only.
- scripts/progression/evolution_service.gd — all twelve IDs can record evolution tier transactions; that does not implement per-tier stat, ability, or art changes.
- docs/ATTACHMENT_FUNCTION_CONTRACT.md, Notion/Live Readbacks/02_Founding_Recruit_Roster.md, and reconstructed migration_package/notion_reconstruction/02_Roster.md — source-backed broad character/skill/equipment links and explicit open questions. The local Notion readback is dated 2026-10-24T03:56:33.654Z and marked verification: unverified; the offline reconstruction is explicitly non-verbatim. No live Notion or Drive connector read was made for this audit.

## Recruit-by-recruit source and runtime gap matrix

| Recruit | Source-backed identity / skill / equipment input | Runtime definition and level path | Missing before individualized combat implementation |
|---|---|---|---|
| BULWARK | Tactical Soldier / Combat Medic; Last Protocol emergency squad heal; roster contract references rifle, medical pack, hoses | No individual stats, actor, ability, or level-up path; generic placeholder | Ability trigger/effect/target/rules; rifle behavior; authored medical attachments; individual stats and upgrade policy |
| BREAKER | Brawler / Cyberpsycho; Redline boosted impact with neural strain; Tier I boundary is shoulder shell over biological upper arm, elbow-start prosthesis | Only individual definition and run-level purchase path; numeric values/cost curve are prototype trial values | Canonical/final numbers remain open; Redline trigger, strain, effect duration/limits and event contract; production-ready rig/art still open |
| CIPHER | Netrunner / Sharpshooter; Ghost Round cyberware-disrupting precision shot; hacked rifle optics | No individual combat definition/actor/level path; generic placeholder | Ability and target/implant semantics; rifle/optic authored mounts and behavior; individual stats/upgrade policy |
| SPARK | Combat Engineer / Drone Operator; Scrap Swarm has exactly three attack drones | No individual combat definition/actor/level path; generic placeholder; three static quarantined drone cutouts exist | Drone identity-to-ability mapping, formation/path/target/firing/return behavior; simulation rules; rig integration and individual stats/upgrades |
| SPECTER | Infiltrator / Blade Specialist; Null Trace cloaked priority strike | No individual combat definition/actor/level path; generic placeholder | Cloak/priority target rules and timing; blade grip/sheath and cadence; stats/upgrades |
| IRONCLAD | Heavy Gunner / Tank; Lockdown anchors and suppresses; approved reference has powered armor/heavy weapon | No individual combat definition/actor/level path; generic placeholder | Exact weapon subtype and stow state; anchor/suppress mechanics; armor rig attachments; stats/upgrades |
| STITCH | Rippertech / Chem Specialist; Black Market Cocktail heals/boosts with instability | No individual combat definition/actor/level path; generic placeholder | Heal/boost amounts, instability and targeting/timing; medical/chem kit and use events; stats/upgrades |
| RECOIL | Shotgunner / Brawler; Breach Charge penetrates frontline; hydraulic prosthesis | No individual combat definition/actor/level path; generic placeholder | Shot cadence/spread and charge path/impact mechanics; prosthesis chain and event behavior; stats/upgrades |
| ECHO | Netrunner / Drone Operator; remote drones are sensory extensions; Signal Cascade creates decoys | No individual combat definition/actor/level path; generic placeholder | Visible device/decoy mapping and count, paths/formation/sensory rules; independently owned attachments; stats/upgrades |
| VECTOR | Blade Specialist / Skirmisher; Slipstream multi-target dash | No individual combat definition/actor/level path; generic placeholder | Dash target/path/timing and blade cadence; attachment pivots/mounts; stats/upgrades |
| DEADLOCK | Tactical Marksman / Anti-Cyberware; System Break disables strongest enemy implant; rifle source link | No individual combat definition/actor/level path; generic placeholder | Weapon count/carry-stow transition; implant ranking/effect semantics and rifle behavior; stats/upgrades |
| GLITCH | Cyberpsycho / Infiltrator; Frame Skip accelerates target-switching; current local owner decision identifies one rifle in held and back-mounted carry states | No individual combat definition/actor/level path; generic placeholder | Rifle part boundaries, mounts, pivots, transition, and provenance; target-switch event semantics; cape/armor ownership; stats/upgrades |

## Cross-roster implementation facts and blockers

- Recruitment is implemented for all twelve using deterministic unique purchases. The currently approved prototype prices are rarity-based, not individualized upgrade costs.
- Combat target/attack/damage flow is automatic and shared; squad movement/attack stats use the generic placeholder profile for every recruit except BREAKER. That profile, enemy scaling, wave credit values, and slot speeds are test fixtures, not character canon.
- All twelve can record permanent evolution tiers, but these records currently do not change stats, abilities, appearance, or cyberware.
- No source-reviewed individual base stats, defense, damage, cooldown/cadence, ability trigger/cost/target/fallback rules, enemy implant taxonomy, or individual level-cost curves were located in the local roster sources reviewed. Do not copy BREAKER values to other recruits.
- Historical source conflicts recorded by this audit: ECHO's count/mapping; DEADLOCK's weapon count and carry state; GLITCH's sidearm/visual conflict. A later local owner decision resolves GLITCH identity as one rifle in two carry states; the roster's sidearm wording is superseded locally, while exact boundaries, mounts, pivots, transition, and provenance remain open. ECHO's decoys are distinct from physical sensory devices, but visible mapping/count remain open. SPARK's three drones are source-backed by the roster, but their formation and behavior are unresolved.

## Next decisions for I-06

1. Resolve combat/ability semantics (I-04/I-05 dependencies) before assigning role-specific simulation numbers or ability effects.
2. Decide whether the first leveling expansion is BREAKER-only balance validation or a twelve-recruit shared upgrade framework with per-recruit data supplied only after approved values exist. No costs or stats are proposed by this audit.
3. Provide source/artist decisions for the equipment conflicts above and ability-specific attachment inputs; preserve unresolved fields as unset until decided.

**No status change to implementation readiness:** I-06 remains blocked on approved per-recruit data and upstream I-04/I-05 contracts. The audit closes only I-06a's read-only evidence task.
