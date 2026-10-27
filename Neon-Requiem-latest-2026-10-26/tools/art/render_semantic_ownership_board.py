"""Render a native-resolution source/ownership overlay for a cutout manifest.

This board visualizes the declared masks. It does not verify that labels or
boundaries are anatomically correct and never promotes candidate art.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.art.build_krita_authoring_workspace import (  # noqa: E402
    _int_tuple,
    _part_origin_and_pixels,
    _resolve_confined,
)

PALETTE = [
    (235, 75, 90), (55, 190, 235), (250, 180, 60), (175, 105, 235),
    (85, 205, 130), (245, 115, 190), (80, 145, 245), (235, 220, 85),
    (65, 215, 195), (230, 135, 65), (155, 195, 70), (195, 115, 145),
]


def render_ownership_board(candidate_dir: Path, output: Path) -> dict[str, Any]:
    candidate_dir = candidate_dir.resolve()
    try:
        candidate_dir.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError("candidate directory must be inside the project") from exc
    output = output.resolve()
    if output.exists():
        raise FileExistsError(f"refusing to overwrite {output}")

    manifest_path = _resolve_confined(candidate_dir, "parts_manifest.json", "parts manifest")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    parts = manifest.get("parts")
    if isinstance(parts, dict) and parts:
        sx, sy, width, height = _int_tuple(manifest["crop_xywh"], 4, "crop_xywh")
        source_path = _resolve_confined(ROOT, manifest["source"], "source reference")
        with Image.open(source_path) as opened:
            source_image = opened.convert("RGBA")
        if sx < 0 or sy < 0 or width <= 0 or height <= 0 or sx + width > source_image.width or sy + height > source_image.height:
            raise ValueError("crop_xywh is outside the source reference")
        source = source_image.crop((sx, sy, sx + width, sy + height))
        declared_parts = list(parts.items())
        traced_manifest = False
    elif isinstance(parts, list) and parts and isinstance(manifest.get("source_image"), str):
        source_path = _resolve_confined(ROOT, manifest["source_image"], "source reference")
        with Image.open(source_path) as opened:
            source = opened.convert("RGBA")
        width, height = source.size
        canvas_size = manifest.get("canvas_px")
        if canvas_size is not None and canvas_size != [width, height]:
            raise ValueError("canvas_px does not match the approved source dimensions")
        declared_parts = []
        for index, info in enumerate(parts):
            if not isinstance(info, dict):
                raise ValueError(f"parts[{index}] must be an object")
            semantic = info.get("part_id") or info.get("semantic_label")
            if not isinstance(semantic, str) or not semantic.strip():
                raise ValueError(f"parts[{index}] needs part_id or semantic_label")
            declared_parts.append((semantic, info))
        traced_manifest = True
    else:
        raise ValueError("manifest parts must be a nonempty legacy object or traced-polygon array")

    semantic_names = [semantic for semantic, _info in declared_parts]
    if len(semantic_names) != len(set(semantic_names)):
        raise ValueError("part semantic IDs must be unique for ownership review")

    part_masks: dict[str, Image.Image] = {}
    for semantic, part_info in declared_parts:
        if not isinstance(part_info, dict):
            raise ValueError(f"{semantic}: part entry must be an object")
        if traced_manifest:
            polygons = part_info.get("polygons_xy")
            if polygons is None and part_info.get("polygon_xy") is not None:
                polygons = [part_info["polygon_xy"]]
            if not isinstance(polygons, list) or not polygons:
                raise ValueError(f"{semantic}: traced part needs polygon_xy or polygons_xy")
            mask = Image.new("L", (width, height), 0)
            draw = ImageDraw.Draw(mask)
            for polygon_index, polygon in enumerate(polygons):
                if not isinstance(polygon, list) or len(polygon) < 3:
                    raise ValueError(f"{semantic}: polygon {polygon_index} needs at least three points")
                points: list[tuple[int, int]] = []
                for point in polygon:
                    if not isinstance(point, list) or len(point) != 2 or any(type(value) is not int for value in point):
                        raise ValueError(f"{semantic}: polygon points must be integer [x, y] pairs")
                    x, y = point
                    if not (0 <= x < width and 0 <= y < height):
                        raise ValueError(f"{semantic}: polygon point {(x, y)} is outside source dimensions")
                    points.append((x, y))
                draw.polygon(points, fill=255)
        else:
            image, (px, py) = _part_origin_and_pixels(candidate_dir, part_info)
            part_alpha = image.getchannel("A").point(lambda value: 255 if value >= 32 else 0)
            mask = Image.new("L", (width, height), 0)
            mask.paste(part_alpha, (px, py), part_alpha)
        part_masks[semantic] = mask

    assigned = Image.new("L", (width, height), 0)
    overlap = Image.new("L", (width, height), 0)
    overlay = source.copy()
    legend: list[tuple[str, tuple[int, int, int], int]] = []
    overlap_pairs: list[dict[str, Any]] = []
    for index, (semantic, mask) in enumerate(part_masks.items()):
        for previous_name, previous_mask in list(part_masks.items())[:index]:
            shared_pixels = ImageChops.multiply(previous_mask, mask).histogram()[255]
            if shared_pixels:
                overlap_pairs.append({"part_a": previous_name, "part_b": semantic, "shared_pixels": shared_pixels})
        overlap = ImageChops.lighter(overlap, ImageChops.multiply(assigned, mask))
        assigned = ImageChops.lighter(assigned, mask)

        color = PALETTE[index % len(PALETTE)]
        color_layer = Image.new("RGBA", (width, height), color + (0,))
        color_layer.putalpha(mask.point(lambda value: 90 if value else 0))
        overlay = Image.alpha_composite(overlay, color_layer)
        legend.append((semantic, color, mask.histogram()[255]))

    overlap_tint = Image.new("RGBA", (width, height), (255, 35, 35, 0))
    overlap_tint.putalpha(overlap.point(lambda value: 190 if value else 0))
    overlay = Image.alpha_composite(overlay, overlap_tint)

    font = ImageFont.load_default()
    legend_width = 270
    margin = 20
    top = 80
    canvas = Image.new("RGB", (margin * 3 + width * 2 + legend_width, top + height + margin), (22, 27, 36))
    draw = ImageDraw.Draw(canvas)
    draw.text((margin, 18), "SEMANTIC OWNERSHIP MAP - QUARANTINED DIAGNOSTIC", font=font, fill=(240, 240, 245))
    draw.text((margin, 43), "Native crop scale; red pixels have multiple part owners. Labels are unverified.", font=font, fill=(240, 160, 165))
    canvas.paste(source.convert("RGB"), (margin, top))
    overlay_x = margin * 2 + width
    canvas.paste(overlay.convert("RGB"), (overlay_x, top))
    legend_x = margin * 3 + width * 2
    draw.text((legend_x, top), "Declared part ownership", font=font, fill=(240, 240, 245))
    for index, (semantic, color, pixels) in enumerate(legend):
        y = top + 26 + index * 26
        draw.rectangle((legend_x, y, legend_x + 14, y + 14), fill=color)
        draw.text((legend_x + 20, y), f"{semantic}: {pixels}px", font=font, fill=(225, 229, 236))
    draw.text((legend_x, top + 26 + len(legend) * 26), f"Overlapping owners: {overlap.histogram()[255]}px", font=font, fill=(255, 115, 115))
    draw.text((margin, top + height + 6), "Source crop", font=font, fill=(220, 225, 235))
    draw.text((overlay_x, top + height + 6), "Manifest ownership overlay", font=font, fill=(220, 225, 235))

    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output)
    return {
        "output": str(output),
        "size_px": list(canvas.size),
        "source_crop_px": [width, height],
        "source_reference": source_path.relative_to(ROOT).as_posix(),
        "part_count": len(legend),
        "overlap_pixels": overlap.histogram()[255],
        "overlap_pairs": overlap_pairs,
        "parts": {name: {"owned_pixels": pixels, "color_rgb": color} for name, color, pixels in legend},
        "scope": "manifest_pixel_ownership_visualization_only",
        "semantic_correctness": "NOT_VERIFIED",
        "production_approved": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("candidate_dir", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    report = render_ownership_board(args.candidate_dir, args.output)
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
