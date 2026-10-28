# Neon Forge Core — experimental planning scaffold

This is an isolated first increment of the proposed AI-operated character production system. **It does not create artwork, rig characters, approve evidence, invoke paid services, or change runtime scenes.**

## Scope
- BREAKER only, four official forms: Origin, Adapted, Signature, Requiem.
- Five planning stages per form: source review, semantic parts, pivots and rig, animation review, production review.
- New JSON job file with exclusive creation, schema validation, read-only status display.
- Deliberately no automatic stage transitions or production approval.

From the Godot project root:

```powershell
python tools/neon_forge/job_controller.py init docs/work_orders/neon_forge_breaker_job.json
python tools/neon_forge/job_controller.py status docs/work_orders/neon_forge_breaker_job.json
python -m unittest tests.test_neon_forge_job_controller -v
```

The `init` command writes only to the explicitly chosen **new** JSON path. Do not run it against existing files. The `status` command is read-only.

## Next engineering steps
1. Audit Poly-Rig, Godot editor plugin, standard manifest adapter and test environment.
2. Add a read-only inventory of existing candidate manifests and evidence, using existing validators.
3. Add structured validation reports and quarantined review bundles, with no approvals.
4. Add explicit operator-authorized, resumable task execution and bounded retries.
5. Only after the above, prototype isolated rig builds and visual QA.

## Safety contract
Follow `AGENTS.md`, `docs/AI_CHARACTER_WORK_ORDERS.md`, `docs/CHARACTER_ART_PIPELINE.md`, and `docs/BREAKER_RIG_CONTRACT.md`. Current BREAKER Tier I art remains quarantined and not production-ready. A successful mechanical test never means visual approval. All four forms remain pending until source-backed evidence exists. Never modify combat simulation or saves as a side effect of production tooling.
