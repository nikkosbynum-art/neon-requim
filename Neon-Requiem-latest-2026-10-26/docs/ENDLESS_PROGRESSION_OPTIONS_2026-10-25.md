# Endless v1 progression — decision options (NON-CANONICAL)

**Status: Proposal only. Nothing below is approved or implemented.** The live source approves procedural endless progression beginning at wave 126, while the current runtime and version-1 save validation stop at 125. This brief offers choices for a future Endless v1 profile; it does not change that boundary or supply numeric values.

**Current safe state:** keep the runtime/save cap at 125 until the user approves a complete profile. See `docs/ENDLESS_PROGRESSION_AUDIT_2026-10-25.md` for the source and code audit. The existing Undercity wave-13 presentation boundary remains a provisional test fixture.

## 1. Enemy difficulty scaling

| Option | Proposed rule shape | What it would unlock |
|---|---|---|
| **A — Continuous curve** | Scale enemy attributes from wave 126 using one continuous formula. The formula, coefficients, rounding, and numeric ceiling still need approval. | One compact data-driven scaling function and boundary/high-wave tests. |
| **B — Staged bands** | Use a selected curve within named progression bands, with an approved change at each band boundary. Band size, curve, and transition behavior need approval. | Clear pacing checkpoints and independently tunable balance segments. |
| **C — Soft or hard cap** | Grow with a selected curve, then approach a soft ceiling or stop at a hard ceiling. The ceiling and post-cap behavior need approval. | A defined difficulty maximum and arithmetic/performance safety target. |

## 2. Encounter composition

All choices must use a user-approved enemy pool and preserve the source direction that factions mix as progression develops. The approved faction names are not a composition algorithm.

| Option | Proposed rule shape | What it would unlock |
|---|---|---|
| **A — Seeded weighted pool** | Choose eligible enemy archetypes from approved faction weights, using a saved or reproducible seed. Weights, group sizes, and anti-repeat rules need approval. | Reproducible procedural encounters and probability/variety tests. |
| **B — Encounter templates** | Cycle through authored composition templates and apply seeded variation within each template. Template contents and rotation need approval. | Stronger encounter readability with controlled replay variation. |
| **C — Faction sequence** | Rotate or schedule factions, with composition templates selected inside each faction segment. Order, length, and mixing behavior need approval. | Predictable faction pacing and targeted content/visual planning. |

## 3. Boss cadence after wave 125

The five named bosses remain one per launch district; endpoint placement is only the pacing-test baseline. Any repeated named identity must respect the established rule that a recruited unique identity is excluded from enemy generation.

| Option | Proposed rule shape | What it would unlock |
|---|---|---|
| **A — No endless bosses** | District bosses end with wave 125; endless uses ordinary encounters only. | A smaller first endless implementation with no new boss lifecycle. |
| **B — Repeatable generic elites** | Add repeatable, non-unique elite/boss-like archetypes on a selected cadence; do not reuse named recruit identities. | A periodic difficulty/reward beat without altering unique-boss ownership. |
| **C — Eligible named returns** | Allow a selected cadence of named bosses only while their unique recruit has not been acquired; permanently exclude each after acquisition. Cadence and selection rules need approval. | Reuse of named boss content while retaining the acquisition exclusion rule. |

## 4. Rewards and milestones

The approved economy direction is exponential for wave rewards and leveling costs, but the rate and relationship remain open. Existing linear Undercity values are provisional and are not candidates for automatic extension.

| Option | Proposed rule shape | What it would unlock |
|---|---|---|
| **A — Exponential ordinary rewards only** | Define an ordinary clear reward curve for all endless waves; no recurring endless milestone bonus. | Basic credit accounting, offline-rate input, and reward-curve tests. |
| **B — Exponential rewards plus recurring milestones** | Add a repeatable milestone schedule with explicitly approved bonus types and amounts. | Long-run reward beats and repeatable milestone tests. |
| **C — Exponential rewards plus one-time milestones** | Award a first-clear bonus at selected endless milestones, with no repeat bonus after that milestone is recorded. | Permanent first-clear tracking and cross-Reboot duplicate-prevention tests. |

For every option, choose the coefficients, milestone spacing, bonus type/amount, and treatment of Evolution Data and Network Influence after the five district endpoints. Offline credit claims must continue to award credits only and must not advance waves.

## 5. High-wave and save compatibility

The current version-1 schema rejects wave, run high-water, and permanent highest-wave values above 125. The approved migration policy requires an explicit supported source version, copy-based migration, validation, rollback, and preservation of the original before older saves are migrated.

| Option | Proposed rule shape | What it would unlock |
|---|---|---|
| **A — Keep the 125 cap for now** | Defer endless runtime and retain current save validation until the other profile decisions are ready. | No save compatibility changes; implementation resumes only after a complete profile is approved. |
| **B — Bounded wave counter** | Keep the existing wave fields and define a finite supported maximum with explicit arithmetic/overflow handling. Confirm whether the current schema can safely accept that range; test existing version-1 saves before changing validation. | Endless play to an agreed ceiling with a simpler save representation. |
| **C — Segmented progression counter** | Store an approved segment/cycle plus a bounded within-segment wave, with an explicit versioned copy-migration from version 1. Segment behavior must be separately approved. | A larger progression space without relying on one ever-growing wave integer, plus migration tests. |

No option makes the game mathematically unbounded. If wave numbering or segmented progression changes the save shape, define the version-1 mapping and rollback behavior before shipping the new reader/writer.

### Current implementation and save-policy impact — read-only evidence

This section documents present behavior so the choices are easier to evaluate. It does not select a save option or authorize a migration.

- `scripts/persistence/save_service.gd` writes `save_version: 1` and accepts only version 1. The current v1 contract requires integer run `wave` and `highest_cleared_wave` fields, with `wave >= 1` and high-water `>= 0`; both are capped at `MAX_PROTOTYPE_WAVE = 125`. Permanent `highest_wave_ever`, when present, is also capped at 125. A value of 126 in any of those fields is rejected.
- The current v1 shape also accepts older v1 payloads that omit optional fields such as per-slot `squad_hp` or the offline timestamp, using documented defaults/baseline behavior. Unknown fields are preserved by supported version-1 load/update/save operations. This is compatibility within the existing v1 shape, not an implemented migration from a different schema version.
- The parser rejects a missing/invalid version and every version other than 1. No source schema version has an implemented migration path. Under the approved policy in `docs/DESIGN_DECISIONS.md`, any future older-version migration must work on a copy, validate the migrated copy, preserve the original as recoverable, and roll back if migration or commit validation fails. Newer/unknown versions remain protected from ordinary writes.
- Existing save transactions stage and validate a temporary file, preserve verified `.bak`/`.bak.prev` recovery copies, verify committed content, and attempt rollback on commit failure. Recovery reads primary first, then `.bak`, then `.bak.prev`, reports when a recovery copy was used, and does not rewrite the primary as part of recovery. These are existing save protections; they do not implement wave-126 support or a schema migration.
- Existing regression coverage includes version-1 section round-trip, optional older v1 fields, rejection of run/permanent wave 126, rejection of unsupported versions, backup precedence/recovery, save fault injection and rollback, and Reboot persistence. It does not test progression saves above 125 or a v1-to-new-version migration. This audit did not run tests.

**Implications for the listed options:**

- **A — Keep the 125 cap:** preserves current version-1 validation and existing saves without a new mapping. Endless runtime remains deferred.
- **B — Bounded wave counter:** if the fields and representation stay unchanged and only a finite, explicitly approved ceiling is widened, existing v1 saves at or below 125 could remain in-range without field mapping. That is not yet proven safe: the ceiling, numeric/reward arithmetic, and the decision to retain or bump `save_version` must be explicit, with tests for old v1 loads, the new boundary, and overflow/rejection just beyond it. No maximum is selected here. If the chosen representation changes, the new-version and migration requirements below apply.
- **C — Segmented progression counter:** adding segment/cycle fields changes the save shape. Select a new version and define how every supported v1 wave/high-water/permanent high-water value maps to the new representation before implementation. Then migrate a copy, validate it, retain the original until commit succeeds, and test rollback and recovery. This brief does not invent that mapping.

Current code behavior gives no basis for claiming either a supported maximum above 125 or successful migration of existing user saves.
## Selection worksheet

To prepare an implementable profile, select one option in each section and supply the unspecified formula/weights/cadence/limits called out above:

- Scaling: **A / B / C**
- Encounter composition: **A / B / C**
- Boss cadence: **A / B / C**
- Rewards: **A / B / C**
- High-wave/save compatibility: **A / B / C**
- Or **Defer**: keep the runtime and save cap at 125 while postponing endless rules.

Selections are design input only. Implementation starts only after the selected rules, their numeric values, and save behavior are explicitly approved and recorded in the canonical decision source.

## Source notes

- Live [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de): endless procedural progression follows the five district bands; highest-cleared holding-wave retreat; scaling and economy details remain open.
- Live [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d): difficulty curves, wave scaling, boss encounters, reward/cost curves, and milestone details require testing or remain unresolved.
- Live [Production Roadmap](https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e): 1.0 district bands through 125 and playtest-based progression tuning.
- Local [endless-progression audit](ENDLESS_PROGRESSION_AUDIT_2026-10-25.md): exact runtime/save cap and validation boundary.

Live Notion fetch results report `verification.state: unverified`; this brief is a non-canonical local proposal. No Google Drive source was used, and no remote content was changed.

