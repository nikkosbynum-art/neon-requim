# Prototype tests

## Python regression suite (sandbox-aware)

Run the full Python suite with the preflight wrapper:

```powershell
python tests/run_python_tests.py
```

The wrapper checks write access to the project-local fixture parents before unittest discovery. If it reports `BLOCKED`, no Python tests ran; grant the listed paths the project's approved test-write access and rerun. Treat that result as an environment permission issue, not a code regression. For verbose output, add `--verbose`. Keep `FIXTURE_WRITE_DIRS` in `tests/run_python_tests.py` synchronized when a new test introduces another explicit project-local `TemporaryDirectory(dir=...)` parent.

## Structured combat events for future attachment presentation

`CombatDirector.combat_action_resolved` emits deep-copied `attack_resolved` payloads after authoritative damage commits. Its `_emit_ability_resolved` hook publishes a target-aware or targetless `ability_resolved` event on the same sequence only when a caller reports an already-committed effect; the hook does not activate abilities or apply gameplay effects. The main suite checks ally/enemy source/target IDs, shared event ordering, targetless ability identity, malformed ability rejection, post-hit state ordering, and that listener mutation cannot change combat. It also exercises `AttachmentEventRouter` actor-instance ownership filters, duplicate-ID rejection, malformed-event rejection, duplicate/out-of-order sequence suppression, and per-receiver event-copy isolation. A SPARK router regression registers three separate drone receivers and verifies each receives the same owner attack event once; the main-scene test separately confirms the end-to-end attack route. No current ability implementation calls the hook. These tests validate event transport only; they do **not** implement drone movement, target selection, damage, authored art/rigs, or character-specific signature abilities. No production equipment is registered.

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_runner.gd
```

## All-12 Tier I edit-workspace audit

The roster-wide audit reads the current plan and the actual 12 generated ORA archives/sidecars. It validates source/candidate paths, attachment contracts, archive integrity, manifest/stack order, per-character attachment layer presence, hidden transparent blank RGBA layers, reference embedding/visibility, current open-question notes, and quarantined status. It compares embedded reference pixels byte-for-byte to their source images. It is read-only and does not judge anatomy or visual quality.

## Reference-derived prop cutouts

`test_extract_reference_prop_candidate.py` covers explicit object/background seeds, connected-component isolation, transparent safety margins, source-color preservation, owner-matched draft output, overwrite/path guards, and audit rejection after pixel tampering. `audit_reference_prop_candidate.py` checks hashes, source RGB, pairwise mask overlap, and mechanical alpha but does not clear semantic or production gates. The SPARK test candidate is extracted from the approved anatomy turnaround as three separate drone PNGs; it remains static reference cutout art only. Its mechanical audit passes, but Krita review, authored pivots, deformation, and runtime behavior remain unverified.

`test_audit_semantic_cutout.py` also verifies that the alpha audit reports four-connected island sizes and the secondary-to-main component ratio without changing its mechanical pass/fail result. This is a review aid for detached fragments, not a semantic classifier; intentional multi-piece accessories still need human review.

`test_cipher_profile_part_candidate_audit.py` covers candidate 06's source coverage and alpha gates and reconstructs its named part masks to verify measured overlap at the thigh/shin and shin/boot seams. `tests/art/test_cipher_candidate_06_cutouts.gd` confirms Godot can read all ten PNGs and the 330×960 neutral assembly while candidate status remains quarantined. Neither test proves semantic ownership, authored pivots, hidden anatomy, or deformation.

`tools/art/render_semantic_part_contact_sheet.py <candidate_dir> <new_output.png>` creates a native-scale checkerboard sheet from a candidate's named RGBA files. It refuses overwrite and project-external paths. The output is a review aid and leaves semantic and production approval false. Candidate 06's contact sheet and pixel-ownership map are saved under `docs/visual_qa/`.

The Godot attachment-router regression also covers targetless owner events (such as a support-ability presentation cue) alongside resolved attacks, independent drone receivers, owner-instance isolation, and event-copy mutation isolation. It validates event transport only: it does not implement ability effects, weapon cadence, drone movement/targeting, attachment transforms, or production visuals.

## CIPHER candidate 09B knee-guard pivot diagnostic

`tests/test_runner.gd` verifies the approved guard pivot in both full-source and part-local coordinates. The normal-renderer diagnostic below rebuilds the source-aligned knee crop from the quarantined parts, compares neutral composition with the candidate assembly, then displays ±15° rigid rotations around that hinge. The angles are diagnostic only; the test does not certify seam quality, skinning, action ranges, other pivots, or production art. Use a new output filename for each capture because the script refuses to overwrite prior review evidence.

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/art/capture_cipher_candidate_09b_knee_guard_motion.gd -- --output res://docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_GUARD_MOTION_NEW_QUARANTINED.png
```

```powershell
python tools/art/audit_rigging_prep_all_12.py
python -m unittest discover -s tests -p 'test_rigging_prep_all_12.py' -q
python -m unittest discover -s tests -p 'test_roster_edit_workspaces.py' -q
```

## Quarantined OpenRaster part export

`tools/art/export_reviewed_openraster_parts.py` takes an explicit selection manifest and exports only non-empty semantic authoring layers from a quarantined `.ora`. It preserves full-canvas offsets and requires equipment role/owner/behavior status metadata. Multiple art components can share one `attachment_role_id`; the runtime assigns unique attachment instance IDs later. Output is restricted to the matching character's `tier_01_drafts/` folder, always quarantined, and never treated as a production manifest. The focused tests cover blank-layer rejection across all twelve actual workspaces, alignment, weapon/cable/drone metadata, wrong owners, duplicate part IDs, shared equipment role IDs, hidden/unsafe layer selection, non-unit opacity, and overwrite/runtime-path refusal.

```powershell
python -m unittest discover -s tests -p 'test_export_reviewed_openraster_parts.py' -v
```

## CIPHER quarantined rig blockout

The blockout scene under `tests/art/` uses generic polygons plus one quarantined CIPHER head composite. It validates the proposed 16-bone hierarchy, pose-transform plumbing, and fixed ground/head pivots. It does not validate production anatomy, art seams, complete animation clips, or runtime integration.

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/art/test_cipher_rig_blockout.gd
```

## CIPHER head-pivot art-input smoke test

This isolated test uses the quarantined cleaned CIPHER head candidate. It validates image loading, audited bounds, a provisional review scale, and a fixed socket transform over five small angles. It does not validate a full character rig or approve the art.

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/art/test_cipher_head_pivot_candidate.gd
```

## BREAKER art-manifest review tests

The quarantined profile rig uses `pivot_manifest.json` to declare the part files, source canvas, provisional parent bones/pivots, draw order, and review scale. Python tests validate schema, paths, image decoding/dimensions/alpha, pivot bounds, hierarchy references, layer order, visible-height measurements, and the separate production-readiness blockers:

```powershell
python -m unittest tests.test_character_art_manifest -v
python tools/art/validate_character_art_manifest.py assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/pivot_manifest.json
```

The Godot structural/pose smoke test loads that same manifest, checks 13 loaded parts and all declared bones/layers, verifies neutral alignment and target scaling, then exercises idle, walk, punch, and hit pivots:

```powershell
godot --headless --path . --script res://tests/test_breaker_profile_rig_trial_01.gd
```

Use `--require-production` with the validator only when deliberately checking the art gate; the current review-only manifest is expected to return exit code 2 because art approval, concealed anatomy, authored pivots, seam review, and animation review are still incomplete. These tests do not certify anatomy, all-frame seams, or production readiness.

## Founding-roster intake audit

The shared contract in `tools/art/character_art_manifest.schema.json` and the executable Python checks support all twelve founding recruits. The roster file preserves its canonical Notion source and explicitly registers only the existing BREAKER review manifest as a legacy pilot. Other BREAKER trial manifests are ignored; the other eleven recruits remain `NOT SUBMITTED` until real source assets arrive. The batch audit never creates or modifies manifests, ORAs, or image files; it verifies the actual generated archives read-only.

```powershell
python tools/art/validate_character_art_roster.py
python tools/art/validate_character_art_roster.py --json
python tools/art/validate_character_art_roster.py --require-all
python tools/art/validate_character_art_roster.py --require-production
python -m unittest tests.test_character_art_manifest tests.test_character_art_roster -v
```

Test fixtures create tiny temporary RGBA tiles inside the project workspace; they are deleted after the test and are not character art.

Run the script test suite from this project folder with Godot 4:

```powershell
godot --headless --path . --script res://tests/test_runner.gd
```

The suite also checks the HUD remains within the 800×450 minimum viewport, exact-cost and insufficient-credit upgrades, and that a cleared encounter's credit reward is not paid twice. Progression tests cover Reboot and damage-bonus trials, evolution gate milestones and sequential per-recruit unlock transactions, material accounting, one-time claims, and input immutability. Material payout tests verify +1 repeatable Evolution Data per successful clear plus first-clear bonuses, including all five endpoints, replays, and malformed profiles. Reboot tests verify eligibility, reset/high-water behavior, preservation of permanent data, save-backed award/reset atomicity using memory fault injection and real disposable disk I/O, duplicate prevention, and failed-write preservation. Evolution records are progression only; no tier stat or art effects are implemented. Save persistence across distinct Godot launches can be checked with a disposable identifier; the read process removes the probe and its recovery sidecars:

Offline-credit tests use the shared ordinary encounter reward formula at the saved highest-cleared wave, check the configurable hourly rate and eight-hour cap, and confirm that no encounter or wave advancement occurs. They cover legacy timestamp baselining without retroactive payout, future-clock correction, sub-credit accumulation, duplicate prevention, persisted-before-live-apply ordering, and preservation of saved wave/high-water/recruit/HP/permanent/settings state. Evolution and Reboot save callbacks also verify that their persisted run resets the offline accrual baseline.

For an end-to-end return/claim/reload across separate Godot processes, use a unique probe ID. The `verify` process removes the temporary save and recovery sidecars:

```powershell
godot --headless --path . --script res://tests/offline_claim_process_probe.gd -- write offline_qa_01
godot --headless --path . --script res://tests/offline_claim_process_probe.gd -- claim offline_qa_01
godot --headless --path . --script res://tests/offline_claim_process_probe.gd -- verify offline_qa_01
```

The probe seeds one elapsed hour at wave-25 holding reward, performs the real main-scene load and atomic claim in a second process, then reloads in a third process and checks no duplicate payout or wave advance. It uses only a unique disposable project-local save, not the user's normal save.

```powershell
godot --headless --path . --script res://tests/restart_save_probe.gd -- write qa_run_01
godot --headless --path . --script res://tests/restart_save_probe.gd -- read qa_run_01
```

Use a fresh identifier for each run. The write invocation refuses to overwrite an existing probe file. The writer performs BREAKER's approved prototype purchases from Street through Requiem Form (wave gates 25/75/125; costs 1/2/3 Evolution Data), then saves the resulting permanent state together with wave-125 run and settings data. The separate reader recomputes the expected transaction and verifies the full payload, including zero remaining Evolution Data. This exercises the transaction and versioned save service across two independent Godot processes; it is not the user's normal save file. These values are prototype feasibility trials, not final balance.

The suite verifies that the 125-wave combat and save ceilings agree; wave-125 run/permanent state round-trips, while wave 126 is rejected. Waves 26–125 are placeholder progression tests and do not represent completed district content. Structured `wave_cleared` event checks verify the cleared wave/reward/high-water payload, that subscribers observe committed intermission state, and that an encounter cannot emit a duplicate clear event. The live System Reboot control stays locked before a wave-25 first clear, unlocks afterward, captures current in-memory run progress, persists the reset and award before mutating the live scene, preserves permanent research/first-clear state, and restores base-level squad HP. The live callback is exercised with wave-50 state to verify the second prototype reward band and refreshed damage stats. These callback checks use a unique disposable project-local save path and remove its save/recovery files; they do not use or modify the normal user save.

The suite also verifies that each local BREAKER art exploration loads as a 1536×1024 image with an alpha channel and transparent gutter, and that its draft folder remains `.gdignore`d. These checks validate file structure only; they do not make the atlas animation-ready or validate part pivots and seams.

Capture fresh HUD screenshots from the actual main scene at 1280×720 and 800×450 after three seconds of automatic combat per size:

```powershell
godot --path . --script res://tests/capture_visual_qa.gd
```

The capture helper writes `undercity_atmosphere_1280x720.png` and `undercity_atmosphere_800x450.png` under `docs/visual_qa/`, then uses the next available numbered suffix on reruns instead of overwriting existing captures. It reloads each PNG to verify its dimensions and should be run with a display-capable Godot build so the viewport is rendered normally.

Capture the actual main-scene zone change during its 0.85-second prototype crossfade:

```powershell
godot --path . --script res://tests/capture_zone_transition_qa.gd
```

This QA helper advances the scene through its combat-owned wave-13 test boundary, captures the transition at 1280×720, then captures the same encounter after three seconds of automatic movement. It checks both saved PNG dimensions and never saves game progress. It writes `docs/visual_qa/modular_zone_crossfade_1280x720.png` and `docs/visual_qa/modular_zone_positions_after_3s_1280x720.png` (timestamp suffixes are used on reruns). The boundary and two palette-only modules are QA fixtures, not final encounter pacing or district geography.

Capture the full advancing squad and BREAKER's simulation-triggered hit reaction:

```powershell
godot --path . --script res://tests/capture_combat_presentation_qa.gd
```

The helper checks that all six allies remain active, at least four are moving from their start positions, CombatDirector damage lowers BREAKER's HP and emits the hit state, the rig presents that state, and the ground shadow remains below BREAKER. It writes numbered 1280×720 screenshots under `docs/visual_qa/`. The hit-pose capture uses a controlled in-memory encounter setup to select BREAKER as the target; it does not save progress or modify source combat data.

Capture the carryover-HP defeat and retreat recovery loop:

```powershell
godot --path . --script res://tests/capture_retreat_recovery_qa.gd
```

This helper advances the authoritative fixed-step simulation to natural full-squad defeat, captures the highest-cleared holding-wave retreat state, then verifies/captures full-health re-entry. It only accelerates in-memory simulation steps; it does not change balance definitions or save progress. Numbered 1280×720 screenshots are written under `docs/visual_qa/`.

Capture the eligible BREAKER evolution requirement at both HUD reference sizes (run with a display-capable Godot build):

```powershell
godot --path . --script res://tests/capture_evolution_hud_preview.gd
```

This preview injects only disposable in-memory state (first-clear wave 25 and 1 Evolution Data), never reads or writes the player's normal save, and captures numbered 1280×720 and 800×450 PNGs under `docs/visual_qa/`.

Capture the offline-claim HUD at both reference sizes with disposable save fixtures:

```powershell
godot --path . --script res://tests/capture_offline_claim_qa.gd
```

The helper claims one hour of test earnings from a temporary wave-25 save, captures 1280×720 and 800×450, verifies PNG dimensions, and removes all temporary save/recovery files. It never touches normal user data.

Capture the read-only Network Research framework at both reference sizes:

```powershell
godot --path . --script res://tests/capture_research_framework_qa.gd
```

This helper shows the four approved branches with pending-design labels, verifies that no node purchase is available and that Influence is unchanged, and writes numbered screenshots under `docs/visual_qa/`. Research nodes, costs, prerequisites, and effects are intentionally unconfigured.

Capture the quarantined BREAKER part trial in neutral, walk, punch, and hit poses:

```powershell
godot --path . --script res://tests/capture_breaker_profile_motion_qa.gd
```

This uses only the local 13-mask review assembly with estimated pivots, checks pose sampling/anchor stability, and saves a review-only contact sheet. A successful capture is not approval for runtime use or proof of production joint coverage.

The isolated profile-part walk gait has a phase-level regression and an eight-phase review sheet:

```powershell
godot --headless --path . --script res://tests/test_breaker_profile_walk_gait.gd
godot --path . --script res://tests/capture_breaker_walk_cycle_qa.gd
```

The regression checks alternating knee lift, ankle counter-rotation, opposite arm swing, pixel-sampled boot contact during two stance phases, smooth loop closure, and stable ground anchoring. The capture is review-only and keeps the profile art quarantined. The runtime code-drawn BREAKER placeholder has suite assertions for opposing legs, counter-swinging arms, reduced cyber-arm movement, ankle response, and its stable ground anchor; its display capture is `capture_combat_presentation_qa.gd`.

Run the isolated BREAKER production-art gate checks and capture its action/squad review sheets:

```powershell
godot --headless --path . --script res://tests/test_breaker_art_gate.gd
godot --path . --script res://tests/capture_breaker_production_gate_qa.gd
```

The structural test checks all 13 shared-canvas parts and transparent corners, the 256 px visible-height scale, in-bounds estimated pivots, five pose channels, facing, and ground anchor. The display helper captures idle, walk, punch, hit, defeat, and six full-size BREAKER profiles at staggered gait phases. These tests and captures validate the isolated review harness only; hidden joint anatomy, continuous seams, authored pivots, and mesh deformation remain open. None of this art is linked to runtime.

The runner checks six-slot setup and explicit placeholder labels, configured horizontal start offsets, unique depth positions with at least 28 world units between sorted neighbors, data-driven melee/ranged styles and engagement distances, melee approach to contact, ranged stand-off attacks, unique per-slot movement speeds and actual movement deltas, and that the main HUD exposes no speed/pace control and movement speed is absent from settings and serialized run/settings data. It verifies HUD save/upgrade feedback remains inside the panel, the four existing action buttons retain their order, and the new read-only Research dialog lists the four approved branches without purchaseable nodes. Headless HUD signal coverage presses Upgrade x10 twice from identical starting state with adequate credits and verifies repeatable level and credit results. Presentation snapshots interpolate ally and enemy positions between fixed steps without mutating authoritative snapshots, and new encounters reset interpolation origins. It also checks nearest-living-ally automatic targeting, damage to selected allies, placeholder ally participation in attacks, reward ordering and one-time credit accounting, BREAKER upgrade costs and live combat stat scaling, a full automatic encounter with movement and squad damage, reproducibility, wave transition and prototype cap, HP carryover across successful wave transitions, defeated allies remaining down, natural full-squad defeat before the cap, retreat to the highest cleared holding wave, full recovery on retreat, and the approved modular zone transition without changing actor positions. Save tests verify per-slot HP round-trip, validation of malformed HP arrays/values and research ranks, and backward-compatible loading of older version-1 saves without HP fields. It also checks BREAKER Tier I rig anchors/facing and eased pose transitions, versioned save restoration, malformed/invalid save rejection, and main-scene environment/HUD wiring. Unsupported save versions must be rejected. The disk round-trip uses a disposable project-local test file, removes its sidecars, and never opens the normal user save.

Research transaction tests use only in-memory fixture nodes: they cover the four branch catalog, no-node behavior, prerequisites, Influence deduction, rank limits, malformed definitions, immutable inputs, save-before-apply ordering, and failed-write preservation. Wave-clear autosave tests use disposable project-local files and verify the current run, squad HP, settings, repeatable materials, first-clear ledger, and permanent high-water persist together. A sentinel fixture verifies that autosave cannot overwrite a pre-existing save before the player loads it; the test also checks Load/Save guidance. An invalid parent path injects a failed autosave; the test checks that no partial file appears, session rewards remain available, HUD recovery guidance is shown, and a later valid clear saves successfully.

The BREAKER rig regression also verifies that the ground, neck, and right-fist FX markers exist; visual facing does not move the root/ground anchor while the fist marker follows the mirror; the visual rig owns no collision shapes; and `play_action` leaves simulation position and health unchanged. A quarantined head candidate is loaded into an isolated rig to verify transparent/opaque pixels, explicit pivot alignment to the head bone, scale, placeholder feature hiding, and no simulation-state changes. These checks validate file and transform plumbing only, not assembled visual quality, production artwork, or a finished rig.

Main-scene presentation tests also verify a ground-contact shadow for each of the six allies and the enemy, shadow render order beneath the actors, and shadow alignment with each ally's lane/contact anchor. These code-drawn shadows and the upper-walkway floor seams are presentation cues for the backline, not final environment art.

Transactional persistence fault-injection tests use an in-memory file-operations adapter and never touch disk. They cover temp open/write/flush/read-back failures, backup staging/promotion/removal failures while preserving the older recovery copy, semantically altered but valid staged/backup/committed data, partial and invalid commit copies, rollback-copy failures, and recovery from a missing/corrupt primary through `.bak` or `.bak.prev`.

## BREAKER profile rig trial 02

`test_breaker_profile_cutout_candidate_02.gd` checks the generated candidate's RGBA dimensions, fully transparent background, and high-alpha silhouette bounds. `test_breaker_profile_rig_trial_02.gd` checks isolated rig construction, shared-canvas layers, review scale, pivot presence, facing/anchor stability, and idle/walk/punch/hit/defeat transform channels. `capture_breaker_profile_trial_02_qa.gd` uses Godot's display-capable renderer to capture two review sheets.

Run targeted headless checks with Godot 4.7.2's console executable:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_profile_cutout_candidate_02.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_profile_rig_trial_02.gd
```

These checks validate file/transform plumbing, not production animation. The trial is quarantined; masks and pivots are estimates, hidden anatomy is not reconstructed, and no deformation or all-frame seam validation exists.

Audit whether trial 03 contains independent hidden under-paint:

```powershell
python tools/art/audit_breaker_trial_03_hidden_anatomy.py
```

Exit code 2 is the expected **NOT VERIFIED** gate result for the current layers. The audit checks pixel provenance; it must not be reinterpreted as a general anatomy detector. See `docs/BREAKER_HIDDEN_ANATOMY_AUDIT.md`.

The local workspace has no layered authoring source (`.psd`, `.kra`, `.ora`, `.aseprite`, `.ase`, `.xcf`); the candidate is flattened. The audit always exits 2 because pixel provenance is not a semantic hidden-anatomy certification. A passing hidden-anatomy result requires a separate authored/reviewed asset process.

## BREAKER trial 04 inferred under-paint

```powershell
python tools/art/audit_breaker_profile_trial_04_underpaint.py
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_profile_rig_trial_04_underpaint.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --fixed-fps 60 --path . --script res://tests/test_breaker_profile_rig_trial_04_joint_contacts.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_breaker_trial_04_joint_stress_qa.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_breaker_profile_trial_04_qa.gd
```

The Pillow audit checks only layer integrity and exact neutral reconstruction. The Godot checks exercise structure, clip transforms, and selected pivot neighborhoods. The exaggerated joint-stress capture is intentionally used to visually expose gaps; it revealed residual artifacts. None of these test-only inferred fills constitute verified anatomy or production approval.

Additional trial-04 intended gait checks:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_profile_trial_04_walk_gait.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_breaker_trial_04_walk_cycle_qa.gd
```

The strengthened 12-joint contact test now requires 15 adjacent opaque pixels per neighborhood (observed minimum 35) across all 206 60-Hz sampled poses. This applies to the current authored action ranges only; the exaggerated stress capture is diagnostic and not a playable clip.

## BREAKER arm component board candidate 12

Run the structural audit and Godot direct-image test:

```powershell
python tools/art/audit_breaker_arm_components_candidate_12.py
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_arm_components_candidate_12.gd
```

These checks validate the 1774×887 RGBA image, transparent corners, and four separated high-alpha panel regions. They do not validate anatomical meaning, hidden surfaces, part alignment, pivots, full-body proportion, or animation; candidate 12 remains a quarantined concept board.

## BREAKER arm component board candidate 13

Run the static audit, Godot direct-image check, and display-capable rendered assembly review:

```powershell
python tools/art/audit_breaker_arm_components_candidate_13.py
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_breaker_arm_components_candidate_13.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_breaker_candidate13_arm_assembly.gd
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_breaker_candidate13_reference_scale.gd
```

The Python and Godot checks validate RGBA decode, panel gutters/bounds, reference-height scaling, and binary-alpha overlap for the biological upper arm under the external shell and at the elbow. They require the estimated assembly union to be one connected region and retain visible upper-arm pixels below/around the shell. This verifies only the candidate's 2D visible surface at fixed offsets, not anatomical accuracy or concealed 3D structures. The assembly capture shows the reference, shell-on assembly, shell-off under-arm surface, and an elbow-flex pose. The separate scale capture calibrates the arm height to the approved-direction full-body reference (0.519 relative art scale; 73.7 px at 256 px body height). It is a height-only match: pose, orientation, width, and silhouette fit remain unverified. Pivots are estimated and all-frame animation seams remain unverified. Candidate 13 stays in the `.gdignore`d draft folder.

## Candidate01 v20 rendered shell-on edge guard

Run with a display-capable renderer (the headless dummy renderer cannot return viewport images):

```powershell
godot --path . --script res://tests/test_breaker_candidate01_v20_shell_on_visual_parity.gd
```

The test captures the underlay hidden and shown across 206 stable sampled pose frames. A small change is expected where the underlay blends beneath partially transparent source-skin texels; the current observed maximum is 37 changed pixels / 83 channel levels, bounded by test ceilings of 64 / 96 and restricted to the shoulder/upper-arm region. This is a regression guard, **not** a byte-identical parity claim or an anatomy-quality test. Run `python tools/art/audit_breaker_candidate01_tapered_underarm_v20.py` separately for opaque source-mask coverage only. The draft remains quarantined.

The fitted-arm contact suite raises its minimum elbow contact to 100 source-pixel neighborhood contacts: `godot --headless --fixed-fps 60 --path . --script res://tests/test_breaker_profile_rig_trial_01_candidate01_fitted_arm_options.gd`. The v20 minimum is 104 across 206 samples. This tests estimated-transform contact in the review rig, not the artistic quality of the joint; inspect `docs/visual_qa/BREAKER_T1_candidate01_v20_elbow_join_zoom.png` alongside the shell-off anatomy comparison.
# Manual rig review

Open and run tests/art/rig_review_workbench.tscn in Godot to inspect the currently adapted quarantined Tier I candidates. The workbench captures a six-pose review sheet under the Godot user://rig_review_captures/ data directory. Its selected-joint diagnostic lets the reviewer enter a min/max angle and context note; the default -75°/+75° is generic, unverified, and single-joint-only. It does not establish an authored action range. Before the animation gate, review actual combined character-specific idle/movement/attack/hit/defeat poses in an isolated gameplay-camera QA view at 1280×720 and 800×450, using the approved anatomy/style references and ground contact. See docs/CHARACTER_ART_PIPELINE.md for limits and production-art gates. This manual review scene is not a test pass and does not approve art.

To assemble a standard manifest in that workbench, enter its project-relative `character_art_manifest.json` path and choose **Load manifest**. Use **Capture selected-joint sweep** for the selected bone's -75°, -40°, 0°, 40°, and 75° neutral-pose diagnostic. For the static named-part/assembly/alpha/overlap review packet, run `python tools/art/build_character_review_bundle.py <manifest> <new-project-relative-output-directory>`. All captures and bundle outputs remain review aids; see `docs/CHARACTER_ART_PIPELINE.md` for workflow gates and limits.

## Twelve-character roster preview

Run tests/art/founding_roster_gameplay_preview.tscn in Godot. It renders a static 4×3 game-scale roster mockup and saves docs/visual_qa/FOUNDING_ROSTER_GAME_SCALE_PREVIEW_01.png. The figure sources remain a mix of approved references and quarantined candidates; the board is not runtime content or a 12-unit combat formation.


## CIPHER candidate 07 raw-file intake

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/art/test_cipher_candidate_07_cutouts.gd
```

This checks direct PNG decoding, dimensions, transparent safety corners, the source-aligned 330x960 assembly, mast ownership metadata, and quarantine flags. It does not approve semantic labels, pivots, hidden anatomy, deformed seams, or production readiness. Pair it with `python -m unittest tests.test_cipher_candidate_07_mast_ownership -v` and `python tools/art/audit_cipher_profile_part_candidate.py assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07`.

## CIPHER candidate 07 PolyRig contour preflight

Run the full Godot suite or `tools/art/validate_character_art_pipeline.ps1`. The CIPHER section of `tests/test_runner.gd` exercises every manifest-listed part through `PolyRigContourMeshBuilder`, which creates one `Polygon2D` for each detected alpha contour beneath the same semantic owner. Current candidate 07 result: all contours triangulate through PolyRig (including all 8 `backpack_mount` contours); four parts are multi-contour and still require semantic ownership review. The test verifies the candidate remains quarantined and does not imply rig readiness. The prior diagnostic overlay `docs/visual_qa/CIPHER_T1_BACKPACK_POLYRIG_CONTOUR_DIAGNOSTIC_01_QUARANTINED.png` records the former triangulation failure locations; its six locations are now stale as failure points, but remain useful for locating the tiny source features. No pixels, semantic assignments, pivots, or weights are changed by the test.

For an actual rendered source-alignment comparison, run Godot **without** `--headless`:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script 'res://tests/art/capture_cipher_candidate_07_contour_mesh_fidelity.gd'
```

The check compares the source-aligned candidate composite to the per-contour mesh render at 0.5×, then compares each source cutout to its mesh at native 1:1 scale. Current result: all ten parts are below a provisional 1% sampled color-difference bound; no fully opaque interior pixels differ. It does not save an image by default. To save a new, non-overwriting board, add `-- --output res://docs/visual_qa/<new_quarantined_filename.png>`. A headless dummy renderer cannot provide the viewport texture for this diagnostic. The current successful board is `docs/visual_qa/CIPHER_T1_CANDIDATE_07_POLYRIG_MESH_ASSEMBLY_02_QUARANTINED.png`; semantic, pivot, weighting, movement, and deformation gates remain open.

## SPARK drone shared contour-builder preflight

The main Godot suite routes all three quarantined SPARK drone images through `PolyRigContourMeshBuilder`. Each must build exactly one textured `Polygon2D` with pixel-aligned UVs and triangulated faces. Run `tools/art/validate_character_art_pipeline.ps1` for the full validation. This checks the mesh-input path only; side-view adaptation, semantic completeness, pivots, articulation, animation, drone behavior, runtime integration, and production approval remain open.
- Added a candidate-07 hand/jacket ownership regression: it verifies foreground ordering, no visible hand/pelvis or hand/torso mask overlap, existing hand/forearm seam overlap, and explicit inferred-underpaint status. This checks the user-approved interpretation only; candidate remains quarantined and art pixels are unchanged.

## SPARK drone contour-mesh native render comparison

Run the following in Godot's normal Compatibility renderer (not `--headless`):

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script 'res://tests/art/capture_spark_drone_contour_mesh_fidelity.gd'
```

The script compares each source texture with its shared-builder contour mesh at native scale, requiring ≤1% sampled color difference and zero fully opaque interior differences. It writes a new numbered review board under `docs/visual_qa/`. This verifies only static raster fidelity; semantic completeness, side-view adaptation, pivots, animation, behavior, and production approval remain open.

## CIPHER candidate 09B current-cutout preflight

The full Godot suite now checks all eleven current CIPHER candidate 09B part images through `PolyRigContourMeshBuilder`. It validates manifest membership, file uniqueness/dimensions, the separate `near_knee_guard`, source texture/UV/triangles, and that the candidate is not promoted. The user-approved knee-guard owner split is retained; exact mask boundaries and rig review remain open. Run `tools/art/validate_character_art_pipeline.ps1` for the full Python, all-12 workspace, and Godot validation.

The CIPHER contour-mesh renderer diagnostic also supports candidate 09B:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script 'res://tests/art/capture_cipher_candidate_07_contour_mesh_fidelity.gd' -- --candidate 09b --output res://docs/visual_qa/CIPHER_T1_CANDIDATE_09B_POLYRIG_MESH_ASSEMBLY_01_QUARANTINED.png
```

It compares the source-aligned assembly at 0.5× and each of the eleven candidate-09B parts at native scale. This is static raster QA only and does not pass semantic, knee-boundary, pivot, deformation, or production gates.

## CIPHER rifle cutout PolyRig preflight and native-scale fidelity

The main Godot test runner checks the quarantined 540×270 CIPHER rifle PNG through `PolyRigContourMeshBuilder` and asserts one contour, one textured mesh, pixel-aligned UVs, triangles, and no fallback. Run `tools/art/validate_character_art_pipeline.ps1` for the full local validation.

For the separate visual raster comparison, use Godot 4.7.2's Compatibility renderer (not `--headless`):

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script 'res://tests/art/capture_cipher_rifle_mesh_fidelity.gd' --rendering-method gl_compatibility
```

Current result: one PolyRig contour, zero fallback, 1/49,320 sampled differences (0.00203%), zero fully opaque interior differences. Board: `docs/visual_qa/CIPHER_T1_RIFLE_POLYRIG_FIDELITY_01_QUARANTINED.png`. This validates only the raster rendering of the existing PNG; source match, optic relationship, semantic ownership, grip/stow pivots, attachment pose, deformation, behavior, and production status remain open.

## Windows launch and persistence smoke verification

Run the disposable-project smoke check from the project root:

```powershell
& '.\tests\run_isolated_windows_smoke.ps1'
```

If the default approved temp root is unavailable, pass the task-approved writable root explicitly:

```powershell
& '.\tests\run_isolated_windows_smoke.ps1' -ApprovedTempRoot 'C:\Users\Work\.codex\visualizations\2026\10\25\01a17426-0ad4-7a31-b700-1190fce1cb5c'
```

This uses the configured Godot 4.7.2 Windows GUI and console executables. It copies runtime plugins and only the assets needed by the Godot suite into a GUID-named temporary project under the approved test root, changes only the copied project's app name, sets a temporary `APPDATA`, runs a clean editor import, captures the Recruitment dialog at 800×450 and 1280×720, launches the copied main scene with Compatibility rendering for 120 frames, runs `tests/test_runner.gd`, and verifies that a second Godot process can restore permanent progression, current-run state/squad HP, and settings. The two layout captures are preserved in a GUID-named folder under the approved root for visual review. The wrapper compares the ordinary Neon Requiem save SHA-256 before and after. Successful-run temporary data is cleaned; failed runs preserve their logs and warn if Windows keeps a file handle open. The optional `-ApprovedTempRoot` parameter changes only the disposable root; all path-containment and cleanup safeguards remain active.

The editor currently prints `Safe save failed` during the clean import/shutdown even though the import exits successfully and runtime/regression checks pass. Treat editor-settings persistence as unresolved. The Python suite separately requires project-local fixture write access; if its preflight says `BLOCKED`, no Python tests ran.

Save protection and recovery regression coverage also checks that ordinary saves preserve unsupported-schema files and all-corrupt save sets, confirmed reset is required to replace an unsupported save, recovery precedence is primary → `.bak` → `.bak.prev`, and nested unknown fields survive ordinary updates. Validation on 2026-10-25: the isolated Windows Godot suite and separate-process persistence probe passed; the Recruitment captures were produced at both sizes; the Python runner preflight passed and all 105 tests passed with `TEMP`/`TMP` pointed at an approved writable temp directory.

## Core-loop regression coverage

The Godot regression runner exercises these prototype behaviors:

- **Combat and save transactions:** fixed-step automatic attacks/targeting, six-slot squad behavior, melee contact and ranged stand-off, successful wave-clear rewards saved with the run, failed wave-clear writes retaining session rewards, and save fault-injection/rollback/recovery. Run-level and bulk upgrades include affordability and state-commit checks.
- **System Reboot:** eligibility and award boundaries, run reset/high-water behavior, full-HP restoration, preservation of permanent unlocks/research/evolution/materials/first-clear claims, save-before-apply and failed-save immutability. The live dialog test presses Cancel and checks that the run/permanent state and save path remain untouched, then presses its affirmative button and reloads the committed reset.
- **Evolution:** all twelve founding recruits can record Adapted Form with separate tier keys and shared-material accounting; locked purchases do not mutate live or saved state; BREAKER and CIPHER exercise later-tier gates through Military/Apex; failed saves do not apply tier/material changes; save readback is checked.
- **Recruitment:** the twelve-ID catalog and trial prices, starting ownership/credits, exact and insufficient affordability, duplicate rejection, save-before-apply success/failure, reload, legacy starter normalization, and ownership preservation across Reboot. The live roster UI and saved purchase results are checked.
- **Modular zones:** provisional wave selection/boundaries, single zone-change notifications, crossfade creation and cleanup, interruption by a rapid reverse transition, and a combat-triggered zone switch that preserves squad presentation positions. These tests verify the presentation framework and its provisional fixtures, not canonical district content or pacing.
- **Save guard UI:** ordinary Save is exercised against malformed metadata, an unsupported schema, and an unrecoverable save set; all source files must remain unchanged and no staged artifacts may remain. Reset Save cancellation and affirmative replacement are exercised against disposable primary/sidecar files.

The Python regression suite covers project tooling, asset/workspace processing, and source bookkeeping; it does not simulate the Godot gameplay loop. Passing prototype regressions do not verify production balance, final district/boss content, production art, migration from a real user profile, or release readiness.

Latest isolated core-loop validation on 2026-10-25: Godot 4.7.2 clean import **PASS**, 120-frame Windows GUI launch **PASS**, full headless regression **PASS**, separate-process save/load probe **PASS**, and the normal user save remained unchanged. The Recruitment layout captures were produced at 800×450 and 1280×720. Python preflight passed and **105 tests passed** with `TEMP`/`TMP` set to the approved writable workspace. The all-12 workspace audit result is separate from these gameplay checks; authoring workspaces remain quarantined.
