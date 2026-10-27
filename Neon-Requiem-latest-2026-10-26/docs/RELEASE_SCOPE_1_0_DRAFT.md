# Neon Requiem — 1.0 Scope Draft

**Status: Partially approved; release target updated from the user-approved local decision dated 2026-10-25. Roster/art option C, evolution availability for all twelve and its hybrid gate, Windows 1.0 target (direct-download installer, x86_64, Windows 11), scalable 16:9 presentation with a 1280×720 minimum viewport, and Reboot eligibility after the first wave-25 clear are approved. Minimum hardware, exact Windows 11 build, additional display-support combinations, build/update procedure, and other listed system details remain open.** Prepared from the local user brief, project decisions, and offline reconstruction kit. The offline kit is explicitly reconstructed; this draft records the cited local approval and does not certify that it includes later remote decisions.

The Influence formula and material-source policy in [`PROGRESSION_RULES_PROPOSAL.md`](PROGRESSION_RULES_PROPOSAL.md) are approved for prototype feasibility testing only; they are not final balance/canon. Evolution threshold and cost examples remain proposals.

## Scope anchors already established

- Cyberpunk 2.5D endless idle army RPG; six active squad slots from the beginning.
- Automatic combat, targeting, and ability activation; no gacha or manual combat controls.
- Deterministic credit recruitment; a named boss defeat guarantees its unique recruit.
- Hybrid power-driven, fixed-step combat simulation is authoritative; presentation visualizes simulation events.
- Four permanent evolution tiers: Origin Form, Adapted Form, Signature Form, and Requiem Form.
- Manual System Reboot; permanent Network Influence and research; reboot resets credits, run-levels, current wave to 1, and the run's highest-cleared-wave counter to 0 while retaining permanent progression. Reward uses the pre-reset run peak; reset behavior approved 2026-10-24, award formula approved for prototype feasibility testing only.
- Offline earnings are credits only, use the saved holding wave, do not advance waves, and target an eight-hour cap.
- The initial scope names twelve founding recruits and five district ranges through wave 125, followed by procedural endless progression. These are scope anchors from the supplied brief; detailed encounter content still needs definition.
- Modular encounter zones with seamless-looking transitions are approved. Specific zone content/layout and production pacing are not thereby approved.
- Spending ceiling is $25 total additional spend, targeting $0.

## 1.0 cut: approved decisions and remaining proposals

| Area | Recommended working scope | Status |
|---|---|---|
| Platform and package | Direct-download Windows installer, x86_64 only, for Windows 11; mobile is outside 1.0. | **Approved 2026-10-25.** Minimum hardware, exact Windows 11 build, and build/update procedure remain open. |
| Presentation target | Scalable 16:9 presentation with a minimum viewport of 1280×720. | **Approved 2026-10-25.** Additional supported resolution/aspect-ratio combinations remain open. |
| Recruit roster | All twelve named founding recruits are in the 1.0 playable roster; six can be deployed at once. | **Approved 2026-10-24** |
| Character art | All twelve recruits have distinct visible art changes at every evolution step (Street, Combat, Military, Apex) in 1.0. BREAKER may retain first production priority. | **Approved 2026-10-26**; tier-specific designs and all production gates remain open |
| District progression | Preserve the stated five 25-wave district bands through 125 and endless progression after. Treat each band as a content target, not as a completed or fully specified encounter plan. | Brief-based scope; exact zone maps/pacing open |
| Boss/recruitment | Named bosses guarantee their unique recruit; once recruited, they stop appearing as named enemies. | In the offline reconstruction; confirm against canonical sources when available |
| Economy and combat values | Ship the approved systems with data-driven, playtested formulas; no prototype numeric value becomes final by default. | System scope established; formulas open |
| Evolution | All twelve can evolve in 1.0; every step requires a progression milestone plus earned materials. All twelve require distinct visible art changes at each of the four stages in 1.0. | **Availability and hybrid gate approved 2026-10-24; all-twelve visual coverage approved 2026-10-26; exact thresholds/materials/costs and tier-specific art designs remain open** |
| System Reboot | Manual reboot in the initial release; first eligible after the first clear of wave 25. Preserve recruits, evolution, research, and permanent influence; reset credits, run-levels, current wave to 1, and run high-water to 0. Reward is based on the pre-reset run peak. | **Eligibility/reset boundary approved; award and passive curve approved for prototype testing only, not final balance** |
| Offline earnings | Credit-only, based on saved holding wave, capped at eight hours; no offline wave/boss/recruit/level advancement. | Behavior established; rate formula open |
| Save data | Versioned local save with permanent, run, and settings sections; support migration and recovery before release. | Recommended architecture; not formally approved |
| Zone presentation | Keep the approved modular-zone transition system; define authored district environments and encounter layouts as production content. | Architecture approved; content open |

## Decisions still open to lock the 1.0 cut

### A. Roster and art scope — approved

1. **Full roster and full art:** all twelve recruits playable, with distinct visible art changes at every evolution step. This art scope was selected by the owner on 2026-10-26; exact tier designs and production completion remain gated.
2. **Six-recruit launch:** six playable recruits with four tiers; remaining six join after 1.0. Not selected.
3. **Historical broad roster, staged art (selected 2026-10-24; art deferral superseded 2026-10-26):** all twelve playable with Tier I art; BREAKER first; higher-tier art for the other eleven deferred post-1.0. The later owner decision requires distinct visible changes at all evolution steps for all twelve in 1.0.

Historical 2026-10-24 plan, superseded for visual completeness by the 2026-10-26 owner decision: all twelve are playable and have evolution progression in 1.0, Tier I art is targeted for each, and BREAKER was initially prioritized for the first four-tier art set while the other eleven's higher tiers were deferred. Current 1.0 scope requires distinct visible art changes at all four evolution steps for all twelve. The hybrid gate remains approved: both a progression milestone and earned materials are required. Exact milestones, material types, acquisition rules, costs, and individual tier designs remain open.

### B. Release platform and package — approved

- Platform: Windows PC only for 1.0; mobile is outside scope. Approved 2026-10-24.
- Package and architecture: direct-download Windows installer, x86_64 only; approved 2026-10-25.
- OS and presentation: Windows 11; scalable 16:9 presentation with a minimum viewport of 1280×720; approved 2026-10-25.
- Still open: minimum hardware (after the approved low-end/typical/high-end device test coverage), exact Windows 11 build, additional supported display combinations, and build/update procedure.


### C. Reboot and evolution pacing

1. **Selected by the user on 2026-10-24:** Reboot becomes eligible after the player clears wave 25 for the first time.
2. A different explicit wave or milestone. Not selected.
3. Defer eligibility until progression playtests establish a checkpoint. Not selected.

**Approved on 2026-10-24:** evolution uses a hybrid gate; each tier requires both a progression milestone and earned materials. Choose the exact milestone thresholds, material types and sources, amounts, and costs later. Do not implement invented values as canon or add paid acquisition/gacha.

The release distribution and minimum presentation target are approved as stated above. The minimum Windows 11 build, minimum hardware floor, accepted display combinations beyond 16:9 at 1280×720, and installer/build/update procedure remain undecided. The approved scalable window sizing does not add mobile to 1.0.

### D. Save and technical target

1. Approve the current versioned permanent/run/settings partition for 1.0 (recommended).
2. Change the partition or save location before further persistence work.

### E. Zone and encounter content

Confirm whether the supplied district bands (Undercity 1–25, Neon Row 26–50, Black Grid 51–75, Enforcement Zone 76–100, The Spire 101–125) remain the 1.0 planning target, then define named bosses, ordinary enemy mix, and authored zone layouts per band. The existing wave-13 switch is only a prototype test fixture.

## Work that can proceed while choices are pending

- Keep numeric combat/economy values in data and tune them through playtests without calling them final.
- Continue the BREAKER Tier I asset pipeline as a quarantined production experiment; the latest head cutout failed the style/scale fit review and must not be integrated.
- Preserve the six-slot, fully automatic combat loop and approved movement/grounding rules.
- Build source-independent tooling and tests for data validation, save migration, and encounter reproducibility.

The roster/art scope, evolution availability for all twelve, and Windows-PC-only release are approved. The 2026-10-26 owner decision supersedes the prior post-1.0 deferral: every recruit needs distinct visible art changes at every evolution step in 1.0. This approves the coverage target only; do not invent tier-specific designs or bypass the source, semantic, provenance, pivot, deformation, rig/animation, and production gates. Economy values remain open until their related rules are approved.

## Boundaries of this draft

This is a local planning artifact, not a canonical-source reconciliation, production schedule, or proof of release readiness. Approved decisions are identified and scoped above; remaining recommendations are proposals. Remote asset-library verification and repository confirmation remain outside this pass.
