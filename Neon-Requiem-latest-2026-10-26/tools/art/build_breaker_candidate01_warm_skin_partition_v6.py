"""Build a quarantined warm-skin-only split for the candidate01 arm layer.

This experiment keeps source pixels only where the existing skin mask and the
source's warm skin palette agree. Every excluded source pixel goes to the
complementary shell layer, so shell-on composition remains reversible.
"""
from collections import deque
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
PARTS = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01"
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy"
SOURCE = PARTS / "cyber_upper_arm.png"
MASK_SOURCE = TRIAL / "candidate01_biological_upper_arm_visible_v4.png"
SKIN_OUT = TRIAL / "candidate01_biological_upper_arm_visible_v6_warm_pixels.png"
SHELL_OUT = TRIAL / "candidate01_external_shoulder_shell_v6_complement.png"


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    old_mask = Image.open(MASK_SOURCE).convert("RGBA").getchannel("A")
    width, height = source.size
    src, old, = source.load(), old_mask.load()
    mask = Image.new("L", source.size, 0)
    out = mask.load()
    count = 0
    for y in range(height):
        for x in range(width):
            r, g, b, a = src[x, y]
            if old[x, y] >= 245 and a >= 245 and r - g >= 22 and g - b >= 6 and r >= 95:
                out[x, y] = 255
                count += 1
    if count < 1000:
        raise AssertionError(f"Skin palette filter retained too few pixels: {count}")
    skin = source.copy()
    skin.putalpha(Image.composite(source.getchannel("A"), Image.new("L", source.size, 0), mask))
    complement = Image.eval(mask, lambda value: 0 if value >= 245 else 255)
    shell = source.copy()
    shell.putalpha(Image.composite(source.getchannel("A"), Image.new("L", source.size, 0), complement))
    if Image.alpha_composite(shell, skin).tobytes() != source.tobytes():
        raise AssertionError("Warm skin/shell split did not reconstruct exact source pixels")
    for path in (SKIN_OUT, SHELL_OUT):
        if path.exists():
            raise SystemExit(f"Refusing to overwrite existing review output: {path}")
    skin.save(SKIN_OUT, optimize=True)
    shell.save(SHELL_OUT, optimize=True)
    print(f"PASS: exact shell-on source reconstruction; warm-skin partition has {count} pixels.")
    print("LIMIT: color segmentation is a review experiment, not validated art or production masking.")


if __name__ == "__main__":
    main()
