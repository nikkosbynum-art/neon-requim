#!/usr/bin/env python3
"""Audit source-pixel fidelity and mechanical alpha for reference prop candidates."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
ALPHA_AUDIT_PATH = ROOT / "tools/art/audit_semantic_cutout.py"
_SPEC = importlib.util.spec_from_file_location("audit_semantic_cutout", ALPHA_AUDIT_PATH)
_ALPHA_MODULE = importlib.util.module_from_spec(_SPEC)
assert _SPEC is not None and _SPEC.loader is not None
_SPEC.loader.exec_module(_ALPHA_MODULE)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def audit_candidate(candidate_dir: Path) -> dict:
    candidate_dir = candidate_dir.resolve()
    manifest_path = candidate_dir / "candidate_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    character_id = manifest.get("character_id")
    errors: list[str] = []
    if not isinstance(character_id, str) or not character_id:
        raise ValueError("candidate manifest needs a character_id")
    expected_root = (ROOT / f"assets/characters/{character_id.lower()}/tier_01_drafts").resolve()
    if expected_root not in candidate_dir.parents:
        raise ValueError("candidate must be within the matching character's draft quarantine")
    source_path = (ROOT / manifest.get("source_reference", "")).resolve()
    if ROOT.resolve() not in source_path.parents or not source_path.is_file():
        raise ValueError("source_reference must resolve to a file within the project")
    if _sha256(source_path) != manifest.get("source_sha256"):
        errors.append("source_hash_mismatch")
    if manifest.get("animation_ready") is not False or manifest.get("production_approved") is not False or manifest.get("runtime_integrated") is not False:
        errors.append("candidate_gate_must_remain_closed")

    source = Image.open(source_path).convert("RGB")
    item_reports = []
    owned_pixels: list[set[tuple[int, int]]] = []
    seen_ids: set[str] = set()
    for item in manifest.get("items", []):
        item_id = str(item.get("id", ""))
        item_errors: list[str] = []
        if not item_id or item_id in seen_ids:
            item_errors.append("missing_or_duplicate_item_id")
        seen_ids.add(item_id)
        if item.get("owner_character_id") != character_id or item.get("animation_ready") is not False or item.get("production_approved") is not False or item.get("runtime_integrated") is not False or item.get("pivot") is not None:
            item_errors.append("item_owner_or_quarantine_metadata_invalid")
        image_path = candidate_dir / str(item.get("file", ""))
        if candidate_dir not in image_path.resolve().parents or not image_path.is_file():
            item_reports.append({"id": item_id, "status": "FAIL", "errors": ["missing_or_unsafe_image_path"]})
            errors.append(f"{item_id}:missing_or_unsafe_image_path")
            continue
        if _sha256(image_path) != item.get("sha256"):
            item_errors.append("image_hash_mismatch")
        with Image.open(image_path) as loaded:
            if loaded.mode != "RGBA":
                item_errors.append("image_is_not_RGBA")
                item_reports.append({"id": item_id, "status": "FAIL", "errors": item_errors})
                errors.extend(f"{item_id}:{error}" for error in item_errors)
                continue
            image = loaded.copy()
        alpha_audit = _ALPHA_MODULE.audit_cutout(image)
        if alpha_audit["status"] != "PASS":
            item_errors.append("mechanical_alpha_audit_failed")

        bbox = item.get("bbox_source_px", [])
        margin = item.get("safety_margin_px")
        rgb_mismatches = 0
        visible: set[tuple[int, int]] = set()
        if len(bbox) != 4 or type(margin) is not int or margin < 1:
            item_errors.append("invalid_source_bounds_or_margin")
            owned_pixels.append(set())
        else:
            left, top, right, bottom = bbox
            if any(type(value) is not int for value in bbox) or left < 0 or top < 0 or right > source.width or bottom > source.height or right <= left or bottom <= top:
                item_errors.append("source_bounds_outside_reference")
                owned_pixels.append(set())
                item_report = {"id": item_id, "status": "FAIL", "errors": item_errors, "production_approved": False}
                item_reports.append(item_report)
                errors.extend(f"{item_id}:{error}" for error in item_errors)
                continue
            expected_size = [right - left + 2 * margin, bottom - top + 2 * margin]
            if image.size != tuple(expected_size) or list(image.size) != item.get("output_px"):
                item_errors.append("output_size_mismatch")
            alpha = image.getchannel("A")
            crop_alpha = alpha.crop((margin, margin, image.width - margin, image.height - margin))
            outer_alpha = alpha.copy()
            outer_alpha.paste(0, (margin, margin, image.width - margin, image.height - margin))
            if outer_alpha.getbbox() is not None:
                item_errors.append("safety_margin_not_transparent")
            for y in range(crop_alpha.height):
                for x in range(crop_alpha.width):
                    if crop_alpha.getpixel((x, y)) == 0:
                        continue
                    sx, sy = left + x, top + y
                    visible.add((sx, sy))
                    if image.getpixel((margin + x, margin + y))[:3] != source.getpixel((sx, sy)):
                        rgb_mismatches += 1
            if rgb_mismatches:
                item_errors.append("source_rgb_changed")
            if len(visible) != item.get("source_alpha_pixels"):
                item_errors.append("visible_pixel_count_mismatch")
            owned_pixels.append(visible)
        item_report = {
            "id": item_id,
            "status": "PASS" if not item_errors else "FAIL",
            "alpha_audit": alpha_audit,
            "source_rgb_mismatches": rgb_mismatches,
            "source_alpha_pixels": len(visible),
            "errors": item_errors,
            "production_approved": False,
        }
        item_reports.append(item_report)
        errors.extend(f"{item_id}:{error}" for error in item_errors)

    overlap_reports = []
    for first_index in range(len(owned_pixels)):
        for second_index in range(first_index + 1, len(owned_pixels)):
            overlap = len(owned_pixels[first_index] & owned_pixels[second_index])
            overlap_reports.append({"first": manifest["items"][first_index].get("id"), "second": manifest["items"][second_index].get("id"), "shared_source_pixels": overlap})
            if overlap:
                errors.append("item_masks_overlap")
    if not item_reports:
        errors.append("candidate_has_no_items")
    return {
        "status": "PASS" if not errors else "FAIL",
        "scope": "source_hash_and_pixel_fidelity_plus_mechanical_alpha_only",
        "candidate_dir": str(candidate_dir),
        "source_reference": manifest.get("source_reference"),
        "source_sha256": manifest.get("source_sha256"),
        "items": item_reports,
        "pairwise_mask_overlap": overlap_reports,
        "errors": errors,
        "production_approved": False,
        "semantic_completeness_verified": False,
        "pivots_verified": False,
        "animation_ready": False,
        "runtime_integrated": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("candidate_dir", type=Path)
    parser.add_argument("--report", type=Path, help="Optional JSON report path; defaults to source_fidelity_report.json inside candidate.")
    args = parser.parse_args()
    try:
        report = audit_candidate(args.candidate_dir)
        report_path = args.report or args.candidate_dir / "source_fidelity_report.json"
        report_path = report_path.resolve()
        if args.report and ROOT.resolve() not in report_path.parents:
            raise ValueError("report output must remain inside the project")
        if report_path.exists():
            raise FileExistsError(f"refusing to overwrite existing report: {report_path}")
        report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print(f"{report['status']}: source/alpha audit report written to {report_path}")
    return 0 if report["status"] == "PASS" else 2


if __name__ == "__main__":
    sys.exit(main())
