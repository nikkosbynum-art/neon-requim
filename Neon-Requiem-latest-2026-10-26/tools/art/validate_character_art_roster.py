#!/usr/bin/env python3
"""Audit submitted character-art manifests against the founding roster."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tools.art.validate_character_art_manifest import validate_manifest_data


ROSTER_PATH = Path(__file__).with_name("character_art_roster.json")
CANONICAL_ROSTER_IDS = (
    "BULWARK", "BREAKER", "CIPHER", "SPARK", "SPECTER", "IRONCLAD",
    "STITCH", "RECOIL", "ECHO", "VECTOR", "DEADLOCK", "GLITCH",
)
STANDARD_MANIFEST_FILENAME = "character_art_manifest.json"
CHARACTER_ASSETS_DIR = Path("assets/characters")


def _inside(root: Path, relative_path: Any) -> Path | None:
    if not isinstance(relative_path, str) or not relative_path.strip():
        return None
    candidate = (root / relative_path).resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError:
        return None
    return candidate


def load_roster(path: Path = ROSTER_PATH) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("roster root must be a JSON object")
    return value


def audit_roster(
    roster: dict[str, Any],
    project_root: Path,
    *,
    require_all: bool = False,
    require_production: bool = False,
) -> dict[str, Any]:
    """Return roster intake statuses and integrity errors without creating files."""
    errors: list[str] = []
    characters = roster.get("characters")
    if roster.get("roster_schema_version") != 1 or isinstance(roster.get("roster_schema_version"), bool):
        errors.append("roster_schema_version must be 1")
    source = roster.get("source")
    if not isinstance(source, dict) or not isinstance(source.get("url"), str) or not source["url"].startswith("https://"):
        errors.append("source.url must preserve the canonical roster URL")
    if roster.get("manifest_filename") != STANDARD_MANIFEST_FILENAME:
        errors.append(f"manifest_filename must be {STANDARD_MANIFEST_FILENAME!r}")
    required_tier_ids = roster.get("required_tier_ids")
    if (
        not isinstance(required_tier_ids, list)
        or not required_tier_ids
        or any(not isinstance(tier, int) or isinstance(tier, bool) or tier < 1 for tier in required_tier_ids)
        or len(set(required_tier_ids)) != len(required_tier_ids)
    ):
        errors.append("required_tier_ids must be a non-empty list of unique positive integers")
        required_tier_ids = [1]
    if not isinstance(characters, list):
        errors.append("characters must be an ordered list")
        characters = []

    ids: list[str] = []
    entries_by_id: dict[str, dict[str, Any]] = {}
    for index, entry in enumerate(characters):
        if not isinstance(entry, dict):
            errors.append(f"characters[{index}] must be an object")
            continue
        character_id = entry.get("character_id")
        if not isinstance(character_id, str) or not re.fullmatch(r"[A-Z][A-Z0-9_]*", character_id):
            errors.append(f"characters[{index}].character_id must be a canonical uppercase roster ID")
            continue
        if character_id in entries_by_id:
            errors.append(f"duplicate roster character_id: {character_id}")
        ids.append(character_id)
        entries_by_id[character_id] = entry
        if not isinstance(entry.get("manifest_paths", []), list):
            errors.append(f"{character_id}.manifest_paths must be a list")

    if len(ids) != len(CANONICAL_ROSTER_IDS) or set(ids) != set(CANONICAL_ROSTER_IDS):
        missing_ids = sorted(set(CANONICAL_ROSTER_IDS) - set(ids))
        unknown_ids = sorted(set(ids) - set(CANONICAL_ROSTER_IDS))
        errors.append(f"roster must contain the canonical twelve IDs; missing={missing_ids}, unknown={unknown_ids}")

    character_root = (project_root / CHARACTER_ASSETS_DIR).resolve()
    known_slugs = {character_id.lower() for character_id in CANONICAL_ROSTER_IDS}
    rows: list[dict[str, Any]] = []
    seen_paths: set[Path] = set()
    missing_count = 0
    missing_required_tier_count = 0
    blocker_count = 0

    # Only the new standard filename is discovered recursively. Older BREAKER
    # experiments use pivot_manifest.json and are ignored unless explicitly listed
    # as review-only pilots in the roster file.
    if character_root.is_dir():
        for manifest_path in character_root.rglob(STANDARD_MANIFEST_FILENAME):
            try:
                relative = manifest_path.resolve().relative_to(character_root)
                slug = relative.parts[0].lower() if relative.parts else ""
                if slug not in known_slugs:
                    errors.append(f"standard manifest is outside a founding-recruit folder: {manifest_path}")
            except ValueError:
                errors.append(f"standard manifest resolves outside the characters folder: {manifest_path}")

    for character_id in CANONICAL_ROSTER_IDS:
        entry = entries_by_id.get(character_id)
        if entry is None:
            rows.append({"character_id": character_id, "status": "ROSTER ENTRY MISSING", "manifests": []})
            continue
        slug_root = (character_root / character_id.lower()).resolve()
        candidates: set[Path] = set()
        if slug_root.is_dir():
            for discovered in slug_root.rglob(STANDARD_MANIFEST_FILENAME):
                try:
                    discovered.resolve().relative_to(slug_root)
                    candidates.add(discovered.resolve())
                except ValueError:
                    errors.append(f"{character_id}: manifest resolves outside its character folder: {discovered}")

        explicit_paths = entry.get("manifest_paths", [])
        if not isinstance(explicit_paths, list):
            explicit_paths = []
        for relative_path in explicit_paths:
            candidate = _inside(project_root, relative_path)
            if candidate is None:
                errors.append(f"{character_id}: manifest path escapes the project or is invalid: {relative_path!r}")
                continue
            try:
                candidate.relative_to(slug_root)
            except ValueError:
                errors.append(f"{character_id}: explicitly listed manifest is outside its character folder: {relative_path}")
                continue
            if not candidate.is_file():
                errors.append(f"{character_id}: explicitly listed manifest does not exist: {relative_path}")
                continue
            candidates.add(candidate)

        duplicate_tiers: set[int] = set()
        seen_tiers: set[int] = set()
        manifest_results: list[dict[str, Any]] = []
        for manifest_path in sorted(candidates):
            if manifest_path in seen_paths:
                errors.append(f"manifest is assigned to more than one roster entry: {manifest_path}")
            seen_paths.add(manifest_path)
            result: dict[str, Any] = {
                "path": str(manifest_path.relative_to(project_root.resolve())),
                "status": "INVALID",
                "errors": [],
                "blockers": [],
            }
            try:
                manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError) as exc:
                result["errors"] = [f"could not read manifest: {exc}"]
                errors.append(f"{result['path']}: {result['errors'][0]}")
                manifest_results.append(result)
                continue
            if not isinstance(manifest, dict):
                result["errors"] = ["manifest root must be a JSON object"]
                errors.append(f"{result['path']}: {result['errors'][0]}")
                manifest_results.append(result)
                continue
            manifest_id = manifest.get("character_id")
            if manifest_id != character_id:
                result["errors"].append(f"character_id {manifest_id!r} does not match roster ID {character_id}")
            tier_id = manifest.get("tier_id")
            if isinstance(tier_id, int) and not isinstance(tier_id, bool):
                result["tier_id"] = tier_id
                if tier_id in seen_tiers:
                    duplicate_tiers.add(tier_id)
                seen_tiers.add(tier_id)
            structural_errors, blockers, measured_height = validate_manifest_data(manifest, manifest_path.parent)
            result["errors"].extend(structural_errors)
            result["blockers"] = blockers
            result["asset_status"] = manifest.get("asset_status")
            result["measured_visible_height_px"] = measured_height
            if duplicate_tiers:
                # Keep processing all entries; mark tier duplicates after the loop below.
                pass
            if result["errors"]:
                result["status"] = "INVALID"
                errors.extend(f"{result['path']}: {message}" for message in result["errors"])
            else:
                result["status"] = str(manifest.get("asset_status", "UNKNOWN")).upper()
            if result["blockers"]:
                blocker_count += 1
            manifest_results.append(result)

        for duplicate_tier in duplicate_tiers:
            matching = [item for item in manifest_results if item.get("tier_id") == duplicate_tier]
            for item in matching:
                message = f"duplicate tier_id {duplicate_tier} for {character_id}"
                item["errors"].append(message)
                item["status"] = "INVALID"
            errors.append(f"{character_id}: duplicate tier_id {duplicate_tier}")

        if not manifest_results:
            missing_count += 1
            missing_tiers = list(required_tier_ids)
            missing_required_tier_count += len(missing_tiers)
            rows.append({
                "character_id": character_id,
                "status": "NOT SUBMITTED",
                "missing_required_tiers": missing_tiers,
                "manifests": [],
            })
        else:
            present_tiers = {item["tier_id"] for item in manifest_results if isinstance(item.get("tier_id"), int)}
            missing_tiers = [tier for tier in required_tier_ids if tier not in present_tiers]
            missing_required_tier_count += len(missing_tiers)
            status = "INCOMPLETE" if missing_tiers else "SUBMITTED"
            rows.append({
                "character_id": character_id,
                "status": status,
                "missing_required_tiers": missing_tiers,
                "manifests": manifest_results,
            })

    return {
        "errors": errors,
        "characters": rows,
        "missing_count": missing_count,
        "missing_required_tier_count": missing_required_tier_count,
        "blocker_count": blocker_count,
        "require_all": require_all,
        "require_production": require_production,
    }


def _exit_code(report: dict[str, Any]) -> int:
    if report["errors"]:
        return 1
    if report["require_all"] and report["missing_required_tier_count"]:
        return 2
    if report["require_production"] and (report["missing_required_tier_count"] or report["blocker_count"]):
        return 3
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=PROJECT_ROOT)
    parser.add_argument("--roster", type=Path, default=ROSTER_PATH)
    parser.add_argument("--require-all", action="store_true", help="Fail if any founding recruit has no manifest")
    parser.add_argument("--require-production", action="store_true", help="Fail if any roster entry lacks a production-ready manifest")
    parser.add_argument("--json", action="store_true", help="Print a machine-readable audit report")
    args = parser.parse_args(argv)
    project_root = args.project_root.resolve()
    try:
        roster = load_roster(args.roster)
        report = audit_roster(
            roster,
            project_root,
            require_all=args.require_all,
            require_production=args.require_production,
        )
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(report, indent=2))
    else:
        for row in report["characters"]:
            print(f"{row['character_id']}: {row['status']}")
            for manifest in row["manifests"]:
                tier = manifest.get("tier_id", "?")
                print(f"  Tier {tier}: {manifest['status']} - {manifest['path']}")
                for message in manifest["errors"]:
                    print(f"    ERROR: {message}")
                if manifest["blockers"]:
                    print(f"    PRODUCTION GATE BLOCKED: {', '.join(manifest['blockers'])}")
        required_tiers = roster.get("required_tier_ids", [1])
        print(
            f"Required Tier {', '.join(str(tier) for tier in required_tiers)} coverage: "
            f"{len(report['characters']) - report['missing_required_tier_count']}/12 complete; "
            f"{report['missing_required_tier_count']} required tier manifest(s) missing."
        )
        for error in report["errors"]:
            print(f"ERROR: {error}")

    code = _exit_code(report)
    if code == 0:
        message = "PASS: roster intake audit completed; missing art remains an explicit status, not a fabricated manifest."
    elif code == 2:
        message = "FAIL: one or more founding recruits do not have every required tier manifest."
    elif code == 3:
        message = "FAIL: production readiness is incomplete for one or more founding recruits."
    else:
        message = "FAIL: roster or manifest integrity errors were found."
    print(message, file=sys.stderr if args.json else sys.stdout)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
