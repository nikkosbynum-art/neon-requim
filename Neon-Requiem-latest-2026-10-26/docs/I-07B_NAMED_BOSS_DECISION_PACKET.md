# I-07b — Named boss identity, encounter, and recruitment choices

**Status:** Recruitment transaction selected; content and encounter gates remain open  
**Date:** 2026-10-26 America/Chicago  
**Scope:** Turn the existing I-07a source-gap audit into a bounded owner decision set.  
**Excluded:** Boss profiles, spawns, runtime/data/test changes, art generation, remote writes, or inferred content.

## Evidence base and limits

This packet relies on `docs/I-07A_BOSS_SOURCE_GAP_AUDIT.md` and its cached local Notion readbacks. Those fetches were marked `verification.state: unverified`; this packet did not make a fresh remote Notion or Drive read. The offline handoff is reconstructed, not a verbatim export. The source URLs are [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de), [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d), [Founding Recruit Roster](https://app.notion.com/p/40394c5658c8812d849be3d32629920e), [Production Roadmap](https://app.notion.com/p/40394c5658c88172981ce66c9e206f3e), and [Asset Library & Artwork Manifest](https://app.notion.com/p/40394c5658c8816f9d76d1d08afbbfd9). Retrieval dates/status are recorded in `docs/MIGRATION_REPORT.md` and the I-07a audit.

### Facts supported by current project sources

- The five approved concept names are **Patchwork** (replacing Nacre), **Ghostlight**, **Chainbreak**, **Civic Warden**, and **Sable Venn**.
- One named boss is planned for each of five 25-wave districts. The five bands are Undercity (1–25), Neon Row (26–50), Black Grid (51–75), Enforcement Zone (76–100), and The Spire (101–125); procedural endless starts at 126.
- District-endpoint placement is approved as a **pacing-test baseline** to compare against alternatives. It is not locked as the final spawn rule.
- A named boss is guaranteed recruitable on first defeat. Once recruited, that unique identity is permanently excluded from enemy generation; generic archetypes may recur.
- **Owner selection (2026-10-26):** first defeat immediately grants permanent ownership. The unique identity is excluded from enemy generation as part of that grant.
- Apply the existing recruit roster rules at grant: fill the first open active slot; if all six are occupied, place the recruit in reserve; if acquired during combat, begin deployment at the next encounter.
- The local feasibility reward profile gives one repeatable Evolution Data per successful clear and one extra for the first-cleared named boss. This is a prototype material trial, not a full boss-specific reward profile or final balance approval.
- The only local runtime enemy definition found by I-07a is the prototype Undercity Grunt. Boss-ID event transport and a synthetic `boss.test_warden` regression fixture do not implement a named-boss encounter or recruitment lifecycle.

### Evidence gaps

- No source assigns any of the five names to a district.
- No full boss profile, faction assignment, combat role, stats/scaling, ability contract, target rules, encounter composition/script, or boss-specific credit/reward profile was found.
- The available local asset package has no named-boss identity sheet or production-ready boss assets. The generic BOSS/ELITE image is not mapped to a named identity. This is a local-package finding, not a fresh search of remote Drive.
- The earlier separate claim-action and pending-claim replay branches are closed by the immediate permanent grant. No pending-unclaimed state remains in the selected lifecycle.

## Decision set

### 1. Assign identities to districts

Exactly one named identity per district is approved at the scope level; the mapping is open. Fill the mapping without inferring it from names, factions, or concept art:

| District | Wave band | Boss identity |
|---|---:|---|
| Undercity | 1–25 | Unassigned |
| Neon Row | 26–50 | Unassigned |
| Black Grid | 51–75 | Unassigned |
| Enforcement Zone | 76–100 | Unassigned |
| The Spire | 101–125 | Unassigned |

Identities available for assignment: Patchwork, Ghostlight, Chainbreak, Civic Warden, Sable Venn.

### 2. Keep endpoint placement a trial or lock it as final

Current source decision: use district endpoints as the pacing-test baseline and compare alternatives during pacing tests. No final placement rule is selected here. Retain that test-only status unless an explicit later decision locks authored placement.

### 3. First-defeat ownership and deployment — selected

First defeat immediately adds the unique boss to permanent ownership; enemy generation excludes that identity as part of the grant. Apply the existing roster contract without a boss-specific exception: use the first open active slot, otherwise reserve the recruit when all six slots are occupied, and defer deployment until the next encounter if acquired during combat. The separate claim-action option and all pending-claim replay branches are no longer applicable.

### 4. Remaining lifecycle/content questions

The selected ownership transaction does not assign a district, define encounter records, or settle the enemy generator's general boss cadence. Boss-to-district mapping, faction, combat role, stats/scaling, ability/target contract, encounter composition/script, and complete rewards remain open. The endpoint remains a pacing-test baseline only; it is not the final spawn rule.

### 5. Supply the boss encounter records

For each identity, source or owner input is still needed for district mapping, faction, combat role, stats/scaling, automatic ability/target contract, encounter composition/script, and complete reward profile. The packet does not propose values or mechanics. Keep the existing first-clear Evolution Data trial separate from unapproved boss-specific rewards.

### 6. Supply approved boss visual/production sources

Provide or approve identity-specific visual references before authoring boss art. The generic mech illustration and four local concept sheets do not establish any named boss's appearance, parts, rig, or animation. Do not promote them as named-boss production art.

## Implementation boundary

The selected first-defeat ownership/deployment rules are a design decision, not implementation or test evidence. Do not add boss spawns, district mappings, stats, abilities, or art by inference. Define complete encounter records and lifecycle tests after remaining content/source decisions before wiring encounters.

## Local review record

- Derived from the I-07a read-only source-gap audit; no new source access was performed.
- Owner-selected immediate permanent grant on first defeat, immediate unique-identity generator exclusion, and existing first-open-slot/reserve/next-encounter deployment rules (2026-10-26).
- No runtime, data, test, art, save, or remote document changed while preparing this packet.
- No tests were run; none are applicable to a documentation-only decision packet.
- Keep local `Notion/` and `Google Drive/` copies as staging only. Group canonical reconciliation is still queued; no remote sync is claimed.
