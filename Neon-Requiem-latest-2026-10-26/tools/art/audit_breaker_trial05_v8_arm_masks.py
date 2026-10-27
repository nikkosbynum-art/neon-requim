"""Build a reproducible arm-mask overlay for BREAKER trial 05 v8.

The heuristic only identifies visible skin-colored source pixels in a manually
bounded shoulder/upper-arm ROI. It cannot infer occluded anatomy or canon.
"""
from __future__ import annotations

import json
from hashlib import sha256
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
RIG = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v8"
SOURCE = RIG / "reference_cutout.png"
SOURCE_DRAFT = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_05.png"
CYBER = RIG / "cyber_upper_arm.png"
NATURAL = RIG / "natural_upper_arm.png"
META = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_05.json"
OUTPUT = ROOT / "docs/visual_qa/BREAKER_T1_trial05_v8_arm_mask_ownership_audit.png"
ROI = (340, 230, 470, 390)
MIN_SKIN_PIXELS = 2500


def skin_color_heuristic(r: int, g: int, b: int) -> bool:
    """Broad warm-skin color heuristic; manual inspection is still required."""
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    cyber = Image.open(CYBER).convert("RGBA")
    natural = Image.open(NATURAL).convert("RGBA")
    metadata = json.loads(META.read_text(encoding="utf-8"))
    assert source.size == cyber.size == natural.size == (1024, 1536)
    assert metadata["file"] == SOURCE_DRAFT.relative_to(ROOT).as_posix()
    assert sha256(SOURCE_DRAFT.read_bytes()).hexdigest().upper() == metadata["sha256"].upper(), "Trial-05 source draft differs from its recorded hash."

    source_pixels = source.crop(ROI).tobytes()
    cyber_alpha = cyber.getchannel("A").crop(ROI).tobytes()
    natural_alpha = natural.getchannel("A").crop(ROI).tobytes()
    skin_in_cyber = 0
    skin_in_natural = 0
    for index, (ca, na) in enumerate(zip(cyber_alpha, natural_alpha)):
        offset = index * 4
        r, g, b, a = source_pixels[offset : offset + 4]
        if a > 0 and skin_color_heuristic(r, g, b):
            skin_in_cyber += ca >= 245
            skin_in_natural += na >= 245
    assert skin_in_cyber >= MIN_SKIN_PIXELS, skin_in_cyber
    assert skin_in_natural == 0, skin_in_natural

    width, height = 1200, 900
    pad = 24
    panel_w = (width - pad * 3) // 2
    panel_h = height - pad * 2
    canvas = Image.new("RGB", (width, height), (18, 22, 28))
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()

    def overlay(image: Image.Image, layers: list[tuple[Image.Image, tuple[int, int, int, int]]], size: tuple[int, int]) -> Image.Image:
        result = Image.new("RGBA", size, (32, 37, 45, 255))
        result.alpha_composite(image.resize(size, Image.Resampling.LANCZOS))
        for layer, color in layers:
            mask = layer.getchannel("A").resize(size, Image.Resampling.NEAREST)
            tint = Image.new("RGBA", size, color)
            tint.putalpha(mask.point(lambda alpha: min(color[3], int(alpha * 0.70))))
            result.alpha_composite(tint)
        return result.convert("RGB")

    full_scale = min((panel_w - 24) / source.width, (panel_h - 60) / source.height)
    full_size = (round(source.width * full_scale), round(source.height * full_scale))
    full = overlay(source, [(cyber, (255, 55, 96, 170)), (natural, (34, 210, 255, 170))], full_size)
    left_x, top_y = pad, pad + 26
    canvas.paste(full, (left_x, top_y))
    draw.text((left_x, pad), "Source ownership: red = cyber_upper_arm; cyan = natural_upper_arm", fill="white", font=font)

    crop = source.crop((190, 170, 890, 660))
    crop_layers = [
        (cyber.crop((190, 170, 890, 660)), (255, 55, 96, 185)),
        (natural.crop((190, 170, 890, 660)), (34, 210, 255, 185)),
    ]
    crop_scale = min((panel_w - 24) / crop.width, (panel_h - 60) / crop.height)
    crop_size = (round(crop.width * crop_scale), round(crop.height * crop_scale))
    right_x = pad * 2 + panel_w
    canvas.paste(overlay(crop, crop_layers, crop_size), (right_x, top_y))
    draw.text((right_x, pad), "Shoulder ROI: source skin pixels are owned by cyber_upper_arm", fill="white", font=font)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUTPUT)
    print(f"PASS: {skin_in_cyber} skin-color heuristic pixels in cyber_upper_arm ROI; {skin_in_natural} in natural_upper_arm ROI.")
    print(f"PASS: built {OUTPUT.relative_to(ROOT).as_posix()} ({width}x{height}).")
    print("LIMIT: the color heuristic plus mask ownership is not semantic anatomy proof; occluded fills remain inferred.")


if __name__ == "__main__":
    main()
