"""Mechanical-only audit for the quarantined CIPHER profile cutout candidates.

A clean alpha mask and high silhouette coverage never certify semantics, hidden
anatomy, pivots, deformation, or production readiness.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    # Keep both `python -m tools.art...` and direct script invocation usable.
    sys.path.insert(0, str(ROOT))

from tools.art.audit_semantic_cutout import audit_cutout
from tools.art.extract_cipher_profile_parts_candidate_02 import remove_exterior_board

DEFAULT_ASSEMBLIES = {
    "reference_cutout_rig_candidate_01": "CIPHER_T1_REFERENCE_CUTOUT_ASSEMBLY_CANDIDATE_01.png",
    "reference_cutout_rig_candidate_02": "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_02_QUARANTINED.png",
    "reference_cutout_rig_candidate_03": "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_03_QUARANTINED.png",
    "reference_cutout_rig_candidate_04": "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_04_QUARANTINED.png",
    "reference_cutout_rig_candidate_05": "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_05_QUARANTINED.png",
    "reference_cutout_rig_candidate_06": "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_06_QUARANTINED.png",
    "reference_cutout_rig_candidate_07": "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_07_QUARANTINED.png",
}


def audit_candidate(candidate_dir: Path, *, assembly_name: str | None = None,
                    min_source_coverage: float = 0.99) -> dict[str, Any]:
    candidate_dir = candidate_dir.resolve()
    manifest_path = candidate_dir / "parts_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    source_path = ROOT / manifest["source"]
    cx, cy, cw, ch = manifest["crop_xywh"]
    source = remove_exterior_board(Image.open(source_path).crop((cx, cy, cx + cw, cy + ch)))
    source_core = source.getchannel("A").point(lambda a: 255 if a >= 32 else 0)
    assembly_name = assembly_name or DEFAULT_ASSEMBLIES.get(candidate_dir.name)
    if not assembly_name:
        raise ValueError("assembly_name is required for an unregistered candidate folder")
    assembly_path = candidate_dir / assembly_name
    assembly = Image.open(assembly_path).convert("RGBA")
    if assembly.size != source.size:
        raise ValueError(f"assembly is {assembly.size}, source crop is {source.size}")
    assembly_core = assembly.getchannel("A").point(lambda a: 255 if a >= 32 else 0)
    source_pixels = source_core.histogram()[255]
    assembly_pixels = assembly_core.histogram()[255]
    missing = ImageChops.subtract(source_core, assembly_core).histogram()[255]
    extra = ImageChops.subtract(assembly_core, source_core).histogram()[255]
    coverage = assembly_pixels / max(source_pixels, 1)

    parts = {}
    alpha_failures = []
    for semantic, info in manifest["parts"].items():
        path = candidate_dir / info["file"]
        result = audit_cutout(Image.open(path).convert("RGBA"))
        parts[semantic] = {
            "file": info["file"],
            "status": result["status"],
            "size_px": [result["width_px"], result["height_px"]],
            "margins_px": result["margins_px"],
            "external_low_alpha_pixels": result["external_low_alpha_pixels"],
            "connectivity_diagnostic": result["connectivity_diagnostic"],
            "failures": result["failures"],
        }
        if result["status"] != "PASS":
            alpha_failures.append(semantic)

    failures = []
    if alpha_failures:
        failures.append("part_alpha_or_margin_failure")
    if coverage < min_source_coverage:
        failures.append("assembly_source_coverage_below_threshold")
    if extra:
        failures.append("assembly_has_pixels_outside_source_silhouette")
    semantic_review_status = manifest.get("semantic_review_status", "NOT_AUTOMATED_OR_VERIFIED")
    mechanical_status = "MECHANICAL_FAIL" if failures else "MECHANICAL_PASS"
    if failures:
        overall_status = "MECHANICAL_FAIL"
    elif semantic_review_status in {"PREVIEW_SCREEN_FAIL", "FULL_REVIEW_FAIL"}:
        overall_status = "MECHANICAL_PASS_SEMANTIC_SCREEN_FAIL"
    else:
        overall_status = "MECHANICAL_PASS_VISUAL_REVIEW_REQUIRED"
    return {
        "status": overall_status,
        "mechanical_status": mechanical_status,
        "candidate": candidate_dir.name,
        "scope": "alpha_margins_and_neutral_source_silhouette_coverage_only",
        "min_source_coverage": min_source_coverage,
        "source_core_pixels": source_pixels,
        "assembly_core_pixels": assembly_pixels,
        "source_coverage_ratio": round(coverage, 6),
        "missing_source_core_pixels": missing,
        "extra_core_pixels": extra,
        "alpha_failures": alpha_failures,
        "failures": failures,
        "semantic_visual_review": semantic_review_status,
        "semantic_review_evidence": manifest.get("semantic_review_evidence"),
        "semantic_review_note": manifest.get("semantic_review_note"),
        "full_resolution_krita_review": "NOT_VERIFIED",
        "pivots_and_deformation": "NOT_VERIFIED",
        "production_approved": False,
        "parts": parts,
    }


def audit_exit_code(report: dict[str, Any]) -> int:
    if report["mechanical_status"] == "MECHANICAL_FAIL":
        return 1
    if report["semantic_visual_review"] in {"PREVIEW_SCREEN_FAIL", "FULL_REVIEW_FAIL"}:
        return 2
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("candidate_dir", type=Path)
    parser.add_argument("--assembly", help="assembly image filename; defaults by candidate folder")
    parser.add_argument("--minimum-source-coverage", type=float, default=0.99,
                        help="provisional mechanical check threshold (default: 0.99)")
    args = parser.parse_args()
    report = audit_candidate(args.candidate_dir, assembly_name=args.assembly,
                             min_source_coverage=args.minimum_source_coverage)
    print(json.dumps(report, indent=2))
    return audit_exit_code(report)


if __name__ == "__main__":
    raise SystemExit(main())
