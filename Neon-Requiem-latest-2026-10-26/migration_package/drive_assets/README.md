# Neon Requiem — Rebuild & Backup Kit

Notion (canonical design): https://app.notion.com/p/40394c5658c88174b135cd3432d667c1
Google Drive (backup destination): https://drive.google.com/drive/folders/1EsuAqZMVJeGSLTWPULaDFitDcfwlq8c2

## Contents
- `concept_art/`: original PNG concept sheets recovered from the current workspace.
- `Breaker_Tier1_Godot_Production_Spec.md`: production reference.
- `MANIFEST.md`: asset list and statuses.
- `sync/`: reference GitHub Actions workflow and Python script for pushing milestone archives to Google Drive. Requires GitHub repository and Drive credentials setup before it runs.

This is a snapshot, not a working Godot project. No sprite rig, transparent sprite layers, or Godot scenes have been created.

## Codex start
1. Open Notion project HQ and all child design pages.
2. Read Breaker production spec and manifest.
3. Create an isolated Godot 4 project; preserve six active slots, no gacha, no fal.ai.
4. Use concept images only as references, not animation-ready assets.
5. Commit the project and set up milestone backups using `sync/`.
