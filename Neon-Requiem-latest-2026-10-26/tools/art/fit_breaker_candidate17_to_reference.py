"""Create a clearly labeled, non-runtime scale/pose overlay for candidate 17."""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
ARM = DRAFTS / "BREAKER_T1_compact_vertical_arm_concept_candidate_17.png"
OUTPUT = ROOT / "docs/visual_qa/breaker_candidate09_candidate17_fit_overlay.png"


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    arm = Image.open(ARM).convert("RGBA")
    alpha = arm.getchannel("A")
    # Ignore the low-alpha generated glow when measuring the painted arm.
    bounds = alpha.point(lambda value: 255 if value > 32 else 0).getbbox()
    assert bounds is not None
    crop = arm.crop(bounds)

    # Estimated from the visible candidate 09 shoulder-to-fist height. Preserve
    # aspect ratio; a fit test must not stretch the art to force a match.
    target_height = 351
    target_width = round(crop.width * target_height / crop.height)
    target_origin = (287, 240)
    crop = crop.resize((target_width, target_height), Image.Resampling.LANCZOS)
    crop.putalpha(crop.getchannel("A").point(lambda value: value * 3 // 4))
    overlay = source.copy()
    overlay.alpha_composite(crop, dest=target_origin)

    panel_size = (512, 768)
    board = Image.new("RGB", (panel_size[0] * 2, panel_size[1]), (22, 22, 27))
    board.paste(source.resize(panel_size, Image.Resampling.LANCZOS).convert("RGB"), (0, 0))
    board.paste(overlay.resize(panel_size, Image.Resampling.LANCZOS).convert("RGB"), (panel_size[0], 0))
    draw = ImageDraw.Draw(board)
    draw.text((12, 10), "CANDIDATE 09 SOURCE", fill=(255, 255, 255))
    draw.text((panel_size[0] + 12, 10), "CANDIDATE 17 AT ESTIMATED ARM SCALE", fill=(255, 255, 255))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    board.save(OUTPUT)
    print(f"PASS: source/arm decode and fit preview created ({OUTPUT.relative_to(ROOT)})")
    print(f"Review only: content bbox {bounds}, aspect-preserved fit {target_width}x{target_height}, placement {target_origin}, 75% overlay opacity.")


if __name__ == "__main__":
    main()
