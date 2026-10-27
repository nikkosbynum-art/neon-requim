# Automatic abilities and squad preferences — source reconciliation

**Status:** Live Notion source read; local documentation only. No gameplay or art changes.
**Retrieved:** 2026-10-26 UTC. Notion fetch results report verification.state: unverified.
**Scope:** Automatic ability activation/targets and optional squad position/role preferences. The offline reconstruction is non-verbatim and does not fill live-source gaps.

## Finding

No character ability is fully specified for implementation. Approved policy: deployed units independently select targets and activate skills automatically when available and eligible according to character AI and skill requirements. Manual special-ability triggers, tactical target overrides, and per-target commands are excluded. The policy does not give per-skill operational rules.

The preference data contract is implementation-ready: optional soft Front/Middle/Rear band; optional Vanguard/Assault/Support/Control role; unlimited recruits per band; position wins a position/role conflict; role guides movement within a selected band and by itself when no band is set; preferences persist per recruit across Reboots; configuration is outside combat. Spatial movement remains unspecified.

## Missing ability fields

Each ability needs approved trigger/eligibility predicates; cooldown start/duration/reset/cadence; any resource cost; effect type/targets/magnitude/duration/stacking/termination; target eligibility/priority metric/tie-break/count/range/fallback; target lock/retargeting/interruption; ordering for simultaneous events; and behavior for defeat, wave changes, invalid/no targets, plus character-specific passive interactions.

Roster summaries are not mechanics: emergency heal; increased impact with neural strain; cyberware-disrupting precision shot; three attack drones; cloaked priority strike; anchor/suppress; heal and attack boost with instability; frontline penetration; decoys; multi-target dash; disable strongest enemy implant; accelerated target-switching burst. “Priority,” “strongest,” and “frontline” have no canonical metric/fallback.

## Missing formation fields

Need approved band geometry/world positions and depth offsets; spacing and occupancy; collision/pathfinding and ground/lane constraints; regroup/cohesion; role-specific movement within/without a band; movement priorities when role, target, range, obstacle, or encounter state conflict; and whether preferences affect targeting. The live rule defines preferences as movement guidance and does not define a targeting modifier.

## Selectable next decisions

Formation: (A) implement preference data/settings/persistence only and defer spatial behavior (recommended); (B) specify geometry, spacing, collision/pathing, and role movement first; (C) defer preference implementation.

Abilities: (A) specify BREAKER’s complete skill contract, then implement/test that one skill (recommended for the vertical slice; mechanics need user approval); (B) specify all twelve complete contracts before implementing any skill; (C) keep policy/event transport only and defer all skill behavior.

## Live source evidence

- Game Design & Progression: https://app.notion.com/p/40394c5658c88159962fee5423c311de — fetched 2026-10-26; edited 2026-10-26T03:12:05.596Z; verification unverified. Confirms automatic target/skill policy; says algorithms/cooldowns and spacing/position parameters need prototyping. Older “next design decision” statements are superseded by the later preference contract. The same fetched Game Design page and Decision Log retain old implementation status text saying the Godot combat engine/AI is not implemented; current local implementation records show a working automatic combat simulation, so those status sentences need reconciliation rather than being treated as current build state.
- Decision Log & Change Control: https://app.notion.com/p/40394c5658c88127b755c01197ff628d — fetched 2026-10-26; edited 2026-10-26T03:12:02.885Z; verification unverified. Confirms automatic policy and later position/role bands, precedence, and Reboot persistence.
- Founding Recruit Roster: https://app.notion.com/p/40394c5658c8812d849be3d32629920e — fetched 2026-10-26; edited 2026-10-26T03:12:07.445Z; verification unverified. Lists twelve signature-skill summaries, not full mechanics.
- Offline reconstructed pages were consulted as secondary context only; they contain no complete ability contracts.

