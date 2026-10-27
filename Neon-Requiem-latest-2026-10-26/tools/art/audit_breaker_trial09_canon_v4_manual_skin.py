"""Audit candidate 09 v4 split ownership, canon ROI, and neutral reconstruction."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
TRIAL = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
BASE = DRAFTS / "profile_rig_trial_09_canon_v2"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
ROI = (255, 380, 410, 470)


def is_skin(rgb: tuple[int, int, int]) -> bool:
    r, g, b = rgb
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def skin_count(image: Image.Image, box: tuple[int, int, int, int]) -> int:
    px = image.convert("RGBA").load()
    x0, y0, x1, y1 = box
    return sum(1 for y in range(y0, y1) for x in range(x0, x1) if px[x, y][3] >= 245 and is_skin(px[x, y][:3]))


def main() -> None:
    manifest = json.loads((TRIAL / "pivot_manifest.json").read_text(encoding="utf-8"))
    assert manifest["hidden_anatomy_verified"] is False
    assert manifest["shell_skin_split"]["same_parent_bone"] == "CyberShoulder"
    assert "cyber_shoulder_shell" in manifest["arm_layer_ownership"]["external_shell"]
    assert manifest["validation"]["godot_tested"] is True
    assert len(manifest["validation"]["godot_tests"]) == 2
    source = Image.open(SOURCE).convert("RGBA")
    target = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    union = Image.new("L", source.size, 0)
    assembled = Image.new("RGBA", source.size, (0, 0, 0, 0))
    for name in manifest["layers_back_to_front"]:
        layer = Image.open(TRIAL / f"{name}.png").convert("RGBA")
        assert layer.size == (1024, 1536), f"{name} has a mismatched source canvas"
        alpha = layer.getchannel("A")
        assert ImageChops.multiply(union, alpha).getbbox() is None, f"exclusive ownership overlap at {name}"
        assembled.alpha_composite(layer)
        union = ImageChops.lighter(union, alpha)
    expected = source.copy()
    expected.putalpha(target)
    assert ImageChops.difference(assembled, expected).getbbox() is None, "full neutral image does not reconstruct exactly"
    assert ImageChops.subtract(target, union).getbbox() is None, "visible silhouette has unowned pixels"

    upper = Image.open(TRIAL / "cyber_upper_arm_skin.png").convert("RGBA")
    shell = Image.open(TRIAL / "cyber_shoulder_shell.png").convert("RGBA")
    forearm = Image.open(TRIAL / "cyber_forearm.png").convert("RGBA")
    upper_roi = skin_count(upper, ROI)
    shell_roi = skin_count(shell, ROI)
    forearm_roi = skin_count(forearm, ROI)
    assert upper_roi >= 5000, f"visible bicep skin ownership too low: {upper_roi}"
    assert shell_roi == 0, f"bicep color pixels assigned to shell: {shell_roi}"
    assert forearm_roi == 0, f"bicep color pixels assigned to forearm: {forearm_roi}"
    old_upper = Image.open(BASE / "cyber_upper_arm.png").convert("RGBA")
    arm_composite = Image.alpha_composite(upper, shell)
    assert ImageChops.difference(arm_composite, old_upper).getbbox() is None, "skin/shell split differs from source upper-arm texture"
    assert (TRIAL / ".gdignore").exists(), "trial art must remain excluded from Godot runtime import"

    print(f"PASS: {len(manifest['layers_back_to_front'])} exclusive layers; full neutral character exactly reconstructs candidate 09.")
    print(f"PASS: arm split exact; bicep ROI skin pixels: biological={upper_roi}, shell={shell_roi}, forearm={forearm_roi}.")
    print("LIMIT: concealed skin under shell, pivots, and animation are not validated by this Python audit.")


if __name__ == "__main__":
    main()
