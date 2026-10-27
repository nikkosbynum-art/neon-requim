# Progression Rules — 1.0 Proposal

**Status: The user approved these values and scopes for prototype feasibility testing on 2026-10-24; they are not final balance/canon.** The capped lifetime bonus is applied to authoritative outgoing ally damage only; HP, defense, enemy damage, and movement are unchanged.

## Network Influence on Reboot

### Prototype trial formula

At a manual Reboot, award one Influence for each completed 25-wave band, beginning with wave 25:

```text
influence_award = floor(highest_wave_since_last_reboot / 25)
```

Example awards: wave 24 → 0 (Reboot unavailable); wave 25 → 1; wave 49 → 1; wave 50 → 2; wave 125 → 5. Past wave 125, each additional 25 cleared waves adds one more Influence.

Add the award to both lifetime Influence and spendable Influence. For the prototype, lifetime Influence grants a global outgoing squad damage bonus:

```text
bonus_fraction = min(0.005 * sqrt(lifetime_influence), 0.25)
```

Examples: 1 Influence → 0.5%; 25 → 2.5%; 100 → 5%; 2,500 or more → 25% cap. The curve is deterministic and diminishing. It multiplies authoritative ally attack damage; it does not change squad HP/defense, enemy damage, or movement.

**Approved reset boundary (2026-10-24):** a successful Reboot starts the run at wave 1 and resets its run highest-cleared-wave counter to 0. Calculate the award from the pre-reset peak reached since the prior Reboot. `permanent.highest_wave_ever` records the best first-clear milestone and is not reset by Reboot.

## Evolution gate values

All twelve recruits can evolve in 1.0. Every tier requires both a cleared-wave milestone and earned materials. **Historical 2024 art scope, superseded by the local owner decision recorded 2026-10-26:** BREAKER gets the first complete four-tier art set; the other eleven keep Tier I visuals until their higher-tier art arrives after 1.0. Current 1.0 scope requires a distinct visible art change for all twelve recruits at every evolution step; tier-specific designs and production evidence remain to be authored and approved.

| Unlock | Approved prototype milestone | Approved prototype cost per recruit |
|---|---:|---:|
| Adapted Form | First clear of wave 25 | 1 Evolution Data |
| Signature Form | First clear of wave 75 | 2 Evolution Data |
| Requiem Form | First clear of wave 125 | 3 Evolution Data |

“Evolution Data” is a temporary generic material name, not approved canon. The user approved these milestone and per-recruit cost values for prototype feasibility testing only; they are not final balance. Deterministic first-clear and repeatable-encounter earnings use a shared roster inventory, with enough total supply targeted for all twelve recruits to reach each eligible tier. No gacha or paid item source is proposed. Prototype payout trial values are 1 per successful clear plus 1 extra for each first-cleared district endpoint or named boss; these are not final balance.

**Approved for prototype feasibility testing:** use a shared roster inventory. Earn materials deterministically from first clears and repeatable encounters, with long-term total supply sufficient for all twelve recruits to reach each tier. This avoids random or paid acquisition and avoids permanently missable materials. Prototype payout values are implemented at 1 material per successful wave clear plus 1 for each first-cleared district milestone or named boss.

## Prototype implementation boundary

`scripts/progression/progression_rules.gd` implements data-driven calculation and validation primitives. `scripts/progression/reboot_service.gd` applies the approved reset boundary as a pure state transaction using an injected award profile and caller-supplied full squad HP. These helpers do not add UI or alter the main scene. Their automated checks use fixtures matching the proposed wave-step example; those fixtures prove transaction and code behavior only, not approval of balance values or runtime integration.

The next tuning gates are:

1. Test the Reboot award and capped square-root passive bonus across multiple cycles; review progression pace and combat power impact.
2. Evaluate whether the approved prototype evolution milestones/costs and material reward trial support the roster-wide supply target without making evolution feel automatic or excessively slow.

## Feasibility review and runtime prerequisites

The separate test lane reviewed the progression structure and found no architectural rewrite is needed. Existing boundaries fit the design: pure progression rules, a save-backed Reboot transaction, permanent/run save sections, and CombatDirector-owned authoritative ally stats. The outgoing-damage bonus, permanent first-clear evolution milestones, live manual Reboot caller, configurable wave-clear material payouts, and evolution gate/record transaction now run in the prototype. The transaction supports all twelve approved recruit IDs; the player-facing purchase control is currently BREAKER-only because no other recruit implementation is in the scene. The combat/save horizon reaches wave 125 to exercise higher award bands, but waves 26–125 reuse the Undercity grunt and placeholder battlefield; no authored post-Undercity district content exists. Higher wave-band, material reward, and evolution gate values are runtime-accessible for feasibility tests but remain provisional. The explicit-path save helper assumes one game process; concurrent instances are not coordinated.

The prototype profile supplies Reboot, damage bonus, material reward, and evolution gate values for feasibility testing only; none is final balance. The generic tier-record/material transaction and BREAKER HUD/save path are integrated, but no evolution stat, trait, or visual effect is implemented.
