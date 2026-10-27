#!/usr/bin/env python3
"""Build a bounded, source-grounded work order for one character-art task."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PLAN = PROJECT_ROOT / "tools" / "art" / "rigging_prep_all_12.json"


def _project_path(value: str | Path) -> Path:
    candidate = Path(value)
    if not candidate.is_absolute():
        candidate = PROJECT_ROOT / candidate
    resolved = candidate.resolve()
    try:
        resolved.relative_to(PROJECT_ROOT.resolve())
    except ValueError as exc:
        raise ValueError("Paths must remain inside the project.") from exc
    return resolved


def _bullet_list(items: Any, fallback: str = "- None recorded.") -> str:
    if not isinstance(items, list) or not items:
        return fallback
    return "\n".join(f"- {str(item).strip()}" for item in items)


def _attachment_summary(records: Any) -> str:
    if not isinstance(records, list) or not records:
        return "- No attachment contracts recorded."
    lines: list[str] = []
    for record in records:
        if not isinstance(record, dict):
            continue
        name = record.get("id", "unnamed")
        kind = record.get("kind", "unspecified")
        behavior = record.get("known_behavior", "No behavior recorded.")
        lines.append(f"- **{name} ({kind}):** {behavior}")
        for unknown in record.get("unknowns", []):
            lines.append(f"  - Open: {unknown}")
    return "\n".join(lines) if lines else "- No attachment contracts recorded."


def build_work_order(
    plan_file: Path,
    character_id: str,
    objective: str,
    phase: str,
    output_file: Path,
) -> Path:
    data = json.loads(plan_file.read_text(encoding="utf-8"))
    records = data.get("characters") if isinstance(data, dict) else None
    if not isinstance(records, list):
        raise ValueError("Rigging prep input must contain a characters list.")
    character = next(
        (record for record in records if isinstance(record, dict) and str(record.get("id", "")).casefold() == character_id.casefold()),
        None,
    )
    if character is None:
        valid = ", ".join(str(record.get("id")) for record in records if isinstance(record, dict))
        raise ValueError(f"Unknown character {character_id!r}. Choose one of: {valid}")
    if output_file.exists():
        raise FileExistsError(f"Refusing to overwrite existing work order: {output_file}")

    references = [
        f"`{character.get('concept_reference', 'UNRESOLVED')}` — concept / visible identity source",
        f"`{character.get('anatomy_reference', 'UNRESOLVED')}` — anatomy source",
    ]
    content = f"""# {character['id']} Tier I work order

**Phase:** {phase}
**Status:** Draft work order; generated from local planning metadata, not an art approval.

## Task contract

**Objective:** {objective.strip()}

Before starting, fill in every blank below. If the answer is not supported by the approved source, mark it unresolved rather than inventing it.

- **One bounded deliverable:** TODO — name one candidate, document, or tool output and its exact path.
- **In scope:** TODO — list only the changes needed for this objective.
- **Out of scope:** Other characters, tiers, runtime integration, design/canon changes, unrelated cleanup.
- **Acceptance criteria:** TODO — specify observable checks and expected results.
- **Evidence to return:** TODO — list file paths, command output, or human-review images needed to assess the criteria.
- **Stop condition:** Stop and report the unresolved source issue if required parts are missing, clipped, duplicated, ambiguously owned, or unsupported. Do not continue with another generation/extraction loop to hide missing evidence.

## Source context

The following data is copied from `tools/art/rigging_prep_all_12.json`, a planning contract. It is not a substitute for the live canonical source when available.

### References

{_bullet_list(references)}

### Existing candidate and recorded status

- Candidate: `{character.get('existing_candidate', 'UNRECORDED')}`
- Status: {character.get('candidate_status', 'UNRECORDED')}
- Priority note: {character.get('priority_note', 'None recorded.')}

### Character-specific rig concerns

{_bullet_list(character.get('special_rig_items'))}

### Attachment context and open details

{_attachment_summary(character.get('functional_attachment_contract'))}

## Project rules

- Read `docs/DESIGN_DECISIONS.md`, `docs/IMPLEMENTATION_STATUS.md`, and `docs/CHARACTER_PART_AUTHORING_GUIDE.md` before editing. Use character-specific approved references and any required source checks stated in `AGENTS.md`.
- Approved visual references guide visible design only. Do not infer hidden anatomy, semantics, pivots, or production readiness from a flattened reference or generated image.
- Keep all new art and review candidates quarantined. Do not change runtime scenes or production gates in this task.
- Keep simulation authoritative; presentation work must not add manual targeting or player-triggered abilities.
- Separate mechanical results, runtime behavior, visual judgments, and production approval in the report. A successful script, clean alpha audit, or plausible screenshot proves only the check it actually performs.
- Reuse standard anchors when they fit; record a source-backed anatomy exception when they do not.
- Spend no paid generation/API credits for this task unless the user separately approves a concrete cost and expected benefit. Prefer existing local tools and stop if the objective depends on a paid service.

## Review record

- **Mechanical checks and results:** TODO
- **Runtime checks and results:** TODO (or mark not applicable)
- **Visual review and reviewer:** TODO (or mark not performed)
- **Production gate impact:** None unless separately approved with evidence.
- **Unresolved questions / next owner:** TODO

## Shared gate reference

{_bullet_list(data.get('shared_validation_gates'))}

Use only the gates relevant to this task. This work order does not require unrelated gates to be completed and cannot itself approve the candidate.
"""
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(content, encoding="utf-8", newline="\n")
    return output_file


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("character", help="Roster character ID, e.g. CIPHER")
    parser.add_argument("objective", help="One bounded task objective")
    parser.add_argument("output", help="New project-relative Markdown output path")
    parser.add_argument("--phase", default="candidate intake", help="Workflow phase label")
    parser.add_argument("--plan", default=str(DEFAULT_PLAN), help="Project-relative roster plan JSON")
    args = parser.parse_args()

    try:
        plan = _project_path(args.plan)
        output = _project_path(args.output)
        if not plan.is_file():
            raise FileNotFoundError(f"Planning contract not found: {plan}")
        created = build_work_order(plan, args.character, args.objective, args.phase, output)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 2
    print(f"Created draft work order: {created.relative_to(PROJECT_ROOT).as_posix()}")
    print("It is not an art approval or production gate.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
