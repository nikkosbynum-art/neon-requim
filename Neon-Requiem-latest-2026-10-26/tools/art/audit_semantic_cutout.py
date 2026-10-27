#!/usr/bin/env python3
"""Audit mechanical transparency and margin gates for one RGBA art cutout.

This reports alpha geometry only. It cannot validate anatomy, identity,
semantic part completeness, pivots, animation, or production readiness.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageFilter


def _connected_components(mask: Image.Image) -> list[dict[str, Any]]:
    """Return thresholded alpha island areas/bounds using four-neighbor connectivity.

    This is diagnostic only. A disconnected silhouette may be intentional for
    props, cloth panels, armor plates, or semantic parts with separate pieces.
    """
    width, height = mask.size
    remaining = bytearray(mask.tobytes())
    components: list[dict[str, Any]] = []
    for seed, value in enumerate(remaining):
        if not value:
            continue
        remaining[seed] = 0
        stack = [seed]
        area = 0
        min_x = max_x = seed % width
        min_y = max_y = seed // width
        while stack:
            pixel = stack.pop()
            area += 1
            x = pixel % width
            y = pixel // width
            min_x = min(min_x, x)
            max_x = max(max_x, x)
            min_y = min(min_y, y)
            max_y = max(max_y, y)
            if x > 0 and remaining[pixel - 1]:
                remaining[pixel - 1] = 0
                stack.append(pixel - 1)
            if x + 1 < width and remaining[pixel + 1]:
                remaining[pixel + 1] = 0
                stack.append(pixel + 1)
            if pixel >= width and remaining[pixel - width]:
                remaining[pixel - width] = 0
                stack.append(pixel - width)
            if pixel + width < width * height and remaining[pixel + width]:
                remaining[pixel + width] = 0
                stack.append(pixel + width)
        components.append({"area_px": area, "bbox_xyxy_exclusive": [min_x, min_y, max_x + 1, max_y + 1]})
    return sorted(components, key=lambda component: component["area_px"], reverse=True)


def audit_cutout(
    image: Image.Image,
    *,
    alpha_threshold: int = 32,
    min_margin_fraction: float = 0.10,
    halo_alpha_threshold: int = 1,
    halo_tolerance_radius: int = 3,
    max_external_halo_pixels: int = 50,
) -> dict[str, Any]:
    if image.mode != "RGBA":
        raise ValueError("input must be RGBA with transparency")
    if not 1 <= alpha_threshold <= 255:
        raise ValueError("alpha threshold must be between 1 and 255")
    if not 0 <= halo_alpha_threshold <= 255:
        raise ValueError("halo alpha threshold must be between 0 and 255")
    if not 0 <= min_margin_fraction < 0.5:
        raise ValueError("minimum margin fraction must be in [0, 0.5)")
    if halo_tolerance_radius < 0:
        raise ValueError("halo tolerance radius cannot be negative")
    if max_external_halo_pixels < 0:
        raise ValueError("maximum halo pixels cannot be negative")

    width, height = image.size
    alpha = image.getchannel("A")
    core = alpha.point(lambda value: 255 if value >= alpha_threshold else 0)
    bbox = core.getbbox()
    if bbox is None:
        raise ValueError("input contains no pixels at the requested alpha threshold")

    x0, y0, x1, y1 = bbox
    components = _connected_components(core)
    component_areas = [component["area_px"] for component in components]
    largest_component = component_areas[0]
    secondary_component_ratio = (
        component_areas[1] / largest_component if len(component_areas) > 1 else 0.0
    )
    margins = {
        "left": x0,
        "top": y0,
        "right": width - x1,
        "bottom": height - y1,
    }
    margin_fractions = {
        "left": x0 / width,
        "top": y0 / height,
        "right": (width - x1) / width,
        "bottom": (height - y1) / height,
    }

    low_alpha = alpha.point(
        lambda value: 255 if value > halo_alpha_threshold else 0
    )
    if halo_tolerance_radius:
        size = 2 * halo_tolerance_radius + 1
        allowed_edge = core.filter(ImageFilter.MaxFilter(size))
    else:
        allowed_edge = core
    external_halo = ImageChops.subtract(low_alpha, allowed_edge)
    external_halo_pixels = external_halo.histogram()[255]

    corner_alpha = {
        "top_left": alpha.getpixel((0, 0)),
        "top_right": alpha.getpixel((width - 1, 0)),
        "bottom_left": alpha.getpixel((0, height - 1)),
        "bottom_right": alpha.getpixel((width - 1, height - 1)),
    }
    failures = []
    if any(value < min_margin_fraction for value in margin_fractions.values()):
        failures.append("insufficient_transparent_margin")
    if external_halo_pixels > max_external_halo_pixels:
        failures.append("external_low_alpha_halo")
    if any(value != 0 for value in corner_alpha.values()):
        failures.append("canvas_corner_not_transparent")

    return {
        "status": "PASS" if not failures else "FAIL",
        "scope": "mechanical_alpha_cutout_checks_only",
        "width_px": width,
        "height_px": height,
        "alpha_threshold": alpha_threshold,
        "threshold_bbox_xyxy_exclusive": [x0, y0, x1, y1],
        "connectivity_diagnostic": {
            "neighbor_rule": "4-connected",
            "component_count": len(component_areas),
            "component_areas_px_descending": component_areas,
            "component_bounds_xyxy_exclusive_descending_area": [
                component["bbox_xyxy_exclusive"] for component in components
            ],
            "largest_component_px": largest_component,
            "largest_secondary_component_ratio": round(secondary_component_ratio, 6),
            "review_note": "Diagnostic only; detached pieces may be intentional and require semantic visual review.",
        },
        "margins_px": margins,
        "margin_fractions": margin_fractions,
        "minimum_margin_fraction": min_margin_fraction,
        "halo_alpha_threshold_exclusive": halo_alpha_threshold,
        "halo_tolerance_radius_px": halo_tolerance_radius,
        "external_low_alpha_pixels": external_halo_pixels,
        "maximum_external_low_alpha_pixels": max_external_halo_pixels,
        "corner_alpha": corner_alpha,
        "failures": failures,
        "production_approved": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--alpha-threshold", type=int, default=32)
    parser.add_argument("--minimum-margin-fraction", type=float, default=0.10)
    parser.add_argument("--halo-alpha-threshold", type=int, default=1)
    parser.add_argument("--halo-tolerance-radius", type=int, default=3)
    parser.add_argument("--maximum-external-halo-pixels", type=int, default=50)
    args = parser.parse_args()

    with Image.open(args.input) as loaded:
        report = audit_cutout(
            loaded,
            alpha_threshold=args.alpha_threshold,
            min_margin_fraction=args.minimum_margin_fraction,
            halo_alpha_threshold=args.halo_alpha_threshold,
            halo_tolerance_radius=args.halo_tolerance_radius,
            max_external_halo_pixels=args.maximum_external_halo_pixels,
        )
    report["source"] = str(args.input)
    print(json.dumps(report, indent=2))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
