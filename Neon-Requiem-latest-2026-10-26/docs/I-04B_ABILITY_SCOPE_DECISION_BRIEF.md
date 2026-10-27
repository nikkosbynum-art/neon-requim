# I-04b — Automatic ability scope decision brief

**Status:** Ready for manager presentation; no option selected. This is decision support, not an ability specification or approval to implement mechanics.
**Evidence:** `docs/AUTOMATIC_ABILITIES_AND_FORMATION_SOURCE_AUDIT_2026-10-26.md` and Test Lane's read-only T-02a combat coverage audit in the `Neon Requiem Test Lane` chat, 2026-10-26. No code or tests were changed for this brief.

## What the current build and tests establish

The current combat regression coverage exercises automatic deterministic encounter progression and rewards; six-slot placeholder combat; movement speeds, melee contact and ranged stand-off; nearest-living-ally enemy targeting; defeat, retreat and HP recovery; and attack/wave-clear event sequencing with committed state visible to listeners. The current simulation is a direct-damage prototype, not an approved hybrid outcome model.

Ability tests cover event transport and presentation routing only. No ability currently triggers or applies a gameplay cooldown, resource cost, or effect. The existing target fallback tests cover nearest-living-ally targeting and squad defeat when no ally remains; there is no skill-specific fallback, multi-enemy tie-break, or ability target-selection test. Test Lane also found the seed/outcome model and boss lifecycle are separate upstream gaps; those are not solved by selecting an ability scope.

## Scope choices

### A — Specify BREAKER first, then implement and test one ability

**What it unlocks:** A bounded vertical-slice experiment for the full automatic-ability path—eligibility, authoritative effect, simulation event, and regression coverage—before committing the other eleven skills to detailed contracts. The roster summary alone is not enough to infer BREAKER's mechanics.

**What must happen first:** Approve a complete BREAKER ability contract. Its trigger/eligibility, cooldown semantics, resource cost if any, effect/target/magnitude/duration/stacking/termination, target priority/tie-break/fallback, retargeting/interruption, ordering with simultaneous combat events, defeat/wave-transition behavior, and interactions with character passives must be defined. Test Lane then needs focused behavior, ordering, and fallback coverage. A scope choice does not itself approve those mechanics.

### B — Specify all twelve abilities before implementing any

**What it unlocks:** A cross-roster contract set that can expose interactions and shared rules before any skill behavior is coded.

**What must happen first:** Approve complete operational contracts for all twelve signature-skill summaries, including shared definitions for target metrics, cooldown/resource semantics, event ordering, interruptions, and no-target/invalid-target handling. These details are absent from the roster summaries. This is the largest up-front design and review commitment; implementation remains blocked until the contracts are approved.

### C — Keep automatic policy/event transport and defer skill behavior

**What it unlocks:** Continued work on other simulation and progression systems without inventing signature-skill behavior. The existing event-only transport hook can remain available for future effects.

**What it defers:** No character ability executes, consumes a gameplay resource, uses a gameplay cooldown, or changes combat outcomes. Existing transport coverage is not ability gameplay coverage.

## Decision boundary and open details

Choose A, B, or C to set scope. Any mechanics added under A or B still require their own explicit approval; no values, target metrics, or effects are supplied by this brief. If C is chosen, record the deferral and keep the event hook labeled as transport-only. In every case, preserve automatic activation/target selection and do not add manual skill triggers or target overrides.

**Source boundaries:** The live design confirms automatic activation according to character AI and skill requirements, but no ability has a complete executable contract. Roster labels—including “priority,” “strongest,” and “frontline”—do not define measurable rules or fallback behavior. See the source audit for live Notion URLs and retrieval metadata; it reports `verification.state=unverified`.
