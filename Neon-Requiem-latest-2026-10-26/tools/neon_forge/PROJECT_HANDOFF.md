# Neon Forge — canonical working handoff (proposed)

**Status:** Context handoff for project-manager review. Not a new art/canon approval, implementation authorization, or assertion of tests passed.
**Repository:** `nikkosbynum-art/neon-requim`
**Working branch:** `feature/neon-forge-core`
**Draft PR:** https://github.com/nikkosbynum-art/neon-requim/pull/2
**Previous research roadmap:** https://github.com/nikkosbynum-art/neon-requim/issues/1
**Baseline:** `Neon-Requiem-latest-2026-10-26`

## First task: preserve and reconcile context

Before more code or art, the project manager should:
1. Read this handoff and all authoritative project contracts referenced below.
2. Compare against the current main branch, approved source records, and any newer local work; note drift explicitly.
3. Confirm scope, decision ownership, approval gates, and test baseline.
4. Convert the master initiative into bounded, one-character/one-phase work orders following `docs/AI_CHARACTER_WORK_ORDERS.md`.
5. Record missing evidence and blockers; do not mark work approved or complete merely because this handoff exists.
6. Keep future implementation in a protected branch or disposable copy, and provide a concise status report before work begins.

## Owner's desired product

Build **Neon Forge**, an AI-operated character production system for Neon Requiem, minimizing the owner's manual involvement. The owner selects a character/form scope and approves creative direction or genuinely unresolved exceptions; automated tooling handles job planning, asset preparation, semantic separation, rig assembly, animation, validation, QA captures, retries, and release packaging. The owner reviews final visual results. Never silently alter established canon or fabricate approval.

**Architecture:** local resumable production orchestrator + existing Python art validators/manifests + Godot EditorPlugin/workbench + existing Poly-Rig + optional authorized image services + structured evidence and approval dashboard. Start inside the Godot repo; a standalone Windows controller can follow after reliability is proven. AI coordinates deterministic tools rather than replacing their checks.

**Operating limitation:** ChatGPT conversations alone do not continuously operate local Godot; execution requires an authorized connected Codex/agent environment. External generation costs require approval. Jobs must be restartable after interruption.

## Initial production scope

**BREAKER, four official evolution forms:**
1. Origin Form / Tier I
2. Adapted Form / Tier II
3. Signature Form / Tier III
4. Requiem Form / Tier IV

Old Street/Combat/Military/Apex board labels are ordered shorthand only. All twelve recruits / 48 form combinations are eventual game scope, but this initiative proves BREAKER first, then a second recruit to demonstrate reusable tooling.

### BREAKER identity and rig constraints

Preserve scarred human face, messy undercut, boxer stance, asymmetric right cybernetic fist, matte black/gunmetal and controlled crimson, neck regulator, left knee brace, boots. Critically: the approved external shoulder shell overlays the **biological upper arm** and the prosthesis begins at the **elbow**. Do not infer missing hidden anatomy from rejected candidates. All form changes must follow approved source direction; flattened boards do not constitute separated parts.

Preserve BREAKER's presentation-only API:
`present(world_x, state, health_ratio, world_y)`, `set_facing_right(value)`, `play_action(name)`, `set_tier(tier)`, `set_overload(value)`, `get_anchor_global_position(name)`.
Keep `fx_anchor_ground`, `fx_anchor_neck`, `fx_anchor_fist_r`. Only mirror `VisualSkeleton`, not gameplay root. Simulation alone owns targeting, health, damage, ability outcomes, movement and save state. Equipment/FX follow authoritative events; they cannot generate gameplay outcomes.

## Source of truth and existing tooling

Read:
- `AGENTS.md`
- `docs/DESIGN_DECISIONS.md`
- `docs/IMPLEMENTATION_STATUS.md`
- `docs/ROADMAP_TO_1_0.md`
- `docs/V1_READINESS_LEDGER.md`
- `docs/AI_CHARACTER_WORK_ORDERS.md`
- `docs/CHARACTER_ART_PIPELINE.md`
- `docs/CHARACTER_PART_AUTHORING_GUIDE.md`
- `docs/BREAKER_RIG_CONTRACT.md`
- `docs/ATTACHMENT_FUNCTION_CONTRACT.md`
- `docs/C05A_EVOLUTION_ART_COVERAGE_MAP.md`
- `docs/ASSET_MANIFEST.md`

Existing implementation includes `addons/poly-rig/`, `tools/art/character_art_manifest.schema.json`, `tools/art/validate_character_art_manifest.py`, `tools/art/validate_character_art_roster.py`, `tools/art/build_character_review_bundle.py`, `tools/art/build_character_work_order.py`, and `tests/art/rig_review_workbench.tscn`. Audit actual behavior before expanding; do not duplicate or replace existing approval logic.

Current documented state: BREAKER Tier I has no complete accepted semantic part set or production manifest; arm/shell candidates are quarantined, shell-off hidden-arm appearance unresolved, and no character is a fully approved Tier I production rig. Tier II–IV do not have approved separated production parts or verified hot-swaps. The existing rig workbench standard-manifest adapter is neutral-only; single-joint diagnostic sweeps do not prove animation quality. Current runtime uses placeholders. Do not misrepresent these statuses.

## Approval contract

The existing five evidence-backed gates are authoritative:
- `visible_art_approved`
- `hidden_anatomy_authored`
- `pivots_authored`
- `joint_seams_reviewed`
- `animation_reviewed`

Keep `review_only`, `production_candidate`, `production_ready` distinct. Each true gate requires source hash, reviewer, timestamp, and project-relative evidence. Mechanical PASS does not mean anatomy, aesthetics, or animation approval. Owner concept approval is not production approval. Candidates stay quarantined until all evidence and explicit final visual acceptance exist.

Review at native scale, 256px foot-to-hair normalized reference, 1280×720 gameplay and 800×450 downscale; test idle/walk/punch/hit/defeat, facing, joint seams, ground anchor, six-unit readability, attachments, and source/ownership correctness. Reject missing, clipped, duplicated, ambiguously owned or unsupported semantic parts. Avoid guessing pivots or underpaint. Maintain no-overwrite review bundles and source provenance.

## Planned components

1. Production orchestrator: persistent job state, stage dependencies, bounded retries, logs, cancellation, resumability, cost/authorization checks.
2. Asset preparation: approved-reference comparison, semantic parts, underpaint proposals, contact sheets, ownership overlays, alpha/provenance diagnostics.
3. Rigging: authored pivots/bones, Poly-Rig reuse, layer order, sockets, isolated candidate scene.
4. Animation: authored actions, joint-range and seam review, attachment synchronization, gameplay-scale captures.
5. QA and release: deterministic validators, headless Godot tests, visual review, evidence verification, fail-closed release package.
6. Minimal approval interface: owner sees creative exceptions and final visual comparison, not routine engineering steps.

## Master delivery phases

- NF-BRK-01 repository/source audit and contract freeze.
- NF-BRK-02 planning-only, recoverable job orchestration.
- NF-BRK-03 Origin semantic art and hidden-anatomy review.
- NF-BRK-04 Origin rig assembly.
- NF-BRK-05 Origin animation and game-scale QA.
- NF-BRK-06 Adapted Form production.
- NF-BRK-07 Signature Form production.
- NF-BRK-08 Requiem Form production.
- NF-BRK-09 isolated four-form compatibility and form switching.
- NF-BRK-10 reviewed, reproducible release package and handoff.
- After BREAKER: second-recruit validation to prove reuse.

Generate a new phase-specific work packet using `python tools/art/build_character_work_order.py BREAKER "<bounded objective>" <new-output-path> --phase <phase>`; the generator does not approve or execute work.

## Mechanics guardrails

No changes to authoritative combat, formation, stats, economy, saves, or ability canon as a side effect of character tooling. Existing all-twelve ability contracts are provisional playtest defaults; functional level/stat growth is BREAKER-only pending evidence; wave 126 is a design-approved endless start but current runtime/save cap remains 125. Equipment attachments are event-driven and uniquely owned by actor instance; no phantom drones, duplicated weapons or invented combat effects.

## Current Neon Forge code status

Draft PR #2 adds:
- `tools/neon_forge/job_controller.py`: BREAKER four-form planning-only JSON job creation, validation and status reporting; exclusive create prevents overwrite.
- `tests/test_neon_forge_job_controller.py`: initial tests authored, **not executed or verified** in the connected environment.
- `tools/neon_forge/README.md`: scope and safety documentation.

This is **not** an autonomous asset generator, rig builder, or working editor plugin. No art, game scenes, approvals, gameplay, or main-branch files were modified by this scaffold. The PR is draft and unmerged.

## Next actions, in order

1. Project manager reads and acknowledges this handoff and reconciles newer work.
2. Run existing baseline and new Neon Forge tests in an actual project environment; report failures separately.
3. Audit Poly-Rig/editor integration and existing validator outputs.
4. Add read-only candidate discovery and structured reports.
5. Build quarantined review bundle orchestration and failure/resume tests.
6. Only then add explicitly authorized asset production, rig generation, animation, and release stages.

**Stop on missing source/canon decisions or unsafe actions. Do not mark a phase complete without its measured evidence.**
