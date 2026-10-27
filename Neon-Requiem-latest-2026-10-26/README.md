# Neon Requiem

Godot 4 project foundation and first playable prototype for the cyberpunk 2.5D endless idle army RPG.

## Current build

This project currently contains a small, code-drawn prototype: a data-driven modular-zone presentation with crossfading procedural Undercity backdrops, a temporary modular BREAKER Tier I stand-in, five clearly labeled generic ally placeholders, one basic enemy definition, six-slot automatic combat, credits, BREAKER run-leveling, deterministic Evolution Data encounter rewards (prototype trial values), a 125-wave progression test horizon, and versioned local save/load. Only waves 1–25 use the Undercity prototype label; waves 26–125 are explicitly labeled as a progression test fixture and reuse the same grunt, scaling, and placeholder battlefield. No post-Undercity district content is implemented by this extension. The combat simulation owns movement, automatic target selection, attacks, damage, and defeat; presentation interpolates between fixed steps without changing simulation state. Resolved attacks are also emitted through a presentation-only attachment router; no character-specific weapons, drones, or abilities are integrated yet. Allies carry HP across successful waves; full-squad defeat retreats to the highest cleared holding wave and restores the squad for another attempt. Per-slot HP is part of the current run save. The Undercity grunt uses a configurable prototype damage ramp to exercise retreat. The sample zone boundary at wave 13 only exercises transitions; zone names, art, and production pacing remain undefined. The HUD has responsive sizing and themed controls. Generic ally combat values, enemy scaling, individual movement speeds, and lineup offsets are configurable prototype placeholders, not character canon.

The offline handoff is extracted under `migration_package/`; its Notion files are reconstructed working copies rather than verbatim exports. Use the live canonical sources when connected, and keep reconstructed details explicitly labeled. The project records prior Notion readback evidence in its documentation; local `Notion/` and `Google Drive/` copies are staging materials, not remote backups. The current attachment-preparation and event-routing changes are local only; deferred reconciliation is tracked in [`docs/REMOTE_SYNC_QUEUE.md`](docs/REMOTE_SYNC_QUEUE.md). The project docs distinguish source material, approved decisions, and concept-only artwork.

## Run

Open this folder in Godot 4 and run `scenes/main.tscn` (also configured as the project main scene). The default remains the existing direct-damage control. To launch the provisional hybrid experiment, pass the Godot user arguments `--neon-hybrid-trial --neon-combat-seed=12345` after the `--` argument separator; all profile values are configurable and trial-only. The hybrid runtime draft is pending focused Test Lane validation. See `docs/IMPLEMENTATION_STATUS.md` for exact validation scope and current test state.

## Controls

Combat, abilities, and unit walking speeds are automatic. Players cannot change movement speeds. Use **Upgrade x1 / x10** for deterministic credit-based recruit leveling, **Save** to write local state, and **Load** to restore it. No manual targeting or ability trigger is provided.

## Status and sources

Character-art intake for the founding roster is documented in [docs/CHARACTER_ART_PIPELINE.md](docs/CHARACTER_ART_PIPELINE.md) and [docs/ATTACHMENT_FUNCTION_CONTRACT.md](docs/ATTACHMENT_FUNCTION_CONTRACT.md) and [docs/ART_EDIT_BATCH_12.md](docs/ART_EDIT_BATCH_12.md). Run `python tools/art/validate_character_art_roster.py` to see per-recruit manifest coverage and readiness blockers.

See [docs/MIGRATION_REPORT.md](docs/MIGRATION_REPORT.md), [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md), [docs/ASSET_MANIFEST.md](docs/ASSET_MANIFEST.md), [docs/BREAKER_RIG_CONTRACT.md](docs/BREAKER_RIG_CONTRACT.md), [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md), and [docs/REMOTE_SYNC_QUEUE.md](docs/REMOTE_SYNC_QUEUE.md). All unapproved technical defaults are labeled provisional; visuals are code-generated placeholders or local art drafts, not production-ready assets.

See [docs/ROADMAP_TO_1_0.md](docs/ROADMAP_TO_1_0.md) for completed milestones, remaining work, dependencies, and working 1.0 exit criteria.

## Local sync folders

`Notion/` contains copies of the project documents and the offline reconstructed handoff pages. `Google Drive/` mirrors the labeled Drive library folders and contains the available reference-art copies, prototype QA snapshots, and a validated source snapshot archive. These are local staging copies; update them after working documents change. Nothing has been uploaded to remote Notion or Drive.
