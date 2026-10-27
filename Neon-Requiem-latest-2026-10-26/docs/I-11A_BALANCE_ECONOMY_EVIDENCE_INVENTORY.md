# I-11a — Balance and economy evidence inventory

**Status: COMPLETE — read-only inventory.** This maps the current local profile inputs, runtime behavior, approved design boundaries, and missing evidence before I-05/I-11 tuning. No runtime values, tests, profiles, saves, or assets were changed. No tests or simulator scenarios were run.

## Executive finding

The project has a configurable prototype economy and a read-only arithmetic simulator, but no captured playtest telemetry or balance report artifacts were found in the project. The numeric inputs are mostly feasibility values. The central approved direction is a hybrid exponential economy, while the current ordinary credit reward fixture is linear and the current combat loop is deterministic direct-damage simulation without the approved power-versus-difficulty layer, abilities, faction synergies, or a seed contract. This is a known prototype/design gap, not evidence that the direction changed.

**Recommendation:** do not tune coefficients yet. First settle the I-05 combat/outcome contract and capture a controlled baseline with the existing profile values; then compare explicitly named candidate profiles against recorded combat and economy outcomes. Keep all candidates separate from source profiles and do not auto-select a winner.

## Canonical and local evidence read

### Live Notion reads — 2026-10-26

The four read-only page fetches succeeded. Their connector metadata reports `verification.state: unverified`; the fetch response did not expose truncation or unknown-block counters, so this inventory does not claim a Notion verification badge or independently confirm omitted content.

| Page | Source URL | Page last edited | Relevant evidence |
|---|---|---|---|
| Game Design & Progression | https://app.notion.com/p/40394c5658c88159962fee5423c311de | 2026-10-26T03:12:05.596Z | Hybrid exponential wave/farm rewards and recruit costs are approved as a concept; all sample values are illustrative. Exact curves, milestones, cost/reward ratio, offline formula, and prestige values need playtesting. Combat power/outcome relation remains open. |
| Decision Log & Change Control | https://app.notion.com/p/40394c5658c88127b755c01197ff628d | 2026-10-26T04:44:43.728Z | Hybrid power-driven combat and hybrid exponential economy are approved directions; no final numeric constants or release balance. Reward/cost curves, milestone magnitude, idle/offline parity, inflation, and prestige currency remain open. |
| Founding Recruit Roster | https://app.notion.com/p/40394c5658c8812d849be3d32629920e | 2026-10-26T03:12:07.445Z | Trial recruitment prices: Common 300, Rare 600, Epic 1,200; starting playtest credits 600; VECTOR, SPARK, and RECOIL begin owned; recruits are unique/no gacha. These are not final balance. |
| Production Roadmap, Tools & Decisions | https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e | 2026-10-26T16:26:20.005Z | Current plan stages playtests as combat → economy → evolution/Reboot → combined end-to-end; calls for fixed and varied seeds and logs outcomes, durations, resolution reasons, unit contributions, economy sources/sinks/purchases, and evolution/Reboot eligibility/resources/progression effects. All numeric values remain trial-only. |

### Local project evidence

- Prototype inputs: `data/progression/progression_prototype_profile.json`, `data/progression/recruitment_prototype_profile.json`, `data/waves/undercity_prototype.json`, `data/enemies/undercity_grunt.json`, `data/characters/breaker_t1.json`, `data/squads/undercity_six_slot.json`, and `data/characters/founding_recruits.json`.
- Runtime: `scripts/combat/combat_director.gd`; `scripts/progression/economy.gd`, `recruitment_service.gd`, `offline_earnings_service.gd`, `progression_rules.gd`, `material_reward_service.gd`, `evolution_service.gd`, and `reboot_service.gd`.
- Analysis tool: `tools/balance_simulator/README.md`, `tools/balance_simulator/balance_simulator.py`, and `docs/LOCAL_BALANCE_SIMULATOR_SCOPE_01.md`.
- Design/test boundaries: `docs/DESIGN_DECISIONS.md`, `docs/OPEN_QUESTIONS.md`, `docs/I-05B_HYBRID_COMBAT_DECISION_BRIEF.md`, and the source-backed playtest plan above.
- File inventory found the simulator and its test module, but no saved simulator CSV/JSON reports, recorded playtest logs, or telemetry dataset. This is a local project-tree finding only.

## Current profile and runtime inputs

All numeric items below are **prototype/feasibility inputs**, unless explicitly identified as an approved non-numeric constraint. Derived examples are arithmetic from those inputs, not playtest results.

| Area | Current configured/runtime behavior | Status and scope |
|---|---|---|
| Ordinary wave credits | `12 + 4 × (wave - 1)`, clamped to nonnegative; 12 at wave 1, 108 at wave 25, and 508 at wave 125. | Linear fixture, not the approved long-term exponential reward curve. The Undercity profile's 1–125 extension reuses placeholder content and is not the district/endless model. |
| Recruitment | Start with 600 credits; Common 300, Rare 600, Epic 1,200; initial owned trio VECTOR/SPARK/RECOIL; one copy of each founding recruit, deterministic credit purchase. | Source-backed playtest setup, not final prices. Recruitment is implemented for the twelve founding recruits. |
| BREAKER leveling | Level-up cost candidate `round(20 × 1.12^(level - 1))`; Tier I begins at 18 attack and 120 HP; each BREAKER level adds 2.4 attack and 9 max HP. The current display/test evidence gives x1 cost 20 and x10 cost 349 from level 1. | Cost curve was approved for playtesting only. BREAKER is the only recruit with an individual run-level purchase path. No level cap is defined. Other recruits' generic 8 attack/70 HP are placeholder squad values, not character balance. |
| Enemy scaling | Prototype Undercity Grunt: 48 base HP + 9 per wave; 8 base attack + 1.6 per wave; 25 move speed; 1.05 s attack interval. Enemy HP also adds 26 per active ally. | Configurable combat placeholders; no approved production wave/enemy curve. Current profile supports waves 1–125; 26–125 reuse the same generic enemy/placeholder presentation. |
| Combat resolution | Fixed-step authoritative simulation applies configured per-hit damage directly to HP; enemy attacks use configured attack power/cadence; defeat/retreat and wave clear drive rewards. | No aggregate power comparison/probability layer, defense model, seeded variation, implemented ability effects, or faction synergy was found in this path. Thus the approved hybrid outcome model is not complete. |
| System Reboot | First eligibility at wave 25; 1 Influence per completed 25-wave band since the preceding Reboot. Reboot resets current credits/run-levels and run high-water under the approved prototype reset semantics. | Trial feasibility formula. It is not a final prestige curve; exact cadence/magnitude should be judged with actual cycle length and rebuilding evidence. |
| Lifetime Influence | `min(0.005 × sqrt(lifetime Influence), 0.25)` as an outgoing-squad-damage bonus only. | Trial profile, not final benefit. Spendable Influence is separate, but the research catalog is empty/read-only, so no actual Influence sink is playable. |
| Evolution Data | 1 shared material per clear plus 1 extra for each first-cleared district endpoint (25, 50, 75, 100, 125); boss first-clear handling is data-driven but no boss implementation exists. Trial tier gates/costs: Combat at 25/1, Military at 75/2, Apex at 125/3. | Prototype material ledger only. Tier transactions record progression; final stat changes, release supply curve, boss flow, and exact evolution balance are absent. |
| Offline credits | 1 ordinary reward per hour at the saved holding wave, capped at 28,800 seconds (8 hours), credit-only, no wave advancement; claim timestamp/reward is saved atomically before live apply. | User-approved playtest rule and current target, not final payout rate. Rate inherits the current ordinary-reward fixture. |
| Wave/content horizon | Prototype runtime/save and simulator horizon currently stop at 125; approved endless progression begins at 126. | Endless enemy/reward scaling and save compatibility above 125 remain undefined and unimplemented; do not extrapolate the Undercity fixture. |

## Tuning boundaries and unresolved items

1. **I-05 combat contract is a prerequisite.** The decision brief still leaves open how power advantage affects outcomes, deterministic versus seeded variation, the direct-damage prototype versus hybrid resolution, defense/cadence/ability/synergy participation, and measurable stalemate handling. No numeric tuning can establish the approved hybrid model while these rules are unsettled.
2. **Economy direction versus current fixture:** exponential ordinary rewards/farming and upgrade costs are approved as a design direction. The current ordinary credit reward data is linear; no production reward growth rate, milestone bonuses, or reward/cost ratio is approved. The BREAKER cost curve is only a bounded playtest candidate, not a roster-wide system.
3. **Research and later content:** no research purchase sink is enabled. Endless wave 126+, named bosses, production faction/enemy composition, and all-twelve leveling are not present as balance evidence.
4. **No observed playtest dataset:** local documentation describes test requirements, but no persistent run logs or simulator result artifacts were found. The simulator's default “clear each wave once” model is bookkeeping; it does not forecast whether a wave can be cleared, encounter duration, loss/retreat rates, or player behavior.

## Evidence required before I-05/I-11 tuning

Follow the roadmap's staged order. For each run, retain the exact prototype profile/version hashes, wave, active lineup, recruit levels, HP state, scenario settings, and seed when a seed is supported. Do not describe fixed-seed replay as available until a seed contract and implementation exist.

- **Combat stage:** for each encounter, record clear/defeat/stalemate and resolution reason; encounter duration; starting and ending HP; attacks/damage by source and target; unit contribution; wave and enemy profile; and retreat/holding-wave result. Compare fixed and varied seeds only after the I-05 seed policy exists. Keep the visible event sequence coherent with authoritative simulation.
- **Economy stage:** record credits at start/end, each wave reward, recruitment and upgrade purchase/level, all other income/sinks, credits remaining, and time-to-afford important purchases. Compare credit income against the costs of plausible purchase choices without changing the trial values mid-run.
- **Evolution/Reboot stage:** record first-clear eligibility, repeatable and milestone material inflows, material spend/remaining, Reboot wave/high-water, Influence awarded and balances, reset effects, and post-Reboot return to progression. Research remains read-only until node rules are approved.
- **Combined stage:** verify the same run's combat result, reward transactions, upgrades/recruitment, material/Influence flows, save/load, offline claim, Reboot and subsequent progression; distinguish verified persistence from in-memory state.
- **Interpretation:** use repeated, named baseline/candidate runs and report distributions/rates rather than a single “winner” or simulator forecast. Separate observed player feedback from instrumentation. Boss-placement comparisons require actual boss encounters and clear rate, duration, and subsequent progression evidence; none exists in the current local runtime.

## Next task recommendation

After I-11a, the next useful implementation task is a **bounded playtest telemetry capture/export for the existing prototype**, with profile hashes and per-encounter outcomes/durations/unit contributions plus economy source/sink events. Keep it read-only with respect to progression decisions: no balance profile edits, no seed behavior until I-05 approves it, and no automatic choice of candidate values. Then collect the combat baseline and present unresolved I-05 choices before tuning I-11. This is a recommendation for task sequencing, not a newly approved game mechanic or numeric decision.

## No-change record

Local profiles and runtime were inspected only. Notion was read only; the four pages above still report `verification.state: unverified`. Google Drive was not accessed in this task. No tests, simulator runs, game launches, profile edits, commits, uploads, or remote page changes occurred.
