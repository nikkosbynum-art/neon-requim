#!/usr/bin/env python3
"""Build a non-approving review bundle for a standard character-art manifest."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys
from typing import Any

from PIL import Image, ImageChops

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tools.art.audit_semantic_cutout import audit_cutout
from tools.art.render_semantic_part_contact_sheet import render_contact_sheet
from tools.art.validate_character_art_manifest import (
    _inside,
    _project_root,
    validate_manifest_data,
)


GATE_LABELS = {
    "visible_art_approved": "Compare visible identity and proportions with approved references.",
    "hidden_anatomy_authored": "Confirm hidden anatomy and overlap paint are authored and provenance-labeled.",
    "pivots_authored": "Confirm pivots are artist-authored and match the declared bone hierarchy.",
    "joint_seams_reviewed": "Inspect seams and contact through the required joint ranges.",
    "animation_reviewed": "Review authored clips at full size and gameplay scale.",
}


def _project_relative(path: Path) -> str:
    return path.resolve().relative_to(PROJECT_ROOT.resolve()).as_posix()


def _write_json(path: Path, value: Any) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def _build_visual_diagnostics(
    manifest_path: Path,
    output_dir: Path,
    manifest: dict[str, Any],
) -> dict[str, Any]:
    diagnostics: dict[str, Any] = {"contact_sheet": None, "assembly": None, "ownership_overlap": None}
    contact_path = output_dir / "part_contact_sheet.png"
    try:
        sheet = render_contact_sheet(manifest_path.parent, contact_path, columns=2)
        diagnostics["contact_sheet"] = {"status": "RENDERED", **sheet}
    except Exception as exc:  # Keep the report useful when an optional preview cannot render.
        diagnostics["contact_sheet"] = {"status": "UNAVAILABLE", "reason": str(exc)}

    canvas = manifest.get("source_canvas_px")
    parts = manifest.get("parts")
    if (
        not isinstance(canvas, list)
        or len(canvas) != 2
        or not all(isinstance(value, int) and value > 0 for value in canvas)
        or not isinstance(parts, list)
        or not parts
    ):
        diagnostics["assembly"] = {"status": "UNAVAILABLE", "reason": "Canvas or parts list is invalid."}
        diagnostics["ownership_overlap"] = {"status": "UNAVAILABLE", "reason": "Canvas or parts list is invalid."}
        return diagnostics

    size = (canvas[0], canvas[1])
    assembly = Image.new("RGBA", size, (0, 0, 0, 0))
    union = Image.new("L", size, 0)
    ownership = Image.new("L", size, 0)
    overlap = Image.new("L", size, 0)
    skipped: list[str] = []
    for record in sorted(
        (item for item in parts if isinstance(item, dict)),
        key=lambda item: item.get("draw_order", -1) if isinstance(item.get("draw_order"), int) else -1,
    ):
        name = str(record.get("name", "<unnamed>"))
        part_path = _inside(manifest_path.parent, record.get("file"))
        if part_path is None or not part_path.is_file():
            skipped.append(name)
            continue
        try:
            with Image.open(part_path) as opened:
                part = opened.convert("RGBA")
        except OSError:
            skipped.append(name)
            continue
        if part.size != size:
            skipped.append(name)
            continue
        mask = part.getchannel("A").point(lambda value: 255 if value >= 32 else 0)
        overlap = ImageChops.lighter(overlap, ImageChops.multiply(ownership, mask))
        ownership = ImageChops.lighter(ownership, mask)
        union = ImageChops.lighter(union, part.getchannel("A"))
        assembly.alpha_composite(part)

    assembly_path = output_dir / "assembled_review_candidate.png"
    assembly.save(assembly_path)
    diagnostics["assembly"] = {
        "status": "RENDERED" if not skipped else "PARTIAL",
        "path": _project_relative(assembly_path),
        "skipped_parts": skipped,
        "scope": "static back-to-front alpha assembly only; no anatomy or pivot approval",
    }

    overlap_path = output_dir / "overlap_diagnostic.png"
    overlap_image = Image.new("RGBA", size, (0, 0, 0, 0))
    overlap_image.putalpha(overlap.point(lambda value: 180 if value else 0))
    overlap_image.save(overlap_path)
    overlap_pixels = overlap.histogram()[255]
    diagnostics["ownership_overlap"] = {
        "status": "MEASURED" if not skipped else "PARTIAL",
        "path": _project_relative(overlap_path),
        "multiply_owned_pixels_at_alpha_32": overlap_pixels,
        "scope": "mechanical overlap diagnostic; intentional joint overlays require human interpretation",
    }

    union_path = output_dir / "union_alpha_review.png"
    union_image = Image.new("RGBA", size, (255, 255, 255, 0))
    union_image.putalpha(union)
    union_image.save(union_path)
    try:
        alpha_report = audit_cutout(union_path)
        diagnostics["union_alpha_audit"] = {
            "status": alpha_report.get("status", "UNAVAILABLE"),
            "report": alpha_report,
            "scope": "mechanical union-alpha bounds and margin checks only",
        }
    except Exception as exc:
        diagnostics["union_alpha_audit"] = {"status": "UNAVAILABLE", "reason": str(exc)}
    return diagnostics


def build_review_bundle(manifest_file: Path, output: Path) -> dict[str, Any]:
    manifest_file = manifest_file.resolve()
    output = output.resolve()
    try:
        manifest_file.relative_to(PROJECT_ROOT.resolve())
        output.relative_to(PROJECT_ROOT.resolve())
    except ValueError as exc:
        raise ValueError("Manifest and output must remain inside the project.") from exc
    if not manifest_file.is_file() or manifest_file.name != "character_art_manifest.json":
        raise ValueError("Input must be an existing character_art_manifest.json file.")
    if output.exists():
        raise FileExistsError(f"Refusing to overwrite existing review bundle: {output}")
    try:
        output.relative_to(manifest_file.parent.resolve())
    except ValueError:
        pass
    else:
        raise ValueError("Review bundle output must be outside the source candidate folder.")

    manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
    if not isinstance(manifest, dict):
        raise ValueError("Manifest root must be an object.")
    errors, blockers, measured_height = validate_manifest_data(manifest, manifest_file.parent)
    output.mkdir(parents=True, exist_ok=False)
    diagnostics = _build_visual_diagnostics(manifest_file, output, manifest)
    project_root = _project_root(manifest_file.parent)
    source_path = _inside(project_root, manifest.get("source_reference"))
    source_hash = None
    if source_path is not None and source_path.is_file():
        source_hash = hashlib.sha256(source_path.read_bytes()).hexdigest()

    gates = manifest.get("production_gates", {})
    gate_evidence = manifest.get("production_gate_evidence", {})
    manual_gates = {}
    for key, label in GATE_LABELS.items():
        flagged_true = isinstance(gates, dict) and gates.get(key) is True
        evidence_blocker = (
            "source_reference_hash_mismatch" in blockers
            or "source_reference_hash_missing" in blockers
            or any(item.endswith(":" + key) for item in blockers)
        )
        if flagged_true and not evidence_blocker and isinstance(gate_evidence, dict) and isinstance(gate_evidence.get(key), dict):
            gate_status = "RECORDED_WITH_EVIDENCE"
        elif flagged_true:
            gate_status = "FLAGGED_TRUE_BUT_EVIDENCE_BLOCKED"
        else:
            gate_status = "NEEDS_HUMAN_REVIEW"
        manual_gates[key] = {"status": gate_status, "review_instruction": label}
    report = {
        "bundle_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "candidate": {
            "character_id": manifest.get("character_id"),
            "tier_id": manifest.get("tier_id"),
            "manifest": _project_relative(manifest_file),
            "asset_status": manifest.get("asset_status"),
            "source_reference": manifest.get("source_reference"),
            "source_reference_sha256": source_hash,
            "target_visible_height_px": manifest.get("target_visible_height_px"),
            "measured_visible_height_px": measured_height,
        },
        "structural_validation": {"status": "PASS" if not errors else "FAIL", "errors": errors},
        "production_readiness": {
            "status": "BLOCKED" if blockers or errors else "READY_REQUIRES_EXPLICIT_APPROVAL",
            "blockers": blockers,
            "production_approved": False,
        },
        "mechanical_visual_diagnostics": diagnostics,
        "human_review": manual_gates,
        "limits": [
            "This bundle does not assign semantic labels or approve anatomy.",
            "Static assembly and alpha/overlap metrics are mechanical review aids only.",
            "Godot pose/deformation review and explicit per-gate evidence remain required.",
        ],
    }
    _write_json(output / "review_report.json", report)
    checklist = [
        f"# {manifest.get('character_id', 'Character')} Tier {manifest.get('tier_id', '?')} review checklist",
        "",
        "This folder contains review aids, not production approval.",
        "",
        "- [ ] Compare concept and anatomy references together.",
        "- [ ] Inspect every part at 100%; confirm completeness, semantic ownership, and clean boundaries.",
        "- [ ] STOP at semantic intake if a required part is missing, clipped, duplicated, ambiguously owned, or unsupported by the approved reference; record the source correction needed before further work.",
        "- [ ] Review the static assembly against the approved views and confirm grounding.",
        "- [ ] Confirm hidden anatomy and overlap paint are authored or explicitly unresolved.",
        "- [ ] Confirm pivots are authored; treat the workbench fixed-angle sweep as diagnostic only and record character-specific ranges from authored clips or reviewed action poses.",
        "- [ ] Review combined idle/movement/attack/hit/defeat poses in an isolated gameplay-camera QA scene at 1280x720 and 800x450; record silhouette, role/gear readability, and ground contact.",
        "- [ ] Attach reviewer, timestamp, and evidence paths for each gate before setting it true.",
        "- [ ] Keep candidate quarantined until all gates and the explicit approval step pass.",
        "",
        "See review_report.json for mechanical checks and their limits.",
    ]
    (output / "MANUAL_REVIEW_CHECKLIST.md").write_text("\n".join(checklist) + "\n", encoding="utf-8")
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, help="character_art_manifest.json inside the project")
    parser.add_argument("output_dir", type=Path, help="new project-relative review-bundle directory")
    parser.add_argument("--require-production", action="store_true", help="return 2 when production gates are blocked")
    args = parser.parse_args()
    try:
        report = build_review_bundle(args.manifest, args.output_dir)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FAIL: could not build candidate review bundle: {exc}")
        return 1
    output = args.output_dir.resolve()
    print(f"REVIEW BUNDLE: {output}")
    print(f"STRUCTURE: {report['structural_validation']['status']}")
    print(f"PRODUCTION: {report['production_readiness']['status']}")
    if report["structural_validation"]["errors"]:
        for error in report["structural_validation"]["errors"]:
            print(f"- ERROR: {error}")
        return 1
    if args.require_production and report["production_readiness"]["blockers"]:
        for blocker in report["production_readiness"]["blockers"]:
            print(f"- BLOCKED: {blocker}")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
