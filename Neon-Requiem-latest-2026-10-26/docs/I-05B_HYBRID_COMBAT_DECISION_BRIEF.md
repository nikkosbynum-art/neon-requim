# I-05b — Hybrid combat and outcome decisions

**Status:** Policy semantics selected; first configurable runtime trial drafted, Test Lane validation pending — 2026-10-26 America/Chicago.
**Scope choice:** The owner selected the likelihood-based hybrid outcome model and associated trial semantics recorded below. I-04 scope B remains selected: all twelve ability contracts must be defined before any ability is implemented. No numeric coefficient or release balance value is approved here.

## Evidence and source limits

- Live **Game Design & Progression**: https://app.notion.com/p/40394c5658c88159962fee5423c311de, read-only fetch 2026-10-26T03:12:05.596Z (`verification.state=unverified`). It approves a hybrid power-driven simulation: combined deployed-squad power versus enemy difficulty establishes expected advantage; individual health/damage/defense, automatic abilities, and faction synergies shape the encounter; visible attacks and outcomes must remain coherent. At fetch time it left outcome mapping and formulas open; later manager selections are recorded below and are not represented as live-source readback.
- Live **Decision Log & Change Control**: https://app.notion.com/p/40394c5658c88127b755c01197ff628d, read-only fetch 2026-10-26T04:44:43.728Z (`verification.state=unverified`). At fetch time it left outcome relationship, effective-power formula, damage/health/cooldown equations, seed behavior, and stalled-encounter treatment open. This is historical source evidence; later local manager selections below supersede those open fields for project planning, not as a fresh canonical read.
- Approved defeat flow: after defeat, retreat automatically to the highest-cleared holding wave; restore the squad on holding-wave re-entry. The one-time stalemate cinematic is associated with arrival. Timer-expiry defeat was selected later by owner-delegated manager recommendation, documented below; runtime transition/integration remains unimplemented.
- Test Lane's read-only **T-02a** audit (Test Lane chat, 2026-10-26): current tests cover reproducibility for identical inputs in the deterministic direct-damage prototype, six-slot placeholder combat, melee/ranged movement and target fallback, defeat/retreat/re-entry, and committed attack/wave-clear event ordering. They do not cover fixed-versus-varied seeds, probability/outcome rules, stalemate, or encounter-metric recording. The audit also identifies I-04 ability behavior as unimplemented; event transport/presentation coverage is not ability gameplay coverage.
- Local implementation evidence: `scripts/combat/combat_director.gd` applies per-hit attack values and wave-scaled enemy HP/attack in the current prototype; the combat path has no encounter seed or outcome-probability calculation. Numeric profile inputs are marked placeholders in `data/characters/breaker_t1.json`, `data/squads/undercity_six_slot.json`, `data/enemies/undercity_grunt.json`, and `data/waves/undercity_prototype.json`.
- The named I-05a file `docs/I-05a_HYBRID_COMBAT_OPTIONS_2026-10-26.md` is not present in the checked-out project. Its completion summary in `docs/REMAINING_G_TASKS_BY_LANE.md` and `docs/REMOTE_SYNC_QUEUE.md` says it separated approved hybrid direction from trial numbers, identified open power/outcome/damage/defense/cooldown/stalemate/seed rules, and recommended testing the current deterministic direct-damage prototype before inventing formulas. This brief uses that recorded summary plus the live source and T-02a evidence; it does not claim to have imported a missing file.

## Recorded selections

- Squad power influences outcome likelihood without guaranteeing a win; the simulation remains authoritative and does not preselect a winner.
- The first trial power score uses current HP, maximum HP, attack power, and attack interval. Movement, style, range, and formation are telemetry. Recalculate the score at each committed attack.
- Use a bounded-monotonic likelihood mapping, applying the same relative-power rule to allied and enemy attacks. Impact varies at each committed attack.
- Use an encounter-local seeded Godot `RandomNumberGenerator` for reproducible playtests; consume draws in deterministic simulation action order. This does not establish an exact cross-engine-version RNG sequence contract.
- Resolve fixed-step actions before timer checks. Reset the no-progress timer on HP/defeat changes and qualifying ability/status effects. If both timers expire on the same step, report maximum timeout as primary and no-progress as also expired.
- **Timer-expiry result:** under the owner's standing authorization to select supported Recommended options, expiry of either timer resolves as defeat. Apply the approved automatic retreat to the highest-cleared holding wave; restore the squad on holding-wave re-entry; show the one-time stalemate cinematic on arrival; and after one holding-wave clear automatically retry the next uncleared wave. This is an owner-delegated manager selection, not a claim that the earlier direct timer replies selected the terminal result.

## Historical selectable alternatives — superseded by the selections above

The initial review presented these options before the manager-thread choices and owner-delegated selection were reconciled. They remain here as decision history, not as current open alternatives:

1. **Power/outcome:** guarantee outcomes at a threshold; influence likelihood without guaranteeing; or defer to the direct-damage prototype. Likelihood influence was selected.
2. **Randomness:** deterministic from state; seeded variation; or defer. Seeded playtests were selected, with an encounter-local test-harness seed and deterministic draw order.
3. **Combat model:** retain direct-damage prototype; define hybrid interactions before tuning; or defer model changes. Hybrid policy choices are now recorded; individual equations and ability/synergy interactions remain open.
4. **Stalemate:** define timer-based operation and its defeat flow now; or defer detection. Timer rules and defeat on either timer expiry are now recorded; numeric thresholds, qualifying-effect details, and runtime integration remain open.

## Remaining mechanics and tuning

### First configurable runtime experiment — implementation drafted; validation pending

`CombatDirector` now keeps `direct_damage` as the default control and enables `hybrid_trial` only with `--neon-hybrid-trial` (optionally set a positive seed using `--neon-combat-seed=<integer>`). The JSON profile `data/combat/hybrid_combat_trial.json` labels every numeric input provisional. The implemented experiment is deliberately narrow: sum per-actor scores from living squad members and the current enemy; each actor score combines current HP fraction × normalized maximum HP, normalized maximum HP, normalized attack power, and normalized attack cadence using profile weights. At each committed attack, divide the acting side's score by both sides' total score, linearly map that relative-power share between the configured low/high impact probabilities, draw from an encounter-local seeded Godot RNG, and apply the configured low/high damage multiplier. Both sides use the same mapping; a stronger side improves expected impact but can still roll low, and a weaker side can still roll high. This is an experiment, not a final damage/defense equation or balance claim.

The trial also applies configurable maximum-encounter and no-progress timers after fixed-step actions. No-progress resets when any individual HP value changes or a qualifying-effect hook is called. Timer expiry resolves as defeat; when both expire on one step, maximum timeout is primary and no-progress is recorded as also expired. Existing retreat, holding-wave recovery, and auto-retry flow are reused. The presentation emits a one-time, process-local stalemate arrival cue; it is a placeholder hook, not a completed cinematic, and its across-save persistence semantics remain undecided. Existing abilities are not implemented and no ability calls the qualifying-effect hook yet.

The first Test Lane attempt failed before hybrid activation: Godot's parsed JSON seed/stride values did not satisfy a strict `TYPE_INT` check, so the profile fell back to direct damage and most focused assertions cascaded. Implementation changed validation to accept either integer or float representations only when finite, positive, and integral; the fix is awaiting Test Lane retest. The Godot import/parse command exited 0 but logged AppData profile/save write warnings, which Test Lane treated as environment messages rather than a code failure. Direct damage remains the default; the hybrid trial must not be described as validated or tuned until focused tests cover seed replay, both-side probability mapping, timer ordering/ties, retreat/recovery/retry, and unchanged direct-mode outcomes.

### Remaining limits and approval boundaries

- Tune and playtest the trial per-actor aggregation weights/references, bounded mapping limits, impact multipliers, and timer thresholds. The current configured values are feasibility inputs only.
- Specify which future ability/status effects qualify as progress after all twelve I-04 contracts are approved; no ability is implemented by this slice.
- Exact replay across Godot engine versions is not established; the seed promises repeatability only within the supported test environment and identical simulation action order.
- Define and test individual defense/cooldown interactions, ability effects, and faction synergies. I-04 requires all twelve ability contracts before any ability implementation.
- The code reuses current retreat/re-entry and auto-retry behavior and emits a presentation cue, but the final one-time arrival cinematic and persistence semantics are not implemented.

## Numeric values that remain trial-only

Keep all current numeric combat profile values as configurable prototype/trial inputs, not canon: BREAKER Tier I stats and level increments; generic six-slot ally stats, movement/engagement values, and enemy-per-active-ally health adjustment; Undercity enemy health/attack scaling and attack cadence; wave reward values; and any combat-facing progression modifier explicitly marked for feasibility testing. The current documents do not approve a final effective-power formula, damage/defense/cooldown equations, wave scaling, or release balance. No numeric values are proposed or promoted in this brief.

## Decision boundary

Do not claim the hybrid model is complete or tuned. This bounded hybrid trial uses configurable provisional formula/value choices and needs Test Lane evidence before playtest interpretation. Current direct-damage behavior remains the default control. Neither model produces final balance evidence for unimplemented defenses, abilities, faction synergies, or cyberware. Exact replay across Godot engine versions is not guaranteed. No formula, coefficient, damage value, timer duration, or release balance is canon by this implementation.
