"""Audit candidate 09 v2 layer ownership, neutral reconstruction and canon ROI."""
from __future__ import annotations

import json
from hashlib import sha256
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
TRIAL = DRAFTS / "profile_rig_trial_09_canon_v2"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
ROI = (255, 380, 410, 470)


def is_skin(r: int, g: int, b: int) -> bool:
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def skin_count(image: Image.Image, roi: tuple[int, int, int, int]) -> int:
    px = image.convert("RGBA").load()
    x0, y0, x1, y1 = roi
    return sum(
        1
        for y in range(y0, y1)
        for x in range(x0, x1)
        if px[x, y][3] >= 245 and is_skin(*px[x, y][:3])
    )


def main() -> None:
    manifest = json.loads((TRIAL / "pivot_manifest.json").read_text(encoding="utf-8"))
    assert manifest["source_sha256"] == sha256(SOURCE.read_bytes()).hexdigest()
    assert manifest["hidden_anatomy_verified"] is False
    source = Image.open(SOURCE).convert("RGBA")
    target = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    assembled = Image.new("RGBA", source.size, (0, 0, 0, 0))
    union = Image.new("L", source.size, 0)
    layers = []
    for name in manifest["layers_back_to_front"]:
        layer = Image.open(TRIAL / f"{name}.png").convert("RGBA")
        assert layer.size == source.size == (1024, 1536), f"{name}: shared canvas mismatch"
        alpha = layer.getchannel("A")
        assert ImageChops.multiply(union, alpha).getbbox() is None, f"visible ownership overlap: {name}"
        assembled.alpha_composite(layer)
        union = ImageChops.lighter(union, alpha)
        layers.append(name)
    assert ImageChops.subtract(target, union).getbbox() is None, "visible silhouette has unowned pixels"
    assert ImageChops.subtract(union, target).getbbox() is None, "a layer extends outside the target silhouette"
    expected = source.copy()
    expected.putalpha(target)
    assert ImageChops.difference(assembled, expected).getbbox() is None, "neutral composite differs from source"

    upper = Image.open(TRIAL / "cyber_upper_arm.png").convert("RGBA")
    forearm = Image.open(TRIAL / "cyber_forearm.png").convert("RGBA")
    upper_skin = skin_count(upper, ROI)
    forearm_skin = skin_count(forearm, ROI)
    assert upper_skin >= 5000, f"biological bicep pixels were not assigned to the upper-arm layer: {upper_skin}"
    assert forearm_skin == 0, f"biological bicep pixels remain on mechanical forearm layer: {forearm_skin}"

    print(f"PASS: {len(layers)} exclusive layers; exact neutral reconstruction; no silhouette gaps or spill.")
    print(f"PASS: approved anatomy ROI has {upper_skin} warm-skin pixels on cyber_upper_arm and {forearm_skin} on cyber_forearm.")
    print("LIMIT: color heuristic validates visible layer ownership only; hidden anatomy, shell separation and deformation remain NOT VERIFIED.")


if __name__ == "__main__":
    main()
