"""Audit whether BREAKER trial 03 contains independently authored under-paint.

This is a provenance/coverage audit, not an anatomy detector. The current
exporter derives layer RGB from the flattened source, so this check documents
whether that remains true and prevents overlap-mask coverage from being
misreported as verified hidden anatomy.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_hidden_anatomy_candidate_03.png"
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_03"


def main() -> int:
    manifest = json.loads((TRIAL / "pivot_manifest.json").read_text(encoding="utf-8"))
    source = Image.open(SOURCE).convert("RGBA")
    source_rgb = source.convert("RGB")
    silhouette = source.getchannel("A").point(lambda alpha: 255 if alpha >= 245 else 0)
    silhouette_data = list(silhouette.get_flattened_data())
    src_data = list(source_rgb.get_flattened_data())
    coverage = [0] * (source.width * source.height)
    differing_layer_pixels = 0
    layer_pixel_count = 0
    outside_silhouette = 0

    for part in manifest["parts"]:
        layer = Image.open(TRIAL / part["file"]).convert("RGBA")
        if layer.size != source.size:
            raise ValueError(f"{part['file']} has size {layer.size}, expected {source.size}")
        layer_rgb = layer.convert("RGB")
        alpha_data = list(layer.getchannel("A").get_flattened_data())
        rgb_data = list(layer_rgb.get_flattened_data())
        for index, alpha in enumerate(alpha_data):
            if alpha == 0:
                continue
            layer_pixel_count += 1
            coverage[index] += 1
            if silhouette_data[index] == 0:
                outside_silhouette += 1
            if rgb_data[index] != src_data[index]:
                differing_layer_pixels += 1

    overlap_pixels = sum(1 for count in coverage if count >= 2)
    triple_pixels = sum(1 for count in coverage if count >= 3)
    silhouette_pixels = sum(1 for alpha in silhouette_data if alpha > 0)
    overlap_ratio = overlap_pixels / max(1, silhouette_pixels)

    print(f"Parts checked: {len(manifest['parts'])}")
    print(f"Layer pixel samples checked: {layer_pixel_count}")
    print(f"Layer RGB differing from flattened source at the same pixel: {differing_layer_pixels}")
    print(f"Layer pixels outside source alpha>=245 silhouette: {outside_silhouette}")
    print(f"Overlapped silhouette pixels (2+ layers): {overlap_pixels} ({overlap_ratio:.2%})")
    print(f"Triple-covered silhouette pixels: {triple_pixels}")
    print("RESULT: HIDDEN ANATOMY NOT VERIFIED. Pixel provenance alone cannot certify semantic under-paint.")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
