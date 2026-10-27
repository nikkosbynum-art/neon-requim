"""Audit the quarantined candidate 15 concept against its candidate 09 source.

This checks image structure and reports visual-difference measurements only.
It cannot validate anatomy, alpha cutout quality, pivots, or animation seams.
"""

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageStat


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
REVIEW = DRAFTS / "BREAKER_T1_arm_boundary_reading_candidate_15.png"
OUT = ROOT / "docs/visual_qa/breaker_candidate09_vs_candidate15_arm_review.png"
ARM_ROI = (220, 205, 500, 535)


def rgb_mae(image_a: Image.Image, image_b: Image.Image, box: tuple[int, int, int, int]) -> float:
    difference = ImageChops.difference(image_a.crop(box), image_b.crop(box))
    return sum(ImageStat.Stat(difference).mean) / 3.0


def main() -> None:
    source = Image.open(SOURCE).convert("RGB")
    review_rgba = Image.open(REVIEW).convert("RGBA")
    review = review_rgba.convert("RGB")
    assert source.size == review.size == (1024, 1536), "reference canvas changed"

    alpha_histogram = review_rgba.getchannel("A").histogram()
    assert alpha_histogram[255] == 1024 * 1536, "candidate 15 opaque-background status changed"

    # Side-by-side canvas for manual art review, with arm crops enlarged separately.
    panel_width, panel_height = 512, 768
    board = Image.new("RGB", (panel_width * 2, panel_height + 300), (24, 24, 29))
    source_panel = source.resize((panel_width, panel_height), Image.Resampling.LANCZOS)
    review_panel = review.resize((panel_width, panel_height), Image.Resampling.LANCZOS)
    board.paste(source_panel, (0, 0))
    board.paste(review_panel, (panel_width, 0))
    draw = ImageDraw.Draw(board)
    draw.text((12, 8), "CANDIDATE 09 SOURCE", fill=(255, 255, 255))
    draw.text((panel_width + 12, 8), "CANDIDATE 15 REVIEW", fill=(255, 255, 255))

    crop_width, crop_height = 560, 660
    source_crop = source.crop(ARM_ROI).resize((crop_width, crop_height), Image.Resampling.LANCZOS)
    review_crop = review.crop(ARM_ROI).resize((crop_width, crop_height), Image.Resampling.LANCZOS)
    board = Image.new("RGB", (crop_width * 2, panel_height + crop_height), (24, 24, 29))
    board.paste(source_panel, (0, 0))
    board.paste(review_panel, (panel_width, 0))
    draw = ImageDraw.Draw(board)
    draw.text((12, 8), "CANDIDATE 09 SOURCE", fill=(255, 255, 255))
    draw.text((panel_width + 12, 8), "CANDIDATE 15 REVIEW", fill=(255, 255, 255))
    board.paste(source_crop, (0, panel_height))
    board.paste(review_crop, (crop_width, panel_height))
    draw = ImageDraw.Draw(board)
    draw.text((12, panel_height + 8), "ARM ROI", fill=(255, 255, 255))
    draw.text((crop_width + 12, panel_height + 8), "ARM ROI", fill=(255, 255, 255))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    board.save(OUT)

    print(f"PASS: both images decode at {source.width}x{source.height}")
    print(f"PASS: candidate 15 is fully opaque ({alpha_histogram[255]} opaque pixels)")
    print(f"Arm ROI RGB MAE: {rgb_mae(source, review, ARM_ROI):.3f}")
    print(f"Full-canvas RGB MAE: {rgb_mae(source, review, (0, 0, 1024, 1536)):.3f}")
    print("NOT TESTED: canon legibility, transparent cutout, components, pivots, concealed anatomy, animation/seams")
    print(f"Review board: {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
