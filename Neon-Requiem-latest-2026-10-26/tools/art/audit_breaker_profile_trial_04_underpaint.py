"""Check trial-04 inferred underpaint integrity and static-source preservation."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_hidden_anatomy_candidate_03.png"
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_04_inferred_underpaint"


def main() -> int:
    source = Image.open(SOURCE).convert("RGBA")
    manifest = json.loads((TRIAL / "pivot_manifest.json").read_text(encoding="utf-8"))
    composite = Image.new("RGBA", source.size, (0, 0, 0, 0))
    underpaint_pixels = 0
    sampled_rgb_changes = 0
    src_rgb = source.convert("RGB").load()

    for part in manifest["layers_back_to_front"]:
        layer = Image.open(TRIAL / f"underpaint_{part}.png").convert("RGBA")
        if layer.size != source.size:
            raise ValueError(f"underpaint_{part}.png size mismatch")
        alpha = layer.getchannel("A")
        if any(alpha.getpixel(point) != 0 for point in ((0, 0), (1023, 0), (0, 1535), (1023, 1535))):
            raise ValueError(f"underpaint_{part}.png has a nontransparent canvas corner")
        pixels = layer.load()
        for y in range(layer.height):
            for x in range(layer.width):
                if pixels[x, y][3] > 0:
                    underpaint_pixels += 1
                    if pixels[x, y][:3] != src_rgb[x, y]:
                        sampled_rgb_changes += 1
        composite.alpha_composite(layer)

    for part in manifest["layers_back_to_front"]:
        composite.alpha_composite(Image.open(TRIAL / f"{part}.png").convert("RGBA"))

    reference = source.copy()
    reference.putalpha(source.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    difference = ImageChops.difference(composite, reference)
    exact = difference.getbbox() is None
    print(f"Underpaint pixels: {underpaint_pixels}")
    print(f"Underpaint RGB values differing from the same source coordinate: {sampled_rgb_changes}")
    print(f"Neutral composite exactly preserves thresholded candidate 03: {exact}")
    print("ANATOMY STATUS: INFERRED ONLY / NOT VERIFIED; this script tests file and neutral fidelity, not semantic anatomy.")
    return 0 if underpaint_pixels > 0 and sampled_rgb_changes > 0 and exact else 1


if __name__ == "__main__":
    raise SystemExit(main())
