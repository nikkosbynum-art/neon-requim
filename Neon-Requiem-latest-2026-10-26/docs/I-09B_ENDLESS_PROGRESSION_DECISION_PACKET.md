# I-09b — Endless progression decision packet

## Owner-selected deferrals — 2026-10-26 America/Chicago

Preserve wave 126 as the design-approved endless start while retaining the current 125 runtime/save ceiling. Defer the complete scaling profile, encounter generator/pool/composition, boss cadence, endless rewards/milestones, and above-125 offline reward inputs until a complete profile and compatible save policy are available. Preserve credit-only offline rewards, saved holding-wave behavior, claim-save, no wave advance, and the eight-hour claim target. Do not extrapolate the provisional Undercity fixture. Current SaveService writes schema version 2 and migrates known version 1; references below that call version 1 current are superseded.

**Status:** Decision support only; no endless progression rule beyond the approved start boundary is selected here  
**Date:** 2026-10-26 America/Chicago  
**Scope:** Present neutral, selectable policy shapes for progression after wave 125, based on the current source/runtime audit and prior qualitative options.  
**Excluded:** New formulas, numeric values, wave profiles, runtime/save changes, or claims that endless play is implemented.

## Current approved scope and safe implementation boundary

- Procedural endless progression starts at **wave 126** after the five approved district bands through wave 125.
- The high-level design describes endless procedural waves and retreat to the highest previously cleared holding wave.
- Offline rewards are credit-only, use the saved holding wave's ordinary reward as their hourly basis, do not advance waves, and are saved on claim. The eight-hour cap is the current design target. This policy is already selected; it is not reopened by this packet. The ordinary reward for a holding wave above 125 still needs an approved endless reward profile.
- The general economy direction is exponential for wave rewards and leveling costs, but it does not specify endless coefficients, growth stages, or reward relationships.
- The current runtime and version-2 save validation stop at wave 125. Until a complete profile and save policy are selected and validated, retain that boundary. Known version-1 saves migrate to version 2. The existing Undercity values are provisional and are not an endless progression formula.

Source evidence is summarized in `docs/ENDLESS_PROGRESSION_AUDIT_2026-10-25.md` and `docs/MIGRATION_REPORT.md`, from [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de), [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d), [Production Roadmap](https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e), and [Codex Reconstruction Handoff](https://app.notion.com/p/40394c5658c881b990ece736c16dc0ee). The cached live fetches were read-only and report `verification.state: unverified`; this packet did not perform a new remote read. The local handoff is reconstructed, not a verbatim export.

**Decision status:** Each option below is a qualitative proposal only. Choosing an option family does not approve a formula, numeric value, weight, interval, limit, reward amount, boss mechanic, or save mapping. No value is to be filled by inference.

## 1. Enemy scaling model

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Continuous progression** | One continuous scaling model across endless waves. Its function, inputs, rounding and safety limits remain to be specified. | A compact rule can be tuned continuously; it requires boundary and high-wave arithmetic validation. |
| **B — Staged progression bands** | Define a sequence of progression stages with separately specified scaling behavior and transitions. | Supports explicit pacing changes; requires approved stage boundaries and each stage's model. |
| **C — Scaling with a soft/hard ceiling** | Select a progression model and define a soft ceiling or hard stop plus post-ceiling behavior. | Provides a defined late-run bound; requires the ceiling behavior and consequences to be specified. |

**Still required for any option:** which enemy attributes scale, formula/table, stage boundaries if applicable, rounding, safety bounds and behavior when a bound is reached. No coefficients or ceilings are proposed here.

## 2. Procedural encounter composition

The approved faction names do not define an enemy pool or composition algorithm.

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Seeded weighted pool** | Select eligible enemy archetypes using approved weights and a reproducible seed policy. | Naturally supports variation and reproducibility; requires an approved pool, weights, group composition and repeat controls. |
| **B — Authored encounter templates** | Select among approved encounter templates, with any randomized variation defined explicitly. | Gives direct author control over encounter readability; requires templates, selection/rotation policy and any variation rules. |
| **C — Faction schedule** | Define a progression schedule for faction appearances and a composition policy within each scheduled segment. | Makes faction pacing explicit; requires schedule, mixing behavior and composition rules. |

**Still required for any option:** eligible enemy/archetype pool, composition size/roles, faction appearance/mixing, repeat/variety constraints, and deterministic seed/replay contract. “Mix factions” alone is not an executable rule.

## 3. Boss cadence after wave 125

The five launch named bosses remain one per launch district; their endpoint placement is a pacing-test baseline. The source does not define an endless boss schedule. Any handling of unique recruit identities must preserve permanent enemy-generator exclusion after recruitment.

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — No endless bosses** | Endless waves contain no boss encounters after the five districts. | Avoids a new endless boss lifecycle; removes recurring boss encounters from the endless profile. |
| **B — Repeatable generic elite/boss archetypes** | Define repeatable non-unique archetypes and their place in endless encounters. | Avoids reusing recruited named identities; requires approved archetype content, cadence and encounter rules. |
| **C — Eligible named identities** | Define whether named identities can return while not permanently recruited, and how the existing exclusion rule applies. | Reuses named identity content; requires a compatible recruitment/replay lifecycle and an approved cadence/selection policy. |

**Still required for any boss-bearing option:** cadence and phase behavior, eligible identities/archetypes, interaction with first-defeat recruitment, and generator-exclusion semantics. No schedule or boss behavior is inferred.

## 4. Ordinary rewards and endless milestones

The economy direction is exponential, while exact ordinary reward and cost relationships remain open. The provisional linear Undercity credit data is not a candidate curve to extend automatically.

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Ordinary wave rewards only** | Define the ordinary endless credit reward and do not add an endless milestone bonus. | Simplifies reward accounting and the offline-rate input; provides fewer explicit milestone reward beats. |
| **B — Repeatable milestone rewards** | Define ordinary rewards and recurring milestone events/bonuses. | Adds repeatable progression beats; requires approved milestone schedule and reward semantics. |
| **C — One-time first-clear milestones** | Define ordinary rewards and one-time rewards for selected endless first clears. | Supports durable first-clear goals; requires permanent milestone tracking and duplicate-prevention rules. |

**Still required for any option:** ordinary credit rule; milestone boundaries/recurrence; reward types and values; and how Evolution Data, Network Influence, and any other permanent materials behave after the five district endpoints. No amount, interval or post-district material rule is selected here. Existing prototype material payouts remain trial values, not a canonical endless reward table.

## 5. Offline credit payout for holding waves above 125

The approved offline structure remains unchanged: credits only, saved holding-wave basis, claim-time save, no wave advancement, and the current eight-hour target. The payout basis for an endless holding wave depends on the unresolved endless ordinary reward rule.

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Defer unsupported high-wave claims** | Keep claims tied to supported reward data; defer a claim whose saved holding wave is above 125 until its endless reward input is approved. | Avoids inventing payouts; a player at an unsupported high holding wave waits for that profile before receiving this claim. |
| **B — Use the approved endless holding-wave reward** | After the endless ordinary credit rule is approved, use its saved holding-wave reward as the hourly claim input, under the existing offline constraints. | Keeps payouts linked to current holding progress; requires the ordinary reward rule plus high-wave rate/bounds validation. |

No option changes the credit-only/no-wave-advance/claim-save policy. This packet selects no high-wave rate, payout formula, or cap change.

## 6. High-wave ceiling and overflow behavior

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Retain the 125 cap for now** | Keep the current runtime/save limit while deferring endless implementation. | Preserves the current version-2 contract and supported version-1 migration; wave 126 remains design-approved but not playable. |
| **B — Bounded wave counter** | Set a finite supported maximum using the existing wave/high-water representation, with explicit handling at and beyond its limit. | May preserve a simpler save shape if proven safe; requires an approved maximum, arithmetic limits and boundary behavior. |
| **C — Segmented progression counter** | Define a segmented progression representation with bounded within-segment values. | Avoids relying on one indefinitely growing wave integer; requires segment rules, a new save shape and versioned migration. |

No option makes the game mathematically unbounded. **Still required:** selected maximum or segment model, integer/arithmetic safety, displayed wave identity, end/overflow behavior, and interactions with retreat, first-clear milestones and Reboot. No maximum or segment size is proposed here.

## 7. Save compatibility

The current version-2 save writer and validator reject run wave/high-water and permanent highest-wave values above 125. Known version-1 saves migrate to version 2. The approved migration policy requires an explicitly supported source version, copy-based migration, validation, recoverable original and rollback on failure.

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Keep current version-2 contract with the 125 cap** | Do not widen the reader/writer or add migration paths until the endless profile is ready. | Protects existing saves and requires no new mapping; blocks above-125 progression. |
| **B — Widen the existing wave fields** | Keep the same representation but explicitly approve a finite higher ceiling and prove numeric/save safety for the existing schema before accepting it. | Could avoid a field-shape migration if compatibility is demonstrated; must still test old version-1 saves, boundaries and overflow. No compatibility claim is presumed. |
| **C — Add a versioned progression representation** | Define new fields/schema and an explicit supported version-1-to-new-version mapping, migrated on a copy with validation, rollback and preserved recovery. | Supports a different progression representation; requires a complete mapping and migration/regression evidence before release. |

**Still required:** supported versions, field mapping, whether the version number changes, unknown-field preservation, failure/recovery behavior, and focused tests using disposable fixtures rather than a user's save. The packet does not claim a migration is implemented or safe above 125.

## 8. Retreat, Reboot and first-clear semantics

The high-level approved rules include retreat to the highest previously cleared holding wave and manual System Reboot. Their ordinary operation remains part of the approved loop; endless first-clear and milestone handling after the five district endpoints remains unspecified.

| Option | Rule shape | Trade-off / consequence |
|---|---|---|
| **A — Preserve existing retreat/Reboot rules; defer endless milestones** | Keep current retreat and Reboot behavior, and define no endless-specific first-clear award until its reward policy is approved. | Minimizes change; does not establish new permanent goals/rewards past the districts. |
| **B — Extend first-clear tracking to approved endless milestones** | Define which endless milestones are recorded and how they interact with rewards, retreat and Reboot. | Enables durable endless progression goals; requires approved milestone semantics and permanent save tracking. |

**Still required:** high-water/holding-wave semantics above 125; milestone repeatability and persistence; award/reset interactions; and how Reboot affects any endless-specific records. No new Reboot award, reset, or milestone behavior is proposed.

## Owner selection worksheet

Selections may be made by section; **Defer** is valid and keeps the current 125 runtime/save cap.

- Scaling: **A / B / C / Defer**
- Encounter composition: **A / B / C / Defer**
- Post-125 boss cadence: **A / B / C / Defer**
- Rewards/milestones: **A / B / C / Defer**
- Offline claim above wave 125: **A / B / Defer**
- High-wave ceiling/representation: **A / B / C / Defer**
- Save compatibility: **A / B / C / Defer**
- Retreat/Reboot/milestone semantics: **A / B / Defer**

Choosing option families alone does not authorize implementation. Each selected rule still needs the missing content, formula shape, numeric inputs, bounds, and save behavior explicitly supplied and reviewed. Keep the runtime and save boundary at 125 until a complete, validated profile is approved.

## Implementation and validation boundary

This packet changes no game behavior. Do not extrapolate provisional Undercity data, invent a formula/number/encounter pool, or change the 125 cap from this packet. After decisions are approved and canonical sources reconciled, implement a data-driven profile with tests for wave-125/126 boundaries, deterministic generation, scaling/overflow, boss identity behavior, reward accounting, offline claims, retreat/Reboot semantics and save compatibility.

No runtime, data, test, art, or save files changed. No tests were run because this is a documentation-only decision packet. No remote Notion or Drive update, upload, or readback is claimed.
