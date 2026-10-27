# Local Balance Simulator — Scope 01

**Status: IMPLEMENTED LOCALLY; validation pending.** This is a local analysis-tool brief, not approval of balance changes. The simulator must never overwrite game profiles, save files, or canonical design sources.

## Goal

Create a small, dependency-free Python command-line tool that reads the current local prototype profiles and reports progression/economy outcomes in reproducible CSV plus a concise Markdown summary. It should help compare explicitly named scenarios after playtests, while separating configured trial values from open balance questions.

## Project fit

- Runtime stays Godot/GDScript; this tool is analysis-only and does not enter the game build.
- Reuse the local Python environment and standard library initially. Avoid paid services, cloud analytics, new packages, and a separate test framework.
- Read the source JSON profiles as input. Require scenario assumptions to be passed through a separate scenario file or CLI arguments. Never edit source profiles or user saves.
- Every report records tool version, date, input file paths/hashes, scenario settings, and which values are prototype trial data.

## Initial inputs

- `data/progression/progression_prototype_profile.json` — Reboot, lifetime Influence benefit, repeatable/first-clear Evolution Data, offline cap/rate, and per-recruit evolution gates.
- `data/waves/undercity_prototype.json` — current ordinary credit reward curve and prototype horizon. Its 1–125 entries reuse provisional Undercity content; do not treat this profile as a canonical district or endless model.
- `data/characters/breaker_t1.json` — BREAKER's run-level cost base/growth only. Do not apply its curve to the other eleven recruits.
- `data/progression/recruitment_prototype_profile.json` may be included for recruitment purchase-price accounting; all prices are trial values.
- `data/world/district_scope.json` may supply named district endpoints, but the tool must not infer named-boss placement, boss rewards, or content after wave 125.

## Version-one reports

1. **Wave progression table:** wave number, ordinary credits, repeatable Evolution Data, first-clear milestone bonus, cumulative materials, and whether a configured permanent evolution milestone is met. Baseline scenario assumes each wave through the selected horizon is successfully cleared once. It is a bookkeeping scenario, not a combat-clear prediction.
2. **Reboot table:** user-supplied run endpoints, trial Influence awarded per run, lifetime/spendable Influence totals, lifetime damage-bonus fraction, and run resets. Do not invent reboot timing or auto-reboot behavior.
3. **Offline-claim table:** user-supplied holding wave and elapsed time; apply the configured cap/rate and the existing ordinary credit reward calculator. Show uncapped and capped elapsed time, reward, and formula inputs. Never advance waves or simulate offline combat.
4. **Evolution supply table:** per-tier and whole-roster costs, current trial material availability, shortfall/surplus, and first wave where each gate is met. Boss rewards are excluded unless an explicitly identified boss-rule scenario is later approved.
5. **BREAKER upgrade table:** exact per-level rounded costs and cumulative credit requirements for a user-selected level range, plus selectable credit-budget purchases. Label base 20 / growth 1.12 as a playtest candidate; do not infer a level cap or apply it roster-wide.
6. **Sensitivity comparison:** allow named, user-supplied candidate values to be compared side by side without saving them back to the source profiles. The tool reports differences; it does not declare a preferred balance or auto-select a curve.

## Known calculations for the configured trial profile

- Ordinary wave credits currently use `max(0, base_credit_reward + (wave - 1) × credit_reward_per_wave)`; the supplied Undercity fixture is 12 + 4 × (wave − 1). The simulator reads these values instead of hardcoding them.
- Reboot Influence follows the configured first eligibility wave and step size. The current prototype trial awards 1 at wave 25, then one per additional 25-wave step. It resets run wave/high-water and run credits/levels in its modeled state while preserving permanent progression.
- Lifetime Influence benefit is reported using the configured square-root formula and 25% cap; it affects outgoing squad damage only. The simulator must not translate that into wave speed or win probability.
- Evolution Data is modeled as repeatable per-clear material plus configured one-time district endpoint bonuses. With the present trial settings, a single clear of all 125 prototype waves contributes 125 repeatable units plus five district bonuses, excluding all bosses. A full 12-recruit path through all three current trial gates costs 72 shared units. These are derived feasibility totals, not approved release balance.
- Offline claims use the saved holding-wave ordinary reward, configured rate, elapsed time, and cap, with the same floor behavior as the current service. They do not produce wave clears or materials.
- BREAKER upgrade costs are rounded individually at each next level before summing a batch, matching the current service sequence.

## Scenario controls

- Wave horizon, starting credits, and whether each selected wave is assumed cleared once.
- Optional sequence of manual Reboot run endpoints; no schedule is presumed.
- Optional offline holding wave and elapsed duration.
- Recruit count to model for shared evolution-cost accounting (default scenario can show 1 and 12 side by side; the default is an analysis choice, not a gameplay rule).
- BREAKER level range and credit budget/purchase policy.
- Alternative profile-value overlays supplied in scenario input only, with scenario labels and provenance.

## Non-goals and guardrails

- No combat simulation, time-to-clear prediction, win-rate claim, enemy-power extrapolation, boss cadence, endless waves after 125, research-node catalog, cyberware values, or player-retention analytics.
- No player telemetry collection, cloud/database connection, spreadsheet framework requirement, editing of source data, save-file access, or gameplay/runtime integration.
- No “balanced/unbalanced” verdict without defined design targets and actual playtest evidence. Reported totals are arithmetic consequences of supplied settings.
- Keep current approved trial values and unresolved design questions clearly marked. Never turn a sensitivity profile into canon or a release recommendation automatically.

## Proposed implementation boundary

- Entry point: `tools/balance_simulator/` with a Python CLI and a small JSON scenario format.
- Outputs: CSV tables and a Markdown summary at a caller-selected output directory. Its resolved path must remain under a caller-selected safe output root, including when symlinks or Windows junctions are involved, and remain outside protected runtime/source/test/save locations. Output overwrite behavior must be explicit; do not silently replace prior reports.
- Initial checks: input-schema validation, exact formula comparisons against current GDScript service behavior, edge cases for wave 1/25/50/75/125, offline cap boundaries, Evolution Data one-time claims, and purchase rounding. These are implementation-phase requirements; no tests were run while preparing this scope.

## Remaining implementation choices

- The CLI requires the caller to select both `--safe-output-root` and `--output-dir`; no user-specific report location is assumed.
- The first version remains dependency-free and CSV/Markdown/JSON only. Any later visualization package is a separate decision.

## Evidence consulted

Read-only local inspection on 2026-10-26 of `docs/ARCHITECTURE.md`, `docs/IMPLEMENTATION_STATUS.md`, `docs/OPEN_QUESTIONS.md`, `data/progression/progression_prototype_profile.json`, `data/progression/recruitment_prototype_profile.json`, `data/waves/undercity_prototype.json`, `data/characters/breaker_t1.json`, `data/world/district_scope.json`, and the progression/Reboot/evolution/material/offline GDScript services. No game values or implementations changed.
