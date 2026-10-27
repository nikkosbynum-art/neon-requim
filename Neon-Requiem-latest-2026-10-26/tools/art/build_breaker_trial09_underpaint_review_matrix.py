"""Build a legible owner-review board for quarantined BREAKER arm studies."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
V5 = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint/hidden_biological_upper_arm_donor.png"
V6 = DRAFTS / "profile_rig_trial_09_canon_v6_reference_contour/hidden_biological_upper_arm_donor.png"
V9 = DRAFTS / "profile_rig_trial_09_canon_v9_continuous_arm_underpaint/hidden_biological_upper_arm_donor.png"
OUTPUT = ROOT / "docs/visual_qa/BREAKER_T1_underpaint_visual_review_matrix.png"
CROP = (220, 220, 485, 520)


def composite(donor_path: Path | None, shell_on: bool) -> Image.Image:
    output = Image.new("RGBA", (1024, 1536), (22, 26, 32, 255))
    if donor_path is not None:
        output.alpha_composite(Image.open(donor_path).convert("RGBA"))
    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    for name in layers:
        if not shell_on and name == "cyber_shoulder_shell":
            continue
        output.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return output


def main() -> None:
    font = ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", 24)
    panels = [
        ("V5 · GENERATED SKIN DONOR · SHELL OFF", composite(V5, False)),
        ("V6 · REFERENCE-GUIDED DONOR · SHELL OFF", composite(V6, False)),
        ("V9 · CONTINUOUS UNDERLAYER · SHELL OFF", composite(V9, False)),
        ("APPROVED CANDIDATE 09 · SHELL ON", Image.open(SOURCE).convert("RGBA")),
    ]
    scale, margin, label_h, gap = 2.25, 28, 56, 24
    pw, ph = round((CROP[2] - CROP[0]) * scale), round((CROP[3] - CROP[1]) * scale)
    tile_w, tile_h = pw + margin * 2, ph + label_h + margin * 2
    board = Image.new("RGB", (tile_w * 2 + gap, tile_h * 2 + gap), "#11151a")
    draw = ImageDraw.Draw(board)
    for i, (label, image) in enumerate(panels):
        col, row = i % 2, i // 2
        x0, y0 = col * (tile_w + gap), row * (tile_h + gap)
        draw.rounded_rectangle((x0, y0, x0 + tile_w, y0 + tile_h), radius=10, fill="#1b2129")
        draw.text((x0 + margin, y0 + 14), label, font=font, fill="#edf1f5")
        crop = image.crop(CROP).resize((pw, ph), Image.Resampling.NEAREST)
        board.paste(crop.convert("RGB"), (x0 + margin, y0 + label_h + margin))
    board.save(OUTPUT, optimize=True)
    print(f"PASS: built 2x2 review board at {board.width}x{board.height} with four labeled panels.")
    print("LIMIT: shell-off panels are diagnostic hypotheses; the shell-on reference is the approved visible target.")
    print(f"QA: {OUTPUT.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
