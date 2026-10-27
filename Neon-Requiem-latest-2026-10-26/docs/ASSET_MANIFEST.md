# Asset manifest

## I-12c persistence implementation update — no asset changes — 2026-10-26

The SaveService now blocks ordinary saves when a malformed or invalid `.bak`/`.bak.prev` exists, with focused Godot regression coverage recorded in `docs/IMPLEMENTATION_STATUS.md`. Confirmed Reset retains the existing verified quarantine path. This was a code/test-only change: no game assets, references, concept art, production art, or user saves changed.

## Evolution concept-direction update — 2026-10-26 — no production assets

BULWARK's owner-selected evolution concept is medic-specific progression through armor, medical-pack, and diagnostic-bracer changes, preserving connected hose logic and the approved helmet-cross treatment. CIPHER's HUD-to-biomechanical-eye and single-rifle carry-state direction, SPARK's three distinct drones with staged hardware upgrades, and character-specific evolution remain concept-only as recorded in `docs/C05A_EVOLUTION_ART_COVERAGE_MAP.md`. Verified CIPHER eye-integration, SPARK drone-upgrade, BULWARK medic-progression, and two SPECTER sword proposal boards are present in the local Codex `generated_images` folder outside the project tree; their dimensions, hashes, and status are recorded below. The separate revised CIPHER four-form board is approved for visual direction only; its path, dimensions, and hash are verified in the C-05d entry below, and it remains outside the project and quarantined. None is integrated/copied into the project. No project asset was added, changed, promoted, or made production/rig-ready; do not infer gameplay effects from concepts. Canonical reconciliation remains queued.

**Remaining evolution direction:** future concept boards add character-specific cybernetic interfaces that enhance established signature accessories/gear rather than generic plating. SPECTER's approved concept direction ties interfaces to its established cloak and visually evolves one recognizable signature sword by grade. Preserve source-backed identity/count. Stealth, ability, and blade mechanics are not canon; gameplay function or balance changes remain proposals pending owner approval. Keep all concept boards quarantined; this direction promotes no asset or rig.

**Netrunner family direction:** digital transformation is a visual direction for CIPHER, ECHO, and GLITCH only, expressed distinctly for each. ECHO's approved ascended digital-energy Requiem look retains visual-only levitation and keeps sensory devices separate from Signal Cascade decoys. GLITCH's approved glitch-signal language is an anchor, not a template to copy wholesale. The revised CIPHER four-form board is approved for visual direction only; it remains outside the project and quarantined, and is not cataloged as a project asset. Its outside-project path, dimensions, and file hash are recorded in the C-05d entry below. No production, rig, gameplay, mechanics, runtime, or integration status changes.

All twelve recruits' current evolution-board directions remain direction-only; generated boards are quarantined and are not production assets. The latest GLITCH board is a direction-only/quarantined reference, described by the owner as perfect for the direction. The revised CIPHER four-form board is now approved for visual direction only; it remains outside the project and quarantined. The owner-review outcome and remaining gates are documented in `docs/NETRUNNER_APEX_VISUAL_DIRECTION_REVIEW_2026-10-26.md`.

### Local Codex generated-image board inventory — outside project tree

These PNGs are under `C:\Users\Work\.codex\generated_images\01a17419-ad01-7752-8a49-3a4bcd000fa7\`. They were inspected read-only on 2026-10-26. Their hashes identify these local files only; no source-authoring history or project-side provenance manifest was found. The first three are owner-approved concept directions, not production/rig approval. The two SPECTER boards are unapproved generated proposals. All five remain quarantined and are not integrated or copied into project assets.

| Character / board | File | Dimensions | SHA-256 | Status |
|---|---|---:|---|---|
| CIPHER eye integration | `exec-c03d9718-f45a-4c2f-ae4d-f080f413cb77.png` | 1774×887 | `99c5f4490c6daef44f2ff5c9494f42daea4b49886c4ba30afe98ddfc44f5c6f6` | Owner-approved visual direction; concept only. |
| SPARK drone upgrades | `exec-7b75e7b0-a281-40df-8bcc-7e280b8fe72f.png` | 2172×724 | `5e702f715d484a4b44cc1142f750d0a16ea35e09cb7dcafbbe403522aed7f373` | Mechanic with three distinct drones; owner-approved visual direction; concept only. |
| BULWARK medic progression | `exec-8d05d16b-8dc2-4262-a99b-23ca70c31788.png` | 1774×887 | `1d1883cd9f487971971204fb1397b71c859beef3a787f3445a855f2a0b7f1ebd` | Owner-approved concept direction; no mechanics or production/rig approval. |
| SPECTER sword proposal | `exec-a2e93526-76c7-4b1f-99cf-a8d423e12d83.png` | 1774×887 | `70da1428eeec61c9e8f1241f53db9ed216679dc7ccbf91d29b285a2051ef082b` | Generated four-stage proposal; no project-side approval or production record. |
| SPECTER later sword revision | `exec-8a69ed45-8806-44dc-bc60-6409733d0cf9.png` | 1774×887 | `9bb43aae115b43d19fde3696d98f0452fc8d581a10dbe7463a7c71449d355910` | Later generated proposal; no project-side approval or production record. |

### Revised CIPHER digital-Apex board — C-05d verification — outside project tree

Verified read-only at `C:\Users\Work\.codex\generated_images\01a17419-ad01-7752-8a49-3a4bcd000fa7\exec-9b29115b-db4d-4b74-bcc0-f23479e0e5c4.png` on 2026-10-26. Dimensions: 1774×887; file size: 2,244,076 bytes; SHA-256: `d2552a9ddac3b43ce3e19b69325272776181e013e475e1fd8f001f4147abb606`. Status: owner-approved for visual direction only; outside-project and quarantined. It is not a project asset or production/rig/gameplay approval and has not been copied or integrated. The Military panel is ambiguous because it shows a held rifle and a second weapon-like back item; the artist must identify the back item, and if it is the rifle, show only one carry state for that grade.

None of the boards establishes editable/semantically separated parts, source-aligned boundaries, pivots, neutral assemblies, deformation, rig/hot-swap, or production acceptance. Character-specific gaps include CIPHER rifle mounts, SPARK drone articulation/behavior, BULWARK hose endpoints and artist-authored side-facing cross, and SPECTER sword/hand boundaries, grip pivots, and held/sheath transitions.

## C-05a all-twelve evolution-art coverage map — documentation only — 2026-10-26

Added `docs/C05A_EVOLUTION_ART_COVERAGE_MAP.md`, a documentation artifact with 48 character/tier source-coverage entries and the evidence gates required before any evolution art can be accepted. Concept directions approved: CIPHER's external HUD progresses toward an integrated biomechanical eye with one rifle in one carry state per grade; SPARK is a mechanic with three distinct drones receiving staged hardware upgrades. Generated boards remain quarantined and are not production/rig approvals. Direction remains character-specific; BREAKER's current cybernetic progression is suitable. Proposed mechanics remain provisional/non-canon and mechanical upgrades are not canon. No board path/hash was located locally during C-05a. No image, audio, model, rig, animation, production asset, candidate status, runtime visual, or save changed or was promoted. Existing candidates remain quarantined. No tests or remote reads/writes/uploads/readback occurred.

## 2026-10-26 owner art-scope decisions — no asset changes

All twelve recruits require distinct visible art changes at every evolution step for 1.0. GLITCH is one rifle in two carry states; ECHO's Signal Cascade decoys are distinct from physical sensory devices and are not mapped/countable from visible spheres; IRONCLAD's back-stowed weapon state is approved art direction; BULWARK's side-facing helmet cross is approved and must be separately artist-authored. Exact tier designs, semantic boundaries, mappings, mounts, pivots, transitions, provenance, deformation, rig, and production acceptance remain open as applicable. These decisions change no binary or candidate status; all art candidates remain quarantined. Canonical reconciliation is queued; no remote source was read or edited in this update.

## I-04 twelve-recruit ability trial — no asset changes — 2026-10-26

Added the JSON gameplay trial profile `data/combat/ability_trial.json`; it is provisional simulation data, not an art asset or canonical content. Test Lane added `tests/i04_ability_regression_runner.gd`; after Implementation fixed the ordinary-attack compile error, the focused I-04 runner exited 0. The residual focused gates now pass, including all-twelve action-boundary/no-target coverage, save-state non-mutation, effect expiry, status cleanup, and healing caps. Evidence remains focused-only; no art changed or was promoted, and broader/release validation remains open. No sprites, rigs, attachments, audio, environments, production enemy composition, or user saves changed. All existing character images retain their reference/concept status. See `docs/IMPLEMENTATION_STATUS.md`.

## I-05 hybrid combat trial — no asset changes — 2026-10-26

The bounded hybrid combat trial is code/profile work only. Godot 4.7.2 focused I-05 regressions, CLI seed override check, headless main-scene smoke, and the full regression suite passed. No artwork, audio, model, rig, production visual, save, or source asset changed or was promoted. The code-drawn combatants remain placeholders; the provisional trial numbers are not character or asset specifications. See `docs/I-05B_HYBRID_COMBAT_DECISION_BRIEF.md` and `docs/IMPLEMENTATION_STATUS.md` for exact commands, environment warnings, and limits.

## T-01g evolution-roster viewport review — no asset changes — 2026-10-26

Five UI review captures were produced and inspected in a disposable copy only: ready and locked panels at 1280×720 and 800×450, plus the 800×450 scroll-bottom state. No art, audio, model, rig, runtime visual, or production asset changed or was promoted. The PNGs remain disposable UI QA captures, not production assets. See the T-01g record in `docs/IMPLEMENTATION_STATUS.md` and the remote queue.


## I-11b telemetry design — no asset changes — 2026-10-26

Read-only mapping of current combat/economy seams produced a bounded telemetry design. No art, audio, model, rig, runtime visual, production asset, profile, or save changed. The Character lane reports Notion link text without readable source binaries and unavailable Google Drive access; no remote asset inventory was completed. Concept/reference art remains distinct from animation-ready production parts. See `docs/I-11B_BOUNDED_TELEMETRY_DESIGN.md` and `docs/REMOTE_SYNC_QUEUE.md`.


## I-11a balance/economy evidence inventory — no asset changes — 2026-10-26

Read the live Notion design, decision, roster, and roadmap pages plus local gameplay profiles and services to map balance inputs. This documentation task created no art, audio, model, rig, runtime visual, or production asset. The current code-drawn actors and configured combat/economy values remain prototype placeholders. No tests, simulator run, or asset promotion occurred; Drive was not accessed. See `docs/I-11A_BALANCE_ECONOMY_EVIDENCE_INVENTORY.md` and `docs/REMOTE_SYNC_QUEUE.md`.

## C-02/C-03 all-twelve source-readiness check — no asset changes — 2026-10-26

The Character Art and Rigging Review chat reports nine successful read-only Notion fetches, all unverified, and no Google Drive access. Those records did not supply source-authored Tier I part layers, complete part-boundary/ownership maps, or authored pivots. This is not a Drive asset inventory. No art, ORA, asset manifest, candidate, rig, or runtime asset changed or was promoted. Keep candidates quarantined and reconcile the newer user-approved decisions with canonical pages later; details remain in the local artist-input packet and handoff matrix.

## I-03b SPARK/ECHO body-lane direction — historical; superseded — no asset changes — 2026-10-26

This intermediate direction assigned a separate spatial height/air lane to SPARK and ECHO bodies. It was superseded by the later owner clarification: all recruit bodies stay grounded; SPARK drone attachments and ECHO decoy attachments use the separate spatial lane. Exact behavior remains pending. No floating movement, animation, character data, or runtime asset was created or changed. See `docs/I-03B_SPATIAL_MOVEMENT_DECISION_BRIEF.md`.

## BT-01 local balance simulator and confirmed-reset hardening — no game asset changes — 2026-10-26 America/Chicago

Updated `tools/balance_simulator/` for resolved containment under a caller-selected safe output root and integral-JSON-number handling. Confirmed-reset persistence now stages hash-verified recovery copies for unsupported/invalid backup sidecars. Focused Python regressions passed (10, preflight passed) and Test Lane's Godot 4.7.2 confirmed-reset/save-protection regressions exited 0. No art, audio, model, runtime visual, profile, or user save was changed. Simulator reports written during regression testing were temporary and removed.

## C-02k CIPHER 09B provenance check — no asset changes — 2026-10-26

The four quarantined 09B ORAs retain embedded manifest hash `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3` against the current neighboring `parts_manifest.json` hash `d717fb49e45c4de79e88f50cf4f406ee343583e354fcf50f05bf2019d707ea16`; the four archives are byte-identical at `a54597c5a486b881cc201cc0ae063fb017f0d26331149f3b3829513dfa91b2b8`. Earlier manifest bytes are unavailable. No ORA or asset was changed or promoted. Resolve only with the preserved earlier manifest or a verifiable source snapshot/version record that binds those exact bytes to the ORA. See `docs/ORA_PROVENANCE_AUDIT_2026-10-26.md`.

## R-01 retention/cyberware research — no asset changes — 2026-10-26 America/Chicago

Refreshed the unapproved **District Operations and Cyberware Buildcraft** recommendations in `docs/RETENTION_AND_CYBERWARE_MILESTONE_RESEARCH_2026-10-26.md` against official EF1/EF2 listings, official Cyberpunk 2077 materials, and idle-game research. No visual asset, gameplay item, cyberware data, art, runtime resource, or test was created or changed. C-02d remains the bounded quarantined CIPHER 09B knee sweep; target-scale readability is a non-blocking observation only. The separate SPARK/ECHO air-lane direction changes battlefield position but has no asset/runtime implementation. No candidate art is approved or promoted.

## C-02j ECHO and IRONCLAD source-review consolidation — no asset changes — 2026-10-26 America/Chicago

The Tier I artist-input packet and handoff matrix now record source-backed per-view ECHO device depiction counts and IRONCLAD cable/weapon observations. The ECHO cutout trial remains discarded with no retained semantic device candidate. IRONCLAD’s visible cable cutout remains quarantined; no detached weapon candidate was found in the reviewed workspaces. No image, audio, model, manifest, ORA, runtime asset, or candidate binary changed or was promoted. See `docs/TIER_I_ARTIST_INPUT_PACKET_C02_01.md` and `docs/ARTIST_HANDOFF_MATRIX_T1_01.md`.

## I-01c price disclosure UI — no asset changes — 2026-10-26 America/Chicago

Updated `scripts/main.gd` to label displayed recruitment prices and BREAKER x1/x10 upgrade prices as prototype trial values. The disabled unaffordable recruitment action displays its configured service-derived unmet price. Recruitment prices come from the existing recruitment evaluation; upgrade totals come from the current upgrade-cost service. No image, audio, character asset, data profile, or runtime economy value changed. Fresh Godot import, focused roster/save-migration checks, and the full headless Godot suite passed in Test Lane. Recruitment/Upgrade viewport capture and visual review at 800×450 and 1280×720 remain deferred until after 4:30 PM America/Chicago.

## Active roster default-order rule — no asset changes — 2026-10-26 America/Chicago

The user superseded the previous starter-priority lineup default. New profiles and supported saves without a saved lineup now auto-fill up to six owned recruits in stable founding-roster order. This only changes roster deployment ordering; no artwork, audio, or asset files changed. Focused roster/save-migration checks and the full headless Godot suite passed in Test Lane; visual UI review remains deferred until after 4:30 PM America/Chicago.

## I-07a named-boss reference inventory — no production assets found — 2026-10-26

| Source | Format / dimensions | Finding | Readiness |
|---|---|---|---|
| `migration_package/drive_assets/concept_art/01_world_roster_concept_sheet.png` | PNG, RGBA, 1536×1024 | Visual content is a BREAKER production board despite its world/roster filename and manifest label. | Concept/reference only; no named boss identity evidence; not runtime art. |
| `migration_package/drive_assets/concept_art/02_character_faction_design_sheet.png` | PNG, RGB, 1536×1024 | Character/faction exploration with generic enemy archetypes, including a generic BOSS/ELITE mech. | Concept/reference only; no evidence mapping it to any approved named boss. |
| `migration_package/drive_assets/concept_art/03_breaker_evolution_reference.png` | PNG, RGB, 1536×1024 | BREAKER evolution reference. | Not boss art; not runtime art. |
| `migration_package/drive_assets/concept_art/04_breaker_production_board.png` | PNG, RGB, 1536×1024 | BREAKER production reference board. | Not boss art; not runtime art. |

The inspected local package contains no named-boss-specific art, model, rig, animation, or production asset. This is a local-package finding, not a remote Drive inventory. See `docs/I-07A_BOSS_SOURCE_GAP_AUDIT.md`; no art was changed or promoted.

## C-02d angle-sweep review criteria — no asset changes — 2026-10-26 America/Chicago

The quarantined capture script now distinguishes silhouette-edge gaps from interior triangle folds or texture shear across the five fixed knee poses. No art, part, mesh geometry, weight, source ORA, underpaint, or runtime asset changed. The 4:30 PM render/review gate remains in force; this is a review-tool clarification, not asset approval.

## I-02c roster/persistence code update — no artwork changed — 2026-10-26 America/Chicago

| Paths | Format | Contents | Readiness |
|---|---|---|---|
| `scripts/progression/roster_state_service.gd` | GDScript | Six-slot identity lineup, vacancy/reserve helpers, ownership checks, identity HP initialization, and Reboot healing helpers | Headless regression validated by Test Lane; viewport review pending |
| `scripts/progression/formation_preference_service.gd` | GDScript | Per-recruit Front/Middle/Rear and Vanguard/Assault/Support/Control preference validation and updates | Persistence contract only; no combat behavior; focused/full Godot regressions passed |
| `scripts/persistence/save_service.gd` | GDScript | Version-1-to-2 roster HP migration using copy, validation, staged commit and existing recovery handling | Focused migration and full Godot regressions passed in disposable project |
| `scripts/main.gd`, `scripts/combat/combat_director.gd`, `scripts/progression/economy.gd`, `scripts/progression/reboot_service.gd` | GDScript | UI/deployment handoff, ID-keyed run snapshots, identity HP runtime hookup, and all-owned-recruit Reboot recovery | Full headless Godot regression passed; viewport review pending |

No art, runtime character images, concept sheets, or rig files changed in this implementation pass. Existing character references remain non-production reference artwork; character visual approval/rig readiness is unaffected. Test Lane passed the fresh import, focused roster/save-migration regressions, and full headless Godot suite; viewport review remains pending.

## Save recovery-load presentation — code only — 2026-10-26 UTC

No asset files changed. `scripts/main.gd` now displays SaveService's existing recovery warning and defers any automatic offline-claim save when a recovery copy was loaded, leaving the save set untouched during Load. Confirmed Reset Save behavior is unchanged. After the update, Python preflight passed and the suite passed 108/108 with `TEMP`/`TMP` pointed to the project `tests/` directory; Godot 4.7.2 headless `tests/test_runner.gd` passed with isolated `APPDATA`. The new recovered-load UI branch still lacks a focused assertion; no GUI window was opened and no art/runtime asset changed.

## Save system policy and validation record — 2026-10-26 UTC

No asset files changed. `scripts/persistence/save_service.gd` protects unsupported or unrecoverable saves from ordinary overwrite, recovers in primary → `.bak` → `.bak.prev` order without rewriting the primary, preserves unknown fields during supported updates, and exposes replacement only through the confirmed Reset Save flow. Regression coverage is in `tests/test_runner.gd`; the SaveService does not currently implement migrations from older schema versions. Validation evidence is recorded in `docs/MIGRATION_REPORT.md`. The policy and implementation status were published to Notion and verified by readback; Drive tools are unavailable, so no binary or document upload is claimed. Local Drive/Notion folders remain staging copies only.

## Research source reconciliation — framework remains empty — 2026-10-25

| Local file | Format | Contents / source status | Readiness |
|---|---|---|---|
| `data/progression/research_catalog.json` | JSON | Four approved branch IDs and display names; node arrays remain empty because canonical sources defer node definitions | Framework only; no IDs, costs, rank caps, effects, prerequisites, or unlock rules are approved |
| `scripts/progression/research_service.gd` | GDScript | Generic validation and save-before-apply framework for future Influence purchases | No node purchases or gameplay effects are configured |
| `scripts/main.gd` | GDScript | Read-only Research branch summary UI | No research option can be purchased or applied |

No research assets or runtime content changed during the source audit.

## Tier I OpenRaster source provenance scan — local, read-only — 2026-10-26 UTC

The roster-wide audit at `docs/TIER_I_ORA_PROVENANCE_AUDIT_01.md` inspected 43 ORAs across all 12 Tier I characters: 4 identical CIPHER 09B copies report a digest mismatch against the current manifest, 39 have no embedded source-manifest digest/path and are unverifiable, and 0 have a verifiable match. The mismatch copies do not represent four independent source discrepancies. All candidate art remains quarantined; no ORA or manifest was changed. Local staging only; remote reconciliation remains queued.

## CIPHER 09B ORA provenance — unresolved source blocker — 2026-10-26 UTC

The quarantined authoring ORA embeds a `source_candidate_manifest_sha256` that differs from the current neighboring `parts_manifest.json`. The builder computes that field from the neighboring manifest at creation. Timestamps place the current manifest about 39 minutes after the ORA, which is suggestive of a later edit but does not prove the old manifest contents or establish either file as authoritative. No matching prior manifest copy or Git history is available locally. Do not repair either artifact based on inference; reconcile when contemporaneous source evidence is available. See `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/ART_RIG_REVIEW_STATUS_01.md`. The candidate remains quarantined; no artwork or runtime files changed.

## BREAKER run-level purchase transaction — code/data update — 2026-10-26

| Path | Format | Contents | Status |
|---|---|---|---|
| `scripts/progression/economy.gd` | GDScript | Candidate x1/x10 affordability and per-level credit calculations using the configured cost curve | Prototype logic; values are trial-only; no level cap is approved |
| `scripts/combat/combat_director.gd` | GDScript | Preview/apply boundary for the BREAKER run-level purchase and resulting combat stats/HP, including the existing lifetime Influence bonus | Prototype logic; isolated Godot regression passed |
| `scripts/main.gd` | GDScript | Save-before-apply x1/x10 HUD transaction | Prototype UI/runtime path; isolated Godot regression passed |
| `data/characters/breaker_t1.json` | JSON | BREAKER's base level-up cost and growth candidate | Placeholder configuration; 20 base and 1.12 growth are playtest values, not final balance |
| `tests/test_runner.gd` | GDScript | x1/x10 cost, affordability, save failure, unloaded-save guard, HP, and Influence modifier regressions | Test Lane regression coverage; isolated Godot suite passed |
| `tests/user_data_path_save_probe.gd` | GDScript | Separate-process x1 purchase write/readback probe in disposable user data | QA helper; isolated round-trip passed and normal user save was unchanged |

**Validation update:** Test Lane's isolated Godot 4.7.2 workflow passed the purchase regressions, full headless suite, Windows GUI launch, and separate-process x1 save readback; Python passed **105/105**. No art or binary asset changed. Exact costs and persistence are covered for BREAKER's prototype path; the level cap remains undefined and the other eleven recruit level paths are not implemented.

## Tier I quarantined part candidate audit — 2026-10-25/26

`docs/TIER_I_QUARANTINED_PART_AUDIT_01.md` records the read-only roster audit of independently reviewable isolated-part candidates. No art/runtime files changed. All candidates remain quarantined. CIPHER 09B's knee-guard boundary and hinge pivot pass only their scoped, user-approved review; the remaining CIPHER candidate set is incomplete. The DEADLOCK antenna and VECTOR knee-guard cutouts are explicitly rejected for semantic contamination even though their selected pixels match source RGB. BREAKER underarm is inferred. Other reviewed attachment/detail candidates lack required source-backed view, grip, socket, or owner input. See the audit and `docs/ARTIST_HANDOFF_MATRIX_T1_01.md` for candidate paths, evidence, and next artist inputs.

## Attachment event transport follow-up — code support only — 2026-10-26 UTC

`CombatDirector` now exposes a sequenced ability-event presentation hook for future authoritative ability code. No character asset, pivot, rig, animation, or attachment scene was changed. The all-12 workspaces remain blank quarantined art-preparation files; no art is promoted or production-ready by this code change. Python 105/105, all-12 workspace audit, Godot clean import, isolated GUI launch, full headless regression, and save/load smoke validation passed. No remote upload is claimed.

## SPARK Tier I drone cutouts and provisional pivots — quarantined candidate 01

| Local file | Format | Purpose / readiness |
|---|---|---|
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_01_BLUE_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png` | PNG, RGBA, 392×321 | Source-derived static drone cutout; visible silhouette reviewed on checkerboard at native scale; quarantined, not animation-ready. |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_02_RED_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png` | PNG, RGBA, 342×296 | Source-derived static drone cutout; visible silhouette reviewed on checkerboard at native scale; quarantined, not animation-ready. |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_03_AMBER_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png` | PNG, RGBA, 322×311 | Source-derived static drone cutout; visible silhouette reviewed on checkerboard at native scale; quarantined, not animation-ready. |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/attachment_pivots_review_01.json` | JSON | Three provisional, author-placed pivots on the visible central cores; role/owner IDs recorded; all approval/readiness flags remain false. |
| `docs/visual_qa/SPARK_DRONE_CANDIDATE_01_PIVOT_REVIEW_01_QUARANTINED.png` | PNG, 1560×494 | Native-scale checkerboard visual review with pivot marks; quarantined review evidence. |

Source-fidelity and alpha audit: **PASS** for exact RGB preservation, zero pairwise mask overlap, transparent margins, and one contour per drone. Godot 4.7.2 full headless suite **PASS**, including three independent PolyRig contour meshes and pivot-inside-visible-art checks; Python regression **88/88 PASS**; all-12 prep audit **PASS**. This verifies only visible static cutouts and provisional rigid-body pivot placement; articulation, rotor behavior, flight/formation, gameplay event mapping, runtime integration, and production readiness remain unverified.

## Shared attachment presentation support — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `scripts/presentation/attachment_presentation_receiver.gd` | Godot GDScript | Plays only explicitly mapped animation clips for routed, monotonically sequenced simulation events. Presentation-only; not connected to character runtime scenes. |
| `tests/test_runner.gd` | Godot GDScript | Regression covers event routing, mapped-only animation playback, immutable event values, duplicate rejection, and no-clip event handling. |

Godot 4.7.2 full headless suite **PASS**; Python regression **88/88 PASS**; all-12 workspace audit **PASS**. This is reusable attachment infrastructure, not a weapon/drone/accessory implementation. All character art, authored pivots, sockets, per-character event mappings, and pose/deformation reviews remain pending; no new binary asset was created.

## Current all-12 attachment workspace check — 2026-10-25 UTC

- The twelve current `attachment_decomposition_01` / `attachment_decomposition_02` OpenRaster workspaces remain blank, quarantined authoring containers with embedded references and named empty layers; they are not completed character parts or rigs.
- Paired visual review and current paths are recorded in `ATTACHMENT_REFERENCE_REVIEW_12.md` and `ATTACHMENT_DECOMPOSITION_BATCH_12.md`. SPECTER/GLITCH cape sheets remain continuous; unresolved weapon/drone questions are not encoded as extra art or fixed runtime counts.
- All 12 current workspaces opened read-only in Krita with no repair prompts; no save/reopen round-trip or art edit was performed. Exported semantic parts, authored pivots, and production rig compatibility remain unverified.

## CIPHER candidate 09B pivot and hinge diagnostic — review-only — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `tests/art/capture_cipher_candidate_09b_knee_guard_motion.gd` | Godot GDScript | Rebuilds the 09B knee-region crop from quarantined parts and renders rigid rotations around the user-approved guard pivot; refuses output overwrite |
| `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_GUARD_MOTION_07_QUARANTINED.png` | PNG, 1280×720 | Source, neutral, and ±15° knee views; neutral crop differs from candidate assembly by 0 / 70,000 pixels; quarantined diagnostic only |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/parts_manifest.json` | JSON | Corrected summary: the guard pivot alone is approved/authored; other pivots remain unauthored |

Godot 4.7.2 normal-renderer capture **PASS**. Full project validation **PASS**: Python 86/86, all-12 workspace audit, and headless Godot suite. This does not verify deformation, seam quality, or production readiness.

## Sandbox-aware Python test runner — local workflow tool — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `tests/run_python_tests.py` | Python | Checks write permissions for project-local test fixture parents before launching unittest discovery; reports blocked environment access separately from test failures. Not run in this update. |
| `AGENTS.md`, `tests/README.md` | Markdown | Direct future Python suite runs through the preflight wrapper and explain its blocked-permission result. |

This changes only how the Python regression suite is started. No game asset or runtime file changed.

## Remote asset-source check — 2026-10-25 21:30 UTC

Notion read-only access is available and its Asset Library/Project HQ/Roadmap/Decision Log/Backup Protocol pages were fetched. No Google Drive file tool is exposed in this session, so local asset status has not been reconciled to Drive and no remote asset update/upload is claimed. All character candidate states remain as recorded below and quarantined where specified.

## Bounded character-art work orders — local tool — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `tools/art/build_character_work_order.py` | Python | Builds a one-character work packet from local plan metadata; syntax/help, generated CIPHER packet content, and duplicate-output refusal verified; out-of-project path rejection not tested |
| `docs/AI_CHARACTER_WORK_ORDERS.md` | Markdown | Instructions and limits for using generated work packets; reconstructed local plan is not canonical source data |

## PolyRig multi-island attachment regression — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `tests/art/test_polyrig_single_contour_per_texture.gd` | Godot 4.7.2 headless | PASS: detects two disconnected synthetic components and triangulates them as separate mesh inputs; no character art is modified or approved |
| `docs/CHARACTER_PART_AUTHORING_GUIDE.md` | Markdown | Records PolyRig 0.9.3 Auto Mesh's one-contour-per-texture constraint and separate semantic/moving-item mesh requirement |

The installed plugin's Auto Mesh source uses only one alpha contour for each texture. This is a tool limitation to account for during authoring; no character art, runtime receiver, or production rig was changed.

Current verification: the PolyRig synthetic split-input and geometry/weight headless checks pass; the full Python suite passes **85/85** and the all-12 ORA/source/sidecar audit passes. These results validate tooling and workspace structure only.

## Character-art intake and gameplay-readability workflow — local tooling/docs only, no production art — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `docs/CHARACTER_PART_AUTHORING_GUIDE.md`, `docs/CHARACTER_ART_PIPELINE.md`, `docs/RIGGING_PREP_ALL_12.md` | Markdown | Bounded semantic intake stop rule; reference-backed shared-rig reuse and exceptions; combined action review at 1280×720 and 800×450 |
| `tests/art/rig_review_workbench.gd` | Godot GDScript | Reviewer-entered joint min/max and context note produce five neutral single-joint diagnostic samples with explicitly unverified metadata; not an animation gate |
| `tools/art/build_character_review_bundle.py` | Python | Manual checklist includes the stop rule, authored action-range evidence, and gameplay-scale combined-pose review; bundle remains quarantined and non-approving |

No character art, gate state, or runtime scene was changed. The camera-scale evidence step is currently manual; no automated capture harness exists.

## Character-art workflow review improvements — local tools, no production art — 2026-10-25 UTC

| Local file | Format | Purpose / readiness |
|---|---|---|
| `tools/art/character_art_manifest.schema.json`, `tools/art/character_art_manifest.template.json` | JSON Schema / JSON | Adds an optional backward-compatible ground-pivot property (required by manifest preview) and evidence-record shape for five gates; template remains review-only with gates false |
| `tools/art/validate_character_art_manifest.py` | Python | Checks optional approved-reference SHA-256 and requires evidence records/files for gates marked true; structural validity stays separate from production readiness |
| `tools/art/build_character_review_bundle.py` | Python + Pillow | Creates a no-overwrite, quarantined static review packet; no semantic or production approval |
| `tests/art/manifest_character_rig_preview.gd`, `tests/art/rig_review_workbench.gd` | Godot GDScript | Loads standard manifest parts, uses authored pivots and 256 px comparison scale, and captures diagnostic joint sweeps; review-only, neutral pose for standard manifests |
| `tools/art/render_semantic_part_contact_sheet.py` | Python + Pillow | Renders legacy and standard manifest parts at native scale on checkerboard; semantic correctness remains a human gate |

No character art was created or promoted by these tools. See `docs/CHARACTER_ART_PIPELINE.md` for usage and limitations.

## Combat event and attachment presentation-routing foundation — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `scripts/combat/combat_director.gd` | GDScript | Fixed-step prototype simulation | Emits structured resolved-attack data after damage; no ability-specific event emitted |
| `scripts/presentation/attachment_event_router.gd` | GDScript | Structured combat events | Headless-tested actor-instance source/target routing, isolated event copies, and duplicate-sequence suppression; connected to main scene, but no production equipment nodes are registered |
| `tests/test_runner.gd` | GDScript / Godot headless | Combat director and router | Covers hit event order/state isolation and attachment owner/event filtering; no character art integration |

## Structured combat attachment-event hook — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `scripts/combat/combat_director.gd` | GDScript | Fixed-step prototype combat | Emits deep-copied attack-resolved events after damage is committed; generic integration hook only, not character-specific presentation |
| `tests/test_runner.gd` | GDScript / Godot headless | CombatDirector | Regression covers ally/enemy payloads, deterministic ordering, post-commit state, and event-copy isolation |
| `docs/ATTACHMENT_FUNCTION_CONTRACT.md` | Markdown | Live roster page and approved local visual references | Defines future weapon/accessory/drone event links and open details; no attachments implemented |

## Twelve-character editable attachment workspaces — quarantined — 2026-10-25 UTC

**Current pointer:** five characters use `assets/characters/<id>/tier_01_drafts/attachment_decomposition_01/` and seven source-reviewed updates use `attachment_decomposition_02/`. All are blank, quarantined authoring workspaces. Earlier batches remain preserved. See `docs/ATTACHMENT_DECOMPOSITION_BATCH_12.md` and `docs/ATTACHMENT_REFERENCE_REVIEW_12.md` for current paths, source observations, and unresolved items. No production art or functional attachment has been implemented.

**On-disk count (2026-10-25):** 38 OpenRaster files exist under `assets/characters/`: 12 version-01 and 7 version-02 current attachment-preparation workspaces; the remaining 19 are preserved earlier edit prep and character-specific experiments. This inventory count does not mark any candidate production-ready.

| Current per-character file pattern | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/<id>/tier_01_drafts/attachment_decomposition_0[12]/<ID>_T1_ART_EDIT_WORKSPACE_0[12]_QUARANTINED.ora` (12 total; BREAKER 1024×1536, others 1536×1024) | OpenRaster; approved local anatomy/concept refs and blank granular authoring layers | Per-character `concept_reference` and `anatomy_reference` in `tools/art/rigging_prep_all_12.json` | Edit prep only / quarantined; current versions not visually opened in Krita |
| Corresponding `README_EDIT_PREP.md` sidecars in each current workspace folder | Markdown | Same per-character plan and visual review | Decomposition guidance and unresolved source questions; no production claim |

| Local file group | Format / source | Readiness |
|---|---|---|
| `assets/characters/<id>/tier_01_drafts/edit_batch_01/*_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` for all 12 roster IDs | OpenRaster, approved local anatomy/concept references and blank named authoring layers | **EDIT PREP ONLY / QUARANTINED**; not semantic parts, a rig, gameplay behavior, or runtime content |
| `assets/characters/<id>/tier_01_drafts/edit_batch_01/README_EDIT_PREP.md` | Per-character workspace sidecar and source pointers | Lists attachment items and general functional validation; no production claim |
| `tools/art/build_roster_edit_workspaces.py` | Pillow + OpenRaster packaging | No-overwrite workspace builder; never paints/extracts or approves art |
| `tools/art/rigging_prep_all_12.json` | Approved visual references and reconstructed/local roster context | Includes per-character attachment function requirements and unresolved details; planning data only; no runtime behavior |
| `docs/ATTACHMENT_FUNCTION_CONTRACT.md` | Live roster source link, approved character references, local offline handoff | Simulation-to-presentation contract and validation requirements; **not implemented runtime behavior** |

The SPARK workspace has separate blank layers for three source-backed attack drones. ECHO count remains unresolved. Eleven same-size concept refs are embedded as hidden layers; BREAKER’s board is separately referenced because its canvas differs. The generated OpenRaster files are local project assets and have not been uploaded to Google Drive.

**Krita open check (2026-10-25):** all 12 current quarantined `.ora` edit workspaces opened without repair warnings and displayed their listed reference/canvas dimensions. This read-only application check does not verify blank authoring-layer pixels, semantic completeness, part ownership, hidden anatomy, pivots, deformation, or rig compatibility. No workspace was edited or saved; status remains edit prep only and quarantined.

### Individual edit-batch files

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/bulwark/tier_01_drafts/edit_batch_01/BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/BULWARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/breaker/tier_01_drafts/edit_batch_01/BREAKER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1024×1536 | `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png` + `migration_package/drive_assets/concept_art/04_breaker_production_board.png` | Edit prep only / quarantined |
| `assets/characters/cipher/tier_01_drafts/edit_batch_01/CIPHER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/spark/tier_01_drafts/edit_batch_01/SPARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/SPARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/specter/tier_01_drafts/edit_batch_01/SPECTER_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/SPECTER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/ironclad/tier_01_drafts/edit_batch_01/IRONCLAD_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/IRONCLAD_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/stitch/tier_01_drafts/edit_batch_01/STITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/STITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/STITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/recoil/tier_01_drafts/edit_batch_01/RECOIL_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/RECOIL_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/RECOIL_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/echo/tier_01_drafts/edit_batch_02/ECHO_T1_ART_EDIT_WORKSPACE_02_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/ECHO_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/ECHO_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Current blank edit prep, v2 / quarantined; drone count and decoy visual unresolved |
| `assets/characters/echo/tier_01_drafts/edit_batch_01/ECHO_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | Same approved ECHO references | Superseded blank edit prep, preserved / quarantined |
| `assets/characters/vector/tier_01_drafts/edit_batch_01/VECTOR_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/VECTOR_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/VECTOR_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/deadlock/tier_01_drafts/edit_batch_01/DEADLOCK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/DEADLOCK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/DEADLOCK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |
| `assets/characters/glitch/tier_01_drafts/edit_batch_01/GLITCH_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora` | OpenRaster, 1536×1024 | `docs/visual_qa/GLITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` + `docs/visual_qa/GLITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Edit prep only / quarantined |


## Founding roster Tier I rigging preparation — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `tools/art/rigging_prep_all_12.json` | JSON | Existing approved concept/anatomy turnarounds, BREAKER specification/review material, and existing per-character candidates | Twelve-character rigging inventory and shared part/gate plan; planning metadata only, no art approval |
| `docs/RIGGING_PREP_ALL_12.md` | Markdown | The JSON inventory and current local rigging evidence | Reviewable work plan; distinguishes candidate stages from production approval |
| `tools/art/audit_rigging_prep_all_12.py` | Python | Local roster and rigging plan | Checks roster/source/candidate and per-character attachment contract coverage, then inspects all 12 on-disk ORA archives/sidecars, exact attachment-layer coverage, blank alpha, reference visibility/embedding, byte-exact reference pixels, and quarantine status; does not certify anatomy or approve art |
| `tests/test_rigging_prep_all_12.py` | Python unittest | Rigging-prep audit | Three focused inventory/attachment-contract/on-disk ORA tests; not an anatomy or Krita/Godot visual rig test |

No new character art, runtime resource, remote upload, or production-ready rig was created by this preparation milestone.

## CIPHER QA rig blockout — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `tests/art/cipher_t1_rig_blockout_preview.tscn` | Godot scene | Isolated CIPHER skeletal QA blockout | Test-only scene, not used by main/runtime project |
| `tests/art/cipher_t1_rig_blockout.gd` | GDScript | Godot `Skeleton2D` and `Bone2D` blockout | 16-bone proposal with 15 generic placeholders; no production anatomy/art |
| `tests/art/test_cipher_rig_blockout.gd` | GDScript | Godot 4.7.2 headless regression | Passes hierarchy, placeholder count, six pose transforms, fixed ground anchor and head pivot; does not verify full animation or joint artwork |

The candidate torso-generation outputs were rejected before importing into the project: both failed the art-intake constraints. They are not listed as candidate assets and no torso art was retained.

## CIPHER Tier I rigging-prep evidence — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `docs/CIPHER_T1_RIGGING_PREP_01.md` | Markdown | Approved CIPHER concept/anatomy references plus local pilot findings | Rigging proposal and missing-part checklist; pivots/scales labeled provisional |
| `tests/art/test_cipher_head_pivot_candidate.gd` | GDScript | Godot 4.7.2 isolated transform smoke test | Test-only; confirms texture loading, scale math, and fixed pivot across five small rotations; not a full rig test |

The test imports the quarantined cleaned head composite solely as an isolated art-review input. It does not make this image runtime content or establish production readiness.

## CIPHER head/neck alpha-cleaned review candidate — quarantined — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/cleanup_working/CIPHER_T1_HEAD_NECK_CLEANED_CANDIDATE_01_QUARANTINED.png` | PNG, RGBA, 1536×1120 | Krita alpha-mask cleanup and centered canvas extension from candidate 01; original RGB pixels preserved | Mechanical alpha/margin audit **PASS**; visual/anatomy/semantic/pivot/animation gates **NOT VERIFIED**; **QUARANTINED**, not runtime or production art |
| `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/cleanup_working/CIPHER_T1_HEAD_NECK_CLEANUP_WORKING_COPY.png` | PNG, RGBA, 1536×1024 | Untouched duplicate of original before Krita cleanup | Working source copy; SHA-256 matches original |

The original candidate and working copy remain unchanged. The cleaned PNG is a separate review export; do not treat the alpha-audit pass as anatomy or production approval. It remains only in local draft storage and has not been uploaded to Google Drive or added to Godot.

## User-approved anatomy turnaround references — 2026-10-25 UTC

The user approved these turnarounds as anatomy references for visible proportions and anatomy. They are not production sprites, transparent cutouts, rig input, or runtime assets; concealed anatomy, exact part boundaries, pivots, and deformation remain unverified. All are PNG, 1536×1024 RGB.

| Local file | Source | Readiness |
|---|---|---|
| `docs/visual_qa/BULWARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved BULWARK visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved CIPHER visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved SPARK visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/SPECTER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved SPECTER visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved IRONCLAD visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/STITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved STITCH visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/RECOIL_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved RECOIL visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/ECHO_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved ECHO visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/VECTOR_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved VECTOR visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/DEADLOCK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved DEADLOCK visual reference | **Approved anatomy reference; not production parts** |
| `docs/visual_qa/GLITCH_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Approved GLITCH visual reference | **Approved anatomy reference; not production parts** |

## CIPHER Tier I part-atlas pilot — quarantined — 2026-10-25 UTC

| Local file/group | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/parts_atlas_candidate_01/CIPHER_T1_PARTS_ATLAS_CANDIDATE_01_QUARANTINED.png` | PNG, RGBA, 1536×1024 | Generated atlas pilot | Rejected/quarantined; not semantic rig input |
| `assets/characters/cipher/tier_01_drafts/parts_atlas_candidate_01/components/` | Numbered RGBA crops + JSON | Alpha-component extractor | Review aid only; unnamed, no pivots |
| `assets/characters/cipher/tier_01_drafts/parts_atlas_candidate_02/CIPHER_T1_PARTS_ATLAS_CANDIDATE_02_QUARANTINED.png` | PNG, RGBA, 1536×1024 | Generated atlas pilot | Quarantined; clipping/duplicate/ambiguous parts in diagnostic |
| `assets/characters/cipher/tier_01_drafts/parts_atlas_candidate_02/components/` | 18 numbered RGBA crops + JSON | Alpha-component extractor | Review aid only; unnamed, no pivots, not rig input |
| `docs/visual_qa/CIPHER_T1_PARTS_ATLAS_DIAGNOSTIC_02_TRIMMED_2026-10-25.png` | PNG, 1200×1200 | Crop contact sheet | Visual rejection evidence only |
| `tools/art/extract_character_atlas_components.py` | Python | Local tooling | Deterministic alpha crop review aid, not semantic recognition |
| `docs/CHARACTER_PART_AUTHORING_GUIDE.md` | Markdown | CIPHER pilot findings | Required workflow guidance for future character part passes |

## CIPHER individually prompted head/neck candidate — quarantined — 2026-10-25 UTC

| Local file/group | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/CIPHER_T1_HEAD_NECK_CANDIDATE_01_QUARANTINED.png` | PNG, RGBA, 1536×1024 | Generated from approved CIPHER concept + anatomy turnaround references | Identity cues recognizable; external alpha haze and insufficient vertical safety margin; **quarantined** |
| `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/components/component_01.png` | PNG, RGBA crop | Alpha-threshold-32 review extraction | One connected review crop; unnamed, no pivot, not production-approved |
| `assets/characters/cipher/tier_01_drafts/individual_parts_candidate_01/components/components.json` | JSON | `extract_character_atlas_components.py` | Metadata states quarantined, semantic names false, pivots false, production approval false |
| `tools/art/audit_semantic_cutout.py` | Python / Pillow | Single RGBA part alpha/margin audit | Mechanical intake report includes alpha-island areas/bounds; a pass cannot approve anatomy or production art |

| Local review board | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `docs/visual_qa/ANATOMY_TURNAROUND_COMPARISON_01_2026-10-25.png` | PNG, 1040×1438 RGB | Paired approved concepts and turnaround drafts, recruits 1–4 | Visual QA aid only |
| `docs/visual_qa/ANATOMY_TURNAROUND_COMPARISON_02_2026-10-25.png` | PNG, 1040×1438 RGB | Paired approved concepts and turnaround drafts, recruits 5–8 | Visual QA aid only |
| `docs/visual_qa/ANATOMY_TURNAROUND_COMPARISON_03_2026-10-25.png` | PNG, 1040×1098 RGB | Paired approved concepts and turnaround drafts, recruits 9–11 | Visual QA aid only |

## Eleven approved individual Tier I visual references — 2026-10-25 UTC

These local concept images are **user-approved Tier I visual references**. Their character identity and depicted appearance are approved for visual direction. They are not production art, separated sprite parts, rig inputs, or runtime assets; hidden anatomy, part boundaries, pivots, and deformation still need authoring and validation. All are PNG, 1536×1024 RGB, generated for this project and stored under `docs/visual_qa/`.

| Local file | Source cues | Readiness |
|---|---|---|
| `docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Netrunner / sharpshooter, hacked rifle optics | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/SPARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Combat engineer / drone operator, scrapyard mechanic | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Infiltrator / blade specialist, cloaked priority strike | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/IRONCLAD_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Female heavy gunner / tank, powered armor | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/STITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Rippertech / chem specialist, implant surgeon | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/RECOIL_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Shotgunner / brawler, hydraulic prosthetic arm | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/ECHO_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Netrunner / drone operator, neural injury, drones as sensory extensions | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/VECTOR_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Independent courier, blade skirmisher, reflex implants | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/DEADLOCK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Tactical marksman / anti-cyberware suppression | **Approved visual reference.** Not a rig or sprite asset. |
| `docs/visual_qa/GLITCH_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | Female cyberpsycho / infiltrator, neural acceleration damage | **Approved visual reference.** Not a rig or sprite asset. |

The matching BULWARK proposal is listed below. The full proposal scope and caveats are recorded in `docs/CHARACTER_ART_CONCEPT_PROPOSAL_01.md`. The local `Notion/Visual QA/` and `Google Drive/01 - Concept Art/` copies are staging copies only; they do not indicate remote publication.

## Founding-roster art intake tooling — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `docs/visual_qa/BULWARK_T1_CONCEPT_TURNAROUND_01_2026-10-25.png` | PNG, 1536×1024 RGB | User-approved Tier I visual reference, based on roster facts | **Approved visual reference.** Not parts, rig-ready, or runtime content. |

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `docs/visual_qa/ROSTER_T1_CONCEPT_PROPOSAL_01_2026-10-25.png` | PNG, 1448×1086 RGB | Generated from roster-backed prompt; broad visual guidance from local class/faction concept board | Eleven-panel **unapproved concept proposal** only. Not canon, not sliced, not rig-ready, not runtime content. |
| `docs/CHARACTER_ART_CONCEPT_PROPOSAL_01.md` | Markdown | Live Founding Recruit Roster + local concept audit | Panel mapping, provenance, noncanonical details, and next approval gate. |

The eleven non-BREAKER source-backed intake briefs are in [`docs/CHARACTER_ART_INTAKE_11.md`](CHARACTER_ART_INTAKE_11.md). They are text-only production intake notes derived from the live roster; they do not add or approve art. Local source audit found generic class/faction concept boards and BREAKER-only production material, with no per-character animation-ready parts for the remaining roster.

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `tools/art/character_art_roster.json` | JSON, twelve founding IDs | Live Notion Founding Recruit Roster, retrieved 2026-10-25 | Tooling index only; one explicit BREAKER review-manifest exception; other recruits have no submitted art manifest. |
| `tools/art/character_art_manifest.schema.json` | JSON Schema Draft 2020-12 | Shared v1 character/tier intake contract | Editor/tooling aid. Cross-file paths, image pixels, inter-field references, and measured-alpha constraints are enforced by the Python validator. |
| `tools/art/character_art_manifest.template.json` | JSON | Shared v1 template | Intentionally incomplete placeholders; not a character manifest and not counted by roster audit. Production gates default false. |
| `tools/art/validate_character_art_roster.py` | Python 3 / Pillow | Roster config + standard per-tier manifest filename | Batch report for all 12; discovers only `character_art_manifest.json`, ignores unregistered historical BREAKER trials, and never creates art/manifests. |
| `docs/CHARACTER_ART_PIPELINE.md` | Markdown | Local implementation and live roster source | Documents intake, status meanings, commands, and limits. |

Current audit: one required Tier I manifest is present (BREAKER, `review_only`); eleven recruits remain `NOT SUBMITTED`. Twenty-two focused Python tests pass; Godot 4.7.2 import, BREAKER rig smoke test, and the full prototype suite pass. No art was created or promoted by the intake tool.

## Candidate01 v20 retained for review — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_tapered_underarm_v20.png` | PNG, 1024×1536 RGBA | Inferred underlay masked beneath the approved candidate01 visible art | **Review candidate by user direction.** Keep quarantined. The 100-contact regression passes 104–267 contacts over 206 sampled poses; this does not approve anatomy, appearance, production art, or runtime integration. No further shape revision is part of this disposition. |

## Manifest-driven BREAKER review rig — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/pivot_manifest.json` | JSON, schema version 1 | Local profile trial and hand-estimated source-pose pivots | `review_only`; integrity checks pass; does not approve art, pivots, anatomy, seams, animation, or runtime use. |
| `tools/art/validate_character_art_manifest.py` | Python 3 / Pillow | Manifest validator | Validates manifest structure, safe paths, source/layer decoding, canvas/alpha/pivots/bones/order, and measured silhouette height; keeps art-readiness blockers separate from structural pass. |
| `tests/test_character_art_manifest.py` | Python unittest | Current BREAKER manifest | Seven positive/negative integrity tests; not an art-quality or anatomy test. |
| `tests/breaker_profile_rig_trial_01_preview.gd` and `tests/test_breaker_profile_rig_trial_01.gd` | Godot 4 GDScript | Manifest-driven isolated review fixture | 13-layer hierarchy and idle/walk/punch/hit smoke test passes. Stays under `tests/`; no runtime integration. |

## BREAKER arm-fit review additions — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v10_reference_row_profile/hidden_biological_upper_arm_donor.png` | PNG, 1024×1536 RGBA | Candidate 09 visible skin-row profile plus generated texture | **Rejected shell-off fit:** proximal extension reads as a wedge. Quarantined; not runtime or canon. |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v11_candidate16_skin_donor/inferred_biological_upper_arm_underpaint.png` | PNG, 1024×1536 RGBA | Top three warm-skin threshold regions from candidate 16, transformed to candidate 09 arm landmarks | Shell-on composite is pixel-identical after opaque-coverage clipping; shell-off visual **rejected** for disconnected patches and texture artifacts. Quarantined. |
| `tools/art/build_breaker_trial09_v11_candidate16_skin_donor.py` | Python / Pillow | Reproducible candidate-16 mask, transform, shell-on audit, and review-board generator | Static check passes shell-on identity; does not certify anatomy. |
| `docs/visual_qa/BREAKER_T1_candidate09_v11_candidate16_skin_donor.png` | PNG, 1590×634 | Generated by v11 builder | Review board for source, shell-on and shell-off views; hidden anatomy remains unverified. |
| `tests/capture_breaker_profile_rig_trial_09_canon_v4_manual_skin.gd` | Godot 4 GDScript | v4 isolated review rig | Display capture seeks fixed idle/walk/punch/hit/defeat sample times; visual review only. |
| `tests/capture_breaker_trial09_v4_underpaint_comparison.gd` and `docs/visual_qa/breaker_trial09_v4_underpaint_comparison_1280x720_punch.png` | Godot GDScript / PNG, 1280×720 | Candidate 09 v4 review rig | Confirms the small punch-frame dark fragment is present with underpaint hidden too; visible-source seam remains open. |
| `tests/capture_breaker_trial09_v4_punch_layer_isolation.gd` and `docs/visual_qa/breaker_trial09_v4_punch_layer_isolation_hide_*.png` | Godot GDScript / PNG, 1280×720 | Candidate 09 v4 review rig | Selective hides for upper-arm skin, shell, cyber forearm, torso, and natural upper arm did not isolate the trailing dark contour. It may be a cable detail or a split-layer artifact; ownership remains unconfirmed. Review-only; no runtime use. |

All new arm donors and captures are review-only. No runtime reference or remote binary upload is claimed.

## Candidate01 v20 rendered-edge regression — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_tapered_underarm_v20.png` | PNG, 1024×1536 RGBA | Generated from the quarantined candidate01 hidden-anatomy donor; clipped behind existing visible torso/skin/shell/prosthesis | **Review-only inferred underlay.** Opaque source coverage audit passes. Godot render shows bounded blending under semi-transparent shoulder-edge texels; not byte-identical full-frame parity and not production anatomy. |
| `candidate01_tapered_underarm_v21.png`, `candidate01_tapered_underarm_v22.png` in the same draft folder | PNG, 1024×1536 RGBA each | One-pixel and three-pixel mask erosions of v20 | **Rejected exploratory variants.** They narrow the shoulder-root connection and do not eliminate the rendered edge blend. Keep quarantined; do not use in runtime or represent as accepted fixes. |
| `tools/art/build_breaker_candidate01_tapered_underarm_v21.py`, `tools/art/build_breaker_candidate01_tapered_underarm_v22.py` | Python / Pillow | Reproducible one-pixel and three-pixel erosion trials | Exploratory only; tests did not justify replacing v20. |
| `tests/test_breaker_candidate01_v20_shell_on_visual_parity.gd` | Godot 4 GDScript | OpenGL Compatibility screenshot comparison, hidden/shown underlay | Passes 206 stable sampled poses with a configured maximum 64 changed pixels / 96 channel levels, constrained to the shoulder/upper-arm region; observed peak 37 / 83. Headless viewport render is unsupported. |
| `docs/visual_qa/BREAKER_T1_v20_parity_mismatch_zoom.png` | PNG review board | Captured Godot 4.7.2 OpenGL Compatibility renders, underlay off/on | Shows a small translucent shoulder-edge blend difference. Diagnostic only; shell-off anatomy and production readiness remain unverified. |
| `docs/visual_qa/BREAKER_T1_candidate01_v20_elbow_join_zoom.png` | PNG, 1360×640 RGB | 3× nearest-neighbor crop of Godot neutral-detail shell-off/on captures | Shows the inferred biological upper arm to elbow-start prosthesis join. Focused tests require 100 source-pixel contact and pass v20 at 104–267 across 206 poses. Review evidence only; no authored joint or production part. |
| `docs/visual_qa/BREAKER_T1_v20_vs_candidate01_source_arm_review.png` | PNG comparison board | Flattened candidate01 reference and v20 isolated rig capture | Shows shell-off reconstructed underarm for human review; not an authored sprite part or approval record. |

The approved Tier I boundary is external shoulder shell over biological upper arm; the mechanical prosthesis begins at the elbow. This is a design decision, not approval of the v20 art. All draft images stay quarantined and out of runtime scenes.

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `docs/visual_qa/BREAKER_T1_candidate01_inferred_elbow_anatomy_imagegen_study_01.png` | PNG, 1024×1536 RGB | Generated as a localized anatomy exploration using approved profile candidate 01 as visual reference | **Quarantined comparison only.** Not a cutout or production part. Arm-only panel overstates bicep size; full-body panel alters unrelated source details. No pixels were used in runtime or the v20 rig. |

## BREAKER arm-boundary concept review — 2026-10-25 UTC

### v12 punch-contour source and parent trial — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v12_cable_component/pelvis_without_cable_component.png`, `cable_component.png` | PNG RGBA, 1024×1536 | Exact partition of a 264-pixel connected component from v4 `pelvis.png` | `.gdignore`d review-only; exact RGBA recomposition passes. Cable intent and animation owner are unresolved. |
| `tools/art/build_breaker_trial09_v12_cable_component.py` | Python / Pillow | Isolates the source-connected component and verifies exact reconstruction | PASS for source partition only; makes no semantic/anatomy claim. |
| `tests/capture_breaker_trial09_v12_cable_parent_comparison.gd` and `docs/visual_qa/breaker_trial09_v12_cable_{pelvis,torso,cyber_shoulder,cyber_elbow}_{neutral,idle,walk,punch}.png` | Godot 4 GDScript / PNG, 150×165 crops | Four candidate parent bones, four poses | OpenGL Compatibility renderer captures all 16; neutral variants differ by 8 filtered edge pixels (within test tolerance). Review-only; no parent selected. |
| `docs/visual_qa/breaker_trial09_v12_cable_parent_punch_review.png` | PNG, 1240×390 | Four-parent punch comparison from the current Godot captures | Review-only; variants are too similar to establish cable intent or select production attachment. |

All v12 files remain isolated from runtime scenes. No source art is removed or promoted.


| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_component_concept_candidate_14.png` and `.README.md` | PNG, 1024×1536; 940,153 transparent / 632,711 semi-transparent / 0 fully opaque | Built-in generated component study, references candidates 09 and 03 | Rejected fit study. Component pose/scale does not match the reference; alpha haze prevents clean cutout. Quarantined, not runtime. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_boundary_reading_candidate_15.png` and `.README.md` | PNG, 1024×1536, opaque flattened image | Built-in edit of local candidate 09 | Manual visual reading passes the approved shoulder-shell/biological-upper-arm/elbow-start-prosthesis rule. Still concept-only: no transparent background, independent layers, verified concealed anatomy, pivots, or animation seams. Quarantined, not runtime. |
| `tools/art/audit_breaker_arm_boundary_candidate_15.py` | Python / Pillow | Local source-vs-review audit | Passed decode, canvas-size, and expected opaque-background checks; reports differences and creates a review board. Does not test artistic correctness or rig readiness. |
| `docs/visual_qa/breaker_candidate09_vs_candidate15_arm_review.png` | PNG, 1120×1428 | Generated by the audit above | Side-by-side whole-character and arm-ROI visual review only. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_pose_matched_arm_assembly_candidate_16.png` | PNG, 1312×1199 RGBA; 953,406 transparent / 619,084 semi-transparent / 598 opaque | Generated using candidates 15/09 as references | Quarantined isolated arm anatomy donor. Manual visual review reads shell-over-biological-upper-arm/elbow-start prosthesis. Alpha>32 bounds `(22,22)-(1295,1173)` and alpha>127 bounds `(23,22)-(1294,1173)` do not touch the bottom row. Component separation, pivots, and full-body proportion fit are not validated. |
| `tools/art/inspect_breaker_candidate16_skin_mask.py` and `docs/visual_qa/breaker_candidate16_skin_mask_diagnostic.png` | Python / PNG, 1312×1199 | Local threshold diagnostic of candidate 16 | 119,790 warm-skin pixels selected; visual audit finds armor-reflection false positives. Segmentation rejected for component extraction. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_compact_vertical_arm_concept_candidate_17.png` | PNG, 1024×1536 RGBA; 1,129,536 transparent / 443,328 semi-transparent / 0 opaque | Generated using candidates 09/15 as references | Rejected provisional scale fit: overlays the reference too small, especially at the fist; alpha bounds touch the canvas bottom. Quarantined, not runtime. |
| `tools/art/fit_breaker_candidate17_to_reference.py` and `docs/visual_qa/breaker_candidate09_candidate17_fit_overlay.png` | Python / PNG, 1024×768 | Local 75%-opacity placement preview using painted content bounds (`alpha > 32`); aspect-preserved 146×351 px fit | Manual comparison only; candidate is too narrow for the reference arm. Placement is not authored or canonized. |

All candidate images are local drafts. No Google Drive binary upload or runtime reference is claimed.

## Evolution unlock implementation — 2026-10-24

No new visual assets were added or promoted. BREAKER uses the Tier I code-drawn placeholder rig after an evolution tier is recorded; this transaction does not implement tier stats, traits, or appearance changes. Concept sheets and quarantined atlas drafts remain references/explorations, not production-ready rig parts.

## Evolution HUD visual QA — 2026-10-24

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `docs/visual_qa/evolution_gate_1280x720_06.png` | PNG, 1280×720 | Actual display-capable Godot capture using a disposable in-memory wave-25 / 1-data eligibility fixture | HUD layout QA only; prototype placeholders, not production UI/art |
| `docs/visual_qa/evolution_gate_800x450_06.png` | PNG, 800×450 | Same fixture and capture session | HUD layout QA only; confirms narrow-view caption suppression and reduced panel scaling |

The helper does not read or alter the normal user save. These screenshots are also staged under the local Notion Visual QA and Google Drive `03 - Environments & UI` folders; no remote uploads were made.

Last inventoried: 2026-10-24 from the offline migration package. Dimensions and byte sizes are from the extracted local files. The offline Drive inventory records file IDs, but this session did not re-verify remote Drive contents.

## Recovered concept references

All four images are PNG, 1536 × 1024, and remain under `migration_package/drive_assets/concept_art/`. They are references only and are not imported into the game's runtime assets.

| Local file | Size (bytes) | Drive ID in handoff inventory | Observed contents | Readiness |
|---|---:|---|---|---|
| `01_world_roster_concept_sheet.png` | 3,323,258 | `1C9kAqnmyBE_GMdNBB2j1tK1_g-JPVBhX` | BREAKER identity, four armor stages, animation examples, modular part concepts, battle example | Concept sheet; filename does not match most visible content. Not cutout sprite parts. |
| `02_character_faction_design_sheet.png` | 2,446,590 | `1dQnQHU6MbAmr-Y798AS-J8xFGLUU19X7` | Base unit classes, faction looks, enemy archetypes | Concept sheet; not production character assets. |
| `03_breaker_evolution_reference.png` | 3,135,028 | `119ZEI1_FVZ5HiAjt9aHiIdxUnR0Z4Ll2` | Twelve recruit portraits, class-stage examples, gacha recruitment and battle UI panels | Concept sheet; filename/content mismatch. Gacha panel conflicts with the approved no-gacha design and is not to be implemented. |
| `04_breaker_production_board.png` | 2,907,242 | `1upT7jW1K5pLr1X0ItmGm5b9UXe2JvFy5` | BREAKER four-tier visual direction, identity anchors, modular part concepts, VFX and battle examples | Approved visual direction/reference board per the production spec; still a flattened concept board, not separate transparent parts or a working rig. |

Image contents were visually reviewed. Some labels inside the boards use different character-stage names than the approved global evolution tiers; see `DESIGN_DECISIONS.md`. The handoff `DRIVE_INVENTORY.json` describes the IDs as verified files, while the recovered `drive_assets/MANIFEST.md` says the local PNGs are not independently verified uploads. The file IDs are retained as reported handoff metadata; this local audit does not resolve the remote-upload discrepancy.

## Recovered text references

| File | Format | Handoff source | Status |
|---|---|---|---|
| `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md` | Markdown | Drive ID `1Vw-drEACq3hdDy_OfYt25dGgjVEslORu` | Approved visual direction and implementation-ready specification; not evidence that assets or a tested rig already exist. |
| `migration_package/drive_assets/README.md` | Markdown | Drive ID `1E_SFhXoBVjZy8bE5X0ogtaxCREQQ9uWc` | Rebuild/backup kit README; describes prior source recovery and no existing Godot project/rig. |
| `migration_package/drive_assets/MANIFEST.md` | Markdown | Drive ID `104dFfcUdjeO7H1CwJLE8jUJHCbyEdN9Y` | Recovered file list; says the local images are not independently verified uploads. |

The handoff's `docs/DRIVE_INVENTORY.json` lists these Drive IDs and says folders `03 Environments & UI`, `04 Audio & Music`, `05 Godot Project Backups`, and `07 Notion Exports` were empty at inspection. The same package reports no transparent sprite layers, rigged animation, Godot project, music, or environment source assets.

## Current local prototype visuals

## BREAKER modular parts trial 01 — 2026-10-24

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/modular_parts_trial_01/{head_neck,torso_vest,pelvis,left_upper_arm,left_forearm_hand,right_cyber_arm,right_fist,left_thigh,right_thigh,left_shin,right_shin,boot}.png` | 12 RGBA PNGs, each 1254×1254 | User-approved generated component previews copied into the project without altering source files | Quarantined preview set. Alpha preserved. `pivot_manifest.json` records per-file alpha bounds and provisional visual pivot estimates. Parts were generated independently and require separate estimated scales in the review scene. Not production-ready and not referenced by runtime. Most parts do not retain a strict 8 px fully transparent border because faint alpha pixels reach an image edge. |
| `assets/characters/breaker/tier_01_drafts/modular_parts_trial_01/README.md` and `pivot_manifest.json` | Markdown / JSON | Local audit of the component previews | Provenance, measured alpha bounds, provisional pivots, fit-test outcomes, and readiness limits. |
| `tests/breaker_parts_trial_01_preview.tscn`, `tests/breaker_parts_trial_01_preview.gd` | Godot scene / GDScript | Isolated local assembly harness | Loads draft PNGs directly from disk; no runtime links. Fits a review assembly to the 256 px foot-to-hair target and provides preview-only idle/walk/punch/hit transform smoke tests. 2× review found visible joint gaps and inconsistent component angles; neutral assembly gate failed. |
| `docs/visual_qa/breaker_modular_parts_trial_01_{neutral,idle,walk,punch,hit}.png` | PNG, 1280×720 each | Godot 4.7.2 OpenGL captures from the isolated harness | Visual review only. Static fit and transform smoke-test frames; not gameplay footage or production animation. |
| `docs/visual_qa/breaker_modular_parts_trial_01_neutral_zoom.png` | PNG, 1280×720 | Same isolated Godot harness at 2× part scale for clarity | Closer visual review; exposes joint gaps/component-angle mismatch. Not a production-scale asset. |

`pivot_manifest.json` records source alpha bounds at threshold `alpha > 32`; all pivot coordinates and part-scale values remain estimates. A full alpha scan found that 21.0–51.2% of all canvas pixels have alpha ≥250; this indicates mostly transparent canvases with highly opaque artwork, but does not verify joint seams. The preview fits the composition to 256 px using a global 0.86 factor plus per-part scales. The 2× review shows visible joint gaps and inconsistent component angles; neutral assembly acceptance is **FAILED**. The idle/walk/punch/hit transform tracks are harness smoke tests only. Production deformation validation remains blocked pending art correction.

## Runtime UI update — 2026-10-24

The manual System Reboot confirmation/control is generated from Godot UI nodes and styleboxes in `scripts/main.gd`; it introduces no image, audio, font, or other external runtime asset. It remains a prototype HUD element using the approved provisional Reboot profile.

## Progression horizon update — 2026-10-24

No new art or audio was added for the wave-125 progression test horizon. Waves 26–125 continue to display the same code-drawn Undercity placeholder battlefield and reuse the Undercity grunt definition; the HUD labels this span `Progression Test Fixture`. District-specific environments and encounter assets remain missing.

## Encounter reward event update — 2026-10-24

The structured `CombatDirector.wave_cleared` event and `scripts/progression/material_reward_service.gd` are code-only systems; they create no visual/audio asset. The profile contains user-approved-for-prototype trial payouts; no named boss assets or encounters have been added.

| Local file | Format/dimensions | Readiness |
|---|---|---|
| `scripts/characters/breaker_t1_placeholder_rig.gd` | Godot `Skeleton2D` / `Bone2D` hierarchy with code-generated polygon parts | Tier I-shaped visual stand-in aligned to specified anchors; temporary, not final art or an approved production rig. |
| `docs/BREAKER_RIG_CONTRACT.md` | Markdown rig/interface contract | Defines the simulation/presentation boundary, stable root and facing behavior, API, and FX markers. Prototype contract only; not evidence of production art or a complete reusable rig. |
| `scripts/presentation/placeholder_actor.gd` | GDScript-generated polygons | Generic temporary enemy stand-in. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_parts_atlas_draft_01.png` | Generated RGBA PNG, 1536 × 1024, 2,146,211 bytes | Original local art exploration based on the approved written BREAKER Tier I spec. A sample empty gutter is transparent. No crop/pivot/seam validation; `.gdignore`d and unused by runtime scenes. SHA-256: `A83870F0E61BAE0F3E0C792D10636055D1637CF3D29BDC68888C0B23CF476E91`. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_parts_atlas_draft_02.png` | Generated RGBA PNG, 1536 × 1024, 2,453,675 bytes | Original local exploration guided by the approved Tier I production board and written spec. Alpha samples pass; the sheet does not pass the rig-contract gate because part bounds, common scale, pivots, and joint seams are unvalidated. `.gdignore`d and unused by runtime scenes. SHA-256: `2855D96F093F8393BD44B154932A9811FF3A16074E48D182B9EF5AF9C3A8B529`. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_head_candidate_01.png` | Generated RGBA PNG, 1254 × 1254, 1,436,883 bytes | One head-and-neck cutout candidate generated locally from draft 02 for an isolated rig trial. Sampled transparency and opaque pixels pass. Proposed pivot `(571, 1156)` maps to the head-bone origin in a headless transform test at a 29-unit display height. Still draft-only: isolated 1280×720 viewport review confirms head-anchor placement and facing mirroring, but shows a style/scale mismatch against the code-drawn body; do not integrate. `.gdignore`d and not referenced by the main scene. QA capture: `docs/visual_qa/breaker_head_candidate_preview_1280x720.png`. SHA-256: `DED71DE12BCF4C5549B311CFD24458A272398135FF576E699EFB4E91118F8AB2`. |
| `data/squads/undercity_six_slot.json` | JSON configuration | Six active slots; five generic ally placeholders with tunable prototype combat values, internal movement speeds, melee/ranged styles, and staggered start/depth offsets. Placeholder roles are test fixtures, not canonical recruit data. |
| `data/characters/breaker_t1.json`, `data/enemies/undercity_grunt.json` | JSON configuration | Prototype combat definitions include melee style and data-driven contact distance; values are placeholders, not final balance. |
| `scripts/combat/combat_director.gd` | GDScript simulation | Uses configured engagement distances to make ranged entities hold stand-off positions and melee entities close to contact. Combat behavior only; no new art assets. |
| `scenes/main.tscn` and `scripts/environment/undercity_backdrop.gd` | Godot text scene / code-drawn procedural backdrop | Temporary layered-city, rain, and wet-street stand-in; not production environment art. |
| `scripts/environment/environment_director.gd` and `data/zones/undercity_prototype_zones.json` | GDScript and JSON | Approved modular-zone presentation framework with two palette-only test modules. The wave-13 boundary is provisional QA data; no authored environment art or canonical zone layout was added. |
| `tests/capture_zone_transition_qa.gd`, `docs/visual_qa/modular_zone_crossfade_1280x720*.png`, and `docs/visual_qa/modular_zone_positions_after_3s_1280x720*.png` | GDScript capture helper / 1280 × 720 PNGs | Actual main-scene wave-13 transition and post-transition movement captures. Latest post-movement capture verifies the backline ground-shadow and upper-walkway seam treatment. QA images only; they show code-drawn placeholder environments and actors, not production art. |
| `tests/capture_combat_presentation_qa.gd`, `docs/visual_qa/six_actor_movement_1280x720_03.png`, and `docs/visual_qa/breaker_hit_pose_1280x720_03.png` | GDScript QA helper / 1280 × 720 PNGs | Full squad movement and BREAKER hit reaction from the actual main scene; the hit is driven through a controlled CombatDirector damage step. Contact shadows are visible. QA captures of polygon placeholders, not production art. |
| `tests/capture_retreat_recovery_qa.gd`, `docs/visual_qa/carryover_hp_full_squad_defeat_1280x720_03.png`, and `docs/visual_qa/carryover_hp_holding_wave_recovery_1280x720_03.png` | GDScript QA helper / 1280 × 720 PNGs | Accelerated fixed-step simulation reaches natural full-squad defeat, captures automatic retreat to the highest-cleared holding wave, then verifies and captures full-health retry. No persistent save or balance definition is changed. QA captures of placeholder characters, not production art. |

## BREAKER Tier I art review — 2026-10-24

| Local file | Format / dimensions | Review | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_parts_atlas_draft_01.png` | RGBA PNG, 1536 × 1024 | Visually reviewed against `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md` | Exploration only. Individual crops, shared scale, pivots, seams, and assembled poses have not been validated. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_parts_atlas_draft_02.png` | RGBA PNG, 1536 × 1024 | Visually reviewed against the same spec | Exploration only. Its exposed torso does not match the spec's sleeveless dark vest direction; crops, scale, pivots, seams, and assembled poses remain unvalidated. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_head_candidate_01.png` and `docs/visual_qa/breaker_head_candidate_preview_1280x720.png` | RGBA PNG, 1254 × 1254; QA capture, 1280 × 720 | Head-and-neck cutout mounted on temporary placeholder rigs | Pivot transform and mirroring plumbing pass; the cutout visibly mismatches the placeholder body's style/scale. Do not promote or integrate. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_full_anatomy_trial_01.png` | RGBA PNG, 1024 × 1536, 2,005,919 bytes | Intermediate local image-generation edit based on Draft 01 | Quarantined, flattened anatomy study. Vest/knee anatomy still needs review; not rigged or runtime-ready. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_full_anatomy_trial_02.png` | RGBA PNG, 1024 × 1536, 2,048,236 bytes | Local image-generation full-body study based on Draft 01; same binary staged under `Google Drive/02 - Character Sprites/` locally | Closed-vest anatomy pass; hard knee armor still visible. Flattened single pose, not rigged or runtime-ready. SHA-256: `D69655C3E187E3F3848D76A4AABA92FA82AADD8CD907E3151B28031BB5DBF8F4`. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_full_anatomy_trial_03.png` | RGBA PNG, 1024 × 1536, 2,068,910 bytes | Local image-generation revision based on trial 02; same binary staged under `Google Drive/02 - Character Sprites/` locally | Flattened concept study only. Still has an oversized knee support and overlapping limbs; fails as a source for a faithful modular split. Do not treat as rig-ready. SHA-256: `FB3DC94047BC696B53A351A6AF6BB678FEE5BDDF262E46C1AB768059C1E065EE`. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_review_atlas_01.png` | RGBA PNG, 1536 × 1024, 2,335,554 bytes | Generated 6×3 reinterpretation based on full-body trial and earlier draft; staged locally in `Google Drive/02 - Character Sprites/` | FAILED source-faithfulness review. It contains substitute/reinterpreted anatomy and background/halo treatment; it is not a source-faithful split. Keep quarantined for audit only. SHA-256: `71397CE751A69F7221FE4ECD9E453A0E02BC2B22049C1920339920BD47711589`. |
| `assets/characters/breaker/tier_01_drafts/modular_review_01/` | 18 RGBA PNG fixed-cell crops, each 256×341/342, plus README | Deterministic row-major crops of the failed atlas; same set staged locally in `Google Drive/02 - Character Sprites/modular_review_01/` | FAILED/UNUSABLE as character parts. Alpha corner samples pass, but these are cells of the generated reinterpretation, not source anatomy; several bounds touch cell edges, with no source-faithful pivots, overlap seams, or neutral assembly. Do not rig or use at runtime. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_neutral_pose_preview_01.png` | RGBA PNG, 1024 × 1536, 1,949,896 bytes | Newer generated preview from separate Codex task; local copy staged in `Google Drive/02 - Character Sprites/` | Quarantined pose reference only. Exact alpha scan: 1,051,677 fully transparent, 521,187 partial-alpha, zero fully opaque pixels. Transparent corners pass, but semi-transparent atmospheric backdrop remains; not a clean cutout or modular source. SHA-256: `93B8B90D2A1BD5D5873948C2E06D720ED86243981FD972570211A847AB9ECCA2`. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_atlas_candidate_02.png` | RGBA PNG, 1536 × 1024, 2,345,439 bytes | Generated modular atlas from separate Codex task; local copy staged in `Google Drive/02 - Character Sprites/` | Quarantined review input. Not a literal source crop; do not accept substitutes as validated anatomy. No clean crops or runtime use. SHA-256: `D96A536C566D1E91E0BF85D367C094C944925AD211FBEE4BFE84D993AA5F1A23`. |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_modular_atlas_candidate_03.png` | RGBA PNG, 1536 × 1024, 2,168,650 bytes | Layout revision from separate Codex task; local copy staged in `Google Drive/02 - Character Sprites/` | FAILED crop gate. Exact cell scan found zero fully opaque pixels; semi-transparent haze reaches every cell. 0/18 cells has an 8 px clear margin; no crop was made. Not source-faithful, not valid parts, not runtime-ready. SHA-256: `6B8C99DF1D2220947E8ED9AA2973FFE49A3C67ABBE6FE285F7A5D59D12C4259D`. |

The user approved Draft 01 as the basis for a local visual trial. Trial 03 and both generations of modular review atlas/crops do not pass the source-faithful/clean-alpha part acceptance gates. The neutral-pose preview is not a clean cutout. No candidate was promoted to runtime; modular part separation, pivots, seams, neutral assembly, and animation remain unvalidated.

`tests/restart_save_probe.gd` is a GDScript test helper that purchases BREAKER's approved prototype evolution tiers with disposable state, writes the resulting versioned save in one Godot process, and validates restoration from a second process. It creates no runtime assets and deletes its test file and recovery sidecars after the read pass.

The probe passed on Godot 4.7.2: three sequential purchases persisted through separate process launches, ending at Apex Grade with all six prototype Evolution Data spent. This is save/progression evidence only; tier stat and artwork effects remain unimplemented.

The staged `docs/visual_qa/undercity_atmosphere_800x450_05.png` (800 × 450) was visually reviewed during the 2026-10-24 roadmap pass. The HUD and six placeholder actors are visible without clipping; the panel overlays part of the skyline, while actor lanes remain below it. This is a visual QA capture of the current code-drawn placeholder scene, not production artwork. A new screenshot could not be regenerated through Godot's headless dummy renderer in this pass.

The selected project folder was initially empty. The migration package was extracted separately into `migration_package/`; reference files were not duplicated into runtime assets. A `.gdignore` keeps its PNGs out of Godot's runtime import scan. The original ZIP remains in the workspace as the received handoff and is excluded from source control.

## Persistence implementation note

Save hardening changed `scripts/persistence/save_service.gd` and its regression coverage; it introduced no new runtime art, imported asset, or binary dependency. The version 1 JSON section layout remains `permanent`, `run`, and `settings`; `.bak` and `.bak.prev` are local recovery sidecars. See `IMPLEMENTATION_STATUS.md` for the verified validation and backup behavior.

## 2026-10-24 combat tuning update

The carryover-HP wave rule, full-health recovery at the holding wave after defeat, configurable Undercity grunt damage ramp, and approved modular-zone transition framework are code/data changes only; they introduce no production art assets. The `attack_per_wave` value and wave-13 zone switch are provisional prototype tuning/QA fixtures, not approved final rules. All six squad actors, enemy, and both backdrops remain temporary code-drawn visuals. Live QA includes the carryover-HP retreat/re-entry pair at `docs/visual_qa/carryover_hp_full_squad_defeat_1280x720_03.png` and `docs/visual_qa/carryover_hp_holding_wave_recovery_1280x720_03.png`, plus wave-13 crossfade/post-movement captures. These are QA captures of placeholder visuals, not production art. Tests verify per-slot health carryover, holding-wave recovery, and that zone presentation transitions do not alter squad actor positions.

## 2026-10-24 progression-system groundwork

| Local file | Format | Purpose / readiness |
|---|---|---|
| `scripts/progression/progression_rules.gd` | GDScript | Tested data-driven primitives for prototype-trial Reboot awards, lifetime/spendable balances, capped square-root damage bonus, permanent milestone gate, material consumption, and one-time first-clear claims. |
| `scripts/progression/reboot_service.gd` | GDScript | Tested pure Reboot transaction and explicit-path save-backed operation using SaveService atomic persistence. Not wired into the live game or UI. |
| `data/progression/progression_prototype_profile.json` | JSON | Prototype-only 25-wave Influence steps, `min(0.5% × sqrt(lifetime Influence), 25%)` outgoing-damage bonus, and deterministic/shared material policy. Loaded for the combat damage modifier; other progression rules remain provisional. Evolution milestone waves, costs, and material quantities remain unresolved. |
| `docs/PROGRESSION_RULES_PROPOSAL.md` | Markdown | Prototype-feasibility trial rules and outstanding evolution tuning decisions; not final balance or production data. |

## Remote source links

- [Google Drive asset root](https://drive.google.com/drive/folders/1EsuAqZMVJeGSLTWPULaDFitDcfwlq8c2)
- [Reconstruction archive](https://drive.google.com/file/d/1pIJpLWEnxu8esNkAX3_d46WuSt2Zw3iM/view)

Remote Drive tools were unavailable. Local file readiness is based on the contents of the offline reconstruction kit, not a fresh remote audit.

## Offline-earnings implementation assets and data

No new artwork or audio was added for this milestone. The configurable offline prototype rules live in `data/progression/progression_prototype_profile.json`; calculation and save integration are code in `scripts/progression/offline_earnings_service.gd`, `scripts/progression/economy.gd`, and `scripts/main.gd`. Regression fixtures are in `tests/test_runner.gd`. These are source/configuration files, not production art assets. The existing concept images remain reference-only and are not used by offline claims or runtime character scenes.

## Progression and BREAKER QA additions — 2026-10-24

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `data/progression/research_catalog.json` | JSON | Four approved permanent research branches with empty node lists | Framework fixture only; no costs, effects, prerequisites, or purchases are approved |
| `scripts/main.gd` | GDScript | Live roster Evolution panel with all twelve approved recruit IDs, configured milestone/material gates, and save-before-apply tier recording | Prototype UI; no tier stat/trait effects or higher-tier art |
| `scripts/progression/evolution_service.gd` | GDScript | Per-recruit tier progression, approved prototype gate checks, and immutable permanent-state transactions | Prototype core; preserves BREAKER save key; values are feasibility trials |
| `scripts/progression/research_service.gd` | GDScript | Save-before-apply purchase framework plus fail-closed research catalog structure/reference/cycle validation | Prototype core; no nodes or runtime gameplay effects approved |
| `tests/test_runner.gd` | GDScript | Save preservation/reset/recovery policy; deterministic recruit transactions, save/reload, Reboot persistence and two-size UI; wave autosave; evolution and research regressions | Automated prototype tests; disposable fixture saves only; Godot 4.7.2 isolated suite passed |
| `tests/offline_claim_process_probe.gd` | GDScript | Seed/claim/reload in three separate Godot processes | QA helper; disposable save only |

## Evolution panel responsive layout correction — code only — 2026-10-25 America/Chicago

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `scripts/main.gd` | GDScript | Two-line roster rows, larger action/progression text, viewport-sized panel, horizontal scrolling disabled | Godot regression and Compatibility-renderer visual review passed at 800×450 and 1280×720; prototype UI only |
| `tests/test_runner.gd` | GDScript | Checks full action-label fit, no horizontal overflow, minimum effective progress-text size and retained vertical scrolling at 800×450/1280×720; preserves all-roster purchase/save/gate checks | Godot 4.7.2 full suite passed through Test Lane |
| `docs/visual_qa/evolution_roster_ready_800x450_02.png` | PNG, 800×450 | Ready-state roster panel capture | Visual QA evidence; code-drawn prototype UI |
| `docs/visual_qa/evolution_roster_ready_scroll_bottom_800x450_02.png` | PNG, 800×450 | Scrolled roster bottom with final recruits and Close control | Visual QA evidence; code-drawn prototype UI |
| `docs/visual_qa/evolution_roster_locked_800x450_02.png` | PNG, 800×450 | Locked progression state | Visual QA evidence; code-drawn prototype UI |
| `docs/visual_qa/evolution_roster_ready_1280x720_02.png` | PNG, 1280×720 | Ready-state roster panel capture | Visual QA evidence; code-drawn prototype UI |
| `docs/visual_qa/evolution_roster_locked_1280x720_02.png` | PNG, 1280×720 | Locked progression state | Visual QA evidence; code-drawn prototype UI |

Test Lane's full Godot 4.7.2 regression, 120-frame headless launch, and Compatibility-renderer visual capture/review passed. No art, font, or other external runtime asset was added. The panel continues to use the existing approved roster, prototype milestone/material gates, save-before-apply transaction, and no-effects notice.

## Deterministic founding-recruit purchase slice — code/data, validated — 2026-10-26 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `data/characters/founding_recruits.json` | JSON | Live-Notion-backed twelve-recruit IDs, names, factions, roles, and rarities with source timestamp | Source data; abilities and runtime character definitions are not supplied by this catalog |
| `data/progression/recruitment_prototype_profile.json` | JSON | 600 starting credits, VECTOR/SPARK/RECOIL starter ownership, unique-purchase policy, and 300/600/1,200 rarity prices | Approved feasibility trial values; not final balance |
| `scripts/progression/recruitment_service.gd` | GDScript | Fail-closed validation, eligibility, duplicate prevention, and immutable permanent/run purchase transaction | Implemented; isolated Godot regression passed |
| `scripts/main.gd` | GDScript | RECRUITS panel and atomic SaveService purchase flow | Implemented; isolated Godot regression and 800×450/1280×720 visual checks passed; no squad deployment or combat integration |
| `tests/capture_recruitment_layout.gd` | GDScript | Captures recruitment panel at two window sizes in an isolated project | Test-only capture helper; screenshots are stored in the Codex QA workspace, not runtime assets |
| `tests/capture_offline_claim_qa.gd` | GDScript | Offline-claim message viewport captures | QA helper; no real save used |
| `docs/visual_qa/offline_claim_1280x720.png` | PNG, 1280×720 | HUD message after a disposable +108 test claim | QA capture; temporary code-drawn gameplay art |
| `docs/visual_qa/offline_claim_800x450.png` | PNG, 800×450 | HUD message at minimum reference viewport | QA capture; compact text fits without clipping |
| `tests/capture_breaker_profile_motion_qa.gd` | GDScript | Neutral/walk/punch/hit contact-sheet generator for quarantined profile parts | QA helper; estimated pivots and incomplete hidden anatomy |
| `docs/visual_qa/breaker_profile_joint_motion_1280x720_04.png` | PNG, 1280×720 | Four sampled poses from the 13-mask BREAKER part trial | Review-only; not runtime art, production pivot validation, or proof of complete joint coverage |
| `tests/capture_research_framework_qa.gd` | GDScript | Displays and captures the four-branch read-only Research UI at two sizes | QA helper; no Influence or research data is changed |
| `tests/test_breaker_profile_walk_gait.gd` | GDScript | Checks alternating leg lift, ankle compensation, arm counter-swing, loop closure, and root anchor | QA regression; isolated quarantined art only |
| `tests/capture_breaker_walk_cycle_qa.gd` | GDScript | Captures eight phases of the isolated BREAKER profile-part walk | QA helper; review sheet only, does not validate production pivots |
| `docs/visual_qa/breaker_profile_walk_cycle_1280x720_04.png` | PNG, 1280×720 | Eight-phase BREAKER profile walk cycle with stance contact checks | Review-only; 13 art layers remain quarantined; no production readiness claim |
| `docs/visual_qa/breaker_profile_joint_motion_1280x720_06.png` | PNG, 1280×720 | Updated neutral/walk/punch/hit samples after gait refinement | Review-only; estimated pivots and hidden anatomy remain unresolved |
| `docs/visual_qa/six_actor_movement_1280x720_04.png` | PNG, 1280×720 | Live six-actor scene capture with revised placeholder gait | QA capture; code-drawn placeholder art, not production BREAKER art |
| `docs/visual_qa/research_framework_1280x720_03.png` | PNG, 1280×720 | Dark in-game Network Research panel with four branches and pending-design labels | QA capture; no node values or purchase controls are present |
| `docs/visual_qa/research_framework_800x450_03.png` | PNG, 800×450 | Small-viewport research panel review with current spendable Influence | QA capture; text fits and panel remains centered |
| `docs/visual_qa/offline_claim_1280x720_02.png` | PNG, 1280×720 | Main HUD after one disposable offline claim | QA capture; no user save is used |
| `docs/visual_qa/offline_claim_800x450_02.png` | PNG, 800×450 | Main HUD after one disposable offline claim at minimum viewport | QA capture; text is denser but unclipped |

The motion contact sheet confirms the current trial rig can present sampled pivot rotations while retaining its ground anchor. Parts remain quarantined: hidden anatomy, deformation, and production pivot accuracy are unresolved. The walk refinement changes code-drawn placeholder motion and isolated review animation only; it adds no production art assets.

## Local sync staging

The local staging folders were reconciled on 2026-10-25 (America/Chicago). `Notion/Project Docs/` and `Google Drive/07 - Notion Exports/` were refreshed from current project documentation, tests, and the selected current review notes. `Notion/Visual QA/` remains a curated subset rather than a mirror of the 1,500+ source QA files; it now includes selected CIPHER 09B, CIPHER rifle, SPARK drone, SPECTER blade, IRONCLAD cable, and gameplay transition evidence. Recent source-aligned candidate files and review notes are staged under `Google Drive/02 - Character Sprites/`; candidates remain explicitly quarantined. `Google Drive/06 - Milestone Snapshots/` remains a curated set of gameplay viewport captures, refreshed where source image hashes differed.

These are local staging copies only. No remote Drive upload or Notion edit was made in this refresh; selected live Notion reads and earlier readbacks are recorded in `docs/MIGRATION_REPORT.md`. `Notion/Live Readbacks/` and the offline reconstruction folders were preserved as received. The latest source archive remains the historical snapshot #24 dated 2026-10-24; it is not a mirror of later working-tree changes. The original recovered references remain under `migration_package/drive_assets/`, and current QA originals remain under `docs/visual_qa/`.

## BREAKER modular parts trial 01 fit update — 2026-10-24

The twelve 1254×1254 RGBA component images remain quarantined under `assets/characters/breaker/tier_01_drafts/modular_parts_trial_01/`. Their source pixels are unchanged. The isolated preview harness now uses revised estimated pivots/offsets to overlap major joins. Latest neutral, walk, punch, and hit 2× captures show connected joins in the sampled stills under visual review; this is a provisional fit check, not proof of continuous deformation or production readiness. Residual angle and texture seams remain. The corrected preview transforms are not authored/approved rig data, and none of these images are referenced by the runtime scene. Updated captures are `docs/visual_qa/breaker_modular_parts_trial_01_{neutral,walk,punch,hit}_zoom.png`; `breaker_modular_parts_trial_01_full_body_detail.png` is a cropped review view of the neutral capture, not a new source asset.

The user then flagged the assembly's proportions. The isolated fit now uses a broader root, wider torso/pelvis/legs, a wider hip stance, a higher waist/hip line, lengthened lower legs, and a larger cyber arm/fist; see `docs/IMPLEMENTATION_STATUS.md`. `docs/visual_qa/breaker_tier1_proportion_study_01.png` is a separate 1024×1536 concept-only comparison image generated from Trial 03. It has an opaque dark backdrop despite the transparent-background request, is not sprite-ready, and is not used in runtime. The harness now performs alpha-contact checks at 12 representative body joins and checks both boot soles near the ground in neutral, walk, punch, and hit samples. All pass within the documented pixel tolerances. This is sampled contact validation, not continuous seam/deformation validation. Neither the new study nor the adjusted preview transforms are approved production assets; exact proportions remain pending visual review against a neutral character turnaround.

The user then reported Trial 01 still looks very different from the reference models. Record sampled joint contact as **PASS**, but reference fidelity as **FAILED**. `docs/visual_qa/breaker_reference_fidelity_comparison_01.png` documents the open human hand, claw-like cyber fingers, non-boxer arm pose, and different hip/leg silhouette. Do not treat Trial 01 or the generated proportion studies as replacement art. A coherent neutral side-view source must be established before another component set is produced.

## BREAKER approved profile rig trial — 2026-10-24

| Local file/group | Format / dimensions | Source / purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png` | PNG, 1024×1536 | User-approved visual target; source for the isolated 13-layer trial | Concept/reference only; backdrop retained |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/{pelvis,torso,head_neck,cyber_upper_arm,cyber_forearm,natural_upper_arm,natural_forearm,left_thigh,left_shin,left_boot,right_thigh,right_shin,right_boot}.png` | 13 RGBA PNGs, each 1024×1536 | Source-pixel masks with shared full-canvas coordinates | Exact neutral reconstruction; isolated review now targets 256 px visible height; provisional pivots; quarantined, not runtime-ready |
| `tests/test_breaker_art_gate.gd` | GDScript | Checks all 13 layers, alpha corners, 256 px visible scale, pivot bounds, facing, stable anchor, and five action channels | Isolated gate regression; passing checks do not certify production art |
| `tests/capture_breaker_production_gate_qa.gd` | GDScript | Captures 5 action samples and 6 full-size BREAKER figures at staggered gait phases | Review-only capture; uses quarantined art and estimated pivots |
| `docs/visual_qa/breaker_production_gate_actions_1280x720.png` | PNG, 1280×720 | Idle, walk, punch, hit, defeat at 256 px visible height | Review capture; action-transform smoke test, not all-frame seam validation |
| `docs/visual_qa/breaker_production_gate_six_unit_1280x720.png` | PNG, 1280×720 | Six BREAKER profiles at full visible scale with staggered walk phase | Readability review; not the runtime squad formation or six unique recruit art |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/pivot_manifest.json` | JSON | Provisional 14-point rig manifest, updated with current isolated Godot test scope | Pivot coordinates remain hand-estimated; production readiness explicitly false |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/{pivot_manifest.json,assembled_neutral.png,parts_sheet_preview.png,uncovered_mask.png,assembly_difference.png}` | JSON and PNG review artifacts | Estimated pivots and extraction/assembly QA | Trial evidence; visible silhouette renders ~238 px at 1/6 canvas fit; no hidden anatomy or deformation certification |
| `tests/breaker_profile_rig_trial_01_preview.tscn`, `tests/breaker_profile_rig_trial_01_preview.gd`, `tests/test_breaker_profile_rig_trial_01.gd` | Godot scene/scripts | Isolated rig preview and structural/animation smoke test | Godot 4.7.2 passes; user-reviewed neutral/walk/punch/hit samples are coherent; complete frame seam certification remains open |

**Current extraction audit — 2026-10-24:** An independent comparison against the source matte thresholded at alpha ≥245 confirmed all 440,938 visible silhouette pixels are covered; visible RGB matches exactly, visible alpha is binary, and no pixels extend outside the thresholded silhouette. This certifies neutral assembly only. Earlier mask-failure/uncovered-pixel notes below describe superseded exporter revisions. The current 13-layer trial remains quarantined, with provisional pivots, combined hand/boot/head-neck parts, no hidden-joint reconstruction, and no mesh deformation.

The dedicated 210-frame walk regression was rerun with Godot 4.7.2 at fixed 60 FPS and passed (exit 0): five cycles, alternating hip rotation, 154 px horizontal travel, and no ground-anchor vertical drift. The sandbox log-file warning is non-fatal. The separate display-rendered walk capture/contact sheet remains visual evidence only.

The trial parts and captures are excluded from runtime scenes. The smoke test does not upgrade the source PNGs to production animation assets.

## BREAKER walking simulation — 2026-10-24

| Local file/group | Format / dimensions | Source / purpose | Readiness |
|---|---|---|---|
| `tests/breaker_profile_walk_simulation.tscn` and `.gd` | Godot scene/script, 1280×720 review stage | Loops the profile rig's 0.65 s walk clip and translates the visual anchor through a 390–890 px review lane | Isolated preview; 44 px/s is a test fixture only |
| `tests/test_breaker_profile_walk_simulation.gd` | GDScript test | 210-frame test for five walk cycles, alternating hip pivots, 154 px travel, fixed anchor height, and all 13 layers loaded | Godot 4.7.2 headless test passed; no seam/deformation certification |

No new source artwork was generated. The walking scene loads only the quarantined trial layers and is not referenced by the main game scene.

## BREAKER profile rig trial 02 — 2026-10-24

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_cutout_candidate_02.png` | RGBA PNG, 1024×1536, 1,774,421 bytes | Background-removal image-generation output derived from the user-approved candidate 01 | Quarantined flattened cutout candidate. Alpha scan confirms more than 1.1M fully transparent pixels; alpha>=245 bounds `(239,46)–(791,1472)`. SHA-256 `8EF0C5975594B4AE119917D0A8836AC30FE68D35B30A40DA8CA4298AC8803897`. Not rig-ready or runtime art. |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_02/{13 layer PNGs, pivot_manifest.json, README.md}` | 13 RGBA PNG layers at 1024×1536, JSON/Markdown records | Existing exporter run with explicit candidate 02 source and trial 02 output | Quarantined extraction trial. Export verified zero uncovered high-alpha silhouette pixels and exact neutral composite. Masks and pivots are estimates; hidden anatomy is not present. Not production-ready. |
| `tests/breaker_profile_rig_trial_02_preview.tscn`, related GDScript and two targeted tests | Godot scene/scripts | Isolated trial 02 validation harnesses | Godot 4.7.2 passed alpha-matte, static rig structure, 256 px review scale, estimated-pivot presence, facing/anchor, and five transform-channel checks. This does not validate anatomy, joint seam continuity, deformation, or animation quality. |
| `docs/visual_qa/breaker_profile_trial_02_actions_1280x720.png`, `docs/visual_qa/breaker_profile_trial_02_six_unit_1280x720.png` | PNG, 1280×720 | Godot 4.7.2 display-rendered trial 02 capture | Review-only idle/walk/punch/hit/defeat samples and six full-size duplicate profiles. Not gameplay or production-animation approval. |

Candidate 02 visually preserves the approved profile direction and has real transparent canvas pixels despite appearing on a dark composite in the image viewer. It is not pixel-identical to candidate 01. Static extraction reconstructs its alpha-thresholded silhouette exactly, but only visible anatomy was segmented. The earlier statement that the separate background-removal attempt retained an opaque backdrop is superseded by the alpha scan and Godot image test. **Production-art gate remains NOT PASSED**; all trial 02 content is outside runtime.

| Local file | Format / dimensions | Source / purpose | Readiness |
|---|---|---|---|
| `docs/visual_qa/breaker_profile_walk_trial_01_contact_sheet.png` | PNG, 1400×1344 | 20 sampled frames from Godot's 60 FPS display-rendered walk capture, cropped around BREAKER | Visual QA only; shows sampled seam contact and remaining foot glide |
| `docs/visual_qa/breaker_profile_walk_trial_01.gif` | GIF, 105 frames, 30 FPS review playback, 280×310 | Downsampled from the 210-frame Godot Movie Maker capture | Preview only; not runtime art or a production animation export |

The temporary full PNG frame sequence and silent WAV created by Movie Maker were removed after the contact sheet/GIF were verified; the Godot captures are preserved at the two paths above.

Earlier user review used a 256 px full-canvas fit, yielding about 238 px visible height. The latest isolated art-gate harness corrects this to the specified 256 px visible-height target (`scale=256/1427`) and includes a full-size six-character readability capture. The hands remain part of forearm sprites, the head and neck are fused, and feet remain part of boot sprites; no hidden-joint fill or mesh deformation is included. Keep the export quarantined.

The first connected-anatomy redraw candidate is `assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png` (PNG, 1024×1536, 2,391,769 bytes; local generated concept). It is one complete figure with the established outfit, but it changes the boxer stance: the natural fist and cyber fist both hang low, the legs are straighter, and the torso/hip silhouette is narrower. Pixel sampling found no fully transparent pixels; the visible dark backdrop remains. Mark **NOT ACCEPTED FOR PART EXTRACTION**. Keep it in `tier_01_drafts/`; it is not runtime art or an animation-ready asset. Side-by-side: `docs/visual_qa/breaker_profile_rebuild_candidate_01_comparison.png`.

**Approval update — 2026-10-24:** The user approved `BREAKER_T1_profile_rebuild_candidate_01.png` as the current BREAKER Tier I visual target. This supersedes the preceding “not accepted” visual judgment. The source remains concept-only with a visible backdrop and no extracted parts or rig validation; do not describe it as production-ready or runtime-integrated.

**Mask-pass status — 2026-10-24:** `profile_rig_trial_01/` contains a failed 13-layer experiment derived from the user-approved profile candidate. Its assembled image has background polygons and clipping artifacts; keep the folder quarantined and do not use its PNGs at runtime. The source profile remains the approved visual target. Production part readiness is still **NOT READY**.

Profile rig trial 01 was refined to clip part polygons to the approved candidate's alpha-derived silhouette. Its 13 full-canvas PNGs load at 1024×1536, but the coverage check leaves 16,148 silhouette pixels uncovered and exact neutral reconstruction fails. The assembly and mask evidence are in `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/`. This is still a quarantined experiment, not transparent production parts or runtime art; pivots and animation remain untested.

**Neutral part-assembly update — 2026-10-24:** The approved profile source now has a 13-layer mask trial under `profile_rig_trial_01/`. The exporter validates shared dimensions and complete static coverage; the neutral composite exactly matches the source silhouette and color pixels. This is **not yet an animation-ready rig**: joints have only estimated overlap margins, occluded anatomy is missing, pivots are unvalidated, and no Godot motion test has been run. Runtime remains unchanged.

## BREAKER Trial 03 hidden-anatomy audit — 2026-10-24

| Local file | Format / purpose | Result / readiness |
|---|---|---|
| `tools/art/audit_breaker_trial_03_hidden_anatomy.py` | Python provenance audit over all 13 exported layers | Run result: hidden anatomy NOT VERIFIED; 664,937 opaque layer pixels checked, 0 RGB pixels independently differ from flattened source at the same coordinate |
| `docs/BREAKER_HIDDEN_ANATOMY_AUDIT.md` | Reproducible audit report and passing criteria | Production-art gate fails until genuine under-paint, authored pivots, and full-seam timeline review exist |

Trial-03 mask overlap (173,588 multi-covered pixels, 40.62% of source silhouette) is duplicate flattened-source color, not proof of hidden anatomical fills. Existing profile fidelity PASS applies only to visible resemblance; it does not imply rig or hidden-anatomy correctness.
The workspace contains no layered authoring source (`.psd`, `.kra`, `.ora`, `.aseprite`, `.ase`, `.xcf`) from which occluded anatomy can be verified.

## BREAKER inferred under-paint trial 04 — 2026-10-24

| Local file/group | Format / dimensions | Source / purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_04_inferred_underpaint/` | 13 visible RGBA layers + 13 inferred underpaint RGBA layers, shared 1024×1536 canvas, JSON manifest and README | Trial-03 visible masks plus joint-radius pixel extrapolation; 42 px patch radius, 26 px source sample offset | Static composite exact; isolated Godot/contact tests pass; stress pose artifacts remain. Inferred, NOT verified anatomy; quarantined and not runtime-ready |
| `tools/art/create_breaker_profile_trial_04_underpaint.py` | Python/Pillow asset-generation tool | Creates a new sibling trial only; refuses to overwrite an existing trial folder | Reproducible draft tooling; inferred color extrapolation, not authored/canonical art |
| `tools/art/audit_breaker_profile_trial_04_underpaint.py` | Python/Pillow static audit | Checks underpaint exists and neutral composition exactly preserves candidate 03 | PASS for file integrity/static fidelity only; explicitly does not verify semantic anatomy |
| `tests/breaker_profile_rig_trial_04_preview.tscn` and `tests/test_breaker_profile_rig_trial_04_underpaint.gd` | Godot scene/test | Isolated review rig with underlays following each visible part's bone | Godot 4.7.2 PASS within structural/transform scope only |
| `docs/visual_qa/breaker_profile_trial_04_joint_stress_1280x720_02.png` | PNG, 1280×720 | Exaggerated arm/leg/torso pivot stress poses at 256 px character height | Review-only; visible residual breakup confirms further art/pivot work needed |
| `docs/visual_qa/breaker_profile_trial_04_inferred_underpaint_actions_1280x720_02.png` | PNG, 1280×720 | Isolated idle/walk/punch/hit/defeat channels | Review-only; not a production animation gate |

No candidate or trial-04 file is referenced by runtime. Hidden anatomy is **INFERRED / NOT VERIFIED**; do not treat the successful static/contact tests as a production-art pass.

**Intended animation range update — 2026-10-24:** The trial-04 0.65 s gait regression passes; the full cycle capture shows connected joints at the 256 px target height. Strengthened 12-joint neighborhood test passes 2,472 samples across 206 fixed-60-Hz poses, with at least 15 adjacent opaque contact pixels required (observed minimum 35). This confirms sampled joint neighborhoods for current authored clips only. The 5-pose extreme stress sheet is outside those clips and remains diagnostic. Hidden art is still inferred, not artist/canon verified; no runtime use.

| Local file | Format / purpose | Readiness |
|---|---|---|
| `tests/test_breaker_profile_trial_04_walk_gait.gd` | Godot gait regression for authored 0.65 s walk clip | PASS: alternating legs, ankle compensation, arm counter-swing, head stabilization, loop closure, ground contact, stable anchor |
| `tests/capture_breaker_trial_04_walk_cycle_qa.gd` and `docs/visual_qa/breaker_profile_trial_04_walk_cycle_1280x720.png` | Eight-phase 0–88% walk review at full target height | Connected sampled pose presentation; review evidence, not art-source verification |

## BREAKER canon/art audit additions — 2026-10-24

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_01.png` | PNG RGBA, 1024×1536; alpha 0–254; 1478 px figure bound | Separate Tier I boxer-guard art exploration derived from approved profile appearance reference | Quarantined draft only; visual anchors reviewed; pose changes silhouette; not user-approved, not layered, not runtime, and not evidence of hidden anatomy |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_01.json` | JSON | Provenance, alpha/bounds, visual anchors, and approval status | Draft metadata; records observed scope/drift; does not canonize the generated candidate |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_01_README.md` | Markdown | Review criteria and acceptance boundary | Explicitly states draft-only status and anatomy limits |
| `tools/art/audit_breaker_guarded_pose_candidate.py` | Python / Pillow | Reproducible RGBA, transparency, canvas-bound, and side-by-side sheet checks | Structural test only; manual visual review and anatomy certification remain separate |
| `docs/visual_qa/BREAKER_T1_guarded_pose_canon_review_01.png` | PNG, 1120×860 | Side-by-side approved profile and guarded-pose draft comparison | Visual QA, not production artwork |
| `docs/visual_qa/BREAKER_T1_guarded_pose_256px_review_01.png` | PNG, 1080×370 | Approved reference and guarded draft at the Tier I spec's 256 px visible height on a shared ground line | Scale/groundedness visual QA; single-frame flattened draft only |

## BREAKER candidate 05 / guarded rig trial 05 v4 — 2026-10-24

**Visual review: PASS as a Tier I draft; final art approval: PENDING.** The new guarded-pose candidate restores both forearm wraps, preserves the approved profile’s face/scars/undercut, neck regulator, sleeveless dark vest, enlarged crimson-lit right cyber arm and cross-body fist, human left arm, dark trousers, and boots. Side-by-side review at the production specification’s 256 px visible height keeps these anchors legible. The lower-body edit improved the foot baseline; the screen-half alpha bounds differ by about 32 source px (about 5.6 px at review scale), and both heels/toes read grounded against the shared QA floor. Review files: `docs/visual_qa/BREAKER_T1_guarded_pose_canon_review_05.png` and `docs/visual_qa/BREAKER_T1_guarded_pose_256px_review_05.png`. This is generated review art and is not user-approved final art or runtime content.

**Static rig feasibility: PASS.** Candidate 05 exports to isolated `profile_rig_trial_05_guarded_pose_v4/`. The reproducible audit `python tools/art/audit_breaker_guarded_trial05_v4.py` passes 13-layer neutral reconstruction against the source alpha>=245 silhouette, with 0 uncovered pixels; 89,272 inferred underpaint pixels were added, 89,218 of which differ from the source RGB at the same coordinates. The underpaint uses local color-axis extrapolation. This shows filled texture, not artist-authored or semantically verified anatomy.

**Godot checks: PASS within stated scopes.** Godot 4.7.2 passed the isolated 13-layer rig structure and 256 px fit, 2,472 selected joint-neighborhood samples across 206 poses at 60 Hz (minimum/maximum adjacent contact pixels 136/315), and the 0.65 s walk-gait regression (alternating knee flexion, ankle compensation, arm counter-swing, loop closure, stable root, and sampled sole contact). The full project test runner and main scene at 120 headless frames also passed after the candidate update. Godot prints a non-fatal sandbox warning because `user://logs/godot.log` cannot be written.

**Semantic hidden anatomy: NOT VERIFIED; production-art gate: NOT PASSED.** The source image is flattened. The trial’s hand-estimated pivots and underpaint cannot establish concealed anatomy, every-frame seam continuity, or deformation quality. `trial_05 v4` stays quarantined under `tier_01_drafts/` with no runtime links. A headless Godot Movie Maker capture was attempted and crashed in the dummy renderer on a null texture; no Godot walk screenshot/movie is claimed. Static visual evidence is available; a rendered clip capture remains a follow-up.

## BREAKER candidate 05 / guarded rig trial 05 v8 — 2026-10-24

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v8/` | 13 visible RGBA PNG layers + 13 inferred underpaint RGBA PNG layers, each 1024×1536; JSON pivot manifest | Single-owner mask feasibility rig from flattened guarded-pose candidate 05 | Quarantined draft; exact static reconstruction and selected Godot contact/walk tests pass; inferred anatomy is **NOT VERIFIED**, not production art, not runtime |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v8/README.md` | Markdown | Export method, static audit, and readiness limits | Documents inferred underpaint and non-runtime status |
| `tools/art/audit_breaker_guarded_trial05_v8.py` | Python / Pillow | Rebuild and exclusive ownership audit for v8 | Reproducible static test; cannot certify anatomy |
| `tests/test_breaker_profile_trial_05_v10_defeat_fade.gd` | GDScript | Isolated fade timing and anchor regression | Passes clip key/anchor checks; does not approve defeat art |
| `docs/visual_qa/BREAKER_T1_trial05_v8_walk_contact_sheet.png` | PNG | Display-rendered conservative walk sample | Preview only; no major detachment at sampled poses; not all-frame anatomy proof |
| `docs/visual_qa/BREAKER_T1_trial05_defeat_options.png` | PNG | Compare broken-joint collapse, restrained slump, and slump/fade endpoints | Review evidence; no option approved as final |

Underpaint values: 297,312 inferred pixels, 296,989 pixels with changed RGB versus the flattened source at the same coordinates. This is local color extrapolation. Hands remain joined to forearms and feet to boots. The v8 conservative walk looks coherent in the retained review sheet, while the stronger collapse visibly tears and fails review. See `docs/BREAKER_HIDDEN_ANATOMY_AUDIT.md`; hidden anatomy remains **NOT VERIFIED** and the production art gate remains **NOT PASSED**.
## BREAKER Tier I canon review candidate 07 — 2026-10-24

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.png | PNG RGBA, 1024×1536, true transparent corners | Tier I static review art with human shoulder/upper arm and right cyber forearm/fist | Quarantined draft; static structure/scale/ground tests pass; no runtime or rig integration |
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.json | JSON sidecar | Prompt provenance, canonical checklist, status | Records written-spec fit and conflict with approved profile's arm silhouette |
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07_README.md | Markdown | Candidate scope and limitations | Static image only; hidden/deformed anatomy unverified |
| tools/art/audit_breaker_t1_canon_candidate_07.py | Python / Pillow | Alpha, bounds, visible height, and boot baseline checks | PASS; cannot certify art meaning or hidden anatomy |
| tools/art/build_breaker_t1_canon_candidate_07_review.py | Python / Pillow | Same-scale comparison of approved profile, candidate 05, and candidate 07 | Review visualization only |
| docs/visual_qa/BREAKER_T1_canon_candidate_07_comparison.png | PNG | Three-up comparison at 256 px visible height on a shared floor line | Shows cyberware extent conflict; owner review required |

Historical note from 2026-10-24: the written Tier I spec and approved profile image appeared to differ on right-arm cyberware extent. The user resolved the visible boundary on 2026-10-25: external shoulder shell over biological upper arm; mechanical prosthesis begins at the elbow. Candidate 07/05 comparisons remain quarantined as historical feasibility work; hidden anatomy and production art are still unverified.

## BREAKER candidate 09 canon arm ownership v2 — 2026-10-25 UTC

| Local file | Format / dimensions | Source / purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v2/` | 13 visible PNG layers + 13 underpaint PNGs, shared 1024×1536 canvas; JSON manifest and README | Quarantined rig feasibility trial extracted from candidate 09; visible upper-arm skin pixels reassigned from forearm ownership | Canon boundary tested in one visible pose; NOT production art/runtime; hidden anatomy inferred; pivots estimated |
| `tools/art/export_breaker_trial09_canon_v2.py` | Python/Pillow | Reproducibly exports v2 arm-ownership trial | PASS for exact neutral composite and single visible owner; does not validate art anatomy |
| `tools/art/audit_breaker_guarded_trial09_canon_v2.py` | Python/Pillow audit | Audits layer coverage, reconstruction, and arm ROI ownership | PASS: 5,796 warm-skin-classified ROI pixels on upper arm, 0 on mechanical forearm |
| `tests/breaker_profile_rig_trial_09_canon_v2_preview.tscn` and `.gd` | Godot 4.7.2 review harness | 256 px visible character, pose channels and review display | Test-only; no runtime reference |
| `docs/visual_qa/BREAKER_T1_candidate09_arm_canon_v2.png` | PNG, 1280×720 | Arm ownership/pose QA capture | Review evidence, not asset |
| `docs/visual_qa/breaker_trial09_canon_v2_four_actions_1280x720.png` | PNG, 1280×720 | Idle/walk/punch/hit comparison at 256 px visible scale | Review only; poses remain visually subtle at this size |
| `docs/visual_qa/breaker_trial09_canon_v2_four_actions_1280x720_02.png` | PNG, 1280×720 | Revised idle/walk/punch/hit capture after review-only motion tuning | Punch/hit read more clearly; walk remains subtle; not runtime art |
| `docs/visual_qa/breaker_trial09_canon_v2_six_unit_1280x720_05.png` | PNG, 1280×720 | Six-profile readability check | Review only; not production UI/art |
| `docs/visual_qa/breaker_trial09_canon_v2_six_unit_1280x720_06.png` | PNG, 1280×720 | Latest six-profile readability capture | Review only; not production UI/art |
| `docs/visual_qa/breaker_trial09_canon_v2_defeat_1280x720.png` | PNG, 1280×720 | Full-size defeat/fade review | Review harness capture, not a final authored animation |

The user-approved boundary is an external shoulder shell over biological upper-arm anatomy, with the mechanical right prosthesis beginning at the elbow. Python export/audit and Godot structure/ROI checks pass within scope. Review-only motion tuning makes the punch and hit more distinct, while the walk remains restrained. The static source has no separately recoverable shell or hidden anatomy. All files remain quarantined; the production-art gate is **NOT PASSED**. Earlier candidate 07 entries that call the arm-boundary conflict unresolved predate the user's choice and are historical.

## BREAKER Tier I arm-component sheet candidate 11 — 2026-10-25 UTC

| Local file | Format / dimensions | Source / purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_component_sheet_candidate_11.png` | PNG RGBA, 1024×1536 | Built-in image generation using approved profile candidate 01 and arm study candidate 09; four arm-component concept views | Quarantined concept; visually communicates approved shell/upper-arm/elbow boundary; too exaggerated in bicep; no pivots/alignment; haze/fringe remains; not runtime |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_component_sheet_candidate_11.json` | JSON provenance/audit sidecar | Source references, SHA256, alpha counts, limitations | Metadata only |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_component_sheet_candidate_11_README.md` | Markdown | Manual canon/art/readiness review | Documents that production-art gate is NOT PASSED |
| `tools/art/audit_breaker_arm_component_sheet_candidate_11.py` | Python/Pillow | Static alpha/canvas audit | Executes and returns expected readiness-gate exit 2 for residual semi-transparent haze |
| `tests/test_breaker_arm_component_sheet_candidate_11.gd` | Godot 4.7.2 | Direct image decode, canvas and transparent-corner check | PASS for image loading only; does not validate anatomy or readiness |

The manual visible-canon review passes the external shell / biological upper arm / elbow-start prosthesis rule. Artistic match is partial because of exaggerated bicep proportions; technical art readiness fails due to semi-transparent haze, one-sheet layout, unverified view scale/pivots/attachment edges, and absent assembly/motion test. No runtime references or external binary uploads were made.
## BREAKER Tier I canon review candidate 07 — 2026-10-24

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.png | PNG RGBA, 1024×1536, true transparent corners | Tier I static review art with human shoulder/upper arm and right cyber forearm/fist | Quarantined draft; static structure/scale/ground tests pass; no runtime or rig integration |
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.json | JSON sidecar | Prompt provenance, canonical checklist, status | Records written-spec fit and conflict with approved profile's arm silhouette |
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07_README.md | Markdown | Candidate scope and limitations | Static image only; hidden/deformed anatomy unverified |
| tools/art/audit_breaker_t1_canon_candidate_07.py | Python / Pillow | Alpha, bounds, visible height, and boot baseline checks | PASS; cannot certify art meaning or hidden anatomy |
| tools/art/build_breaker_t1_canon_candidate_07_review.py | Python / Pillow | Same-scale comparison of approved profile, candidate 05, and candidate 07 | Review visualization only |
| docs/visual_qa/BREAKER_T1_canon_candidate_07_comparison.png | PNG | Three-up comparison at 256 px visible height on a shared floor line | Shows cyberware extent conflict; owner review required |

Historical note from 2026-10-24: candidate 07 followed the written forearm-only reading while candidate 05 preserved the original profile silhouette. The user resolved the visible boundary on 2026-10-25: external shoulder shell over biological upper arm; mechanical prosthesis begins at the elbow. No art is promoted because hidden anatomy, authored pivots, and production deformation remain unverified.

Godot 4.7.2 test: tests/test_breaker_t1_canon_candidate_07.gd passes direct image decode, alpha-corner, canvas, target-height, and boot-baseline checks. It intentionally bypasses Godot's import scan because tier_01_drafts is ignored; no runtime image reference was added.

## BREAKER candidate 07 canon-review rig trial — 2026-10-24

| Asset / evidence | Purpose | Status |
|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_07_canon_v1/` | 13 visible single-owner part PNGs, 13 inferred underpaint PNGs, pivot manifest and neutral assembly from candidate 07 | Quarantined feasibility draft; no runtime reference; hidden anatomy NOT VERIFIED |
| `tools/art/export_breaker_trial_07_canon_single_owner.py` and `tools/art/audit_breaker_trial_07_canon_v1.py` | Isolated export wrapper and static source-reconstruction audit | Audit PASS for coverage/exact neutral composite only; color underpaint is inferred, not anatomy |
| `tests/breaker_profile_rig_trial_07_candidate07_canon_preview.gd` and paired scene | Godot 4.7.2 Skeleton2D review-only rig at 256 px visible height | Structure and action-channel test PASS; provisional pivots |
| `tests/test_breaker_profile_rig_trial_07_candidate07_canon_contacts.gd` | Sampled joint contacts across idle/walk/punch/hit/defeat at fixed 60 Hz | PASS, 2,472 samples / 206 poses; local neighborhoods only |
| `tests/test_breaker_profile_trial_07_candidate07_canon_walk.gd` | Walk gait, anchor, loop and sampled sole checks | PASS; review harness only |
| `docs/visual_qa/BREAKER_T1_candidate_07_canon_walk_cycle.png` | Display-rendered eight-phase walk review at 1280×720 | Manual visual: connected-looking at sampled phases; not an all-frame/anatomy certification |
| `tests/capture_breaker_trial_07_candidate07_canon_actions.gd` and `docs/visual_qa/BREAKER_T1_candidate_07_canon_actions.png` | Godot 4.7.2 display-rendered idle/walk/punch/hit/defeat review at 1280×720 | Capture and transform/anchor checks PASS; manual sampled-pose review only; defeat is a fall preview |

The candidate 07 five-action review note is published/read back on the live Notion Asset Library and Roadmap; the screenshot and layer binaries remain local only. The actual visual review was rendered with the Godot 4.7.2 OpenGL compatibility renderer. The headless attempt could not capture a viewport texture, so it is recorded as a failed capture attempt rather than a pass. Current live Notion BREAKER text specifies a human shoulder/upper arm with right cyber forearm/fist; the still-open visual reference discrepancy and its source evidence are in `docs/OPEN_QUESTIONS.md`.

## BREAKER Tier I neutral anatomy review candidate 08 — 2026-10-25

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_neutral_anatomy_review_candidate_08.png` | PNG RGBA, 1024×1536 | Neutral single-pose anatomy review draft | Quarantined; low-opacity alpha fringe; not canon, runtime, or production art |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_neutral_anatomy_review_candidate_08.json` | JSON | Provenance, scope, hash, and limitations | Explicitly records arm-scope conflict and unverified hidden anatomy |
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_neutral_anatomy_review_candidate_08_README.md` | Markdown | Review and test scope | Documents static-only limits |
| `tools/art/audit_breaker_t1_neutral_candidate_08.py` and `tests/test_breaker_t1_neutral_candidate_08.gd` | Python / GDScript | Static image decode, bounds, scale, ground checks | PASS within stated image-only scope |
| `docs/visual_qa/BREAKER_T1_candidate_08_neutral_anatomy_comparison.png` | PNG | Same-scale comparison of approved profile, candidate 07 and candidate 08 | Review aid; no canon choice implied |

Candidate 08 is a flattened generated review illustration, not a recovered source or rig-ready layered asset. Its forearm-only interpretation is provisional and does not resolve the visible shoulder/upper-arm discrepancy with the approved profile. Hidden anatomy, pivots, animation deformation, and continuous seams remain NOT VERIFIED; the production-art gate remains NOT PASSED.

## BREAKER Tier I arm-extent decision board — 2026-10-25

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `docs/visual_qa/BREAKER_T1_arm_extent_decision_board.png` | PNG RGB, 1800×1370 | Side-by-side candidate 07 vs candidate 05 at matched 256 px visible height, with enlarged shoulder/arm crops | Local review aid; clarifies conflict only; not a canon decision or production asset |
| `tools/art/build_breaker_t1_arm_extent_decision_board.py` | Python / Pillow | Reproducibly assembles the two quarantined drafts into the decision board | Rebuild verified deterministic; no source artwork changed |

Manual visual check: both drafts preserve the same guarded pose and core face/vest/fist identity. Their shoulder-to-forearm machinery extent is visibly distinct and labeled. Hidden anatomy and animation remain outside this comparison's scope.

## A/B candidate verification refresh — 2026-10-25 UTC

The decision board `docs/visual_qa/BREAKER_T1_arm_extent_decision_board.png` is a local RGB review aid, 1800×1370, built by `tools/art/build_breaker_t1_arm_extent_decision_board.py`. It contains no newly generated or modified character pixels. Rebuild is deterministic (SHA256 `651C150F3895FE3AE577329146ECFA92EF1D3DE40FB0C9F6C049A29DC33C5491`).

Current candidate 05 v8 and candidate 07 selected-pose Godot checks pass, but they sample contact and gait on inferred underpaint with estimated pivots. The older generic candidate 05 contact regression was retargeted from v4 to v8 and passes; the v4 scene itself had 412 seam-sample failures and is not endorsed by the current test. Candidate 03 hidden anatomy audit still returns the expected NOT VERIFIED result because no exported-layer RGB differs from the flattened source.

## BREAKER Tier I arm-extent reconciliation study candidate 09 — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png` | PNG RGBA, 1024×1536; SHA256 `a6319eec185b06ae2ef96f652855698687ecede1901095bf271405103a986506` | Quarantined study preserving the profile's shoulder-shell silhouette over a human upper arm, with mechanical right forearm/fist | Review concept only; not canon, production art, or runtime. Hidden anatomy and animation are **NOT VERIFIED** |
| Paired `.json` and `_README.md` files | JSON / Markdown | Provenance, status, validation scope, and limitations | Local metadata only |
| `tools/art/audit_breaker_t1_arm_extent_reconciliation_candidate_09.py` and `tests/test_breaker_t1_arm_extent_reconciliation_candidate_09.gd` | Python / GDScript | Static image and Godot decode/scale/ground checks | PASS within stated image-only scope |

Candidate 09 has fully transparent canvas corners, but its alpha audit reports 554,254 semi-transparent pixels and no fully opaque pixels; a clean opaque cutout is not verified. It contains no authored layers or pivots. It is a reconciliation study, not a canon choice; no binary upload is claimed.

### Verification rerun — 2026-10-25 UTC

The user has since approved the visible arm boundary: external shoulder shell over biological upper arm; mechanical prosthesis begins at the elbow. Candidate 09 v2 passes its targeted Godot ROI/rig and sampled-contact tests within their stated scope, and the full prototype suite passes. Candidate 11 passes only basic decode/canvas/corner checks. The Python alpha audits continue to reject both as production-ready cutouts; hidden anatomy, authored pivots, panel separation, and continuous all-frame seams remain unverified. No candidate is promoted to runtime or final art.

Candidate 03 also passes the existing visible-fidelity test against candidate 02 (IoU 0.9761, visible RGB MAE 17.65/255, maximum bounds drift 3 px). The hidden-anatomy provenance audit checks 664,937 layer pixels and finds zero independently differing RGB pixels against the flattened source. Candidate 09 v2 has 297,686 locally color-extrapolated underpaint pixels and its manifest explicitly sets `hidden_anatomy_verified` to false. These layers can help test overlap but are not verified anatomical art.

### BREAKER arm component board candidate 12 — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_12.png` | PNG RGBA, 1774×887; SHA256 `5576044246aa9c7cc1466f94acfd39fbe9bc3cf517ca6978a304d53ffb8fc2e4` | Four-panel view of human upper arm, separate shoulder shell, mechanical forearm/fist, and assembled arm | Quarantined concept board; visible boundary matches approved reading; not production art, separate runtime parts, or hidden-anatomy proof |
| Paired `_README.md` and `.json` | Markdown / JSON | Provenance, scoped validation, limitations | Local metadata only |
| `tools/art/audit_breaker_arm_components_candidate_12.py`, `tests/test_breaker_arm_components_candidate_12.gd` | Python / GDScript | RGBA, corner transparency, four panel ranges/gutters | PASS for structure only; anatomy and animation not tested |

Visual review finds the elbow boundary clear and the shell-alone panel isolated. Full-body proportions and authored joints remain open. The PNG includes 19,388 low-alpha fringe pixels and 5,651 soft-alpha pixels; it is not treated as a clean production atlas. No runtime reference or remote binary upload was made.


## BREAKER anatomy inspection board candidate 10 — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_anatomy_inspection_board_candidate_10.png` | PNG RGB, 1774×887; SHA256 recorded in paired JSON | Generated review board separating shoulder shell, human upper arm, mechanical forearm/fist | Quarantined illustrative study only; not canon, source evidence, production art, rig, or runtime content |
| Paired `.json` and `_README.md` | JSON / Markdown | Provenance, image hash, limitations and review status | Local metadata only |

The generated cutaway/exploded views do not prove hidden anatomy and include unapproved visual details. Their “arm-extent canon remains unresolved” note was accurate when created but is now historical; the user later approved an external shoulder shell over a biological upper arm, with the prosthesis beginning at the elbow.


## BREAKER v8 arm-mask ownership audit — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `docs/visual_qa/BREAKER_T1_trial05_v8_arm_mask_ownership_audit.png` | PNG RGB, 1200×900; SHA256 `03fc93e601df995913c457158a12f6d8c51c6aa373f4d35f19cbb540ea67c626` | Visualizes source ownership of right `cyber_upper_arm` and opposite `natural_upper_arm` masks | QA visualization only; not character art/runtime content |
| `tools/art/audit_breaker_trial05_v8_arm_masks.py` | Python / Pillow | Reproducibly checks source provenance and visible warm-skin color pixels owned by the right upper-arm mask, and builds the QA board | Passes its stated pixel heuristic; not semantic anatomy proof |

The heuristic counts 3,115 color-classified source pixels in the right shoulder ROI inside `cyber_upper_arm` and 0 inside `natural_upper_arm`. The right upper-arm source layer still fuses the exposed skin patch with shoulder hardware; hidden surfaces are extrapolated.


## BREAKER arm-split QA fixture v1 — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_arm_split_v1/visible_human_upper_arm_surface.png` | PNG RGBA, 1024×1536 | Warm-color pixels split from the flattened right upper-arm composite | **Rejected as standalone art:** sparse/fragmented surface; QA fixture only |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_arm_split_v1/external_shoulder_shell.png` | PNG RGBA, 1024×1536 | Remaining visible shell/hardware pixels from same composite | QA fixture only; not an authored independent shell asset |
| `docs/visual_qa/BREAKER_T1_trial05_v8_arm_split_neutral_compare.png` | PNG RGB, 1280×560 | Source vs isolated skin vs reconstructed neutral comparison | Visual QA only |
| `tools/art/build_breaker_t1_arm_split_v1.py`, `tests/test_breaker_trial05_v8_arm_split_v1.gd` | Python / GDScript | Rebuild and test visible pixel ownership/reconstruction | Passes pixel round-trip only; visual part-usability check fails |

User-approved canon boundary: external shoulder shell over biological upper arm; prosthesis begins at elbow. No hidden anatomy was created by this pixel split.

## Arm-boundary integration review and rejected alpha experiment — 2026-10-25

- User-approved canon is now explicit: the external shoulder shell sits over a biological upper arm; the mechanical right prosthesis begins at the elbow. This resolves the prior conflict between profile art and the written forearm description. It does not approve any current image as production art.
- Candidate 09 visually communicates the approved boundary at review scale. Its static Python audit and Godot decode test pass: 1024×1536 RGBA, solid visible bounds `(153, 32)–(950, 1492)`, 1,460 px visible height, projected boot delta 5.44 px at a 256 px review height. Hidden anatomy, rig pivots, motion and continuous seams remain NOT VERIFIED.
- Re-ran the full Godot prototype suite, candidate 09 static-image test, trial 05 v8 rig test, and 2,472 sampled contact checks across 206 poses at 60 Hz; all passed within their stated scope. The candidate 09, guarded-pose layer ownership and arm-mask audits also passed. The known non-fatal Godot user-log write warning persists.
- Evaluated the latest generated alpha-cleanup experiment without importing it. It retained 1024×1536 RGBA and the same alpha maximum (254); although its threshold silhouette IoU with candidate 09 is 0.995424, 1,370,832 RGBA pixels differ and 543,709 visible RGB pixels changed. It did not establish a clean cutout or preserve the source faithfully. REJECTED; no project art was replaced or added.
- Production-art gate remains NOT PASSED. The v8 split remains QA-only and is not a standalone arm asset. Continue art development from the approved candidate/reference direction with separate visible-pose and anatomy/rig gates.

## BREAKER Tier I arm components candidate 13 — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.png | PNG RGBA, 1774×887; SHA256 61f9b2a8b65c3e4a217cd441adb50e5136913c3b5f81f6d337145a13902c1d45 | Four-panel upper-arm / shoulder-shell / mechanical forearm / assembled concept board | Quarantined review concept; not runtime art, not an atlas |
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13_README.md | Markdown | Provenance, approved boundary, checks and limitations | Local draft metadata |
| assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.json | JSON | Candidate metadata and readiness status | Local draft metadata |
| docs/visual_qa/breaker_candidate13_arm_component_assembly_1280x720.png | PNG RGB, 1280×720 | Rendered comparison of assembled reference and estimated three-part fit in neutral/flex poses | Visual QA only; manual pivots, no production seam certification |
| tools/art/audit_breaker_arm_components_candidate_13.py, tests/test_breaker_arm_components_candidate_13.gd, tests/capture_breaker_candidate13_arm_assembly.gd | Python / GDScript | Static bounds/scale, direct image, and display-rendered assembly checks | Scoped passes; hidden anatomy/full rig remains unverified |

The static audit finds 16,624 fringe-alpha pixels and 5,348 soft-alpha pixels. The composition demonstrates the approved visible arm boundary, but it does not verify a clean production cutout, hidden anatomy, authorable pivots, or animation-ready seams. The elbow-flex comparison still shows a fit mismatch. Keep all candidate assets under the ignored draft path.

Candidate 13 pivot-fit follow-up: the latest review capture is docs/visual_qa/breaker_candidate13_arm_component_assembly_1280x720_02.png (PNG RGB, 1280×720). It replaces the earlier capture for current manual review; the forearm pivot estimate now aligns the visible elbow cap. Neutral and 0.30-radian elbow-flex poses read as connected at review scale with no obvious open gap. Estimated pivots are not author-verified and do not certify continuous seams or motion.

## BREAKER candidate 13 under-shell alpha validation — 2026-10-25 UTC

The local candidate 13 audit/test now evaluate a review assembly at estimated offsets. They report 26,325 px shell-over-upper-arm overlap, 29,014 px exposed upper-arm pixels, 18,785 px upper-arm-to-mechanical-forearm overlap, and one connected binary-alpha union. The new display-rendered capture includes a shell-off under-arm view. These measurements support continuous visible 2D surface coverage in the proposed composition; they are not a semantic anatomy check and do not verify concealed 3D structure, full-body proportions, exact pivots, or animation seams. Latest local capture: docs/visual_qa/breaker_candidate13_arm_component_anatomy_1280x720_02.png; PNG RGB, 1280×720.

## Candidate 13 reference-height calibration and anatomy review — 2026-10-25 UTC

The candidate 09 v2 approved-direction full-body reference has 1466 px visible height; its cyber-arm layer union is 422 px high. Candidate 13's assembled arm panel is 813 px high. The test-derived component scale is 0.519 relative to the reference art, matching a 73.7 px arm extent at the 256 px body-height target. This is height-only; art pose/orientation differ and width/silhouette match remain unverified.

Latest captures:
- docs/visual_qa/breaker_candidate13_arm_component_anatomy_1280x720_03.png — shell-on, shell-off under-arm, neutral, and elbow-flex review.
- docs/visual_qa/breaker_candidate13_reference_scale_1280x720_03.png — full-body reference beside height-calibrated candidate arm.

The 2D alpha composition test verifies shell coverage, exposed biological upper arm, elbow overlap, and connected union at estimated offsets. Neither capture nor overlap test establishes exact anatomy, concealed 3D detail, author pivots, all-frame seams, or production readiness.

## Arm-fit rejection and continuous-underpaint trials — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.png` | PNG RGBA, 1774×887 | Four-panel concept board | **Rejected as a full-body pose/proportion match**; still a quarantined boundary study only |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v3_continuous_underpaint/underpaint_cyber_upper_arm.png` | PNG RGBA, 1024×1536 | Continuous capsule sampled from candidate 09 bicep | Rejected visually for abrupt bands; QA experiment only |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_donor_underpaint/underpaint_cyber_upper_arm.png` | PNG RGBA, 1024×1536 | Continuous backing sampled from candidate 03 anatomy reference | Rejected visually for stripes/mottling; QA experiment only |
| `docs/visual_qa/breaker_candidate09_v2_arm_layer_inspection_1600x1100.png` | PNG RGB, 1600×1100 | Source, layer ownership, and inferred v2 surface inspection | QA only |
| `docs/visual_qa/breaker_candidate09_v3_underpaint_qa.png`, `docs/visual_qa/breaker_candidate09_v4_donor_underpaint_qa.png` | PNG RGB, 1350×930 | Visual comparisons for rejected underpaint trials | QA only; not production art |
| `tools/art/build_breaker_trial09_canon_v3_underpaint.py`, `tools/art/build_breaker_trial09_canon_v4_donor_underpaint.py` | Python / Pillow | Reproducible isolated underpaint experiments | Rebuilds separate quarantined drafts; neither passes visual acceptance |

Candidate 13's arm aspect ratio (0.462) differs sharply from the candidate 09 reference union (1.495); height-only scaling does not solve pose or silhouette. The current canon reference is candidate 09's original flattened art. Candidate 09 v2 preserves its visible composite and approved skin ownership but does not reconstruct verified hidden anatomy. No arm component or underpaint draft is approved for runtime.

The updated Python and Godot 4.7.2 candidate 13 audits now verify that its mismatch is explicitly recorded: at matched height it is 195.2 px wide versus 631 px for the reference (69.1% narrower). The manifests for v3/v4 parse cleanly, and a runtime-tree search finds no references to candidate 13 or the rejected underpaint drafts.

## BREAKER candidate 09 v4/v5 hidden-arm anatomy studies — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_manual_skin/cyber_upper_arm_skin.png`, `cyber_shoulder_shell.png` | PNG RGBA, 1024×1536 each | Exclusive visible skin/shell layers from candidate 09 | Quarantined feasibility layers; exact neutral reconstruction, not production cutouts |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v5_generated_underpaint/donor_no_shell.png` | PNG RGBA, 1024×1536 | Generated shell-removed anatomy donor | Quarantined donor; its full composition is not source-preserving and must not replace candidate 09 |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v5_generated_underpaint/hidden_biological_upper_arm_donor.png` | PNG RGBA, 1024×1536; 18,066 visible pixels | Warm-skin pixels extracted beneath the original shell mask | Quarantined hidden-surface hypothesis; exact neutral composite remains unchanged; not canonically authored or production art |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v5_generated_underpaint/generated_reference_edit.png` | PNG RGBA, 1024×1536 | First generated edit attempt | Rejected as replacement; 1,382,917 pixels differ from the reference |
| `docs/visual_qa/BREAKER_T1_candidate09_v4_manual_skin_split.png` | PNG RGB, 900×1260 | v4 visible skin/shell ownership diagnostic | QA board; green/magenta overlays are not character art |
| `docs/visual_qa/BREAKER_T1_candidate09_v5_underpaint_shell_off.png` | PNG RGB, 1120×668 | Shell-off comparison of source layers and v5 underpaint | QA only; shows a continuous volume, but its rounder deltoid and residual source fragments need visual review |
| `docs/visual_qa/BREAKER_T1_candidate09_v5_generated_underpaint_roi_comparison.png` | PNG RGB, 1704×662 | Source / full generated edit / RGB difference, cropped to the arm | QA only; demonstrates why the full generated edit was rejected |
| `tools/art/export_breaker_trial09_canon_v4_manual_skin.py`, `audit_breaker_trial09_canon_v4_manual_skin.py`, `export_breaker_trial09_v5_hidden_arm_donor.py`, `build_breaker_trial09_v5_anatomy_donor_review.py` | Python / Pillow | Reproducible visible split, donor mask, source comparison and audit | Pass stated checks; generated anatomy remains a hypothesis |
| `tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin.gd`, `_contacts.gd`, `test_breaker_profile_rig_trial_09_canon_v5_underpaint.gd` | Godot GDScript | Structure, canon ROI, and 60 Hz registration review tests | Focused tests pass; shared-bone registration is not independent-shell deformation validation |

All v4/v5 files are in `.gdignore`d draft folders and have no runtime references. The candidate 09 v4 Python audit reports 14 exclusive layers and exact neutral reconstruction; its right bicep ROI has 5,796 warm-skin-classified pixels on the biological layer, zero on shell and forearm. The v5 donor is beneath the source shell and preserves that exact neutral composite. It is not approved for runtime or production. Hidden anatomy/pivots/deformation remain NOT VERIFIED; production-art gate remains NOT PASSED.

| `docs/visual_qa/BREAKER_T1_candidate09_v5_connected_anatomy_overlay.png` | PNG RGB, 1120x674 | Visible + inferred biological skin connectivity and source-with-shell overlays | Quarantined QA evidence only; 2D connected-mask result, not proof of anatomical accuracy or production readiness; SHA-256 `C3343A9C46CF9C47F04887CE569BC52B4DD172F0ECFDB67CDD28695A871CF42A` |


## BREAKER candidate 09 v6–v9 hidden anatomy review studies — 2026-10-25 UTC

| Local file | Format / dimensions | Purpose | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v6_reference_contour/reference_contour_full_edit.png` | PNG RGBA, 1024×1536 | Constrained generated edit using candidate 09 as silhouette reference | Quarantined source study; not a replacement for candidate 09 |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v6_reference_contour/hidden_biological_upper_arm_donor.png` | PNG RGBA, 1024×1536; 15,993 selected pixels | v6 under-shell skin extraction | Quarantined; exact visible composite but rounded shell-off fit not accepted |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v7_narrow_contour/hidden_biological_upper_arm_donor.png` | PNG RGBA, 1024×1536; 14,753 pixels | 8% horizontal contraction of v6 donor | Rejected after visual review; still inflated and has fragmented edges |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v8_clean_underpaint/hidden_biological_upper_arm_donor.png` | PNG RGBA, 1024×1536 | 5px mask close and 591-pixel fill | Quarantined; exact visible composite and connectivity pass, visual improvement not established |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v9_continuous_arm_underpaint/hidden_biological_upper_arm_donor.png` | PNG RGBA, 1024×1536 | Continuous skin underlayer derived from v4 visible skin and v6 donor | Quarantined; 206-sample Godot registration passes, shell-off fit not accepted |
| `docs/visual_qa/BREAKER_T1_candidate09_v6_reference_contour.png` | PNG RGB, 1658×668 | v5/v6/source contour comparison | QA only |
| `docs/visual_qa/BREAKER_T1_candidate09_v7_narrow_contour.png` | PNG RGB, 2198×668 | v5/v6/v7/source comparison | QA only; v7 rejected |
| `docs/visual_qa/BREAKER_T1_candidate09_v8_clean_underpaint.png`, `docs/visual_qa/BREAKER_T1_candidate09_v9_continuous_arm_underpaint.png` | PNG RGB, 2188×664 each | v5/v6/v8 or v9/source comparisons | QA only; no production-art approval |
| `docs/visual_qa/BREAKER_T1_underpaint_visual_review_matrix.png` | PNG RGB, 1328×1598 | Legible 2×2 shell-off draft and approved shell-on source comparison | QA only; SHA-256 `17BA6693ED7D1E9E63E8BB7BF811A3CA6A8D0ED3453134D8109F4F5BD99587FA` |
| `tools/art/export_breaker_trial09_v6_reference_contour.py`, `build_breaker_trial09_v7_narrow_contour.py`, `build_breaker_trial09_v8_clean_underpaint.py`, `build_breaker_trial09_v9_continuous_arm_underpaint.py`, `build_breaker_trial09_underpaint_review_matrix.py` | Python / Pillow | Reproducible mask exports, exact-composite/connectivity checks, and review board | Scoped checks pass; generated/inferred anatomy remains unverified |
| `tests/test_breaker_profile_rig_trial_09_canon_v9_underpaint.gd` | Godot GDScript | v9 donor registration across 206 neutral/60 Hz samples | Passes registration only; no anatomy or production-art validation |

All v6–v9 files are quarantined; each draft folder contains `.gdignore`. No new runtime references or production assets.


## BREAKER candidate 09 v13 hidden shoulder donor — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/shell_off_anatomy_study.png` | PNG RGB, 1024×1536 | Generated from candidate 09 as a shell-off anatomy hypothesis | Quarantined provenance only; broad generated edit is not replacement art. |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/hidden_biological_upper_arm_donor.png` | PNG RGBA, 1024×1536; 16,407 alpha pixels | Skin-classified generated pixels clipped to opaque candidate 09 v4 shell mask and upper-arm ROI | Exact thresholded shell-on reconstruction passes; 25,738-pixel largest visible/hidden skin union; not artist-authored or production-verified. |
| `tools/art/build_breaker_trial09_v13_compact_shoulder_donor.py`, `tools/art/audit_breaker_trial09_v13_shoulder_donor.py` | Python / Pillow | Build, provenance, source-preservation and connectivity checks | PASS within stated scopes. |
| `tests/test_breaker_profile_rig_trial_09_canon_v13_underpaint.gd` | Godot 4 GDScript | 206 neutral/60 Hz transform/anchor samples across five poses | PASS for shared-bone registration only; no artistic or independent shell validation. |
| `docs/visual_qa/BREAKER_T1_candidate09_v13_shoulder_donor_review.png` | PNG RGB, 2208×672 | Candidate 09 shell-on, no-donor shell-off, rejected v9 shell-off, and v13 shell-off comparison | User visual review requested; production art not approved. |

No runtime references or remote binary uploads.


### v13 connected donor and shell-separation diagnostics — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/hidden_biological_upper_arm_donor_v2.png` | PNG RGBA, 1024×1536; 16,464 alpha pixels | Largest broad skin-classified component from the v13 generated shell-off study, clipped to opaque source shell | Deterministic extraction; exact thresholded shell-on reconstruction and 2D connectivity checks pass. Generated hypothesis only; not approved or runtime. |
| `tools/art/refine_breaker_trial09_v13_connected_skin.py` | Python / Pillow | Rebuilds/checks the v2 component mask without overwriting an existing differing donor | PASS: 26,309-pixel source skin component; 16,464 pixels under shell; exact shell-on composite. |
| `tools/art/audit_breaker_trial09_v13_shoulder_donor.py`, `tests/test_breaker_profile_rig_trial_09_canon_v13_underpaint.gd` | Python / Godot GDScript | Donor bounds, source identity, 2D continuity, and 206 pose registration samples | PASS within stated limits; not anatomical or production-art proof. |
| `tests/capture_breaker_v13_shell_offset_stress.gd`, `docs/visual_qa/BREAKER_T1_v13_shell_independent_motion_stress.png` | Godot GDScript / PNG, 1300×530 comparison | Baseline, shell +12 source px, independent rotation 0.16 rad, shell hidden | Captures pass; anchor stable. Review-only visual stress, not an approved animation clip. |

The shell-off shape still requires user review. Do not promote the donor or upload it as production art.


| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/hidden_biological_upper_arm_donor_v4_full_shell.png` | PNG RGBA, 1024×1536; 25,942 alpha pixels | Every opaque pixel in the v4 shoulder-shell mask, sampled from v13 generated shell-off study | Exact shell-on composite; complete source-mask coverage. May expose generated non-skin pixels when shell moves; quarantined and unapproved. |
| `tools/art/build_breaker_trial09_v13_full_shell_underpaint.py`, `tests/capture_breaker_v13_full_shell_offset_stress.gd` | Python / Godot GDScript | Full-shell mask extraction and independent shell shift/rotation/hide captures | Build and capture PASS; anchor stable. Visual/artistic acceptance remains open. |
| `docs/visual_qa/BREAKER_T1_v13_full_shell_independent_motion_stress.png`, `docs/visual_qa/BREAKER_T1_v13_full_shell_detail_stress.png` | PNG RGB, 1300×530 and 1120×320 | Four pose-independent shell states and close shoulder detail | Review only; shows a generated full shoulder, not approved anatomy or production art. |


## BREAKER v13 v5 correction study — 2026-10-25 UTC

| Asset | Format / dimensions | Source and purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/shell_off_anatomy_study_v2.png` | PNG RGB, 1024×1536 | Generated shell-off correction based on candidate 09; slightly tightens shoulder contour | Quarantined study; visual review still finds shoulder oversized |
| `.../hidden_biological_upper_arm_donor_v5_full_shell.png` | PNG RGBA, 1024×1536; 25,942 alpha pixels | Generated pixels clipped to the full opaque candidate 09 shell mask | Exact thresholded shell-on composite; Godot pose registration passes; not accepted anatomy or runtime art |
| `tools/art/build_breaker_trial09_v13_v5_full_shell_underpaint.py`; `tests/test_breaker_profile_rig_trial_09_canon_v13_v5_underpaint.gd`; `tests/capture_breaker_v13_v5_full_shell_offset_stress.gd` | Python / Godot GDScript | Rebuild, 206-sample registration, and independent shell stress capture | PASS for scoped checks; anatomy/art gate remains NOT PASSED |
| `docs/visual_qa/BREAKER_T1_v13_v5_shoulder_zoom_stress.png` | PNG RGB, 1600×350 | Four-view shoulder zoom: baseline, shifted shell, rotated shell, shell hidden | Review evidence; visibly oversized contour remains unresolved |


## BREAKER v13 v6 proportion study — 2026-10-25 UTC

| Asset | Format / dimensions | Source and purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor/hidden_biological_upper_arm_donor_v6_compact_82.png` | PNG RGBA, 1024×1536; 11,144 alpha pixels | 82%-width generated under-shell skin hypothesis, clipped to original opaque shell mask and upper-arm ROI | Exact shell-on reconstruction and pose registration pass; quarantined, user review pending |
| `tests/test_breaker_profile_rig_trial_09_canon_v13_v6_underpaint.gd`; `tests/capture_breaker_v13_v6_compact_offset_stress.gd` | Godot GDScript | 206-sample registration and independent-shell stress capture | PASS for scoped checks; generated seams/anatomy remain unverified |
| `docs/visual_qa/BREAKER_T1_v13_shoulder_shape_options.png` | PNG RGB, 1500×460 | Shell-hidden comparison: v13 v4, v5, and narrower v6 | Review evidence; no option accepted yet |


### v6 connectivity note

The combined v4 visible skin plus v6 donor mask measures 20,723 pixels across 58 components; largest component 20,505 pixels (98.9%). This misses the earlier 25,000-pixel screening threshold and flags small disconnected fragments. The donor remains quarantined; this diagnostic does not pass anatomy continuity.


## Approved candidate01 hidden-arm studies — 2026-10-25 UTC

| Asset | Format / dimensions | Source and purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/shell_off_anatomy_study_v1.png` | PNG RGB, 1024×1536 | Generated shell-off anatomical study from approved candidate01 | Quarantined reference only; full-image edits are not source art |
| `.../hidden_biological_upper_arm_candidate01_v2.png` | PNG RGBA, 1024×1536; 21,108 alpha pixels | Hand-bounded and skin-classified upper-arm underlay | One connected region; exact shell-on source at alpha threshold 245; forearm overlap 6,383 px; not production art |
| `.../hidden_biological_upper_arm_candidate01_v3_compact72.png` | PNG RGBA, 1024×1536; 15,219 alpha pixels | 72%-width compact proportion hypothesis | Exact shell-on source; one connected upper-arm/forearm region; 4,732 px overlap; visual review pending |
| `tools/art/build_breaker_trial01_candidate01_hidden_arm.py`; `tests/test_breaker_profile_rig_trial_01_candidate01_hidden_arm.gd`; `tests/test_breaker_profile_rig_trial_01_candidate01_hidden_arm_v3.gd` | Python / Godot GDScript | Deterministic extraction, pixel reconstruction, arm/forearm connectivity, 206-sample shared-bone registration | PASS for scoped checks only; art gate NOT PASSED |
| `docs/visual_qa/BREAKER_T1_candidate01_hidden_arm_options.png` | PNG RGB, 1400×477 | Approved source, generated shell-off study, v2 and v3 donor comparison | Review evidence; no version approved |

## BREAKER candidate01 shell / upper-arm review — 2026-10-25

| Asset | Format / dimensions | Source and purpose | Status |
|---|---|---|---|
| `docs/visual_qa/BREAKER_T1_candidate01_shell_elbow_rebuild_v4.png` | PNG RGB, 1260×750 | Side-by-side approved crop, exact shell-on layer split, and shell-off assembly | QA only; shell-off assembly rejected because generated underpaint and old rig masks create visible misalignment |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_biological_upper_arm_visible_v4.png` | PNG RGBA, 1024×1536 | Classified visible skin pixels split from the approved candidate01 upper-arm layer | Exact compositing partition with external-shell v4; jagged isolated edges; quarantined, not production art |
| `.../candidate01_external_shoulder_shell_v4.png` | PNG RGBA, 1024×1536 | Complementary pixels from the same source layer | Exact compositing partition; not independently authored/deformed; quarantined |
| ImageGen constrained shell-off edit (generated 2026-10-25) | PNG, 1024×1536 | Attempted proportion-matched anatomy reference | Rejected: unrelated body areas changed; not copied into the project |

The user's approved boundary is external shell over biological upper arm with elbow-start prosthesis. The split reconstructs the approved source layer exactly, but that does not establish valid shell-off anatomy. No new images are runtime resources, and no production art is approved.

| `docs/visual_qa/BREAKER_T1_candidate01_shell_off_v2_v3_donor_comparison.png` | PNG RGB, 820×740 | Cropped shell-off v2 versus compact v3 underlays at the approved candidate01 elbow | Both rejected: oversize donor and unclear elbow connection; QA only |

## BREAKER candidate01 elbow-boundary fit studies — 2026-10-25

| Asset | Format / dimensions | Source / purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/isolated_upper_arm_generated_fit_study.png` | PNG RGBA, 1024×1536 | Generated isolated skin study, trimmed and fitted to candidate01 shoulder/elbow pivots | Quarantined source only; not production art |
| `.../candidate01_fitted_underarm_slim_affinefix_v2_review.png` | PNG RGBA, 1024×1536; 14,357 opaque pixels | x-scale 0.20 fitted underlay; 1,070-pixel overlap with elbow-start forearm | Quarantined review hypothesis; shell-on exact and 2D union connected |
| `.../candidate01_fitted_underarm_broad_affinefix_v2_review.png` | PNG RGBA, 1024×1536; 20,059 opaque pixels | x-scale 0.28 fitted underlay; 1,523-pixel overlap with elbow-start forearm | Quarantined review hypothesis; shell-on exact and 2D union connected |
| `docs/visual_qa/BREAKER_T1_candidate01_elbow_underarm_fit_options_affinefix_v2.png` | PNG RGB, 1170×610 | Approved source beside slim and broad shell-off cropped fits | Visual QA only; neither fit is approved |
| `docs/visual_qa/BREAKER_T1_candidate01_fullbody_256px_elbow_underarm_affinefix_v2.png` | PNG RGB, 1320×500 | Full-body variants at 256 px visible height | Visual QA only; shell-off acceptance pending |
| `tests/test_breaker_profile_rig_trial_01_candidate01_fitted_arm_options.gd` | Godot GDScript | Verifies source-aligned layer parenting through 412 sampled pose frames for two width trials | PASS within stated transform scope; not a visual or seam acceptance test |
| `tools/art/build_breaker_trial01_candidate01_fitted_arm_options.py` | Python | Deterministic split/fit, source reconstruction, overlap and connected-mask checks | PASS within stated image scope |
| `docs/BREAKER_T1_HIDDEN_ANATOMY_ART_BRIEF.md` | Markdown | Provisional art-authoring brief and five acceptance gates for canon, fidelity, anatomy, part readiness, and rig continuity | Reference only; it does not approve a shape or asset |

The y=495 forearm split derives from the provisional trial elbow pivot. Shell pixels from both source layers are grouped on the shoulder bone; mechanical forearm pixels at/below that row remain on the elbow bone in the review rig. Generated image boards with the previous incorrect affine transform are superseded; do not use those boards for art decisions. Runtime art remains unchanged.

| `tests/capture_breaker_candidate01_shell_on_rig_review.gd` and `docs/visual_qa/BREAKER_T1_candidate01_shell_on_rig_*.png` | Godot GDScript / five PNG viewport captures | Candidate01 source partitions assembled with shell visible in neutral, walk, punch, hit, and defeat | Godot OpenGL capture succeeded. Presentation/pose plumbing only; estimated pivots and provisional layers do not certify concealed anatomy or production readiness. |

| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_vector_underlay_v1.svg` | SVG, 1024×1536 | Hand-authored source-aligned underarm shape using approved candidate01 proportions as a guide | Quarantined art trial only; masked by source shell/skin/forearm when assembled. Shell-on opacity and sampled elbow contact pass; shell-off style/proportion review pending. Not runtime art. |
| `tests/capture_breaker_candidate01_vector_underlay_review.gd` and `docs/visual_qa/BREAKER_T1_candidate01_vector_underlay_*.png` | Godot GDScript / 10 PNG captures | Shell-on/off pose review across neutral, walk, punch, hit, defeat | Godot 4.7.2 OpenGL Compatibility capture passed; visual gate remains pending. |
| `tests/test_breaker_profile_rig_trial_01_candidate01_fitted_arm_options.gd` | Godot GDScript | Fitted-arm and vector underlay source-coverage / contact checks | Three variants, 206 samples each; vector 398–865 elbow-contact pixels; underlay has zero opaque pixels exposed in shell-on source composite. Structural proof only. |

### Concealed-arm generation attempt — 2026-10-25 UTC

A separate transparent upper-arm concept was generated for evaluation against the approved crop. It was visually rejected as oversized, overly muscular, and style-mismatched; it was not copied to the project or used in a rig. It is not part of the asset library or production candidates.

### Canonical Drive read-only inventory — 2026-10-25 10:07 UTC

Source root: [Neon Requiem Drive](https://drive.google.com/drive/folders/1EsuAqZMVJeGSLTWPULaDFitDcfwlq8c2). Browser readback only; no files were changed.

| Live folder | Readback | Formats / readiness |
|---|---|---|
| `01 — Concept Art` | `01_world_roster_concept_sheet.png`; `02_character_faction_design_sheet.png`; `03_breaker_evolution_reference.png`; `04_breaker_production_board.png` | PNG concept/reference sheets. Not production animation parts. |
| `02 — Character Sprites` | `Breaker_Tier1_Godot_Production_Spec.md` | Markdown specification; no rig-ready sprite parts in this folder. |
| `05 — Godot Project Backups` | Empty | No remote Godot backup found. |
| `06 — Milestone Snapshots` | `MANIFEST.md`; `README.md`; `Neon_Requiem_Reconstruction_Kit.zip` | ZIP reconstruction archive plus text manifests. Archive inspection found no PSD/KRA/ORA/XCF/BLEND/SVG source. |

The same native/layered format search found no editable art source in the inspected local backup archives. The shell-on review captures are listed in `docs/visual_qa/`; they are QA outputs from the isolated estimated-pivot rig and are not production assets. No remote upload is claimed.

### Candidate01 slim/broad fit visual disposition — 2026-10-25 UTC

The corrected affinefix_v2 crop and full-body QA boards have now been reviewed. Both fit PNGs remain inventoried as rejected/quarantined studies: exposed donor texture and hard cutout artifacts are visible, and neither arm contour/style matches the approved reference. Their Python and Godot structural tests still pass within scope, but visual rejection supersedes prior pending-acceptance labels. Keep both files out of runtime and production exports. No approved replacement hidden-arm art exists yet.

### Contextual cutaway study — 2026-10-25 UTC

| Asset | Format / dimensions | Source / purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_cutaway_study_v1.png` | PNG RGB, 926×1698, 2,393,211 bytes; SHA-256 `993B63BCC2803F94ADAC00747B1D72C27D2CD1F97CC1C20637224A987C25B62B` | Generated contextual view from approved candidate01 arm crop; shows shell, hidden-arm boundary, elbow prosthesis and a shell-off inset | Quarantined concept only. Boundary intent is legible; upper arm is too bulky and shoulder armor differs from approved art. Not tested, rig-ready, or runtime-referenced. |

## Candidate01 underlay overlay trials — 2026-10-25 UTC

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_vector_underlay_v1.svg` | SVG, 1024×1536 | Source-aligned vector underlay hypothesis | Quarantined; shell-off review rejected for flat, detached contour. |
| `.../candidate01_upper_arm_source_texture_underlay_v2.svg` | SVG, 1024×1536 | Same underlay with source-layer texture at 18% opacity | Quarantined; shell-off review rejected for swollen/detached contour and stray texture marks. |
| `tests/capture_breaker_candidate01_source_texture_underlay_review.gd`, `tests/test_breaker_profile_rig_trial_01_candidate01_fitted_arm_options.gd` | Godot GDScript | Capture six poses shell-on/off; check source-mask coverage, arm registration and elbow contact | 824 sampled frames PASS across four options; not visual acceptance or all-frame deformation validation. |
| `docs/visual_qa/BREAKER_T1_candidate01_source_texture_underlay_*.png` | PNG RGB, six poses shell-on/off plus two details | Isolated Godot visual QA | Shell-on appearance retained; shell-off anatomy rejected. Review only, not production art. |

No runtime asset was added. The approved arm-boundary decision remains external shoulder shell over biological upper arm with prosthesis beginning at elbow; hidden shape and production part art remain unapproved.

## Candidate01 source-skin and vector v2 trials — 2026-10-25 UTC

| Asset | Format / dimensions | Source and purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_vector_underlay_v2.svg` | SVG, 1024×1536 | Compact tapered vector hypothesis with simple muscle-plane shading | Quarantined; shell-on exact; shell-off visual review fails style/connection. |
| `.../candidate01_same_source_skin_upper_arm_underlay_v1.png` | PNG RGBA, 1024×1536 | Scaled skin cutout from BREAKER's own exposed opposite arm | Quarantined; shell-off review shows narrow, detached strip. |
| `.../candidate01_upper_arm_same_source_skin_texture_underlay_v3.svg` | SVG, 1024×1536 | Vector v2 with same-source arm-skin texture layer | Quarantined; shell-on exact; shell-off texture streaking/source seams fail review. |
| `tools/art/build_breaker_trial01_same_source_skin_underlay_v1.py`, `tools/art/build_breaker_trial01_same_source_skin_texture_underlay_v3.py` | Python | Rebuild same-source skin cutout and source-texture SVG trial | Reproducible draft builders; no production asset approval. |
| `tests/test_breaker_profile_rig_trial_01_candidate01_fitted_arm_options.gd` | Godot GDScript | Seven alternatives: shell-on coverage and five-pose elbow-contact registration | Godot 4.7.2 PASS; 1,442 samples. Not artistic or all-frame validation. |
| `tests/capture_breaker_candidate01_vector_underlay_v2_review.gd`, `tests/capture_breaker_candidate01_same_source_skin_texture_underlay_v3_review.gd` | Godot GDScript | OpenGL captures for shell on/off in five poses plus detail | Capture passes; estimated pivots and provisional parts only. |
| `docs/visual_qa/BREAKER_T1_underarm_review_options_2026-10-25.png` | PNG RGB, 1600×1820 | Approved shell-on source beside three shell-off trial variants | Review aid only; none of the shell-off variants is accepted. |

Generated localized repaint and isolated-arm images were visually rejected and not copied into project assets. No runtime resource references were added.

## Candidate01 compact source-texture v4 — 2026-10-25 UTC

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_compact_skin_texture_underlay_v4.svg` | SVG, 1024×1536 | 84%-width v2 contour with low-opacity same-character skin texture | Shell-on source fidelity and 206-frame sampled contact pass; shell-off still too vector-like with visible streaks. Quarantined, rejected as production art. |
| `tools/art/build_breaker_trial01_compact_skin_texture_underlay_v4.py`; `tests/capture_breaker_candidate01_compact_skin_texture_underlay_v4_review.gd` | Python / Godot GDScript | Rebuild and capture shell-on/off poses and details | Review evidence only. |
| `docs/visual_qa/BREAKER_T1_candidate01_compact_skin_texture_underlay_v4_neutral_detail_shell_*.png` | PNG RGB, 1280×720 | Shell-on/off detail review | Shell-on source retained; shell-off not accepted. |
| `docs/visual_qa/BREAKER_T1_underarm_review_options_v4_2026-10-25.png` | PNG RGB, 1600×1820 | Side-by-side shell-on and v2/v3/v4 shell-off studies | Review board; no shell-off art approved. |

Godot 4.7.2 focused fit/contact test passes eight variants across 1,648 samples; compact v4 records 186–374 transformed elbow-contact pixels across 206 frames. The full prototype test suite passes. These results do not validate artistic quality, continuous deformation, or production readiness.

## BREAKER candidate01 mapped skin texture trials v5–v6 — 2026-10-25 UTC

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `.../generated_upper_arm_texture_source_v1.png` | PNG RGBA, generated standalone arm image | Isolated source for texture sampling only | Quarantined; generated anatomy is oversized, never used as a shape or runtime part. |
| `.../candidate01_upper_arm_generated_texture_underlay_v5.png` | PNG RGBA, 1024×1536 | Compact vector v2 shape with 14% mapped generated skin texture | Shell-on exact and sampled registration pass; still too smooth/vector-like. Rejected as production art. |
| `.../candidate01_upper_arm_generated_texture_underlay_v6.png` | PNG RGBA, 1024×1536 | Same shape with 38% mapped texture | Shell-on exact and sampled registration pass; crosswise shading mismatches anatomy. Rejected as production art. |
| `tools/art/build_breaker_trial01_generated_texture_underlay_v5.py`, `..._v6.py` | Python | Reproducible texture mapping at two blend amounts | Quarantined review builders only. |
| `tests/capture_breaker_candidate01_generated_texture_underlay_v5_review.gd`, `..._v6_review.gd` | Godot GDScript | Five-pose shell-on/off capture | Review-only evidence. |
| `docs/visual_qa/BREAKER_T1_underarm_review_options_v6_2026-10-25.png` | PNG RGB, 1600×1820 | Shell-on baseline and v4/v5/v6 comparison | Review aid; all shell-off variants rejected. |

Godot 4.7.2 focused review passes ten variants across 2,060 samples, including 206 pose samples for each new texture option. Full prototype tests pass; art gate remains **NOT PASSED**.

## BREAKER candidate01 constrained paint v7 — quarantined review

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_upper_arm_constrained_painted_underlay_v7.png` | PNG RGBA, 1024×1536 | Generated paint clipped to the compact v2 contour; review-only biological upper-arm underlay | Quarantined; exact shell-on coverage and sampled contact pass, but native-scale shell-off review finds a jagged shoulder-wrap fragment and ambiguous join. Not production art and not referenced at runtime. |
| `assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/generated_upper_arm_texture_source_v1.png` | PNG RGBA, 1024×1536 | Texture source for v7 paint study | Quarantined paint source only; oversized anatomy is not used as geometry. |
| `tools/art/build_breaker_trial01_constrained_painted_underlay_v7.py` | Python | Deterministic v7 underlay builder | Review tool; does not modify approved/source/runtime art. |
| `tests/capture_breaker_candidate01_constrained_painted_underlay_v7_review.gd`, `tests/capture_breaker_candidate01_v7_gameplay_scale_review.gd` | Godot GDScript | OpenGL pose and gameplay-scale review captures | Review evidence; estimated pivots and provisional anatomy only. |

## BREAKER candidate01 source-mask cleanup and connected fit v8–v10 — quarantined

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `tools/art/build_breaker_candidate01_clean_shell_skin_partition_v5.py`; `candidate01_biological_upper_arm_visible_v5_main_component.png`; `candidate01_external_shoulder_shell_v5_complement.png` | Python / PNG RGBA, 1024×1536 | Remove isolated mask components while assigning all other original pixels to the complementary shell | Exact source reconstruction; no meaningful shell-off improvement. Quarantined. |
| `tools/art/build_breaker_candidate01_warm_skin_partition_v6.py`; `candidate01_biological_upper_arm_visible_v6_warm_pixels.png`; `candidate01_external_shoulder_shell_v6_complement.png` | Python / PNG RGBA, 1024×1536 | Source-palette mask experiment | Exact source reconstruction; visual output remains effectively unchanged. Quarantined. |
| `tools/art/build_breaker_trial01_connected_underlay_v10.py`; `candidate01_upper_arm_connected_underlay_v10.png` | Python / PNG RGBA, 1024×1536 | Tapered arm extension reaching under the torso cutout | 1,410 opaque torso-overlap pixels; shell-on fully occluded. Gameplay-scale connection reads better; native-scale paint stretch remains. Provisional candidate only. |
| `tests/capture_breaker_candidate01_v8_clean_skin_partition_review.gd`, `tests/capture_breaker_candidate01_v9_warm_skin_partition_review.gd`, `tests/capture_breaker_candidate01_v10_connected_underlay_review.gd` | Godot GDScript | OpenGL shell on/off, five poses, native detail and 256 px scale captures | Review harnesses; estimated pivots, no production-art approval. |
| `docs/visual_qa/BREAKER_T1_candidate01_warm_partition_v9_shell_toggle_review.png` | PNG, 1320×810 | Shell-on versus shell-off source-mask comparison | Shows the pre-v10 torso attachment gap; review aid only. |
| `docs/visual_qa/BREAKER_T1_candidate01_v10_connected_underlay_neutral_detail_shell_off.png`, `..._256px_shell_off.png` | PNG, 1280×720 | v10 close-up and gameplay-scale shell-off previews | Gameplay-scale review is promising; close-up still shows stretched paint. Keep quarantined. |

**V10 disposition update:** native detail review rejects the stretched geometry and visible edge artifacts. Preserve its files and tests as a failed experiment; it is not a current candidate for promotion. `docs/visual_qa/BREAKER_T1_candidate01_v10_gameplay_toggle_review.png` is a review comparison only.

## BREAKER candidate01 under-vest socket v11 — rejected review study

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `tools/art/build_breaker_trial01_underarm_socket_v11.py`; `candidate01_upper_arm_underarm_socket_v11.png` | Python / PNG RGBA, 1024×1536 | Preserve v7 arm contour and add an under-vest connector from sampled edge pixels | 11,148 added pixels; zero shell-on exposure; contact tests pass. Native detail shows horizontal texture streaks; rejected and quarantined. |
| `tests/capture_breaker_candidate01_v11_socket_underlay_review.gd`; `docs/visual_qa/BREAKER_T1_candidate01_v11_socket_underlay_neutral_detail_shell_off.png` | Godot GDScript / PNG, 1280×720 | Five-pose, anchor, detail, and 256 px review capture | Capture/anchor pass; visual art fails. Not production evidence. |

## BREAKER Tier I arm boundary confirmation and validation rerun — 2026-10-25 UTC

The user reconfirmed the approved boundary: external shoulder shell over biological upper arm; elbow-start mechanical prosthesis including forearm/fist. No hidden contour or draft was approved. Godot 4.7.2 focused review test passed 13 variants / 2,678 sampled frames, and full prototype tests passed. Art remains not passed; no runtime reference changed. Captures and art drafts remain quarantined.

## BREAKER candidate01 generated-skin underlay v12–v15 — quarantined

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `candidate01_upper_arm_source_edit_v12_shell_on.png` | PNG RGB, 1024×1536 | Localized image edit from candidate01 | Rejected as a replacement: prosthesis/arm and other pixels drift; donor provenance only. |
| `candidate01_upper_arm_source_edit_v13_shell_off.png` | PNG RGB, 1024×1536 | Shell-off anatomy edit derived from v12 | Too bulky as a full-body result; retained as a source-texture donor only. |
| `tools/art/build_breaker_candidate01_generated_skin_underlay_v14.py`; `candidate01_generated_skin_fitted_underlay_v14.png` | Python / PNG RGBA, 1024×1536 | Fit donor to source arm envelope | Shell-on occlusion passes; sampled elbow contact fails at 10 px in defeat. Expected-reject test fixture. |
| `tools/art/build_breaker_candidate01_generated_skin_underlay_v15.py`; `candidate01_generated_skin_fitted_underlay_v15.png` | Python / PNG RGBA, 1024×1536 | Tapered, torso-facing extension of v14 donor | Shell-on occlusion and 206 sampled Godot contact frames pass (104–268 px); shell-off contour remains provisional and unapproved. |
| `tests/capture_breaker_candidate01_v14_generated_skin_underlay_review.gd`; `tests/capture_breaker_candidate01_v15_generated_skin_underlay_review.gd` | Godot GDScript | Five-pose, shell toggle, native/detail, and 256 px captures | OpenGL Compatibility captures and anchor checks pass; review only. |
| `docs/visual_qa/BREAKER_T1_candidate01_v15_generated_skin_underlay_neutral_detail_shell_off.png`; related `_walk_`, `_punch_`, `_hit_`, `_defeat_`, and `_256px_` captures | PNG | Visual fit evidence | Not production art. V15 is not runtime referenced. |

### BREAKER candidate01 underarm fit v16–v20 — quarantined review trials

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `tools/art/build_breaker_candidate01_tapered_underarm_v20.py`; `candidate01_tapered_underarm_v20.png` | Python / PNG RGBA, 1024×1536 | Tapered upper-arm fit with displacement reaching zero at the elbow | Shoulder root gap 2 source px; shell-on layer coverage passes; Godot elbow contact 104–267 px across 206 sampled pose frames. Review-only; not approved production art. |
| `tests/capture_breaker_candidate01_v20_tapered_underarm_review.gd`; `docs/visual_qa/BREAKER_T1_candidate01_v20_tapered_underarm_*` | Godot GDScript / PNG, 1280×720 | Five-pose shell toggle, native detail and 256 px captures | OpenGL Compatibility capture and ground-anchor checks pass. Shell-off shoulder/axilla look remains provisional and awaits owner review. |
| v16–v18 generated-skin connectors; v19 elbow-anchored transform | PNG RGBA, 1024×1536 | Alternative fits | v16–v18 visually rejected as artificial connector shapes; v19 fails elbow contact (5–59 px). Retain only as quarantined failed studies. |

Focused regression suite now covers 20 variants / 4,120 pose samples; v14 and v19 are explicit expected rejects. Full prototype runner passes. Tests establish source-layer occlusion, sampled bone contact and anchor stability only; they do not prove final anatomy, authored pivots, continuous all-frame deformation or production readiness. Canonical boundary remains external shell over biological upper arm, prosthesis from elbow.

### BREAKER v20 source comparison and independent-shell diagnostic — 2026-10-25 UTC

| Asset | Format / dimensions | Purpose | Status |
|---|---|---|---|
| `docs/visual_qa/BREAKER_T1_v20_vs_candidate01_source_arm_review.png` | PNG RGB, 1180×660 | Approved source shoulder/arm crop beside v20 shell-off rig capture | Review comparison; visible proportions/identity follow the source direction, but the generated shell-off underlay and elbow transition remain unapproved. |
| `docs/visual_qa/BREAKER_T1_candidate01_v20_tapered_underarm_shell_stress_*.png` | PNG RGB, 1280×720 | Baseline, +12 px, +0.16 rad, and shell-hidden diagnostic captures | Ground anchor stable. +12 px exposes underlay; +0.16 rad rotation reveals gaps. This independent-shell transform is diagnostic only; current v20 trial keeps shell and skin on one shoulder bone. Not a production animation test. |
| `docs/visual_qa/BREAKER_T1_candidate01_v20_tapered_underarm_neutral_detail_shell_off_elbow_overlap_visible.png` | PNG RGB, 1280×720 | Shell-off diagnostic retaining the source elbow-overlap slice | Reveals source mechanical overlap above the trial elbow boundary; diagnostic only, not the accepted anatomical view. |

Shell-on source layers remain unchanged; the underlay is fully occluded in the tested source-layer arrangement. Artistic approval of concealed anatomy and elbow transition remains open.

| `tools/art/audit_breaker_candidate01_tapered_underarm_v20.py` | Python / Pillow | Source-layer occlusion and source composite comparison | PASS: 21,434 opaque underlay pixels covered; 0 changed opaque candidate01 shell-on pixels. Hidden anatomy/artistic production approval is not implied. |

### Remote text-status readback — 2026-10-25 UTC

The live Notion Asset Library now records candidate01 v20's local-only status, 21,434-pixel shell-on occlusion audit, zero changed opaque source pixels, focused Godot results, and the open visual/production gate. The live page readback was verified at `2026-10-25T12:15:36.798Z`. No image binary was uploaded; Drive write tools are unavailable in this session.
## CIPHER Tier I reference-cutout profile rig candidate 01 — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_*_REF_CUTOUT_CANDIDATE_01.png` (10 files) | PNG RGBA; sizes recorded in `parts_manifest.json`; 60 px transparent border | Masked visible pixels from approved CIPHER anatomy side turnaround | Quarantined semantic cutout candidates; pivots and hidden overlap are provisional; not runtime art |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png` | PNG RGBA, 540×270 | Hand-authored local vector-style rifle attachment | Separate provisional attachment; weapon details are not canon |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_REFERENCE_CUTOUT_ASSEMBLY_CANDIDATE_01.png` | PNG RGBA, 330×960 | Reassembled semantic cutouts from the reference profile | Neutral assembly review; not production-approved |
| `tests/art/cipher_t1_reference_cutout_rig_candidate.gd` and `tests/art/cipher_t1_reference_cutout_rig_preview.tscn` | GDScript / Godot scene | Godot `Skeleton2D` candidate and part attachment | QA-only; 15 bones, 11 visible texture layers; not loaded by the game |
| `docs/visual_qa/CIPHER_T1_RIG_POSE_REVIEW_CANDIDATE_01.png` | PNG RGB, 1280×720 | Deterministic local pose review renderer | Review board for neutral, walk, aim/fire, and defeat; not a Godot viewport capture |

The local authoring/preview tools are `tools/art/extract_cipher_profile_parts.py`, `tools/art/build_cipher_rifle_candidate.py`, and `tools/art/render_cipher_rig_review.py`. All 10 reference-derived cutouts and the rifle pass the mechanical alpha/margin audit. Neutral silhouette overlap against the extracted reference is 99.4% (803 source pixels missed, zero extra silhouette pixels). This only describes pixel coverage; concealed anatomy, independent joint deformation, far-side coverage, and production readiness remain unverified. No art was promoted into runtime.

## Ten founding-recruit Tier I profile mesh-rig candidates — quarantined — 2026-10-25 UTC

| Local file/group | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/{bulwark,spark,specter,ironclad,stitch,recoil,echo,vector,deadlock,glitch}/tier_01_drafts/profile_mesh_rig_candidate_01/*_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png` | 10 PNG RGBA files, dimensions in per-character manifests; 128 px transparent safety border | Approved per-character anatomy turnaround, right-facing profile crop | Source RGB preserved; flattened profile only; quarantined mesh-rig input, not semantic sprite parts or runtime art |
| `parts_manifest.json` and `rig_manifest.json` in each candidate folder | JSON | Per-character source bounds, alpha bounds, provisional landmarks, rig method, and unresolved gates | Candidate metadata; approximate landmarks are not artist-authored pivots; production art remains not submitted |
| `tests/art/founding_t1_profile_mesh_rig_candidate.gd`; `tests/art/founding_t1_profile_mesh_rig_preview.tscn` | GDScript / Godot scene | Shared 19-bone `Skeleton2D`, per-contour `Polygon2D` meshes, PolyRig geodesic weights | Isolated QA scene only; 10 profiles, 11 contours, 2,937 weighted vertices. Generic poses; not loaded in runtime |
| `tests/art/test_founding_t1_profile_mesh_rigs.gd` | Godot GDScript | Batch test of images, contour meshes, normalized weights, Skeleton2D-relative bone paths, pose-state handling and stable ground root | Godot 4.7.2 headless **PASS** |
| `tests/art/capture_founding_t1_profile_mesh_rig_poses.gd`; `docs/visual_qa/founding_t1_mesh_rig_pose_capture_candidate_01/` | Godot capture script; 60 viewport PNGs + 11 labeled contact boards | Six generic pose transforms for each of ten quarantined mesh candidates | Godot 4.7.2 display-rendered capture **PASS**; visible-pixel and non-neutral-change guards pass for all 60; visual review confirms mesh rendering. Generic transforms only, not authored animations or art approval. |
| `tools/art/extract_founder_profile_rig_inputs.py`; `tests/test_founding_profile_mesh_rig_inputs.py` | Python / Pillow / unittest | Extract each approved side profile without changing source RGB; validate manifests, alpha margins and sampled source pixels | Python validation **PASS**; extraction is not semantic part authoring |
| `docs/visual_qa/FOUNDING10_PROFILE_MESH_INPUT_REVIEW_CANDIDATE_01.png` | PNG RGB, 1200×1000 | Contact sheet of extracted profile inputs | Static extraction review only; preserves visible approved silhouettes |
| `docs/visual_qa/FOUNDING10_MESH_RIG_BONE_LANDMARK_REVIEW_CANDIDATE_01.png` | PNG RGB, 1800×1240 | Provisional per-character bone landmark overlay | Estimated joints only; static QA |
| `docs/visual_qa/founding_t1_mesh_rig_pose_capture_candidate_01/FOUNDING10_MESH_RIG_POSES_OVERVIEW_CANDIDATE_01.png` plus ten `*_POSE_REVIEW_CANDIDATE_01.png` boards | PNG RGB; overview 1200×500, per-character 960×900 | Display-rendered neutral/idle/walk/attack/hit/defeat candidate review | Visual capture and review only; flattened input, approximate landmarks, generic transforms, quarantined |

These candidates use one flattened visible-profile texture per recruit. They do not supply modular evolution parts, concealed/far-side anatomy, authored pivots, detached accessory rigs, or authored animation clips. The mesh deformation now renders in the isolated QA scene, but production-art status remains **NOT SUBMITTED** for all ten.

## Authoring tools

| Local file | Format / version | Purpose | Status |
|---|---|---|---|
| `addons/poly-rig/` (source copy: `poly-rig-plugin-v0.9.3-EA/addons/poly-rig/`) | Godot editor add-on, package metadata 0.9.3 Early Access | 2D mesh generation and bone-weight authoring for `Polygon2D` / `Skeleton2D` | Godot 4.7.2 headless editor startup loads the active add-on after excluding the duplicate packaged copy from scanning. Geometry/weight smoke test passes. The add-on startup banner says 0.9.2, so exact version is unresolved. Initial tooling checkpoint; subsequent work uses its algorithms in quarantined visible-profile candidates documented below. No character art was promoted. |
| `tests/art/test_polyrig_geometry_smoke.gd` | Godot GDScript | Seven-vertex body-shaped triangulation and two-bone weight normalization | Godot 4.7.2 headless **PASS**. Algorithm feasibility only; not visual character-rig validation. |
| `poly-rig-plugin-v0.9.3-EA/addons/poly-rig/.gdignore` | Godot project scan marker | Prevent duplicate global script classes from the retained package copy | Local non-destructive scan exclusion; source package files remain present. |

| `addons/phantom_camera/` | Godot editor add-on, Phantom Camera v0.11.0.3 (MIT; tag commit `cb6e0966ac305202c47f1d1a81c105966e29da96`) | 2D/3D camera following, framing, and transitions | Enabled through `project.godot` for evaluation; Godot editor load not yet validated. Tooling only; no game scenes were changed. Free. |

| `tests/presentation/zone_transition_prototype_01/` | Godot scene + GDScript test harness | Isolated camera handoff and existing environment palette crossfade prototype | QA-only. Focused Godot 4.7.2 headless check passes; no main scene/runtime integration or production environment art. See `docs/ZONE_TRANSITION_PRESENTATION_PROTOTYPE_01.md`. |
| `docs/ZONE_TRANSITION_PRESENTATION_PROTOTYPE_01.md` | Markdown | Prototype scope, architecture, test evidence, and limitations | Local prototype report; provisional fixtures only. Not a canonical zone or pacing decision. |

## Image-generated semantic-part sheet experiments — quarantined — 2026-10-25 UTC

Exploratory PNG sheets for BREAKER (candidates 01 and cleanup 02), BULWARK, CIPHER, and SPARK are stored under each character's 	ier_01_drafts/imagegen_semantic_parts_candidate_01/ folder. They fail the alpha/margin audit and have unresolved semantic/component mapping. See BREAKER's README_QUARANTINED.md. Do not import, upload as production art, or use as rig inputs. These are review evidence only.



## CIPHER Krita part-authoring workspace 01 - 2026-10-25

Created a quarantined OpenRaster workspace at `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/krita_authoring_workspace_01/`. It contains the approved side-profile crop as the visible reference, ten separately aligned candidate cutout layers (hidden initially), and a transparent inferred-underpaint layer. The approved reference and existing cutout PNGs were not changed. This is a manual-review aid; semantic ownership, hidden anatomy, pivots, and animation quality remain unverified.

Validation: OpenRaster structure, layer count/visibility, 330x960 canvas registration, PNG decoding, and merged preview passed a Python round-trip check. Krita visual-open verification passed in the follow-up below; individual layer/art review remains pending. The workspace is quarantined and is not runtime content.


## CIPHER Krita authoring workspace 01 - quarantined

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/krita_authoring_workspace_01/CIPHER_T1_PART_AUTHORING_WORKSPACE_01_QUARANTINED.ora` | OpenRaster; 330x960; 12 aligned layers | Approved CIPHER side-profile crop plus the ten existing manifest cutouts | Krita open verified; body layers hidden by default; art review and production gates **NOT VERIFIED**; quarantined; not runtime |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_CARRIED_RIFLE_REF_CUTOUT_CANDIDATE_01.png` | PNG RGBA; 138x476 | Unmapped reference crop found outside the current part manifest | Zero transparent margin; not used by the rig; quarantined and excluded from authoring workspace |

The independently tested `CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png` remains the rifle attachment in the review rig. The unmapped crop above is not its replacement.


## CIPHER semantic remap candidates 02-03 and diagnostic boards - 2026-10-25

| Local file/group | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_02/` | 10 RGBA cutouts + manifest + 330x960 assembly | Manual polygon masks over approved profile | **REJECTED** after assembly missed 5,021 core silhouette pixels (96.25% coverage); quarantined; no runtime use |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_03/` | 10 RGBA cutouts + manifest + 330x960 assembly | Revised manual polygon masks over approved profile | Mechanical alpha/margin **PASS**; neutral source coverage 99.63%; semantic/visual/pivot/deformation gates **NOT VERIFIED**; quarantined |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_03/krita_authoring_workspace_03/CIPHER_T1_PART_AUTHORING_WORKSPACE_03_QUARANTINED.ora` | OpenRaster; 330x960; 12 aligned layers | Approved source profile + candidate-03 cutouts | Structural round-trip **PASS**; Krita visual-open check deferred until after 5 p.m. Chicago time; quarantined |
| `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_01_QUARANTINED.png` | PNG, 1200x1530 | Candidate-01 manifest cutouts | Diagnostic evidence; exposes mapping contamination; not art |
| `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_02_QUARANTINED.png` | PNG, 1200x1530 | Candidate-02 cutouts | Diagnostic evidence; candidate 02 rejected |
| `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_03_QUARANTINED.png` | PNG, 1200x1530 | Candidate-03 cutouts | Diagnostic only; requires detailed review |
| `docs/visual_qa/CIPHER_T1_PROFILE_COORDINATE_GRID_DIAGNOSTIC_01.png` | PNG, 660x1920 | Approved CIPHER profile crop | Coordinate aid for hand-authored mask review |

Candidate 01's five focused Python tests and Godot reference rig test pass but do not validate semantic mapping. Candidate 03's ten part files pass only the mechanical alpha/margin checks. No production art or runtime rig is approved.


## CIPHER semantic part-audit tooling - 2026-10-25

| Local file | Type | Scope | Readiness |
|---|---|---|---|
| `tools/art/audit_cipher_profile_part_candidate.py` | Python/Pillow audit | Per-part alpha/margins plus assembled source-silhouette coverage for CIPHER reference cutout candidates | Mechanical only; never approves semantic mapping, pivots, animation, or production art |
| `tests/test_cipher_profile_part_candidate_audit.py` | Python unittest | Candidate 01/02/03 expected mechanical dispositions | **PASS** 3/3; candidate 02 reject and candidates 01/03 review-required |

Threshold: 99% source-core coverage is a provisional audit cutoff, not a design or production decision. Candidate 03 achieves 99.63% coverage and remains quarantined pending human visual review.


The complete local Python suite passed 37/37 after adding the CIPHER mechanical gate test. The focused Godot cutout rig test passed on candidate 01 only; candidate 03 remains unrigged and unreviewed.


## CIPHER remap candidate 04 - awaiting Krita review

| Local file/group | Format / dimensions | Evidence | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04/` | 10 RGBA cutouts + manifest + 330x960 assembly | Manual masks over approved side profile | Alpha/margins **PASS**; thresholded source coverage **100%** (0 missing/extra); PREVIEW_SCREEN_FAIL; retained as quarantined diagnostic only; do not rig; no full-resolution Krita review |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04/krita_authoring_workspace_04/CIPHER_T1_PART_AUTHORING_WORKSPACE_04_QUARANTINED.ora` | OpenRaster, 330x960, 12 aligned layers | Approved source profile and candidate 04 cutouts | Structural round-trip **PASS**; retained for workspace inspection only after the preview-screen failure; not production or runtime |
| `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_04_QUARANTINED.png` | PNG, 1200x1530 | Ten candidate 04 semantic labels | Diagnostic only; semantic overlap/boundary review still required |
| `tools/art/extract_cipher_profile_parts_candidate_04.py` | Python/Pillow | Candidate 03 polygons plus targeted gaps found by coverage audit | New quarantined candidate generator; no source changes |

The CIPHER part audit and regression suite now cover candidate 04; its test confirms full mechanical coverage while explicitly keeping visual review required.

| `tools/art/build_krita_authoring_workspace.py` | Python tool | Manifest-driven OpenRaster authoring workspace builder | Supports non-destructive candidate workspaces; tested on candidate 01/04 manifests; does not certify semantic correctness |
| `tests/test_krita_authoring_workspace_builder.py` | Python unittest | ORA layers/registration/overwrite guard | **PASS** 3/3; candidate 04 12 layers / 10 hidden parts; candidate 01 negative crop offsets preserved |

## Validation delta - 2026-10-25

The OpenRaster builder regression suite now passes 7/7. It verifies workspace registration and no-overwrite behavior, and rejects project/candidate path escapes, out-of-bounds source crops, and source-bbox/alpha-bound mismatches. The full Python suite passes 45/45. The Godot all-ten profile-mesh structural check passes, but confirms only reusable skeleton/mesh mechanics; no semantic modular rig or production-ready art is established.

## Current roster and CIPHER audit state - 2026-10-25

Roster preflight confirms all 12 have local reference/candidate inventory and shared review gates, but this is not proof of twelve production rigs. Ten Godot profile-mesh candidates pass structural checks as flattened visible-profile mesh tests. CIPHER candidate 04 passes mechanical source coverage and alpha/margins only; semantic review and rigging are pending. The audit CLI now runs directly from the project root.

| CIPHER candidate workspaces | OpenRaster build compatibility | Candidates 01-04 | **PASS** aligned 330x960 layers for both manifest placement schemas; this is packaging/registration evidence only, not semantic or production approval |

## Godot import exclusion boundary - 2026-10-25

All 12 per-character tier_01_drafts folders now contain .gdignore. This excludes quarantined candidate textures/workspaces from Godot's automatic import scan while retaining raw-file access for explicit review tests. The roster test verifies coverage; CIPHER and all-ten Godot tests pass after the change. No draft asset has been promoted to runtime.

## Import-scan readback - 2026-10-25

Godot 4.7.2 headless Editor scan completed successfully after adding the twelve .gdignore markers. The Editor cache contains no tier_01_drafts path references. Ninety-eight pre-existing ignored .import sidecars remain in draft folders; no deletion was needed and none was performed. Explicit Godot raw-file review tests continue to pass.

## CIPHER semantic remap candidate 05 - quarantined review candidate

| Local artifact | Format / dimensions | Evidence | Readiness |
|---|---|---|---|
| assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/ | Ten RGBA cutouts + manifest + 330x960 assembly | Candidate 04 polygons with backpack mask excluding head/hood ownership | Alpha/margins PASS; thresholded silhouette coverage 100%; overlapping-owner pixels 4,549 (candidate 04: 9,205); semantic review NOT_REVIEWED; quarantined, not rig input |
| assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/krita_authoring_workspace_05/CIPHER_T1_PART_AUTHORING_WORKSPACE_05_QUARANTINED.ora | OpenRaster 330x960, 12 layers | Approved profile reference, blank inferred-underpaint and ten hidden candidate cutouts | Structural builder test PASS; not opened in Krita; candidate remains unreviewed |
| docs/visual_qa/CIPHER_T1_PART_OWNERSHIP_MAP_04_QUARANTINED.png | PNG 990x1060; native 330x960 source crop | Candidate 04 ownership visualization | Diagnostic; 9,205 shared-owner pixels; does not validate semantics |
| docs/visual_qa/CIPHER_T1_PART_OWNERSHIP_MAP_05_QUARANTINED.png | PNG 990x1060; native 330x960 source crop | Candidate 05 ownership visualization | Diagnostic; 4,549 shared-owner pixels; semantic correctness NOT_VERIFIED |
| tools/art/extract_cipher_profile_parts_candidate_05.py | Python/Pillow | Reproducible single-boundary revision | Creates new candidate only; refuses overwrite; does not approve art |
| tests/art/test_cipher_candidate_05_cutouts.gd | Godot headless | Raw file read, dimensions, safety corners, quarantine metadata | PASS; no rig or deformation test |


Candidate-05 ownership map pairwise report: the candidate-04 backpack/head-hood pair had 4,525 shared pixels; candidate 05 records zero for that pair. The board still reports 4,549 total multiply-owned pixels across the remaining pairs. These are diagnostic counts only; joint overlap can be intentional and semantic correctness is NOT_VERIFIED.

## CIPHER candidate 05 - preliminary alpha-checkerboard screen fail - 2026-10-25

| File | Format / dimensions | Evidence | Readiness |
|---|---|---|---|
| `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_05_QUARANTINED.png` | PNG, 808x2896; ten cutouts composited over explicit checkerboard at source pixel scale | Native-resolution file preview | Preliminary semantic screen **FAIL**; the contact sheet flags the incomplete `near_thigh` and detached strip in `torso_jacket`; `pelvis_belt_gear` also needs review |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/` | Ten RGBA cutouts + manifest + 330x960 assembly | Approved right-facing anatomy turnaround; manual masks | Mechanical **PASS** (100% thresholded coverage, 0 missing/extra, 10/10 alpha/margin); semantic `PREVIEW_SCREEN_FAIL`; quarantined diagnostic only, not rig input |

The visible checkerboard in the review board is a transparency visualization, not pixels in the source files. This preliminary screen does not replace the full Krita layer review. No candidate pixels changed; hidden/far-side anatomy, pivots, and deformation remain unverified. This current disposition supersedes earlier candidate-05 notes that said semantic review was `NOT_REVIEWED`; the full-resolution Krita review remains `NOT_VERIFIED`.
# Rig review tooling

tests/art/rig_review_workbench.tscn is a manual, quarantined-candidate review tool. It creates no production assets and does not change asset readiness. Current adapters cover the ten flattened profile-mesh preflights and the CIPHER cutout candidate; BREAKER and remaining candidates continue through their existing review scenes. Godot 4.7.2 startup and the initial BULWARK display were visually checked; pose-sheet capture and other adapters remain unverified.

## Twelve-character roster preview

docs/visual_qa/FOUNDING_ROSTER_GAME_SCALE_PREVIEW_01.png is a Godot-rendered, 4×3 Tier I roster mockup. It uses ten quarantined mesh candidates, the quarantined CIPHER cutout candidate, and BREAKER's approved static reference. It is a presentation/review image only and does not replace sprites, establish animation readiness, or change any asset status. Godot 4.7.2 rendered the scene and the image was visually inspected.


## Equipment function requirement reaffirmed — 2026-10-25 UTC

The user confirmed that character weapons, accessories, cyberware, tethers, and drones must function as designed, not merely appear in art. This is an acceptance requirement for both rig/presentation integration and authoritative simulation behavior. Existing roster-backed examples and unresolved mechanics remain in `ATTACHMENT_FUNCTION_CONTRACT.md`; no character-specific equipment behavior is newly implemented by this confirmation.

## Quarantined authoring and prop-review assets — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_01_BLUE_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png` | PNG RGBA, 392×321 | `docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png` | Reference-derived static cutout; alpha screen PASS; pivots/hidden surfaces/animation NOT VERIFIED; quarantined |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_02_RED_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png` | PNG RGBA, 342×296 | Same approved SPARK anatomy reference | Reference-derived static cutout; alpha screen PASS; pivots/hidden surfaces/animation NOT VERIFIED; quarantined |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/SPARK_T1_ATTACK_DRONE_03_AMBER_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png` | PNG RGBA, 322×311 | Same approved SPARK anatomy reference | Reference-derived static cutout; alpha screen PASS; pivots/hidden surfaces/animation NOT VERIFIED; quarantined |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/candidate_manifest.json` | JSON | Same approved SPARK anatomy reference plus explicit crop/object/background seeds | Provenance and per-item alpha bounds/seeds/hashes recorded; animation, production, runtime gates false |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/README_QUARANTINED.md` | Markdown | Candidate manifest and authoring guide | Review-only instructions; no production claims |
| `assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01/source_fidelity_report.json` | JSON | Candidate files + approved source image | Actual-item audit PASS: exact source RGB preserved, zero inter-mask overlap, mechanical alpha PASS; semantic/pivot/animation/production gates false |
| `tools/art/extract_reference_prop_candidate.py` + `tools/art/spark_drone_cutout_candidate_01.json` | Python/Pillow + JSON | Explicit source crop/object/background seeds | Reproducible extraction helper; emits only quarantined static review candidates |
| `tools/art/audit_reference_prop_candidate.py` | Python/Pillow | Candidate manifest and referenced source | Verifies source/hash fidelity, non-overlap, safety margin and alpha; never approves production |
| `tests/test_extract_reference_prop_candidate.py` | Python unittest | Synthetic color-field/reference fixtures | 5/5 focused tests pass; checks source ownership, tamper detection, alpha isolation, output containment and quarantine flags |
| `tests/test_runner.gd` | Godot GDScript test | `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; source-backed SPARK three-drone role | Test coverage only: routes one authoritative attack event to three separate placeholder receivers; no character art or production drone behavior exists |
| `tools/art/export_reviewed_openraster_parts.py` | Python / Pillow / OpenRaster ZIP | Explicit semantic layer selection JSON and edited `.ora` | Exports non-empty selected layers at source-canvas alignment into the character's Tier I draft quarantine; writes review metadata only, not production art |
| `tests/test_export_reviewed_openraster_parts.py` | Python unittest | Synthetic `.ora` fixtures and all 12 current edit workspaces | 12/12 focused checks pass; blank equipment layer exports are refused across all twelve actual workspaces; validates alignment, negative offsets, weapon/cable/drone metadata, owner IDs, unique part IDs, shared attachment roles across visual components, opacity, safe layer selection, and quarantine boundaries |

The twelve batch OpenRaster authoring workspaces still contain blank art layers, so no edited part PNGs were exported from those workspaces. CIPHER candidate 06 is a separate source-derived masked review iteration and has not been promoted to production or runtime.

## SPARK drone mesh-input regression — quarantined — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `tests/test_runner.gd` + `tools/art/polyrig_contour_mesh_builder.gd` | Godot GDScript | Three quarantined SPARK drone PNGs and installed PolyRig utility | Full Godot 4.7.2 headless PASS: each cutout builds one textured `Polygon2D`, keeps pixel-aligned UVs and triangulated faces; structural mesh-input check only |

This does not resolve the front-view versus side-view presentation mismatch or establish semantic completeness, pivots, animation, combat behavior, runtime integration, or production readiness. All three PNGs remain quarantined.

## CIPHER candidate 07 intake regression — quarantined — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `tests/test_runner.gd` (`_test_cipher_candidate_07_intake`) | Godot GDScript | Candidate 07 manifest, ten quarantined cutouts, source reference, and neutral assembly | Full Godot 4.7.2 headless suite PASS: validates file/manifest integrity and that semantic/production gates remain false; does not certify semantic correctness or a rig |

Candidate 07 itself remains **QUARANTINED / NOT RIG INPUT**. The automated test intentionally requires `semantic_review_status: NOT_VERIFIED` and `production_approved: false` until the visual review is complete.

## Repeatable all-character art-pipeline validation — 2026-10-25 UTC

| Local file | Format | Scope | Readiness |
|---|---|---|---|
| `tools/art/validate_character_art_pipeline.ps1` | PowerShell | Full Python suite, all-12 workspace audit, Godot full suite | End-to-end **PASS**: 85 Python tests, all twelve ORA/source/layer/quarantine checks, and Godot 4.7.2 suite with ten profile mesh preflights plus CIPHER/SPARK asset checks |

The command validates prep structure and testable mesh inputs only. It does not certify production rigs or promote any candidate art.

## CIPHER candidate 06 — leg seam overlap review — 2026-10-25 UTC

| Local file | Format / dimensions | Source / evidence | Readiness |
|---|---|---|---|
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/` | Ten RGBA part cutouts with 60 px safety padding; 330×960 aligned neutral assembly | Approved CIPHER side-profile anatomy turnaround; revised candidate-05 polygon ownership/draw order | Quarantined review candidate. Mechanical alpha and 100% silhouette coverage pass; semantic review, pivots, hidden anatomy, and deformation NOT VERIFIED |
| `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06/CIPHER_T1_PART_AUTHORING_WORKSPACE_06_QUARANTINED.ora` | OpenRaster, 330×960, 12 layers | Candidate 06 parts plus visible reference crop; generated by `tools/art/build_krita_authoring_workspace.py` | Opened in Krita; ten cutout layers hidden initially; editable review aid, not approved art |
| `tools/art/extract_cipher_profile_parts_candidate_06.py` | Python/Pillow | Candidate-05 source masks plus explicit leg draw order/overlap | Reproducible new candidate generator; refuses overwrite; no art approval |
| `tools/art/render_semantic_part_contact_sheet.py` | Python/Pillow | Named part entries in a confined candidate manifest | Native-scale checkerboard diagnostic; refuses overwrite; semantic review remains NOT_VERIFIED |
| `docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_06_QUARANTINED.png` | PNG 730×3558 | Candidate 06's ten named transparent cutouts | Native-scale individual layer screen; extended thigh crop visible; 882px torso island provisionally tracks rear jacket outline; semantic status remains NOT VERIFIED |
| `docs/visual_qa/CIPHER_T1_PART_OWNERSHIP_MAP_06_QUARANTINED.png` | PNG 990×1060 | Candidate 06 masks over approved profile crop | Diagnostic records 9,869 multiply-owned pixels including intentional joint overlap; labels remain unverified |
| `tests/art/test_cipher_candidate_06_cutouts.gd` | Godot 4.7.2 headless | Candidate manifest, ten part PNGs, neutral assembly | PASS raw-file intake and quarantine checks; no rig/deformation validation |
| `tests/test_render_semantic_part_contact_sheet.py` | Python unittest | Synthetic RGBA parts | 2/2 PASS; verifies native dimensions, review-only status, and no-overwrite behavior |

Measured thresholded shared pixels: near thigh/shin **3,520**; near shin/boot **1,800**. The neutral assembly retains 100% of the source core. The contact sheet makes all ten pieces individually inspectable at native scale and confirms the thigh extension visually. The 882px secondary torso island maps to the rear jacket outline in the approved profile and remains provisionally in that part; the semantic review remains NOT_VERIFIED. Candidate 06 is excluded from runtime.
## Alpha-island semantic-review diagnostic — 2026-10-25 UTC

Updated `tools/art/audit_semantic_cutout.py` and `tools/art/audit_cipher_profile_part_candidate.py` to include four-connected alpha-component counts/areas and the secondary-to-main component ratio in per-part reports. The alpha audit now also returns each island's exclusive pixel bounds so reviewers can map a component to a source crop using manifest bounds and padding. This is diagnostic metadata only; existing art assets were not changed or promoted. CIPHER candidate 05 remains quarantined after its visual semantic screen failure. Focused unit tests pass 7/7; full Python suite passes 79/79; all-12 workspace audit passes.

## CIPHER candidate 07 - quarantined mast-ownership revision - 2026-10-25 UTC

`assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07/` contains ten source-derived visible-profile cutouts, a 330x960 neutral assembly, manifest, README, and candidate-specific OpenRaster authoring workspace. The revision transfers the visible signal mast/top cap/tube from the head composite to the backpack layer, based on the approved CIPHER turnaround. Candidate 06 remains preserved. The candidate 07 contact sheet and ownership overlay are under `docs/visual_qa/`.

The mechanical audit reports 133,741/133,741 source-core pixels covered, zero missing/extra pixels, and ten alpha/margin passes. The Python source-pixel ownership regression and Godot 4.7.2 raw-file intake pass. Candidate status remains `QUARANTINED`, semantic review is `NOT_VERIFIED`, and `production_approved` is false. The detached torso-detail island, remaining overlap ownership, hidden/far-side anatomy, authored pivots, deformed seams, and full editor review are unresolved. These are visible-reference cutouts, not complete animation-ready parts.

## CIPHER candidate 08 - hand/jacket continuity study - 2026-10-25 UTC

`assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_08_hand_jacket_underpaint/` is a new, quarantined review candidate built from candidate 07. Candidate 07 already assigns the visible near hand exclusively to `near_hand`; a read-only source-alpha check finds zero shared hand pixels in `pelvis_belt_gear` or `torso_jacket`. Candidate 08 preserves those parts and adds `CIPHER_T1_JACKET_UNDER_HAND_INFERRED_CANDIDATE_08_QUARANTINED.png`, a flat charcoal underpaint confined to the current hand footprint and drawn behind `near_hand`. This surface is inferred from the user's approved ownership interpretation because the flattened source does not reveal it. Neutral assembly: `CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_08_QUARANTINED.png`. It is a continuity placeholder only: no texture, pivot, motion coverage, semantic approval, or production status is claimed. Candidate 07 and canonical source art are unchanged; neither draft is runtime art.

The user accepted this underpaint approach for now at the intended display scale, expecting it to be nearly invisible. This is a scoped review disposition only. Gameplay-scale captures and motion exposure review remain outstanding; candidate 08 remains quarantined.

Candidate 08 static review evidence: normalized 256 px visible-height preview at `docs/visual_qa/CIPHER_T1_CANDIDATE_08_ISOLATED_SCALE_1280x720_QUARANTINED.png` and 800×450 downscale; native semantic contact sheet `CIPHER_T1_PARTS_CONTACT_SHEET_08_QUARANTINED.png`; ownership map `CIPHER_T1_PART_OWNERSHIP_MAP_08_QUARANTINED.png`; and knee-boundary decision board `CIPHER_T1_CANDIDATE_08_KNEE_BOUNDARY_REVIEW_QUARANTINED.png`. The user approved a separate `near_knee_guard`; candidate 09B below implements the scoped split. The static reference-scale preview is not an in-engine animation or gameplay-size pass.

## CIPHER 09B duplicate-only ORA package audit — quarantined — 2026-10-26 UTC

- Added `assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/krita_roundtrip_workspace_09b_03_DISPOSABLE/CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_ROUNDTRIP_03_DISPOSABLE.ora` as a disposable copy only. The copy and preserved authoring ORA are 1,198,184 bytes and byte-identical, SHA-256 `A54597C5A486B881CC201CC0AE063FB017F0D26331149F3B3829513DFA91B2B8`.
- Read-only package checks: ZIP CRC valid; 18 entries; `stack.xml` and embedded manifest agree on 330×960 canvas and 13 layer names; all 13 layer PNG entries are referenced and have matching canvas dimensions; the 11 named art layers match candidate part IDs; the four-part selection references existing layers and excludes hidden inferred underpaint.
- **Krita save/reopen remains unverified:** Krita showed `Not Responding` when opening the duplicate; no saved/reopened file or pixel/alpha/boundary comparison exists. The ORA embedded source-manifest pointer (`43C735DAA7B57D3F214C818151D3ECB24C1D60B3192EF204B668554DE7E1D9E3`) differs from the current neighboring `parts_manifest.json` hash (`D717FB49E45C4DE79E88F50CF4F406EE343583E354FCF50F05BF2019D707EA16`). This pointer mismatch is recorded for provenance reconciliation; neither ORA nor manifest was repaired. All art remains quarantined.

## CIPHER candidate 09B - separate knee guard review - 2026-10-25 UTC

`assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/` contains an 11-part quarantined draft with a separate `near_knee_guard` layer. The user approved the owner split and traced raster edge: front armor plate/red optic and upper side lug belong to the guard; lower round hinge/wrap straps stay with the leg layers. It uses existing source RGB and the neutral composite is pixel-identical to candidate 08. The approved pivot at source pixel `(770, 665)` is authored at guard-part pixel `(77, 115)` in `parts_manifest.json`. The user also approved the separate v04 inferred trouser underpaint for the flex-exposed knee gap. It remains a quarantined review layer, excluded from neutral/runtime art. The isolated patch and rigid-cutout bend review are `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_ISOLATED_04_QUARANTINED.png` and `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_BEND_REVIEW_04_QUARANTINED.png`. A Godot 4.7.2 Compatibility `Sprite2D` capture with the approved fill at 0°, 12°, and 20° is `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_GODOT_MOTION_02_QUARANTINED.png`; neutral knee crop reconstruction was exact (0/70,000 differences). These are rigid transform previews, not deformation validation; this remains quarantined and is not runtime art.

## Editor tool startup note — 2026-10-25 UTC

Godot 4.7.2 loads PolyRig 0.9.2 Early Access. The Phantom Camera editor plugin also requires the `PhantomCameraManager` autoload, now present in `project.godot`; startup no longer logs singleton errors. A TLS error from the plugin's update-check path remains. No art binaries changed in this validation. All candidate and reference classifications remain as listed above; candidate work stays quarantined.

## CIPHER candidate 07 visual evidence note — 2026-10-25 UTC

Review of the quarantined source-profile assembly and visual diagnostics against the approved concept/anatomy references finds that the visible neutral silhouette is retained, while a detached narrow torso/jacket-outline fragment (882 alpha pixels in the prior component audit) and 9,869 multiply-owned source pixels still need semantic ownership review. Treat these as unresolved candidate findings, not automatic acceptance/rejection. Candidate remains quarantined; no edits, pivots, rig promotion, or production-art change occurred.
- Candidate 07 part-level audit evidence: all ten manifest-listed PNG parts pass provisional mechanical alpha/margin/halo checks, and the neutral source-profile assembly has 100% thresholded source coverage with no missing/extra pixels. The assembly itself is not a per-part cutout and is excluded from the part-margin gate. This does not resolve the detached torso island, semantic ownership, pivots, far-side anatomy, deformation, or production status.

## CIPHER candidate 07 PolyRig contour readiness — 2026-10-25 UTC

The Godot suite now tests the actual ten manifest-listed cutouts through alpha-contour extraction and independent PolyRig triangulation. Four images are multi-contour and require separate `Polygon2D` meshes/ownership handling. The `backpack_mount` image yields 8 contours but only 2 triangulate; the remaining six are a source-art review block, not automatically discarded noise. This geometry preflight is separate from semantic validation. Candidate 07 remains `QUARANTINED / NOT_VERIFIED`, with no pivots, deformation approval, or production runtime art.
- CIPHER backpack contour diagnostic locations (candidate image coordinates, 215×582 PNG): #1 `(154,71)-(155,72)`, #2 `(151,75)-(152,76)`, #3 `(152,73)-(153,75)`, #4 `(153,72)-(154,73)`, #5 `(150,77)-(151,78)`, #7 `(138,518)-(139,522)`. Each produced four points but no triangulation. They are review coordinates only; do not infer that these pixels are disposable.
- Review overlay: `docs/visual_qa/CIPHER_T1_BACKPACK_POLYRIG_CONTOUR_DIAGNOSTIC_01_QUARANTINED.png` marks the six non-triangulating contours on the intact, quarantined backpack cutout. It is a diagnostic image, not an edited asset or approval.

## CIPHER candidate 07 hand/jacket semantic interpretation — 2026-10-25 UTC

Candidate 07's manifest now explicitly records the user-approved near-hand ownership: visible hand pixels belong to foreground `near_hand`, the jacket continues behind the hand, and the hand pixels must not belong to `pelvis_belt_gear`. No hidden jacket underpaint has been authored; if added later for articulation it must be labeled inferred from concealed source. A Python regression verifies draw order and that the hand mask has zero shared source-core pixels with pelvis/torso while retaining overlap with the near forearm. Candidate remains `QUARANTINED / NOT_VERIFIED`; no art pixels changed.
## CIPHER candidate 07 contour mesh builder update — 2026-10-25 UTC

The new review-only Godot helper `tools/art/polyrig_contour_mesh_builder.gd` creates separate textured `Polygon2D` nodes for every alpha contour while retaining the existing semantic parent. The integrated candidate-07 preflight now builds all contours in all ten images; `backpack_mount` is 8/8 PolyRig-triangulatable. Four part images remain multi-contour and require semantic ownership review. This does not add or change artwork and does not establish pivots, weights, hidden anatomy, deformation, or production status. All candidate-07 art remains `QUARANTINED / NOT_VERIFIED`.

## CIPHER candidate 07 rendered contour-mesh diagnostics — 2026-10-25 UTC

| File | Format | Purpose / readiness |
|---|---|---|
| `tests/art/capture_cipher_candidate_07_contour_mesh_fidelity.gd` | Godot script | Normal-renderer-only static comparison of the approved profile crop, candidate assembly, and per-contour mesh assembly. Reports bounded sampled color differences; no art or rig gate is passed. |
| `docs/visual_qa/CIPHER_T1_CANDIDATE_07_POLYRIG_MESH_ASSEMBLY_01_QUARANTINED.png` | PNG | Initial 0.55× comparison; its sampled pixel difference exceeded the provisional 1% gate and it is superseded. Diagnostic only. |
| `docs/visual_qa/CIPHER_T1_CANDIDATE_07_POLYRIG_MESH_ASSEMBLY_02_QUARANTINED.png` | PNG | 0.5× comparison board associated with the passing 531 / 79,200 (0.67045%) sampled difference result. Quarantined review evidence, not runtime art. |

The same normal-renderer diagnostic compares every part texture against its contour meshes at native scale. All ten are below the provisional 1% difference bound; `torso_jacket` is the highest at 0.18492%. All parts have zero differing pixels in fully opaque interior regions. Remaining raster differences occur on semitransparent or alpha-edge-adjacent pixels. This does not establish semantics, pivots, weights, hidden anatomy, deformation, or art approval.


## SPARK drone mesh render diagnostic — quarantined QA evidence — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `tests/art/capture_spark_drone_contour_mesh_fidelity.gd` | Godot GDScript | Three quarantined SPARK drone PNGs and shared PolyRig contour builder | Normal-renderer comparison completed; static mesh input only |
| `docs/visual_qa/SPARK_DRONE_POLYRIG_MESH_FIDELITY_01_QUARANTINED.png` | PNG 1280×720 | Native-scale Godot 4.7.2 render comparison | Quarantined diagnostic board; source/mesh pairs visually align |

Measured pixel differences are 0.09695%, 0.08792%, and 0.10186% for drones 01–03; each had zero differing fully opaque interior pixels under the diagnostic's sampling method. This does not pass semantic, side-view, pivot, articulation, runtime, or production gates. The original reference-derived drone art is unchanged and remains quarantined.

## CIPHER candidate 09B routine contour-mesh preflight — quarantined — 2026-10-25 UTC

| Local file | Format | Source | Readiness |
|---|---|---|---|
| `tests/test_runner.gd` (`_test_cipher_candidate_09b_mesh_inputs`) | Godot 4.7.2 headless | Eleven candidate-09B parts and `parts_manifest.json` | PASS: all 11 build through `PolyRigContourMeshBuilder`; all detected contours use PolyRig with no Geometry2D fallback |

The test checks part dimensions, unique manifest files, draw-order membership, the separate knee-guard part, and that the candidate remains quarantined. It preserves `PARTIAL_USER_APPROVAL; RASTER_AND_RIG_REVIEW_OPEN`: only the knee-guard owner interpretation is approved. The exact source mask, pivots, deformation, hidden anatomy, and production gate remain open; no runtime art is claimed.

## CIPHER candidate 09B normal-render mesh comparison — quarantined QA — 2026-10-25 UTC

| Local file | Format / scope | Result / readiness |
|---|---|---|
| `tests/art/capture_cipher_candidate_07_contour_mesh_fidelity.gd` | Godot 4.7.2 Compatibility renderer; supports candidate 07 and 09B | Candidate 09B source-aligned composite differs by 544/79,200 (0.68687%) at 0.5×; all eleven native-scale parts are below 1%, with zero fully opaque interior differences |
| `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_POLYRIG_MESH_ASSEMBLY_01_QUARANTINED.png` | PNG 1280×720 | Three-panel approved profile, candidate assembly, contour-mesh render; diagnostic only |

These checks show static raster fidelity, not semantic correctness, a visually accepted knee edge, pivots, hidden anatomy, or deformation. Candidate 09B stays quarantined and is not runtime/production art.

## CIPHER candidate 09B Godot knee-underpaint preview approval — 2026-10-25 UTC

The user approved the knee-joint underpaint update as shown in the Godot motion-02 review capture (docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_GODOT_MOTION_02_QUARANTINED.png). This approval is scoped to that review presentation; the inferred layer remains quarantined and excluded from neutral/runtime art. The capture uses rigid transforms and does not validate deformation or production readiness.
## Manual traced-polygon helper and IRONCLAD cable cutout — 2026-10-25 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `tools/art/extract_traced_reference_parts.py` | Python / Pillow helper | Explicitly traced polygons over source image | Source-pixel cutouts only; records hashes and quarantine flags; does not infer anatomy, pivots, or hidden fill |
| `tools/art/ironclad_back_cable_candidate_01.json` | JSON trace manifest | IRONCLAD source-preserving visible profile; upstream registration to approved anatomy turnaround recorded | One manually traced U-shaped cable loop; coordinates remain candidate-only |
| `assets/characters/ironclad/tier_01_drafts/attachment_cutout_candidate_01/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01.png` | PNG RGBA, 605×1206; alpha bounds `[190,598,259,649)`; 781 nonzero-alpha pixels | Exact visible source pixels from registered profile candidate | Quarantined cutout; endpoints, mounts, pivots, deformation, and behavior unverified |
| `assets/characters/ironclad/tier_01_drafts/attachment_cutout_candidate_01/parts_manifest.json` | JSON | Source/upstream hashes and traced polygons | Quarantined; production, semantic, pivot, deformation, and runtime flags are false |
| `docs/visual_qa/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01_QUARANTINED.png` | PNG visual QA board | Source profile detail and traced cutout on checkerboard | Diagnostic only; not runtime/production art |
| `tests/test_ironclad_cable_candidate.py`, `tests/art/test_ironclad_cable_cutout.gd` | Python / GDScript tests | Source registration, 781-pixel bounds, Godot loading | PASS for source-pixel identity and static resource loading only |

## SPECTER and STITCH equipment intake reviews — quarantined — 2026-10-25

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `assets/characters/specter/tier_01_drafts/attachment_decomposition_02/EQUIPMENT_REVIEW_02_QUARANTINED.md` | Markdown | Approved concept/anatomy views and attachment function contract | Source review only; sword-grip, cape-occlusion, and hood/mask neck overlap unresolved; no cutouts |
| `assets/characters/stitch/tier_01_drafts/attachment_decomposition_02/EQUIPMENT_REVIEW_01_QUARANTINED.md` | Markdown | Approved concept/anatomy views and attachment function contract | Source review only; case/vial grip boundaries, coat panels, and back-assembly ownership unresolved; no cutouts |

## Source polygon authoring tool — 2026-10-26 UTC

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `tools/art/trace_part_authoring.py` | Python / Tkinter / Pillow | Manually traced approved source-image points in project coordinates | Authoring aid only; no image or pivot generation; exported data remains quarantined |
| `tests/test_trace_part_authoring.py` | Python tests | Manifest validation and existing source-traced exporter | Six tests cover path safety, integer coordinates, owner/semantic metadata, malformed traces, and quarantine-only export |

## SPECTER visible sword fragments — quarantined — 2026-10-25

| Local file | Format / dimensions | Source | Readiness |
|---|---|---|---|
| `tools/art/specter_blade_visible_candidate_01.json` | JSON traced-polygon manifest | Approved SPECTER front three-quarter concept; manual source-pixel polygons | Two visible fragments only; glove-hidden grip excluded; no pivot or complete held/stowed relationship |
| `assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01/SPECTER_T1_BLADE_HILT_VISIBLE_CANDIDATE_01.png` | PNG RGBA, 1536×1024; 777 nontransparent pixels | Registered approved concept, hash recorded in output manifest | Quarantined visible hilt fragment; does not include glove or hidden grip |
| `assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01/SPECTER_T1_BLADE_BODY_VISIBLE_CANDIDATE_01.png` | PNG RGBA, 1536×1024; 2,698 nontransparent pixels; bounds `[455,483,781,775)` | Registered approved concept, hash recorded in output manifest | Quarantined visible guard/blade fragment; source pixels preserved; no pivot/deformation approval |
| `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_CONTACT_QUARANTINED.png` | PNG diagnostic contact sheet, 3162×1168 | Candidate cutouts on checkerboard | Human visual QA aid only; not art approval |
| `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_OWNERSHIP_QUARANTINED.png` | PNG diagnostic ownership board, 3402×1124 | Approved concept with traced source mask overlay | Zero mask overlap; semantic labels still unverified; not rig input |
| `tests/art/capture_specter_blade_mesh_fidelity.gd` | GDScript/Compatibility-renderer diagnostic | SPECTER candidate 01 parts and shared PolyRig contour builder | Native-scale static texture/mesh comparison only; quarantined |
| `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_01_QUARANTINED.png` | PNG Godot Compatibility board, 1280×720 | Initial unannotated source/mesh view | Superseded visual-only diagnostic; no quantitative report |
| `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_02_QUARANTINED.png` | PNG Godot Compatibility board, 1280×720 | Intermediate render diagnostic | Superseded by board/report 03; no quantified status labels |
| `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_03_QUARANTINED.png` | PNG Godot Compatibility review board, 1280×720 | Native-scale crops of the hilt and blade candidate beside PolyRig mesh renders | Diagnostic only; 1 contour for hilt, 16 for blade body; no opaque-interior differences |
| `docs/visual_qa/SPECTER_T1_BLADE_CANDIDATE_01_POLYRIG_FIDELITY_03_QUARANTINED.json` | JSON render comparison report | Godot 4.7.2 normal Compatibility renderer | 0.23392% hilt and 0.09588% blade sample differences; no fallback; no semantic/rig approval |

Godot 4.7.2 confirms every detected contour triangulates through PolyRig and the static crop render stays within the provisional 1% image-difference diagnostic. The blade texture creates 16 mesh contours under one semantic owner. These fragments do not constitute a complete functional weapon or SPECTER rig. Hidden grip pixels, hand attachment, weapon pivot, hip sheath relationship, and animation remain unresolved.



## CIPHER rifle attachment mesh diagnostic — quarantined

`assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png` remains a quarantined static candidate. Godot 4.7.2 Compatibility validation through `PolyRigContourMeshBuilder` produced one contour / one PolyRig mesh / zero fallback; native render difference was 1/49,320 (0.00203%), with zero opaque-interior differences. Evidence: `docs/visual_qa/CIPHER_T1_RIFLE_POLYRIG_FIDELITY_01_QUARANTINED.png` and `tests/art/capture_cipher_rifle_mesh_fidelity.gd`. This only validates raster fidelity of the existing PNG. Source match, scope ownership, grip and stow pivots, attachment poses, deformation, behavior, and production status remain unverified.

## CIPHER rifle diagnostic — full-suite evidence

The routine pipeline now includes a direct CIPHER rifle mesh-input regression. Full validation passed: Python **105/105**, all-12 workspace/attachment audit **PASS**, and Godot 4.7.2 headless suite **PASS** including one PolyRig contour and zero fallback for the quarantined rifle PNG. The separate Compatibility renderer passed at **1/49,320** sampled differences (**0.00203%**) and zero opaque-interior differences. These checks do not clear source, semantic, mount, pose, deformation, behavior, or production gates.

## Windows launch and persistence smoke test — 2026-10-25 UTC

| File | Format | Status / readiness |
|---|---|---|
| `tests/run_isolated_windows_smoke.ps1` | PowerShell | Local QA harness. Builds a disposable project copy with a unique application name and isolated `APPDATA`, performs clean editor import, Windows GUI launch, full Godot regression, and save round-trip. Not game content. |
| `tests/user_data_path_save_probe.gd` | Godot GDScript | Local QA fixture. Verifies permanent progression, current-run state/squad HP, and settings across separate Godot processes; deletes only its unique probe files. Not runtime content. |

The runner validates that the normal user save hash does not change. The editor import emits a safe-save warning during shutdown; runtime and tests pass, but editor-settings persistence remains unverified. The Python test preflight is blocked because the current sandbox cannot write its project-local fixtures. No art assets changed or were promoted in this milestone.

### Python verification follow-up — 2026-10-25 UTC

The exact project fixture-write access was granted for one test run. `python tests/run_python_tests.py` passed **105/105**; `python tools/art/audit_rigging_prep_all_12.py` passed all roster and workspace checks. This removes the Python-suite blocker for this run. All twelve editable attachment workspaces still contain blank placeholders, and no character has production-ready modular parts as a result of these tests. No artwork changed.

## Notion decision sync — text only — 2026-10-25 America/Chicago

The live Decision Log, Game Design & Progression, Founding Recruit Roster, and Production Roadmap pages were updated with text-only 1.0 decisions and verified by readback. No art asset, binary attachment, or production visual was uploaded or changed by this sync. GitHub was not accessed.

## Tier I live-source reconciliation — no asset change — 2026-10-26 UTC

Read-only Notion source evidence is recorded in Notion/Live Readbacks/TIER_I_ART_HANDOFF_SOURCE_CHECK_2026-10-26.md. The roster and Decision Log do not add character-specific art ownership or attachment answers for the open ECHO, GLITCH, and DEADLOCK requests. Existing candidate classifications and quarantine gates remain unchanged; no art binary or runtime asset was added, removed, or promoted. No Drive upload occurred.

## CIPHER rifle source-shape follow-up — quarantined — 2026-10-26 UTC

The existing isolated rifle PNG remains a review-only cutout. Display comparison with the approved concept/anatomy references did not establish source silhouette match or identify the vertical side-view item as the same prop. It has no authored pivot, remains absent from the body parts manifest, and was not changed or promoted. See docs/visual_qa/CIPHER_RIFLE_ATTACHMENT_REVIEW_01_QUARANTINED.md.

## Ability/formation audit — no asset change — 2026-10-26 UTC

No character artwork or runtime asset changed. The twelve roster skill descriptions are not complete implementation specifications; the source audit is documentation only. Existing asset readiness and quarantine status remain unchanged. See docs/AUTOMATIC_ABILITIES_AND_FORMATION_SOURCE_AUDIT_2026-10-26.md.

## District visual-plan metadata — no production assets — 2026-10-26 UTC

The new district scope JSON records approved wave bands and the 1.0 visual-module plan only. It contains no environment artwork, canonical zone names, palette approvals, or runtime assets. Existing Undercity palettes remain provisional fixtures; no files in the asset library were modified.

## Endless progression source audit — no asset change — 2026-10-25 America/Chicago

The source audit confirms the endless start at wave 126 but does not approve new enemy, boss, district, or environment assets for that range. No artwork or runtime asset changed. Keep current Undercity palettes and their wave-13 transition as provisional fixtures. See `docs/ENDLESS_PROGRESSION_AUDIT_2026-10-25.md`.

## BREAKER run-level purchase sync — documentation only — 2026-10-26 UTC

No asset files changed. The validated BREAKER purchase status was published to the live Production Roadmap and confirmed by Notion fetch readback; the Backup & Synchronization Protocol records the Drive blocker. Google Drive file/folder tools are unavailable, so no remote folder readback or upload is claimed. No binaries were included; labeled local Notion/Drive folders remain staging copies only.

## Tier I ORA provenance inventory — documentation only — 2026-10-26 UTC

Read-only inventory of all 43 quarantined ORAs: all ZIP CRC checks passed; 0 verifiable source-manifest matches; 4 byte-identical CIPHER 09B ORAs share one embedded manifest-hash mismatch; 39 lack a usable source-manifest pointer/hash (33 have JSON metadata without provenance, 6 have no embedded JSON). All 24 approved local source-index files still match their recorded SHA-256 values; no embedded ORA hash matched an approved-index hash. Earlier CIPHER 09B manifest bytes are unavailable, so provenance remains unresolved. Exact filenames, hashes, method, and limits: `docs/ORA_PROVENANCE_AUDIT_2026-10-26.md`. No artwork, ORA, candidate status, or runtime asset changed; all candidates remain quarantined. Local evidence only; remote reconciliation is queued.

## C-02p source-review handoff — no asset promotion — 2026-10-26

The DEADLOCK antenna, BULWARK helmet medical marking, and SPARK drone findings are consolidated in `docs/TIER_I_ARTIST_INPUT_PACKET_C02_01.md` and `docs/ARTIST_HANDOFF_MATRIX_T1_01.md`. Visible source-pixel fidelity is not treated as semantic ownership or rig approval. DEADLOCK's antenna mask remains rejected; BULWARK's mark remains front-view-only with backing ownership unresolved; SPARK's crops remain reference cutouts with orientation and pivot gates open. No art/runtime asset changed, and all candidates remain quarantined.

## C-02r SPARK/ECHO air-lane art readiness — no production assets — 2026-10-26

The approved separate spatial height/air-lane direction does not make the current quarantined attachments production-ready. SPARK's three near-frontal drone cutouts preserve visible pixels only; side/rear views, side-view/orientation treatment, and reviewed authored pivots are missing. ECHO's visible spheres are not mapped to sensory-drone versus Signal Cascade decoy roles/counts, and no complete device/tether ownership set or reviewed pivots exists. No attachment art, runtime asset, or test changed; candidates remain quarantined. See the C-02r packet and matrix update.

## CIPHER 09B knee weight-map angle sweep — quarantined QA capture — 2026-10-26

| Local file | Format / dimensions | Scope / readiness |
|---|---|---|
| `tests/art/capture_cipher_candidate_09b_knee_weight_map_angle_sweep.gd` | Godot GDScript | Updated to render the intended board in a dedicated SubViewport because the project root remains fixed at 1280×720. Uses only the selected quarantined export parts; no runtime path. |
| `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_WEIGHT_MAP_ANGLE_SWEEP_GODOT_08_QUARANTINED.png` | PNG, 1640×500 | Real Godot 4.7.2 Compatibility-renderer capture of -20°, -10°, 0°, +10°, +20° at 44 px test half-band. No underpaint; estimated hip/weights; illustrative angles. Diagnostic only; candidate remains quarantined. SHA-256 `08016f73a6a3c29d449ce122c371f3f0c83bde55c0b6ce3f4ee30737c24b1573`. |

Visual inspection shows knee deformation at the five sampled poses; extreme-pose seam-edge distortion cannot be distinguished from mesh folds/texture shear in this review. Source-manifest provenance and Krita save/reopen remain unresolved; full-rig, continuous-motion, production, and runtime gates remain open. Godot printed user log/shader-cache write warnings, but rendering and PNG save succeeded. No source art, ORA, runtime asset, or candidate status was changed or promoted.

## 2026-10-26 — Godot test-runner lineup signature fix — no asset changes

Only three test-runner calls were updated to match the current `build_default_lineup(owned_ids)` signature. No game assets, runtime data, or character art changed; no tests were run.

## C-02s scoped attachment decisions and provenance follow-up — documentation only — 2026-10-26

User approvals recorded locally: BULWARK white cross backing is helmet-panel-owned; CIPHER's held concept rifle and vertical side-view item are the same prop across carry states; DEADLOCK has one rifle shown held and back-mounted in different states. These resolve identity/ownership only and establish no cutout boundary, new attachment point, coordinate, pivot, or production approval. No asset was modified; all candidates remain quarantined. CIPHER 09B's prior manifest digest `43c735daa7b57d3f214c818151d3ecb24c1d60b3192ef204b668554de7e1d9e3` remains unrecoverable from local project/staging evidence; 39 other Tier I ORAs have no usable source pointer/hash. See `docs/ORA_PROVENANCE_AUDIT_2026-10-26.md`. Remote reconciliation is queued; no remote read/write/upload occurred.

## 2026-10-26 — cover art concept 01 — quarantined concept reference

| `assets/concept_art/neon_requiem_cover_concept_01.png` | 1024×1536 PNG | Generated for the user-requested cover-art concept | Mood/composition reference only: rainy neon megacity, anonymous backlit squad silhouettes, gunmetal with crimson/cyan/magenta accents. Not approved canon, not named-character art, and not a runtime asset. No character designs or game systems are established by this image. |

## 2026-10-26 — cover art concepts 02–03 — quarantined concept references

| `assets/concept_art/neon_requiem_cover_concept_02.png` | 1024×1536 PNG | Generated as an alternative cover concept | Rainy street canyon with anonymous recruit silhouettes; title and palette follow concept 01. Not canonical or runtime art. |
| `assets/concept_art/neon_requiem_cover_concept_03.png` | 1024×1536 PNG | Generated as an alternative cover concept | Elevated rooftop and transit-arc composition with anonymous silhouettes; title and palette follow concept 01. Not canonical or runtime art. |

`docs/CHARACTER_CARDS_CONTENT_DRAFT_01.md` links approved source reference sheets but contains no newly generated character artwork. Its content is source-grounded and draft-only.

## 2026-10-26 — VECTOR card layout prototype — documentation mockup only

`docs/character_cards/vector_card_prototype_01.html` is a reusable visual-card layout sample. It displays the existing approved VECTOR concept reference and links the anatomy turnaround; it does not generate, crop, extract, or promote character art. It is not a runtime screen or approved final card design. Basic attack remains open and Slipstream remains summary-only.

## C-02d CIPHER 09B knee angle sweep — diagnostic only — 2026-10-26

The quarantined 1640×500 Godot 4.7.2 Compatibility-rendered board covers -20°, -10°, 0°, +10°, and +20° with the existing 44 px test half-band and approved knee pivot. A disposable copy regenerated the existing board byte-for-byte (SHA-256 `08016f73a6a3c29d449ce122c371f3f0c83bde55c0b6ce3f4ee30737c24b1573`); the protected source PNG was not overwritten. Visual review confirms a knee seam gap at +20° and interior mesh/texture distortion at stronger bends. No art or runtime asset changed and no candidate was promoted. Keep 09B quarantined pending source-backed seam/overlap, full-rig and continuous-deformation review, Krita save/reopen, and ORA source-manifest provenance evidence. Isolated preview workspace: `.codex_tmp_C02d_20261026_01/`.

## Evolution form naming update — 2026-10-26 — no asset changes

The global progression labels are now Origin Form, Adapted Form, Signature Form, and Requiem Form. This is a naming update only; the four-tier art coverage remains 12 recruits × 4 forms, and no art, rig, or candidate status changed. Approved concept directions remain quarantined and are not production approvals.
