"""Render named quarantined RGBA parts at native scale on a checkerboard.

This is a visual-inspection aid only. It does not evaluate semantic correctness
or promote art. Output paths must be new files inside the project.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.art.build_krita_authoring_workspace import _resolve_confined  # noqa: E402


def render_contact_sheet(candidate_dir: Path, output: Path, columns: int = 2) -> dict[str, Any]:
    candidate_dir = candidate_dir.resolve()
    output = output.resolve()
    try:
        candidate_dir.relative_to(ROOT.resolve())
        output.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError("candidate and output must stay inside the project") from exc
    if output.exists():
        raise FileExistsError(f"refusing to overwrite {output}")
    if columns < 1 or columns > 4:
        raise ValueError("columns must be between 1 and 4")

    legacy_path = candidate_dir / "parts_manifest.json"
    standard_path = candidate_dir / "character_art_manifest.json"
    manifest_path = legacy_path if legacy_path.is_file() else standard_path
    manifest_path = _resolve_confined(candidate_dir, manifest_path.name, "parts manifest")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    parts = manifest.get("parts")
    if isinstance(parts, dict):
        part_records = [(semantic, info) for semantic, info in parts.items()]
    elif isinstance(parts, list):
        part_records = []
        for info in parts:
            if not isinstance(info, dict):
                raise ValueError("part entries must be objects")
            semantic = info.get("semantic_label") or info.get("part_id") or info.get("name")
            part_records.append((semantic, info))
    else:
        part_records = []
    if not part_records:
        raise ValueError("manifest parts must be a nonempty object or array")

    loaded: list[tuple[str, str, Image.Image, tuple[int, int, int, int] | None]] = []
    for semantic, info in part_records:
        if not isinstance(semantic, str) or not semantic.strip() or not isinstance(info, dict):
            raise ValueError("each part entry needs a semantic_label, part_id, or name and an object")
        image_path = _resolve_confined(candidate_dir, info.get("file", ""), f"{semantic} image")
        with Image.open(image_path) as opened:
            part = opened.convert("RGBA")
        if part.width == 0 or part.height == 0:
            raise ValueError(f"{semantic} has an empty image")
        alpha_bounds = part.getchannel("A").getbbox()
        loaded.append((semantic, image_path.name, part.copy(), alpha_bounds))

    margin = 18
    header_h = 58
    footer_h = 32
    tile_w = max(part.width for _, _, part, _ in loaded) + margin * 2
    tile_h = max(part.height for _, _, part, _ in loaded) + header_h + footer_h + margin * 2
    rows = (len(loaded) + columns - 1) // columns
    canvas = Image.new("RGB", (columns * tile_w + margin, rows * tile_h + margin), (22, 27, 36))
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()
    tile_reports = []

    for index, (semantic, filename, part, alpha_bounds) in enumerate(loaded):
        col, row = index % columns, index // columns
        x = margin + col * tile_w
        y = margin + row * tile_h
        draw.rounded_rectangle((x, y, x + tile_w - 8, y + tile_h - 8), radius=8,
                               fill=(34, 38, 49), outline=(79, 85, 102), width=2)
        draw.text((x + 10, y + 8), semantic, font=font, fill=(240, 240, 245))
        checker_x, checker_y = x + margin, y + header_h
        checker = Image.new("RGBA", (part.width, part.height), (165, 165, 170, 255))
        checker_draw = ImageDraw.Draw(checker)
        square = 16
        for cy in range(0, part.height, square):
            for cx in range(0, part.width, square):
                if ((cx // square) + (cy // square)) % 2:
                    checker_draw.rectangle((cx, cy, min(cx + square - 1, part.width - 1),
                                            min(cy + square - 1, part.height - 1)), fill=(112, 116, 126))
        checker.alpha_composite(part)
        canvas.paste(checker.convert("RGB"), (checker_x, checker_y))
        size_label = f"{part.width}x{part.height}px | native scale | quarantine"
        draw.text((x + 10, y + tile_h - footer_h - 5), size_label, font=font, fill=(190, 196, 207))
        tile_reports.append({"part": semantic, "file": str((candidate_dir / filename).relative_to(ROOT)),
                             "size_px": [part.width, part.height], "alpha_bounds_xyxy": alpha_bounds})

    draw.text((margin, 4), "NAMED PARTS — CHECKERBOARD — QUARANTINED VISUAL REVIEW ONLY",
              font=font, fill=(244, 172, 180))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output)
    return {
        "output": str(output),
        "size_px": list(canvas.size),
        "candidate": str(candidate_dir.relative_to(ROOT)),
        "part_count": len(loaded),
        "semantic_review": "NOT_VERIFIED",
        "production_approved": False,
        "parts": tile_reports,
    }
def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("candidate_dir", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--columns", type=int, default=2)
    args = parser.parse_args()
    print(json.dumps(render_contact_sheet(args.candidate_dir, args.output, args.columns), indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
