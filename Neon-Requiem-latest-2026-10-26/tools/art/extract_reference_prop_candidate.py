#!/usr/bin/env python3
"""Create quarantined source-derived prop cutouts from explicit crop/seed manifests.

This is a review aid, not semantic segmentation or production-art approval. It
keeps only the foreground component connected to each manually placed object
seed; the artist still has to inspect and repair every contour in Krita.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _validate_point(point: object, width: int, height: int, label: str) -> tuple[int, int]:
    if not isinstance(point, list) or len(point) != 2 or any(type(value) is not int for value in point):
        raise ValueError(f"{label} must be a two-integer [x, y] point")
    x, y = point
    if not (0 <= x < width and 0 <= y < height):
        raise ValueError(f"{label} lies outside the source image")
    return x, y


def _foreground_from_seed(
    image: Image.Image,
    bbox: list[int],
    background_seed: list[int],
    object_seed: list[int],
    tolerance: int,
) -> tuple[Image.Image, dict]:
    source_width, source_height = image.size
    if not isinstance(bbox, list) or len(bbox) != 4 or any(type(value) is not int for value in bbox):
        raise ValueError("bbox must be [left, top, right, bottom] integer coordinates")
    left, top, right, bottom = bbox
    if left < 0 or top < 0 or right > source_width or bottom > source_height or right <= left or bottom <= top:
        raise ValueError("bbox must be a non-empty rectangle contained in the source")
    if type(tolerance) is not int or tolerance < 1 or tolerance > 96:
        raise ValueError("background_tolerance must be an integer from 1 through 96")
    bg_x, bg_y = _validate_point(background_seed, source_width, source_height, "background_seed")
    obj_x, obj_y = _validate_point(object_seed, source_width, source_height, "object_seed")
    if not (left <= bg_x < right and top <= bg_y < bottom and left <= obj_x < right and top <= obj_y < bottom):
        raise ValueError("both seeds must fall inside bbox")

    crop = image.crop((left, top, right, bottom)).convert("RGB")
    width, height = crop.size
    pixels = crop.load()
    background = pixels[bg_x - left, bg_y - top]

    # Flood the near-uniform backdrop inward from the crop edge. Enclosed light
    # paint on the prop is not discarded unless it has a path to the edge.
    background_mask = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def near_background(x: int, y: int) -> bool:
        r, g, b = pixels[x, y]
        return max(abs(r - background[0]), abs(g - background[1]), abs(b - background[2])) <= tolerance

    def enqueue(x: int, y: int) -> None:
        index = y * width + x
        if not background_mask[index] and near_background(x, y):
            background_mask[index] = 1
            queue.append((x, y))

    for x in range(width):
        enqueue(x, 0)
        enqueue(x, height - 1)
    for y in range(height):
        enqueue(0, y)
        enqueue(width - 1, y)
    while queue:
        x, y = queue.popleft()
        if x > 0:
            enqueue(x - 1, y)
        if x + 1 < width:
            enqueue(x + 1, y)
        if y > 0:
            enqueue(x, y - 1)
        if y + 1 < height:
            enqueue(x, y + 1)

    seed_x, seed_y = obj_x - left, obj_y - top
    seed_index = seed_y * width + seed_x
    if background_mask[seed_index]:
        raise ValueError("object_seed was classified as background; adjust seed or tolerance")

    # Keep the foreground object connected to the explicit object seed. This
    # excludes a neighboring hand/character even when it falls inside bbox.
    foreground = bytearray(width * height)
    foreground[seed_index] = 1
    queue.append((seed_x, seed_y))
    while queue:
        x, y = queue.popleft()
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1),
                       (x - 1, y - 1), (x + 1, y - 1), (x - 1, y + 1), (x + 1, y + 1)):
            if nx < 0 or ny < 0 or nx >= width or ny >= height:
                continue
            index = ny * width + nx
            if not foreground[index] and not background_mask[index]:
                foreground[index] = 1
                queue.append((nx, ny))

    mask = Image.new("L", (width, height), 0)
    mask.putdata([255 if value else 0 for value in foreground])
    alpha_bbox = mask.getbbox()
    if alpha_bbox is None:
        raise ValueError("object seed produced an empty foreground mask")
    alpha_pixels = sum(foreground)
    return mask, {
        "bbox_source_px": [left, top, right, bottom],
        "alpha_bbox_in_crop_px": list(alpha_bbox),
        "source_alpha_pixels": alpha_pixels,
        "source_crop_px": [width, height],
        "background_sample_rgb": list(background),
        "background_tolerance": tolerance,
        "object_seed_source_px": [obj_x, obj_y],
        "background_seed_source_px": [bg_x, bg_y],
    }


def create_candidate(manifest_path: Path, output_path: Path) -> dict:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("schema_version") != 1:
        raise ValueError("only schema_version 1 is supported")
    character_id = manifest.get("character_id")
    if not isinstance(character_id, str) or not character_id.strip():
        raise ValueError("character_id is required")
    expected_root = (ROOT / f"assets/characters/{character_id.lower()}/tier_01_drafts").resolve()
    output_resolved = output_path.resolve()
    if expected_root not in output_resolved.parents:
        raise ValueError("output must be inside the matching character's tier_01_drafts quarantine")
    if output_resolved.exists():
        raise FileExistsError(f"refusing to overwrite existing candidate: {output_resolved}")

    source_rel = manifest.get("source_reference")
    if not isinstance(source_rel, str) or not source_rel.strip():
        raise ValueError("source_reference is required")
    source_path = (ROOT / source_rel).resolve()
    if ROOT.resolve() not in source_path.parents or not source_path.is_file():
        raise ValueError("source_reference must name an existing project file")
    image = Image.open(source_path).convert("RGB")
    records = manifest.get("items")
    if not isinstance(records, list) or not records:
        raise ValueError("items must be a non-empty list")
    ids = [record.get("id") for record in records if isinstance(record, dict)]
    if len(ids) != len(records) or any(not isinstance(item_id, str) or not item_id.strip() for item_id in ids):
        raise ValueError("each item must have a non-empty id")
    if len(ids) != len(set(ids)):
        raise ValueError("item IDs must be unique")

    # Resolve and validate every mask before making any output, so a bad seed
    # cannot leave a misleading partial candidate folder.
    prepared = []
    for record in records:
        item_id = record["id"]
        try:
            mask, audit = _foreground_from_seed(
                image,
                record.get("bbox"),
                record.get("background_seed"),
                record.get("object_seed"),
                record.get("background_tolerance", 24),
            )
            left, top, right, bottom = audit["bbox_source_px"]
            margin = record.get("safety_margin_px", 48)
            if type(margin) is not int or margin < 1 or margin > 512:
                raise ValueError("safety_margin_px must be an integer from 1 through 512")
            item = Image.new("RGBA", (mask.width + 2 * margin, mask.height + 2 * margin), (0, 0, 0, 0))
            crop = image.crop((left, top, right, bottom)).convert("RGBA")
            item.paste(crop, (margin, margin))
            expanded_mask = Image.new("L", item.size, 0)
            expanded_mask.paste(mask, (margin, margin))
            item.putalpha(expanded_mask)
            filename = f"{character_id}_T1_{item_id.upper()}_REFERENCE_CUTOUT_CANDIDATE_01_QUARANTINED.png"
            prepared.append((item_id, filename, item, audit, margin))
        except ValueError as error:
            raise ValueError(f"{item_id}: {error}") from error

    output_resolved.mkdir(parents=True)
    output_items = []
    try:
        for item_id, filename, item, audit, margin in prepared:
            item_path = output_resolved / filename
            item.save(item_path, optimize=True)
            audit.update({
                "id": item_id,
                "file": filename,
                "output_px": list(item.size),
                "safety_margin_px": margin,
                "sha256": sha256(item_path),
                "attachment_role_id": f"{character_id.lower()}.{item_id}",
                "owner_character_id": character_id,
                "pivot": None,
                "animation_ready": False,
                "production_approved": False,
                "runtime_integrated": False,
                "status": "REFERENCE-DERIVED CUTOUT CANDIDATE / QUARANTINED",
            })
            output_items.append(audit)
        result = {
            "schema_version": 1,
            "character_id": character_id,
            "tier_id": 1,
            "source_reference": source_rel,
            "source_status": manifest.get("source_status", "reference art; not animation-ready production art"),
            "extraction_method": "edge-flood near-background removal plus explicitly seeded connected foreground component",
            "source_sha256": sha256(source_path),
            "status": "REFERENCE-DERIVED REVIEW CANDIDATE / QUARANTINED",
            "readiness": "Static foreground cutouts only; semantic completeness, edge cleanup, pivots, 3D/deformation, and animation remain unverified.",
            "animation_ready": False,
            "production_approved": False,
            "runtime_integrated": False,
            "items": output_items,
        }
        (output_resolved / "candidate_manifest.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        readme = (
            f"# {character_id} source-derived prop cutout candidate\n\n"
            "**Status: REFERENCE-DERIVED REVIEW CANDIDATE / QUARANTINED.** These static cutouts come from a flattened approved visual reference. They are not rig-ready or runtime art.\n\n"
            f"Source: `{source_rel}` (SHA-256 in `candidate_manifest.json`).\n\n"
            "The extraction keeps foreground pixels connected to explicit object seeds. Review each image at 100% over a checkerboard. Correct halos, clipping, incomplete hidden surfaces, and semantic boundaries in Krita. No pivots were inferred. Production and runtime gates remain false.\n"
        )
        (output_resolved / "README_QUARANTINED.md").write_text(readme, encoding="utf-8")
    except Exception:
        # Keep the newly-created folder as a visible partial failure rather
        # than deleting any files automatically.
        raise
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    try:
        result = create_candidate(args.manifest, args.output)
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print(f"Created {len(result['items'])} quarantined reference-derived cutouts; animation/runtime readiness remains false.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
