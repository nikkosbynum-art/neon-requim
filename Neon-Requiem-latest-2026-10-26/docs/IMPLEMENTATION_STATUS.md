# Implementation status
## 2026-10-26 America/Chicago — I-12c malformed-sidecar save guard — focused validation

- Ordinary Save now returns `SAVE_PROTECTED_ERROR` before staging a temporary file whenever `.bak` or `.bak.prev` is present but has unsupported schema metadata or fails save validation, including alongside a valid primary. The inspection reports these candidates through `unsupported_sidecars`; the guard uses that result while leaving the recovery loader unchanged.
- Confirmed Reset still bypasses the ordinary-save guard and uses the existing verified quarantine and rollback path. Supported-save unknown-field preservation and load/recovery order were not changed.
- Added focused memory-file regressions for malformed JSON in `.bak` and a supported-version but invalid `.bak.prev`; each checks protected error, byte-for-byte save-set preservation, and absence of a staged `.tmp` file.
- Validation: Godot 4.7.2 headless `--confirmed-reset-regression-only` exited **0** and printed `All focused confirmed-reset and save-protection regressions passed.` No full suite, import, scene smoke, or UI run was performed. No real user save was inspected or changed.
- This local implementation result is queued for canonical reconciliation. No remote Notion/Drive write, upload, or readback is claimed.

## 2026-10-26 — C-05d CIPHER board evidence and artist clarification — local documentation only

- Verified the owner-approved revised CIPHER four-form digital-Apex concept board read-only in the local Codex generated-images folder outside the project: `exec-9b29115b-db4d-4b74-bcc0-f23479e0e5c4.png`, 1774×887, 2,244,076 bytes, SHA-256 `d2552a9ddac3b43ce3e19b69325272776181e013e475e1fd8f001f4147abb606`.
- Logged it as visual-direction approval only; it remains outside-project and quarantined, not a production asset or rig/gameplay/runtime/integration approval. In the Military panel, a held rifle and weapon-like back item create an unresolved identity ambiguity. Artist must label the back item; if it is the signature rifle, only one carry state may be shown for that grade, preserving the approved one-rifle/one-carry-state constraint.
- Updated the asset manifest, evolution coverage map, artist handoff, migration report, and remote sync queue. Refreshed their labeled Notion/Drive staging copies and verified matching SHA-256 values. No art was changed/copied/integrated, no code/runtime/tests changed or ran, and no remote read/write/upload/readback occurred. Documentation-only writer slot released to the manager.

## 2026-10-26 — owner-selected documentation follow-ups — local only

- I-03: owner-selected overlap constraint remains. The manager separately selected provisional passing rules, a no-threat predicate, and permission for a bounded disposable geometry-only harness; these do not authorize spatial runtime work. Air-lane geometry and ECHO mapping remain open; no harness has been created or run.
- I-06: functional level purchase/stat growth remains BREAKER-only pending individualized combat/economy evidence; all-twelve recruitment/evolution records remain.
- I-09: wave 126 is the approved design start; current runtime/save ceiling remains 125. Profile families and above-125 offline inputs are deferred. Undercity fixtures remain provisional.
- Character evolution direction now includes the owner-selected BULWARK medic-specific concept (armor, medical pack, diagnostic bracer; preserve connected hose and helmet-cross treatment); concept-only, with no mechanics or production approval.
- SaveService writes schema v2 and migrates known v1. These local records do not claim remote reads/writes/uploads. No code, test, art, or runtime validation changed in this batch.
- Staging verification completed: SHA-256 matched for 17 changed/current coverage-map and artist-handoff Markdown files in each of `Notion/Project Docs/` and `Google Drive/07 - Notion Exports/` (34 staged copies total). This verifies local copy integrity only; it is not a remote sync.
- Read-only board inventory verified five generated PNGs outside the project tree: CIPHER, SPARK, and BULWARK approved concept directions plus two unapproved SPECTER proposals. Exact dimensions, hashes, and quarantine status are in `docs/ASSET_MANIFEST.md`. No boards were copied, altered, integrated, or promoted.
- The standing evolution-direction standard and netrunner visual boundaries are documented. The owner approved the revised CIPHER four-form board for visual direction only, as recorded in `docs/NETRUNNER_APEX_VISUAL_DIRECTION_REVIEW_2026-10-26.md`; it remains outside the project and quarantined.
- Official form labels remain Origin Form, Adapted Form, Signature Form, and Requiem Form; historical board labels map in sequence as shorthand only. All twelve character boards remain direction-only/quarantined. The CIPHER approval does not cover production, rigging, gameplay, mechanics, runtime, or integration. This is documentation-only: no code/data/art/runtime/system changes or tests were made.
- Owner-review status correction reconciled the CIPHER board as visual-direction-approved only; its file remains outside the project and quarantined. SHA-256 matched all 11 affected source Markdown files against both labeled local staging folders (22 copies). This is local copy integrity only, not remote sync.
- Local staging verification for this batch passed: SHA-256 matched all 11 source Markdown documents against `Notion/Project Docs/` and `Google Drive/07 - Notion Exports/` (22 staged copies). This is local copy integrity only, not a remote sync or canonical readback.

## 2026-10-26 America/Chicago — C-05a evolution-art coverage map and lane handoff — local documentation only

Character completed `docs/C05A_EVOLUTION_ART_COVERAGE_MAP.md`, a 48-entry map covering all twelve recruits at Street, Combat, Military, and Apex grades. It records direction-only BREAKER and earlier CIPHER references, missing source/art evidence, and per-tier semantic, provenance, pivot, pose, deformation, rig, and production gates. Owner clarification requires character-specific visual changes; do not assume every recruit gains cybernetic parts. BREAKER's existing cybernetic progression is suitable. Approved concept direction: CIPHER's external HUD progresses into an integrated biomechanical eye, with one rifle in one carry state per grade; SPARK is a mechanic with three distinct drones receiving staged hardware upgrades. Generated boards remain quarantined and are not production/rig approval; exact stage implementations remain to be mapped. Proposed mechanics remain provisional/non-canon; mechanical upgrades are proposals, not canon. Local board paths/hashes remain to reconcile. No art, runtime/code/data, tests, saves, or remote source changed; no validation or remote read/write/upload/readback is claimed. Character releases the single-writer slot to Design for I-03/I-06 documentation/options. Implementation I-03 remains gated on Design decisions and applicable Character/source evidence; v1/art readiness remains 34%/3%.

## 2026-10-26 America/Chicago — I-04 residual focused coverage closeout — local only

Test Lane completed the residual focused gates in `tests/i04_ability_regression_runner.gd`: all-twelve no-target readiness/cooldown and action-boundary dispatch; GLITCH ordinary-shot preservation with one enemy; CIPHER stable-ID tie selection; ECHO expiry; target-bound cleanup for CIPHER/IRONCLAD/DEADLOCK; BULWARK/STITCH heal caps; ability-state exclusion from the actual `main._make_run_snapshot` payload; victory/defeat/retreat cleanup; and GLITCH targeting-status expiry. Godot 4.7.2 focused run exited 0 with `All focused I-04 ability regressions passed.` Known user-log write warning and intentional malformed-profile warning appeared. No full suite, import/editor parse, or scene smoke was run. No production code, design, data, art, or saves changed in this closeout. The single-writer slot is released to Character for queued C-05a documentation-only work; I-04 remains focused-only, with broader/release verification and provisional design values unresolved.

## 2026-10-26 America/Chicago — expanded 1.0 character-art scope and carry-state decisions — local documentation only

- Owner-selected art scope: all twelve recruits require distinct visible art changes at each of four evolution stages in 1.0. This supersedes C-05's prior post-1.0 deferral for eleven recruits. The requirement does not approve specific tier designs or clear source/semantic/provenance/pivot/deformation/rig/production gates.
- Owner-selected character directions: GLITCH's held/back-mounted item is one rifle in two carry states, replacing the “sidearm” label; semantic boundaries, mounts, pivots, transition behavior, and provenance remain open. ECHO Signal Cascade decoys are distinct from physical sensory devices; no visible spheres may be mapped/counted as decoys without source/owner mapping. IRONCLAD's back-stowed weapon state is approved as art direction, with exact mount/overlap/anchors/pivots/transitions open. BULWARK's side-facing cross is approved in addition to the front cross; an artist-authored side view is required, never a pasted front crop.
- Readiness updated: production art estimate reduced from 5% to 3% due to expanded 1.0 scope and no accepted Tier I/evolution production art; raw weighted readiness is 33.6%, rounding to 34%.
- Test completed focused I-04 residual coverage. Character has completed C-05a, the documentation-only all-twelve/four-tier evolution-art coverage and evidence map. Design receives the released writer slot for I-03/I-06 documentation/options; Implementation remains gated for I-03 until Design's remaining rule/scaffold decisions and relevant Character/source gates are resolved.
- Documentation only: no art, runtime, tests, saves, or remote sources changed; no validation run or remote read/write/upload/readback is claimed. Local staging refresh and hashes are recorded in the remote queue.

## 2026-10-26 America/Chicago — I-07b and I-03 decision-record reconciliation — local only

- Recorded the owner-selected named-boss transaction: first defeat grants permanent ownership immediately and excludes that unique identity from enemy generation; the existing roster rules fill the first open active slot, use reserve when all six are occupied, and defer combat-time deployment to the next encounter. Separate claim-action and pending-unclaimed replay branches are closed.
- Boss-to-district mapping, encounter records, faction/role/stats/abilities, spawn/cadence, full reward profiles, and identity-specific art remain open. No runtime, data, test, art, or save changes occurred.
- Corrected I-03 records to state that all bodies remain grounded while SPARK drone and ECHO decoy attachments use the spatial air lane. Tuning after layout testing does not authorize or define a test scaffold; its permitted scope remains unresolved. No spatial runtime or tests changed.
- Refreshed local labeled staging copies and compared SHA-256 hashes. No test or validation run was performed in this documentation-only update. No remote read/write/upload/readback is claimed.
- Test Lane now owns the remaining I-04 action-boundary, no-target, save-state, and lifecycle coverage; focused-only evidence remains the current validation state.

## I-04 twelve-recruit ability trial — focused residual coverage passed; broader verification pending — 2026-10-26 America/Chicago

- Added runtime code for the twelve simulation contracts from `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` in `scripts/combat/combat_director.gd`, with configurable values in `data/combat/ability_trial.json`. Values and selected rules remain owner-delegated playtest defaults, explicitly non-canon; normal combat remains direct-damage and abilities remain disabled unless opted in with `--neon-ability-trial`.
- Runtime includes automatic action-boundary checks, cooldown/temporary-effect cleanup, authoritative attack/ability events, team healing/support, attack modifiers/statuses, cyberware/implant targeting and disables, abstract ECHO decoy targeting, and a trial-only multi-enemy fixture path for SPARK/RECOIL/VECTOR/GLITCH and target-priority checks. Default wave data still has one enemy. ECHO has no physical actor/art/air-lane mapping.
- The trial profile does not add ability state to saves, production encounter composition, character art, or authored enemy capabilities. Reference and concept art remain unchanged.
- **Initial focused Test Lane attempt (historical):** Added test-only coverage in `tests/i04_ability_regression_runner.gd` and invoked it with Godot 4.7.2 using `--headless --path . --script res://tests/i04_ability_regression_runner.gd`. An initial runner parse issue (untyped `before_hp`) was corrected. The next run exited 1 before regressions executed because `_resolve_ally_attack(index, target_id)` supplied two arguments although the helper requires at least three. The compile issue was corrected and the successful rerun is recorded below.
- **Implementation correction:** Updated the ordinary attack call at `combat_director.gd:482` to pass the recruit's configured attack power as the required third argument. This restores the existing ordinary attack input expected by the helper; no other production logic was changed for the fix.
- **Focused Test Lane rerun after the compile fix:** `--headless --path . --script res://tests/i04_ability_regression_runner.gd` exited 0 and reported `All focused I-04 ability regressions passed.` The run emitted the known `user://logs/godot.log` write warning and the intentional warning from the malformed-profile fail-closed assertion. The runner covers default direct-damage/ability-off behavior, malformed profile rejection, all twelve ability resolution paths (GLITCH through `_simulate_allies`), representative cooldown commits and encounter-start cleanup, CIPHER cyberware/fallback, stable-ID selection for SPECTER and highest-strength DEADLOCK selection, SPARK/RECOIL/VECTOR ordered event batches, GLITCH one-target readiness/retargeting, ECHO abstract token/durability, healing/no-revive, IRONCLAD anchor/suppression, STITCH living-only boosts/penalty, and a hybrid progress-hook case.
- **Residual focused coverage closeout (2026-10-26):** `tests/i04_ability_regression_runner.gd` now asserts no-target readiness/cooldown behavior for all twelve recruits (GLITCH retains its ordinary shot against the sole enemy), automatic action-boundary dispatch for all twelve, deterministic stable-ID choice for a CIPHER tie, ECHO timer expiry, CIPHER/IRONCLAD/DEADLOCK target-bound cleanup on enemy defeat, BULWARK/STITCH heal caps, ability-runtime-map exclusion from the actual `main._make_run_snapshot` payload, victory/defeat/retreat cleanup, and GLITCH burst targeting-status expiry. The focused Godot 4.7.2 command `--headless --path . --script res://tests/i04_ability_regression_runner.gd` exited 0 and reported `All focused I-04 ability regressions passed.` It emitted the known `user://logs/godot.log` write warning and the intentional malformed-profile fail-closed warning. Multi-enemy checks use in-memory trial fixtures only. No import/editor parse, scene smoke, or full regression suite was run.
- **Current status:** The ordinary attack call-arity defect was corrected by Implementation. Test Lane made test-only edits and completed the requested focused residual coverage. Character then completed C-05a documentation; the single-writer slot is now released to Design for I-03/I-06 documentation/options. I-04 remains focused-only, not broad-suite or release validated; ability values remain provisional and ECHO presentation/source gates remain open. See `docs/WORK_LANE_ASSIGNMENTS.md`.

## I-05 hybrid combat trial — focused and full Godot verification passed — 2026-10-26

- Kept deterministic `direct_damage` as the default control. Added opt-in `hybrid_trial` via Godot user argument `--neon-hybrid-trial`, with optional positive `--neon-combat-seed=<integer>` override.
- Added configurable profile `data/combat/hybrid_combat_trial.json`, explicitly labeled `PROVISIONAL_TRIAL_VALUES_NOT_CANON`. The draft sums living actor scores from current/max HP, attack power, and attack interval/cadence, then applies the same bounded relative-power high-impact likelihood to each side's committed attacks using an encounter-local seeded Godot RNG. Impact multipliers and both stalemate timer thresholds remain feasibility inputs only.
- Fixed-step actions resolve before timer checks. No-progress resets on any per-actor HP change or the qualifying-effect notification hook. Either timer expiry is recorded as defeat; if both expire on the same step, maximum timeout is primary and no-progress is additionally recorded. The existing retreat-to-holding-wave, full recovery on re-entry, and next-uncleared retry path is reused.
- Connected a one-time process-local presentation cue at stalemate arrival. It is only a placeholder signal/HUD message, not a completed cinematic; persistence semantics for the one-time event are not defined. I-04 ability runtime code has since been added as an opt-in trial and reports committed HP/effective-combat changes to the progress hook; the I-05 results below predate that code and do not verify it.
- **Initial Test Lane attempt (historical):** the focused run exited 1 because strict `TYPE_INT` validation rejected the parsed JSON seed/stride variants, leaving hybrid mode disabled and causing downstream assertions to cascade. No full suite or main-scene smoke was run during that first attempt.
- **Verified fix:** seed and stride validation accepts finite positive integer-valued JSON numbers represented as either integer or float, while rejecting fractions, non-numbers, and non-positive values. A focused malformed fractional-seed regression confirms fail-closed fallback to `direct_damage`.
- **Godot 4.7.2 import/parse:** `--headless --editor --path . --quit` exited 0, completed filesystem scanning and registered `CombatDirector`. The editor could not write `C:/Users/Work/AppData/Roaming/Godot` or `user://` settings/log data and printed safe-save/settings errors; these are environment write warnings, not script parse failures.
- **Focused I-05 regressions:** `--headless --path . --script res://tests/test_runner.gd -- --i05-regression-only` exited 0 and reported `All focused I-05 hybrid-combat regressions passed.` Coverage includes direct-damage default/event behavior, explicit first seed and replay, score inputs, bounded monotonic and mirrored two-sided mapping, per-attack resampling, timer action order/reset/tie, timeout defeat, holding-wave recovery, cue and retry flow. The malformed-profile case intentionally emits the expected fail-closed warning.
- **CLI seed and scene smoke:** the dedicated CLI seed regression with `--neon-hybrid-trial --neon-combat-seed=12345` exited 0 and verified opt-in plus first/subsequent encounter seeds. The 220-frame headless main-scene smoke with those arguments exited 0.
- **Full Godot suite:** `--headless --path . --script res://tests/test_runner.gd` exited 0 and reported `All Neon Requiem prototype tests passed.` It emitted the known `user://logs/godot.log` write warning and the unrelated informational quarantined CIPHER mesh `LIMIT` diagnostic.
- These results verify this configurable I-05 trial within the supported Godot 4.7.2 environment; they do not tune or canonize profile values, promise cross-version RNG replay, verify the subsequently added I-04 abilities, or complete/persist the placeholder arrival cue as a cinematic. No artwork or user saves changed, and no remote source/service was used.
- Local labeled Notion/Google Drive staging copies are refreshed and hash-checked after this status update. They are staging copies only; no remote Notion/Drive write or verified readback is claimed.

## T-01g evolution-roster two-size viewport review — complete — 2026-10-26 America/Chicago

Test Lane captured five screens in its disposable project at 1280×720 and 800×450: ready and locked states at both sizes, plus the 800×450 scroll-bottom state. Godot GUI capture exited 0; import cache and source/copy hashes matched; helper checks passed. Test Lane rechecked the original-resolution scroll-bottom PNG: the final five recruits are fully visible, the preceding row is clipped only as expected while scrolling, Close is visible, the prototype note is fully visible through “effects,” and no horizontal scrollbar appears. The earlier clipping report was a scaled-preview misread of the same image, not a UI defect.

The helper verifies final-row intersection but does not assert footer visibility; this is a helper-coverage gap, not a product defect. No source code, tests, assets, or saves changed; T-01h used no further UI or Godot relaunch. Captures remain in the disposable copy and were not imported as production assets.


## I-11b bounded prototype telemetry design — complete, read-only — 2026-10-26 America/Chicago

- Added `docs/I-11B_BOUNDED_TELEMETRY_DESIGN.md`, mapping current combat/economy commit seams, a minimal local opt-in export, privacy/save boundaries, and future acceptance checks.
- Current fixed-step combat exposes resolved attacks but not structured encounter-start/defeat records. The design proposes minimal observational lifecycle events and save-status-aware credit transactions; no simulation, economy value, save, profile, or RNG changed.
- At the time of the I-11b telemetry design, I-05 was still awaiting outcome/seed selections. Those policy choices are now recorded in the 2026-10-26 I-05 closeout below; telemetry of the current direct-damage prototype still cannot validate the unimplemented hybrid model or final balance. No implementation or tests were run for I-11b.
- T-01g is now complete with a successful GUI capture and original-resolution review; see the T-01g section above. The initial fresh-copy failure was superseded.
- Character reports that Notion exposes source link text but not the required readable source binaries; Google Drive remains unavailable. This is a source-readability limitation, not proof that remote assets are absent or an asset inventory.


## I-11a balance/economy evidence inventory — complete, read-only — 2026-10-26

- Added `docs/I-11A_BALANCE_ECONOMY_EVIDENCE_INVENTORY.md`, mapping the current prototype profiles/runtime formulas, trial-only values, source-backed design boundaries, missing telemetry, and evidence required before I-05/I-11 tuning.
- Read-only Notion fetches succeeded for Game Design & Progression, Decision Log & Change Control, Founding Recruit Roster, and Production Roadmap. Each fetch reports `verification.state: unverified`; the connector response did not expose truncation counters. Google Drive was not accessed. Canonical-source reconciliation remains queued.
- The key gap is explicit: the approved economy direction is hybrid exponential, but ordinary prototype wave rewards remain a linear fixture. Current combat directly resolves HP damage and still lacks the now-selected but unimplemented power/outcome layer and seeded variation, abilities, and faction synergies. No balance verdict or coefficient change is supported by the available evidence.
- A local project-tree search found no saved balance-simulator output reports or playtest telemetry dataset. The simulator's clear-each-wave bookkeeping scenarios do not predict combat results or time-to-clear.
- The first T-01g bounded GUI attempt produced no captures: a fresh disposable copy reported GDScript type-inference parse errors at `scripts/main.gd` lines 388, 679, 1186, 1321, and 1416, then failed to load the main scene without a prebuilt `.godot` import cache. It was inconclusive, not a confirmed source regression; the later successful capture is recorded in the T-01g review above.
- Character's all-twelve C-02/C-03 read-only source readiness check reports nine successful Notion fetches (`verification.state: unverified`) and no Drive access. No source-authored part layers, complete ownership/boundary maps, or authored pivots were found in those remote records; newer session decisions remain to be reconciled. Per-character gaps remain in the local artist-input packet and handoff matrix; no candidate or art was promoted.
- No runtime values, tests, simulator scenarios, saves, or assets were changed/run by I-11a. The subsequent I-11b design now scopes telemetry implementation; numeric tuning remains deferred until I-05 rules and playtest evidence are ready.

## D-02 accessibility scope approval — documentation only — 2026-10-26 America/Chicago

- Owner approved keyboard/mouse for 1.0 and deferred controller support; approved continuous text-only scaling; and approved master volume plus mute.
- Under the user's prior authorization to select supported recommendations, the manager separately selected a provisional local follow-up: D-01 gameplay-clarity SFX only (defer soundtrack and in-engine outcome sequences); D-02 continuous text-only scaling 100–150%, default 100%; master volume 0–100%, default 100%, separate mute; Tab / Shift+Tab focus traversal, Enter / Space activation, Escape close/cancel, arrows for options/sliders where applicable; non-color indicators for color-communicated interactive/gameplay-critical states; captions for gameplay-critical non-speech SFX only. These are manager-selected recommendations, not direct owner-authored canon, and await canonical reconciliation.
- Prerequisites: a shared text-scaling helper and layout review; a persisted mute field with load/default handling; implementation evidence for keyboard traversal, dialog boundaries and focus restoration; an inventory of color-communicated states and their non-color indicators; and an inventory of gameplay-critical SFX/caption labels. No cues, speech, music, or outcome sequences are authored by this decision.
- Manager-selected provisional missing-field default: `muted = false` for new profiles and saves without the field; existing `master_volume` default remains `1.0`. This avoids silent muting at the cost of audio playing until muted. This is local-only, pending canonical reconciliation.
- This entry records product direction only. No UI/input/audio/save-schema implementation or validation was performed. No tests were run; no remote readback is claimed. See `docs/REMOTE_SYNC_QUEUE.md`.

## C-02s scoped attachment decisions and provenance handoff — local documentation only — 2026-10-26

- Recorded the user's approvals: BULWARK's white cross backing belongs to the helmet panel; CIPHER's held concept rifle and vertical side-view item are the same prop in different carry states; DEADLOCK has one rifle shown held and back-mounted in different states. These resolve ownership/identity only. No cutout boundaries, hidden geometry, new attachment points/coordinates, pivots, transition behavior, or art approval were inferred.
- Updated the local decision/open-question records, paired-reference review, artist handoff packet/matrix, per-character handoffs, implementation/asset/migration records, and local remote-sync queue. Candidates remain quarantined.
- Provenance recovery remains unresolved: exact prior CIPHER 09B manifest bytes for SHA-256 `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3` and a verifiable snapshot/version record were not found in the project or labeled staging. Thirty-nine other Tier I ORAs lack usable source pointers/hashes.
- No art, ORA, runtime, test, or app/UI was changed or used. No tests were run and no remote read/write/upload is claimed. Full evidence: `docs/ORA_PROVENANCE_AUDIT_2026-10-26.md`.

## BT-01 local balance simulator and confirmed-reset hardening — focused verification passed — 2026-10-26 America/Chicago

- The analysis-only simulator continues to read local prototype profiles and emit the configured CSV, Markdown, and JSON reports. It now requires caller-selected `--safe-output-root` and `--output-dir`; resolved output paths must remain within the selected root (including symlink/junction resolution) and outside protected project data, script, test, save, and cache directories. Metadata records the resolved root and output path.
- Integer fields accept JSON integers and finite integral JSON numbers such as `3.0`; fractional values and booleans are rejected. Integer-valued candidate overrides are normalized to integers.
- Confirmed Reset Save now preserves unsupported or invalid `.bak`/`.bak.prev` bytes in adjacent files named with their SHA-256 digest, verifies exact bytes/hash before active-sidecar removal, and only removes them after the new primary validates. A verified hash-named primary snapshot supports rollback; if rollback itself cannot finish, recovery copies remain on disk. Ordinary saves continue to block while unsupported active sidecars remain.
- Added Python regressions for numeric parsing, candidate overrides, safe-root containment, and report generation. Focused run: `python tests/run_python_tests.py --pattern test_balance_simulator.py -v` — **10 passed**, with preflight passing. Added scoped Godot memory-file regressions for confirmed reset, quarantine byte/hash verification, quarantine-copy/removal failures, rollback, and ordinary-save recovery. Test Lane ran the focused Godot 4.7.2 headless command with `--confirmed-reset-regression-only`; it exited **0** and reported all focused confirmed-reset/save-protection regressions passed.
- No game/runtime profile, save, or art asset was intentionally changed. Simulator test reports were disposable and removed. No Notion/Drive remote write or readback occurred; local staging and grouped remote reconciliation are recorded in `docs/REMOTE_SYNC_QUEUE.md`.

## I-03b earlier SPARK/ECHO body air-lane direction — historical; superseded — 2026-10-26 America/Chicago

- This interim answer assigned the separate spatial lane to SPARK and ECHO bodies. The user's later clarification superseded it: bodies stay grounded; SPARK drone attachments and ECHO decoy attachments use a separate spatial air lane. See the current I-03b entry below and `docs/I-03B_SPATIAL_MOVEMENT_DECISION_BRIEF.md`.
- This historical direction did not authorize implementation. No runtime, character data, test, art, or asset changed.

## C-02k CIPHER 09B source-manifest provenance check — unresolved; local evidence only — 2026-10-26

- Read only the embedded `edit_workspace_manifest.json` pointer/hash in the four 09B ORAs, the current neighboring candidate manifest hash, and approved local source-index fingerprints. The ORAs point to candidate directory `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/` and declare `source_candidate_manifest_sha256=43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3`. The current `parts_manifest.json` hashes to `d717fb49e45c4de79e88f50cf4f406ee343583e354fcf50f05bf2019d707ea16`.
- All four ORAs are byte-identical at SHA-256 `a54597c5a486b881cc201cc0ae063fb017f0d26331149f3b3829513dfa91b2b8`. The approved CIPHER concept/anatomy source hashes still match the local source index, but that index cannot recover the earlier candidate manifest. Its exact bytes/version record tied to the ORA are needed; no earlier copy is available locally. Keep provenance unresolved and all art quarantined.
- No files were changed by the read-only provenance check. No ORA, candidate manifest, art, runtime, or test file was changed; no app was launched and no tests were run. Full evidence and limits: `docs/ORA_PROVENANCE_AUDIT_2026-10-26.md`.

## R-01 retention/cyberware research — candidate only — 2026-10-26 America/Chicago

- Refreshed the recommendation against official Endless Frontier and Endless Frontier 2 store listings, CD PROJEKT RED's official Update 2.0 cyberware/build-planner articles, and two idle-game research sources. Recommendations are: clearer offline-return feedback; a later non-timed deterministic District Operations loop; capacity-limited cyberware choices with impactful playstyle trade-offs; and making the approved SPARK/ECHO air lane readable. Only the return-feedback UX is proposed as near-term; the remaining feature changes stay unapproved post-1.0 candidates.
- Cyberware effects/capacity, operation and boss rules, rewards, balance, and release milestone are unresolved. Research catalog deferral remains intact; no runtime behavior or canon changed.
- C-02d remains the existing CIPHER 09B knee sweep. Research contributes only a non-blocking target-scale readability observation and does not change review gates or candidate status.
- No code, runtime data, tests, art, assets, or save files changed. No validation was run. See `docs/RETENTION_AND_CYBERWARE_MILESTONE_RESEARCH_2026-10-26.md` and `docs/REMOTE_SYNC_QUEUE.md`.

## C-02j ECHO and IRONCLAD artist-input consolidation — complete; local only — 2026-10-26 America/Chicago

- Consolidated the completed read-only source reviews into the existing Tier I artist-input packet and handoff matrix. ECHO’s view-by-view sphere depictions vary (concept: 2/3/2; anatomy: 2/1/2), with two unlabeled isolated callouts; the cropped device trial was discarded and no semantically isolated candidate remains. Device identity/count/relationship, orientation, tether route/owners/sockets, and pivots remain unresolved.
- IRONCLAD’s visible cable ends disappear into or are obscured by the back unit depending on view; the square ends of its existing 781-pixel cutout are crop boundaries, not anchors. The heavy rotary weapon is shown held two-handed; the rear-view omission does not show a stowed state. No detached authored weapon candidate or source-backed grip/pivot coordinates were found.
- All work remains quarantine/reference-only. No art, ORA, candidate, runtime, or test files changed; no Godot/Krita/foreground application was launched and no tests were run. No new canonical source access occurred. The updated local staging copies and remote-sync status are recorded in `docs/REMOTE_SYNC_QUEUE.md`.

## I-01c trial price disclosure — headless regression validated; viewport review pending — 2026-10-26 America/Chicago

- Recruitment detail rows now show each recruit's configured **TRIAL PRICE** from `PrototypeRecruitmentService.evaluate_recruitment()`, including unaffordable Epic entries. Existing action button labels and purchase behavior remain unchanged.
- The main HUD identifies the BREAKER x1 and x10 costs as trial costs. x1 and full x10 totals are calculated through the existing `CombatDirector.upgrade_cost()` service at the current level; the HUD actions remain `Upgrade x1` and `Upgrade x10` in their existing order.
- The disabled unaffordable recruitment action now formats its service-derived unmet cost directly as `NEED <cost> CREDITS`, matching the configured Epic price disclosure. Affordable Common/Rare labels, trial context, purchase formulas, button actions/order, save paths, and combat behavior were not changed.
- **Headless validation:** Godot 4.7.2 fresh editor import **PASS** (exit 0; the known editor `Safe save failed` shutdown warning appeared); focused roster/save-migration regressions **PASS**; full `tests/test_runner.gd` suite **PASS**. The suite checks the Epic unmet-price label, button fit, and Recruitment panel bounds at 800×450 and 1280×720. Test Lane corrected only assertions/fixtures that encoded the superseded starter-priority order or omitted a source reference from the disposable copy. No production code, assets, or user saves were changed in Test Lane.
- Viewport captures and visual review of Recruitment and Upgrade labels remain deferred until after 4:30 PM America/Chicago. Exact x1/x10 displayed totals and visual legibility/bounds are not yet visually verified.

## I-03a spatial formation evidence map — complete; spatial rules remain open — 2026-10-26 America/Chicago

- Completed a read-only comparison of the 2026-10-26 Notion readbacks, approved preference contract, current `CombatDirector` movement/targeting, `main.gd` presentation, and the Undercity six-slot placeholder fixture. The evidence map is `docs/I-03A_SPATIAL_FORMATION_EVIDENCE_AUDIT.md`.
- Current preferences are validated, displayed, and persisted only. The prototype uses fixed per-slot depth and encounter-start X offsets, horizontal movement toward individual melee/ranged engagement points, and nearest-living-ally enemy targeting. No preference-driven movement, friend collision/pathfinding, regrouping, or dynamic band reformation is implemented.
- The soft-band/role meaning is source-backed; spatial geometry and movement precedence remain unspecified. No spatial runtime, data, tests, or art changed, and no tests were run for this read-only audit. Do not infer canon from provisional Undercity fixture coordinates.

## I-03b spatial-movement decision brief — partial rules approved; remaining choices pending — 2026-10-26 America/Chicago

- User-approved rules include fixed battlefield depth bands and boundaries; enemy-relative distance; ordered same-band positions in founding-roster order; local avoidance and authored-obstacle route/wait; role-to-attack-start mapping; temporary departure from a preferred band to enter role attack range followed by regrouping; and finishing the current attack/ability before regrouping.
- Exact contact/ranged thresholds and same-band offsets are intentionally deferred until after layout testing; no values are selected now. Evaluating distance against the enemy's current position as it moves and preserving existing attack range when no role is selected remain implementation interpretations/conservative fallback, not approved numeric rules.
- User-selected tuning sequence: exact contact/ranged thresholds, same-band offsets, and boundary dimensions/coordinates will be tuned after layout testing; no values are selected now. One shared fixed boundary shape applies to every encounter.
- Latest spatial decisions: compress ordered spacing first, then temporarily relax the preferred band if the ordered layout still does not fit; after target changes, regroup only when enemies pose no threat and finish the current action first; defeated recruits stop moving. All recruit bodies remain grounded. SPARK drone attachments and ECHO decoy attachments use a separate spatial height/air lane, not presentation-only hover. ECHO's drone/decoy mapping, attachment activation, lane geometry/transitions/collision/pathing/band interaction/targeting and attack effects, overlap/passing, and the operational “no threat” condition remain open. No other recruit/attachment has an air-lane exception.
- `docs/I-03B_SPATIAL_MOVEMENT_DECISION_BRIEF.md` contains the current bounded contract. Earlier body-lane and presentation-hover decisions are retained only as superseded history in the local decision log.
- No runtime, data, test, or art changes occurred; no tests were run. Spatial behavior stays deferred until the remaining contract is approved.

## I-03c spatial follow-up — manager-selected provisional rules — documentation only — 2026-10-26

- Under the user's prior authorization to select supported recommendations, the manager selected temporary passing only to route around authored obstacles or satisfy the approved role attack-range override, preserving founding-roster order as destination order; a no-threat regroup predicate requiring no living enemy target and no unresolved committed enemy attack/effect against the recruit; and permission for a disposable geometry-only layout harness with a strict bounded scope.
- Harness scope: representative positions, bands, authored obstacles, and the shared fixed boundary only; disposable and isolated from production scenes/combat simulation; no targeting, attacks, threat evaluation, balance, ECHO mapping, or numeric threshold work. No harness has been created or run.
- These are manager-selected provisional directions, distinct from earlier owner-selected rules and pending canonical reconciliation. Exact contact/ranged thresholds, offsets, and boundary dimensions/coordinates remain deferred until layout evidence. ECHO identity mapping and air-lane/source gates remain open.
- No spatial runtime, data, art, test, or harness was changed or validated. No tests were run; no implementation or validation claim is made. See `docs/I-03B_SPATIAL_MOVEMENT_DECISION_BRIEF.md` and `docs/REMOTE_SYNC_QUEUE.md`.
## I-07a named-boss source-gap audit — complete; content decisions remain open — 2026-10-26 America/Chicago

- Read-only audit completed in `docs/I-07A_BOSS_SOURCE_GAP_AUDIT.md` using the locally cached Notion readbacks, migration records, project data, and recovered concept package. Cached source retrieval timestamps and unverified fetch status remain documented in `docs/MIGRATION_REPORT.md`; this task did not make a new remote Notion or Drive read.
- The five approved concept names are Patchwork (replacing Nacre), Ghostlight, Chainbreak, Civic Warden, and Sable Venn. One named boss per district and endpoint placement as a pacing-test baseline are recorded, but no identity is assigned to a district.
- The source guarantees recruitability on first defeat and permanent generator exclusion after recruitment. Immediate grant versus separate recruit action, pre-recruit replay/exclusion timing, encounter rules, boss-specific credits, profiles, and boss visual assets remain unspecified.
- Existing boss-ID event transport and first-clear Evolution Data accounting are hooks/prototype progression only. No boss profile/spawn/recruitment feature exists. No runtime/data/test/art/save changes or tests occurred in this audit.
- I-07a is complete as a source-gap audit. I-07 implementation remains waiting on the listed user/source decisions. Its concise text summary was appended to the live Notion Production Roadmap and confirmed by fetch readback; the page remains marked `verification.state=unverified`. Drive tools are unavailable, so no Drive read/upload/readback is claimed.

## I-07b named-boss decision packet — ready for owner review; no boss canon added — 2026-10-26 America/Chicago

- Created `docs/I-07B_NAMED_BOSS_DECISION_PACKET.md` from the I-07a audit and cached source evidence. It presents the five approved identities for unassigned district mapping, preserves endpoint placement as a pacing-test baseline, and bounds the first-defeat recruitment and pre-recruit replay choices without inventing bosses or mechanics.
- Records remaining profile fields, reward limits, and the local named-art gap. Source fetches remain cached/unverified; there was no fresh remote read. This is a local decision aid, not a new canonical boss specification.
- No code, data, tests, art, or saves changed; no tests were run. No Notion/Drive write or upload occurred. Refresh staging copies and reconcile after owner review; see `docs/REMOTE_SYNC_QUEUE.md`.

## I-09b endless progression decision packet — ready for owner review; no endless rules added — 2026-10-26 America/Chicago

- Created `docs/I-09B_ENDLESS_PROGRESSION_DECISION_PACKET.md` from the existing endless source/runtime audit and qualitative options. Wave 126 remains the approved endless start; runtime and save validation remain capped at 125.
- Presents neutral option families and trade-offs for enemy scaling, encounter composition, post-125 boss cadence, rewards/materials, offline holding-wave claims, high-wave ceiling/overflow, save compatibility, and first-clear/retreat/Reboot semantics. It does not choose formulas, numeric values, schedules, pools, or migration mappings.
- Existing offline constraints are recorded as already approved: saved holding-wave reward basis, credit-only, no offline wave advancement, save-on-claim, with an eight-hour cap as the current target. The above-125 reward input remains unresolved pending an endless reward profile.
- No runtime, data, tests, art, or saves changed; no tests were run because the work is documentation-only. No remote read/write/upload/readback was performed. Local staging copies are refreshed and recorded in `docs/REMOTE_SYNC_QUEUE.md`.

## C-02d CIPHER 09B bounded angle sweep — capture rendered; art review pending — 2026-10-26 America/Chicago

- Godot 4.7.2 Compatibility renderer capture **PASS** (exit 0): `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHT_MAP_ANGLE_SWEEP_GODOT_08_QUARANTINED.png`, 1640×500. It shows -20°, -10°, 0°, +10°, and +20° using the existing four quarantined export parts, the approved `[770,665]` knee pivot, and the 44 px test half-band. No underpaint is drawn. The hip anchor and weights are test estimates; angle values are illustrative, not approved motion limits.
- Visual inspection confirms a rendered knee-bend sweep, but visible seam-edge distortion at the extreme poses remains ambiguous against mesh folds/texture shear. This is a diagnostic prompt for art review, not a deformation pass. The dedicated SubViewport in the capture helper avoids the project's fixed 1280×720 root viewport; no project window setting changed.
- Godot logged the existing unwritable `user://logs/godot.log` and shader-cache warnings; neither prevented the Compatibility render or PNG save. The capture is a real display-renderer result, not a headless dummy render.
- The 09B ORA's embedded source-manifest hash (`43c735…`) still differs from the current manifest (`d717fb…`); earlier manifest bytes remain unavailable. The selected export is reproducible from the disposable ORA but is not proof of a Krita save/reopen. Source provenance and Krita round-trip remain unresolved; full-rig and continuous-motion behavior are unverified. Candidate remains quarantined; no source/approved art or runtime asset changed and no candidate was promoted.

## I-02c roster lifecycle and I-01b preference controls — headless regression validated; viewport validation pending — 2026-10-26 America/Chicago

- Added ownership-validated six-slot lineup state with vacant slots, first-open-slot recruitment, reserve behavior when full, between-encounter lineup editing, and queued recruitment deployment while combat is running. The user has now superseded the earlier starter-priority default: new/no-lineup profiles auto-fill up to six currently owned recruits in stable founding-roster order; slots remain vacant only when fewer than six are owned and excess recruits stay in reserve.
- Added identity-keyed run HP for all owned recruits. Supported v1 save migration maps only the source-defined first slot to BREAKER and preserves the other five positional values as legacy data; other owned recruits receive full HP where no identity HP existed. Migration uses SaveService's staged/verified write path. Unsupported versions and recovery-only loads remain protected.
- System Reboot now heals every owned recruit, including reserves, while preserving the active lineup and permanent preferences. Formation UI stores per-recruit Front/Middle/Rear and Vanguard/Assault/Support/Control choices; these are persisted only and do not affect combat movement or targeting.
- Corrected the HUD's HP label to show the actual field lead identity and its max HP, including when BREAKER is in reserve. Reboot confirmation now has an explicit wrapped layout; visual bounds are being rechecked by Test Lane after its first capture exposed clipping.
- **Test Lane validation:** fresh Godot 4.7.2 import **PASS** (exit 0), focused roster/save-migration suite **PASS**, full headless Godot suite **PASS** (exit 0). The updated checks cover canonical default order, vacancies below six, reserves above six, purchase during combat saving and queueing for the next encounter, and deployment only at that boundary. Test Lane also corrected the live attack fixture to select VECTOR by recruit identity after the roster order changed. No production code, assets, or real user saves were changed. Viewport recapture/visual review remains after 4:30 PM America/Chicago. T-03a Save Hardening remains separate.
- `docs/DESIGN_DECISIONS.md`, `docs/OPEN_QUESTIONS.md`, `docs/MIGRATION_REPORT.md`, `docs/ASSET_MANIFEST.md`, and `docs/REMOTE_SYNC_QUEUE.md` record status and deferred canonical reconciliation. The local directory is not a Git repository, so no commit was made.

## Recovery-load warning and save-set protection — implementation updated; broad regressions pass — 2026-10-26 UTC

- `scripts/main.gd` now surfaces the existing SaveService recovery warning when Load restores `.bak` or `.bak.prev`.
- If offline-claim processing would require a save during a recovery load, it is deferred. The loaded recovery state is applied without invoking SaveService, so Load itself does not rewrite the damaged or missing primary or rotate recovery copies. The UI reports that the automatic offline claim was deferred.
- Confirmed Reset Save remains connected to its existing confirmation dialog and explicit confirmed-reset SaveService call.
- **Validation run after this implementation:** `python tests/run_python_tests.py` project-local write preflight passed, and the 108-test suite passed after setting the child test process `TEMP`/`TMP` to the writable project `tests/` directory. Godot 4.7.2 `tests/test_runner.gd` passed headless with isolated `APPDATA`; it printed `All Neon Requiem prototype tests passed.` No GUI window was opened.
- The default Windows temp location produced ACL write errors after the runner's project-local preflight passed; this was an environment issue. The approved project-local temp rerun passed 108/108.
- The full Godot suite verifies SaveService recovery ordering and ordinary offline-load behavior, but it does not yet assert the new `main.gd` recovery-load warning/deferral branch using a recovered `.bak` or `.bak.prev`. That focused integration test remains outstanding. No user save was inspected or modified.

## I-13 connector/access audit — read-only — 2026-10-26 UTC

- Connector availability: no Google Drive file/folder tools and no general GitHub repository-read tool are exposed in this session. A GitHub pull-request diagnostics tool is present, but it requires an identified pull request and does not provide repository metadata or top-level file browsing.
- Public web availability: the web search/open tool is available, but it could not read the exact repository URL, https://github.com/nikkosbynum-art/neon-requim. The URL open returned “Cache miss”; the exact repository API URL was not accessible; an exact site-restricted search did not return the requested repository.
- Result: the named repository’s existence/access status, metadata, and top-level files are unverified. These errors do not establish that the repo is private or absent. No similarly named repository was substituted. No clone, file change, push, permission change, Drive folder lookup, upload, or remote write occurred.
- Keep the Drive/GitHub source-connection milestone blocked on service access. Local labeled staging folders are not evidence of remote Drive contents. No code, tests, runtime, or data changed in this audit.

## Save preservation and explicit reset — policy approved and regression validated — 2026-10-26 UTC

- Ordinary Save blocks unsupported/newer or malformed schema metadata and save sets with no valid primary or recovery copy. The explicit Reset Save confirmation is the only replacement path for these protected files; cancel leaves them unchanged.
- Load recovery precedence is primary → `.bak` → `.bak.prev`; a recovery load returns a warning and does not rewrite the primary. Temporary files are not recovery candidates.
- Unknown fields, including nested fields, survive supported load/update/save operations. The known version-1 roster save shape now has a version-2 migration; other historical schemas remain unsupported. Focused validation of this migration is pending Test Lane.
- The implementation, reset confirmation wiring, and transactional failure paths are covered by the SaveService regressions in `tests/test_runner.gd`. Test Lane recorded the isolated Godot 4.7.2 full suite passing, including preservation, recovery, confirmed reset, and rollback assertions. See `docs/MIGRATION_REPORT.md` for the detailed evidence.
- This documents existing implementation and validation; no save code or user save was changed in this documentation update.
- **Remote documentation status:** the policy and verified implementation summary were published to the live Notion Decision Log and Production Roadmap and confirmed by fetch readback on 2026-10-26. Drive file tools are unavailable in this session; no Drive folder readback or upload is claimed. Local Drive/Notion directories remain staging only.

## Research branch source reconciliation — no catalog changes — 2026-10-25 America/Chicago

- Live canonical Notion pages and workspace search confirm the four approved branch names, spendable-Influence purchase currency, and persistence across Reboot. The 1.0 decision explicitly defers node definitions until combat/economy testing.
- No source-backed node IDs/names, costs, rank caps, gameplay effects, prerequisites, or branch/node unlock criteria were found for any branch. The offline handoff is a reconstructed high-level brief and adds no missing definitions.
- `research_catalog.json` remains four empty branch arrays and the Research panel remains read-only. No gameplay, code, or data changed; no tests were run for this documentation/source audit.

## I-10b research catalog decision packet — ready for later owner review; catalog remains deferred — 2026-10-26 America/Chicago

- Created `docs/I-10B_RESEARCH_CATALOG_DECISION_PACKET.md` from the recorded canonical source reconciliation and current approved branch/persistence rules. It presents only generic structural choices and a blank worksheet; it does not define node identities, effects, costs, caps, prerequisites, or unlocks.
- Preserves the user's existing selection to defer node definitions until combat/economy playtests. The four branch arrays remain empty and the Research UI remains read-only. Purchased research and both Influence balances persist through Reboot; automatic combat remains automatic with no manual ability/target controls.
- Exposes the unresolved node identity/order, rank/cap, full effect contract and activation timing, spendable Influence cost structure, prerequisites, unlock criteria, and integration with automatic combat. No system or implementation decision is added by this packet.
- No runtime, data, test, art, or save files changed; no tests were run. No remote source read/write/upload/readback was performed. Local staging copies are refreshed and queued in `docs/REMOTE_SYNC_QUEUE.md`.

## BREAKER run-level purchase audit — implemented and validated in isolation — 2026-10-26

- Reconciled the prototype cost with the user-approved moderate playtest candidate in the live Notion Decision Log: base 20 credits and 1.12 growth per level. This remains trial balance, not release balance.
- BREAKER's x1 and x10 path now computes a candidate purchase, persists its credits, level, HP and run snapshot before applying the purchase to live state, and blocks a purchase when an existing save has not been loaded. Save failure leaves the live run unchanged. The resulting attack power retains the current lifetime Influence bonus.
- Exact-cost affordability remains inclusive (`credits >= next cost`); each purchased level deducts its normal cost. The economy still has no level cap because the canonical design leaves caps undecided. Other eleven recruits do not yet have level-purchase paths.
- **Validation (Test Lane):** Python **105/105 PASS**. Godot 4.7.2 isolated import/Windows GUI launch/full headless regression and separate-process x1 purchase save readback **PASS**; normal user save unchanged. Regression covers x1 exact/one-short cost, x10 costs `[20, 22, 25, 28, 31, 35, 39, 44, 50, 55]` (349 total), exact and 348-credit prefix budgets, missing-field default, failed-save rollback, unloaded-save protection, post-purchase HP and Influence bonus, and fresh-process persistence. Existing Reboot tests cover resetting run credits/levels while preserving permanent state.
- **Source reconciliation:** live Notion Decision Log and Game Design & Progression were fetched read-only. The Decision Log contains the approved trial candidate; the design page continues to leave final costs and caps open. Notion fetch responses report `verification.state: unverified`. No remote write or Drive upload occurred.

## Tier I quarantined part candidate audit — review complete, source-input blockers remain — 2026-10-25/26

- Completed a read-only roster audit of the existing independently reviewable Tier I isolated-part candidates. The scoped CIPHER 09B knee-guard boundary and hinge pivot pass their user-approved review; this does not clear remaining CIPHER parts, deformation, editable-app round-trip, or production readiness.
- Recorded partial/rejected evidence for BULWARK's front-only helmet marking, BREAKER's inferred shell-off underarm, SPARK's static front-view drones, SPECTER's incomplete visible sword/grip, IRONCLAD's endpoint-hidden cable, DEADLOCK's semantically contaminated antenna mask, and VECTOR's trouser-contaminated knee mask. Exact missing inputs and evidence are in `docs/TIER_I_QUARANTINED_PART_AUDIT_01.md` and `docs/ARTIST_HANDOFF_MATRIX_T1_01.md`.
- **Disposition:** no candidate art or runtime scene was edited or promoted. Exact RGB correspondence did not count as semantic approval. The audit stops where new artist/source input is needed; no further mask subdivision or hidden-surface invention is justified by current references.
- **Validation/access:** read-only image, manifest, and source-pixel review only; no automated tests were run. The live BREAKER Notion fetch was returned with `verification.state: unverified`. No remote write, upload, or readback occurred. Local staging copies were refreshed and SHA-256 compared.

## Evolution panel responsive layout correction — implemented and visually/regression validated — 2026-10-25 America/Chicago

- Reworked each of the twelve roster entries into a two-line row, increasing recruit, gate, and action text sizes for the 800×450 display after canvas scaling. The full `RECORD <TIER>` action remains visible in the row heading.
- Expanded the centered panel to 92% of the logical viewport width and 90% of its height, disabled horizontal scrolling, and kept vertical scrolling available for the full roster.
- Existing roster IDs, prototype wave/material gates, eligibility state, save-before-apply purchase transaction, and the note that tier records do not add stats or art effects are unchanged.
- **Validation:** Test Lane's Godot regression verifies action text width, no horizontal overflow, minimum 12-pixel effective progress text at 800×450, and retained vertical navigation at 800×450 and 1280×720. It also rechecked all twelve purchases, save readback, and locked-state immutability. Full Godot 4.7.2 headless suite **PASS** (`All Neon Requiem prototype tests passed.`); 120-frame headless launch **PASS** (exit 0); Compatibility-renderer visual captures **PASS** at 800×450 and 1280×720. The reviewed 800×450 ready, scroll-bottom, and locked captures show readable rows, full action labels, no horizontal scrollbar, and a visible Close control. Captures: `docs/visual_qa/evolution_roster_ready_800x450_02.png`, `evolution_roster_ready_scroll_bottom_800x450_02.png`, `evolution_roster_locked_800x450_02.png`, `evolution_roster_ready_1280x720_02.png`, and `evolution_roster_locked_1280x720_02.png`. Known nonfatal Godot `user://` log/shader-cache write warnings and the informational quarantined-art `LIMIT` diagnostic remain. Python tests were not run.
- **Local staging refresh:** the four source docs had matched both labeled staging folders by SHA-256 before the follow-up source-note edits. Later normal copy attempts were denied for updated documents. The current source versions of `DESIGN_DECISIONS.md`, `IMPLEMENTATION_STATUS.md`, `ASSET_MANIFEST.md`, `MIGRATION_REPORT.md`, and `REMOTE_SYNC_QUEUE.md` do not match their copies in `Notion/Project Docs/` or `Google Drive/07 - Notion Exports/`. No remote Notion or Drive update occurred.

## Deterministic founding-recruit purchase slice — implemented and validated in isolation — 2026-10-26 UTC

- Added a source-backed catalog for the twelve founding recruit IDs, factions, roles, and rarities, plus a prototype profile with the live Notion-approved playtest setup: 600 starting credits, VECTOR/SPARK/RECOIL as starters, all twelve available from the start, and trial prices of 300/600/1,200 credits by Common/Rare/Epic rarity.
- Added `PrototypeRecruitmentService` with fail-closed roster/profile validation, one-copy ownership, affordability checks, immutable candidate state, and permanent ownership plus run-credit deduction in one transaction.
- Added a responsive RECRUITS panel. Eligible purchases save permanent unlocks and the current run through SaveService before applying the new ownership and credit balance. Load adds any missing approved starter recruits to legacy saves without adding credits; reboot preserves permanent unlocks while resetting run credits under the existing rule.
- Combat deployment, squad selection, named-boss recruitment, character-specific combat definitions, abilities, and production art are not implemented by this slice. The code-drawn combat roster remains a placeholder.
- **Validation:** Test Lane's Godot 4.7.2 isolated import **PASS**, 120-frame Windows GUI launch **PASS**, full headless regression suite **PASS** (`All Neon Requiem prototype tests passed.`), and separate-process persistence probe **PASS** for permanent progression, current run, squad HP, and settings. Recruitment coverage verifies all twelve IDs and rarity prices, 600-credit starters, exact/insufficient affordability, duplicate rejection, failed-save no-mutation, purchase save/reload, legacy starter normalization without credit grants, and ownership preservation through Reboot. The normal user save remained unchanged.
- Recruitment UI captures at 800×450 and 1280×720 were reviewed. The apparent 800×450 overflow came from comparing the 1280×720 logical canvas rectangle to physical window dimensions; the project scales canvas items. The corrected regression accounts for canvas stretching, and both captures show the panel within the window with a vertical scrollbar. Captures are in the isolated QA workspace under `C:\Users\Work\.codex\visualizations\2026\10\25\01a17426-0ad4-7a31-b700-1190fce1cb5c\Recruitment_Layout_Captures_468dc43a8b61438088adb778c813c338`.
- `python tests/run_python_tests.py` passed **105/105** after setting `TEMP` and `TMP` to an approved writable workspace. An earlier run inherited a restricted Windows temporary directory and errored on fixture creation; that environment failure was not treated as a code regression.
- **Staging:** normal copies of the updated `IMPLEMENTATION_STATUS.md`, `ASSET_MANIFEST.md`, `MIGRATION_REPORT.md`, and `REMOTE_SYNC_QUEUE.md` were denied in both `Notion/Project Docs/` and `Google Drive/07 - Notion Exports/`; SHA-256 checks confirm those staging files remain stale. No remote Notion/Drive update or upload was made.
- **Scope limits:** combat deployment, squad selection, named-boss recruitment details, character-specific combat definitions, abilities, and production character art remain outside this slice. No local source-project Godot import is claimed; validation used a disposable isolated copy.

## Save preservation and explicit reset — regression validated — 2026-10-26 UTC

- Regression coverage now verifies ordinary Save protects unsupported-schema and fully corrupt save sets, confirmed Reset Save is the only replacement path, valid recovery precedence is primary → `.bak` → `.bak.prev`, and nested unknown fields survive ordinary updates.
- The live UI connects `ConfirmationDialog.confirmed` to `_perform_confirmed_save_reset`; cancel does not invoke replacement. Ordinary Save calls the guarded `save_game` API. The isolated Godot 4.7.2 full suite passed these checks. Production save service and main-scene behavior were not changed for this test-only addition.

## Roster-wide evolution progression UI — implemented and regression-tested — 2026-10-25 America/Chicago

- Replaced the BREAKER-only evolution action with a roster panel containing one row for each of the twelve approved founding recruits. Each row shows its current and next tier, the shared Evolution Data balance and permanent highest cleared wave, and the configured gate. Purchase actions remain disabled until the existing profile gate is met.
- Each eligible row uses the existing `PrototypeEvolutionService` transaction and SaveService save-before-apply path. The established `breaker_tier` key is preserved; other recruits use their existing per-recruit key format. Prototype evolution still records a tier only; no tier stat/trait effects or higher-tier art are applied.
- **Initial validation:** Test Lane added Godot regression coverage for all twelve rows, per-recruit Combat Grade purchases and unique saved keys, one shared-data deduction per recruit, saved-state readback, no live/save mutation on an ineligible request, the 800×450 physical panel bounds after canvas stretch, and unchanged read-only Research behavior. Godot 4.7.2 headless regression suite **PASS** (exit 0; `All Neon Requiem prototype tests passed.`); 120-frame headless main-scene launch **PASS** (exit 0). Both runs emitted the known nonfatal `user://logs/godot.log` warning; the suite also printed an informational quarantined-art `LIMIT` diagnostic. Subsequent visual review found clipped action text, an intersecting horizontal scrollbar, and unreadable small text at 800×450; the correction and recheck are recorded above. Python tests were not run.
- No character art or balance values changed. Release balance remains provisional.

## Fail-closed research catalog validation — implemented — 2026-10-26 UTC

- Added `PrototypeResearchService.validate_catalog()` and made research purchase lookup validate the complete catalog before finding a node. It rejects malformed object/branch/node/list shapes, missing or malformed node fields, non-canonical or duplicate branch/node IDs, non-positive/non-integral costs and rank caps, malformed/self/duplicate prerequisite IDs, references to unconfigured nodes, and prerequisite cycles. Validation follows the existing service contract; it adds no effect schema or gameplay rule.
- The approved four-branch catalog remains empty and validates structurally. Purchases remain unavailable without configured nodes, and the Research dialog remains read-only. Regression fixtures exercise valid acyclic references and invalid catalog cases.
- **Validation:** Godot 4.7.2 headless regression runner **PASS** (exit 0; `All Neon Requiem prototype tests passed.`); 120-frame headless main-scene launch **PASS** (exit 0), rerun by the Test Lane. Both Godot runs emitted the known nonfatal `user://logs/godot.log` write warning. Expected quarantined-art preflight `LIMIT` diagnostics remain informational. Python tests were not run; no art or gameplay effects changed.
- No Git repository metadata was available in the selected project folder. No remote Notion/Drive operation was performed; local sync staging is refreshed and a text-only reconciliation is queued.

## Ability-event transport hook for attachments — code complete, behavior remains future work — 2026-10-26 UTC

- Added `CombatDirector._emit_ability_resolved()` as an event-only hook for a future authoritative ability implementation to call after its effect commits. It validates the source identity/side and ability ID, shares the attack event sequence, supports targetless abilities without inventing a target, and emits through the existing deep-copy presentation signal.
- Extended the Godot test runner to check interleaved attack/ability ordering, targetless payload shape, malformed-event rejection without consuming a sequence, and preservation of combat state when listeners mutate their event copy.
- **Validation:** Python **105/105 PASS**; all-12 attachment/workspace audit **PASS**; Godot 4.7.2 clean editor import **PASS**; Windows GUI launch for 120 frames **PASS**; full Godot headless regression in a disposable project **PASS**; separate-process save/load probe **PASS**. The normal user save was verified unchanged. A non-isolated project-root Godot invocation could not write to `user://` and was not used as final test evidence.
- No ability is activated by this hook. No character-specific abilities/equipment nodes, art, or runtime attachment scenes were added; all art remains quarantined. Live Notion was read for source reconciliation, but no remote content was changed. Google Drive/GitHub tools are not available in this session.

## SPARK Tier I drone cutout and pivot preflight — 2026-10-25 UTC — quarantined review candidate

- Visually inspected all three source-derived SPARK drone cutouts on an explicit checkerboard at native pixel scale. Their visible silhouettes are individually isolated and remain consistent with the approved turnaround; source-fidelity audit reports exact visible RGB preservation, zero pairwise mask overlap, clean alpha margins, and one PolyRig contour per drone.
- Authored provisional pivots at the visible central sensor/core for the blue, red, and amber drone units. The overlay and coordinates are recorded in `attachment_pivots_review_01.json` and `docs/visual_qa/SPARK_DRONE_CANDIDATE_01_PIVOT_REVIEW_01_QUARANTINED.png`.
- **Validation:** Godot 4.7.2 full headless project suite **PASS**, including independent three-drone mesh inputs and checks that each pivot falls on visible pixels with stable SPARK ownership/role metadata; Python regression **88/88 PASS**; all-12 rigging-prep audit **PASS**. These remain source-derived static cutouts, not animated or runtime-integrated assets; formation, flight paths, targeting, rotor animation, hidden surfaces, and final production approval remain open.
- No source pixels were modified. No gameplay behavior was added or inferred, and the other eleven characters' art status is unchanged.

## Event-driven attachment presentation receiver — 2026-10-25 UTC — locally validated

- Added `scripts/presentation/attachment_presentation_receiver.gd` as a reusable presentation-only receiver for weapons, drones, armor, and accessories. Each attachment maps named simulation event types to authored animation clips; the receiver checks monotonic sequence numbers and never changes combat outcomes, targets, or damage.
- Added a Godot regression that routes a committed attack event through `AttachmentEventRouter`, confirms only the mapped clip plays, confirms event payload values remain unchanged, rejects duplicate sequences, and confirms an event without a configured clip does not trigger arbitrary animation.
- **Validation:** Godot 4.7.2 full headless project suite **PASS**; Python regression **88/88 PASS**; all-12 rigging-prep audit **PASS**. The new receiver is not registered to production character scenes yet, because semantic part art, pivots, and per-character event mappings are still unverified. The current twelve OpenRaster files remain blank quarantined authoring prep; no art or runtime scene changed.
- No Cyberpunk franchise behavior was imported; the source-backed roster/event boundaries remain authoritative. No remote source was updated.

## Source refresh and authoring guidance reconciliation — 2026-10-25 23:34 UTC

- Read-only live Notion fetch of the Founding Recruit Roster succeeded. The returned roster confirms high-level character roles and named abilities, including SPARK's three attack drones; it does not resolve ECHO's drone/decoy mapping, DEADLOCK's weapon count/carry state, or GLITCH's depicted weapon identity. The fetched roster page reports its content as of 2026-10-24; no newer equipment-specific canonical text was returned.
- Reconciled the all-12 batch summary with the paired-reference review: SPECTER and GLITCH each retain one continuous main cape sheet, with a separate cloth part allowed only at a visible independent seam. Updated historical first-pass edit notes to point to the current reviewed workspace plan.
- All 12 current OpenRaster workspaces passed a read-only Krita open check with no repair prompts; references and canvas dimensions matched their per-character plans. No file was edited or saved. A Krita save/reopen round-trip and all semantic/art gates remain open. The initial screenshot mismatch was resolved by re-observing the returned Krita window state; Firefox was not interacted with.
- **Validation:** focused workspace/exporter regression PASS (21 tests); full Python suite PASS (88 tests); all-12 workspace/source/quarantine audit PASS; Godot 4.7.2 headless regression PASS; headless editor import/scan PASS (exit 0); Krita read-only open check PASS for 12/12. Editor import logged a TLS handshake warning during startup, but completed the file scan and reimport. No art pixels, workspace archives, runtime scenes, or source assets changed.

## Paired-reference attachment review and targeted workspace revision — 2026-10-25 UTC — locally validated

- Visually compared the approved concept and anatomy references for all 12 characters with the current attachment plan. This was file-based source review, not a Krita workspace round-trip or a production-art review.
- **Historical authoring status (2026-10-25; superseded where noted by local owner decisions dated 2026-10-26):** Refined seven workspaces in a no-overwrite version-02 batch: CIPHER (separates head optic from rifle scope), SPARK (wrench-like tool), SPECTER and GLITCH (continuous torn cape sheets), IRONCLAD (no assumed stow point), STITCH (visible vial only), DEADLOCK (weapon count/carry ambiguity remains open), and GLITCH (weapon identity conflict remains open). Later local decisions resolve IRONCLAD's back-stowed direction and GLITCH's one-rifle/two-carry-state identity; authoring details remain open. The first 12-workspace batch and earlier edit batches remain preserved.
- Added `docs/ATTACHMENT_REFERENCE_REVIEW_12.md`; updated the per-character plan, sidecars, open questions, current workspace index, and local staging copies. No source pixels changed and no part art was generated.
- **Validation:** focused workspace/exporter regression PASS (21 tests); full Python suite PASS (88 tests); all-12 workspace/source/quarantine audit PASS; Godot 4.7.2 headless regression PASS. Current workspace files still need a Krita open/save round-trip and all semantic, pivot, deformation, attachment-behavior, and production gates.
- No remote source was read or updated, and no assets were uploaded. No local Git repository is present.

## Attachment authoring decomposition batch — 2026-10-25 UTC — locally built and validated

- Added a new no-overwrite OpenRaster workspace for each of the 12 characters under `assets/characters/<id>/tier_01_drafts/attachment_decomposition_01/`. Prior edit batches remain intact.
- Split the authoring prompts so independently moving armor plates, weapons/accessories, drone identities, cloth panels, cables, and equipment have separate layers. Rigid subparts can remain together only when the approved source supports the assembly. Layer names are still preparation guidance; they do not prove anatomy, owner, pivot, or behavior.
- Preserved the source-backed SPARK drone count of three. ECHO drone/decoy count and mapping remain unresolved; cable routes, pivots, and weapon handling are not inferred. Combat simulation remains authoritative for behavior.
- **Validation:** focused workspace/exporter tests PASS (20 tests); full Python suite PASS (87 tests); all-12 workspace/source/quarantine audit PASS; Godot 4.7.2 headless regression PASS (`tests/test_runner.gd`). All new workspaces remain blank, quarantined edit prep; Krita round-trip and art gates have not been run on this new batch. The attempted desktop capture was blocked by the Computer Use helper (`CreateForMonitor failed`), so no visual Krita check is claimed.
- No runtime behavior, character pixels, production assets, or remote sources changed. Local Notion/Drive staging copies are refreshed; no remote sync/upload is claimed.

## CIPHER candidate 09B approved-pivot regression and hinge diagnostic — 2026-10-25 UTC

- Corrected the candidate manifest summary so it distinguishes the one user-approved/authored knee-guard pivot from the other unauthored pivots. `tests/test_runner.gd` now checks the approved source point `(770, 665)`, guard-local point `(77, 115)`, and their resolved profile-crop hinge `(170, 655)`.
- Added `tests/art/capture_cipher_candidate_09b_knee_guard_motion.gd`. Godot 4.7.2 reconstructed the neutral knee-region crop with **0 / 70,000** differing pixels against the source-aligned candidate assembly and rendered neutral, -15°, and +15° diagnostic rotations around the approved pivot. Board: `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_GUARD_MOTION_07_QUARANTINED.png`.
- **Full validation PASS:** Python **86/86**; all-12 OpenRaster/reference/layer/attachment/quarantine audit **PASS**; Godot 4.7.2 full headless suite **PASS**.
- This is a rigid transform and source-alignment diagnostic only. The ±15° values are not authored action ranges. It does not verify seam quality, skinning, hidden anatomy, other pivots, the remaining eleven recruits' rigs, or production readiness. Candidate 09B remains quarantined; no source artwork pixels or runtime scenes changed.

## SPARK drone contour-mesh preflight uses the shared builder — 2026-10-25 UTC

- Replaced the direct triangulator call in `_test_spark_drone_polyrig_mesh_inputs()` with `PolyRigContourMeshBuilder.append_contour_meshes()`, the same review-only helper exercised by CIPHER candidate 07.
- Each of the three quarantined SPARK drone cutouts must now produce exactly one `Polygon2D`, retain its original RGBA texture, keep pixel-aligned UVs, and contain triangulated faces. The candidates are still reference-derived front views; this does not validate side-view art, semantics, pivots, animation, drone behavior, or runtime integration.
- **Validation:** `tools/art/validate_character_art_pipeline.ps1` passed: Python **86/86**, all-12 archive/reference/layer/attachment/quarantine audit **PASS**, and Godot 4.7.2 headless suite **PASS**.
- No image pixels, manifests, runtime scenes, or production statuses changed. All three drone candidates remain quarantined and unapproved.

## Sandbox-aware Python test entry point — implemented locally, not run — 2026-10-25 UTC

- Added `tests/run_python_tests.py` to preflight write access in the project directories used by explicit temporary-fixture tests, then invoke Python unittest discovery. When a path is blocked, it exits before running tests and labels the result `BLOCKED` as an environment permission issue.
- Updated `AGENTS.md` and `tests/README.md` to require this entry point for the full Python suite and to keep its fixture-directory list synchronized.
- The wrapper and regression suite were not run for this documentation/workflow change. No source test, game code, art, or runtime behavior changed. Local staging copies are refreshed; remote reconciliation remains queued.

## Source connector recheck — 2026-10-25 21:30 UTC

- Notion read access is now available through the direct Notion tool. Read-only fetches succeeded for Project HQ, Asset Library, Production Roadmap, Decision Log, and Backup Protocol; recent page edit timestamps range from 04:48 to 18:09 UTC.
- No Google Drive or GitHub tool is exposed in this session. No remote writes or uploads were made. The queued text updates remain local until cross-service reconciliation can be completed together.

## SPARK drone asset regression added to the main Godot suite — 2026-10-25 UTC

- Integrated the three quarantined SPARK drone image checks into `tests/test_runner.gd`; the normal Godot test command now checks unique file paths, raw RGBA readability, transparent outer corners, exactly one alpha contour per candidate, and independent PolyRig triangulation.
- Godot 4.7.2 full headless suite **PASS** after integration. The focused drone test also passed independently. Python full suite **85/85 PASS** using `python tests/run_python_tests.py`; the all-12 archive/reference/layer/quarantine audit **PASS**.
- This only makes the SPARK mesh-input check repeatable in routine testing. It does not verify artwork semantics, a side-view adaptation, pivots, animation, drone behavior, runtime attachment nodes, or production approval. No art pixels or combat code changed.

## CIPHER candidate-07 intake checks added to the main Godot suite — 2026-10-25 UTC

- `tests/test_runner.gd` now checks CIPHER candidate 07's ten manifest-mapped cutouts, declared dimensions, alpha-capable format, transparent corners, nonempty pixels, source path, mast ownership remap, 330×960 assembly, and quarantine/semantic-review flags.
- The full Godot 4.7.2 headless suite **PASS** after integration. This is raw-file and manifest integrity evidence; it does not resolve CIPHER's full semantic review, hidden/far-side anatomy, authored pivots, deformation, or animation. Candidate 07 remains quarantined and the Krita workspaces were not edited or saved.

## One-command character-art pipeline validation — 2026-10-25 UTC

- Added `tools/art/validate_character_art_pipeline.ps1` to run, in order, the preflighted full Python suite, the all-12 workspace/attachment plan audit, and the Godot headless project suite. The Godot suite includes the ten flattened visible-profile mesh preflights, CIPHER candidate-07 file/manifest checks, and SPARK drone PolyRig input checks.
- **End-to-end validation PASS:** Python **85/85**; all-12 archive/reference/layer/quarantine audit **PASS**; Godot 4.7.2 full suite **PASS**.
- This gives a repeatable structural/preflight command. It does not complete semantic art, hidden/far-side anatomy, pivots, continuous deformation, per-character attachment behavior, or production approval. Current candidates remain quarantined.

## Bounded character-art work-order helper — local addition — 2026-10-25 UTC

- Added `tools/art/build_character_work_order.py` and `docs/AI_CHARACTER_WORK_ORDERS.md` as a way to frame one character and one pipeline phase per work packet, with source pointers, current candidate status, acceptance evidence, stop rules, and no-paid-credit guidance.
- The generator uses local `rigging_prep_all_12.json` planning data; it does not fetch canonical sources, create art, establish semantic correctness, approve a rig, or run tests. Python syntax compilation, `--help`, generated CIPHER packet content, and duplicate-output refusal with unchanged-file hash **PASS**. Out-of-project path rejection was not exercised.
- This improves task framing only; no character art or rig state changed.

## PolyRig multi-island attachment constraint — verified tool behavior, no art changes — 2026-10-25 UTC

- Inspection of the installed PolyRig 0.9.3 Auto Mesh implementation found that a texture is reduced to alpha contours and only one contour is used for its generated mesh. Its selection compares contour vertex counts rather than covered pixel area. A weapon, drone, cable, cape panel, or other disconnected item can therefore be omitted or incorrectly selected if combined into one mesh input.
- Added a regression fixture proving that two disconnected components can each be triangulated as separate PolyRig inputs, and documented the one-semantic-item/per-`Polygon2D` preparation rule in the authoring guide. Godot 4.7.2 headless tests: `test_polyrig_single_contour_per_texture.gd` **PASS** (2 checks) and the existing `test_polyrig_geometry_smoke.gd` **PASS** (9 checks: triangulation, weight assignment, and seven normalized vertices).
- Validation refresh: full Python regression suite **85/85 PASS**; `python tools/art/audit_rigging_prep_all_12.py` **PASS** for the 12 current workspace archives, sidecars, source links, blank layers, and quarantine flags. These checks do not validate semantic character art or production rigs.
- This validates the split-input workaround and generic PolyRig geometry only. It does not exercise the editor Auto Mesh dialog on character art, prepare any character parts, verify equipment behavior, or approve a rig. Existing artwork and all candidate statuses remain unchanged/quarantined.
- The twelve current edit workspaces have separately passed a read-only Krita open check with no repair warnings. That check remains limited to file loading/reference visibility.

## Bounded character-art intake and gameplay-readability review — implemented locally, not validated — 2026-10-25 UTC

- Added an early stop rule for missing, clipped, duplicated, ambiguous, or unsupported semantic parts; unresolved source corrections must be recorded before rigging proceeds. Shared anchors are reusable defaults, with reference-backed character-specific exceptions.
- Added a required gameplay-camera-scale review for combined idle, movement, attack, hit, and defeat poses at 1280×720 and 800×450. The workbench's selected-joint capture now accepts reviewer-entered min/max values and a context note, writes five diagnostic samples and unverified sidecar metadata, and identifies the default ±75° range as generic. It does not establish authored action limits or pass animation review.
- Updated the authoring guide, pipeline, all-12 rigging prep, bundle checklist, and manual review instructions. No character art, production gate, runtime scene, or game behavior changed. This is a manual evidence requirement; no camera-scale capture harness was added. No validation was run for this update.
- Local Notion/Drive staging copies are refreshed. Remote source reconciliation and writes remain queued.

## Character art workflow review improvements — implemented locally, not validated — 2026-10-25 UTC

- Strengthened the standard manifest workflow with a recommended ground-pivot field (optional for backward-compatible v1 structural intake; required by the manifest preview), optional approved-reference SHA-256, and evidence records for each production gate. The validator now blocks true gates that lack a reviewer, timezone-aware review timestamp, project-confined evidence files, or matching reference hash.
- Added `tools/art/build_character_review_bundle.py` for one-command candidate review packets: named native-scale parts, static assembly, overlap/alpha diagnostics, a machine-readable report, and a manual checklist. The bundle never approves or promotes a candidate and refuses output overwrite.
- Added standard-manifest loading to the Godot rig workbench, with guarded project-local paths and 256 px measured-visible-height comparison scale, plus selected-joint captures at -75°, -40°, 0°, 40°, and 75° with review-only metadata.
- Updated the character-art pipeline and manual-review instructions. No art candidate, gate state, runtime scene, combat behavior, or production asset changed. Formal roster coverage remains 1/12 (legacy BREAKER review-only pilot); no standard manifest has been submitted.
- The first edit caused compatibility regressions by requiring `ground_pivot` on existing v1 and legacy manifests. It is now optional for structural intake while remaining required by the new rig preview. Validation was not rerun after this correction. Local staging copies are refreshed; remote reconciliation and writes remain queued.

## Twelve-character Tier I game-scale preview — 2026-10-25 UTC

## Bounded character-art intake and gameplay-readability review — implemented locally, not validated — 2026-10-25 UTC

- Added an explicit early stop rule: stop after the first native-scale semantic/ownership review when required parts are missing, clipped, duplicated, ambiguous, or unsupported by approved references; record the needed source correction and do not continue into rigging.
- Documented shared semantic anchors as reusable defaults with character-specific rig/part exceptions when the approved anatomy requires them. Added a gameplay-scale visual gate requiring actual combined idle/movement/attack/hit/defeat poses in isolated QA at 1280×720 and 800×450, checking silhouette, role/gear readability, and grounded contact.
- The workbench now supports reviewer-entered per-joint min/max values and context notes for a five-sample, single-joint neutral diagnostic. It labels the fixed default as generic; the entered range is sidecar metadata only and unverified. Actual authored pose/clip ranges and combined-action captures remain required for `animation_reviewed`.
- Updated the review-bundle checklist, authoring guide, pipeline docs, and manual test instructions. No character art or runtime scene changed. Validation has not been run for these workflow changes.

- Added a 4×3 roster preview scene at tests/art/founding_roster_gameplay_preview.tscn and rendered docs/visual_qa/FOUNDING_ROSTER_GAME_SCALE_PREVIEW_01.png.
- The preview uses ten quarantined visible-profile mesh candidates in generic idle transforms, CIPHER's quarantined cutout-rig candidate, and BREAKER's approved static profile reference. All twelve are displayed at a shared approximate gameplay scale against a neutral cyberpunk presentation backdrop.
- This is a roster lineup mockup, not the six-unit combat formation, authored production animation, complete modular art, or runtime game content. No candidate status or art gates changed.
- Godot 4.7.2 rendered and saved the image; visual inspection confirmed all twelve names and figures are present. Known non-fatal user-log and shader-cache write warnings remain. Local staging copies were refreshed; no remote sync/upload was performed.

## Concept reference sizing exception — 2026-10-25 UTC

OpenRaster metadata confirms 11 workspaces embed their concept reference as a hidden layer because it matches the anatomy canvas. BREAKER’s concept board is not embedded because its canvas differs; its sidecar and batch checklist direct the reviewer to open the referenced production board separately. The builder now generates this distinction and its focused test checks both cases.

## Twelve-character Krita review checklist — 2026-10-25 UTC

- Added `docs/ART_EDIT_BATCH_12.md`, generated from the 12 current workspace manifests, with per-character paths, canvas dimensions, sources, equipment layers, and open questions. It specifies non-destructive `.kra` save handling and semantic/rig validation gates.
- Krita executable is installed at `C:\Program Files\Krita (x64)\bin\krita.exe`. On 2026-10-25, all 12 current quarantined `.ora` workspaces were opened read-only in Krita with no repair warnings. All displayed their expected reference/canvas; BREAKER is the documented 1024×1536 profile rebuild exception, while the other 11 use 1536×1024 turnarounds. No files were edited or saved. This is application-open and reference-visibility evidence only, not semantic review, blank-layer pixel verification, art approval, or a save/reopen round trip. Anatomy completeness, part semantics, pivots, hidden surfaces, equipment behavior, deformation, and rig compatibility remain unverified.

## Combat event and attachment presentation-routing foundation — 2026-10-25 UTC

- `CombatDirector.combat_action_resolved` now emits a monotonic, structured `attack_resolved` event for ally/enemy hits after authoritative damage and hit state are committed. Payloads include source/target IDs, side, style, wave/time, damage, target HP, and defeated flag. Listeners receive a deep copy.
- Added `scripts/presentation/attachment_event_router.gd`: attachment nodes register a stable ID, owner, accepted event types, and source/target ownership field. The router rejects duplicate IDs and malformed registration, ignores malformed events, removes expired receivers, and passes a separate deep copy to each presentation receiver.
- Godot 4.7.2 headless `tests/test_runner.gd` **PASS** after adding event ordering/state-isolation and router ownership/filtering tests. The router is wired into the main scene, enforces strictly increasing event sequence numbers, routes by actor instance ID, and integration testing registers temporary receivers to confirm one resolved hit reaches only its matching instance. No character-specific weapon, drone, accessory, or ability node is registered in the runtime scene.
- No combat mechanics changed: the event is emitted after existing damage resolution. Signature abilities are not represented by events until they exist in authoritative simulation.

## Structured combat action events for attachment presentation — 2026-10-25 UTC

- Added `CombatDirector.combat_action_resolved`, emitted after ally/enemy attack damage and hit state are committed. Payloads contain a monotonic sequence, wave and simulation time, source/target IDs, source side, combat style, damage, post-hit HP, and defeat status. The signal emits a deep copy so subscribers cannot mutate authoritative combat state.
- Added a deterministic Godot regression that verifies both ally and enemy event payloads, ordering after state commit, sequence progression, and isolation from a subscriber that deliberately mutates the received event.
- Godot 4.7.2 headless `tests/test_runner.gd`: **PASS** (`All Neon Requiem prototype tests passed.`). This establishes an attack-event hook for future weapon visuals. No attachment art is connected, and signature abilities, drones, weapon-specific firing modes, and effect events remain unimplemented.
- Full Python regression suite **PASS (61 tests)**; focused OpenRaster/contract suite **PASS (7 tests)**; all-12 read-only archive/sidecar audit **PASS**.

## Twelve-character editable attachment workspaces — 2026-10-25 UTC

- Generated one no-overwrite, quarantined OpenRaster edit workspace for each founding recruit under `assets/characters/<id>/tier_01_drafts/edit_batch_01/`, plus a `README_EDIT_PREP.md` sidecar. Each contains the approved reference and blank semantic body/attachment layers. The 12 new workspace files are separate from four pre-existing CIPHER workspaces; total ORA inventory is 16.
- Added `docs/ATTACHMENT_FUNCTION_CONTRACT.md` and per-recruit contract data to `tools/art/rigging_prep_all_12.json`. Weapons/accessories/drones now have clear ownership, event-link, pose-test, and simulation-authority requirements. No attachment behavior, gameplay code, finished art, or production rig was implemented.
- SPARK’s three attack drones are source-backed; ECHO’s exact count and drone/decoy mapping remain unresolved. Details such as formations, cadence, and weapon handling remain open where the roster does not specify them. No external Cyberpunk material was used.
- **Validation:** `python tools/art/audit_rigging_prep_all_12.py` **PASS** after contract changes; focused OpenRaster/contract suite **PASS (7 tests)**; full Python regression suite **PASS (61 tests)**. All 12 generated ORAs open as valid ZIP/OpenRaster packages; each manifest matches its character and remains quarantined with no semantic parts. Krita round-trip and Godot tests with production art receivers have **NOT BEEN RUN**; generic Godot attack-event routing is headless-tested; containers have not been opened in Krita.
- Local Notion/Drive staging copies are text-only in this milestone. No remote Notion update or Google Drive upload is claimed.

## Quarantined rig review workbench — 2026-10-25 UTC

- Added tests/art/rig_review_workbench.tscn and its script as a manual Godot review surface. It adapts the ten flattened profile mesh candidates and CIPHER's quarantined cutout candidate with character/pose selection, temporary bone rotations, per-part visibility, pivot guides, approved anatomy-reference display, and a six-pose contact-sheet capture saved under user://rig_review_captures/.
- BREAKER and the other characters without an adapter remain explicitly unavailable in this workbench and must use their existing review material. Captures are labeled as review-only in sidecar metadata; the tool does not change manifests, asset status, runtime scenes, or production gates.
- Integrated launch guidance and limits into docs/CHARACTER_ART_PIPELINE.md, docs/RIGGING_PREP_ALL_12.md, and tests/README.md. Refreshed local Notion/Drive staging copies. Remote sync is queued; no remote write is claimed.
- Godot 4.7.2 headless scene launch exited with code 0. Desktop rendering was visually inspected: the BULWARK mesh candidate, ground guide, pivot guides, and workbench controls render after correcting the right panel's bottom anchor. The six-pose image export and other character adapters have not yet been exercised. Godot emitted known non-fatal user log/shader-cache write warnings; do not record this as full candidate or production-art validation.

## Twelve-recruit Tier I rigging preparation inventory — 2026-10-25 UTC

- Added `tools/art/rigging_prep_all_12.json` and `docs/RIGGING_PREP_ALL_12.md` to consolidate approved concept/anatomy sources, existing per-character candidates, special attachment requirements, shared semantic part expectations, and promotion gates for all twelve founding recruits.
- Added `tools/art/audit_rigging_prep_all_12.py` and `tests/test_rigging_prep_all_12.py`. They verify roster coverage, source and candidate paths, and that the plan does not mislabel a candidate as production-approved.
- Preserved current work: ten flattened profile-mesh preflights, CIPHER's separate cutout candidate, and BREAKER's isolated profile/arm trials. No existing art, manifests, scenes, or runtime behavior were replaced.
- Review remains **NOT PRODUCTION COMPLETE** for all twelve. Mesh preflights are flattened textures, CIPHER cutouts still have unresolved semantics/underpaint, and BREAKER's retained v20 remains quarantined. Character-specific attachments and pivots are planning notes until reviewed against source art and authored.
- Validation: `python tools/art/audit_rigging_prep_all_12.py` **PASS**; focused `python -m unittest tests.test_rigging_prep_all_12` **PASS**; full Python suite `python -m unittest discover -s tests -p 'test_*.py'` **PASS (34 tests)**. These checks validate inventory paths and gate coverage, not anatomy, artwork, or Godot rigs.
- Source-access scope: local approved references and project documentation were used. Text-only Notion updates were published and verified by readback on the Asset Library page (`2026-10-25T17:51:05.385Z`) and Production Roadmap page (`2026-10-25T17:51:08.289Z`). Google Drive upload was not performed; no binary asset was uploaded.

## Ten founding-recruit Tier I visible-profile mesh rigs — quarantined — 2026-10-25 UTC

- Completed prerequisite intake for BULWARK, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH using each approved concept and anatomy turnaround. Extracted each right-facing profile as a separate RGBA image with a 128 px transparent border; source RGB is preserved and source sheets are unchanged.
- Added one per-character `parts_manifest.json` and `rig_manifest.json` in `assets/characters/<id>/tier_01_drafts/profile_mesh_rig_candidate_01/`. Each manifest records provenance, dimensions, provisional 19-bone landmarks, the mesh/weight method, and unresolved art gates. The “pivots” are approximate landmarks inferred from flattened references, not artist-authored attachment pivots.
- Added a shared Godot `Skeleton2D`/`Polygon2D` mesh-rig candidate script and preview scene. PolyRig triangulates contours where possible; a boundary-filtered Godot Delaunay fallback handles rejected concave contours. PolyRig geodesic weights are normalized, with nearest-segment fallback for disconnected vertices. Each profile has 11 or fewer contour meshes; the tested batch contains 11 contours total and 2,937 weighted vertices.
- Godot 4.7.2 headless validation **PASS**: all ten profiles load, each has 19 bones and weighted meshes, every vertex weight row normalizes, mesh triangle coverage per contour is 0.94–1.00, every stored bone path resolves from its `Skeleton2D`, the six generic pose states are accepted, and the ground anchor stays fixed. Python image/manifest validation **PASS**: all ten inputs have clean transparent margins, preserve source RGB at sampled visible pixels, and retain quarantined status.
- Display-rendered visual QA **PASS** for capture integrity: `tests/art/capture_founding_t1_profile_mesh_rig_poses.gd` captured all 60 character/pose combinations and asserts each image contains rendered pixels and each non-neutral pose differs visually from neutral. Contact boards were reviewed; the profiles remain recognizable and the generic rotations deform the mesh. This is not approval of anatomy, joints, pivots, or animation quality; the transforms are simple pose smoke tests, not authored clips.
- These are **visible-profile mesh-rig candidates**, not complete modular production art rigs. They still need separately authored body/evolution parts, detached weapons and drones where shown, hidden/far-side anatomy, artist-authored pivots, visual review of deformed poses, and production approval. No runtime character scene uses these candidates.
- Full Python regression suite **PASS** (33 tests); focused Python profile-input audit **PASS** (1 test over all ten assets); focused Godot 4.7.2 mesh-rig harness, display-rendered capture integrity, and full prototype runner **PASS**. Godot emitted non-fatal `user://logs/godot.log` and shader-cache write warnings. No Git metadata is present in this checkout, so no commit was made.

## PolyRig feasibility check — local tooling — 2026-10-25 UTC

- Verified the Godot 4.7.2 editor loads the active PolyRig add-on from `addons/poly-rig/`. The duplicate packaged copy under `poly-rig-plugin-v0.9.3-EA/addons/poly-rig/` is retained as supplied and excluded from project scanning with a local `.gdignore`, preventing duplicate global script classes. The editor reports `[PolyRig] Plugin loaded`; its settings/log paths under the user profile remain unwritable in this restricted session, which emits non-fatal startup/save warnings.
- Added `tests/art/test_polyrig_geometry_smoke.gd`. Godot 4.7.2 headless validation **PASS**: PolyRig triangulates a body-shaped test polygon and geodesic inverse-distance weighting returns normalized weights for all seven vertices across two bones.
- Assessment: PolyRig can speed up mesh creation and initial bone weighting for already-authored continuous sprite parts. It cannot separate semantic body parts, invent concealed pixels, choose attachment pivots, or validate character anatomy. Automatic alpha mesh generation uses the largest contour, so detached drones/equipment need separately authored meshes; hard armor and limb boundaries still need manual treatment and visual seam checks. Test output is algorithmic feasibility evidence only; no character art/rig was processed or promoted with PolyRig in this check.
- Package metadata says 0.9.3 Early Access while its startup message says 0.9.2 Early Access; exact internal release identity is unresolved. Keep the add-on experimental and out of runtime code.

## CIPHER Tier I profile cutout-rig candidate 01 — quarantined — 2026-10-25 UTC

- Derived ten separate RGBA visual layers from the approved CIPHER anatomy turnaround's right-facing profile: hood/hair/face, backpack mount, jacket torso, pelvis/belt, near upper arm, forearm, hand, thigh, shin, and boot. The original sheet remains unchanged and is not referenced by the runtime scene. Each cropped part now has a 60 px transparent safety border.
- Added one hand-authored, separate rifle attachment sprite, a 15-bone `Skeleton2D` candidate, and a review-only pose sheet covering neutral, idle/walk, aim/fire, and defeat. The candidate scene stays under `tests/art/`; no production/runtime scene uses it.
- Godot 4.7.2 headless validation **PASS**: all 11 PNG layers decode and load as textures, 15 bones are present, all six pose identifiers are accepted, the ground anchor stays fixed, and transparent safety corners are present. Existing project Python tests: **32 passed**; new CIPHER cutout/manifest/silhouette tests: **5 passed**. The 10 reference-derived cutouts and separate rifle each pass the mechanical alpha/margin audit. Binary alpha comparison retains 99.4% of the isolated source silhouette with 803 missing source pixels and zero added silhouette pixels; this is a cutout check, not anatomy approval.
- Review status: the neutral profile retains the approved silhouette and proportions; the pose sheet is suitable for continued art iteration. Pivots, semantic masks, torso/backpack overlap, and rifle grip were inferred from a flattened source; far-side art is not authored; the current walk/aim poses keep elbow/knee chains mostly rigid to avoid exposing seams. Continuous joint flex, all-frame seam coverage, and production readiness remain **NOT VERIFIED**.
- This is a complete first **visible-profile art-rig candidate**, not a fully approved or runtime-ready character rig. Keep it quarantined pending semantic/pivot review and far-side/underpaint completion.

## CIPHER Tier I rig blockout — quarantined QA scene — 2026-10-25 UTC

- Added test-only `tests/art/cipher_t1_rig_blockout.gd` and `tests/art/cipher_t1_rig_blockout_preview.tscn`. The blockout has a ground root, pelvis/torso/neck chain, both arm chains, both leg chains, 15 generic polygon placeholders, and the quarantined head composite attached at the proposed neck socket.
- Added `tests/art/test_cipher_rig_blockout.gd`. Godot 4.7.2 headless validation **PASS**: 16 expected bones, 15 placeholder segments, image load, six static pose states (`neutral`, `idle`, `walk`, `aim_fire`, `hit`, `defeat`), stable ground anchor, and head pivot attachment. The separate head-only pivot smoke test also **PASS**.
- The six states are pose-transform checks, not finished animation clips. Placeholder body polygons are not character art; the head composite is still quarantined. This scene is not referenced by the runtime game.
- Two unretained torso-generation trials were reviewed and rejected: one drifted toward a three-quarter view; the other kept an unwanted raised collar and failed the margin/halo audit. No torso art was added to the project.
- CIPHER is now ready for a **rig blockout / art replacement iteration**, but not a full-body art rig. All character-specific body and weapon parts, overlap cleanup, final pivots, reference-scale assembly review, and continuous joint testing remain open. No production or runtime art gate passed.
- Text status was published to Notion Asset Library and Production Roadmap and verified by readback at `2026-10-25T16:03:12.840Z` and `2026-10-25T16:03:22.689Z`. No binary was uploaded. A Google Drive write tool is not available in this environment; Drive staging remains local only.

## CIPHER Tier I head-pivot rigging prep — 2026-10-25 UTC

- Compared the cleaned head/hood composite with the user-approved CIPHER concept and anatomy turnaround. The right-facing hood, face, long dark hair, optic, and collar cues remain legible at profile scale; the single composite still binds these elements together.
- Added `docs/CIPHER_T1_RIGGING_PREP_01.md` with a proposed bone map, inventory of missing parts, and explicit entry gates for full-body rigging. Added isolated Godot smoke test `tests/art/test_cipher_head_pivot_candidate.gd`.
- Provisional transform test uses source-canvas pivot `(760, 815)`, five angles from -0.08 to 0.08 radians, and a 110 px visible head silhouette. These are review-fit values only; final CIPHER scale and authored pivots are not approved.
- Godot 4.7.2 headless test **PASS**: RGBA import, alpha bounds `(372,141)–(1165,997)`, transparent corners, target review scale, and fixed pivot across all five rotations. The engine emitted the existing non-fatal `user://logs/godot.log` write warning.
- Full CIPHER rigging is **NOT READY**: torso/backpack, jacket/pelvis, both arms/hands, both legs/boots, and weapon attachment parts are missing; the proposed pivot remains provisional; the collar/torso seam has not been evaluated. No art entered runtime and no full-body rig was claimed.

## CIPHER head/neck alpha cleanup — quarantined review candidate — 2026-10-25 UTC

- Used Krita on a separate working copy of `CIPHER_T1_HEAD_NECK_CANDIDATE_01_QUARANTINED.png`. Original candidate SHA-256 remains `A9CF42A93B0601EFF653079DB6791D68159B6B08FD41A4F68A475AB545A7BDF9` and was not modified.
- Exported `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/cleanup_working/CIPHER_T1_HEAD_NECK_CLEANED_CANDIDATE_01_QUARANTINED.png` (RGBA, 1536×1120). Alpha levels were adjusted through a transparency mask with input black level 12; canvas height was extended by 96 px and centered. Comparison confirms zero RGB pixel changes against the original in the original canvas area.
- Mechanical alpha audit: **PASS**. At alpha threshold 32, bounds are `(372, 141)–(1165, 997)`; margins are L372/T141/R371/B123 px (all ≥10%); external low-alpha pixels beyond the 3 px edge tolerance are 0; all corners are transparent.
- This only clears the audit's alpha/margin checks. Visual anatomy, semantic neck boundary, clean part edges at animation scale, pivots, deformation, identity fidelity, and production readiness remain **NOT VERIFIED**. The asset remains **QUARANTINED**, is not in runtime, and is not approved as a production sprite part. No Godot validation applies because runtime files did not change.
- Next: inspect at intended in-game scale and against approved CIPHER references; if acceptable, author/verify the semantic boundaries and pivots before rig integration. Do not repeat for other characters without a separate review.

## CIPHER semantic head/neck part attempt — quarantined — 2026-10-25 UTC

- Added provisional semantic part plan `docs/CIPHER_T1_PART_PLAN_01.md` using the user's approved CIPHER concept and anatomy references.
- Generated one separately prompted `head_hood_hair_neck` image from those references. Visual inspection confirms the hood, face, hair, optic and collar cues are recognizable, but diffuse neon haze remains outside the physical silhouette and the thresholded art fills too much of the canvas height for the planned safety margin.
- Static inspection: PNG RGBA 1536×1024, alpha range 0–254, all four canvas corners transparent. At alpha threshold 32, one connected component has bounds `(372, 93)–(1165, 949)` and area 451,223 px. The alpha-any bounds extend to `(81, 61)–(1484, 984)` because of external haze. A targeted image edit did not remove the haze.
- Saved the best visual candidate and one numbered crop under `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/`. Extractor metadata correctly leaves it quarantined, unnamed, without pivots, and not production-approved.
- Result: identity/semantic isolation review **PARTIAL PASS**; clean silhouette/margin gate **FAIL**; part and rig production gates **NOT PASSED**. No runtime/Godot asset changed.
- Added `tools/art/audit_semantic_cutout.py`, a mechanical alpha audit for per-part PNGs. It reports alpha-threshold bounds/margins, outer-corner alpha, and low-alpha pixels beyond a 3 px silhouette dilation; it explicitly cannot approve anatomy or production art.
- Audit result on CIPHER candidate 01: **FAIL** `insufficient_transparent_margin` and `external_low_alpha_halo` (347 pixels outside edge tolerance; provisional 50-pixel limit). The audit does not modify the image.
- Revalidation: **32 Python tests passed** across the new cutout audit, atlas extractor, character-art manifest, and roster intake. The roster audit completed and explicitly reports 1/12 manifests, with all eleven non-BREAKER Tier I entries NOT SUBMITTED. Python compilation passed. No Godot import/scene run: the candidate is quarantined and no Godot project file changed.
- Next: have an artist/editor clean the external alpha and adjust canvas spacing, or produce a genuinely clean cutout before adding more parts. Do not expand this generation method to the other ten yet.

## Approved anatomy references and CIPHER part-intake pilot — 2026-10-25 UTC

- The user approved the matching anatomy turnarounds for all eleven non-BREAKER recruits as anatomy references. They guide visible anatomy/proportions; they do not establish concealed anatomy, transparent sprite parts, pivots, deformation, or production readiness.
- Tested the CIPHER Tier I modular-part workflow with two generated atlas candidates. Candidate 01 was rejected; candidate 02 alpha-segmented into 18 numbered crops, but full-size diagnostic review shows clipped, duplicate, and ambiguous limb elements. Neither atlas is acceptable semantic rig input. Both remain quarantined.
- Added `tools/art/extract_character_atlas_components.py` as a deterministic alpha-component review aid. It deliberately writes numbered, unlabeled crops and quarantine metadata; it does not infer semantics or approve assets.
- Added `docs/CHARACTER_PART_AUTHORING_GUIDE.md` and linked it from `AGENTS.md` so later Codex sessions preserve the intake lessons. The next art attempt must use a semantic part plan, complete individually reviewable assets, and explicit crop/duplication checks before rigging.
- Validation actually run: 26 Python unit tests passed across atlas extraction, character-art manifest, and roster intake suites; roster audit completed and reported missing art honestly. Python bytecode compilation passed. No Godot import/scene test ran because this milestone changed no Godot runtime assets or scenes.
- No candidate entered runtime; no production art gate passed. All eleven Tier I submissions remain **NOT SUBMITTED**. Next: revise the art-source/layout workflow for one pilot and pass semantic/visual review before extending it to the other ten.

## Approved visual references and anatomy-turnaround pass — 2026-10-25 UTC

- User approval: the individual Tier I visual direction for BULWARK, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH is approved. The source concept PNGs are the appearance references of record.
- Generated matching front/side/back anatomy turnaround drafts for all eleven from their approved concept references. Files are `docs/visual_qa/<CHARACTER>_T1_ANATOMY_TURNAROUND_01_2026-10-25.png`, 1536×1024 RGB each.
- All eleven files decode with Pillow at the expected size. This is file-integrity validation only. The user later approved the turnarounds as visible anatomy references; hidden anatomy, part boundaries, authored pivots, and animation remain unverified. They are not production assets; the approved concept remains authoritative if a turnaround drifts.
- Built three side-by-side comparison boards pairing each approved visual reference with its new turnaround. They expose likeness drift for review but do not constitute approval or automated visual validation.
- No transparent sprite parts, per-character production manifests, rigs, Godot imports, or runtime changes were made. All eleven Tier I production art submissions remain **NOT SUBMITTED**.
- Next: review/revise the anatomy turnarounds against their approved concept sheets, then author real transparent parts and pivot maps under the shared character-art gates.

## Eleven individual Tier I visual-reference milestone — 2026-10-25 UTC

- Completed matching three-view visual-development drafts for all eleven non-BREAKER founding recruits: BULWARK, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH. All source PNGs are in `docs/visual_qa/` and each is 1536×1024 RGB.
- The user approved all eleven depicted Tier I concept designs as the visual references. Their faces, proportions, clothing, palette assignments, weapon construction, cyberware placement, gear layout, and RECOIL's depicted prosthetic side are the approved visual direction. Hidden anatomy, transparent part boundaries, pivots, deformation, and production suitability remain unverified.
- Verified all eleven files decode with Pillow and have expected dimensions. No anatomy measurement, sprite separation, manifest submission, rig, Godot import, or runtime integration was performed. The eleven Tier I manifests remain **NOT SUBMITTED**.
- Next: author consistent anatomy/part-boundary source sheets from the approved references, then build and validate transparent parts and per-character rigs through the existing art gates. No gameplay tests apply to these standalone concept images.

## BULWARK Tier I individual concept sheet — 2026-10-25 UTC

- Generated a three-view visual-development proposal from BULWARK's provisional contact-sheet panel and live roster identity; saved as `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` (1536×1024 RGB).
- The user subsequently approved the depicted helmet, weapon, build, palette assignment, and equipment layout as BULWARK's Tier I visual direction; hidden anatomy and part construction remain unverified.
- Visual review confirms three full-body views are present and readable. This is concept art only; no separable parts, measured pivots, anatomy gate, manifest, Godot import, or runtime integration was produced.
- Follow-up completed 2026-10-25: matching individual sheets were created for the other ten non-BREAKER recruits; user approval of all eleven visual references is recorded at the top of this document.

## Eleven-recruit concept proposal board — 2026-10-25 UTC

- Created a single numbered 3×4 contact sheet with provisional Tier I visual proposals for the eleven non-BREAKER recruits, using only verified roster roles/abilities to seed the concepts and the local generic class/faction board for broad style guidance.
- Local review artifact: `docs/visual_qa/ROSTER_T1_CONCEPT_PROPOSAL_01_2026-10-25.png` (1448×1086 RGB). Panel mapping and generated/unapproved details are documented in `docs/CHARACTER_ART_CONCEPT_PROPOSAL_01.md`.
- This draft introduces visual choices not specified by the roster (faces, gender presentation where unspecified, exact proportions, clothing, colors, weapon/cyberware construction). It is not canon and must be reviewed before use as the basis for production art. RECOIL's arm side is not established by the source.
- Manual image review confirms the 11 numbered panels and broad role cues are present. The board is a concept discussion aid, not a proportion-checked set of character sheets. No panels were split, rigged, tested in Godot, or imported into runtime.
- Eleven Tier I manifests remain **NOT SUBMITTED**. Next gate is visual direction approval/revision per recruit, followed by individual anatomy references and then measurable part/pivot/animation validation.

## Remaining eleven recruits: source-backed art intake — 2026-10-25 UTC

- Fetched the live Founding Recruit Roster and audited the local concept-art, character-sprite staging, and runtime character folders.
- Added `docs/CHARACTER_ART_INTAKE_11.md` with verified identity/role/faction/ability facts and an individual Tier I intake checklist for BULWARK, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH.
- Source audit found no character-specific art or part sets for these eleven. The local class/faction board is generic reference art, not a verified portrait mapping or animation-ready asset. The BREAKER production board remains BREAKER-specific.
- No character art, manifests, rigs, or runtime scenes were created. All eleven remain **NOT SUBMITTED**; anatomy, silhouettes, part boundaries, and pivots require character-specific source/design review before rigging.
- Validation: checked roster source retrieval metadata; enumerated local asset roots; decoded and measured the four concept boards (1536×1024 each); existing roster intake audit remains the authoritative manifest check. No gameplay code changed.

## Founding-roster character-art intake pipeline — 2026-10-25 UTC

- Added a shared manifest v1 JSON Schema, deliberately incomplete starter template, roster snapshot sourced from the live Founding Recruit Roster, and a batch intake CLI for all twelve canonical IDs.
- The roster audit discovers only `character_art_manifest.json`; legacy BREAKER `pivot_manifest.json` experiments are ignored unless explicitly registered. The existing BREAKER Tier I review manifest is the sole registered pilot. The other eleven characters remain `NOT SUBMITTED`; the tool creates no empty manifests or art.
- Added explicit report modes: normal intake (missing is a status), `--require-all` (exit 2 on missing), `--require-production` (exit 3 on missing or readiness blockers), and machine-readable `--json`. Invalid roster/manifest data exits 1.
- The roster requires Tier I coverage for each character; a higher-tier submission cannot conceal a missing Tier I asset.
- Hardened malformed cross-reference and numeric-type handling in the shared validator. Tests use only temporary 2×2 raster fixtures inside the workspace, removed after execution.
- Validation: 22 Python unit tests pass; normal roster audit reports BREAKER `REVIEW_ONLY` and 11 `NOT SUBMITTED`; `--require-all` returns its expected blocked exit 2; `--require-production` returns expected blocked exit 3. Godot import, focused BREAKER rig, and full prototype regressions pass. Godot runtime/content is unchanged.

## Candidate01 v20 review disposition — 2026-10-25 UTC

The user chose to keep v20 as a review candidate rather than continue revising its hidden-arm shape now. Preserve v20 and its review evidence in quarantine; do not treat this as approval of the inferred underlay, anatomy, proportions, or production art. The hardened elbow-contact test passes its 100-contact threshold (v20: 104–267 contacts across 206 pose samples); that establishes only contact in the provisional rig. No art or runtime integration changed in response to this disposition. Concealed anatomy, authored pivots, full-frame deformation, and the production-art gate remain **NOT VERIFIED / NOT PASSED**.

## Manifest-driven BREAKER art-review pipeline — 2026-10-25 UTC

- Added a version-1 manifest schema for the quarantined BREAKER Tier I profile rig, a Python validator for schema/path/image/pivot/hierarchy/order/alpha/visible-height integrity, and negative tests for malformed metadata.
- Updated the isolated Godot preview to build its skeleton, parts, draw order, and display scale from the manifest instead of duplicating those declarations in code. Expanded the Godot smoke test to verify manifest-to-scene mapping and sample idle, walk, punch, and hit.
- Validation: 7 Python unit tests pass; manifest structural validation passes for 13 RGBA layers at 1024×1536 and measured 1427 px silhouette; production-gate check correctly returns blocked (exit 2); Godot 4.7.2 import validation and focused review-rig test pass; full `tests/test_runner.gd` passes.
- Scope: test/review tooling only. No runtime assets, combat systems, or canonical character art changed. Keep the parts and estimated pivots quarantined. Concealed anatomy, authored pivots, complete seam review, animation approval, and production readiness remain **NOT VERIFIED / NOT PASSED**.

## BREAKER v13 compact shoulder-underlay study — 2026-10-25 UTC

- Generated a new shell-off anatomy study from approved candidate 09 after v5–v9 shell-off shapes failed review. Extracted 16,407 skin-classified pixels only from the original v4 shell's opaque mask within the upper-arm ROI; the generated whole-image edit is retained only as draft provenance.
- Python audit passes: donor canvas and region checks; exact thresholded shell-on reconstruction; 25,738-pixel largest 8-connected union between hidden donor and visible biological skin. The donor has small disconnected details; connectivity does not establish anatomical quality.
- Godot 4.7.2 v13 registration test passes 206 neutral/60 Hz samples across idle, walk, punch, hit, and defeat. The full `tests/test_runner.gd` suite was rerun and passed. A connected-mask refinement produces 16,464 under-shell pixels and increases the largest visible/hidden 8-connected surface to 25,957 pixels while preserving the exact shell-on composite. A second full-mask donor covers all 25,942 opaque shell pixels and also preserves the exact shell-on composite; Godot registration again passes 206 samples. An OpenGL stress capture covers baseline, 12-source-pixel shell shift, 0.16-radian shell rotation, and shell-hidden views; ground anchor remained stable.
- The shell-off review is still generated rather than authored; visual proportions need user review. Keep v13 `.gdignore`d, not canonical, not production-ready, and out of runtime. No original candidate 09 pixels were overwritten or promoted.

Limits: tests prove mask placement, source-visible preservation, 2D connectivity, shared-bone registration, and stable anchor during a bounded in-memory shell transform only. The stress captures are visual diagnostics; they do not prove biological accuracy, approved shell deformation, authored pivots, continuous deformation, or production seams. These remain **NOT VERIFIED**.

QA: `docs/visual_qa/BREAKER_T1_candidate09_v13_shoulder_donor_review.png`.

## BREAKER shoulder-shell boundary and punch-contour trace — 2026-10-25 UTC

- The user explicitly approved the Tier I arm reading: external shoulder shell over a biological upper arm; the mechanical prosthesis begins at the elbow. This confirms the visible boundary rule already recorded in `docs/DESIGN_DECISIONS.md`; it does not approve any candidate image as production art.
- Traced the dark punch contour to disconnected pixels in the quarantined v4 `pelvis.png` layer. A one-time source partition isolates a 264-pixel connected fragment (bounds `(240,553)-(279,598)`); exact source RGBA recomposition passes. This establishes layer ownership, not whether the pixels are an intentional flexible cable or a flattened-art separation artifact.
- Created v12 as a `.gdignore`d, review-only split and compared attachment under pelvis, torso, cyber shoulder, and cyber elbow in neutral, idle, walk, and punch captures. Godot 4.7.2 saved all sixteen pose captures. All candidate neutral renders differ by 8 pixels from the neutral reference at filtered edges (accepted diagnostic tolerance); the source partition itself is exact.
- Visual review does not select a reliable parent: the four punch variants are too similar at gameplay scale, and the fragment is a pair of sparse slivers rather than a complete authored cable. Keep v12 quarantined; do not delete or repaint source pixels and do not promote a runtime part. The contour's intended meaning and final rig treatment remain open.
- Godot 4.7.2 reruns passed: full `tests/test_runner.gd`; the focused v4 visible-ownership/pose test (5,796 biological upper-arm skin pixels, zero on shell/forearm); the 206-sample contact regression; and the OpenGL Compatibility parent-capture comparison. The headless visual capture attempt failed because the dummy renderer provides no viewport texture; the same capture passed with the OpenGL Compatibility renderer. Known non-fatal log/shader-cache write warnings remain.

Limits: visible arm ownership is tested, but hidden anatomy, independent shell deformation, authored pivots, all-frame seam quality, and production readiness remain unverified. No runtime scene or production asset changed.

## BREAKER arm reconstruction and pose-art review — 2026-10-25 UTC

The user-approved Tier I boundary remains: an external shoulder shell overlays a biological upper arm; the mechanical right prosthesis begins at the elbow. Candidate 09 remains a flattened visual reference, not production art.

- Rejected v10's shell-off fit after manual review: its proximal extension reads as a straight wedge. It remains quarantined and no Godot test was run for it.
- Evaluated a candidate-16 skin-only donor in v11. The Python build selected the three largest warm-skin regions (103,333 threshold pixels), aligned their centers at estimated scale 0.376 and rotation −27.04°, and clipped them under fully opaque candidate-09 pixels. The shell-on assembly is pixel-identical to the v4 source assembly. The shell-off preview still shows disconnected patches and texture artifacts; **rejected for anatomy fit**. Donor is not canonical anatomy, component art, or runtime content.
- Corrected candidate 16's stale alpha-bound note after inspecting the current file: 1312×1199 RGBA; alpha>32 bounds `(22,22)-(1295,1173)`, alpha>127 bounds `(23,22)-(1294,1173)`, and neither touches the bottom row. The image still has 619,084 semi-transparent pixels and is not a clean production cutout.
- Godot 4.7.2 `tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin.gd` passed: 5,796 classified skin pixels on biological upper arm, zero on shell and forearm, and pose/anchor checks for idle, walk, punch, hit, defeat.
- Godot 4.7.2 `tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin_contacts.gd` passed 206 neutral/60 Hz samples with shell and skin sharing transforms. Full `tests/test_runner.gd` passed.
- Updated the display capture helper to seek explicit pose times and capture idle, walk, punch, hit, and defeat. The underpaint-on/off comparison shows a dark trailing contour in both views. A Godot selective-layer review saved `breaker_trial09_v4_punch_layer_isolation_hide_*.png`; those hides alone did not identify the contour. A later isolated source-component review traced it to disconnected pixels within `pelvis.png`; semantic intent and final animation ownership remain unresolved (see the newer contour-trace entry above).

Limits: the scope checks prove the approved visible arm boundary and selected pose registration only. They do not prove concealed anatomy, authored pivots, all-frame pixel continuity, or production readiness. The user approved the Tier I visible anatomy reading on 2026-10-25: external shoulder shell over a biological upper arm; the prosthesis starts at the elbow. **Art/canon review is directionally aligned; final art gate remains NOT PASSED.** No runtime scenes/assets were changed or promoted. Godot display commands still emit non-fatal `user://logs/godot.log` and shader-cache write warnings.

QA files: `docs/visual_qa/BREAKER_T1_candidate09_v10_reference_row_profile.png`, `docs/visual_qa/BREAKER_T1_candidate09_v11_candidate16_skin_donor.png`, `docs/visual_qa/breaker_trial09_v4_manual_skin_arm_pose_qa.png`, `docs/visual_qa/breaker_trial09_v4_underpaint_comparison_1280x720_punch.png`, and `docs/visual_qa/breaker_trial09_v4_punch_layer_isolation_hide_none.png` plus the per-layer hide captures.

Last updated: 2026-10-25 UTC

## Drive audit and candidate01 shell-on pose capture — 2026-10-25 10:07 UTC

- Verified read-only browser access to the canonical Drive root. The character-sprite folder contains only the BREAKER production specification; the Godot backups folder is empty; the milestone-snapshot folder contains its manifest, README, and reconstruction-kit ZIP. The concept-art folder contains four concept PNGs. Neither the archive nor the local backup ZIPs contain layered/native source files suitable for editing.
- Assembled the approved candidate01 visual source partitions in the isolated review rig with the external shoulder shell displayed and the prosthesis beginning at the elbow. Godot 4.7.2 OpenGL Compatibility rendered neutral, walk, punch, hit, and defeat captures under `docs/visual_qa/BREAKER_T1_candidate01_shell_on_rig_*.png`.
- Shell-on preview is visually coherent at this review scale and retains the candidate01 appearance direction. This is a presentation check only: estimated pivots, provisional underlay, and sampled test poses do not pass concealed-anatomy, authored-pivot, deformation, or production-art gates. No art was promoted to runtime.
- Headless capture failed on Godot's dummy renderer because its viewport texture is unavailable; OpenGL Compatibility capture succeeded. After adding the capture helper, the focused fitted-arm check passed (206 frames per width, 412 total) and the full `tests/test_runner.gd` suite passed.
- No remote Drive files were changed. Historical entries saying Drive was inaccessible are superseded by the read-only audit recorded in `docs/MIGRATION_REPORT.md`.

QA helper: `tests/capture_breaker_candidate01_shell_on_rig_review.gd`.

## BREAKER concealed-arm generation attempt — 2026-10-25 10:10 UTC

A localized transparent upper-arm donor was generated from the approved arm crop as a one-off concept. Visual inspection found it too muscular, oversized, and stylistically unlike candidate01; it was not copied into the project, layered, or tested. Candidate01 shell-on art remains the visual authority; no arm asset is promoted.

A second source-aligned generation using both the full-body candidate01 and arm crop was also reviewed. It again produced oversized, bodybuilder-like anatomy and did not preserve BREAKER's restrained proportions. It was rejected and not copied into the project. Repeated standalone image generation has not produced acceptable concealed anatomy; the production art gate remains **NOT PASSED**.

## BREAKER candidate01 vector underlay trial — 2026-10-25 UTC

- Authored `candidate01_upper_arm_vector_underlay_v1.svg` as a source-canvas 1024×1536 review-only layer in the `.gdignore`d hidden-anatomy draft folder. It stays out of runtime scenes.
- Godot 4.7.2 confirms the donor alpha is fully covered by the approved shell/visible-skin/forearm masks in the assembled source, preserving the shell-on art. The updated focused rig test samples all three candidate underlays over 618 frames: vector contact range 398–865 pixels over 206 neutral/idle/walk/punch/hit/defeat samples, stable ground anchor and shoulder/elbow parenting.
- OpenGL Compatibility captured shell-on and shell-off views for neutral, walk, punch, hit, and defeat. Shell-on appearance remains unchanged. The shell-off silhouette is narrower than the rejected image-generation studies, but its visual proportion/style gate remains **PENDING** manual review; it is not canon, accepted art, or production-ready.
- Godot 4.7.2 full `tests/test_runner.gd` passed after the addition. The focused vector test passed. Only nonfatal user log/shader-cache write warnings occurred.

Review captures: `docs/visual_qa/BREAKER_T1_candidate01_vector_underlay_*.png`.

This is a chronological status log. Older entries may describe the BREAKER arm boundary as unresolved; those notes predate the user's explicit approval and are superseded by `docs/DESIGN_DECISIONS.md` and the current check below.

## BREAKER arm-boundary review candidate 14/15 — 2026-10-25 UTC

- Candidate 14 is rejected as a component-fit source: despite communicating shell-over-skin/elbow-start anatomy, its parts do not match candidate 09's pose/scale and its nominal transparent PNG contains 632,711 semi-transparent pixels and no fully opaque pixels.
- Candidate 15 is a quarantined full-body concept edit of candidate 09. Manual review **passes the arm-boundary visual reading**: an external shoulder shell overlies the biological upper arm and the prosthesis starts at the elbow. Side-by-side review is saved as `docs/visual_qa/breaker_candidate09_vs_candidate15_arm_review.png`.
- `python tools/art/audit_breaker_arm_boundary_candidate_15.py` passed image decode/canvas checks (both 1024×1536), confirmed candidate 15 is fully opaque (1,572,864 opaque pixels), and measured RGB MAE 19.918 in the arm ROI and 3.795 across the full canvas. These measurements establish comparison scope only; they do not prove pixel preservation or anatomy.
- Godot 4.7.2 headless `tests/test_runner.gd` passed: “All Neon Requiem prototype tests passed.” Godot still emitted the known non-fatal `user://logs/godot.log` write warning.
- Confirmed the new candidates remain under the `.gdignore`d draft directory; no references were found in `scenes/`, `scripts/`, or `data/`.

## BREAKER isolated arm assembly candidate 16 — 2026-10-25 UTC

- Built a single transparent arm concept study using candidates 15/09 as references. Manual review reads the biological upper arm beneath the shoulder shell and the mechanical transition at the elbow. The arm angle is generally compatible with the source's shoulder-to-fist direction, but this remains a visual donor rather than a fit-checked part.
- Image inspection measured 1312×1199 RGBA, with 953,406 zero-alpha, 619,084 semi-transparent, and 598 fully opaque pixels. Fresh bounds are `(22,22)-(1295,1173)` at alpha>32 and `(23,22)-(1294,1173)` at alpha>127; neither touches the bottom row. Fist clipping/transparent-margin readiness remains **NOT PASSED** because the image has extensive semi-transparency and is not a clean cutout.
- `tools/art/inspect_breaker_candidate16_skin_mask.py` selected 119,790 warm-skin pixels for a diagnostic overlay. Manual inspection shows false positives on reflective armor, so the mask is not suitable for part extraction. The diagnostic image is `docs/visual_qa/breaker_candidate16_skin_mask_diagnostic.png`.
- Candidate 16 has no independent shell/skin/forearm exports, pivots, or pose tests. No layers were extracted or promoted; production art/rig remains **NOT PASSED**.
- Candidate 17's alpha-aware fit excludes the low-alpha glow and preserves aspect ratio. Its painted bounds are 583×1400 px (0.416 width/height), producing a 146×351 px overlay at reference arm height. Manual comparison rejects the fit as too narrow and undersized beside candidate 09. `tools/art/fit_breaker_candidate17_to_reference.py` produced the comparison board; this does not set authored pivots or validate animation.
- Candidate 15 is still a flattened full-body concept with an opaque background. It has no exported masks, pivots, hidden surfaces, or animation validation. **Production-art/rig gate remains NOT PASSED.** No runtime assets changed and no images were uploaded remotely.

## BREAKER art/canon verification rerun — 2026-10-25 UTC

- Reviewed the same-scale candidate 01/05/09 comparison and candidate 09 v2 four-action capture. Candidate 09 retains the approved profile direction and visibly shows an external shoulder shell over a biological upper arm, with the mechanical forearm beginning at the elbow. This is a visible-surface review, not proof of hidden anatomy.
- Godot 4.7.2 full `tests/test_runner.gd` passed. Targeted candidate 09 v2 rig/ROI checks passed (upper-arm skin 5,796 pixels; forearm skin 0), and sampled contact checks passed 2,472 samples across 206 poses at 60 Hz. Candidate 11 Godot checks passed only decode, canvas-size, and transparent-corner validation.
- Python image audits remain intentionally non-passing for production readiness: candidate 09 has 554,254 semi-transparent pixels and no fully opaque pixels; candidate 11 has 25,994 fringe and 6,834 soft-alpha pixels. Candidate 11 retains visible background haze. Both remain quarantined drafts.
- Manual action review: idle, punch, and hit read as intended at 256 px; the walk is still subtle in the four-action sheet. Sampled contacts do not validate continuous seams, authored pivots, or concealed anatomy. **Production-art gate remains NOT PASSED.**
- Godot emitted its known non-fatal `user://logs/godot.log` write warning. No runtime assets were changed or promoted.
- Candidate 03 fidelity regression passed against candidate 02: silhouette IoU 0.9761, visible RGB MAE 17.65/255, maximum bound drift 3 px. This is a visible-art similarity pass only.
- Hidden-anatomy provenance audit for candidate 03 found 664,937 layer pixels checked and 0 independently differing RGB pixels versus the flattened source. Candidate 09 v2 manifest records 297,686 locally extrapolated underpaint pixels and `hidden_anatomy_verified: false`. Neither is authenticated hidden anatomy; the anatomy/production gate stays open.

## BREAKER arm component board candidate 12 — 2026-10-25 UTC

- Created a transparent four-panel concept board for biological upper arm, independent shoulder shell, mechanical forearm/fist, and assembled arm. Manual review confirms the shell-over-human-arm / elbow-start-prosthesis reading and finds the separation clearer than candidate 11. Full-body proportion matching still needs review.
- The board remains quarantined and is not split into runtime art. Its part alignment, pivots, concealed surfaces, and animation seams are not authored or verified.
- Python and Godot 4.7.2 structure tests pass: 1774×887 RGBA, transparent corners, and four separated high-alpha panel ranges. Alpha counts include 19,388 fringe pixels and 5,651 soft-alpha pixels; this is a structural pass, not an alpha/art-production pass.
- Full `tests/test_runner.gd` passed. Candidate 03 fidelity and candidate 09 v2 visible ROI checks pass; candidate 03 hidden-anatomy provenance remains NOT VERIFIED (0 independent source pixels). Production-art gate remains **NOT PASSED**.

## BREAKER arm component-sheet concept candidate 11 — 2026-10-25 UTC

- Built a new concept sheet using the approved profile candidate 01 and arm-boundary study candidate 09 as references. Manual visual review reads the approved anatomy correctly: external shoulder shell over biological upper-arm volume; mechanical prosthesis begins at the elbow. The gunmetal/crimson material language is consistent with the source direction.
- Art direction is **PARTIAL**, not passed: the exposed bicep is more exaggerated than the approved full-body reference; matching panel scale, pivot locations, and attachment geometry are not established.
- Python audit `tools/art/audit_breaker_arm_component_sheet_candidate_11.py` confirms 1024×1536 RGBA, transparent corners, and reports 936,537 transparent pixels, 25,994 fringe pixels (alpha 1–127), and 6,834 soft pixels (alpha 128–244). It correctly exits 2: **production-art gate NOT PASSED** because semi-transparent haze remains.
- Godot 4.7.2 `tests/test_breaker_arm_component_sheet_candidate_11.gd` passes direct disk decode, canvas-size, and transparent-corner checks. These structural checks do not establish production readiness.
- The sheet, README, and metadata remain under `assets/characters/breaker/tier_01_drafts/`; not imported to runtime or assembled in a rig. See `docs/ASSET_MANIFEST.md` and the candidate sidecar for SHA256 and limitations.
- One follow-up image edit aimed at narrowing the bicep was reviewed inline but not copied into the project: it did not materially correct the proportion or provide safe component separation. Candidate 11 remains the documented concept; neither generated image is production art.

## Latest BREAKER art/canon check — 2026-10-25 UTC

- **Canon boundary: PASS.** User-approved: an external shoulder shell sits over a biological upper arm; the mechanical prosthesis begins at the elbow.
- **Candidate 09 v2 visible ownership: PASS within the tested ROI.** Python audit moved 5,877 pixels (including contour) from the forearm ownership to the upper-arm ownership, preserved source RGB and exact neutral reconstruction, and found 5,796 warm-skin pixels in the approved upper-arm ROI versus 0 on the mechanical forearm. Godot 4.7.2 regression confirms the same ownership check, 13 visible/underpaint layers, 256 px visible scale, pose channels, and stable ground anchor.
- **Pose/contact review: PARTIAL.** Godot contact regression passed 2,472 selected joint/pose samples over 206 poses at 60 Hz. A review-only keyframe tuning makes the punch and hit more distinguishable while retaining BREAKER's profile identity and grounded feet. The walk remains subtle at the contact-sheet scale, and contact samples do not verify continuous deformation.
- **Production art/rig gate: NOT PASSED.** Shoulder shell remains fused into the upper-arm texture; hidden surfaces and anatomy are inferred; pivots are estimated; hands/feet remain joined to forearm/boot pieces; expressive pose readability and all-frame seams are not demonstrated. Candidate v2 is quarantined and not referenced by runtime.
- Review captures: `docs/visual_qa/BREAKER_T1_candidate09_arm_canon_v2.png`, `docs/visual_qa/breaker_trial09_canon_v2_four_actions_1280x720.png`, `docs/visual_qa/breaker_trial09_canon_v2_six_unit_1280x720_05.png`, and `docs/visual_qa/breaker_trial09_canon_v2_defeat_1280x720.png`.

## BREAKER Tier I production-gate review — 2026-10-24

- The isolated art-gate rig now targets the specification's true 256 px visible feet-to-hair height (`256 / 1427` measured source silhouette), rather than fitting the full transparent 1536 px canvas to 256 px. The temporary preview exposes idle, walk, punch, hit, and defeat samples while preserving a fixed root anchor and a facing-only flip.
- Added an isolated regression for all 13 shared-canvas layers, RGBA transparent corners, in-bounds provisional pivots, five pose channels, facing, and ground anchor. Added display captures for the five action samples and six full-size staggered BREAKER profiles.
- **Gate status: NOT PASSED for production art.** The captured rig is useful for visual review, but its pivots are hand-estimated; hidden anatomy beneath overlaps is missing; hands remain attached to forearms and feet to boots; and no all-frame seam or mesh-deformation validation exists. Keep all source masks quarantined and out of runtime. The first generated redraw changed the pose and retained its backdrop. The second result does contain a transparent alpha matte; it has now been copied as a quarantined source candidate and evaluated in a separate trial below. This updates the earlier assessment that the background-removal attempt failed.
- Godot 4.7.2: `tests/test_breaker_art_gate.gd` passed; profile walk-gait regression passed; five-cycle moving preview passed; display captures passed; full prototype suite passed; main scene launched for 120 frames. Current art-gate captures: `docs/visual_qa/breaker_production_gate_actions_1280x720.png` and `docs/visual_qa/breaker_production_gate_six_unit_1280x720.png`.

## BREAKER profile cutout candidate 02 and rig feasibility — 2026-10-24

- Recovered the alpha-bearing output from the earlier background-removal generation and preserved it as `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_cutout_candidate_02.png`. The image is 1024×1536 RGBA, has over 1.1 million fully transparent canvas pixels, and its alpha>=245 silhouette bounds are `(239,46)` to `(791,1472)` (1427 px high). Its composition is close to but not pixel-identical to the user-approved candidate 01.
- Extended `tools/art/export_breaker_profile_trial_01.py` with explicit `--source` and `--output` arguments; the default paths remain the original trial 01. Exported to the new sibling `profile_rig_trial_02/`, without changing trial 01. All 13 layers share the 1024×1536 canvas; the export reports zero uncovered high-alpha silhouette pixels and exact neutral reconstruction of the thresholded candidate 02 image.
- Added an isolated Godot trial 02 scene and targeted tests. Godot 4.7.2 passed the source RGBA/transparency/bounds test and the 13-layer rig structure, scale, estimated-pivot, anchor, facing, and idle/walk/punch/hit/defeat transform checks. Display-rendered review captures are `docs/visual_qa/breaker_profile_trial_02_actions_1280x720.png` and `docs/visual_qa/breaker_profile_trial_02_six_unit_1280x720.png`. After these changes, the full prototype test suite also passed and the main scene launched for 120 frames.
- These results prove alpha presence, static extraction coverage, and transform plumbing only. The generated cutout is still a flattened reference, not rig-ready art. Its 13 masks reuse estimated visible contours; hidden anatomy, authored pivots, independent hands/feet, continuous seam behavior and deformation are not validated. **Production-art gate remains NOT PASSED.** All files are quarantined and excluded from runtime.
- No remote Notion or Drive access, upload, Git repository, or commit was available. Local staging copies are updated separately; no remote synchronization is claimed.

## BREAKER walk presentation refinement — 2026-10-24

- The live code-drawn BREAKER placeholder now uses a restrained counter-swinging natural arm, smaller motion in the heavier cyber arm, alternating knee lift, ankle counter-rotation, and slight torso/head response during the existing configurable walk cycle. Combat movement speeds, simulation state, timing defaults, and player controls are unchanged.
- The isolated BREAKER profile-part review rig now has a fuller 0.65-second cycle with staged alternating hip/knee motion, boot counter-rotation, arm counter-swing, and cubic interpolation. Its pelvis track preserves the authored rest offset. The 13-part art and estimated pivots remain quarantined; this preview does not promote them to runtime or validate hidden anatomy/deformation.
- Godot 4.7.2 validation: full prototype test suite passed with assertions for opposing legs, ankle counter-rotation, arm counter-swing, reduced cyber-arm swing, and stable runtime ground anchor. Standalone full-cycle profile-rig test passed (alternating knee lift, pixel-sampled opaque boot contact at two stance phases, opposite arm swing, loop closure under 0.06 rad, stable root anchor); five-cycle translated review passed; main scene launched for 120 frames; display captures passed. Current captures: `docs/visual_qa/breaker_profile_walk_cycle_1280x720_04.png`, `docs/visual_qa/breaker_profile_joint_motion_1280x720_06.png`, and `docs/visual_qa/six_actor_movement_1280x720_04.png`. Godot emitted known non-fatal `user://logs/godot.log` and shader-cache permission warnings in display mode.

## Implemented in this local prototype

- Godot project configuration and main scene entry point.
- Temporary code-drawn Undercity battlefield with a separate procedural skyline, subtle neon windows/haze, animated rain, and wet pavement perspective; clearly non-production environment presentation and enemy placeholder.
- **User-approved on 2026-10-24:** modular encounter zones with seamless-looking transitions. `EnvironmentDirector` now selects zone data by wave and crossfades outgoing/incoming procedural backdrops without changing combat state. The two palette-only prototype modules switch at wave 13 only to exercise the transition; this test boundary and palette variation are not approved content pacing, location names, or production art.
- BREAKER Tier I `Skeleton2D`/`Bone2D` hierarchy with independently attached polygon parts for the messy undercut, scarred human face, sleeveless vest, neck regulator, asymmetric right cybernetic forearm/large fist, boots, and left knee brace. It is ground-anchored and faces right by default.
- Added `docs/BREAKER_RIG_CONTRACT.md` as the local presentation/simulation boundary: stable root ground anchor, visual-only facing, Tier I/action API, and named ground/neck/right-fist FX markers. The rig exposes marker world positions; the visual rig owns no collision shapes.
- Procedural idle, walk, punch, hit, and defeat poses use timing values from the BREAKER specification. The tier selector accepts only Tier I; facing flips the visual skeleton without moving the gameplay anchor.
- Automatic fixed-step six-slot squad simulation: BREAKER and five explicitly unassigned allies approach and attack automatically; enemies select the nearest living ally, apply damage, and trigger retreat only when the squad is defeated. Data-driven engagement behavior lets ranged units hold their configured stand-off distance while melee units close to contact; the Undercity grunt is a melee placeholder. Slots 2–3 provisionally exercise ranged behavior and slots 4–6 melee behavior. Rewards, wave advancement, holding-wave retreat, and the prototype wave cap remain simulation-owned. **User-approved on 2026-10-24; supersedes earlier same-day health decision:** remaining HP carries across successful waves, zero-HP allies remain defeated, and a full squad restores at the highest-cleared holding wave after retreat. Per-slot HP is included in run saves. The prototype horizon now extends through wave 125 so the second through fifth Reboot award bands can be exercised. Waves 26–125 deliberately reuse the same grunt, scaling, and placeholder battlefield; they are labeled Progression Test Fixture and do not implement the approved district content. With current provisional damage tuning, automated simulation clears through wave 5 then naturally retreats to holding wave 5 after 80.2 simulated seconds; this is prototype tuning, not final balance.
- Presentation-only interpolation now smooths ally/enemy movement between the 50 ms simulation steps; it does not modify authoritative combat state or save data. New encounter starts reset interpolation origins to avoid stale-position blending.
- Backline grounding correction: each of the six allies and the enemy now has a dedicated contact shadow, and the upper battlefield walkway has visible floor seams/perspective guides. This is presentation-only; actor positions, formation depths, speeds, and combat behavior are unchanged. Shadows use baseline simulation positions, so placeholder walk/idle bob may create small contact variation.
- **User-approved visual rule (2026-10-24):** characters appear grounded by default; floating is reserved for a defined ability or another clear in-world reason that the presentation communicates. No floating character behavior has been implemented; current actors remain grounded placeholders.
- Configurable provisional horizontal start offsets, role-based engagement distances, depth positions, individual internal movement speeds (36, 43, 49, 58, 66; BREAKER is 52), and generic combat stats for the five unassigned allies; simulation applies speeds and engagement behavior automatically. Placeholder depth spacing is 32 world units between adjacent squad lanes to improve silhouette separation at small viewport sizes. No player-facing speed, range, or formation controls, nor corresponding save/settings fields, exist. The HUD reports squad status and makes placeholder content explicit. Player-defined position preferences are not implemented yet.
- Configurable JSON data for BREAKER Tier I, one basic enemy, and Undercity prototype wave/reward parameters. Numeric values are unapproved placeholders.
- Minimal progression/economy model separated from combat simulation; handles credits, bulk/individual recruit leveling, and run save payload.
- `CombatDirector.wave_cleared(wave_number, credit_reward, run_high_water, boss_id)` emits one structured event after its victory credit grant and wave/intermission state update. Main uses this authoritative event to grant repeatable materials and configured first-clear bonuses; current boss ID is empty unless an encounter's enemy definition provides a canonical `boss.*` ID.
- Deterministic recruit upgrade buttons (one or ten levels, bounded by credits) using a provisional exponential cost curve.
- Version 1 local save/load with separate `permanent`, `run`, and `settings` objects; validates the payload, nested BREAKER level, and optional six-slot `run.squad_hp`, checks staged/backup/committed/rollback data against the intended payload, preserves recovery sidecars during backup promotion, rolls back failed commits, and recovers from `.bak` or `.bak.prev` when the primary is missing or invalid. Older version-1 saves without `squad_hp` remain valid and load with a fresh full-health squad. This remains a provisional prototype schema with no migration path.
- A two-process save probe in `tests/restart_save_probe.gd` exercises write in one Godot process and restore in a separate process, including permanent, run, six-member HP, and settings sections. It now applies BREAKER's three approved prototype evolution purchases (Combat/Military/Apex Grade for 1/2/3 shared Evolution Data) before saving and verifies the Apex tier plus zero remaining materials in the fresh reader process. It uses a unique disposable project-local file and cleans the file and recovery sidecars after the read pass.
- Validation on 2026-10-24: the two-process evolution save probe passed across separate Godot launches; the full headless suite passed (`All Neon Requiem prototype tests passed.`), and a 120-frame headless main-scene launch exited 0. Each process emitted the known non-fatal sandbox warning that `user://logs/godot.log` could not be written.
- Local art pipeline exploration: two original transparent BREAKER Tier I modular-parts atlas drafts were generated from the written specification; the second also used the recovered Tier I production board as a visual reference. Both are staged at `assets/characters/breaker/tier_01_drafts/`. They are source explorations only; neither has verified crops/pivots or seams, both are excluded from Godot imports, and neither replaces the runtime polygon rig.
- Generated a separate transparent BREAKER head-and-neck cutout candidate for a contained integration trial. It loads through the new presentation-only `set_head_art` hook in an isolated rig; the proposed pixel pivot maps to the head-bone origin, and the trial leaves simulation state unchanged. It remains quarantined and needs a real viewport review before any runtime use; full-body parts and deformation remain unverified.
- Draft 02 was checked against the rig contract and was not promoted: it is an exploration sheet without validated part bounds, shared scale, pivots, or joint seams. No art swap was attempted; this protects the existing runtime rig from unverified pieces.
- HUD uses a restrained gunmetal telemetry panel with crimson/cyan control states; save and upgrade feedback is inside the panel. The existing four buttons remain unchanged, and movement-speed controls remain absent.
- Offline handoff inspected: nine reconstructed Notion Markdown pages, decision/implementation status, Drive inventory, production spec, README/manifest, and all four 1536 × 1024 concept sheets.
- Source/access gaps, assumptions, and pending validation documented.

## Approved 1.0 scope (not yet implemented)

- **Historical 2026-10-24 scope, superseded for visual completeness on 2026-10-26:** include all twelve founding recruits in 1.0 with Tier I art targeted, complete BREAKER's four tiers first, and defer the other eleven's higher-tier visuals until after 1.0. Current owner decision requires distinct visible art changes at every evolution step for all twelve in 1.0. The hybrid evolution gate, Windows PC target, and Reboot eligibility remain as separately approved. No additional recruit, evolution, or production art was implemented by recording these scope decisions.

## Progression runtime integration (partial)

- `scripts/progression/progression_rules.gd` provides data-driven Reboot awards, lifetime/spendable Influence accounting, the capped square-root lifetime bonus, permanent first-clear material claims, and evolution material gates/consumption. The prototype profile is loaded for the damage bonus; its numerical rules remain provisional and are not final balance/canon.
- `CombatDirector` applies `min(0.5% × sqrt(lifetime Influence), 25%)` to all allies' authoritative outgoing attack damage. It does not change HP, defense, enemy damage, or movement. The HUD shows the bonus. Save loading supplies lifetime Influence.
- `permanent.highest_wave_ever` tracks cleared-wave milestones and survives Reboots; `evaluate_permanent_evolution_gate` uses that permanent high-water value while still requiring materials. Main-scene saves preserve the first-clear high-water. The data-driven combat horizon and save validation now align at wave 125. This is only a progression test horizon: post-wave-25 district content is not implemented.
- `scripts/progression/reboot_service.gd` provides a pure reset and an explicit-path `reboot_saved_game` operation that reloads the latest save and commits award/reset through SaveService atomically. The live HUD now uses the pure reset operation with current unsaved run state and saves through the same verified SaveService transaction before changing the scene.
- Manual System Reboot is now connected to the live HUD: it unlocks only after a first clear of wave 25, requires confirmation, captures unsaved live run state, commits the transaction before applying it to the running scene, restores base-level squad HP, resets credits/levels/wave, and refreshes lifetime Influence damage. This uses the approved prototype profile; its award/buff values remain trial values, not final balance.
- Live wave-clear material rewards use approved prototype trial values: 1 shared Evolution Data per successful wave clear, plus 1 extra for each newly claimed district endpoint and named boss. **User-approved on 2026-10-24:** every successful clear now atomically autosaves the full permanent/run/settings payload, including credits, HP, first-clear rewards, and a fresh offline timestamp. The save-backed regression verifies reward persistence and manual-save recovery after an injected invalid-path write failure. Failed autosaves keep completed state/rewards in memory and clearly ask the player to press Save; SaveService preserves the previous valid file. No named boss content is defined. Payouts remain prototype values, not release balance.
- Evolution unlock transaction: profile gates are Combat Grade at permanent first-clear wave 25 for 1 Evolution Data, Military Grade at wave 75 for 2, and Apex Grade at wave 125 for 3, per recruit. `evolution_service.gd` supports all twelve approved recruit IDs, preserves the established `breaker_tier` save key, checks milestone/material gates, and produces copied permanent state. The live roster Evolution panel exposes the save-before-apply transaction for all twelve IDs. Each row records its tier and current run before applying live permanent state. This is a progression record only; no tier stat/trait changes or higher-tier art are implemented. Values are prototype trials, not final balance.
- Offline credit claim prototype: `offline_earnings_service.gd` uses the saved highest-cleared holding wave (minimum wave 1) and the shared ordinary encounter reward formula. The approved feasibility rate is one ordinary reward per hour, capped at eight hours. Loading a save atomically writes the payout and timestamp before changing live progression; failed writes award nothing. Offline processing does not simulate or advance waves. Saves without the optional timestamp establish a persisted baseline with no retroactive payout; clock rollback also resets the baseline without granting credits. Rate is a configurable trial value, not release balance.
- Permanent research framework/UI: `research_service.gd` provides validated rank purchases, prerequisite checks, Influence deduction, immutable candidate state, and a save-before-apply wrapper. The HUD has a Research action that lists Combat Protocols, Underground Economy, Network Infrastructure, and Personnel Development. The catalog is intentionally empty and the view is read-only; research node costs, prerequisites, and effects are not defined or applied.
## Not implemented

- Live canonical Notion/Drive verification and newer linked additions; the offline handoff says its Notion Markdown is reconstructed, not verbatim.
- A cleaned production sprite-part set, complete-body rig testing with real art, authored reusable animation clips and combat-synchronized impact events, and Tier II–IV art swapping. The isolated head-candidate viewport trial confirms that the cutout attaches at the configured pivot and mirrors with the rig; visual inspection found a clear style/scale mismatch against the low-resolution polygon body, so the candidate remains quarantined and is not integrated. The code polygon hierarchy remains the main-scene stand-in, not a finished production rig.
- Combat-ready definitions and deployment for the twelve recruits, canonical definitions for the five named boss recruits, player-defined formation preferences, ability definitions, broader enemy roster, and the complete credit economy. Deterministic ownership/purchase for the twelve founding recruits is implemented as a prototype slice; squad assignment remains unimplemented.
- Production district environments, authored zone art/layouts, district-specific enemies/rewards/bosses, endless/procedural progression beyond wave 125, and final zone progression boundaries. Waves 26–125 currently reuse one prototype combat fixture.
- Purchaseable Influence research nodes and gameplay effects, canonical named boss content, higher-tier visual effects for recruits, and cyberware. Offline rate/balance and research node values remain open. Mobile/touch-specific release UI is outside the approved Windows-PC-only 1.0 scope.
- Git repository connection, commit, Notion update, or Drive backup.

## Validation

- Offline earnings final rerun (Godot 4.7.2, 2026-10-24): `Godot_v4.7.2-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/test_runner.gd` exited 0 and printed `All Neon Requiem prototype tests passed.` This includes offline rate/cap math, no wave advancement, single-claim behavior, legacy baseline persistence, live load-state preservation, and timestamp updates on evolution/Reboot saves. `--headless --fixed-fps 60 --path . --quit-after 120` also exited 0. Both emitted only the known non-fatal `user://logs/godot.log` write warning.
- Offline process probe (Godot 4.7.2): three separate processes seeded a disposable wave-25 save, invoked the real main-scene load/claim, then reloaded the result. One 108-credit claim persisted once, the wave remained unchanged, a third process did not duplicate it, and the probe removed its save/sidecars. All three processes exited 0 with the known log warning.
- Wave-clear autosave and research framework (Godot 4.7.2, 2026-10-24): full test suite passes. A live wave-clear callback test verifies permanent first-clear/repeatable materials and the full current run/settings commit together. A deliberately invalid parent path confirms failed autosave creates no partial save, preserves session rewards, displays manual-Save recovery guidance, then persists on the next valid clear. A separate sentinel-save regression confirms that a wave clear before loading cannot overwrite an existing save; explicit Load or Save enables subsequent autosaves. Research tests cover all four empty approved branches, purchase prerequisites, rank/cost validation, immutable inputs, save-before-apply success/failure, and malformed saved ranks. The actual Research dialog is checked as read-only and does not spend Influence.
- Display-capable offline-claim HUD QA passed and reloaded both captures: `docs/visual_qa/offline_claim_1280x720.png` and `docs/visual_qa/offline_claim_800x450.png`. Both show the +108 holding-wave payout and no-wave-advance message without clipping; at 800×450 the complete HUD is visibly denser, but remains inside the viewport.
- BREAKER joint/motion review: the isolated 13-part rig regression passed idle/walk/punch/hit transform checks, and the five-cycle 0.65-second walk test passed with stable ground anchor and hip swing ±0.12 rad. A new display-capable contact sheet records neutral, walk, punch, and hit samples at 1280×720. Sampled anchors remain fixed; visual review shows no major part detachment in these poses. The estimated pivots and missing hidden anatomy remain unverified for production, so every part stays quarantined.
- BREAKER rig-contract regression (Godot 4.7.2 headless suite, 2026-10-24): passed checks for ground/neck/right-fist markers, visual-only facing and stationary ground anchor, collision separation, and no simulation position/HP mutation from presentation actions. The head candidate's transparency samples and isolated head-bone pivot/scale plumbing also passed. An isolated Godot GUI trial was saved and visually reviewed at `docs/visual_qa/breaker_head_candidate_preview_1280x720.png`: attachment at the head anchor and left/right visual mirroring appear correct, but the detailed generated cutout is visibly mismatched in style and scale against the code-drawn body. Draft atlas 02 and the head candidate remain quarantined; neither is referenced by the main scene, and full-body deformation/animation compatibility remains unverified.
- After the rig-contract additions, the full headless suite passed (`All Neon Requiem prototype tests passed.`) and the main scene completed a 120-frame headless launch. Godot emitted the known non-fatal `user://logs/godot.log` permission warning.

- Workspace inspection: passed; the selected folder was empty before project setup. The migration kit was extracted separately, preserving existing project files and the received ZIP.
- Static validation: all JSON definitions parse and all scene/script resource references resolve.
- Godot 4.7.2 headless editor import scan (`--headless --editor --path . --import --quit`): file scan and global script registration completed, exit code 0, and `.gdignore` kept reference/staging folders out of the project import set. The restricted execution environment blocked writes to Godot's AppData/editor settings and `user://` snapshot/log folders, producing permission/safe-save errors; therefore a clean import-settings validation is not confirmed here.
- Headless prototype test runner (`--headless --path . --script res://tests/test_runner.gd`): passed on Godot 4.7.2 after the carryover-HP rule. It verifies HP retained across successful wave entry, defeated members remain down, natural squad defeat before the cap with the current 1.6 damage ramp, retreat to the highest cleared wave, and full recovery on holding-wave re-entry. Save coverage checks per-slot HP round-trip, invalid HP arrays/values, and old version-1 saves without HP data. Other existing coverage includes squad/combat/HUD/rig behavior, malformed and truncated JSON, out-of-range values and unsupported versions, transaction-stage equality, backup recovery and injected failures, partial commit/rollback, and valid-save recovery after malformed data. The disk round-trip uses a disposable project-local file; in-memory fault injection does not touch user save data. Godot emitted a non-fatal `user://logs` permission warning.
- Offline-credit claim slice (Godot 4.7.2, 2026-10-24): tests verify the shared reward formula, configured one-reward/hour rate, eight-hour cap, no wave advancement, copied input, timestamp baselining for legacy saves, clock rollback, sub-credit accrual, and one-time claims. A disposable live-load integration verifies credits, wave, high-water, recruit level, HP, permanent research and settings remain consistent, and the second load cannot duplicate the payout. Separate BREAKER evolution and Reboot save callbacks also verify those transactions reset the accrual baseline. Full suite and main-scene boot results are recorded after the final rerun below.
- Progression rule primitive checks passed: configurable wave-step Influence at below-threshold, threshold, interval, and wave-125 cases; lifetime/spendable accounting without mutating source state; rejection of invalid rules; capped square-root passive bonus boundary tests; evolution milestone/material checks; and all-or-nothing material consumption. Influence and passive-bonus values are approved for prototype feasibility testing only, not final balance; none is loaded by runtime gameplay.
- Reboot transaction checks passed on Godot 4.7.2: approved eligibility and reset/high-water behavior; award based on pre-reset run peak using proposed test values; preservation of permanent unlocks/research/evolution/materials; run credits/levels/HP reset; rejection before wave 25; rejection of malformed/missing squad-HP reset values; and input immutability. Godot headless suite and 120-frame main-scene launch both exited 0 on 2026-10-24. Godot emitted the known non-fatal `user://logs/godot.log` write warning. The scene launch confirms the existing scene still starts; it does not imply Reboot gameplay integration.
- Lifetime Influence tests cover zero/low/moderate/high balances, diminishing returns, the configured cap, invalid inputs, and outgoing attack damage application to all six allies. Regression checks confirm ally HP/max HP and enemy damage remain unchanged.
- Permanent evolution milestone tests verify `highest_wave_ever` round-trips in saves, updates from main-scene clears, remains after Reboot, and continues to gate evolution alongside material inventory.
- Persistence tests verify one save commits the wave-25 Reboot award and run reset together, a second call cannot award again, and failed staged writes preserve the original save. First-clear tests cover shared-inventory increments, duplicate rejection, input immutability, Reboot preservation, and save round-trip/validation.
- Independent test-lane rerun after the outgoing-damage and permanent-milestone integration: full Godot 4.7.2 headless suite passed (exit 0) and the main scene ran 120 frames (exit 0). No new correctness regression. The lane confirmed remaining limits: wave/save ceiling 25, no wave-clear material payout integration, and evolution reward quantities/costs remain open. The follow-up live Reboot control now captures unsaved state and refreshes permanent state/bonus after a successful commit. Godot emits the known non-fatal `user://logs/godot.log` warning.
- Live System Reboot integration (Godot 4.7.2, 2026-10-24): the full headless suite passed after adding the confirmation-gated HUD control. Regression coverage checks the control lock/unlock at the wave-25 milestone, confirmation prompt, live state capture, atomic save-before-reset behavior on a disposable project-local path, permanent research/first-clear preservation, Influence award, base-level HP restoration, and refreshed in-memory run/bonus/ally attack values. A 120-frame headless main-scene launch also passed. The independent test lane reran the final suite and main-scene launch; both exited 0 with no scene/script errors. Godot continues to emit the non-fatal sandbox `user://logs/godot.log` write warning.
- Progression horizon extension (Godot 4.7.2, 2026-10-24): the combat test horizon and save validation now allow waves through 125. Tests verify the cap transition, explicit placeholder label beyond wave 25, valid wave-125 save/load including separate-process persistence, rejection of wave/high-water 126, and the live save-backed Reboot award at wave 50 (two prototype Influence). Full suite and main-scene launch passed locally. The test fixture reuses Undercity enemy/battlefield definitions after wave 25; it does not implement Neon Row or later district content. Godot retains the known non-fatal user-log write warning.
- Structured encounter-clear event (Godot 4.7.2, 2026-10-24): `CombatDirector.wave_cleared` emits the cleared wave number, credited reward, and updated run high-water after the transaction reaches intermission or the configured cap. Regression checks verify event data/order, exactly-once emission, and final-wave behavior. This event was wired to the material reward service in the following milestone below.
- Deterministic material payout integration (Godot 4.7.2, 2026-10-24): the user approved prototype testing values of 1 Evolution Data for every successful wave clear and +1 for each first-cleared district milestone or named boss. `material_reward_service.gd` validates configuration, grants repeatable rewards, and uses the permanent claim ledger for district/boss bonuses. Main listens to the structured wave-clear event, updates the shared inventory, and displays the balance and encounter payout. Tests cover ordinary clears, district/boss first clears and replays, all five district endpoints, malformed profiles, and in-memory source immutability. Full headless suite and 120-frame scene launch passed locally and in the independent test lane. The values are trial balance, and no named boss encounter is currently defined.
- Version-1 save regression now round-trips optional spendable Influence and evolution-material inventory, and rejects negative values and wrongly typed inventories; older version-1 payloads may omit both fields.
- After adding the progression helpers, the full Godot 4.7.2 headless suite passed (`All Neon Requiem prototype tests passed.`), and the unchanged main scene completed a 120-frame headless launch; both exited 0. Godot emitted the known non-fatal `user://logs/godot.log` write warning.
- Roadmap follow-up checks: the headless suite now also confirms a responsive HUD rectangle stays within 800×450, exact-cost upgrades are charged once, unaffordable upgrades leave level and credits unchanged, insufficient-funds UI feedback is shown, and the encounter reward is not paid twice after a level purchase. The updated suite passed on 2026-10-24.
- Local art file checks: the test runner loads both BREAKER atlas drafts, verifies 1536×1024 RGBA format, confirms sampled transparent gutters and opaque art pixels, and confirms the `.gdignore` quarantine marker. This checks file integrity only; no rig or animation claims are made.
- Separate-launch persistence check: Godot 4.7.2 wrote the probe payload in one process and a second process restored matching permanent, run, squad HP, and settings data. Both invocations exited 0; the disposable save and recovery files were removed by the read pass. Godot emitted the same non-fatal `user://logs` permission warning.
- Local art import check: Godot 4.7.2 headless editor file scan completed, and neither quarantined art draft produced a `.import` sidecar. The scan still emitted the known AppData/editor-settings permission errors in this sandbox, so a clean editor-settings validation is not confirmed.
- Headless main-scene launch for 120 frames (`--headless --path . --quit-after 120`): passed with exit code 0 and no scene/script errors. Godot emitted the same non-fatal `user://logs` permission warning.
- Persistence recovery behavior: version 1 save/load passed with staged, backup, committed, and rollback payload comparison; older backups remain available through `.bak.prev` if promotion fails. Injected coverage includes temp open/write/flush/read-back failures, backup staging/promotion/removal failures, altered-but-valid staged/backup/committed data, invalid/partial committed copies, rollback-copy failure and recovery from missing/corrupt primary via either recovery sidecar. Schema migration and broader production durability requirements remain future work.
- Test follow-up: squad coverage exposed an over-scaled enemy HP formula and an out-of-range targeting fixture; both were corrected. A separate upgrade assertion now verifies that level purchases change the BREAKER's live combat stats, not just economy values. The test suite and main-scene launch passed after these corrections.
- Earlier full-health wave-entry tests and GUI observations are superseded by the later carryover-HP decision. Current regression asserts carryover on the post-victory intermission path; retreat recovery is separately tested.
- Modular zone selection and crossfade coverage passes in the Godot headless suite: configured wave boundaries, unchanged zone within a segment, the zone-change signal, simultaneous outgoing/incoming backdrops, and completion cleanup. The main scene also launches headlessly with the environment director.
- Display-capable Godot QA helper drove the main scene through the combat-owned wave-13 boundary, captured a 1280×720 frame mid-crossfade, and reloaded the saved PNG to verify dimensions. The transition was visually inspected; shared skyline geometry preserves continuity, while the palette shift remains deliberately subtle because these are temporary Undercity modules. Godot logged non-fatal sandbox warnings for `user://` logs and shader-cache creation.
- Positioning concern review: the earlier baseline screenshot shows a wave after several seconds of movement, while the first wave-13 capture showed actors immediately after encounter start. A second 1280×720 capture records the wave-13 squad after three seconds of automatic movement. A new regression simulates the wave-12 victory that triggers the zone swap and verifies all six actor positions are unchanged by that presentation transition. The full Godot suite passes. The configured formation offsets and automatic speeds remain unchanged.
- Backline floating concern: latest actual-scene capture shows grounding shadows under every ally/enemy and floor seams plus perspective lines across the upper walkway, where the three back-depth lanes stand. Visual capture: `docs/visual_qa/modular_zone_positions_after_3s_1280x720_2026-10-24T07-54-12.png` (1280×720). Godot 4.7.2 `--headless --path . --script res://tests/test_runner.gd` passes, including shadow count, render order, and lane/contact alignment. No combat coordinates or internal movement speeds changed. Godot reports a non-fatal sandbox `user://logs` write warning.
- Carryover-HP retreat validation: Godot headless suite passes. Natural simulation clears through wave 5 and reaches full defeat at holding wave 5 after 80.2 simulated seconds with the current provisional ramp. The display-capable `tests/capture_retreat_recovery_qa.gd` passes and captures the six-member defeat plus full-health re-entry. Latest inspected captures: `docs/visual_qa/carryover_hp_full_squad_defeat_1280x720_03.png` and `docs/visual_qa/carryover_hp_holding_wave_recovery_1280x720_03.png`. The final capture pair reflects a rendered defeat pose; earlier initial black/incomplete captures are superseded. Saves now preserve each ally's current HP. The capture reported non-fatal sandbox warnings for `user://logs` and shader-cache writes.
- Focused combat-presentation QA: new `tests/capture_combat_presentation_qa.gd` captured a 1280×720 advancing six-ally formation and a BREAKER hit reaction. Its assertions require all six allies active, at least four walking and moved from initial positions, real CombatDirector damage to BREAKER, hit-state presentation by the rig, and the ground shadow remaining below the actor. Latest captures: `docs/visual_qa/six_actor_movement_1280x720_03.png` and `docs/visual_qa/breaker_hit_pose_1280x720_03.png`. Helper passed, then the full Godot 4.7.2 headless prototype suite passed. Visual review found ground contact holds in both frames; no combat or rig adjustment was needed. Godot emitted non-fatal sandbox warnings for `user://logs` and shader-cache writes during the display-capable capture.
- Historical same-monitor GUI observation under the superseded full-heal-at-each-wave rule: wave 21 defeat returned to wave 20 with all six active and BREAKER at full HP. Captures: `docs/visual_qa/automatic_enemy_hit_2026-10-24.jpg` and `docs/visual_qa/full_squad_retreat_reentry_2026-10-24.jpg`. No Save action was pressed. The current carryover-HP rule and retreat recovery are covered by the more recent automated and display-capable checks below.
- Local Git status: the selected project folder has no .git metadata. The current 2026-10-26 I-13 audit found no general GitHub repository-read connector; public web could not read the exact repository URL (Cache miss), its exact API endpoint was inaccessible, and exact-site search found no match. Remote repository identity, visibility, metadata, and top-level files remain unverified; this does not establish absence, privacy, or emptiness. See docs/MIGRATION_REPORT.md.
- Source connectors (2026-10-24 update): Notion read-only fetch/search now succeeds; all eight canonical child pages plus Project HQ were fetched and saved locally under `Notion/Live Readbacks/`. The unresolved BREAKER source conflict is recorded in `docs/OPEN_QUESTIONS.md`; Google Drive and GitHub remote state were not verified in this turn.
- Local sync-folder milestone: current project docs, reconstructed handoff pages, and the latest viewport captures are copied under `Notion/`; offline artwork, QA screenshots, and the numbered Drive library layout are staged under `Google Drive/`. The local document copies are refreshed after the offline, autosave, research-framework, and art-review pass. A locally verified source snapshot remains staged under `Google Drive/05 - Godot Project Backups/`; caches and staging folders are excluded. Asset copies were SHA-256 checked, and Godot 4.7.2 scanning passed without importing the staging folders. No remote upload or backup was performed or verified.

## Next milestone

The evolution HUD and offline-claim HUD have display-capable checks at 1280×720 and 800×450; the BREAKER purchase result also survives a two-process probe. Offline claims use one ordinary holding-wave reward per hour, capped at eight hours, saved before live apply, and never advance waves. Successful wave clears now autosave permanent rewards and the full current run, while protecting an existing save that has not yet been loaded; failed writes retain session progress and ask for manual Save. A read-only Research dialog and save-safe purchase framework list all four branches without adding unapproved nodes or effects. Next progression work is source-approved research node design and broader roster integration. The offline rate, combat/release balance, canonical bosses/district content, migration policy, and production-ready BREAKER part work remain open. Keep quarantined art out of runtime; live Notion read access has since been checked, and complete Notion/Drive reconciliation remains pending.

## BREAKER Tier I art and pivot review — 2026-10-24

Reviewed atlas drafts 01 and 02 against the available BREAKER Tier I production specification and inspected the isolated head-candidate preview. Draft 02's exposed torso conflicts with the spec's sleeveless dark vest direction; Draft 01 appears closer, but neither atlas has validated crop bounds, common scale, pivots, seams, or assembled poses. The head candidate's proposed `(571, 1156)` pivot maps to the head-bone origin at the 29-unit test height and left/right mirroring behaves as expected; visual inspection shows a style/scale mismatch against the code-drawn body. All three images remain quarantined and unused in the main scene. No art was changed or promoted.

Validation run on Godot 4.7.2: `--headless --script res://tests/test_runner.gd` passed; `--headless --quit-after 120` main-scene launch passed. Both emitted the known non-fatal `user://logs/godot.log` write warning. These checks validate code/tests and scene startup, not production-art readiness.

## BREAKER Tier I full-anatomy visual trial — 2026-10-24

The user approved Draft 01 as the base for a complete anatomy review. Generated three flattened full-body candidates; trial 03 is preferred after a focused knee-support revision. It has a closed vest covering the torso, painterly BREAKER identity anchors, trousered legs, grounded boots, a softer strap/brace treatment, and the oversized right cybernetic fist. The brace may still read larger than the written subtle-knee detail. The 1024×1536 RGBA file has transparent corner pixels and is quarantined in `assets/characters/breaker/tier_01_drafts/`; a local-only copy is staged in `Google Drive/02 - Character Sprites/`. It is not split into parts or connected to a rig, so facing/deformation/action animation checks have not been performed on this candidate. No runtime scene/code changed. Godot 4.7.2 headless full test suite passed, as did a 120-frame main-scene launch; both reported only the known non-fatal `user://logs/godot.log` write warning.

## BREAKER modular review extraction and rig-gate audit — 2026-10-24

The earlier generated atlas and 18 fixed-cell RGBA crops remain quarantined for audit history only. A source-faithful attempt was assessed against `BREAKER_T1_full_anatomy_trial_03.png`: this single flattened guarded pose has the cybernetic arm/fist crossing and occluding the torso, limbs overlapping at the shoulder and waist, and legs posed together. Hidden anatomy cannot be recovered from its pixels without inventing content, and it has no joint cut boundaries or pivot annotations. Therefore no safe source-faithful parts or margins could be produced. Step 1 is FAILED/INCOMPLETE; step 2 scale/pivot/seam/neutral-assembly validation is FAILED/INCOMPLETE; step 3 deformation testing is BLOCKED and no rig was built. Existing cell-crop checks (18 files, 256×341/342 cells, transparent corners) only describe the failed atlas, not valid part assets. No Godot tests were run during this source-art audit because no runtime code or assets changed; the most recent prior suite pass is recorded above. Local staging is preserved and clearly marked failed; remote Notion/Drive reconciliation and upload remain deferred.

## Neutral-pose and modular-atlas crop audit — 2026-10-24

Inspected three additional generated inputs and copied them to the quarantined draft folder plus local Drive-labeled staging. The neutral-pose preview is RGBA 1024×1536; exact alpha scan found 1,051,677 alpha-zero pixels, 521,187 partial-alpha pixels, and zero opaque pixels. It has clear corners but the semi-transparent atmospheric pixels mean it is not a clean character cutout. Two 1536×1024 atlases show 18 apparent grid parts but are generated interpretations, not source-faithful splits. On the refined layout, exact cell scans found 0/18 cells with an 8 px fully transparent margin; all cells have alpha bounds touching or nearly touching an edge, with semitransparent halo extending to cell edges. Therefore no new safe crops were produced. Step 1 remains FAILED/INCOMPLETE; step 2 remains FAILED/INCOMPLETE; step 3 deformation harness remains BLOCKED and was not run. No runtime files changed; no Godot tests were run during this asset-only audit. Remote sync remains deferred.

- BREAKER head-art viewport trial (Godot 4.7.2 GUI, 2026-10-24): isolated preview scene rendered both facings and wrote a 1280×720 PNG. The attached image tracks the head pivot and mirrors correctly while the ground line remains stable. Visual review rejects integration at this stage because the detailed head cutout reads as a different style/scale from the polygon torso; no claim is made about animation-ready parts or deformation. The preview harness does not load in the main scene. The full headless prototype suite and a 120-frame main-scene launch were rerun after this trial and both exited 0; the non-fatal `user://logs/godot.log` permission warning persists.

## Evolution milestone and unlock transaction — 2026-10-24

After user approval, added prototype gates for Combat Grade (wave 25, 1 Evolution Data), Military Grade (wave 75, 2), and Apex Grade (wave 125, 3), per recruit. `evolution_service.gd` computes the next tier for the twelve approved recruit IDs, rejects invalid IDs/tier state, and returns a copied permanent state with tier recording and material deduction together. The BREAKER HUD shows its next tier, milestone, cost, available material, and eligibility. Eligible activation saves the new permanent state with the current run before applying the result in memory; failed save leaves the live tier/material balance untouched. HUD feedback discloses that stat/art effects remain pending. Tests cover gate values, sequential unlocks, all roster IDs, blocked purchases, material accounting, current-run persistence, and failed-save atomicity. Godot 4.7.2 full headless suite passed locally and in the independent test lane (exit 0); both 120-frame main-scene launches passed (exit 0). Editor filesystem scan/class registration/import completed, but editor settings/cache writes were blocked by unavailable AppData/Godot user-profile paths; clean editor setup validation is not confirmed. Headless screenshot capture was attempted but the dummy renderer cannot supply viewport textures, so no new visual captures were generated. The known non-fatal `user://logs/godot.log` warning appeared. No artwork was promoted; values are prototype feasibility trials, not release balance.

## Evolution HUD visual review — 2026-10-24

Created `tests/capture_evolution_hud_preview.gd`, a display-capable capture helper that supplies disposable in-memory eligibility (`highest_wave_ever=25`, 1 Evolution Data) without loading or saving user progress. Actual Godot/OpenGL captures were reviewed at 1280×720 and 800×450. The evolution requirement fits both; review found the secondary automatic-combat caption touched the panel at the narrow viewport and the enlarged HUD nearly occluded squad heads. The caption now hides below 960 px width and the narrow HUD scale cap is 1.16. Full Godot 4.7.2 suite and 120-frame main-scene launch passed locally and were independently rerun in the test lane after the adjustment (all exit 0). Final captures are `docs/visual_qa/evolution_gate_1280x720_06.png` and `docs/visual_qa/evolution_gate_800x450_06.png`. UI remains code-drawn prototype presentation, not final UI art. Godot logged sandbox-only user-log and shader-cache warnings.

## BREAKER approved profile rig trial — 2026-10-24

Built an isolated Godot review harness at `tests/breaker_profile_rig_trial_01_preview.tscn` using the 13 source-pixel layers in `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/`. Bone2D pivots are read from the trial manifest and remain provisional. The first run found a test-harness defect: dynamically created Bone2D nodes had zero rest transforms. After initializing the rest pose from the assembled neutral hierarchy and disabling automatic leaf-bone length inference, Godot 4.7.2 headless validation passed. The test confirms all 13 textures load, neutral sprite origins align to the shared source canvas, idle/walk/punch/hit animation tracks move their intended pivots, and the ground anchor stays fixed. The full Godot prototype test suite and 120-frame main-scene launch also passed (exit code 0). The only remaining log message is the sandbox's non-fatal inability to write `user://logs/godot.log`.

This is a structural and animation-track smoke test only. It does not validate rendered joint seams, hidden anatomy, continuous deformation, or production-ready animation. The profile parts remain quarantined and are not referenced by runtime. A visual Godot capture and seam review were outstanding at that point; the later walk review below records the follow-up.

## BREAKER profile walking simulation — 2026-10-24

Added `tests/breaker_profile_walk_simulation.tscn` as a separate review scene that loops the 0.65 s walk clip while translating BREAKER across a stationary stage. Its 44 px/s travel rate and 390–890 px lane are review fixtures, not game combat movement data or player settings. The dedicated 60 FPS Godot 4.7.2 headless test ran 210 frames: **PASS**, five complete walk cycles, both hip pivots swung in both directions (left −0.120..0.114 rad; right −0.114..0.120 rad), 154 px horizontal travel, and 0 px ground-anchor vertical drift. All 13 layers stayed loaded. The complete prototype suite and a 120-frame main-scene launch also passed after the addition.

This verifies animation playback and stage translation, not rendered seam quality or continuous deformation. A headless Movie Maker capture was attempted but the dummy renderer returned a null texture and crashed; its empty temporary output was removed. No visual capture was produced in this run. The art remains trial-only; runtime/combat were unchanged.

## BREAKER walk visual seam review — 2026-10-24

Reran the isolated walking scene through Godot 4.7.2's display-capable OpenGL Compatibility renderer and Movie Maker at 1280×720, 60 FPS, 210 frames (3.5 seconds), exit 0. The result was visually reviewed as 20 sampled poses and a 105-frame looping GIF: `docs/visual_qa/breaker_profile_walk_trial_01_contact_sheet.png` and `docs/visual_qa/breaker_profile_walk_trial_01.gif`. The exposed shoulder, elbow, pelvis, hip, knee, and ankle joins remained visually connected in the sampled frames; no major detached part or ground-anchor hop was apparent. This is a sampled still review, not a pixel-continuity proof for every rendered frame.

The review also shows the gait is restrained and the 44 px/s preview translation is not synchronized to planted-foot phases, so some foot glide is visible. This speed is a review-only fixture. `Skeleton2D` currently rotates rigid full-canvas part sprites; it does not perform mesh deformation or restore hidden anatomy at occluded joints. Those remain unresolved before production approval. No runtime scene or combat data changed. The separate headless capture attempt above remains a failed capture; the display-rendered run succeeded.

### Explicit profile-rig validation record

| Area | Result | Evidence and limit |
|---|---|---|
| Scale | **Coherent at user-reviewed preview scale; strict visible-height target not met.** | Canvas is 1024×1536, fitted to 256 px (`1/6`). Alpha ≥245 bounds `(238,47)–(794,1474)` yield a 1427 px source silhouette, about 238 px at preview scale. The user approved the assembly's coherence at the 256 px preview setting; this does not change the 256 px foot-to-hair specification or authorize scale adjustment. |
| Pivots | **Transform plumbing passes; pivot accuracy provisional.** | Manifest carries 14 estimated source-pixel pivots; Godot loads them, keeps neutral layers aligned, animates the tested joints, and preserves the ground anchor. The points are hand-estimated and were not authored from a neutral turnaround. |
| Seams | **Sampled visual coherence passes; complete seam certification remains open.** | User reviewed neutral/walk/punch/hit previews at the configured 256 px target and found them coherent. The display-rendered 60 FPS walk capture had no major detachment in 20 sampled poses. An independent static pixel audit confirmed 440,938 thresholded silhouette pixels, zero uncovered pixels, zero visible RGB mismatches, binary visible alpha, and no pixels outside the thresholded silhouette. This does not establish pixel-perfect contact at every joint over every frame; visible foot glide remains in the translating test fixture. |
| Deformation / segmentation | **Not implemented or validated for production.** | The scene rotates rigid Sprite2D layers under Bone2D pivots. No mesh skinning, hidden anatomy at overlaps, wrist/hand/finger joints, or deforming joint fill exists. `head_neck`, each forearm with its hand/fist, and each boot with its foot are combined images. |

The pixel audit compares `assembled_neutral.png` to the alpha-thresholded source (source alpha ≥245). It validates the current neutral extraction, not deformation or moving seams. Earlier failed-mask and uncovered-pixel entries below are historical intermediate exporter revisions and are superseded by the current neutral reconstruction and walking-rig records above; quarantine status is unchanged.

The isolated walk regression was rerun with Godot 4.7.2 at fixed 60 FPS: **PASS**, exit 0, five 0.65 s cycles, left hip −0.120..0.114 rad, right hip −0.114..0.120 rad, and world-anchor delta `(154, 0)`. Godot printed the known sandbox warning that `user://logs/godot.log` could not be written; it did not affect the test result.

Overall: keep this as a coherent **trial assembly**, not animation-ready production art. Runtime remains untouched.

## BREAKER modular parts trial 01 — 2026-10-24

The user-approved individual component previews were staged under `assets/characters/breaker/tier_01_drafts/modular_parts_trial_01/` without modifying source PNGs. Added a pivot/readiness manifest and isolated Godot review scene at `tests/breaker_parts_trial_01_preview.tscn`. The harness loads ignored draft PNGs directly from disk, assembles a provisional 256 px reference-height figure, keeps the visual ground root fixed, and supplies isolated idle/walk/punch/hit transform animations. Captures are `docs/visual_qa/breaker_modular_parts_trial_01_{neutral,idle,walk,punch,hit}.png`.

Godot 4.7.2 rendered all five states and the harness assertions passed: all 13 image instances (12 unique PNGs, with the reusable boot used twice) loaded; walk, punch, and hit tracks changed their intended pivots; and the visual root stayed on its ground anchor. The first 2× review exposed disconnected seams. Estimated harness pivots/offsets were adjusted, and a later alpha-contact audit was added for 12 representative joins and both boot soles. Those contacts pass in sampled neutral/walk/punch/hit frames. **Provisional joint-fit review: PASS at sampled points only.** Component angles and texture transitions still need cleanup, and continuous deformation, animation-ready exports, and a production rig are not validated. The contact checks sample local neighborhoods near each joint; they do not prove every pixel along a seam. No runtime scene, combat logic, saves, or production rig changed. Do not promote these images or treat the provisional transforms as approved rig data. Current captures: `docs/visual_qa/breaker_modular_parts_trial_01_neutral_zoom.png`, `..._walk_zoom.png`, `..._punch_zoom.png`, and `..._hit_zoom.png`.

Godot logged the known non-fatal `user://logs/godot.log` and shader-cache write warnings in this sandbox. Local Notion/Google Drive staging copies were refreshed and hash-checked; no remote Notion fetch/update or Drive upload was performed or verified.

## BREAKER Tier I proportion review — 2026-10-24

The user noted that the connected modular assembly's proportions looked wrong. The isolated review harness was adjusted again: the visual root is 1.12× wider with the same 256 px target height and fixed ground anchor; hip offsets are now ±28; the waist/hips were moved up 10 local units and the lower legs extended to preserve boot contact; torso, pelvis, thigh, and shin widths were increased; and the cyber arm/fist were enlarged. These are temporary art-fit transforms, not skeleton/pivot approvals. A separate concept-only proportion study, `docs/visual_qa/breaker_tier1_proportion_study_01.png` (1024×1536 PNG; opaque dark backdrop), was generated from the approved Trial 03 image for visual comparison; it is not an animation asset and is not used by runtime. The reference art is a single dynamic three-quarter pose, not a neutral proportion chart, so exact anatomical ratios cannot be declared canonical from it. The adjusted assembly remains a visual-review candidate awaiting user acceptance; no runtime scene, original part image, combat logic, save, or production rig was changed.

## BREAKER Tier I connection audit — 2026-10-24

Added alpha-pixel contact assertions to the isolated preview harness after the user asked to verify proportions and connections. The tests check 12 representative joins (head/neck, torso/pelvis, pelvis to both thighs, both shoulders, both knees, both ankles, human elbow, and cyber wrist) and both boot soles against the ground line. They run in neutral, walk, punch, and hit captures. A first run found a 2 px head/torso seam; the torso edge was extended slightly and the rerun passed. All 12 joins now have opaque source pixels touching/overlapping within 1.4 viewport pixels near the tested joint in each of the four sampled poses; the boot soles are 0–2 px from the ground line. The harness now exits nonzero on any failed check; all four Godot 4.7.2 capture processes exited 0. The main test suite was not rerun because production/runtime files were not changed. This validates local contact at sampled points and frames, not every pixel along a seam or continuous deformation between frames. The 256 px reference-height fit and fixed root remain preview settings. Exact proportions remain a visual review because the approved source is not a neutral side-view turnaround and the component images have no shared authored scale/pivots. None of the parts are production-ready or in runtime.

## BREAKER reference-fidelity audit — 2026-10-24

Compared the current modular assembly with `BREAKER_T1_full_anatomy_trial_03.png` and the Tier I models on concept boards 01/04. The user reports the preview still looks very different; visual audit confirms that feedback. The contact tests only prove sampled pixel proximity, not likeness. Trial 01 has an open human hand instead of the guarded fist, a claw-like cyber hand instead of the signature closed fist, an extended arm pose unlike the boxer stance, and visible hip/leg silhouette and perspective mismatch. Record local contact checks as **PASS** and reference fidelity as **FAILED**; do not promote trial 01. Side-by-side evidence is `docs/visual_qa/breaker_reference_fidelity_comparison_01.png`. A reference-guided concept generation also retained the three-quarter pose and opaque background, so it was not added as a replacement. Existing component PNGs and trial transforms remain quarantined; runtime uses none of them. The next art pass must start from one coherent neutral right-facing Tier I reference, then produce all parts at a shared scale with deliberate joint overlap. Exact neutral-pose ratios remain to be reviewed against that base; no gameplay or runtime architecture decision is affected.

## BREAKER connected-anatomy redraw candidate 01 — 2026-10-24

After approval to begin a redraw, generated and locally preserved `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png` (1024×1536). The figure is a single coherent image and follows BREAKER's equipment and palette, but it is a significant pose reinterpretation: the natural fist hangs low instead of guarding high, the cyber fist hangs beside the hip instead of crossing the torso, and the stance/torso/leg silhouette is narrower and straighter than Trial 03. The background also remains visible; sampled alpha contains no fully transparent pixels. Reference comparison: `docs/visual_qa/breaker_profile_rebuild_candidate_01_comparison.png`. **Candidate 01: NOT ACCEPTED for part extraction.** No rig parts were split, no runtime art changed, and no Godot tests were run for this asset-only pass. Next redraw must preserve the reference's raised natural fist, low cross-body cyber fist, broad shoulders/hips, and flexed boxer stance before any joint segmentation.

## BREAKER profile candidate approval update — 2026-10-24

The user subsequently approved `BREAKER_T1_profile_rebuild_candidate_01.png` as the Tier I visual direction. This supersedes the earlier review rejection of its appearance. Use this exact image as the source for the next part-separation pass. The source still has a visible backdrop and remains a single image; no transparent parts, pivots, or rig tests exist yet. **Approval scope: visual direction only.**

## BREAKER profile rig mask pass 01 — 2026-10-24

The user approved the parent profile candidate as the visual direction. A local script exported 13 full-canvas mask layers from that single image. Visual QA failed: hand-estimated masks retained large backdrop polygons, had angular contours, and clipped through the face/arm; the silhouette mask self-intersects. The exports are quarantined in `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/` and are not acceptable parts. The source candidate remains approved for appearance only. No runtime art changed and no Godot tests were run. Next, replace the crude masks with deliberate contour tracing plus painted overlap/hidden anatomy before further rigging.

## BREAKER profile rig mask refinement 02 — 2026-10-24

The user-approved candidate contains an alpha matte that separates most background glow from the figure. The exporter now uses an alpha threshold for the shared silhouette and clips all 13 part polygons to it. The assembled neutral preview is substantially cleaner and reads as the approved figure, but the coverage check reports 16,148 uncovered silhouette pixels and exact reconstruction **FAILS**. The exporter completed and all 13 1024×1536 part PNGs decoded; this verifies file generation only. Inspect `uncovered_mask.png` and `assembly_difference.png` for the remaining gaps. Parts remain quarantined; pivots, hidden joint fills, motion, and Godot rig behavior are unvalidated. No Godot tests ran.

## BREAKER neutral part reconstruction — 2026-10-24

Refined the part exporter to assign each source pixel to one part in back-to-front order, then add a small overlap margin at the joins. The exporter fails on missing coverage or a non-exact neutral composite. It passed locally: all 13 part PNGs decode at 1024×1536, the uncovered mask is empty, and `assembled_neutral.png` matches the thresholded approved candidate exactly. `parts_sheet_preview.png` shows the individual crops. This verifies only the static source pose and pixel coverage; the masks are estimated, hidden anatomy at occlusions is absent, pivots remain unvalidated, and no animation or Godot rig test has been run. Keep the art quarantined until joint deformation review.

## BREAKER hidden-anatomy audit — 2026-10-24

- The user requested direct hidden-anatomy verification. The audit **fails the readiness gate**: `tools/art/audit_breaker_trial_03_hidden_anatomy.py` checked 13 parts / 664,937 opaque layer pixels. Zero layer RGB pixels differ from the flattened source at the same canvas coordinate; zero are outside the source alpha>=245 silhouette. There are 173,588 pixels covered by multiple masks (40.62% of the silhouette), but these are repeated source pixels, not independently reconstructed under-paint. Three-or-more layer overlap affects 55,279 pixels.
- This confirms the earlier 2,472 sampled pivot contacts are insufficient evidence for hidden anatomy. The masks were expanded from visible source pixels and clipped to the silhouette; they do not reconstruct limb interiors behind overlaps. Hidden anatomy status is **NOT VERIFIED / FAIL for production readiness**. The candidate remains a close visible-art match to approved candidate 01, but rig correctness is not established.
- Candidate similarity and Godot rig plumbing checks remain PASS within their scope. Full project suite and main-scene launch remain PASS. No runtime linkage or gameplay change was made. Full audit method/evidence is in `docs/BREAKER_HIDDEN_ANATOMY_AUDIT.md`.
- A recursive local search found no `.psd`, `.kra`, `.ora`, `.aseprite`, `.ase`, or `.xcf` source layers. Available BREAKER art remains flattened PNG references; no hidden layer data can be recovered from the local source package.

## BREAKER inferred under-paint trial 04 — 2026-10-24

- Because no layered source was found, the user authorized a reversible inferred-art experiment. `tools/art/create_breaker_profile_trial_04_underpaint.py` created a separate `profile_rig_trial_04_inferred_underpaint/` with 13 added joint-local patches sampled along inferred part axes. Trial 03 and the approved reference were not changed. The source pixels in all visible layers are preserved.
- Static composite audit passed exactly against candidate 03's alpha>=245 silhouette; 120,693 underpaint pixels were added, 120,589 differing from the original same-coordinate source RGB. This proves the underlay is populated and does not alter the neutral composite. The fills are extrapolated texture, **not verified anatomical painting**.
- Godot 4.7.2 isolated trial check passed for 13 visible + 13 underpaint layers, 256 px review scale, same-bone parentage, lower underpaint z-order, five action channels and stable root. The sampled joint test passed 2,472 neighborhood checks over 206 poses at 60 Hz. Neither proves full-seam or anatomy correctness.
- A joint-stress capture with intentionally exaggerated pivots still shows visible artifacts, including leg/ankle breakup. Record stress visual review as **NOT PASSED**; do not promote the test. Capture: `docs/visual_qa/breaker_profile_trial_04_joint_stress_1280x720_02.png`; ordinary action sample: `docs/visual_qa/breaker_profile_trial_04_inferred_underpaint_actions_1280x720_02.png`.
- **Result:** visible reference fidelity remains good; hidden anatomy is still **INFERRED / NOT VERIFIED**, and production-art gate remains **NOT PASSED**. The trial is quarantined with no runtime references. Reproduction and limits: `assets/characters/breaker/tier_01_drafts/profile_rig_trial_04_inferred_underpaint/README.md`.

**Validation update — trial 04, 2026-10-24:** after underpaint z-order correction, the Pillow static audit passed neutral exact reconstruction; Godot isolated rig test passed; 2,472 sampled contact checks passed; full prototype suite passed; and main scene launched for 120 headless frames. Display joint-stress capture completed and visually shows residual artifacts under deliberately exaggerated pivots; this remains a human-review failure for promoting the underpaint draft. Godot sandbox logging and shader-cache warnings are non-fatal.

## BREAKER trial 04 intended-clip seam verification — 2026-10-24

- Added a stronger seam test: every contact neighborhood must contain at least 15 distinct adjacent opaque pixel pairs from the joint's visible/underpaint layers. All 2,472 samples pass across 206 frames at fixed 60 Hz; observed minimum is 35 adjacent pixels. This verifies selected neighborhoods in the actual idle/walk/punch/hit/defeat clips, not the full anatomical outline.
- Added the dedicated BREAKER trial-04 walk-gait regression. It passes alternating knee lift, ankle compensation, natural-arm counter-swing, subtle head response, loop closure and ground contact. The eight-phase full-cycle capture `breaker_profile_trial_04_walk_cycle_1280x720.png` visually shows connected joints at the 256 px target height.
- The deliberately exaggerated joint-stress pose remains only a diagnostic outside the authored clip ranges and exposes limits; those poses are not part of the playable clips. Do not generalize clip-range evidence to arbitrary articulation.
- Trial 04 therefore works as an **isolated prototype preview for the current authored clip ranges** and preserves the neutral source exactly. Underpaint remains inferred rather than semantically/artist verified. Production-art gate remains **NOT PASSED**; runtime does not use this rig.

## BREAKER Tier I art/canon audit rerun — 2026-10-24

- Compared the user-approved profile reference against the written Tier I production spec. The approved reference carries the identity anchors but uses a relaxed arm pose rather than a clear boxer guard. Created a separate, transparent guarded-pose review candidate to check that spec anchor without replacing the approved visual direction.
- Manual review: undercut/scars, dark sleeveless vest, small red neck regulator, crimson-lit enlarged right cybernetic arm/fist, dark trousers, boots, grounded stance, and human/unarmored left arm remain legible. The new guard widens/foreshortens the silhouette by pose. It is a generated interpretation, not approved final art; no clear higher-tier left-arm or spinal armor was introduced. Review sheet: `docs/visual_qa/BREAKER_T1_guarded_pose_canon_review_01.png`.
- Structural candidate audit passed: 1024×1536 RGBA with transparent corners and an in-bounds 1478 px figure. This is not a visual identity or anatomy test. Draft is quarantined, has no runtime references, and cannot supply its own hidden anatomical pixels.
- Re-ran Godot 4.7.2 full prototype suite, trial-04 rig structure, 2,472 intended-clip joint samples at 60 Hz, and dedicated walk-gait regression: all passed. Re-ran the trial-04 Pillow underpaint/composite audit: passed. Trial-03 source-pixel provenance audit still returns expected **NOT VERIFIED** (exit 2). Visual walk samples read connected at intended range; exaggerated joint stress still shows leg/ankle artifacts.
- **Status:** current isolated authored-clip preview works, but hidden anatomy remains inferred and not semantically verified; production-art gate remains **NOT PASSED**. Runtime still uses the separate code-drawn placeholder. No approved decision or existing artwork was replaced. Godot emitted a non-fatal `user://logs/godot.log` permission warning during headless runs.

The guarded-pose visual was also checked at the spec's true 256 px visible height using matching ground baselines. The comparison is `docs/visual_qa/BREAKER_T1_guarded_pose_256px_review_01.png`; its automated audit now checks the shared target-height composition and creates both review sheets. At this size the major identity anchors remain legible, and both boots read grounded. This remains a static pose/scale review, not a rig or hidden-anatomy pass.

## BREAKER candidate 05 / guarded rig trial 05 v4 — 2026-10-24

**Visual review: PASS as a Tier I draft; final art approval: PENDING.** The new guarded-pose candidate restores both forearm wraps, preserves the approved profile’s face/scars/undercut, neck regulator, sleeveless dark vest, enlarged crimson-lit right cyber arm and cross-body fist, human left arm, dark trousers, and boots. Side-by-side review at the production specification’s 256 px visible height keeps these anchors legible. The lower-body edit improved the foot baseline; the screen-half alpha bounds differ by about 32 source px (about 5.6 px at review scale), and both heels/toes read grounded against the shared QA floor. Review files: `docs/visual_qa/BREAKER_T1_guarded_pose_canon_review_05.png` and `docs/visual_qa/BREAKER_T1_guarded_pose_256px_review_05.png`. This is generated review art and is not user-approved final art or runtime content.

**Static rig feasibility: PASS.** Candidate 05 exports to isolated `profile_rig_trial_05_guarded_pose_v4/`. The reproducible audit `python tools/art/audit_breaker_guarded_trial05_v4.py` passes 13-layer neutral reconstruction against the source alpha>=245 silhouette, with 0 uncovered pixels; 89,272 inferred underpaint pixels were added, 89,218 of which differ from the source RGB at the same coordinates. The underpaint uses local color-axis extrapolation. This shows filled texture, not artist-authored or semantically verified anatomy.

**Godot checks: PASS within stated scopes.** Godot 4.7.2 passed the isolated 13-layer rig structure and 256 px fit, 2,472 selected joint-neighborhood samples across 206 poses at 60 Hz (minimum/maximum adjacent contact pixels 136/315), and the 0.65 s walk-gait regression (alternating knee flexion, ankle compensation, arm counter-swing, loop closure, stable root, and sampled sole contact). The full project test runner and main scene at 120 headless frames also passed after the candidate update. Godot prints a non-fatal sandbox warning because `user://logs/godot.log` cannot be written.

**Semantic hidden anatomy: NOT VERIFIED; production-art gate: NOT PASSED.** The source image is flattened. The trial’s hand-estimated pivots and underpaint cannot establish concealed anatomy, every-frame seam continuity, or deformation quality. `trial_05 v4` stays quarantined under `tier_01_drafts/` with no runtime links. A headless Godot Movie Maker capture was attempted and crashed in the dummy renderer on a null texture; no Godot walk screenshot/movie is claimed. Static visual evidence is available; a rendered clip capture remains a follow-up.

## BREAKER candidate 05 / single-owner rig trial 05 v8 and defeat preview v10 — 2026-10-24

**Static assembly: PASS for the stated source-reconstruction checks.** `profile_rig_trial_05_guarded_pose_v8/` assigns every visible source pixel to one of 13 layers. `python tools/art/audit_breaker_guarded_trial05_v8.py` passed: zero uncovered target pixels, zero visible pixels outside the target silhouette, zero multi-owned visible pixels, and exact neutral reconstruction. The 64 px color-axis underpaint contains 297,312 inferred pixels (296,989 differ from source RGB at the same coordinates). This is a texture extrapolation metric, not an anatomy assessment.

**Godot 4.7.2 isolated tests: PASS within scope.** The v8 rig structure/scale/pivot test passed; sampled contact passed across 2,472 joint/pose samples in 206 poses at 60 Hz (71–487 adjacent contacts per tested neighborhood); the 0.65 s gait test passed its alternating knee, ankle compensation, counter-swing, loop, and anchor checks. The main prototype suite passed, and the main scene ran for 120 headless frames. A new v10 fade regression passed with alpha 1.00 at start, 0.72 at 0.55 s, 0.00 at 0.95 s, and a stable world anchor. Every Godot run printed the known non-fatal sandbox warning that `user://logs/godot.log` cannot be written.

**Visual review and remaining failure.** The display-rendered v8 walk contact sheet at the spec's 256 px review height has no major detached parts in the sampled phases; this is a preview-level visual pass only. The v8 larger-collapse defeat animation is visibly torn at joints and is rejected. v9's restrained slump is clean but reads weakly; v10 adds a fade and is mechanically verified, but remains only a review option and was not approved as final defeat behavior. The comparison is `docs/visual_qa/BREAKER_T1_trial05_defeat_options.png`.

**Hidden anatomy: NOT VERIFIED; production-art gate: NOT PASSED.** The only source is flattened, and the inferred underpaint is not authored anatomy. Hands remain attached to forearms and feet to boots; pivots and segmentation are estimated. The generated candidate remains unapproved final art, quarantined, and absent from runtime. No project design decision is being made by these experiments. Runtime art and combat files were not changed; no remote Notion/Drive sync or Git commit was made.
## BREAKER Tier I canon review candidate 07 — 2026-10-24

A separate candidate was generated from the guarded pose to align more literally with the local written Tier I spec: human shoulder/upper arm, mechanical right forearm/fist, dark sleeveless vest, small neck regulator, low-profile left-knee support, human left arm, dark trousers, and combat boots. The source image and candidate 05 remain unchanged. Candidate 07 is quarantined, not user-approved final art, and has no runtime references.

**Static checks: PASS within scope.** The audit tools/art/audit_breaker_t1_canon_candidate_07.py passes RGBA/transparent-corner checks, uncut 1024×1536 bounds (alpha≥245 bbox 153,31–949,1490; visible height 1459 px), and both boot regions at the written 256 px review height (29 px source baseline delta = 5.09 px at review scale). The same-scale comparison includes the approved profile reference and candidate 05. Manual visual check finds the undercut/scars, guarded boxer pose, dark sleeveless vest, regulator, crimson oversized right fist, human shoulder/upper arm, wrapped human left arm, low-profile knee support, and boots legible; no clear Tier II–IV torso/left-arm/leg armor appears.

**Canonical reconciliation remains OPEN.** The user-approved profile includes shoulder/upper-arm machinery that candidate 07 removes to follow the written Tier I spec. Candidate 05 preserves more of that approved silhouette. The local Notion reconstruction is not a verbatim export. Live Notion has since been read; the arm-scope precedence remains unresolved. No final canon claim is made; both remain drafts pending owner choice and full source reconciliation. Candidate 07 is a static illustration only: it has not been rigged or animation-tested, and hidden anatomy remains unverified.
## BREAKER Tier I canon review candidate 07 — 2026-10-24

A separate candidate was generated from the guarded pose to align more literally with the local written Tier I spec: human shoulder/upper arm, mechanical right forearm/fist, dark sleeveless vest, small neck regulator, low-profile left-knee support, human left arm, dark trousers, and combat boots. The source image and candidate 05 remain unchanged. Candidate 07 is quarantined, not user-approved final art, and has no runtime references.

**Static checks: PASS within scope.** The audit tools/art/audit_breaker_t1_canon_candidate_07.py passes RGBA/transparent-corner checks, uncut 1024×1536 bounds (alpha>=245 bbox 153,31–949,1490; visible height 1459 px), and both boot regions at the written 256 px review height (29 px source baseline delta = 5.09 px at review scale). The same-scale comparison includes the approved profile reference and candidate 05. Manual visual check finds the undercut/scars, guarded boxer pose, dark sleeveless vest, regulator, crimson oversized right fist, human shoulder/upper arm, wrapped human left arm, low-profile knee support, and boots legible; no clear Tier II–IV torso/left-arm/leg armor appears.

**Canonical reconciliation remains OPEN.** The user-approved profile includes shoulder/upper-arm machinery that candidate 07 removes to follow the written Tier I spec. Candidate 05 preserves more of that approved silhouette. The local Notion reconstruction is not a verbatim export. Live Notion has since been read; the arm-scope precedence remains unresolved. No final canon claim is made; both remain drafts pending owner choice and full source reconciliation. Candidate 07 is a static illustration only: it has not been rigged or animation-tested, and hidden anatomy remains unverified.


**Godot static art decode — 2026-10-24:** Godot 4.7.2 passed tests/test_breaker_t1_canon_candidate_07.gd by decoding the draft directly from disk, checking its transparent corners, 1024×1536 canvas, 1459 px silhouette, and 5.09 px boot baseline difference when scaled to 256 px. The first resource-load attempt confirmed tier_01_drafts is excluded from Godot's import scan; the test was changed to direct Image.load so the draft stays quarantined and runtime-independent. This is a static image check, not a rig or motion test.

## BREAKER candidate 07 isolated rig review — 2026-10-24

- Candidate 07 was exported to `assets/characters/breaker/tier_01_drafts/profile_rig_trial_07_canon_v1/` without changing the runtime character or existing candidate 05. It uses a transferred, estimated pivot layout and 13 exclusive visible masks, plus extrapolated color underpaint. It remains quarantined and is **not production-ready art**.
- `python tools/art/audit_breaker_trial_07_canon_v1.py` passed: 13 single-owner layers, no uncovered/outside/overlapping visible pixels, exact neutral reconstruction; 294,771 underpaint pixels, 294,395 changed RGB pixels. This does not certify anatomy because underpaint is extrapolated texture.
- Godot 4.7.2 structure/scale/action test passed; the 2,472-joint-contact test across 206 poses passed (72–488 adjacent contacts in sampled neighborhoods); and the 0.65-second alternating walk-cycle regression passed. The full project test runner (`tests/test_runner.gd`) also passed. Ordinary rendered eight-phase capture succeeded at `docs/visual_qa/BREAKER_T1_candidate_07_canon_walk_cycle.png`. A five-panel action capture also succeeded at `docs/visual_qa/BREAKER_T1_candidate_07_canon_actions.png`, sampling idle, walk, punch, hit, and defeat. Manual review at 256 px shows connected-looking silhouette and no major part detachment in the first four samples; the defeat pose reads as a fall. These are sampled preview judgments, not an all-frame anatomy certification. A first headless capture attempt failed because the dummy renderer returned no viewport texture; the display-rendered retry passed.
- **Hidden/deformed anatomy remains NOT VERIFIED.** The source is flattened; underpaint is inferred rather than anatomically authored, hand/forearm and foot/boot remain combined, pivots were transferred, and these checks do not guarantee every-frame seam/deformation quality. No candidate-07 runtime links were found. Production art gate remains **NOT PASSED**.
- Live Notion direct-page readback is complete for the eight canonical child pages and HQ; snapshots are under `Notion/Live Readbacks/`. Text-only status updates were published and read back on HQ, BREAKER spec, Asset Library, Roadmap, and Decision Log; the five-action review follow-up was also published/read back on Asset Library and Roadmap. The remaining shoulder/upper-arm conflict is recorded in `docs/OPEN_QUESTIONS.md`.

## BREAKER Tier I neutral anatomy review candidate 08 — 2026-10-25

A separate 1024×1536 neutral-pose review illustration is quarantined under `assets/characters/breaker/tier_01_drafts/`. It tests the written-spec arm interpretation (human shoulder/upper arm; mechanical right forearm/fist) solely for visible anatomy review; the live Decision Log still shows this boundary unresolved against the previously approved profile image. The candidate is not canon, production art, or runtime content.

Static Python and Godot 4.7.2 image checks passed for decode, canvas/margins, 256 px review scale, and boot alignment. Manual static inspection found no obvious detached visible parts in the relaxed pose. Hidden anatomy, pivots, motion/deformation, and all-frame seams are NOT VERIFIED; a low-opacity fringe remains. Production-art gate remains NOT PASSED. Same-scale comparison: `docs/visual_qa/BREAKER_T1_candidate_08_neutral_anatomy_comparison.png`.

## BREAKER Tier I arm-extent decision board — 2026-10-25 UTC

Created `docs/visual_qa/BREAKER_T1_arm_extent_decision_board.png` with a reproducible Pillow builder. The board compares candidate 07 (written-spec reading: human shoulder/upper arm, mechanical forearm/fist) and candidate 05 (approved-profile reading: machinery through shoulder/upper arm) at the same visible height, with enlarged shoulder-to-forearm crops. Manual visual review confirms the intended visible difference is legible while both drafts retain the same guarded pose and core BREAKER identity anchors. This supports the owner's canon choice; it does not make that choice. Both remain quarantined and neither proves hidden anatomy or animation quality.

Validation: builder regenerated the PNG with an identical SHA256; output is RGB 1800×1370. No runtime code or character art was changed.

## BREAKER A/B art and rig revalidation — 2026-10-25 UTC

- Rebuilt and visually inspected `docs/visual_qa/BREAKER_T1_arm_extent_decision_board.png`. Candidate 07 and candidate 05 use the same guarded pose and matched 256 px visible height; enlarged shoulder/arm crops make the Tier I cyberware difference legible. The board is a decision aid only.
- Candidate 07: Godot 4.7.2 static image, rig structure, 2,472 sampled joint neighborhoods across 206 poses (72–488 adjacent alpha-contact pixels), and authored walk-gait checks PASS within scope.
- Candidate 05 v8: Godot 4.7.2 structure, 2,472 sampled joint neighborhoods across 206 poses (71–487 adjacent alpha-contact pixels), and walk-gait checks PASS within scope.
- Retargeted `tests/test_breaker_profile_rig_trial_05_joint_contacts.gd` from the obsolete v4 scene to the current v8 scene after revalidation found the old v4 seam regression failed at torso/pelvis (412 sample failures). The updated generic test now passes against v8. This does not alter the art or certify the old v4 rig.
- Candidate 03-to-02 visible-art fidelity passes (silhouette IoU 0.9761, RGB MAE 17.65/255, 3 px maximum bound drift). Candidate 08 static image checks also pass within scope.
- Trial 03 source-pixel provenance remains **HIDDEN ANATOMY NOT VERIFIED**: all 664,937 layer pixels reuse the flattened source RGB. Its audit's exit 2 is the expected rejection, not a pass.

Historical status at the time: the arm-boundary choice was unresolved. The user later approved an external shoulder shell over biological upper arm with a mechanical prosthesis beginning at the elbow; see the current decision entry below. No art is promoted. The production-art gate remains NOT PASSED because neither flattened source can prove hidden anatomy, full seam continuity, or deformation quality.

## BREAKER Tier I arm-extent reconciliation study candidate 09 — 2026-10-25 UTC

Candidate 09 is a quarantined, flat 1024×1536 review concept exploring the approved profile's shoulder-shell silhouette over a visibly human upper arm, with a mechanical right forearm/fist. It is not production art, runtime content, or proof of concealed anatomy. Its depiction is consistent with the later user-approved boundary, but it does not prove concealed anatomy.

Validation: the Python static audit passed RGBA decode, fully transparent corners, solid-silhouette bounds `(153, 32)–(950, 1492)`, 1,460 px visible height, and 5.44 px projected boot-baseline delta at 256 px review height. Godot 4.7.2 headless direct-image test passed the same decode/corner/scale/ground checks. SHA256: `a6319eec185b06ae2ef96f652855698687ecede1901095bf271405103a986506`. Alpha audit: 1,018,610 pixels are fully transparent, 554,254 are semi-transparent, and none are fully opaque (maximum alpha 254). Transparent corners and a solid-silhouette threshold pass; a clean opaque cutout is NOT verified. These image-only checks do not test anatomy, pivots, rigging, motion, seams, or canonical compliance. Production-art gate remains **NOT PASSED**.

**Scope adjustment, per user on 2026-10-25:** missing layered hidden anatomy is no longer a blocker to unrelated prototype implementation or using candidate 09 for visible concept review. It remains a limitation on claiming anatomy verified and a gate before promoting production-ready Breaker art/rig. The arm-boundary question was later resolved by explicit user approval; candidate 09 remains a review reference only.


## BREAKER anatomy inspection board candidate 10 — 2026-10-25 UTC

Added `assets/characters/breaker/tier_01_drafts/BREAKER_T1_anatomy_inspection_board_candidate_10.png` with paired provenance JSON/README. Manual review confirms the board clearly distinguishes an assembled shoulder-shell silhouette, a shell-removed view with visible human upper-arm volume, and a mechanical forearm/fist. Its exploded and cutaway panels are illustrative generated views and add surface details (including wraps/underlayers) that are not canonical decisions. This does not establish the true concealed anatomy, rig topology, or animation continuity. The earlier statement that it did not settle the arm-boundary conflict is historical; the user later approved the visible boundary. The artifact remains quarantined, review-only, and absent from runtime. Hidden anatomy: **NOT VERIFIED**; production-art gate: **NOT PASSED**. The requested milestone sync check interval is four hours; existing local automation already matches this cadence.


## BREAKER Tier I anatomy and canon evidence recheck — 2026-10-25 UTC

Live-source recheck: Notion BREAKER Specification fetched at `2026-10-25T04:42:28.408Z`, Decision Log at `2026-10-25T04:04:03.481Z`, and Project HQ at `2026-10-25T04:49:38.237Z`. The written spec still calls Tier I mostly human with a mechanical right forearm/fist; the approved profile still carries shoulder machinery. No newer explicit boundary decision was found.

**Visible anatomy evidence improved, but is not full anatomy verification.** Candidate 05 v8's `cyber_upper_arm` visible mask contains both the shoulder-shell pixels and the exposed skin patch; the reproducible audit found 3,115 warm-skin-heuristic pixels in the right-shoulder ROI owned by this arm layer, versus 0 in the opposite `natural_upper_arm` there. Manual inspection of the same-scale approved-profile comparison confirms the recognizable scarred face/undercut, guarded stance, oversized right fist, dark red/black palette, visible upper-arm skin and grounded boots remain legible at the specification's 256 px visible height. `docs/visual_qa/BREAKER_T1_trial05_v8_arm_mask_ownership_audit.png` is a mask-ownership visualization, not a new character asset.

**Executed validation:** `python tools/art/audit_breaker_trial05_v8_arm_masks.py` passed and generated a 1200×900 RGB audit board (SHA256 `03fc93e601df995913c457158a12f6d8c51c6aa373f4d35f19cbb540ea67c626`). `python tools/art/audit_breaker_guarded_trial05_v8.py` passed 13 single-owner layers, full visible coverage, and exact neutral composite; its 297,312 underpaint pixels remain inferred color texture. Godot 4.7.2 console headless tests passed the isolated rig's 13-part load, 256 px scale, five pose channels and stable anchor; 2,472 selected joint/pose samples across 206 poses at 60 Hz (71–487 adjacent contacts); and gait checks. Candidate 09 Python and Godot 4.7.2 static image checks passed bounds, transparent corners, visible scale and grounded boot alignment. The full `tests/test_runner.gd` prototype suite passed. Godot emitted the known non-fatal `user://logs/godot.log` permission warning.

**Limits / gate:** the bicep and shoulder shell are fused in one upper-arm image layer; under-shell anatomy is still inferred; no all-frame anatomical/deformation audit exists; sampled defeated pose is not yet an unmistakable, clean collapse. Thus visible-clip contact has scoped evidence, while hidden anatomy and production art remain **NOT VERIFIED / NOT PASSED**. No runtime art changed. A generated isolated-arm attempt was rejected and not retained because proportions were too exaggerated and the shell was not separated cleanly.

A source-compatible interpretation worth owner review is to read the shoulder piece as external armor over a biological upper arm, with the prosthesis beginning at the elbow. It is not recorded as canon without explicit approval.


## User-approved BREAKER Tier I arm boundary and mask-split review — 2026-10-25 UTC

The user approved the interpretation: external shoulder shell over a biological upper arm, with the mechanical prosthesis beginning at the elbow. This resolves the canon boundary and aligns the approved profile with the written Tier I spec. It does not promote any draft image to production art.

The reversible v1 mask split preserves the source composite exactly (Python and Godot each report 0 visible-pixel differences; 4,178 skin-classified pixels and 22,564 shell/hardware pixels, no overlap). Manual review fails the usable-part criterion: the skin-only pixels are fragmented and do not form a coherent arm asset. Keep `profile_rig_trial_05_arm_split_v1/` as a rejected QA fixture only. The generated two-piece arm attempt was also discarded as off-proportion. The next art pass must author a continuous human upper-arm surface under the external shell, then validate assembly and motion; do not reuse the sparse skin mask as art.

## Arm-boundary integration review and rejected alpha experiment — 2026-10-25

- User-approved canon is now explicit: the external shoulder shell sits over a biological upper arm; the mechanical right prosthesis begins at the elbow. This resolves the prior conflict between profile art and the written forearm description. It does not approve any current image as production art.
- Candidate 09 visually communicates the approved boundary at review scale. Its static Python audit and Godot decode test pass: 1024×1536 RGBA, solid visible bounds `(153, 32)–(950, 1492)`, 1,460 px visible height, projected boot delta 5.44 px at a 256 px review height. Hidden anatomy, rig pivots, motion and continuous seams remain NOT VERIFIED.
- Re-ran the full Godot prototype suite, candidate 09 static-image test, trial 05 v8 rig test, and 2,472 sampled contact checks across 206 poses at 60 Hz; all passed within their stated scope. The candidate 09, guarded-pose layer ownership and arm-mask audits also passed. The known non-fatal Godot user-log write warning persists.
- Evaluated the latest generated alpha-cleanup experiment without importing it. It retained 1024×1536 RGBA and the same alpha maximum (254); although its threshold silhouette IoU with candidate 09 is 0.995424, 1,370,832 RGBA pixels differ and 543,709 visible RGB pixels changed. It did not establish a clean cutout or preserve the source faithfully. REJECTED; no project art was replaced or added.
- Production-art gate remains NOT PASSED. The v8 split remains QA-only and is not a standalone arm asset. Continue art development from the approved candidate/reference direction with separate visible-pose and anatomy/rig gates.

This entry records the tests run before the candidate 09 v2 arm-ownership update below. Where statements conflict, the latest status at the top of this file and the explicit approved decision in `docs/DESIGN_DECISIONS.md` take precedence.

## Candidate 09 canon arm ownership v2 — 2026-10-25 UTC

Added a quarantined 13-layer trial under `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v2/`. It preserves the flattened source's visible RGB and exact neutral composite while reassigning the visible skin ROI from `cyber_forearm` to `cyber_upper_arm`. This is evidence for the approved visible layer boundary, not a claim of concealed-anatomy reconstruction.

Executed checks:

- `python tools/art/export_breaker_trial09_canon_v2.py` — PASS: one-owner layers and exact visible source reconstruction.
- `python tools/art/audit_breaker_guarded_trial09_canon_v2.py` — PASS: layer coverage/reconstruction and approved arm ROI ownership; 5,796 skin-classified pixels on upper arm, zero on forearm.
- Godot 4.7.2 `tests/test_breaker_profile_rig_trial_09_canon_v2.gd` — PASS: structure, 256 px scale, pose channels, anchor and ROI ownership.
- Godot 4.7.2 `tests/test_breaker_profile_rig_trial_09_canon_v2_contacts.gd` — PASS: 2,472 selected contacts across 206 poses at 60 Hz.
- Godot 4.7.2 `tests/test_breaker_profile_trial_09_canon_v2_defeat_fade.gd` — PASS: staged collapse/fade timing and anchor. This is a review harness behavior, not a finished authored defeat clip.
- Display-rendered Godot action/six-unit and defeat captures — PASS for capture; manual review sees stable identity/grounding, but idle/walk/punch/hit differences remain subtle at thumbnail scale.
- Re-run outcome this session: Python arm/layer audit and all four Godot commands above, including `tests/test_runner.gd`, passed. The export command was also invoked, but safely refused to overwrite its existing trial folder; no files were replaced. Known non-fatal Godot log-write warning appeared in headless runs.
- Review-only motion tuning: punch shoulder strike key increased from 0.22 rad to 0.48 rad with a small torso counter-rotation; hit torso/head/guard reactions were widened. The strengthened pose-threshold regression requires walk knee ≥0.10 rad, punch shoulder ≥0.35 rad, hit torso ≥0.08 rad, and defeat torso ≥0.25 rad. These are harness readability checks, not approved animation timing or production values.
- New display-rendered action review: `docs/visual_qa/breaker_trial09_canon_v2_four_actions_1280x720_02.png`; latest six-profile capture: `docs/visual_qa/breaker_trial09_canon_v2_six_unit_1280x720_06.png`. Manual inspection: punch is now clearer; walk remains visually restrained. No runtime character or combat code was modified.

No production art was promoted and no runtime scene changed. Continue to require independent shoulder-shell/upper-arm art, anatomy and pivot review, clearer action readability, and all-frame seam checks before the art gate can pass. The non-fatal Godot `user://logs/godot.log` permission warning remains present during tests.

## BREAKER Tier I arm components candidate 13 — 2026-10-25 UTC

Candidate 13 is a quarantined concept board, not runtime content or a production atlas. Its four panels visually communicate the approved boundary: external shell over a biological upper arm, with the prosthesis beginning at the elbow. A display-rendered Godot review shows the assembled reference beside manually aligned upper-arm, shell, and forearm atlas regions in neutral and 0.30-radian elbow-flex poses. Manual review finds the separate parts can be composed without an obvious gap at this estimated fit. The flex pose also shows overlap/shape mismatch around the elbow; exact pivots, anatomical continuity, hidden surfaces, and production animation are NOT VERIFIED. Production-art gate remains NOT PASSED.

Executed validation: candidate 13 Python bounds/scale audit PASS; focused Godot 4.7.2 direct-image test PASS; display-rendered assembly comparison PASS; full tests/test_runner.gd suite PASS. Python reports a rough 106 px same-scale overlap proxy (20.7% of forearm height), not a seam test. Headless screenshot capture is unsupported by the dummy renderer and failed as expected; the same capture passed with Godot's display-capable compatibility renderer. Godot also emitted the known non-fatal user log/cache write warnings.

Capture: docs/visual_qa/breaker_candidate13_arm_component_assembly_1280x720.png. No runtime scene or source art was replaced. Candidate 13 remains in the ignored draft folder pending further art work; the image is not uploaded remotely.

## Candidate 13 pivot-fit review follow-up — 2026-10-25 UTC

The first display capture exposed an offset in the review harness rather than a verified art defect. I adjusted the forearm region's estimated pivot to the visible elbow-cap center and recaptured. Manual review of docs/visual_qa/breaker_candidate13_arm_component_assembly_1280x720_02.png now reads the neutral and 0.30-radian flex poses as connected at review scale, with no obvious open gap. This improves the visible assembly check but still uses estimated pivots and rigid atlas regions; no author-approved pivots, hidden anatomy, full-body proportion match, or continuous animation-seam validation is established. Production-art gate remains NOT PASSED.

## Candidate 13 2D under-shell coverage check — 2026-10-25 UTC

Added a shell-off under-arm view and alpha-overlap checks to distinguish a complete visible 2D biological upper-arm surface from concealed anatomy assumptions. At the explicitly estimated review offsets, candidate 13 has 26,325 alpha pixels of shell/upper-arm overlap, 29,014 exposed upper-arm pixels, and 18,785 upper-arm/forearm overlap pixels; the combined 2D alpha union is one connected region. Godot 4.7.2 and the Pillow audit both pass these counts/thresholds; display capture shows shell-on, shell-off, assembled reference, and elbow flex. This supports visible 2D coverage and connection only. Biological accuracy, full-body scale match, authored pivots, concealed 3D structure, and all-frame animation seams remain NOT VERIFIED. Production-art gate remains NOT PASSED.

## Candidate 13 reference-scale and visible-surface checks — 2026-10-25 UTC

A dimension-based calibration now compares candidate 13 to the approved-direction full-body art used by the existing quarantined rig: reference body visible height 1466 px, reference cyber-arm layer union 422 px, candidate 13 assembled panel 813 px. At 0.519 component-to-reference texture scale, both arm extents are 73.7 px on the 256 px target body. This verifies an arm-height ratio only; the reference is a posed 3/4 image while candidate 13 is an isolated arm pose, so width/orientation/silhouette fit remain unverified.

The expanded Python and Godot 4.7.2 checks pass RGBA/panel integrity, reference-height calibration, 26,325 px shell-over-upper-arm coverage, 29,014 px exposed upper-arm surface, 18,785 px elbow overlap, and one connected binary-alpha union at estimated pivots. Shell-on, shell-off, elbow-flex and full-body scale review captures rendered successfully. The full prototype suite passes. Hidden biological accuracy, concealed 3D anatomy, author-approved pivots, intended-clip seams, and production art readiness remain NOT VERIFIED. Production-art gate remains NOT PASSED; no runtime art changed.

## BREAKER arm fit and underpaint review — 2026-10-25 UTC

The user confirmed the canonical boundary: an external shoulder shell sits over a biological upper arm; the right prosthesis starts at the elbow. Candidate 09 remains the closest visual source because its original flattened painted pose and materials are preserved. The candidate 09 v2 layer trial has exact neutral reconstruction and correctly assigns the exposed bicep ROI (5,796 skin-classified pixels on the upper-arm layer, zero on the forearm layer). This is a visible-source ownership result only; hidden anatomy and the separate shell layer remain unresolved technically.

Candidate 13 is rejected as a full-body proportion/silhouette match. The reference arm-layer union is 631×422 px (aspect 1.495); candidate 13's isolated assembled panel is 376×813 px (aspect 0.462). Matching height makes its horizontal width about 69% narrower than the reference. It remains a quarantined boundary-study only.

Two separate continuous-underpaint drafts were evaluated and rejected visually. The v3 source-sampled capsule has abrupt color bands; v4 mapping from the existing candidate 03 anatomy reference produces stripes and mottling. Neither was added to runtime or promoted as art. Both manifests mark them rejected. The earlier v2 backing also remains inferred and does not establish concealed anatomy.

QA artifacts: `docs/visual_qa/breaker_candidate09_v2_arm_layer_inspection_1600x1100.png`, `docs/visual_qa/breaker_candidate09_v3_underpaint_qa.png`, and `docs/visual_qa/breaker_candidate09_v4_donor_underpaint_qa.png`. Candidate 03 and 09 source crops are filed alongside for reference.

Executed validation on 2026-10-25 UTC: candidate 09 v2 Python ownership/reconstruction audit PASS; candidate 13 Python bounds/alpha audit PASS within its stated scope; Godot 4.7.2 candidate 09 rig/ROI test PASS; sampled contact test PASS (2,472 contacts across 206 poses at 60 Hz); defeat-fade harness PASS; candidate 13 focused image/alpha test PASS; full `tests/test_runner.gd` PASS. The tests do not establish hidden anatomy or production art. All headless runs emitted the known non-fatal `user://logs/godot.log` write warning. No runtime art changed; production-art gate remains **NOT PASSED**.

The text-only review status was published and read back from live Notion: BREAKER Specification `2026-10-25T06:46:58.040Z`, Asset Library `2026-10-25T06:46:59.870Z`, and Roadmap `2026-10-25T06:47:01.908Z`. No Drive upload is claimed; Google Drive tools were unavailable.

The candidate 13 regression check now measures width/aspect alongside height and asserts the explicit rejection metadata: 0.462 candidate aspect versus 1.495 reference aspect; 195.2 px versus 631 px width at matched height (69.1% narrower). Python and Godot 4.7.2 both pass this scoped rejection audit. The full prototype test runner passed again, and `rg` confirms neither candidate 13 nor v3/v4 underpaint is referenced by runtime `scenes/`, `scripts/`, or `data/`.

Godot 4.7.2 headless editor scan/reimport reached completion and the main scene ran for 120 frames (exit 0) with isolated temporary user data. The editor emitted a safe-save warning while writing Godot user/editor data; import progress completed, but the environment still does not provide a warning-free editor profile write.

This validation note was published/read back from live Notion at Specification `2026-10-25T06:52:26.594Z`, Asset Library `2026-10-25T06:52:28.740Z`, and Production Roadmap `2026-10-25T06:52:31.808Z`. No Google Drive upload is claimed.

## BREAKER Tier I hidden-arm underpaint study v5 — 2026-10-25 UTC

The approved Tier I boundary remains an external shoulder shell over a biological right upper arm, with the mechanical prosthesis beginning at the elbow. Candidate 09 v4 was re-audited: 14 exclusive visible layers reconstruct the thresholded source exactly; the canon ROI has 5,796 classified skin pixels on the biological upper-arm layer and zero on shell or forearm. Its Godot structure/pose test and sampled registration test pass five poses and 206 samples at 60 Hz.

To address the empty hidden surface, a shell-removed donor was generated from candidate 09 and used only to extract warm skin pixels under the original shell mask. The full generated edit is rejected as a replacement: 1,382,917 of 1,572,864 image pixels differ from candidate 09. The masked underpaint contains 18,066 pixels and the unchanged candidate 09 visible layers still reconstruct the exact neutral image with it beneath them. The shell-off QA board shows an uninterrupted human upper-arm volume, but the generated deltoid reads rounder than the original silhouette and source line fragments remain in the cutaway. This is an anatomy hypothesis for review, not accepted final component art.

Godot 4.7.2 `tests/test_breaker_profile_rig_trial_09_canon_v5_underpaint.gd` passes: the donor, visible bicep, and shell remain registered on the shared CyberShoulder through 206 neutral/60 Hz samples across idle, walk, punch, hit, and defeat. `tests/test_runner.gd` also passes: “All Neon Requiem prototype tests passed.” Headless runs still log a non-fatal failure to write `user://logs/godot.log`. Python v5 export/audit confirms the 18,066 selected pixels and exact neutral composite. No v5 asset is referenced by runtime `scenes/`, `scripts/`, or `data/`.

**Gate:** visible canon boundary and neutral art fidelity PASS within tested scope. The donor's shell-off proportions still need visual review; hidden anatomy is reconstructed rather than canonically authored; pivots are estimates; shell and skin share one bone; continuous deformation and clean production alpha remain NOT VERIFIED. Production-art/rig gate remains **NOT PASSED**. No runtime content changed and no Drive binary upload is claimed. QA: `docs/visual_qa/BREAKER_T1_candidate09_v5_underpaint_shell_off.png` and `docs/visual_qa/BREAKER_T1_candidate09_v5_generated_underpaint_roi_comparison.png`.

Notion text-only status was published and read back from the live BREAKER Specification (`2026-10-25T07:32:17.136Z`), Asset Library (`2026-10-25T07:32:27.257Z`), and Production Roadmap (`2026-10-25T07:32:34.151Z`). The readback includes the v4 visible split, v5 quarantined hidden-skin study, passing scoped tests, and outstanding visual/production gates. No image or binary was uploaded. Drive upload remains unavailable in this session.

## BREAKER Tier I arm continuity audit — 2026-10-25 UTC

The user's approved boundary is implemented as a review-only layer assembly: external shoulder shell over a biological upper arm; the mechanical prosthesis begins at the elbow. Repeated Python audits pass the v4 14-layer exact neutral reconstruction and classify the bicep ROI as 5,796 skin pixels on the biological layer, zero on shell/forearm. The v5 donor contains 18,066 hidden-skin pixels beneath the original shell and keeps the neutral composite pixel-identical.

A new 8-connected mask audit joins the visible and inferred biological skin into a 27,550-pixel largest component; both substantial visible-skin regions (>=100 pixels) belong to that component. The generated QA overlay is 1120x674 RGB; two consecutive runs produced identical SHA-256 `C3343A9C46CF9C47F04887CE569BC52B4DD172F0ECFDB67CDD28695A871CF42A`.

Godot 4.7.2 passes the v4 layer/pose test, the 206-sample contact/registration test, the v5 hidden-donor registration test, and the full prototype `tests/test_runner.gd`. All report the known non-fatal `user://logs/godot.log` write warning. This verifies 2D mask connectivity and shared-bone registration only; it does not verify biological accuracy, independent shell deformation, pivots, full animation seams, or production alpha. The donor remains a quarantined hypothesis, the shell-off proportion review is unresolved, and the production-art gate remains **NOT PASSED**. No runtime references were added.

Local QA preview: `docs/visual_qa/BREAKER_T1_candidate09_v5_connected_anatomy_overlay.png`. Local Google Drive staging contains a review copy only; no remote binary upload is claimed.

## BREAKER candidate 09 underpaint fit trials v6–v9 — 2026-10-25 UTC

The approved visible arm canon remains external shoulder shell over biological upper arm, with the mechanical prosthesis starting at the elbow. The flattened candidate 09 shell-on composite remains exactly reconstructable; v4 assigns 5,796 classified bicep-skin pixels to the biological layer and zero to shell/forearm. The v5 inferred donor also preserves the thresholded visible composition and joins the major visible skin regions.

Four local trials attempted to improve the shell-off anatomical contour. v6 used a constrained generated edit and yielded 15,993 underpaint pixels (versus v5's 18,066); manual review still sees an inflated rounded deltoid and residual image fragments. v7 contracted the mask horizontally by 8%, retained exact shell-on compositing and connected visible regions (23,625-pixel largest component), but visual review rejected it because the contour change was insufficient and edges fragmented. v8 filled 591 pixels around the v6 mask; the 25,592-pixel connected surface passes, but the visual silhouette did not materially improve. v9 builds a continuous underlayer from visible v4 skin and v6 pixels beneath the existing shell/straps; it adds 698 hidden pixels, yields a 26,226-pixel connected surface, and preserves the exact visible composition. Manual review still does not accept its shell-off fit.

Godot 4.7.2 passes v4 structure/pose, v4 206-sample registration, v5 206-sample registration, v9 206-sample registration, and the full prototype suite. The repeated non-fatal `user://logs/godot.log` write failure remains. Python audits pass source fidelity/connectivity; review-board output is deterministic. All v5–v9 drafts remain in `.gdignore`d folders and none are referenced by runtime scenes/scripts/data.

The 2×2 review board is `docs/visual_qa/BREAKER_T1_underpaint_visual_review_matrix.png` (1328×1598 RGB; SHA-256 `17BA6693ED7D1E9E63E8BB7BF811A3CA6A8D0ED3453134D8109F4F5BD99587FA`). Current result: the shell-on candidate matches the approved visible direction and arm boundary; hidden surfaces remain inferred, shell-off shape is not accepted, and production-art/rig gate remains **NOT PASSED**. These experiments do not alter canon or runtime content.


## BREAKER v13 v5 correction check — 2026-10-25 UTC

- Retained a second generated shell-off correction as `shell_off_anatomy_study_v2.png` and built `hidden_biological_upper_arm_donor_v5_full_shell.png` as a quarantined full-shell-mask hypothesis. No original candidate 09 asset or runtime resource changed.
- Python builder `tools/art/build_breaker_trial09_v13_v5_full_shell_underpaint.py` passes exact thresholded shell-on reconstruction across all 25,942 opaque shell-mask pixels. Godot 4.7.2 passes 206 neutral/60 Hz pose-registration samples for idle, walk, punch, hit, and defeat. The full `tests/test_runner.gd` suite passes. OpenGL capture passes baseline, 12-source-pixel shell shift, 0.16-radian shell rotation, and shell-hidden capture with stable ground anchor. Godot emitted a non-fatal `user://C:` directory / shader-cache warning under this sandbox.
- Visual inspection shows a modestly tighter shoulder contour, but it still reads oversized and round compared with approved candidate 09. The donor is **NOT ACCEPTED** as hidden anatomy or production art; keep it quarantined. Latest visual comparison: `docs/visual_qa/BREAKER_T1_v13_v5_shoulder_zoom_stress.png`.
- Tests confirm image-layer reconstruction and rig registration, not anatomy, authored pivots, continuous deformation, or production seams. Art gate remains **NOT PASSED**.


## BREAKER v13 v6 proportion trial — 2026-10-25 UTC

- Added a quarantined 82%-width shoulder hypothesis by compressing the generated shell-off source horizontally around the elbow-side center, then extracting the largest connected skin-classified component inside the arm ROI and original opaque shell. Python confirms 11,144 under-shell pixels and exact thresholded shell-on preservation.
- Godot 4.7.2 passes 206 neutral/60 Hz shared-transform samples across idle, walk, punch, hit, and defeat. The OpenGL stress capture passes baseline, +12 source-pixel shell shift, 0.16-radian rotation, and shell-hidden views with stable ground anchor.
- The side-by-side preview shows a narrower shoulder than v13 v4/v5, though generated texture seams remain. This is only a proportion study; keep it quarantined, not in runtime, and do not call it final art. User review is needed before adopting the narrower direction.
- The full suite passed on v5; v6-specific registration and stress capture passed. Godot continues to emit non-fatal user:// directory and shader-cache warnings under the sandbox.


### v13 v6 continuity measurement correction — 2026-10-25 UTC

A follow-up mask measurement found 20,723 combined visible/hidden skin pixels in 58 8-connected components; the largest connected surface is 20,505 pixels (98.9% of classified pixels). This is useful continuity evidence, but it misses the earlier 25,000-pixel screening threshold and includes 57 small detached components. Do not describe v6 as fully connected or anatomy-verified. The isolated shell-on and rig registration tests still pass; the visual art gate remains open.


## BREAKER approved-profile hidden-arm reconstruction — 2026-10-25 UTC

- Rechecked the live Notion BREAKER Specification (fetched 2026-10-25T08:37:57.606Z), Asset Library (08:37:59.478Z), and Decision Log (08:38:04.547Z). The live spec describes Tier I as mostly human with an athletic muscular silhouette and a mechanical right forearm/fist. The explicit user-approved boundary remains an external shoulder shell over a biological upper arm, with the prosthesis starting at the elbow. Local `docs/DESIGN_DECISIONS.md` identifies `BREAKER_T1_profile_rebuild_candidate_01.png` as the approved appearance target. Candidate 09 is only a reconciliation pose study; its v13 shoulder trials are no longer the art authority.
- Generated and quarantined a candidate01 shell-off anatomy study. Extracted v2 human upper-arm pixels (21,108) as a single 8-connected surface; a narrower 72%-width v3 variant contains 15,219 pixels. Both preserve the candidate01 shell-on assembly exactly at alpha threshold 245, and both overlap the candidate01 mechanical forearm so their binary-alpha union is one connected component (v2: 6,383 overlap pixels; v3: 4,732).
- Godot 4.7.2 registration tests pass 206 neutral/60 Hz samples for v2 and v3 through idle, walk, punch, hit, and defeat, with a stable ground anchor. The full prototype suite passes. Godot prints a non-fatal user-directory warning under this sandbox.
- Visual comparison is in `docs/visual_qa/BREAKER_T1_candidate01_hidden_arm_options.png`. The v3 cutout is more compact, but both are generated hypotheses and need art review; neither is production art or runtime content. The older `profile_rig_trial_01` part extraction has known polygon-mask holes, so its shell-off assembled screenshot is not used as evidence.
- Remaining: review the upper-arm contour against the approved profile, split the external shell into an independent authored part, clean hidden surfaces, and validate all-frame seams/deformation. Production-art gate remains **NOT PASSED**.

## BREAKER candidate01 arm-boundary review — 2026-10-25 UTC

The user reconfirmed the Tier I rule: the external shoulder shell sits over a biological upper arm, and the mechanical prosthesis begins at the elbow. This is consistent with the current approved appearance reference and live written specification.

An alpha split of the approved candidate01 `cyber_upper_arm.png` into visible biological skin (3,379 opaque pixels) and external shell (27,229 opaque pixels) reconstructs that source layer exactly. This is a static pixel-ownership check only. The v4 split has rough cutout edges, and the assembled shell-off preview exposes mismatched generated underpainting plus artifacts from the old review rig masks; it is rejected as anatomy evidence. A constrained generated edit also changed unrelated body regions and is rejected. Both remain quarantined; no runtime references were added.

Godot 4.7.2 `tests/test_runner.gd` passes. Its scope is the existing prototype suite and does not validate the new shell-off anatomy. The test emits the known non-fatal `user://C:` directory warning. This folder has no `.git` metadata, so no commit is available.

**Result:** Canonical arm boundary PASS. Approved shell-on image fidelity PASS for the tested layer split. Concealed anatomy, shell-off contour, independent shell deformation, pivots, and production animation remain **NOT VERIFIED**; production-art gate remains **NOT PASSED**. Review image: `docs/visual_qa/BREAKER_T1_candidate01_shell_elbow_rebuild_v4.png`.

### Candidate01 donor fit comparison addendum — 2026-10-25 UTC

A direct shell-off crop compared the v2 and 72%-width v3 underlays against the approved candidate01 arm and mechanical forearm. Both expose the generated donor as oversized and misaligned, with an unclear elbow-to-prosthesis transition. Reject both for anatomy fit. This confirms the current shell-off assembly is not a reviewable or production-valid result; do not infer acceptance from connectivity or exact shell-on reconstruction. Comparison: `docs/visual_qa/BREAKER_T1_candidate01_shell_off_v2_v3_donor_comparison.png`.

### Final constrained reference fit attempt — 2026-10-25 UTC

A crop-only ImageGen edit and a full-body scale-guided crop edit were both reviewed. The first remained visibly over-rounded; the second enlarged and scarred the upper arm further. Neither image was imported into the project. The generated studies do not satisfy the approved candidate01 proportions and are rejected. No shell-off art currently passes the visual fit review. Continue to use the approved candidate01 shell-on image as the only art authority; hidden anatomy remains open and quarantined.

Godot 4.7.2 focused candidate01 tests were rerun after the visual review: v2 and compact v3 each passed 206 neutral/60 Hz shoulder-registration samples with stable ground anchor. The full `tests/test_runner.gd` also passed. These validate transform registration and existing prototype logic; they do not validate the rejected shell-off donor artwork. The known non-fatal user-directory warning appeared in all headless runs.

## Candidate01 elbow boundary and corrected fit studies — 2026-10-25 UTC

A source-layer audit found that the shoulder shell spans both `cyber_upper_arm.png` and the y<495 portion of `cyber_forearm.png`. The y=495 boundary comes from the trial's provisional CyberElbow pivot; it is an implementation fixture, not a new canon measurement. Treating the entire forearm layer as prosthesis made earlier shell-off boards invalid. The new review path moves the above-elbow forearm pixels into the shoulder-shell group and leaves the prosthesis pixels at/below y=495 on the elbow bone.

A corrected nonuniform affine fit now uses a shoulder-to-elbow section of an isolated generated arm study. Two width hypotheses remain quarantined: slim (x-scale 0.20) and broad (x-scale 0.28). The deterministic builder verifies for both: exact shell-on reconstruction at alpha>=245; exact partition/recombination of the source forearm layer; 8-connected union with the elbow-start forearm; and 1,070 / 1,523 opaque-pixel overlap, respectively. Candidate sizes: 14,357 / 20,059 opaque underarm pixels. A previous affine inversion defect caused earlier QA boards to misplace the donor; those boards are superseded by `docs/visual_qa/BREAKER_T1_candidate01_elbow_underarm_fit_options_affinefix_v2.png` and `docs/visual_qa/BREAKER_T1_candidate01_fullbody_256px_elbow_underarm_affinefix_v2.png`.

Godot 4.7.2's new rig check passes both variants through 412 sampled idle/walk/punch/hit/defeat frames while keeping the donor on the shoulder bone, the split shoulder shell together, and the forearm on the elbow bone. The full prototype runner passes. This establishes source-pixel ownership, transform registration and elbow overlap only. It does not establish acceptable shell-off shape, style fidelity, deformation quality, or production readiness.

The user-approved canon remains external shoulder shell over biological upper arm, prosthesis starts at elbow. Visual acceptance is still pending; production-art gate remains **NOT PASSED**. No runtime references were added. This checkout has no Git metadata. The two width choices are presented for owner review; no candidate is promoted.

### BREAKER elbow seam-contact test extension — 2026-10-25 UTC

The corrected fitted-arm Godot test now evaluates transformed opaque pixel masks inside a 270×170 source-space elbow ROI for every sampled frame, in addition to checking bone ownership and ground-anchor stability. It requires at least 25 8-neighbor contact samples between biological upper arm and elbow-start forearm. Godot 4.7.2 passes 206 samples per width across idle, walk, punch, hit, and defeat: slim contact range 463–1,282; broad 800–1,849. The separate Python builder continues to pass exact shell-on reconstruction, forearm partition, and connected union for both. The full prototype suite also passes.

These structural checks support elbow continuity through sampled poses, but do not establish style match, every interpolated frame, or deformation. The later visual review rejected both widths; see the addendum below. Production-art gate remains **NOT PASSED**.

### BREAKER candidate01 shell-off visual review — 2026-10-25 UTC

Reviewed the corrected crop and 256 px full-body boards. Both generated underarm widths show obvious texture/cutout artifacts and a bulky contour that does not match the approved candidate01 art. **Reject both**; neither becomes a pending owner choice or runtime asset. The previous structural results remain valid only for source reconstruction, bone ownership, and sampled elbow contact. The approved shell-on art is unchanged. Next art pass requires a style-matched hidden upper arm and separately authored shell, followed by visual and animation review. Production-art gate remains **NOT PASSED**.

Retest with Godot 4.7.2 on 2026-10-25: focused fitted-arm test passed both variants over 206 samples each (slim 463–1,282 contacts; broad 800–1,849); the full prototype test runner passed; Python builder `--verify-existing` passed exact shell-on reconstruction, source partition, overlap, and connected-mask checks. Godot emitted a non-fatal `user://C:` directory creation warning. These passing tests do not override the visual rejection.

### Contextual arm cutaway study — 2026-10-25 UTC

Generated and quarantined `candidate01_upper_arm_cutaway_study_v1.png` from the approved local crop. Visual review confirms the external-shell-over-biological-upper-arm and elbow-start-prosthesis relationship, but rejects the study for an enlarged upper-arm contour and altered shoulder-armor design. No test or runtime integration was performed because the image is a concept board, not separable art. It does not resolve concealed anatomy or production readiness.

Created `docs/BREAKER_T1_HIDDEN_ANATOMY_ART_BRIEF.md` to make the next art pass testable across canon boundary, shell-on source fidelity, shell-off proportion/style, separated transparent parts, and sampled Godot seam behavior. The brief explicitly leaves hidden proportions as an unapproved art choice. It records that no current candidate passes the complete gate.

One localized refinement attempt against the contextual cutaway v1 asked ImageGen to narrow only the shell-off inset arm while preserving the approved shell. Manual comparison shows it did not materially reduce the bulky contour and still changed armor details. Reject the output; it remains in the generated-image staging area and was not copied into the project, rigged, or tested. No art candidate passes the complete gate.

## Candidate01 texture-overlay underlay review — 2026-10-25 UTC

- Reviewed `candidate01_upper_arm_source_texture_underlay_v2.svg` at 18% overlay opacity in the isolated Godot review rig. Shell-off view is **rejected**: arm still reads swollen and detached, with stray/doubled texture marks; it does not match candidate01's contour or paint treatment.
- Shell-on view visually preserves the approved candidate01 appearance. Structural test passes do not waive the shell-off visual gate.
- A mirrored/scaled source-skin overlay was separately rejected for garment fragments and mismatched marks. Neither overlay is runtime art.
- Canon boundary remains user-approved: external shoulder shell over biological upper arm; mechanical prosthesis begins at elbow and includes forearm/fist. This boundary does not approve hidden proportions.
- Godot 4.7.2 focused test passed 824 samples across slim, broad, vector, and source-texture variants; the full `tests/test_runner.gd` suite passed. These checks establish sampled registration/contact and prototype behavior only, not shell-off anatomy quality.
- Keep SVGs, capture scripts, and previews quarantined. Production-art gate remains **NOT PASSED**; no runtime references or remote uploads were made.

## Candidate01 hidden-arm direction trials v2–v3 — 2026-10-25 UTC

- User-approved canon remains: external shoulder shell over biological right upper arm; prosthesis starts at elbow and includes forearm/fist. The user's approval does not specify the concealed arm contour.
- Vector underlay v2 improves the tapered contour over v1 and preserves the exact source composite when the shell is on. Shell-off review still fails: the surface is too flat and the upper-arm form does not convincingly join the shoulder skin and prosthetic elbow.
- Same-source skin cutout v1 fails because the donor is too narrow and appears detached. Same-source texture v3 keeps the v2 silhouette but introduces streaks and source seams; it also fails.
- A localized ImageGen repaint and an isolated generated arm both overshoot the approved proportions/style. Neither generated result was imported into the project.
- Godot 4.7.2 focused test passes 1,442 pose samples across seven review variants. v2 and v3 each retain 226–452 sampled elbow-contact pixels over 206 frames; the narrow source cutout variant retains 322–524. The full prototype test runner passes. These checks only support registration/contact and existing prototype systems, not visual quality or all-frame deformation.
- The artwork remains quarantined and runtime scenes remain unchanged. No current hidden-arm candidate passes the complete art gate.

## Compact source-texture v4 review — 2026-10-25 UTC

A provisional authoring assumption used BREAKER's visible natural arm as the shape reference without canonizing its exact hidden proportions. Candidate v4 narrows the v2 vector silhouette to 84% width and applies 8% same-character skin texture. Godot 4.7.2 passes shell-on source fidelity and sampled contact/registration over 206 frames (186–374 contact pixels). The shell-off preview is still too vector-like and retains visible texture streaks, so v4 is not accepted as production art. Full prototype suite passes. The remaining unresolved item is an owner-approved shell-off contour/style; all drafts remain quarantined and runtime art is unchanged.

## Mapped skin texture trials v5–v6 — 2026-10-25 UTC

- Used the compact v2 shape as the silhouette and mapped a generated skin texture across its interior to avoid the narrow-strip seam of earlier same-source overlays. These are quarantined texture experiments, not production art.
- v5 uses a 14% texture blend; it retains the compact shape and source shell-on composite but remains too smooth/vector-like. v6 uses 38%; it adds crosswise shading that does not follow BREAKER's anatomy. Both fail shell-off visual review.
- Godot 4.7.2 focused test passes ten variants across 2,060 samples. v5 and v6 each retain 226–452 contact pixels across 206 sampled poses and preserve the exact shell-on visible source. The full prototype test runner passes.
- Tests establish only sampled layer registration and pixel contact; they do not establish style, anatomy quality, or continuous deformation. No candidate passes the art gate, no runtime art changed, and no remote uploads were made.

### Constrained painted underlay v7 — 2026-10-25 UTC

- The constrained generated-paint underlay preserves the approved shell-on composite exactly in the isolated rig and keeps the biological arm shoulder-bound with elbow overlap.
- Godot 4.7.2 focused test passed all 11 variants across 2,266 sampled pose frames; v7 retained 191–370 sampled elbow-contact pixels. The full prototype test runner passed. These are structural checks only.
- OpenGL review at the 256 px gameplay scale keeps the source character and shoulder shell readable. Native-scale shell-off review still exposes a jagged shoulder-wrap fragment and an ambiguous join; v7 is rejected as a production-art candidate. It remains quarantined and is not referenced by runtime scenes.
- A further isolated image-generation study again exaggerated arm volume and missed the target rendering/scale; it was not imported. A headless screenshot recapture was not usable because the dummy renderer returned no viewport image. Existing OpenGL captures remain the visual evidence.
- Canon boundary is unchanged and approved: external shoulder shell over biological upper arm; prosthesis begins at elbow. Exact hidden contour, transparent production parts, and animated seam quality remain unresolved.

### Candidate01 skin-mask cleanup and connected underlay v8–v10 — 2026-10-25 UTC

- v8 removed isolated pixels from the source skin mask; v9 retained only warm-colour pixels. Both reconstruct the original shoulder pixels exactly, but neither materially changes the shell-off image because the distracting edge is attached to the main source patch.
- The v9 toggle board (`docs/visual_qa/BREAKER_T1_candidate01_warm_partition_v9_shell_toggle_review.png`) exposed a second issue: the narrow upper-arm silhouette sat 60–80 source pixels away from the torso layer, so shell-off showed a disconnected shoulder.
- v10 extends the arm under the torso with a tapered horizontal fit. Python verifies 1,410 opaque arm/torso overlap pixels. The revised Godot test now includes torso coverage in shell-on occlusion; v10 has zero unoccluded pixels against torso, shell, visible skin, and prosthesis.
- Godot 4.7.2 focused test passes 12 variants across 2,472 sampled pose frames; v10 retains 191–370 elbow-contact pixels. OpenGL captures pass five poses, stable ground anchor, and 256 px shell-on/off review. The full prototype test runner passes.
- At gameplay scale v10 reads as connected while preserving the shell-on reference. Native-scale review still reveals stretched paint around the shoulder/axilla; it is a **provisional review candidate**, not approved production art. No runtime scenes changed.
- Canon remains approved: external shoulder shell over a biological upper arm; prosthesis begins at elbow. Hidden proportions and production cutouts remain provisional. No remote write or upload was made.

### Candidate01 v10 close-up rejection — 2026-10-25 UTC

The v10 gameplay-scale shell-off view connects the upper arm toward the torso, but close-up inspection rejects the actual surface: horizontal fitting distorts the muscle planes, creates a sharp inward kink, leaves colored specks at the contour, and still reads as a seam at the elbow. Therefore v10 is **REJECTED as an art candidate**, despite its structural tests. Keep the improved torso-coverage assertion in the test harness; do not promote v10. No candidate currently passes the complete art gate.

### Candidate01 under-vest socket v11 — 2026-10-25 UTC

- v11 preserves v7's original arm silhouette and adds a narrow connector toward the torso using adjacent edge samples. The Python builder adds 11,148 pixels and verifies zero exposure against torso/skin/shell/prosthesis coverage.
- Godot 4.7.2 focused rig test passes 13 alternatives across 2,678 sampled pose frames; v11 retains 191–370 elbow-contact pixels. The full prototype test runner passes. OpenGL five-pose captures pass the anchor check.
- Shell-on appearance stays covered, but native-scale shell-off review shows conspicuous horizontal color streaks through the connector. **Reject v11 as art**; it is not runtime content. Its source-coverage and contact tests remain useful structural evidence only.
- No current hidden-arm underlay passes the combined artistic and rig gate. The approved canon boundary is unchanged; no remote write/upload was performed.

### Live canon recheck — 2026-10-25 UTC

The live BREAKER spec and Decision Log were fetched again. They reaffirm the approved shell-over-biological-upper-arm / elbow-start-prosthesis boundary, but do not approve an exact hidden contour. The live spec still labels hidden anatomy and production animation readiness unverified; local candidate01 v7/v10/v11 remain quarantined. No remote document update occurred.

## User confirmation and validation rerun — 2026-10-25 UTC

The user reconfirmed the Tier I arm reading: the external shoulder shell sits over a biological upper arm; the mechanical prosthesis begins at the elbow and includes the forearm/fist. This confirms the boundary rule only; it does not approve an exact hidden contour or any current draft as production art.

Godot 4.7.2 focused candidate01 fit/contact test passed all 13 variants across 2,678 sampled pose frames, including the approved shell-on occlusion and elbow-contact assertions. The full `tests/test_runner.gd` suite passed. Both headless runs printed the known non-fatal `user://logs/godot.log` write warning. These checks validate sampled structural registration only; shell-off art quality remains **NOT PASSED**, and runtime art is unchanged.

## BREAKER candidate01 constrained skin donor v12–v15 — 2026-10-25 UTC

Two localized image-edit studies were created from the approved candidate01 reference. v12 changes the prosthesis/arm silhouette and other source pixels, so it is rejected as a replacement image. v13 removes the shoulder shell for an anatomy view but exaggerates the upper arm; it is retained only as a texture donor. Neither generated full-body image is runtime content or canonical art.

A fitted transparent underlay v14 was built from the v13 donor and clipped behind the approved source layers. Godot confirms zero shell-on exposure, but its sampled elbow contact falls to 10 pixels in the defeat pose (threshold 25); v14 is an expected-reject fixture. v15 adds a tapered torso-facing extension. Godot 4.7.2 passes its shell-on occlusion check and 206 sampled pose/contact frames (104–268 contact pixels). The complete focused arm suite passes 15 variants / 3,090 samples with v14 explicitly marked as expected reject. The full prototype test runner passes. OpenGL five-pose, detail, and 256 px captures pass the ground-anchor check.

Visual review: v15 provides a continuous skin surface to the elbow-start prosthesis and retains the approved shell-on assembly. The shell-off shoulder/axilla contour remains provisional; the generated donor edge needs owner/art review and has not been accepted as final. All new images remain under the ignored review-only folder; runtime scenes and source art are unchanged.

Limits: these checks establish source-layer occlusion, sampled bone parenting/contact, and anchor stability. They do not prove authored pivots, all-frame deformation, final anatomy approval, or production animation readiness. Headless Godot runs continue to emit the known non-fatal user log-write warning; the OpenGL capture used the Compatibility renderer.

## BREAKER candidate01 underarm fit v16–v20 — 2026-10-25 UTC

The user reaffirmed the Tier I anatomy boundary: an external shoulder shell covers a biological upper arm, and the mechanical prosthesis starts at the elbow. This confirms the boundary; it does not approve a specific hidden contour or draft as production art.

Candidates v16–v18 retain the v15 contact fit but their connector experiments produced visibly artificial collar/underarm forms. V19 improved the shoulder root but failed elbow contact (5–59 pixels). V20 uses a tapered affine shear that brings the shoulder root within 2 source pixels of the torso while preserving the original elbow seam. Godot 4.7.2 focused checks pass for v20: 104–267 elbow-contact pixels across 206 pose samples, zero shell-on underlay exposure, parent registration, and stable ground anchor. The expanded suite passes 20 variants / 4,120 sampled frames, with v14 and v19 marked as expected rejects. The full `tests/test_runner.gd` suite also passes.

OpenGL Compatibility captures cover neutral, walk, punch, hit, defeat, shell-on/off detail, and 256 px views. Visual comparison shows the approved shell/skin/prosthesis reading at gameplay scale. The shell-off donor's shoulder/axilla surface remains provisional and needs owner review for resemblance and proportion; hidden anatomy and production art are still **NOT PASSED**. All drafts and captures remain quarantined; runtime scenes/source art are unchanged. Godot headless runs emit the known non-fatal `user://logs/godot.log` write warning.

### Candidate01 v20 reference and shell-separation visual QA — 2026-10-25 UTC

Added `docs/visual_qa/BREAKER_T1_v20_vs_candidate01_source_arm_review.png` to compare the reconstructed shell-off arm with the approved flattened source crop. The overall human-arm proportions and identity details follow the source direction, but the underarm donor texture/transition is still a reconstruction and has not received visual acceptance. The shell-on capture preserves the source-visible assembly; the donor remains fully occluded by source layers.

The OpenGL helper now uses the same v4 visible-skin and shoulder-shell layers as the structural regression, and adds a diagnostic with the shoulder shell hidden while the elbow-overlap slice remains visible. Independent-shell captures were also made at baseline, +12 source px, +0.16 rad, and hidden states; the ground anchor remains stable. The small translation exposes continuous underlay. The large independent rotation opens visible gaps, so it is not a pass for independent shell animation. In the current trial the shell and skin share the same shoulder bone; the rotated case is a stress image only, not an approved animation.

The shell-off arm-to-forearm transition still needs visual review. No production approval, runtime change, or canon expansion is inferred from these screenshots.

### Candidate01 v20 rendered shell-on edge check — 2026-10-25 UTC

The user reconfirmed the approved Tier I arm reading: an external shoulder shell over the biological upper arm, with the prosthesis beginning at the elbow. The decision is already recorded in `docs/DESIGN_DECISIONS.md`; this approval does not promote a draft asset.

- Godot 4.7.2 Compatibility/OpenGL viewport comparison found a small, repeatable blend change where the hidden underlay sits beneath partially transparent source-skin texels. Neutral changes 29 rendered pixels around the shoulder edge; across 206 stable pose samples, the maximum was 37 pixels / 83 channel levels, confined to the shoulder/upper-arm screen region. The earlier byte-identical claim applies only to opaque source pixels and must not be described as full rendered parity.
- Updated `tests/test_breaker_candidate01_v20_shell_on_visual_parity.gd` to compare stable OpenGL captures across 206 pose samples and enforce bounded edge-delta, channel-delta, and region limits. It passes with configured ceilings of 64 pixels / 96 channel levels. The underlay's exact opaque coverage/source-mask audit passes.
- Godot 4.7.2 focused candidate01 suite passes 20 variants / 4,120 sampled frames; v14 and v19 remain expected rejects. Full `tests/test_runner.gd` passes. The Python v20 opaque-mask/composite audit passes. Headless viewport comparison is unsupported by the dummy renderer; the visual check was run with the Compatibility/OpenGL renderer.
- A one-pixel and three-pixel mask erosion were tried as v21/v22; they narrowed the root connection and still left the rendered edge delta. They are not an accepted fix or replacement for v20.
- The inferred shell-off underarm and elbow transition remain review-only. Anatomy/proportion fidelity, authored pivots, all-frame seam quality, and production readiness are **NOT VERIFIED**. No runtime scene or asset was changed.

QA: `docs/visual_qa/BREAKER_T1_v20_parity_mismatch_zoom.png`; full reference comparison: `docs/visual_qa/BREAKER_T1_v20_vs_candidate01_source_arm_review.png`.

### Candidate01 elbow-contact threshold hardening — 2026-10-25 UTC

Raised the focused arm-fit regression's minimum elbow contact from 25 to 100 source-pixel neighborhood contacts. Godot 4.7.2 passes the full 20-variant / 4,120-sample set at the stronger threshold; v14 and v19 remain expected rejects, while v20 retains 104–267 contacts across 206 poses. The `candidate01_v20_elbow_join_zoom.png` capture provides a visual seam check at detail scale. This supports a tested join in the provisional review rig; it does not establish a hand-authored elbow, anatomical correctness, deformation quality, or final-art approval. Full `tests/test_runner.gd` also passes. The known user-log write warning remains non-fatal.

### Candidate01 anatomy reference study — 2026-10-25 UTC

Generated a quarantined visual study from the approved candidate01 profile to explore the user-approved shoulder-shell / biological-upper-arm / elbow-start-prosthesis reading. The output is 1024×1536 RGB, not a transparent production part. The arm-only panel exaggerates the bicep, while the full-body panel changes unrelated source details and composition. It is not a better replacement for v20 and is not canonical; no pixels were used in the rig or runtime. Keep it only as a comparison reference. This does not settle the shell-off proportion question or hidden-anatomy verification.

QA: `docs/visual_qa/BREAKER_T1_candidate01_inferred_elbow_anatomy_imagegen_study_01.png`.

### Candidate01 v20 shell-on pixel-fidelity audit — 2026-10-25 UTC

Added `tools/art/audit_breaker_candidate01_tapered_underarm_v20.py`. The audit passed: all 21,434 opaque underlay pixels are covered by the source torso/skin/shell/forearm layers, and compositing v20 behind the approved candidate01 source changes 0 opaque shell-on pixels. The audit explicitly does not prove hidden anatomy, proportions, pivots, or production readiness. This gives a direct pixel-level fidelity result in addition to the Godot pose/contact tests.

### Live Notion v20 milestone readback — 2026-10-25 UTC

Notion readback verified the text-only v20 status in the BREAKER Specification (`2026-10-25T12:15:27.563Z`), Asset Library (`2026-10-25T12:15:36.798Z`), and Production Roadmap (`2026-10-25T12:15:45.519Z`). The update preserves the boundary decision and states that v20 remains a local review candidate. No runtime art or binary was added. No Google Drive tools are available in this session; remote Drive sync remains queued.

## PolyRig 0.9.3 Early Access installed for evaluation — 2026-10-25

Copied the user-provided PolyRig add-on from `poly-rig-plugin-v0.9.3-EA/addons/poly-rig/` into the Godot discovery path `addons/poly-rig/` and enabled `res://addons/poly-rig/plugin.cfg` in `project.godot`. This is a tooling-only setup for evaluating 2D mesh generation and skin weights. No character art, rig, or runtime scene was edited or promoted. Godot editor startup validation was not run in this session because no Godot executable was available on PATH; plugin load and use remain unverified. Keep quarantined candidate art behind its existing visual/semantic gates.

## Phantom Camera v0.11.0.3 installed for evaluation — 2026-10-25

Installed the stable MIT-licensed Phantom Camera release (tag `v0.11.0.3`, commit `cb6e0966ac305202c47f1d1a81c105966e29da96`) at `addons/phantom_camera/` and enabled `res://addons/phantom_camera/plugin.cfg` alongside PolyRig in `project.godot`. This is a tooling-only setup for evaluating 2D camera follow and transitions for the approved scrolling battlefield/zone presentation. No gameplay scenes or camera behavior were changed. Godot editor startup validation was not run because no Godot executable was available on PATH; plugin loading and runtime behavior remain unverified. Additional spend: $0.

## Zone-transition presentation prototype 01 — isolated QA — 2026-10-25

Added `tests/presentation/zone_transition_prototype_01/` and `docs/ZONE_TRANSITION_PRESENTATION_PROTOTYPE_01.md`. The focused Godot 4.7.2 headless check passes for a Phantom Camera priority handoff paired with the existing provisional EnvironmentDirector palette crossfade. The fixture uses `undercity_proto_01/02` and the wave-13 selector only as provisional QA data. No main scene, combat simulation, canonical location content, pacing, character art, or runtime behavior changed. The check emitted the known non-fatal `user://logs/godot.log` write warning; rendered visual/performance review and the full suite were not run. Local Notion/Drive staging copies are refreshed; no remote write/upload is claimed.

## Image-generated multi-character parts-sheet intake — 2026-10-25 UTC

Created quarantined exploratory sheets for BREAKER, BULWARK, CIPHER, and SPARK and ran the existing semantic-cutout alpha audit. All five reviewed sheets failed transparent-margin/halo thresholds. Visual inspection also found ambiguous or duplicate component layouts, so they are not accepted parts or rig inputs. The cleanup edit reduced BREAKER's external low-alpha pixels from 2,492 to 646 but still failed the 50-pixel limit and 10% margin gate. The approach is stopped rather than repeated; next art pass must use manually authored, source-preserving layers and per-character 100% crop review. No runtime content changed.

Validation: the existing audit tool ran on all five candidate PNGs and returned FAIL for each. This is expected rejection evidence, not a successful production-art test.


Notion sync follow-up: the image-generated part-sheet rejection was appended and verified on the Asset Library (2026-10-25T18:09:54.972Z) and Production Roadmap (2026-10-25T18:09:56.941Z). No Drive upload or binary asset publication.



## CIPHER Krita part-authoring workspace 01 - 2026-10-25

Created a quarantined OpenRaster workspace at `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/krita_authoring_workspace_01/`. It contains the approved side-profile crop as the visible reference, ten separately aligned candidate cutout layers (hidden initially), and a transparent inferred-underpaint layer. The approved reference and existing cutout PNGs were not changed. This is a manual-review aid; semantic ownership, hidden anatomy, pivots, and animation quality remain unverified.

Validation: OpenRaster structure, layer count/visibility, 330x960 canvas registration, PNG decoding, and merged preview passed a Python round-trip check. Krita visual-open verification passed in the follow-up below; individual layer/art review remains pending. The workspace is quarantined and is not runtime content.


## CIPHER Krita workspace verification update - 2026-10-25

Opened `CIPHER_T1_PART_AUTHORING_WORKSPACE_01_QUARANTINED.ora` in the installed Krita app. It displays the approved CIPHER side-profile source on the 330x960 canvas and exposes the named layer stack. This confirms the file is usable as a Krita authoring document; the individual hidden layers still require art review.

Validation passed: the OpenRaster round-trip check verified 12 aligned layers (10 hidden candidate cutouts, one transparent inferred-underpaint layer, one visible reference), canvas dimensions, PNG decoding, and archive layout. `python -m unittest tests.art.test_cipher_profile_parts -v` passed 5/5 tests. Godot 4.7.2 headless `tests/art/test_cipher_reference_cutout_rig.gd` passed: 11 art layers, 15 bones, six pose states, stable ground anchor, transparent corners. Godot emitted its known non-fatal user-log write warning.

A broad file-name scan also found `CIPHER_T1_CARRIED_RIFLE_REF_CUTOUT_CANDIDATE_01.png` outside the rig manifest; it has zero transparent margin and is not used by the rig. Keep it unmapped/quarantined. The separately tested rifle attachment remains the rig candidate. These checks do not verify far-side anatomy, authored pivots, continuous joint deformation, or production art. Runtime art is unchanged.


## CIPHER semantic-part review - candidates 01-03 - 2026-10-25

A labeled contact sheet exposed semantic defects that alpha and rig-structure tests do not catch. Candidate 01 passes mechanical alpha checks and its isolated Godot rig test, but visual review shows neighboring shoulder/torso pixels in the head cutout, arm pixels in the backpack cutout, and lower-limb mapping/pivot concerns. Candidate 01 is not accepted as a semantic part set.

Candidate 02 is rejected: the mutually exclusive head/backpack masks leave a visible hole, and its transparent silhouette coverage is 96.25% (5,021 source-core pixels missing; 0 extra). Candidate 03 removes that specific mutual-exclusion gap; its ten cutouts each pass the mechanical alpha/margin test and its neutral assembly covers 99.63% of the stripped source silhouette (496 source-core pixels missing; 0 extra). Candidate 03 is still only a quarantined review candidate: its individual semantic boundaries have not passed 100% Krita review, hidden joint surfaces and far-side parts are absent, and no candidate-03 rig/deformation test has run.

Created candidate-02/03 contact sheets and a candidate-03 Krita workspace for further hand review. The candidate-03 workspace is prepared but not opened; all further desktop takeover/painting is deferred until after 5 p.m. Chicago time at the user's direction. No runtime art or scenes changed.


## CIPHER cutout gate hardening - 2026-10-25

Added `tools/art/audit_cipher_profile_part_candidate.py` and `tests/test_cipher_profile_part_candidate_audit.py`. The audit reports alpha/margin checks and neutral source-silhouette coverage separately from semantic review, explicitly returns `production_approved: false`, and cannot label semantic visual review as passed. The three regression tests pass: candidate 01 is mechanical-pass/review-required; candidate 02 fails the 99% provisional coverage threshold; candidate 03 is mechanical-pass/review-required at 99.63%.

This prevents the known failure mode where a successful alpha/rig test is mistaken for a complete semantic art rig. Full manual layer review is still required. Candidate 03's Krita workspace remains unopened pending after 5 p.m. Chicago time; no more desktop takeover will occur before then.


## Full local Python regression after CIPHER gate hardening - 2026-10-25

`python -m unittest discover -s tests -p 'test*.py' -v` passed all 37 tests, including the three new CIPHER candidate audit regressions. The first restricted run could not create seven tests' temporary directories under the read-only project path; the rerun with scoped write access passed without assertion failures. Godot 4.7.2's focused CIPHER reference-cutout rig test also passed (11 art layers, 15 bones, six pose states, stable ground anchor, transparent corners); its user-log write warning is non-fatal. Candidate 03 still has no rig/deformation test, and semantic/art review remains pending.


## CIPHER semantic remap candidate 04 - 2026-10-25

Candidate 04 makes a narrow, evidence-based mask extension at the four missed source regions reported for candidate 03. Its neutral assembly now covers 100% of the thresholded stripped source silhouette (0 missing, 0 extra core pixels); each of the ten separate cutouts passes the current mechanical alpha/margin checks. The mechanical audit reports `MECHANICAL_PASS_VISUAL_REVIEW_REQUIRED`, never production-approved.

Created a 12-layer Krita workspace and labeled part contact sheet for candidate 04. They are prepared for the later desktop review; no Krita interaction was performed after the user's request to defer computer takeover until after 5 p.m. Chicago time. Candidate 04 has not passed manual semantic review, has no far-side or hidden joint surfaces, has no authored pivots, and has not been rig-tested. It remains quarantined.

## File-only authoring pipeline and regression update - 2026-10-25

Added reusable `tools/art/build_krita_authoring_workspace.py` to produce non-destructive, registration-preserving OpenRaster workspaces from explicit part manifests. The builder supports candidate 01 crop offsets (including negative offsets) and later full-source bounding boxes, starts candidate parts hidden, retains the source crop visibly, adds a blank inferred-underpaint layer, and refuses to overwrite an existing workspace. Candidate 04 was built and round-trip inspected as a 12-layer, 330x960 ORA with ten hidden cutouts.

Validation: full Python suite passed 41/41. Godot 4.7.2 focused candidate-01 structure check passed (11 art layers, 15 bones, six pose states, stable ground anchor, transparent corners). That Godot check is limited to candidate 01 and does not validate candidate 04. Candidate 04 remains unopened in Krita by request until after 5 p.m. Chicago time; visual semantic review, concealed/far-side anatomy, pivots, deformation, and runtime integration remain unverified. No runtime assets changed.

## Authoring builder validation hardening - 2026-10-25

Hardened tools/art/build_krita_authoring_workspace.py: manifest source paths must remain within the project, part paths within their candidate folder, source crops within the source image, and declared source bounding boxes must exactly match nontransparent part bounds. The builder also rejects malformed crop vectors and duplicate/missing part files. This addresses silent misregistration and unsafe source references without changing any art.

Validation: the builder's focused suite passes 7/7, including negative crop-offset preservation and four invalid-manifest cases. Full Python regression passes 45/45. Godot 4.7.2 headless tests/art/test_founding_t1_profile_mesh_rigs.gd passes structural checks for all ten quarantined visible-profile mesh candidates (skeleton, contours, mapping, normalized weights, six pose states, fixed ground roots). This is structural evidence only; the ten textures remain flattened profile mesh preflights, not modular part rigs or production art. Candidate 04 still needs the deferred Krita visual review. No runtime assets changed.

## CLI audit and roster-preflight recheck - 2026-10-25

Rechecked the full roster preparation audit: all 12 recruits have local references, candidate inventory, special-rig notes, and shared production gates; listed paths exist and no candidate is marked production-approved. The all-ten Godot profile-mesh structural test passes but remains a flattened-mesh preflight only. CIPHER candidate 04's mechanical audit reports 100% thresholded source-core coverage, zero missing/extra pixels, ten alpha/margin passes, and status MECHANICAL_PASS_VISUAL_REVIEW_REQUIRED. It explicitly leaves semantic review, pivots/deformation, and production approval unverified.

Fixed direct CLI invocation for the CIPHER mechanical audit; both direct-script and module invocation now work. This was a Python import-path issue, not an asset failure. No UI was opened and no art changed.

## Candidate 04 preview-sheet semantic screen - 2026-10-25

A file-based review of the quarantined contact sheet found semantic defects despite the mechanical audit passing: the layer labeled near_thigh appears to contain mostly a waistband/shorts fragment, while torso_jacket includes neighboring arm/strap pixels. Candidate 04 therefore fails this preliminary semantic screen and is not acceptable rig input. This is a contact-sheet diagnosis, not the required 100% Krita layer review; preserve it only as a quarantined diagnostic/workspace test. No art was edited and no desktop application was opened.

## PolyRig toolchain smoke check - 2026-10-25

Godot 4.7.2 headless test tests/art/test_polyrig_geometry_smoke.gd passed: PolyRig triangulated a body-like silhouette and produced normalized weights for both bones. This confirms the installed geometry path can support mesh preflight; it does not author semantic parts or validate a character's anatomy/deformation. The all-ten candidate check remains structural only.

## OpenRaster builder compatibility across CIPHER candidates - 2026-10-25

Expanded the builder tests to cover CIPHER candidates 01 through 04. Both the source-offset schema (candidate 01) and alpha-bound/source-bbox schema (candidates 02-04) now build into aligned 330x960 OpenRaster workspaces without rescaling; the candidates remain quarantined and their semantic quality is independent of packaging success. Focused builder tests pass 8/8 and the full Python suite passes 46/46.

## Quarantined draft import boundary - 2026-10-25

Added a top-level .gdignore marker to every founding character's tier_01_drafts folder, matching the existing BREAKER exclusion. The folders contain candidate art/workspaces and should not be auto-imported as game assets. Added a roster regression requiring exactly 12 draft folders and a .gdignore in each. Focused roster/workspace tests pass 20/20; full Python suite passes 47/47. Godot 4.7.2 headless CIPHER cutout and all-ten profile-mesh tests still pass because they load raw files by path. No runtime scenes reference these draft folders; the candidates remain quarantined.

Import-scan caveat: .gdignore markers are now present in all 12 draft roots, and file-based Godot tests pass. A clean Godot Editor filesystem rescan has not been run, and pre-existing ignored .import sidecars remain in draft subfolders. They were not deleted. Treat import exclusion as configured but not yet proven by a clean rescan; do not claim the import cache was purged.

## Godot draft import scan verification - 2026-10-25

A Godot 4.7.2 headless Editor scan completed with exit code 0 after adding all twelve draft-root .gdignore markers. The verbose scan emitted zero tier_01_drafts log lines, and a search of .godot/editor returned zero cached draft-path matches. Existing ignored .import sidecars remain on disk (98 total across these trees); they were not deleted. The scan establishes that the current Editor filesystem cache excludes draft paths; the sidecars are stale metadata and not evidence of imported runtime resources.

## Candidate 04 semantic failure recorded in data - 2026-10-25

Updated the candidate-04 generator, manifest, quarantine README, and mechanical audit output to carry the observed PREVIEW_SCREEN_FAIL status and its evidence note. The mechanical result remains a separate MECHANICAL_PASS; the combined report now says MECHANICAL_PASS_SEMANTIC_SCREEN_FAIL and exits 2, preventing a clean alpha/coverage result from looking like rig clearance. Full-resolution Krita review is explicitly NOT_VERIFIED. No pixels, reference art, or candidate 01 files changed. The full Python suite passes 47/47.

## CIPHER candidate 05 - source ownership boundary correction - 2026-10-25

The native-resolution ownership map exposed a candidate-04 head/hood and backpack ownership overlap. Candidate 05 changes one rule: backpack_mount excludes the head_hood_hair_face mask. Its measured multiply-owned pixels fell from 9,205 to 4,549 (-50.6%) while the mechanical audit retains 100% thresholded silhouette coverage, zero missing/extra core pixels, and ten alpha/margin passes.

Candidate 05 remains QUARANTINED / NOT RIG INPUT. The ownership map is a diagnostic only; semantic labels have NOT_REVIEWED status, no 100% Krita layer review has occurred, and hidden/far-side anatomy, pivots, and deformation are absent. Godot 4.7.2 intake test passed for all ten raw PNGs and the 330x960 assembly. The OpenRaster builder created a 12-layer workspace, with ten candidate layers hidden. Full Python suite passes 52/52.

## Pairwise ownership diagnostic and CIPHER regression update - 2026-10-25

The source-aligned ownership tool now reports overlap by semantic part pair as well as total red pixels. Regression confirms candidate 04 had 4,525 shared pixels between backpack_mount and head_hood_hair_face; candidate 05 has zero for that pair. Total multiply-owned source pixels fell 9,205 to 4,549 while coverage stayed at 100%. Remaining overlaps are reported for review, not automatically treated as errors because joint overlap may be intentional. Python full suite: 52/52 PASS.

## Post-candidate-05 Godot import scan - 2026-10-25

Reran Godot 4.7.2 headless Editor filesystem scan after creating candidate 05. Process exited 0, emitted zero tier_01_drafts log lines, and .godot/editor contains zero draft-path matches. The new candidate remains excluded from automatic imports; its dedicated raw-file intake test still passes. Existing ignored .import sidecars remain; no cache cleanup was performed.

## CIPHER candidate 05 alpha-checkerboard preview screen - 2026-10-25

Rendered all ten candidate parts at native pixel scale over an explicit checkerboard so transparent regions are distinguishable from opaque art. The preliminary file-based screen flags `near_thigh` as an incomplete waistband/shorts fragment and `torso_jacket` as containing a detached neighboring strip; `pelvis_belt_gear` needs close boundary review. Candidate 05 is now recorded as `PREVIEW_SCREEN_FAIL` and remains a quarantined diagnostic, not rig input. The mechanical result remains separate: 100% thresholded source-core coverage, zero missing/extra pixels, ten alpha/margin passes. No art pixels changed.

Evidence: `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_05_QUARANTINED.png`. The full-resolution Krita layer review is still `NOT_VERIFIED`; hidden/far-side anatomy, authored pivots, and deformation remain absent. Python unittest suite passes 52/52. Godot 4.7.2 headless raw-file intake passes all ten PNGs and the 330x960 assembly with review-failure metadata intact. The mechanical audit returns `MECHANICAL_PASS_SEMANTIC_SCREEN_FAIL` and exit code 2 as intended. No runtime asset or remote source changed.

## Equipment function requirement reaffirmed — 2026-10-25 UTC

The user confirmed that character weapons, accessories, cyberware, tethers, and drones must function as designed, not merely appear in art. This is an acceptance requirement for both rig/presentation integration and authoritative simulation behavior. Existing roster-backed examples and unresolved mechanics remain in `ATTACHMENT_FUNCTION_CONTRACT.md`; no character-specific equipment behavior is newly implemented by this confirmation.

## Quarantined OpenRaster part export tool — 2026-10-25 UTC

Added `tools/art/export_reviewed_openraster_parts.py` for exporting explicitly selected, non-empty semantic layers from edited `.ora` workspaces. It preserves full-canvas alignment, validates character ownership and attachment metadata, rejects blank/reference/unsafe layers and non-normal blend/opacity, refuses overwrites, restricts output to the matching character's `tier_01_drafts/` directory, and labels every export quarantined with production/runtime gates false. It does not infer pivots, semantics, gameplay behavior, or production readiness.

Focused exporter tests: 12/12 passed, including an actual-workspace check proving blank equipment layers in all twelve ORA workspaces cannot be exported, negative-offset canvas clipping, explicit weapon/presentation-only cable metadata, and multiple art components sharing one attachment role. Part IDs remain unique; runtime attachment IDs are assigned later per owner instance. Full Python regression: 73/73 passed. All-12 workspace audit still passes. No character art was authored or promoted; Krita round-trip, semantic review, Godot part deformation, and production attachment behavior remain unverified. Current OpenRaster layers are still blank edit prep.

## ECHO attachment-layer split — 2026-10-25 UTC

- Created ECHO edit workspace v2 under `assets/characters/echo/tier_01_drafts/edit_batch_02/`, preserving v1 unchanged. Its blank authoring layers keep reusable sensory-drone art, Signal Cascade decoy presentation, neural-interface tethers, and backpack/cable clearance distinct.
- This supports the confirmed requirement that character equipment must function through its authored attachment and simulation-event contracts. The roster-wide source-backed contract covers all twelve; the current generic Godot event router is infrastructure only, and no character-specific weapon/drone behavior is implemented.
- ECHO's exact sensory-drone count, drone/decoy relationship, appearance, formation, paths, and sensory rules remain unresolved. No Cyberpunk-franchise mechanics were needed or imported.
- **Validation:** all-12 rigging-prep audit **PASS**; focused all-12 plan tests **3/3 PASS**; OpenRaster builder tests **7/7 PASS**; full Python suite **73/73 PASS**; Godot 4.7.2 headless project suite **PASS**. The Godot result covers generic authoritative attack-event routing only, not ECHO behavior or production attachments. The audit confirms all twelve archives match their hidden blank layer plan and quarantine metadata. No Krita visual review or production attachment behavior test has been performed.

## SPARK three-drone presentation-route regression — 2026-10-25 UTC

Expanded the Godot attachment-router test to register three independent SPARK drone receivers and dispatch one owner `attack_resolved` event. All three receive one event through separate attachment IDs; unrelated BREAKER attachments remain isolated, and repeated/out-of-order events remain suppressed. Godot 4.7.2 headless suite passes. This validates only simulation-to-presentation routing infrastructure; there are no SPARK art nodes, drone movement/targeting/damage behavior, or production attachment assets yet.

## SPARK reference-derived drone cutout workflow — 2026-10-25 UTC

- Added `tools/art/extract_reference_prop_candidate.py`, an explicit-seed source-prop extractor that writes only quarantined review candidates under the matching character's Tier I drafts. It keeps one foreground component per object seed, retains source RGB, records provenance/bounds, adds a transparent safety margin, refuses overwrites, and fails before writing if any selection seed is invalid.
- Extracted three separate static SPARK drone cutouts from the approved anatomy turnaround into `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/`. The references visibly show three distinct drone designs, matching the roster's three-drone identity count. This does not establish hidden surfaces, motor/rotor animation, pivots, movement paths, or combat behavior.
- **Validation:** focused extractor/source-fidelity tests **5/5 PASS**; full Python suite **78/78 PASS**; `audit_reference_prop_candidate.py` **PASS** on the actual three-item candidate with zero source RGB mismatches and zero pairwise mask overlap; all three embedded alpha audits **PASS**; checkerboard board reviewed at native scale. Semantic completeness, source-edge artistry, and Krita round-trip are **NOT VERIFIED**. Production, animation, and runtime flags remain false. A three-drone routing test passes in the Godot 4.7.2 headless suite, but it is router infrastructure only.
- The Godot 4.7.2 Editor scan exited 0 and produced zero draft-path references in `.godot/editor` and zero `.import` sidecars in the candidate folder. The scan also emitted two editor-panel errors from Phantom Camera's viewfinder requesting a missing `PhantomCameraManager` singleton, so the scan is not a clean editor-launch result; these errors do not mention the new art or main gameplay scene.

### SPARK drone PolyRig mesh-input check — 2026-10-25 UTC

- Added `tests/art/test_spark_drone_polyrig_mesh_inputs.gd` and ran it with Godot 4.7.2 headless against the three existing quarantined blue/red/amber drone cutouts.
- **PASS:** all three source files load, each yields exactly one alpha contour at density 1.0, and each contour triangulates independently through `PolyRigDelaunay`. A native-scale checkerboard review shows isolated silhouettes with transparent margins.
- This is mesh-input feasibility evidence only. The source drones are shown front-on while the game presentation is side-view; no side-view redraw, pivot, flight path, animation, gameplay behavior, runtime node, or production-art status was added. All three remain quarantined.

## Targetless equipment-event routing — 2026-10-25 UTC

- `AttachmentEventRouter` now permits sequenced owner events without `target_id`, allowing future support abilities and accessory cues to reach source-owned presentation receivers. Target-owned receivers still require an actual matching target ID.
- Extended the Godot regression with a targetless `ability_resolved` event routed to BULWARK's medical-pack receiver and confirmed that target-owned armor and unrelated drones do not receive it. The test event is a transport fixture; no healing, ability activation, or character-specific equipment behavior was implemented.
- **Validation:** Godot 4.7.2 headless prototype suite passed. Weapons, accessories, and drones remain simulation/presentation integration work for each character; existing cadence, drone behavior, pivots, and ECHO count questions remain open.

## Alpha-island diagnostic for semantic cutout review — 2026-10-25 UTC

- `tools/art/audit_semantic_cutout.py` now reports the number and thresholded pixel area of four-neighbor alpha components plus the secondary-to-main area ratio. This helps locate detached fragments such as the known CIPHER candidate-05 torso strip without treating every multi-piece prop or accessory as a failure.
- Auditing CIPHER candidate 05 reports `torso_jacket`: 24,776 px main component plus 882 px secondary component (3.56%); `head_hood_hair_face`: 18,211 px plus 427 px (2.34%). The candidate remains `PREVIEW_SCREEN_FAIL`; the partial thigh and semantic ownership still need art review. Other multi-component pieces include backpack and belt gear, so counts are diagnostic only.
- **Validation:** focused alpha-audit suite **7/7 PASS**; full Python regression **79/79 PASS**; all-12 workspace audit **PASS**. The candidate audit still intentionally exits with semantic-screen failure despite mechanical alpha/coverage passing.

## CIPHER candidate 06 — source-aligned leg-joint overlap review — 2026-10-25 UTC

- Created `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/` as a new quarantined iteration; candidates 01–05 remain unchanged. Candidate 06 keeps transparent reference-derived cutouts and adds source-pixel overlap under the near-thigh/shin and shin/boot seams, with child layers above their parent in the stated draw order.
- Measured thresholded overlap: thigh/shin **3,520 px**; shin/boot **1,800 px**. Mechanical candidate audit: **100%** thresholded silhouette coverage, **0** missing/extra pixels, all ten alpha/margin checks pass. A candidate-specific OpenRaster workspace preserves the 330×960 canvas and ten hidden cutout layers; it opened in Krita without a repair warning. The neutral assembly was inspected at fit scale and remains source-shaped.
- The known torso secondary island and the incomplete/ambiguous thigh ownership question are not declared resolved by overlap alone. Individual semantic review, the detached torso detail, authored pivots, hidden/far-side anatomy, joint deformation, and runtime integration remain unverified. Candidate 06 remains quarantined and is not rig input.
- **Validation:** candidate audit tests **6/6 PASS**; Krita workspace builder tests **10/10 PASS**; full Python regression **81/81 PASS**; Godot 4.7.2 raw-file intake **PASS** for all ten cutouts and assembly. Godot check is not a rig/deformation test.

## CIPHER candidate 06 native-scale semantic review aids — 2026-10-25 UTC

- Added `tools/art/render_semantic_part_contact_sheet.py` to create checkerboard contact sheets from named part manifests without rescaling the cutouts. It confines inputs/outputs to the project, refuses overwrite, and marks semantic/production approval as unverified.
- Extended `tools/art/audit_semantic_cutout.py` to report four-connected alpha-island bounds in addition to component areas. On CIPHER's torso, the secondary island is 882px at cutout bounds `[60,209,71,398]`, mapping through the candidate source bbox/padding to profile-crop `[101,293,112,482]`.
- Generated `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_06_QUARANTINED.png` and `CIPHER_T1_PART_OWNERSHIP_MAP_06_QUARANTINED.png`. The contact sheet shows the larger near-thigh crop at native scale. The 882 px torso secondary component maps to source-crop x=101..111, y=293..481 and tracks the rear jacket outline; it remains provisionally assigned to the torso layer pending final semantic review. The ownership map reports 9,869 shared pixels, including the planned 3,520 thigh/shin and 1,800 shin/boot seams plus other overlaps requiring review. Neither diagnostic automatically determines correct ownership.
- Candidate 06 remains quarantined; semantic review, authored pivots, hidden/far-side anatomy, and deformation remain NOT VERIFIED. The approved source art and candidates 01–05 were not modified.
- **Validation:** new contact-sheet tests **2/2 PASS**; full Python regression **83/83 PASS**; CIPHER mechanical audit and all-12 workspace audit pass. Godot 4.7.2 raw-file intake reads all ten cutouts and the neutral assembly with review-only gates intact. It does not test a Godot rig or deformation.

## CIPHER candidate 07 - backpack signal mast ownership - 2026-10-25 UTC

Candidate 07 preserves candidate 06 and moves only the source-traced visible rear signal-mast region from `head_hood_hair_face` to `backpack_mount`, matching the approved profile/front/rear turnaround. Its neutral assembly retains 100% of the 133,741 thresholded source-core pixels with no missing or extra silhouette pixels; all ten cutouts pass alpha and margin checks. The named-part contact sheet and ownership overlay are diagnostic review aids. Torso detail island/overlap, complete semantic ownership, pivots, hidden/far-side anatomy, deformation, and full Krita review remain unverified. Candidate 07 is quarantined and is not rig input or production art.

A new Godot 4.7.2 raw-file intake script checks all ten images, the 330x960 neutral assembly, mast-owner metadata, and quarantine flags. This is a file-readability check only.

Before correction, the 85-test Python run failed six manifest/roster assertions because the validator incorrectly required `ground_pivot` although the v1 schema documents it as optional. The validator now accepts absent `ground_pivot` for structural intake while preserving name validation when supplied. After correction, the full Python regression passes 85/85, including 23 manifest/roster tests and 2 candidate-07 ownership tests. Godot 4.7.2 candidate raw-file intake passes, the Godot project suite passes, and the all-12 workspace audit passes.

## Godot editor startup — Phantom Camera autoload corrected — 2026-10-25 UTC

- Godot 4.7.2 headless editor startup had logged repeated missing `PhantomCameraManager` errors because the enabled Phantom Camera plugin's required autoload was absent from `project.godot`. Added the plugin's documented manager script as an autoload; retained the plugin and project history.
- Repeated editor startup: PolyRig 0.9.2 Early Access loaded, project scan and editor layout completed, and the Phantom Camera singleton errors disappeared. A TLS handshake error remains; source inspection identifies the Phantom Camera updater's GitHub Releases endpoint as a likely request source. This does not block local asset validation, but remote update checks are unverified.
- Full pipeline rerun after the config fix: Python **85/85 PASS**, all-12 workspace/attachment/quarantine audit **PASS**, and Godot 4.7.2 prototype suite **PASS**. Art remains quarantined; no visual/semantic gate, pivot, deformation, equipment behavior, or production rig was approved.
- Additional startup check: the actual configured main scene launched headlessly in Godot 4.7.2 with `--quit-after 8` and exited **0**; the log contains no scene/runtime errors.

## CIPHER candidate 07 visual evidence review — remains quarantined — 2026-10-25 UTC

- Compared the candidate-07 source-profile assembly and part contact/ownership sheets with the approved CIPHER concept and anatomy turnaround. The neutral assembled profile retains the visible source silhouette. The torso crop still contains a detached narrow jacket-outline fragment (previously measured at 882 alpha pixels); its semantic assignment and whether it needs a separate garment owner remain unresolved. The ownership map reports 9,869 shared source pixels across multiple owners; seam overlaps are visible, but correct owner boundaries are not yet verified.
- No pixel edits, part remapping, pivots, hidden anatomy, or rig approval were made. Candidate 07 remains `QUARANTINED / NOT_VERIFIED`; resume only with a human-confirmed correction or source-backed semantic interpretation, per the authoring guide's stop rule.
- Focused `audit_cipher_profile_part_candidate.py` rerun against candidate 07's manifest: **10/10 individual part images pass** the provisional RGBA, clear-corner, margin, and external-halo checks; source-profile assembly coverage is 100% (0 missing/extra core pixels). The full source-profile assembly is a display artifact, not one semantic part; its cropped outer margins are not judged by per-part safety-margin rules. `semantic_visual_review` and `full_resolution_krita_review` remain **NOT_VERIFIED**, and production approval remains false.

## CIPHER candidate 07 PolyRig mesh-input preflight — 2026-10-25 UTC

- Extended the Godot regression in `tests/test_runner.gd` to load each of the ten manifest-listed PNG parts, extract actual alpha contours, and feed every contour independently to `PolyRigDelaunay`. The full suite reports the evidence and preserves candidate gates.
- Current result: near_thigh, near_shin, near_boot, pelvis_belt_gear, torso_jacket, near_upper_arm, near_forearm, near_hand, and head_hood_hair_face each have all detected contours triangulatable; four parts are multi-contour (`backpack_mount`, `pelvis_belt_gear`, `torso_jacket`, `head_hood_hair_face`). `backpack_mount` has 8 contours but only 2 triangulate. Its six non-triangulating contours need source-backed human review; do not silently discard them. Auto Mesh cannot represent a multi-contour texture as one mesh.
- The test prints **BLOCKED / REVIEW REQUIRED** while confirming the candidate remains quarantined and unapproved. This is an intentional readiness finding; the complete game test suite still passes. It is not proof of a valid assembled rig or art quality.
- Full pipeline after this change: Python **85/85 PASS**, all-12 prep/attachment audit **PASS**, and Godot 4.7.2 suite **PASS**. All art remains quarantined.
- Image-space detail for the six non-triangulating `backpack_mount` contours: contour #1 `(154,71)-(155,72)`, #2 `(151,75)-(152,76)`, #3 `(152,73)-(153,75)`, #4 `(153,72)-(154,73)`, #5 `(150,77)-(151,78)`, and #7 `(138,518)-(139,522)`; each returned four contour points but no valid triangle indices. These are local coordinates in the 215×582 backpack PNG, not source-profile coordinates. Use them to locate pixels for review; do not auto-delete them.
- Preserved a review-only visual overlay at `docs/visual_qa/CIPHER_T1_BACKPACK_POLYRIG_CONTOUR_DIAGNOSTIC_01_QUARANTINED.png`. It marks the six Godot-reported non-triangulating contours on the intact backpack source; no source pixel was changed.

## CIPHER candidate 07 hand/jacket interpretation — encoded and regression-tested — 2026-10-25 UTC

- Added the user-approved interpretation to the candidate-07 manifest and README, and to its reproducible generator: visible hand pixels belong to foreground `near_hand`; the jacket continues behind; visible hand pixels must not belong to `pelvis_belt_gear`. Any future occluded jacket underpaint is explicitly `INFERRED_NOT_VISIBLE_IN_FLATTENED_SOURCE`; current underpaint status is `NOT_AUTHORED`.
- Added a Python regression that checks manifest wording, draw order, zero shared source-core pixels between hand and pelvis/torso, and the existing hand/forearm overlap. Focused test: **3/3 PASS**. The complete pipeline then passed: Python **86/86**, all-12 audit, Godot suite.
- This records only the approved ownership interpretation. No PNG/ORA pixels changed. Candidate 07 remains quarantined, semantic review remains unverified, and the backpack PolyRig contour failure plus pivots/deformation remain open.

## CIPHER candidate 08 — hand ownership and inferred jacket continuation — 2026-10-25 UTC

- Created `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_08_hand_jacket_underpaint/` from candidate 07 as a separate quarantined review draft. Candidate 07 and the approved source references remain unchanged.
- Candidate 07 already assigns the visible hand exclusively to `near_hand`; a read-only source-alpha overlap check finds zero shared pixels between the hand and either `pelvis_belt_gear` or `torso_jacket`. Candidate 08 preserves those source-derived parts and adds a separately named, flat-charcoal inferred underpaint beneath the hand silhouette, with `near_hand` above it. Manifest metadata records the provenance and limited purpose; the underpaint contains no authored texture or approved articulation coverage.
- Inspected the new neutral assembly and isolated underpaint visually. The hand reads as a foreground hand and the underpaint is hidden at neutral pose. This is a visual draft review only; no automated tests were run for candidate 08. Semantic approval, visible underpaint during movement, pivots, deformation, far-side anatomy, full Krita review, and production readiness remain NOT VERIFIED. Candidate 08 is not rig input or runtime art.
- Added `tools/art/build_cipher_candidate_08_hand_jacket_underpaint.py` as a reproducible, no-overwrite builder for the quarantined candidate.
- User accepted this approach for now at the intended display scale, where the underpaint is expected to be nearly invisible. This is not an observed 1280×720/800×450 gameplay-scale pass, a motion review, or production approval.

## CIPHER candidate 08 static scale and semantic review — 2026-10-25 UTC

- Created isolated neutral-composition previews at the guide's 256 px visible-height reference scale: `docs/visual_qa/CIPHER_T1_CANDIDATE_08_ISOLATED_SCALE_1280x720_QUARANTINED.png` and an 800×450 downscale. The figure reads at both resolutions and the inferred hand underpaint remains hidden in neutral pose. This is not an in-engine gameplay capture, action pose, or final on-screen-size approval.
- Generated candidate-08 native-scale semantic contact and ownership boards. Read-only source-alpha comparison confirms zero shared hand pixels with either `pelvis_belt_gear` or `torso_jacket`; candidate 07 already had exclusive hand ownership. The narrow torso island tracks the visible rear jacket edge in the approved side profile and remains assigned to `torso_jacket` as a garment continuation.
- The thigh/shin masks shared **3,520** thresholded pixels across the distinct knee guard. The user approved a separate `near_knee_guard` anchored at the knee. Candidate 09B at `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/` now assigns the traced guard region its own part and clears it from the thigh/shin parent masks using source RGB only. A pixel comparison reports its neutral assembly is identical to candidate 08. The user has since approved the exact boundary and pivot; other part boundaries and the motion seam remain under review. Candidate 08 and the first draft remain preserved.
- No automated tests were run for this visual review.
- Refreshed the labeled local Notion/Drive staging copies. SHA-256 readback matched all seven updated docs in both staging locations, all five review PNGs in both visual-QA staging folders, and all fourteen candidate-08 files in the Drive sprite staging folder. These are local staging copies only; no remote upload occurred.

## CIPHER candidate 09B — separate knee guard review draft — 2026-10-25 UTC

- Added `tools/art/build_cipher_candidate_09_knee_guard.py` and created the candidate 09B review folder with eleven semantic parts. The `near_knee_guard` mask uses source RGB within a conservative traced boundary; `near_thigh` and `near_shin` relinquish that region. No new color pixels were generated.
- Candidate 09B's neutral assembly is pixel-identical to candidate 08. The user approved the owner split and the traced `near_knee_guard` raster boundary: front plate/red optic and upper side lug belong to the guard; lower round hinge/wrap straps stay with the leg. The user approved the pivot at source pixel `(770, 665)`; candidate metadata records guard-local pixel `(77, 115)`. Approved-pivot evidence is `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_PIVOT_APPROVED_QUARANTINED.png`. The new Godot-rendered ±15° hinge diagnostic is `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_GUARD_MOTION_07_QUARANTINED.png`; it confirms exact neutral reconstruction but remains a rigid proxy. Other part pivots, actual deformation, seam quality, and production remain unresolved.
- Generated candidate 09B native-scale contact and ownership boards plus `docs/visual_qa/CIPHER_T1_KNEE_GUARD_CANDIDATE_09B_BOUNDARY_REVIEW_QUARANTINED.png`. The candidate is quarantined and is not rig input or production art. No automated tests were run.
- Updated `tools/art/create_cipher_candidate_09b_pivot_review.py` and generated an approved-pivot review image. Candidate 09B's manifest now authors the user-approved point. This does not add runtime rig data or validate movement/deformation.
- Recorded the user's approval of the knee-guard raster boundary and generated `tools/art/create_cipher_candidate_09b_knee_bend_review.py` plus a quarantined rigid-cutout pose comparison. The proxy rotates the shin, guard, and boot around the approved pivot at 12° and 20°; it is not a real deforming rig or animation. The motion seam is awaiting review. No tests were run for this art preview.
- Following the user's request for inferred underpaint, added `tools/art/build_cipher_candidate_09b_knee_underpaint_03.py` and `tools/art/build_cipher_candidate_09b_knee_underpaint_04.py`. The current flat layer fills only flex-exposed pixels inside the source-derived leg silhouette and is recorded in `parts_manifest.json` as a separate candidate layer. The user approved this review layer for the shown pose range; it remains excluded from the neutral assembly and runtime. Earlier broad-fill trials are explicitly superseded; no source part pixels were edited.
- Added `tests/art/capture_cipher_candidate_09b_knee_underpaint_motion_02.gd` and captured the approved source, neutral, 12°, and 20° rigid poses with Godot 4.7.2 Compatibility `Sprite2D` rendering. The neutral knee crop matched the candidate assembly exactly (**0 / 70,000** differing pixels). The capture shows the approved underpaint behind the moving cutouts; it is not a deforming/skinned rig or production validation. The per-pixel capture trial 01 is preserved but superseded due speckled rasterization artifacts. Godot emitted user:// log/shader-cache write warnings, but saved the visual capture successfully. No project test suite was run.
- Refreshed local staging and verified SHA-256: seven project docs match in Notion and Drive staging, five QA PNGs match in both review folders, and all sixteen candidate-09B files match in the Drive sprite staging folder. No remote upload occurred.

## Reusable character-art occlusion workflow — user-approved — 2026-10-25 UTC

- Updated `docs/CHARACTER_PART_AUTHORING_GUIDE.md` and `docs/DESIGN_DECISIONS.md` to apply the real-world ownership method to future similar occlusion issues: keep the visible foreground item semantically separate and above the covered surface; when user direction or approved sources establish what continues behind it, allow conservative, separately labeled inferred underpaint.
- Preserve source layers, avoid unsupported details, stop when ownership is ambiguous, and review at gameplay scale plus poses that expose the fill. The rule does not approve hidden anatomy, pivots, deformation, or production readiness.
## PolyRig contour mesh builder — CIPHER candidate 07 mesh intake unblocked — 2026-10-25 UTC

- Added `tools/art/polyrig_contour_mesh_builder.gd`, a reusable review-only helper that extracts alpha contours, triangulates each independently with PolyRig (and guarded Godot Geometry2D fallback), then creates one textured `Polygon2D` per contour under its existing semantic owner. It validates texture/image size and only attaches nodes after every contour succeeds.
- Integrated the helper into the CIPHER candidate-07 Godot regression. All contours in all ten manifest-listed images build; `backpack_mount` is now 8/8 PolyRig triangulations. The four multi-contour images still need semantic ownership review; no pixels, semantic labels, pivots, or weights were changed.
- Added a Godot regression for mismatched texture/image dimensions; the helper rejects the input before adding any nodes to the parent.
- **Validation:** `tools/art/validate_character_art_pipeline.ps1` passed: Python **86/86**, all-12 archive/reference/layer/attachment/quarantine audit **PASS**, and Godot 4.7.2 headless suite **PASS**. CIPHER candidate 07 remains quarantined and unapproved; this is mesh-input geometry evidence only, not a rig or deformation test.

## CIPHER candidate 07 real-render contour mesh comparison — static preflight — 2026-10-25 UTC

- Added `tests/art/capture_cipher_candidate_07_contour_mesh_fidelity.gd` to render the approved anatomy profile crop, the existing candidate assembly, and the helper-built PolyRig contour assembly in Godot's normal OpenGL Compatibility renderer.
- The source-aligned mesh composite differed from the candidate assembly on **531 / 79,200** sampled art-region pixels (**0.67045%**) at 0.5× scale; the diagnostic gate is a provisional ≤1% threshold. Rendered comparison board: `docs/visual_qa/CIPHER_T1_CANDIDATE_07_POLYRIG_MESH_ASSEMBLY_02_QUARANTINED.png`.
- **Validation:** normal-renderer capture and comparison **PASS**. A headless run cannot provide a viewport texture and is not supported for this visual check. This is static texture/contour render evidence only; it does not validate exact pixel identity, semantic ownership, pivots, weights, hidden anatomy, movement, deformation, or production status. Candidate 07 remains quarantined.
- Added a native-scale, per-part comparison to isolate downsampling effects. Godot rendered each source texture beside its generated contour mesh at 1:1; all ten parts stayed below the provisional 1% difference bound (highest: `torso_jacket`, 249 / 134,652 = 0.18492%). All ten had zero differences in fully opaque interior pixels; observed differences were restricted to semitransparent or alpha-edge-adjacent pixels. This is a texture/mesh raster-input check, not semantic or deformation approval.


## SPARK drone contour-mesh render fidelity — 2026-10-25 UTC

- Added `tests/art/capture_spark_drone_contour_mesh_fidelity.gd`, a normal-renderer diagnostic that compares each source PNG with its `PolyRigContourMeshBuilder` mesh at native scale and saves a quarantined side-by-side board.
- Godot 4.7.2 Compatibility renderer results: drone 01 **122/125,832 (0.09695%)** differing samples; drone 02 **89/101,232 (0.08792%)**; drone 03 **102/100,142 (0.10186%)**. All are below the diagnostic's provisional 1% threshold, with zero differing fully opaque interior pixels.
- Board: `docs/visual_qa/SPARK_DRONE_POLYRIG_MESH_FIDELITY_01_QUARANTINED.png`.
- This establishes static texture-to-mesh raster fidelity only. It does not certify semantic completeness, a side-view adaptation, pivots, articulation, animation, attachment behavior, or production status. No source art pixels changed; all drone cutouts remain quarantined.

## CIPHER candidate 09B added to routine PolyRig preflight — 2026-10-25 UTC

- Added `_test_cipher_candidate_09b_mesh_inputs()` to `tests/test_runner.gd`; the normal Godot suite now reads candidate 09B's manifest, validates its eleven part files/dimensions and draw order, checks the pixel-identical neutral-composite record, then builds every alpha contour through `PolyRigContourMeshBuilder`.
- All eleven parts built; every detected contour used PolyRig with zero Geometry2D fallbacks. Contour counts include backpack mount 8, thigh 2, shin 1, knee guard 1, boot 1, pelvis gear 4, torso jacket 2, upper arm 1, forearm 1, hand 1, and head 2.
- Test assertions retain the actual status `PARTIAL_USER_APPROVAL; RASTER_AND_RIG_REVIEW_OPEN`: the knee-guard owner split, traced boundary, and pivot are approved; other part boundaries, deformation, hidden anatomy, and production status remain unresolved. Candidate 09B remains quarantined and is not rig input.
- **Full validation:** Python **86/86**, all-12 archive/reference/layer/attachment/quarantine audit **PASS**, Godot 4.7.2 headless suite **PASS**. No art pixels, manifests, or runtime scenes changed.

## CIPHER candidate 09B normal-render contour fidelity — 2026-10-25 UTC

- Generalized `tests/art/capture_cipher_candidate_07_contour_mesh_fidelity.gd` to compare either candidate 07 (default) or current candidate 09B via `-- --candidate 09b`.
- Godot 4.7.2 Compatibility renderer: the candidate-09B source-aligned mesh assembly differs from its candidate assembly by **544 / 79,200 (0.68687%)** at 0.5×, under the diagnostic's provisional 1% threshold. All eleven part textures also stayed under 1% at native scale; highest was `torso_jacket`, **249 / 134,652 (0.18492%)**. Every part had zero differing fully opaque interior pixels.
- Board: `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_POLYRIG_MESH_ASSEMBLY_01_QUARANTINED.png`.
- This verifies static raster preservation only. The selected knee boundary and pivot are now user-approved, while other part boundaries, hidden/far-side anatomy, and motion/deformation remain unresolved; candidate 09B is still quarantined and not rig input.

## CIPHER candidate 09B Godot knee-underpaint preview approval — 2026-10-25 UTC

The user approved the Godot-rendered knee-joint underpaint update shown in docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_GODOT_MOTION_02_QUARANTINED.png. Approval is limited to the shown quarantined review presentation and pose range. The layer remains outside the neutral assembly and runtime; the rigid Sprite2D capture is not deformation or production approval. Candidate 09B remains quarantined.
## Source-traced character-part extractor and IRONCLAD cable trial — 2026-10-25 UTC

- Added `tools/art/extract_traced_reference_parts.py`. It exports only explicitly supplied integer polygons, preserves the full source canvas and RGB, supports multiple disjoint polygons per attachment, verifies source/upstream hashes, rejects overlapping visible ownership, and marks outputs quarantined with null pivots and false review/runtime approval flags.
- Added regression tests for provenance, source RGB, owner/path/range checks, overwrite refusal, overlap rejection, alpha bounds, and multiple polygons. Added `tools/art/ironclad_back_cable_candidate_01.json` and generated `assets/characters/ironclad/tier_01_drafts/attachment_cutout_candidate_01/` from the visible U-shaped back-unit cable loop. It has 781 nonzero-alpha pixels in one component; bounds are `[190, 598, 259, 649)`.
- QA board: `docs/visual_qa/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01_QUARANTINED.png`. The isolated ends are squared where the source cable enters the pack; mounts, pivots, motion, and behavior remain unverified. The weapon, pack panels, and armor pieces remain unauthored. The cutout is not rig input, production art, or runtime content.
- **Validation:** full Python suite **95/95**; all-12 workspace/reference/quarantine audit **PASS**; Godot 4.7.2 main suite **PASS**; focused Godot cable source-RGB/resource test **PASS**; mechanical alpha/margin audit **PASS**. These results do not certify semantic completeness, endpoints, pivots, deformation, or gameplay behavior.

## SPECTER and STITCH equipment intake reviews — 2026-10-25

- Added character-specific quarantined source reviews at `assets/characters/specter/tier_01_drafts/attachment_decomposition_02/EQUIPMENT_REVIEW_02_QUARANTINED.md` and `assets/characters/stitch/tier_01_drafts/attachment_decomposition_02/EQUIPMENT_REVIEW_01_QUARANTINED.md`.
- SPECTER’s flattened views obscure the sword grip and cape surfaces behind the body; STITCH’s views obscure vial/case grip surfaces and coat/back-assembly boundaries. No semantic cutouts were produced because complete source ownership boundaries are unavailable.
- Both revision-02 ORA files remain blank edit-prep workspaces; no rig, animation, runtime integration, or production art was created or promoted. No automated tests were run for these documentation-only reviews.

## Visual source-polygon tracing tool — 2026-10-26 UTC

- Added `tools/art/trace_part_authoring.py`, a local Tk/Pillow viewer for zoomed and panned manual polygon tracing in approved source-image coordinates. It captures source hash and semantic labels, prevents mixed character ownership and output-folder overwrite, and exports only through the traced-reference quarantine exporter.
- The tool does not add hidden pixels or author pivots; exported parts retain closed approval gates. UI smoke check on Windows loaded the IRONCLAD anatomy view, recorded source point `(68, 11)` at the displayed click, cleared it with Escape, exercised wheel zoom, and restored Fit. No candidate was exported and no artwork changed.
- **Validation:** new tracer tests **6/6 PASS**, including end-to-end trace-manifest export through the existing quarantine extractor; full Python suite **101/101 PASS**; all-12 source/workspace/quarantine audit **PASS**. A live Windows UI smoke check exercised source-coordinate recording, Escape clearing, wheel zoom, and Fit reset. This does not replace native-scale semantic review or validate any recruit's art.

## SPECTER visible sword cutout and traced-manifest QA — 2026-10-25

- Manually traced the exposed hilt and exposed guard/blade body from the approved SPECTER concept into `tools/art/specter_blade_visible_candidate_01.json`. Exported two canvas-aligned, source-RGB-preserving PNG fragments to `assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01/`.
- Updated the checkerboard contact-sheet and semantic ownership-board renderers to read the traced-polygon manifest schema as well as the older dictionary schema. The ownership board reports 0 overlapping pixels. Visual review shows the isolated silhouettes match the visible hilt/blade. The blade body is one connected shape under 8-neighbor connectivity; four-neighbor inspection had misleadingly split diagonal pixels into single-pixel components.
- Revised SPECTER's intake note: the cutout is partial because the glove hides the grip and the held blade's relationship to the hip handle/sheath is unresolved. Cape, hood/mask, pivots, assembly, deformation, behavior, and runtime are still unimplemented. Candidate and review boards remain quarantined and are not rig input.
- **Validation at this milestone:** contact-sheet renderer **3/3 PASS**; ownership-board renderer **5/5 PASS**; candidate source-pixel/quarantine test **1/1 PASS**; full Python suite **105/105 PASS**; all-12 prep audit **PASS**; Godot 4.7.2 headless suite **PASS** through `tools/art/validate_character_art_pipeline.ps1`. At that point the Godot runner did not directly ingest SPECTER; the later direct PolyRig and render-fidelity validation is recorded below. All art remains quarantined; no SPECTER rig or runtime change was made.

## SPECTER fragment PolyRig and native render validation — 2026-10-25

- Added SPECTER candidate 01 to the normal Godot regression runner. Both named RGBA fragments build through `PolyRigContourMeshBuilder`; every contour creates a textured, UV-aligned `Polygon2D` with triangles. Godot finds 1 hilt contour and 16 blade-body contours; all 17 use PolyRig with no Geometry2D fallback. The 16 contours are retained under one blade semantic owner rather than silently dropped or forced into one contour.
- Added `tests/art/capture_specter_blade_mesh_fidelity.gd` for native-scale Compatibility-renderer comparison. The hilt crop differs in 8/3,420 samples (**0.23392%**), and the blade crop differs in 101/105,336 (**0.09588%**). Both have **zero fully opaque interior pixel differences**. The 1% threshold is a diagnostic threshold for static rendering, not art approval.
- Review output: `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_03_QUARANTINED.png` and its JSON metrics report. The board visually confirms the source texture and mesh render align at native crop scale. Headless Godot uses a dummy renderer and cannot produce this pixel capture; the Compatibility render ran on the local NVIDIA renderer.
- **Final validation after the Godot runner change:** `tools/art/validate_character_art_pipeline.ps1` passed with Python **105/105**, all-12 workspace/reference/quarantine audit **PASS**, and Godot 4.7.2 headless suite **PASS**, including the new SPECTER 1+16 contour PolyRig preflight. The separate Compatibility-renderer fidelity script passed both native crop comparisons and saved board/report 03.
- **Scope remains limited:** complete grip, hand attachment, pivot, hip sheath relation, assembly, animation/deformation, and runtime use remain unresolved. This verifies mesh-input/render preservation only; the candidate stays quarantined and is not a finished weapon or rig.


## CIPHER rifle candidate-01 static PolyRig fidelity — 2026-10-25 UTC

- Added `tests/art/capture_cipher_rifle_mesh_fidelity.gd` to compare the isolated rifle PNG directly with the shared PolyRig contour-mesh render at native scale. Godot 4.7.2 Compatibility renderer produced one contour, one PolyRig mesh, and zero fallback meshes. The sampled difference was **1 / 49,320 pixels (0.00203%)**, with **0** fully opaque interior differences.
- QA board: `docs/visual_qa/CIPHER_T1_RIFLE_POLYRIG_FIDELITY_01_QUARANTINED.png`.
- Validation: the focused normal-renderer test passed. The mesh preserves this PNG's raster appearance; this does not verify that the candidate matches the approved rifle source, that the optic is correct, or that semantic ownership, grip/stow pivots, held pose, deformation, weapon behavior, or runtime integration are correct. Keep the cutout quarantined and outside the rig/runtime until those separate gates pass.
- **Full validation after registering the preflight in the routine suite:** `python tests/run_python_tests.py` passed **105/105**; the all-12 workspace/attachment audit passed; and the Godot 4.7.2 headless regression suite passed, including the CIPHER rifle's one-contour PolyRig/no-fallback check. The separate normal Compatibility-renderer fidelity comparison also passed. No candidate was promoted.

## Clean Windows launch and isolated save round-trip — locally validated — 2026-10-25 UTC

- Added `tests/run_isolated_windows_smoke.ps1` and `tests/user_data_path_save_probe.gd`. The runner creates a disposable, uniquely named project copy under the approved temporary workspace, imports it with Godot 4.7.2, launches the Windows GUI executable using the Compatibility renderer for 120 frames, runs the complete Godot headless regression suite in that copy, then performs save/write and fresh-process reload checks in its isolated user-data folder.
- **Validation:** clean editor import/class registration **PASS** (PolyRig and Phantom Camera plugins loaded); Windows GUI launch **PASS**; full Godot headless regression suite **PASS**; separate-process persistence round-trip **PASS** for permanent progression, current run/squad HP, and settings. The normal `Neon Requiem` save hash remained `957A4A197FCE50C6CCCC51B05D7C8787E81DFD44E52C9D99DBC5866D4E07C804` before and after.
- The editor import prints a Godot `Safe save failed` warning during editor shutdown despite completing its scan and returning success. It did not block runtime launch, regression tests, or the isolated save test; editor settings persistence still needs a separate environment-level check.
- The Python preflight did not run: its write-access probe was denied for this project folder, its tests folder, and one character fixture folder. This is a sandbox permission block, not a Python test failure. The source project and the real user save were not written by the isolated runner.
- This is infrastructure verification only. No character art or status was promoted. No remote Notion/Drive update, upload, or Git commit was made.

## Follow-up Python asset regression — locally validated — 2026-10-25 UTC

- Re-ran the project Python suite with the exact fixture-write access requested by its preflight: **105/105 PASS** in 36.952 seconds.
- Ran `python tools/art/audit_rigging_prep_all_12.py`: **PASS** for all twelve references, existing candidate paths, attachment contracts, OpenRaster workspace source layers, blank attachment layers, and quarantine metadata.
- This verifies the tools and preparation scaffolding. It also confirms all twelve workspaces still have blank art layers; none is a semantic part set or production rig. Hidden anatomy, part boundaries, pivots, deformed poses, and production gates remain unverified.
- The suite created no production artwork and made no remote sync. Python validation is no longer blocked for this authorized run; the Godot editor safe-save warning remains open.

## 1.0 decision documentation sync — 2026-10-25 America/Chicago

The user's new 1.0 scope, test plan, and distribution choices were recorded in the live Notion Decision Log, Game Design & Progression, Founding Recruit Roster, and Production Roadmap. Each page was fetched before editing and fetched again afterward; the expected section was present in readback. The corresponding local decision note and sync queue are `docs/LOCAL_SESSION_DECISIONS_2026-10-25.md` and `docs/REMOTE_SYNC_QUEUE.md`. No game implementation changed and no tests were run for this documentation-only update. No GitHub access or binary upload occurred.

## Tier I artist handoff matrix — live-source reconciliation — 2026-10-26 UTC

Read-only Notion fetches of the Founding Recruit Roster, Game Design & Progression, Decision Log, Production Roadmap, and Asset Library were recorded in Notion/Live Readbacks/TIER_I_ART_HANDOFF_SOURCE_CHECK_2026-10-26.md. The fetched roster and decision record do not resolve ECHO’s drone/decoy identity and count, GLITCH’s weapon identity, or DEADLOCK’s rifle count/carry state. They reaffirm that concept approval does not approve hidden anatomy, part boundaries, pivots, deformation, animation, or production art. The local 12-character artist handoff matrix remains a request index; no implementation, art, or runtime gate changed. No remote page edit, Drive upload, or GitHub operation occurred.

## CIPHER rifle source-shape follow-up — review only — 2026-10-26 UTC

A visual comparison of the quarantined isolated rifle candidate with the approved CIPHER concept and anatomy turnarounds did not establish source-silhouette correspondence or whether the vertical side-view item is the same prop. The matrix now lists a source-aligned rifle/optic ownership gate ahead of grip/stow pivots. The candidate remains outside the body assembly; no art, runtime, or rig changed. Review record: docs/visual_qa/CIPHER_RIFLE_ATTACHMENT_REVIEW_01_QUARANTINED.md. No automated tests were run.

## Ability and formation source audit — decisions bounded; effects unspecified — 2026-10-26 UTC

- Live Notion confirms the fully automatic target/skill policy and a concrete squad preference data contract. It does not provide complete operational rules for any signature ability or the spatial movement system.
- Preference contract: optional soft Front/Middle/Rear band and Vanguard/Assault/Support/Control role, unlimited units per band, band precedence, role movement guidance within/without a band, and per-recruit persistence across Reboots. This audit did not implement UI/schema/persistence or player movement controls.
- No ability behavior, character data, art, runtime code, or tests changed. Existing ability event transport is a future presentation hook only.
- Missing contracts/options are in docs/AUTOMATIC_ABILITIES_AND_FORMATION_SOURCE_AUDIT_2026-10-26.md and docs/OPEN_QUESTIONS.md. Notion fetch metadata reports verification.state: unverified; no remote write or Drive operation occurred.


## Launch district scope metadata — source-backed; no runtime encounters added — 2026-10-26 UTC

- Added data/world/district_scope.json with the approved five district names and wave ranges (1–125), endless start at 126, two visual modules per district/local-wave-13 transition plan, one boss per district, endpoint trial placement, and the five approved boss concept names. Bosses remain unassigned to districts. This metadata is not read by runtime systems.
- Preserved data/waves/undercity_prototype.json and data/zones/undercity_prototype_zones.json unchanged. The prototype still uses its existing Undercity content and provisional wave-13 palette boundary; no canonical encounter pacing or boss spawn was wired.
- No complete boss spawn/recruitment feature is implemented. The exact acquisition transaction and identity-exclusion timing were open at the time of this scope-metadata record and were later selected in the I-07b owner decision recorded above; boss profiles, stats, abilities, rewards, district assignment, and faction/wave composition remain missing.
- Added tests/test_district_scope.py with checks for the five source-backed bands, contiguous coverage through wave 125, endless start at 126, per-district boss/module plan fields, unassigned boss identities, and preservation of the provisional Undercity wave-13 fixture. Python preflight PASS; full Python suite 108/108 PASS. No Godot tests were run because the scope catalog is not loaded by runtime code.


## Endless progression source/runtime audit — start approved; implementation blocked on mechanics — 2026-10-25 America/Chicago

- Read the live Game Design & Progression, Decision Log & Change Control, Production Roadmap, and Codex Reconstruction Handoff pages. They agree on procedural progression after the five districts, with endless starting at wave 126; the Game Design page describes retreat to the highest cleared holding wave. None supplies executable enemy-generation, stat-growth, boss-cadence, or endless-reward rules. Fetch metadata reports `verification.state: unverified`.
- Runtime and version-1 saves remain capped at 125: the wave profile ends at 125, CombatDirector stops and clamps at its configured limit, and SaveService rejects run/current/high-water/permanent values above 125. Tests cover the prototype stop and rejection of 126 only.
- The Undercity linear grunt increments and linear credit reward are provisional prototype data. The source's approved exponential-economy direction has no approved endless coefficients; neither fixture is extrapolated.
- No code, runtime data, art, user save, or tests changed. This documentation-only audit does not validate endless gameplay. No Notion/Drive write or upload was performed.
- Exact blocking fields and the decision-ready Endless v1 profile request are in `docs/ENDLESS_PROGRESSION_AUDIT_2026-10-25.md` and `docs/OPEN_QUESTIONS.md`. The wave-13 Undercity presentation fixture is unchanged.

## BREAKER run-level purchase — remote status read back — 2026-10-26

The validated implementation summary was added to the live Production Roadmap and confirmed by Notion fetch readback. The page reports verification.state=unverified; this is successful content readback, not a verification badge. Google Drive file/folder tools are not exposed, so no Drive folder readback or upload is claimed. The candidate cost remains trial balance and the level cap remains undefined. Local labeled staging copies are not remote backups.


## Grouped milestone sync — Notion readback verified; Drive pending — 2026-10-26

The current local recruitment/lineup status, partial spatial approvals, ECHO/IRONCLAD source handoff, unresolved CIPHER provenance, and candidate-only R-01 status were appended to the live Production Roadmap page. A Notion fetch readback confirmed the new section. No assets were uploaded. Google Drive file/folder tools are unavailable in this session, so remote Drive reconciliation remains pending.

## Spatial movement approvals — updated partial contract — 2026-10-26

- The user additionally approved: temporarily leave the preferred band to enter role attack range, then regroup; finish the current attack/ability before regrouping; route around authored obstacles and wait if no route exists.
- Exact band ranges/spacing, explicit arena boundary geometry, defeat/safe-state conditions, and floating exceptions remain open. No spatial runtime code or tests changed for this decision update.

## I-03 spatial follow-up sync — Notion readback verified; Drive unavailable — 2026-10-26

The additional partial spatial approvals were appended to the live Production Roadmap. Notion readback at 2026-10-26T14:48:50.225Z confirmed the three rules and remaining unresolved details. No runtime or tests changed. Drive file/folder tools are unavailable, so Drive sync remains queued.

## I-04b ability scope selected — all twelve contracts before implementation — 2026-10-26

- The user selected scope B: define all twelve ability contracts before implementing any skill. This is a sequencing choice only; mechanics are not approved.
- `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` records each live roster skill summary, its source/verification status, source-limited details, and unfilled operational fields.
- Test Lane T-02a found automatic encounter/reward and target-fallback coverage, plus ability event transport/presentation coverage. No ability trigger, cooldown, resource cost, or gameplay effect is tested or implemented.
- No runtime, test, art, or save files changed; no tests were run for this documentation-only packet.

## I-03 band-precedence clarification — Notion readback verified — 2026-10-26

The live Production Roadmap now explicitly states that the newer user-approved attack-start exception refines general band precedence for that specific conflict. Readback verified at 2026-10-26T14:50:49.693Z. No runtime/tests/assets changed; Drive unavailable.

## I-04c initial ability contract packet — historical; superseded by D-04 closeout — 2026-10-26

- Created `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` from the live Founding Recruit Roster fetch (2026-10-26T03:12:07.445Z; `verification.state=unverified`), local I-06a source/runtime gap audit, and Test Lane T-02a coverage findings.
- At the time of this initial packet, all twelve source skill summaries were retained without converting ambiguous language into metrics or behavior, and every ability was marked summary-only. This status is historical and is superseded by the owner-delegated provisional playtest contracts recorded at the top of this document and in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md`.
- No runtime, tests, art, or save files changed; no tests were run for this documentation-only packet.

## I-05b hybrid combat/outcome decision brief — local review — 2026-10-26

- Created `docs/I-05B_HYBRID_COMBAT_DECISION_BRIEF.md` from live Notion design/decision pages, the recorded I-05a completion summary, current code/data markers, and Test Lane T-02a's read-only coverage audit.
- At the time this brief was created, outcome-power relationship, reproducibility/seed policy, damage/defense/cadence model scope, and stalemate policy were listed as unresolved. Later manager selections are recorded in the I-05 semantic closeout below; formulas, numeric categories, and runtime integration remain open and unimplemented.
- The expected standalone I-05a options file is absent locally; the brief states this limitation and uses the lane/queue summary rather than inventing missing content. No runtime/tests/art/saves changed; no tests were run.

## C-02p DEADLOCK, BULWARK, and SPARK source-review consolidation — local only — 2026-10-26

Consolidated the completed read-only reviews into `docs/TIER_I_ARTIST_INPUT_PACKET_C02_01.md` and `docs/ARTIST_HANDOFF_MATRIX_T1_01.md`. DEADLOCK's 2,362-pixel antenna cutout has exact selected RGB but includes adjacent background and backpack/strap pixels at the socket, so it remains rejected. BULWARK's cross cutout matches visible front-view pixels, while decal-versus-panel ownership and right-facing view mapping remain unresolved; no independent pivot or gameplay-readability pass is supported. SPARK's three cutouts preserve visible pixels and show no crop truncation, but do not establish side/rear art, orientation, pivots, articulation, or behavior. All candidates remain quarantined. No artwork, ORA, runtime, or tests changed; no tests were run. Local staging refresh and hash checks are recorded in `docs/REMOTE_SYNC_QUEUE.md`; no remote sync is claimed.

## I-03b attachment-hover rule — historical; superseded — 2026-10-26

- This interim choice treated attachment hover as presentation-only. It is superseded by the later selection of a separate spatial height/air lane for SPARK drone attachments and ECHO decoy attachments. Exact lane and combat interactions remain open; no runtime, tests, data, or art changed.

## C-02r SPARK/ECHO height-lane art readiness — local review — 2026-10-26

Consolidated the read-only art review into the Tier I artist-input packet and handoff matrix. The user-approved separate spatial height/air-lane direction remains direction only. Existing approved art does not yet support a production air lane: SPARK needs drone side/rear references, an approved side-view/orientation treatment, and reviewed authored pivots; ECHO needs device-to-sensory-drone/Signal Cascade decoy identity and count mapping, plus complete device/tether ownership and reviewed pivots. No altitude, transitions, movement, targeting, or tether behavior was inferred. No art, runtime, or tests changed; no candidate was promoted and no tests were run. No remote synchronization is claimed.

## 2026-10-26 America/Chicago — Godot test-runner lineup signature fix — local; validation pending

Updated the three `tests/test_runner.gd` callers to pass only the owned recruit IDs to `build_default_lineup(owned_ids)`, matching the current service signature and approved founding-roster default. Production lineup behavior and runtime files were not changed. The Godot test runner was not executed, so the correction remains unvalidated. Local staging copies were refreshed; canonical Notion/Drive reconciliation remains queued.

## 2026-10-26 America/Chicago — cover art concept 01 — local concept only

Generated `assets/concept_art/neon_requiem_cover_concept_01.png` (1024×1536) as a portrait cover-art concept. It uses a rainy neon megacity and anonymous backlit squad silhouettes; it does not define named characters, roster appearance, gameplay UI, or canon. Keep it reference-only and out of runtime scenes unless separately approved. No game code/data changed and no tests were run. Local labeled staging copies were refreshed; remote synchronization is not claimed.

## 2026-10-26 America/Chicago — cover art concepts 02–03 and character card content draft — local only

Generated two additional 1024×1536 cover concepts at `assets/concept_art/neon_requiem_cover_concept_02.png` and `_03.png`, exploring a street-canyon approach and an elevated-rooftop composition. Both remain unapproved concept references with generic silhouettes. Created `docs/CHARACTER_CARDS_CONTENT_DRAFT_01.md` from the live founding-roster page and local ability-contract packet. It links the approved Tier I visual references and records biographies/signature-skill summaries; basic attacks are marked open because current sources do not define them. No named-character art or gameplay mechanics were generated or changed. Notion roster and design pages were fetched read-only; both report verification state `unverified`. No tests were run and no remote writes/uploads occurred.

## 2026-10-26 America/Chicago — VECTOR visual card prototype — draft only

Created `docs/character_cards/vector_card_prototype_01.html` as the first reusable character-card layout, using VECTOR as a sample because VECTOR is a playtest starter. The card shows the approved concept turnaround, source-backed roster identity/backstory, the basic-attack field marked open, and Slipstream as a summary-only signature ability. The anatomy turnaround is linked for reference. No new character art, combat mechanics, or runtime UI was created; no tests were run. Local staging copies were refreshed; no remote write/upload occurred.

## 2026-10-26 America/Chicago — v1 readiness ledger introduced — planning status only

Created `docs/V1_READINESS_LEDGER.md` as the single current view of weighted v1 readiness, lane owners, next deliverables, evidence, blockers, and completion state. The initial estimate is 34% (rough range 24–44%), based on fixed scope weights and current implementation evidence, not elapsed time. `docs/WORK_LANE_ASSIGNMENTS.md` now identifies the ledger as authoritative and its older assignment table as a historical snapshot; `docs/ROADMAP_TO_1_0.md` links the ledger from the current snapshot. No runtime, tests, or assets changed; no tests were run. Local staging copies were refreshed; remote publication is not claimed.

## 2026-10-26 America/Chicago — I-05 semantic closeout — local owner-delegated decision

Updated the local I-05 decision/readiness record after reconciling manager-thread answers with stale open notes. The owner-authorized Recommended timer-expiry policy is recorded as selected: either maximum-timeout or no-progress expiry resolves as defeat, then follows the approved retreat to the highest-cleared holding wave, holding-wave re-entry recovery, one-time arrival cinematic, and one-clear auto-retry flow. The direct manager-thread replies themselves selected timer reset/action ordering/tie logging, not this terminal outcome; the current selection is explicitly labeled owner-delegated. I-05 also records likelihood-based outcomes, selected score fields/sampling, two-sided relative-power impact mapping, and encounter-local seeded Godot RNG for reproducible playtests. Effective-power equations, curve/impact coefficients and bounds, timer thresholds, exact qualifying-effect definitions, cross-engine RNG sequence contract, combat equations, abilities/synergies, and runtime implementation remain open. No runtime/data/test changes or validation occurred. Labeled local Notion and Google Drive staging copies were refreshed and hash-verified; no remote read/write/upload or GitHub access is claimed.

## C-02d CIPHER 09B five-angle knee diagnostic — local, quarantined — 2026-10-26

Godot 4.7.2 Compatibility rendering captured -20°, -10°, 0°, +10°, and +20° using the existing 44 px test half-band, approved knee pivot, and source-derived thigh/shin/guard/boot export layers. The render ran in the isolated `.codex_tmp_C02d_20261026_01` project because the source PNG is protected against overwrite. The generated PNG is byte-identical to the existing source capture (SHA-256 `08016f73a6a3c29d449ce122c371f3f0c83bde55c0b6ce3f4ee30737c24b1573`). Visual inspection confirms the +20° knee seam gap persists; stronger bends show interior mesh/texture distortion that is not conclusively separable from edge deformation. Hip placement and weights are test estimates. No underpaint is drawn. Full rig, continuous motion, source-backed seam/overlap, Krita round-trip, and ORA provenance remain unverified. No art/runtime files were changed; candidate 09B stays quarantined and unapproved. The isolated copy and rendered preview are retained under `.codex_tmp_C02d_20261026_01/` for user review.

## 2026-10-26 — evolution form rename — implementation changed; validation pending

The player-facing Evolution panel, progression service, prototype gate profile, and BREAKER tier definition now use Origin Form, Adapted Form, Signature Form, and Requiem Form. The wave 25/75/125 and Evolution Data 1/2/3 feasibility gates are unchanged. The service accepts the previous four display labels. Save loading normalizes those known labels in memory; it does not rewrite save files merely by loading, and ordinary future saves persist the new labels. Current tests and local planning/staging copies were updated. No tests or runtime smoke were run for this naming change, so integration is unverified. No art, rig, ability, stats, mechanics, or balance changed; remote reconciliation is queued.
