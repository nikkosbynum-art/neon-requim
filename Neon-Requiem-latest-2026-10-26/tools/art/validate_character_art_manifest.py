#!/usr/bin/env python3
"""Validate a manifest-driven character-art review set without promoting it."""

from __future__ import annotations

import argparse
from datetime import datetime
import hashlib
import json
import math
import re
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops


PRODUCTION_GATES = (
    "visible_art_approved",
    "hidden_anatomy_authored",
    "pivots_authored",
    "joint_seams_reviewed",
    "animation_reviewed",
)


def _is_pair_of_positive_ints(value: Any) -> bool:
    return (
        isinstance(value, list)
        and len(value) == 2
        and all(isinstance(item, int) and not isinstance(item, bool) and item > 0 for item in value)
    )


def _inside(root: Path, relative_path: Any) -> Path | None:
    if not isinstance(relative_path, str) or not relative_path.strip():
        return None
    candidate = (root / relative_path).resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError:
        return None
    return candidate


def _project_root(manifest_folder: Path) -> Path:
    folder = manifest_folder.resolve()
    for candidate in (folder, *folder.parents):
        if (candidate / "project.godot").is_file():
            return candidate
    return folder


def validate_manifest_data(
    manifest: dict[str, Any], root: Path, *, require_production: bool = False
) -> tuple[list[str], list[str], int | None]:
    """Return structural errors, production blockers, and measured union height."""
    errors: list[str] = []
    blockers: list[str] = []

    manifest_version = manifest.get("manifest_version")
    if not isinstance(manifest_version, int) or isinstance(manifest_version, bool) or manifest_version != 1:
        errors.append("manifest_version must be 1")
    character_id = manifest.get("character_id")
    if not isinstance(character_id, str) or not re.fullmatch(r"[A-Z][A-Z0-9_]*", character_id):
        errors.append("character_id must be a canonical uppercase roster ID")
    if (
        not isinstance(manifest.get("tier_id"), int)
        or isinstance(manifest.get("tier_id"), bool)
        or manifest.get("tier_id", 0) < 1
    ):
        errors.append("tier_id must be a positive integer")
    asset_status = manifest.get("asset_status")
    allowed_statuses = {"review_only", "production_candidate", "production_ready"}
    if not isinstance(asset_status, str) or asset_status not in allowed_statuses:
        errors.append("asset_status must be review_only, production_candidate, or production_ready")

    canvas = manifest.get("source_canvas_px")
    if not _is_pair_of_positive_ints(canvas):
        errors.append("source_canvas_px must contain two positive integers")
        canvas = None

    target_height = manifest.get("target_visible_height_px")
    measured_height_expected = manifest.get("measured_visible_height_px")
    if not isinstance(target_height, int) or isinstance(target_height, bool) or target_height < 1:
        errors.append("target_visible_height_px must be a positive integer")
    if (
        not isinstance(measured_height_expected, int)
        or isinstance(measured_height_expected, bool)
        or measured_height_expected < 1
    ):
        errors.append("measured_visible_height_px must be a positive integer")

    project_root = _project_root(root)
    source_path = _inside(project_root, manifest.get("source_reference"))
    if source_path is None or not source_path.is_file():
        errors.append("source_reference must resolve to a file inside the project folder")
    elif canvas:
        try:
            with Image.open(source_path) as source_image:
                if list(source_image.size) != canvas:
                    errors.append("source_reference dimensions do not match source_canvas_px")
        except OSError as exc:
            errors.append(f"source_reference cannot be decoded: {exc}")

    pivots = manifest.get("pivots_px")
    if not isinstance(pivots, dict) or not pivots:
        errors.append("pivots_px must be a non-empty object")
        pivots = {}
    for pivot_name, point in pivots.items():
        if (
            not isinstance(point, list)
            or len(point) != 2
            or not all(
                isinstance(axis, (int, float))
                and not isinstance(axis, bool)
                and math.isfinite(axis)
                for axis in point
            )
        ):
            errors.append(f"pivot {pivot_name!r} must be a finite [x, y] pair")
            continue
        if canvas and not (0 <= point[0] < canvas[0] and 0 <= point[1] < canvas[1]):
            errors.append(f"pivot {pivot_name!r} lies outside the source canvas")
    ground_pivot = manifest.get("ground_pivot")
    if ground_pivot is not None and (
        not isinstance(ground_pivot, str) or ground_pivot not in pivots
    ):
        errors.append("ground_pivot must name an authored entry in pivots_px")

    bones = manifest.get("bone_hierarchy")
    if not isinstance(bones, list) or not bones:
        errors.append("bone_hierarchy must be a non-empty ordered list")
        bones = []
    bone_names: set[str] = set()
    roots = 0
    for bone in bones:
        if not isinstance(bone, dict):
            errors.append("each bone_hierarchy entry must be an object")
            continue
        missing_bone_fields = {"name", "parent", "pivot", "parent_pivot"} - set(bone)
        if missing_bone_fields:
            errors.append(f"bone_hierarchy entry is missing required fields: {sorted(missing_bone_fields)}")
        name, parent = bone.get("name"), bone.get("parent")
        pivot, parent_pivot = bone.get("pivot"), bone.get("parent_pivot")
        if not isinstance(name, str) or not name:
            errors.append("each bone requires a non-empty name")
            continue
        if name in bone_names:
            errors.append(f"duplicate bone name: {name}")
        if parent is None:
            roots += 1
        elif not isinstance(parent, str) or parent not in bone_names:
            errors.append(f"bone {name} parent {parent!r} must appear earlier in bone_hierarchy")
        if not isinstance(pivot, str) or pivot not in pivots:
            errors.append(f"bone {name} references unknown pivot {pivot!r}")
        if parent is not None and (not isinstance(parent_pivot, str) or parent_pivot not in pivots):
            errors.append(f"bone {name} references unknown parent_pivot {parent_pivot!r}")
        bone_names.add(name)
    if roots != 1:
        errors.append("bone_hierarchy must contain exactly one root")

    parts = manifest.get("parts")
    if not isinstance(parts, list) or not parts:
        errors.append("parts must be a non-empty ordered list")
        parts = []
    part_names: list[str] = []
    seen_names: set[str] = set()
    seen_files: set[str] = set()
    seen_draw_orders: set[int] = set()
    union_alpha: Image.Image | None = Image.new("L", tuple(canvas), 0) if canvas else None
    for part in parts:
        if not isinstance(part, dict):
            errors.append("each part entry must be an object")
            continue
        missing_part_fields = {"name", "file", "parent_bone", "pivot", "draw_order", "alpha_mode"} - set(part)
        if missing_part_fields:
            errors.append(f"part entry is missing required fields: {sorted(missing_part_fields)}")
        name, filename = part.get("name"), part.get("file")
        if not isinstance(name, str) or not name:
            errors.append("each part requires a non-empty name")
            continue
        part_names.append(name)
        if name in seen_names:
            errors.append(f"duplicate part name: {name}")
        seen_names.add(name)
        path = _inside(root, filename)
        if path is None:
            errors.append(f"part {name} file must remain inside the manifest folder")
            continue
        if filename in seen_files:
            errors.append(f"duplicate part file: {filename}")
        seen_files.add(filename)
        if not path.is_file():
            errors.append(f"part {name} file not found: {filename}")
            continue
        parent_bone = part.get("parent_bone")
        if not isinstance(parent_bone, str) or parent_bone not in bone_names:
            errors.append(f"part {name} references unknown parent_bone {parent_bone!r}")
        part_pivot = part.get("pivot")
        if not isinstance(part_pivot, str) or part_pivot not in pivots:
            errors.append(f"part {name} references unknown pivot {part_pivot!r}")
        draw_order = part.get("draw_order")
        if not isinstance(draw_order, int) or isinstance(draw_order, bool):
            errors.append(f"part {name} draw_order must be an integer")
        elif draw_order in seen_draw_orders:
            errors.append(f"duplicate draw_order: {draw_order}")
        else:
            seen_draw_orders.add(draw_order)
        try:
            with Image.open(path) as opened:
                image = opened.convert("RGBA")
                if canvas and list(image.size) != canvas:
                    errors.append(f"part {name} dimensions {image.size} do not match {tuple(canvas)}")
                if part.get("alpha_mode") != "transparent_cutout":
                    errors.append(f"part {name} alpha_mode must be transparent_cutout")
                alpha = image.getchannel("A")
                if alpha.getbbox() is None:
                    errors.append(f"part {name} is fully transparent")
                elif union_alpha is not None:
                    union_alpha = ImageChops.lighter(union_alpha, alpha)
        except OSError as exc:
            errors.append(f"part {name} cannot be decoded: {exc}")

    if part_names:
        expected_order = manifest.get("layers_back_to_front")
        ordered_parts = sorted(parts, key=lambda part: part.get("draw_order", -1) if isinstance(part, dict) else -1)
        order_from_parts = [part.get("name") for part in ordered_parts if isinstance(part, dict)]
        if expected_order != order_from_parts:
            errors.append("layers_back_to_front must match parts sorted by draw_order")

    measured_height: int | None = None
    if union_alpha is not None and union_alpha.getbbox():
        bbox = union_alpha.getbbox()
        measured_height = bbox[3] - bbox[1]
        if measured_height_expected != measured_height:
            errors.append(
                f"measured_visible_height_px says {measured_height_expected}, but part alpha union is {measured_height}"
            )

    source_hash = manifest.get("source_reference_sha256")
    if source_hash is not None:
        if not isinstance(source_hash, str) or not re.fullmatch(r"[A-Fa-f0-9]{64}", source_hash):
            errors.append("source_reference_sha256 must be a 64-character SHA-256 hex string")
        elif source_path is not None and source_path.is_file():
            actual_hash = hashlib.sha256(source_path.read_bytes()).hexdigest()
            if actual_hash.lower() != source_hash.lower():
                blockers.append("source_reference_hash_mismatch")

    gates = manifest.get("production_gates")
    if not isinstance(gates, dict):
        errors.append("production_gates must be an object")
        gates = {}
    else:
        missing_gates = set(PRODUCTION_GATES) - set(gates)
        if missing_gates:
            errors.append(f"production_gates is missing required fields: {sorted(missing_gates)}")
        for gate_name in PRODUCTION_GATES:
            if gate_name in gates and not isinstance(gates[gate_name], bool):
                errors.append(f"production_gates.{gate_name} must be a boolean")
        blockers.extend(name for name in PRODUCTION_GATES if gates.get(name) is not True)

        gate_evidence = manifest.get("production_gate_evidence", {})
        if not isinstance(gate_evidence, dict):
            blockers.append("production_gate_evidence_invalid")
            gate_evidence = {}
        any_approved = any(gates.get(name) is True for name in PRODUCTION_GATES)
        if any_approved and not source_hash:
            blockers.append("source_reference_hash_missing")
        for gate_name in PRODUCTION_GATES:
            if gates.get(gate_name) is not True:
                continue
            record = gate_evidence.get(gate_name)
            if not isinstance(record, dict):
                blockers.append(f"missing_gate_evidence:{gate_name}")
                continue
            reviewer = record.get("reviewer")
            if not isinstance(reviewer, str) or not reviewer.strip():
                blockers.append(f"invalid_gate_reviewer:{gate_name}")
            reviewed_at = record.get("reviewed_at")
            try:
                parsed_date = datetime.fromisoformat(str(reviewed_at).replace("Z", "+00:00"))
                if parsed_date.tzinfo is None:
                    raise ValueError("timestamp has no timezone")
            except (TypeError, ValueError):
                blockers.append(f"invalid_gate_timestamp:{gate_name}")
            evidence_paths = record.get("evidence_paths")
            if not isinstance(evidence_paths, list) or not evidence_paths:
                blockers.append(f"missing_gate_evidence_files:{gate_name}")
            else:
                for evidence_path in evidence_paths:
                    resolved = _inside(project_root, evidence_path)
                    if resolved is None or not resolved.is_file():
                        blockers.append(f"invalid_gate_evidence_file:{gate_name}")
                        break
    if manifest.get("asset_status") != "production_ready":
        blockers.append("asset_status_not_production_ready")
    # Production readiness remains a separate gate: callers can verify a
    # quarantined manifest without confusing structural validity with art approval.
    # The CLI maps blockers to exit status 2 when --require-production is set.
    return errors, sorted(set(blockers)), measured_height


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, help="Path to a character art manifest JSON file")
    parser.add_argument("--require-production", action="store_true", help="Fail unless production gates are all complete")
    args = parser.parse_args()
    manifest_path = args.manifest.resolve()
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"FAIL: could not read manifest: {exc}")
        return 1
    if not isinstance(manifest, dict):
        print("FAIL: manifest root must be a JSON object")
        return 1

    errors, blockers, measured_height = validate_manifest_data(
        manifest, manifest_path.parent, require_production=args.require_production
    )
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(
        f"PASS: {manifest['character_id']} Tier {manifest['tier_id']} manifest structure; "
        f"{len(manifest['parts'])} RGBA parts share {tuple(manifest['source_canvas_px'])} canvas; "
        f"visible union {measured_height}px."
    )
    print(f"ART STATUS: {manifest['asset_status']}")
    if blockers:
        print("PRODUCTION GATE BLOCKED: " + ", ".join(blockers))
        return 2 if args.require_production else 0
    print("PASS: all declared production gates are complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
