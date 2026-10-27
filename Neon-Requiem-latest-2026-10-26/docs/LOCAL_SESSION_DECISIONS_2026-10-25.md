# Local session decisions — 1.0 planning

**Status:** Decisions below were selected by the user in this conversation and saved locally for continuity. The relevant sections were appended to live Notion pages and verified by readback on 2026-10-26 UTC (2026-10-25 America/Chicago). No GitHub repository was accessed. The migration package is a reconstructed, non-verbatim handoff. Numeric balance candidates remain trial-only.

## 1.0 scope and content

- Include all five district bands through wave 125 in 1.0. Use one named boss per district. Keep boss placement at district endpoints as a trial baseline, then compare alternatives in pacing tests.
- Use two visual encounter modules per district, with transitions at district-local wave 13 (global waves 13, 38, 63, 88, and 113). Mix factions throughout districts. The module descriptions are visual direction only; they do not name canon locations or approve production art.
- The five named boss concepts approved in this conversation are Patchwork (replacing Nacre), Ghostlight, Chainbreak, Civic Warden, and Sable Venn. Their exact encounter placements remain provisional until pacing tests.
- Make all twelve founding recruits available for recruitment from the start. Start the playtest roster with Vector, Spark, and Recoil. The starting-credit amount and recruit prices below are playtest candidates only.
- Limit the 1.0 recruit roster to the twelve founding recruits and five named boss recruits. Defer generic recruitables. Do not allow duplicates of named founding recruits; generic recruits may be duplicated if later introduced.
- Give all twelve founding recruits distinct visual changes at all four evolution grades in 1.0. The five boss recruits receive Tier I visuals in 1.0; their higher-grade visuals are deferred.
- Formation preferences include both position and role. Position bands are soft Front/Middle/Rear preferences and may contain any number of recruits. Position wins when it conflicts with role; role guides movement within a band and supplies movement when no position is set. The selected role tags are Vanguard, Assault, Support, and Control, with the movement meanings developed in this conversation. Save each recruit's preferences across Reboots.
- Keep research branches in 1.0; defer the research catalog until combat and economy testing informs its contents.
- Keep the evolution material name undecided. “Evolution Data” remains a prototype label. Evolution gates and material amounts remain trial-only until balanced.

## Trial values and test candidates

These values are explicitly for playtesting and are not release balance or canon:

- Moderate economy test curve: wave reward candidate `round(12 + 223.51*(1.015^(wave-1)-1))`; recruit-level cost candidate `round(20*1.12^(level-1))`.
- Rarity price candidates follow a 1×/2×/4× ratio: Common 300, Rare 600, Epic 1,200. Starting playtest credits: 600.
- Reboot eligibility at wave 25 and the previously selected Influence/material/evolution candidates remain trial values. Keep final balance and tier effects open pending data.
- Use hybrid power advantage to inform expected combat outcome; stats and abilities can change it. Use seeded randomness. The original local note also recorded “stalled combat resolves as defeat,” but the manager-thread audit found no direct reply selecting that timer-expiry result. The outcome is now explicitly selected as an owner-delegated manager recommendation in `docs/LOCAL_SESSION_DECISIONS_2026-10-26.md`. Use both a maximum encounter timeout and a no-progress timer. After one holding-wave clear, auto-retry the next uncleared wave.

## Release target decisions

- 1.0 distribution choice: direct-download Windows installer.
- Architecture: x86_64 only.
- Support Windows 11. Decide the minimum hardware requirement after testing available low-end, typical, and high-end Windows 11 x86_64 devices. The machine categories are a test-coverage plan, not a hardware specification; no minimum build or hardware numbers are selected yet.
- Keep a 16:9 presentation at a minimum viewport of 1280×720 with scalable window sizing.

## Playtest plan

- Test in stages: combat, then economy, then evolution and Reboot, followed by combined end-to-end playtests.
- For combat, use fixed seeds for reproducibility and varied seeds to measure outcome variability. Record lineup, seed, outcome, duration, resolution reason, and per-unit contribution.
- For economy, record credit sources and spending, purchase timing, roster changes, upgrades, and wave progress.
- For evolution and Reboot, record eligibility, materials earned/spent, grade changes, and progression before and after the action.
- Compare boss-placement candidates using clear rates, encounter duration, and effects on subsequent progression.
- Do not set final numerical thresholds from this plan alone; collect playtest evidence first.

## Local-only and deferred items

- Keep the existing project directory structure as the working store. This file and the refreshed staging copies are local only.
- Cross-chat GitHub access remains unresolved. Revisit GitHub access troubleshooting later. Notion text updates were verified on the Decision Log, Game Design & Progression, Founding Recruit Roster, and Production Roadmap pages; no binary upload was performed.
