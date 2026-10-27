# I-11b — Bounded prototype telemetry design

**Status:** Read-only technical design complete; implementation not started. **Date:** 2026-10-26 America/Chicago.

## Purpose and boundary

Design the smallest local telemetry slice that can measure outcomes and timing for the current prototype and account for committed credit sources/sinks. This does not alter simulation, economy values, saves, profiles, randomness, or game behavior. It does not select balance candidates, and a telemetry summary must not be described as a combat forecast or a 1.0 balance verdict.

## Existing seams

- `scripts/combat/combat_director.gd` owns the fixed 0.05-second step and monotonic `sim_time`.
- `combat_action_resolved` publishes an ordered dictionary with sequence, event type, wave, simulation time, source ID/side, target ID, style, damage, target HP after impact, and defeat flag. Subscribers must remain observational.
- `wave_cleared` emits after reward, high-water, next-wave/cap and intermission are committed. The main listener adds first-clear materials and autosaves; telemetry must distinguish an in-memory clear from a disk-persisted clear if autosave fails.
- Encounter start and squad defeat currently have only state/log changes, not structured lifecycle events. Minimal future instrumentation may add lifecycle events at those seams without changing combat ordering or outcomes.
- `snapshot()` exposes live gameplay state and should not be serialized wholesale. Build allow-listed telemetry records instead.
- `PrototypeEconomy` mutates credit balance for ordinary encounter rewards and recruit level purchases. Other credit transaction seams are in `main.gd`: recruitment purchase, BREAKER upgrade, offline claim, and System Reboot reset. Purchase/upgrade/offline/Reboot paths are save-first; record only after successful persistence and live-state application. Wave clear remains playable in memory when autosave fails, so record persistence status rather than pretending it saved.

## Recommended opt-in local export

Use an explicitly started, local-only capture session and a caller-selected output folder protected by the same resolved-root/overwrite rules as the balance simulator. No automatic upload, telemetry endpoint, background recording, or writing under the project tree by default.

Suggested files:

- `manifest.json`: schema/build version, session ID, UTC start/end, scenario label, profile/schema versions and SHA-256 hashes for relevant data definitions, plus initial wave/lineup/levels. Hash raw profile bytes as the balance simulator does, but omit absolute paths.
- `events.jsonl`: append-only, event-sequence-ordered records.
- `summary.json`: deterministic aggregation derived only from the event log; reproducible and disposable.

Do not include raw save contents, save paths, player/account identity, machine/user names, or unrelated settings. Restrict fields to stable recruit/enemy IDs and minimum measurements.

## Minimum event contract

Common fields: `schema_version`, `session_id`, monotonically increasing `event_seq`, `event_type`, `sim_time_s`, `wave`, and `phase`.

1. `encounter_started`: encounter ID, wave, simulation-time start, enemy definition ID/starting HP, active recruit IDs and run-levels, current credit balance, and relevant profile hashes from the manifest.
2. `attack_resolved`: copy the current resolved combat event's allow-listed fields. Aggregate outgoing damage, hits, and target defeats by ally/encounter; aggregate incoming damage separately. Do not infer damage absent from the authoritative event.
3. `encounter_resolved`: outcome enum limited to states the current build supports (`clear`, `squad_defeat`, `prototype_cap`), elapsed simulation seconds, credits before/reward/after, holding/high-water wave, and active roster HP summary. Do not add timeout/stalemate without an approved combat contract.
4. `credit_transaction`: enumerated source/sink (`wave_reward`, `offline_claim`, `recruit_purchase`, `level_upgrade`, `reboot_reset`), positive `amount`, `balance_before`, `balance_after`, transaction/commit status, and minimal source-specific context (recruit ID, levels bought, holding wave/capped offline seconds, or reboot milestone). Keep Influence and Evolution Data in distinct typed resource records if later included; never combine them with credits.

Sequence reflects actual commit/event order. The simulation's attack sequence is not automatically the session export sequence because transaction and lifecycle events also need ordering.

## I-05 dependency and interpretation limit

This design can measure the current direct-damage prototype. It cannot establish the approved hybrid power-driven relationship or validate seeds, defense/cadence interaction, abilities, faction synergies, boss comparisons, varied-seed fairness, or stalemate policy. Do not introduce seed behavior as telemetry scope. Before using captures for balance decisions, the owner must settle the open I-05 outcome/power model, seed/reproducibility policy, damage/defense/cadence interaction, and defeat/stalemate contract. Until then label output as descriptive telemetry of current prototype behavior only.

## Future implementation acceptance checks

- Exactly one start and one terminal outcome per completed encounter; no duplicate clear/defeat rows.
- Event ordering is monotonic and agrees with committed combat/economy transitions.
- Per-ally contribution aggregation equals underlying attack-event sums; outgoing and incoming damage remain separate.
- Every credit row reconciles `before`, transaction amount, and `after`; no failed purchase, failed save-first transaction, or deferred recovery offline claim is falsely recorded as committed.
- Telemetry disabled has no effect on combat, credits, saves, or RNG; export does not change profiles/saves.
- Output containment, collision/overwrite behavior, and schema are validated in isolated tests before playtest use.

## Evidence consulted

Read-only inspection of `scripts/combat/combat_director.gd`, `scripts/progression/economy.gd`, `scripts/main.gd`, `scripts/progression/reboot_service.gd`, and `tools/balance_simulator/balance_simulator.py`. No profiles, saves, art, or runtime behavior changed; no game, test suite, simulator, or editor was run for this design.