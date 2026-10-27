"""Build a cropped source/edit comparison before extracting any hidden anatomy."""
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
EDIT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v5_generated_underpaint/generated_reference_edit.png"
OUTPUT = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v5_generated_underpaint_roi_comparison.png"
ROI = (220, 220, 490, 510)
SCALE = 2


def main() -> None:
    source = Image.open(SOURCE).convert("RGB")
    edited = Image.open(EDIT).convert("RGB")
    if source.size != (1024, 1536) or edited.size != source.size:
        raise ValueError(f"Unexpected canvases: source={source.size}, edit={edited.size}")
    crop_source = source.crop(ROI).resize(((ROI[2]-ROI[0])*SCALE, (ROI[3]-ROI[1])*SCALE), Image.Resampling.NEAREST)
    crop_edited = edited.crop(ROI).resize(crop_source.size, Image.Resampling.NEAREST)
    delta = ImageChops.difference(source.crop(ROI), edited.crop(ROI)).convert("RGB")
    delta = delta.resize(crop_source.size, Image.Resampling.NEAREST)
    panels = [crop_source, crop_edited, delta]
    labels = ["SOURCE ARM REGION", "GENERATED EDIT", "RGB DIFFERENCE"]
    margin, label_h, gap = 24, 34, 18
    panel_w, panel_h = crop_source.size
    board = Image.new("RGB", (margin*2 + panel_w*3 + gap*2, margin*2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for index, (label, panel) in enumerate(zip(labels, panels)):
        x = margin + index * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.paste(panel, (x, margin + label_h))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    board.save(OUTPUT)
    print(f"QA: {OUTPUT.relative_to(ROOT).as_posix()}")
    print(f"PASS: matching canvas and crop {ROI}; this board is for visual review, not asset approval.")


if __name__ == "__main__":
    main()
