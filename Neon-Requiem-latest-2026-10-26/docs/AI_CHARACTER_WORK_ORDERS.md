# AI-assisted character work orders

Use `tools/art/build_character_work_order.py` to make a focused work packet before asking an AI agent to advance a character-art task. The packet gathers local planning facts and project guardrails in one place so the agent can work against a bounded objective instead of repeatedly rediscovering broad project context.

From the project root:

```powershell
python tools/art/build_character_work_order.py CIPHER "Review one corrected candidate against the semantic intake stop rule" docs/work_orders/CIPHER_T1_SEMANTIC_INTAKE_01.md --phase semantic intake
```

The output path must be new and inside the project. The generator will not overwrite an existing work order. After generation, fill in the deliverable path, in-scope changes, acceptance criteria, evidence, and unresolved questions before sending the packet to an agent. Keep one character and one workflow phase per packet; create a new packet for a new phase rather than appending an open-ended task.

## Work-order loop

1. **Frame:** state one concrete objective and one bounded deliverable.
2. **Ground:** check the generated source references and candidate status against the current approved project documents. Reconcile with canonical sources when access is available; local planning metadata can lag.
3. **Execute:** make the smallest change that satisfies the acceptance criteria. Avoid broad cleanup and avoid repeated generation when evidence is missing.
4. **Check separately:** report mechanical checks, runtime/engine checks, and visual review as separate evidence. A screenshot does not prove behavior, and a passing structural audit does not prove art quality.
5. **Stop or hand off:** stop at the first unresolved source/canon conflict or semantic intake failure; state the exact correction and owner needed. Do not promote art or alter production gates through the work-order generator.
6. **Close:** update the project status/asset/migration/sync documents when implementation changes, refresh local staging copies, and report what was actually validated.

The generator uses `tools/art/rigging_prep_all_12.json`, which is explicitly planning metadata and may be reconstructed or stale. It does not fetch Notion/Drive, create art, determine semantic correctness, approve production readiness, run tests, or spend credits. Project-wide rules in `AGENTS.md` and current design decisions take precedence over the generated packet.
