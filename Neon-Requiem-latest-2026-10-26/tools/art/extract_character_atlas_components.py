#!/usr/bin/env python3
"""Extract isolated RGBA components from a quarantined character-parts atlas.

This creates review crops only. It does not assign semantic body-part names,
choose pivots, create a production manifest, or approve an atlas for runtime.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image


@dataclass
class Run:
    y: int
    x0: int
    x1: int
    label: int


class UnionFind:
    def __init__(self) -> None:
        self.parent = [0]

    def make(self) -> int:
        label = len(self.parent)
        self.parent.append(label)
        return label

    def find(self, label: int) -> int:
        while self.parent[label] != label:
            self.parent[label] = self.parent[self.parent[label]]
            label = self.parent[label]
        return label

    def union(self, a: int, b: int) -> None:
        root_a = self.find(a)
        root_b = self.find(b)
        if root_a != root_b:
            self.parent[root_b] = root_a


def connected_components(
    image: Image.Image, alpha_threshold: int = 32
) -> list[dict[str, int]]:
    """Return deterministic 8-connected bounds and pixel areas from RGBA alpha."""
    if image.mode != "RGBA":
        raise ValueError("input must be RGBA with transparency")
    if not 1 <= alpha_threshold <= 255:
        raise ValueError("alpha threshold must be between 1 and 255")

    alpha = image.getchannel("A")
    pixels = alpha.load()
    width, height = image.size
    union_find = UnionFind()
    all_runs: list[Run] = []
    previous: list[tuple[int, int, int]] = []

    for y in range(height):
        current: list[tuple[int, int, int]] = []
        x = 0
        while x < width:
            while x < width and pixels[x, y] < alpha_threshold:
                x += 1
            if x == width:
                break
            x0 = x
            while x < width and pixels[x, y] >= alpha_threshold:
                x += 1
            x1 = x - 1

            label = union_find.make()
            matches = [
                previous_label
                for prev_x0, prev_x1, previous_label in previous
                if prev_x1 >= x0 - 1 and prev_x0 <= x1 + 1
            ]
            for previous_label in matches:
                union_find.union(label, previous_label)

            current.append((x0, x1, label))
            all_runs.append(Run(y, x0, x1, label))
        previous = current

    stats: dict[int, dict[str, int]] = {}
    for run in all_runs:
        root = union_find.find(run.label)
        item = stats.setdefault(
            root,
            {"area": 0, "x0": width, "y0": height, "x1": -1, "y1": -1},
        )
        item["area"] += run.x1 - run.x0 + 1
        item["x0"] = min(item["x0"], run.x0)
        item["y0"] = min(item["y0"], run.y)
        item["x1"] = max(item["x1"], run.x1)
        item["y1"] = max(item["y1"], run.y)

    return sorted(stats.values(), key=lambda box: (box["y0"], box["x0"]))


def extract_components(
    source: Path,
    output_dir: Path,
    *,
    alpha_threshold: int = 32,
    minimum_area: int = 500,
    padding: int = 12,
    trim_subthreshold_alpha: bool = False,
    force: bool = False,
) -> list[dict[str, object]]:
    with Image.open(source) as loaded:
        if loaded.mode != "RGBA":
            raise ValueError(f"{source} must be RGBA; got {loaded.mode}")
        image = loaded.copy()
    if minimum_area < 1 or padding < 0:
        raise ValueError("minimum_area must be positive and padding nonnegative")

    if output_dir.exists() and any(output_dir.iterdir()) and not force:
        raise FileExistsError(f"output directory is not empty: {output_dir}")
    output_dir.mkdir(parents=True, exist_ok=True)

    width, height = image.size
    components = connected_components(image, alpha_threshold)
    components = [item for item in components if item["area"] >= minimum_area]
    records: list[dict[str, object]] = []

    for index, box in enumerate(components, start=1):
        crop_box = (
            max(0, box["x0"] - padding),
            max(0, box["y0"] - padding),
            min(width, box["x1"] + 1 + padding),
            min(height, box["y1"] + 1 + padding),
        )
        filename = f"component_{index:02d}.png"
        crop = image.crop(crop_box)
        if trim_subthreshold_alpha:
            alpha = crop.getchannel("A").point(
                lambda value: value if value >= alpha_threshold else 0
            )
            crop.putalpha(alpha)
        crop.save(output_dir / filename)
        records.append(
            {
                "component_id": f"component_{index:02d}",
                "file": filename,
                "threshold_bbox_xyxy_exclusive": [
                    box["x0"], box["y0"], box["x1"] + 1, box["y1"] + 1
                ],
                "crop_bbox_xyxy_exclusive": list(crop_box),
                "thresholded_alpha_pixel_area": box["area"],
            }
        )

    manifest = {
        "status": "quarantined_component_crops",
        "source": source.as_posix(),
        "source_size_px": [width, height],
        "alpha_threshold": alpha_threshold,
        "minimum_area": minimum_area,
        "padding_px": padding,
        "subthreshold_alpha_trimmed": trim_subthreshold_alpha,
        "semantic_part_names_assigned": False,
        "pivots_authored": False,
        "production_approved": False,
        "components": records,
    }
    (output_dir / "components.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    return records


def parse_args(argv: Iterable[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="transparent RGBA parts atlas")
    parser.add_argument("output_dir", type=Path, help="new or empty review folder")
    parser.add_argument("--alpha-threshold", type=int, default=32)
    parser.add_argument("--minimum-area", type=int, default=500)
    parser.add_argument("--padding", type=int, default=12)
    parser.add_argument(
        "--trim-subthreshold-alpha",
        action="store_true",
        help="clear alpha values below --alpha-threshold in the output crops",
    )
    parser.add_argument("--force", action="store_true", help="allow output overwrite")
    return parser.parse_args(argv)


def main(argv: Iterable[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        records = extract_components(
            args.input,
            args.output_dir,
            alpha_threshold=args.alpha_threshold,
            minimum_area=args.minimum_area,
            padding=args.padding,
            trim_subthreshold_alpha=args.trim_subthreshold_alpha,
            force=args.force,
        )
    except (OSError, ValueError) as exc:
        print(f"error: {exc}")
        return 1
    print(f"Extracted {len(records)} review components to {args.output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
