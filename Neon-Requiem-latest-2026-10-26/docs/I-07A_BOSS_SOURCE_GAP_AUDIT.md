# I-07a — Named boss identity and source gap audit

**Status: COMPLETE — read-only evidence audit**  
**Date:** 2026-10-26 America/Chicago  
**Scope:** five approved named boss concepts; local boss/enemy/district data; available offline and cached Notion source handoff.  
**Excluded:** district assignment, new boss definitions, runtime/data/test changes, real saves, and foreground UI.

## Evidence and sources

The source records available locally include cached Notion readbacks in `Notion/Live Readbacks/` and their source URLs. They are local handoff copies, not a fresh Notion read in this audit. The prior source-read timestamps and connector status are documented in `docs/MIGRATION_REPORT.md` (district/boss audit entry, 2026-10-26 UTC); those fetches reported `verification.state: unverified`.

- [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de) — unique named enemies/bosses are guaranteed recruitable on first defeat; after recruitment, that unique identity is permanently excluded from the enemy generator; generic archetypes may recur.
- [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d), [Founding Recruit Roster](https://app.notion.com/p/40394c5658c8812d849be3d32629920e), [Production Roadmap](https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e), and [Asset Library & Artwork Manifest](https://app.notion.com/p/40394c5658c8816f9d76d1d08afbbfd9) were available only as cached local readbacks for this task.
- Local data inspected: `data/world/district_scope.json`, `data/enemies/undercity_grunt.json`, `data/waves/undercity_prototype.json`, and `data/progression/progression_prototype_profile.json`.
- Local concept inventory inspected: `migration_package/drive_assets/MANIFEST.md`, `README.md`, and all four PNGs under `migration_package/drive_assets/concept_art/`.

## What the available sources support

| Topic | Source-backed fact | Limit |
|---|---|---|
| Boss identities | The five approved names are Patchwork, Ghostlight, Chainbreak, Civic Warden, and Sable Venn. Patchwork replaces the earlier name Nacre. | Approval is for concept names; no full boss profiles are present. |
| District scope | Five 25-wave bands run from Undercity (1–25) through The Spire (101–125); one named boss per district is approved. Endless starts at 126. | Each `district_assignment` in `data/world/district_scope.json` is null. Endpoint placement is recorded as a pacing-test trial, not a locked final spawn rule. |
| Acquisition | A named boss is guaranteed recruitable on first defeat. | Sources do not resolve whether defeat grants ownership immediately or unlocks a separate recruitment action, nor how an unrecruited defeated boss is handled on replay. |
| Identity exclusion | A unique identity is permanently excluded from the enemy generator once recruited; generic archetypes can recur. | No source specifies the exact transaction boundary/timing or pre-recruit recurrence behavior. |
| Prototype material reward | The feasibility profile grants 1 repeatable Evolution Data per successful clear plus 1 extra on a first-cleared named boss. | This is shared prototype material balance, not an approved boss-specific credit reward or a complete encounter reward table. |
| Enemy/combat records | The only runtime enemy definition found is the prototype Undercity Grunt. The wave profile explicitly reuses placeholder content across the prototype range. | No named boss stats, faction, abilities, target rules, AI, attack timing, encounter scripts, or compositions are defined. |

## Asset evidence

The reconstruction package contains four concept/reference PNGs, not five boss portraits or production art. Dimensions and encoding are: `01_world_roster_concept_sheet.png` 1536×1024 RGBA; `02_character_faction_design_sheet.png` 1536×1024 RGB; `03_breaker_evolution_reference.png` 1536×1024 RGB; `04_breaker_production_board.png` 1536×1024 RGB. Visual inspection found no named-boss identity sheet. The second sheet contains generic enemy archetypes, including a generic “BOSS / ELITE” mech illustration; no evidence ties it to any of the five names. The first file's visible content is a BREAKER production board despite its world/roster filename and manifest label, so it cannot serve as a boss mapping source. All four are concept references only, not animation-ready/runtime assets.

No separate named-boss art, model, rig, animation, or boss-specific production asset was found in the inspected local handoff. This is a local-package finding, not a claim that the remote Drive library was searched in this audit.

## Existing implementation boundary

- `district_scope.json` is metadata and is not consumed by runtime encounter systems; the five boss assignments remain null.
- `CombatDirector` transports an optional `boss_id` on a wave-clear event. `PrototypeMaterialRewardService` accepts a canonical `boss.*` claim ID for the approved prototype first-clear material bonus.
- The test ID `boss.test_warden` is a synthetic regression fixture, not a canonical boss profile.
- There is no boss data directory/profile, boss spawn, unique-ownership transaction, or enemy-generator exclusion implementation. The transport and material ledger do not implement the encounter/recruitment lifecycle.

## Unresolved decisions and inputs

1. Map each of the five identities to one of the five districts.
2. Confirm whether the district-endpoint placement remains only a pacing trial or becomes the authored encounter rule.
3. Define boss faction/identity, combat role, stats and scaling, abilities/automatic target behavior, and encounter composition/script.
4. Define ordinary credit/other encounter rewards. Keep the already-approved prototype Evolution Data policy distinct from those rewards.
5. Decide whether first defeat directly grants the unique recruit or unlocks a separate purchase/recruit action.
6. Define post-defeat/pre-recruit replay behavior and the exact point at which the unique boss is removed from generation; retain permanent exclusion after recruitment.
7. Provide boss-specific approved visual references and production assets, plus any required audio/effect sources.

No boss mapping or mechanics are inferred here. No code, runtime data, tests, art, saves, or remote documents changed; no tests were run.
