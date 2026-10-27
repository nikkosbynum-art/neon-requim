#!/usr/bin/env python3
"""Create quarantined, canvas-aligned cutouts from explicitly traced polygons.

This helper does not identify parts or repair hidden anatomy. The polygon points
must be authored against an approved source image and every result still needs
human semantic, pivot, and deformation review.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import tempfile
from typing import Any

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
PART_ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]*$")
ALLOWED_CATEGORIES = {"body_part", "weapon", "accessory", "cyberware", "drone", "cloth", "cable", "effect"}
SAFE_FILE_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]*\.png$")


def _inside(path: Path, root: Path, label: str) -> Path:
    resolved = path.resolve()
    try:
        resolved.relative_to(root.resolve())
    except ValueError as exc:
        raise ValueError(f"{label} must remain inside the project") from exc
    return resolved


def _validate_manifest(manifest: dict[str, Any], size: tuple[int, int]) -> list[dict[str, Any]]:
    if manifest.get("schema_version") != 1:
        raise ValueError("schema_version must be 1")
    character_id = manifest.get("character_id")
    if not isinstance(character_id, str) or not re.fullmatch(r"[A-Z][A-Z0-9_]*", character_id):
        raise ValueError("character_id must be an uppercase roster ID")
    if manifest.get("tier_id") != 1:
        raise ValueError("this helper only accepts Tier I source cutouts")
    if not isinstance(manifest.get("source_view"), str) or not manifest["source_view"].strip():
        raise ValueError("source_view must identify the approved view used for tracing")
    parts = manifest.get("parts")
    if not isinstance(parts, list) or not parts:
        raise ValueError("parts must be a nonempty list")

    seen_ids: set[str] = set()
    seen_files: set[str] = set()
    normalized: list[dict[str, Any]] = []
    width, height = size
    for index, part in enumerate(parts):
        if not isinstance(part, dict):
            raise ValueError(f"parts[{index}] must be an object")
        part_id = part.get("part_id")
        if not isinstance(part_id, str) or not PART_ID_RE.fullmatch(part_id):
            raise ValueError(f"parts[{index}].part_id is invalid")
        if part_id in seen_ids:
            raise ValueError(f"duplicate part_id: {part_id}")
        seen_ids.add(part_id)

        file_name = part.get("file")
        if not isinstance(file_name, str) or not SAFE_FILE_RE.fullmatch(file_name) or file_name in seen_files:
            raise ValueError(f"parts[{index}].file must be a unique PNG basename")
        seen_files.add(file_name)

        if part.get("owner_character_id") != character_id:
            raise ValueError(f"{part_id}: owner_character_id must match character_id")
        if part.get("category") not in ALLOWED_CATEGORIES:
            raise ValueError(f"{part_id}: unsupported category")
        if not isinstance(part.get("semantic_label"), str) or not part["semantic_label"].strip():
            raise ValueError(f"{part_id}: semantic_label is required")
        if not isinstance(part.get("boundary_provenance"), str) or not part["boundary_provenance"].strip():
            raise ValueError(f"{part_id}: boundary_provenance is required")

        polygons = part.get("polygons_xy")
        if polygons is None and part.get("polygon_xy") is not None:
            polygons = [part["polygon_xy"]]
        if not isinstance(polygons, list) or not polygons:
            raise ValueError(f"{part_id}: polygon_xy or nonempty polygons_xy is required")
        checked_polygons: list[list[tuple[int, int]]] = []
        for polygon_index, points in enumerate(polygons):
            if not isinstance(points, list) or len(points) < 3:
                raise ValueError(f"{part_id}: polygon {polygon_index} must contain at least three points")
            checked_points: list[tuple[int, int]] = []
            for point in points:
                if not isinstance(point, list) or len(point) != 2:
                    raise ValueError(f"{part_id}: every polygon point must be [x, y]")
                x, y = point
                if isinstance(x, bool) or isinstance(y, bool) or not isinstance(x, int) or not isinstance(y, int):
                    raise ValueError(f"{part_id}: polygon points must use integer source pixels")
                if not (0 <= x < width and 0 <= y < height):
                    raise ValueError(f"{part_id}: polygon point {(x, y)} is outside source size {size}")
                checked_points.append((x, y))
            if len(set(checked_points)) < 3:
                raise ValueError(f"{part_id}: polygon {polygon_index} has fewer than three unique points")
            checked_polygons.append(checked_points)

        normalized.append({**part, "polygons_xy": checked_polygons})
    return normalized


def extract_parts(manifest_path: str | Path, output_path: str | Path, *, project_root: str | Path = ROOT) -> Path:
    root = Path(project_root).resolve()
    manifest_file = _inside(Path(manifest_path) if Path(manifest_path).is_absolute() else root / manifest_path, root, "manifest")
    output = _inside(Path(output_path) if Path(output_path).is_absolute() else root / output_path, root, "output directory")
    if not manifest_file.is_file():
        raise FileNotFoundError(f"manifest does not exist: {manifest_file}")
    if output.exists():
        raise FileExistsError(f"refusing to overwrite existing output directory: {output}")

    manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
    character_id = manifest.get("character_id")
    expected_parent = root / "assets" / "characters" / str(character_id).lower() / "tier_01_drafts"
    output_parent = _inside(output.parent, root, "output parent")
    if output_parent != expected_parent.resolve():
        raise ValueError("output must be a new directory directly under this character's tier_01_drafts")

    source_value = manifest.get("source_image")
    if not isinstance(source_value, str) or not source_value:
        raise ValueError("source_image is required")
    source = _inside(root / source_value, root, "source image")
    if not source.is_file():
        raise FileNotFoundError(f"source image does not exist: {source}")

    source_bytes = source.read_bytes()
    source_hash = hashlib.sha256(source_bytes).hexdigest()
    expected_hash = manifest.get("source_sha256")
    if expected_hash is not None and expected_hash != source_hash:
        raise ValueError("source_sha256 does not match the current source image")
    upstream_sources = manifest.get("upstream_sources", [])
    if not isinstance(upstream_sources, list):
        raise ValueError("upstream_sources must be a list")
    verified_upstream = []
    for index, item in enumerate(upstream_sources):
        if not isinstance(item, dict) or not isinstance(item.get("source_image"), str):
            raise ValueError(f"upstream_sources[{index}] must name a source_image")
        upstream = _inside(root / item["source_image"], root, f"upstream_sources[{index}]")
        if not upstream.is_file():
            raise FileNotFoundError(f"upstream source does not exist: {upstream}")
        upstream_hash = hashlib.sha256(upstream.read_bytes()).hexdigest()
        if item.get("source_sha256") not in (None, upstream_hash):
            raise ValueError(f"upstream source hash mismatch: {item['source_image']}")
        verified_upstream.append({
            **item,
            "source_sha256": upstream_hash,
        })
    with Image.open(source) as opened:
        source_image = opened.convert("RGBA")
    parts = _validate_manifest(manifest, source_image.size)

    masks: list[tuple[str, Image.Image]] = []
    outputs: list[tuple[dict[str, Any], Image.Image, int, tuple[int, int, int, int]]] = []
    for part in parts:
        mask = Image.new("L", source_image.size, 0)
        draw = ImageDraw.Draw(mask)
        for polygon in part["polygons_xy"]:
            draw.polygon(polygon, fill=255)
        alpha = Image.new("L", source_image.size, 0)
        alpha.paste(source_image.getchannel("A"), mask=mask)
        rgba = source_image.copy()
        rgba.putalpha(alpha)
        visible = sum(alpha.histogram()[1:])
        if visible == 0:
            raise ValueError(f"{part['part_id']}: polygon selects no visible source pixels")
        bounds = alpha.getbbox()
        if bounds is None:
            raise ValueError(f"{part['part_id']}: alpha bounds are unexpectedly empty")
        masks.append((part["part_id"], alpha))
        outputs.append((part, rgba, visible, bounds))

    overlaps: list[str] = []
    for left_index, (left_id, left_mask) in enumerate(masks):
        for right_id, right_mask in masks[left_index + 1 :]:
            # Logical intersection without changing either authored mask.
            left_bytes, right_bytes = left_mask.tobytes(), right_mask.tobytes()
            shared = sum(1 for a, b in zip(left_bytes, right_bytes) if a and b)
            if shared:
                overlaps.append(f"{left_id}/{right_id}: {shared} shared source pixels")
    if overlaps:
        raise ValueError("polygon masks overlap; resolve visible pixel ownership before export: " + "; ".join(overlaps))

    output.mkdir(parents=True)
    try:
        part_records = []
        for part, image, visible, bounds in outputs:
            image.save(output / part["file"], format="PNG", optimize=False)
            part_records.append({
                "part_id": part["part_id"],
                "file": part["file"],
                "semantic_label": part["semantic_label"],
                "category": part["category"],
                "owner_character_id": character_id,
                "attachment_role_id": part.get("attachment_role_id"),
                "boundary_provenance": part["boundary_provenance"],
                "polygons_xy": [[list(point) for point in polygon] for polygon in part["polygons_xy"]],
                "visible_source_pixels": visible,
                "alpha_bounds_xyxy_exclusive": list(bounds),
                "canvas_px": list(source_image.size),
                "pivot_source_xy": None,
                "readiness": "quarantined source-pixel cutout; semantic review required",
            })
        result = {
            "schema_version": 1,
            "character_id": character_id,
            "tier_id": 1,
            "status": "QUARANTINED REVIEW CANDIDATE",
            "source_image": source_value,
            "source_sha256": source_hash,
            "source_view": manifest["source_view"],
            "upstream_sources": verified_upstream,
            "canvas_px": list(source_image.size),
            "production_approved": False,
            "semantic_review_passed": False,
            "pivots_authored": False,
            "deformation_reviewed": False,
            "runtime_integrated": False,
            "parts": part_records,
        }
        (output / "parts_manifest.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        (output / "README_QUARANTINED.md").write_text(
            f"# {character_id} Tier I traced source-pixel cutouts\n\n"
            "Status: QUARANTINED REVIEW CANDIDATE; not rig input or runtime art.\n\n"
            "The polygons were explicitly supplied in the source manifest. This tool only masks the selected source pixels; "
            "it does not infer semantic ownership, fill hidden anatomy, create pivots, or validate deformation. "
            "Review every part at 100% and in a neutral assembly before any rig work.\n",
            encoding="utf-8",
        )
    except Exception:
        shutil.rmtree(output, ignore_errors=True)
        raise
    return output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", help="project-relative JSON with manually traced source polygons")
    parser.add_argument("output", help="new quarantine folder under the same character's tier_01_drafts")
    args = parser.parse_args()
    try:
        result = extract_parts(args.manifest, args.output)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FAIL: {exc}")
        return 1
    print(f"PASS: wrote quarantined source cutouts to {result.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
