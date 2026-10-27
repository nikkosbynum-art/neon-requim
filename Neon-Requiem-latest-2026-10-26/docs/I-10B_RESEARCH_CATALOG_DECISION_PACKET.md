# I-10b — Research catalog decision packet

**Status:** Decision support only; node definitions remain deferred and the catalog stays empty/read-only  
**Date:** 2026-10-26 America/Chicago  
**Scope:** Identify the unanswered research-catalog fields and present neutral structures for later owner decisions.  
**Excluded:** Invented node names/effects/values, runtime/data/test changes, or authorization to populate the catalog.

## Approved source-backed rules

- The four permanent research branches are **Combat Protocols**, **Underground Economy**, **Network Infrastructure**, and **Personnel Development**.
- Purchases use **spendable Network Influence**. Lifetime Influence is a separate permanent balance with its own passive benefit; a research purchase must not deduct lifetime Influence.
- Purchased research and both Influence balances persist through System Reboot. Reboot does not reset research.
- Combat remains fully automatic. Research is not approval for manual ability triggers, manual targeting, tactical target overrides, or per-target commands.
- The 1.0 decision defers node definitions until combat/economy testing informs the catalog. The approved branch names and persistence rules do not define node contents.

Sources recorded by the local read-only reconciliation: [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de), [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d), [Production Roadmap](https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e), [Project HQ](https://app.notion.com/p/40394c5658c88174b135cd3432d667c1), and [Codex Reconstruction Handoff](https://app.notion.com/p/40394c5658c881b990ece736c16dc0ee). Fetch timestamps and `verification.state: unverified` metadata are recorded in `docs/MIGRATION_REPORT.md`. No new remote read was performed for this packet. The offline Notion reconstruction is explicitly non-verbatim.

## Current implementation boundary

`data/progression/research_catalog.json` contains the four approved branches with empty `nodes` arrays. The Research UI is read-only. The service provides fail-closed catalog validation and a save-safe purchase framework, but there are no approved purchaseable nodes or gameplay effects. Its schema requirements and synthetic validation fixtures are implementation contracts, not design approval. Keep the branch arrays empty and the UI read-only until complete node records are supplied and explicitly approved.

## Decisions still needed

These are generic structural choices only. They do not name or define any node. The existing owner decision to defer node definitions until combat/economy playtests remains current; every section may be left **Defer**.

### 1. Node identities and organization

For each approved branch, provide the node ID and display name, plus its placement/order. No node IDs, names, count, or sequence are proposed here.

| Organization option | Definition needed | Consequence |
|---|---|---|
| **A — Independent entries** | Owner supplies individually available node identities and any explicit prerequisites. | More direct catalog organization; no dependency order is implied. |
| **B — Ordered progression** | Owner supplies an explicit sequence and the dependency rule between entries. | Makes progression order visible; requires complete prerequisite links. |
| **C — Branching progression** | Owner supplies each branch point, path, identity, and prerequisite link. | Allows alternate research routes; needs a complete graph and cycle validation. |
| **Defer** | Leave all branch node arrays empty until after combat/economy playtests. | Preserves the current approved 1.0 plan and read-only UI. |

These are organizational options, not source-approved catalog structures. A selected shape still needs owner-provided identities.

### 2. Rank model and cap

| Rank option | Definition needed | Consequence |
|---|---|---|
| **A — One-time entry** | Each node can be purchased once; represent its single state explicitly. | Simpler completion state; no repeated investment in the same node. |
| **B — Capped ranks** | Each node has a specified maximum rank and per-rank behavior. | Supports incremental investment; requires a cap and each rank's full rule. |
| **C — Per-node model** | Owner marks each node one-time or rankable and supplies its cap. | Flexible catalog; requires complete metadata for every node. |
| **Defer** | Leave rank/cap unspecified and do not populate nodes. | No gameplay effect or cost can be purchased. |

No maximum rank or rank progression rule is approved. Do not infer a cap from the service validator's required positive integer field.

### 3. Effect contracts

No effect category, target, trigger, magnitude, duration, stacking, or termination rule is source-approved. Do not fill this section with example node effects. For every future node/rank, the owner must provide:

- Exact effect definition, affected game state and target scope.
- Whether the effect is continuous or event-triggered; if triggered, its predicate and timing.
- Value and units where applicable, duration, stacking/refresh behavior, termination and boundary behavior.
- Any interaction with an existing passive, recruit ability, combat calculation, encounter transition, or save field.

Until each applicable field is supplied and approved, the node is not purchaseable and has no runtime effect.

### 4. Influence costs

The currency is approved: spendable Network Influence only. The cost structure and all cost values remain open.

| Cost option | Definition needed | Consequence |
|---|---|---|
| **A — Per-node cost** | Owner supplies a cost for each purchaseable node. | Clear node-level pricing; rankable nodes need an explicit repeated-purchase rule. |
| **B — Per-rank schedule** | Owner supplies a cost for each rank or a fully specified cost rule. | Supports rank-specific pricing; requires every rank and boundary to be costed. |
| **C — Shared cost rule** | Owner supplies one explicit rule and its scope, including exceptions if any. | Compact definition; requires validation against every node/rank. |
| **Defer** | No costs are assigned. | Purchase service remains unused and UI remains read-only. |

No costs, cost curve, refund rule, or affordability UX behavior is proposed here.

### 5. Prerequisites

No prerequisite IDs, ranks, or graph rules are approved.

| Prerequisite option | Definition needed | Consequence |
|---|---|---|
| **A — No node prerequisites** | Owner confirms all approved nodes are independent. | Avoids dependency gates; nodes still need any separate branch unlock rule. |
| **B — Same-branch links** | Owner provides predecessor IDs/ranks within each branch. | Creates within-branch order; requires complete links and a valid acyclic graph. |
| **C — Cross-branch links allowed** | Owner provides all IDs/ranks and identifies which cross-branch dependencies are allowed. | Supports connected progression across branches; increases dependency and validation complexity. |
| **Defer** | No dependency rule or node links are assigned. | No node can be treated as purchasable from inferred order. |

These options do not grant branch unlocks; those criteria are a separate decision.

### 6. Branch/node unlock criteria

The sources do not define branch/node access gates.

| Unlock option | Definition needed | Consequence |
|---|---|---|
| **A — No additional unlock gate** | Owner explicitly confirms the four branches/nodes have no gate beyond any node prerequisite. | Simpler availability rules; does not imply any node identities or purchases are approved. |
| **B — Explicit progression gates** | Owner supplies the gate for every affected branch/node, including the persistent state it reads. | Enables staged availability; requires complete conditions and save/reboot semantics. |
| **C — Per-entry decision** | Owner marks each branch/node as gated or ungated and supplies its rule. | Allows varied availability; requires a complete catalog-level audit. |
| **Defer** | Leave availability unresolved and do not expose purchaseable nodes. | Preserves the current empty/read-only framework. |

No wave, Reboot count, ownership, or other gate is proposed.

### 7. Automatic-combat and Reboot interaction

**Fixed guardrails:** combat stays automatic; no player-triggered abilities, target selection, tactical overrides, or per-target commands are added. Purchased research and both Influence balances persist across Reboot.

For each approved effect, specify whether it can affect authoritative combat simulation, autonomous ability eligibility/activation or target policy, encounter/wave transitions, only non-combat state, or more than one of these. State exactly when a committed purchase takes effect (current encounter, next encounter, or another explicitly defined boundary), whether purchase is available during combat, and any ordering needed with combat events. These are unanswered fields; no effect or timing option is selected here. Any effect that touches autonomous targeting or ability behavior must retain the no-manual-control rule and receive an explicit contract.

Reboot itself is not an open persistence choice: researched state and both Influence balances remain permanent. If a proposed effect has a run-specific interaction or recalculation rule, supply that rule without resetting purchased research.

## Owner worksheet

The current approved response is **Defer node definitions until combat/economy playtests**. When that gate is reached, fill the following for every node and rank, or leave the catalog empty:

| Branch | Node ID/name/order | Rank model/cap | Complete effect contract | Spendable Influence cost | Prerequisites | Unlock rule | Automatic-combat timing/interaction |
|---|---|---|---|---|---|---|---|
| Combat Protocols | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined |
| Underground Economy | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined |
| Network Infrastructure | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined |
| Personnel Development | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined | Not defined |

## Gate and record

This packet is not authorization to change the catalog, UI, service, save schema, combat behavior, or economy. Only after post-playtest decisions have complete node/rank/effect/cost/dependency/unlock records and explicit approval may the catalog be populated. Until then, preserve the four empty branch arrays and read-only Research UI. No runtime, data, tests, art, save files, or remote documents changed; no tests were run for this documentation-only packet.
