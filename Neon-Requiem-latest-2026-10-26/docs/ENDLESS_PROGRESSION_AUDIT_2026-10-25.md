# Endless progression beyond wave 125 — source and runtime audit

## Follow-up selection — 2026-10-26 America/Chicago

The owner selected deferral of scaling, encounter generation/pool/composition, boss cadence, endless rewards/milestones, and above-125 offline reward inputs. Keep wave 126 as the approved design start and retain the current runtime/save ceiling of 125 until a complete profile and compatible save policy are ready. Current SaveService writes schema v2 and migrates known v1. Do not extrapolate provisional Undercity data.

**Audit date:** 2026-10-25 America/Chicago  
**Status:** Start boundary source-approved; endless behavior is not specified enough to implement.  
**Runtime change:** None.  
**Validation:** Documentation/code inspection only; no tests were run for this audit.

## Source-backed scope

The live [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de) page says the five districts cover waves 1–125 and procedural endless progression follows. It describes endless procedural waves and retreat to the highest cleared holding wave. The live [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d) keeps difficulty curves, wave scaling, economy rates, boss encounters, and exact reward/cost curves open or playtest-only. The [Production Roadmap](https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e) approves 1.0 district scope through 125 and directs progression/balance decisions to testing. The [Codex Reconstruction Handoff](https://app.notion.com/p/40394c5658c881b990ece736c16dc0ee) calls for procedural/infinite waves but labels earlier multipliers and formulas illustrative.

The live Notion fetches were read-only and returned `verification.state: unverified`. The Game Design page last-edited time was `2026-10-26T03:12:05.596Z`; Decision Log and Roadmap times in the prior source readback are `2026-10-26T03:12:02.885Z` and `2026-10-26T03:12:09.241Z`. These timestamps are page metadata, not verified attestations. Google Drive was not read or changed for this audit.

What is approved is the **start point**: procedural endless progression starts at wave 126. “Procedural” does not settle the algorithms, content pool, schedule, or scaling values below.

## Current implementation boundary

- `data/world/district_scope.json` records `endless_progression_starts_at_wave: 126` as scope metadata; runtime does not consume it.
- `data/waves/undercity_prototype.json` sets `last_wave` and `prototype_wave_limit` to 125. Waves 26–125 reuse provisional Undercity enemy, scaling, reward, and battlefield data.
- `scripts/combat/combat_director.gd` advances only to the configured `last_wave`, then enters `prototype_complete`. Loading clamps the current wave and run high-water to that same configured limit.
- `scripts/persistence/save_service.gd` has `SAVE_VERSION := 1` and `MAX_PROTOTYPE_WAVE := 125`. It rejects run wave, run high-water, and permanent `highest_wave_ever` values above 125. Regression fixtures explicitly reject 126.
- The current Undercity grunt uses provisional linear stat increments (`hp_per_wave: 9`, `attack_per_wave: 1.6`). The current encounter reward is provisional linear data (`base_credit_reward: 12`, `credit_reward_per_wave: 4`). These settings are not an approved endless curve and must not be extrapolated as canon. The approved economy direction is exponential, but the rate and reward/cost relationship remain open.
- Current tests validate the 125 prototype stop and reject saved wave 126. They do not establish endless generation, high-wave arithmetic safety, or endless save migration.

## Missing rules required before runtime implementation

1. **Enemy difficulty:** formula or table for HP, attack, defense/power, and any other scaled fields; whether growth is continuous per wave or staged; rounding; caps/soft caps; and an upper numeric safety bound.
2. **Generated encounters:** eligible enemy/archetype pool, faction weights/rotation, composition size and role rules, repeat/variety constraints, and deterministic seed/replay contract. “Mix factions throughout” does not define a generator distribution.
3. **Boss cadence:** whether endless waves have bosses; interval/cadence and any phase/reset rules; allowed recurring identities; and the relationship to the five one-per-district bosses. The district endpoint trial does not define post-125 bosses.
4. **Rewards and milestones:** ordinary credits formula after 125, periodic milestone bonuses and intervals, evolution/reboot material treatment after the five first-clear districts, and any endless-specific reward cap. The exponential economy concept does not supply coefficients.
5. **Offline holding-wave payout:** since the approved prototype prices offline credits from the ordinary reward at the saved holding wave, define the endless reward input and safe bounds before a holding wave can exceed 125.
6. **High-wave/save policy:** maximum supported wave and numeric/overflow behavior; whether the current cap is raised or a new save schema/version is required; and explicit copy-based migration mapping/rollback tests for saves made under version 1. The approved save policy requires a supported migration path before older saves are migrated.
7. **Retreat/reboot interaction:** confirm that the existing highest-cleared holding-wave retreat and Reboot award logic remain valid after the five districts, including first-clear/milestone semantics when district endpoints are exhausted.

## Decision-ready next step

Approve an **Endless v1 progression profile** with explicit values/rules for the seven items above. Once that profile is source-approved, implementation can replace the prototype terminal state with a generator and add tests for deterministic composition, scaling at the boundary and high waves, boss cadence, reward accounting, overflow limits, save/load above 125, and version-1 migration. Until then, retain the 125 runtime/save boundary. Do not edit the provisional Undercity wave-13 visual fixture as part of this work.

## Changes and sync

This is a source/runtime audit only. No code, runtime data, art, or user save changed, and no tests were run. The documentation update is queued for grouped Notion reconciliation. No remote Notion write or Google Drive upload is claimed.

Options brief: `docs/ENDLESS_PROGRESSION_OPTIONS_2026-10-25.md` presents NON-CANONICAL qualitative choices for each missing system and a defer/keep-cap option. No choice or numeric value is approved.
