"""Neon Forge: isolated, resumable, fail-closed character production jobs.

Planning/validation orchestration only. Never writes runtime assets or approvals.
"""
from __future__ import annotations
import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

FORMS = ("Origin Form", "Adapted Form", "Signature Form", "Requiem Form")
STAGES = ("source_review", "semantic_parts", "pivots_and_rig", "animation_review", "production_review")
VALID_STATES = ("pending", "blocked", "ready_for_review", "approved")
SCHEMA_VERSION = 1


def new_job(character: str = "BREAKER") -> dict:
    if character != "BREAKER":
        raise ValueError("v0 supports BREAKER only")
    return {
        "schema_version": SCHEMA_VERSION,
        "character_id": character,
        "mode": "planning_only",
        "forms": {
            str(i): {"name": name, "stages": {stage: {"status": "pending", "evidence": []}
                                              for stage in STAGES}}
            for i, name in enumerate(FORMS, 1)
        },
        "events": [],
    }


def validate_job(job: dict) -> None:
    if job.get("schema_version") != SCHEMA_VERSION or job.get("character_id") != "BREAKER":
        raise ValueError("Unsupported job schema or character")
    if job.get("mode") != "planning_only":
        raise ValueError("Unsafe job mode")
    if set(job.get("forms", {})) != {"1", "2", "3", "4"}:
        raise ValueError("Missing or unexpected forms")
    for i, form in job["forms"].items():
        if form.get("name") != FORMS[int(i)-1] or set(form.get("stages", {})) != set(STAGES):
            raise ValueError("Form contract mismatch")
        for stage in form["stages"].values():
            if stage.get("status") not in VALID_STATES or not isinstance(stage.get("evidence"), list):
                raise ValueError("Invalid stage state")


def save_new_job(path: Path, job: dict) -> None:
    validate_job(job)
    path.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive creation: never overwrite another production record.
    with path.open("x", encoding="utf-8") as out:
        json.dump(job, out, indent=2)
        out.write("\n")


def load_job(path: Path) -> dict:
    job = json.loads(path.read_text(encoding="utf-8"))
    validate_job(job)
    return job


def report(job: dict) -> str:
    validate_job(job)
    lines = ["Neon Forge / BREAKER / planning only"]
    for tier, form in job["forms"].items():
        summary = ", ".join(f"{stage}: {details['status']}"
                            for stage, details in form["stages"].items())
        lines.append(f"Tier {tier} - {form['name']}: {summary}")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("init", "status"))
    parser.add_argument("job_file", type=Path)
    args = parser.parse_args()
    if args.command == "init":
        save_new_job(args.job_file, new_job())
        print(f"Created planning-only job: {args.job_file}")
    else:
        print(report(load_job(args.job_file)))


if __name__ == "__main__":
    main()
