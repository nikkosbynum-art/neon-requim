"""Render a neutral, same-scale review of guarded draft 05 vs canon draft 07."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
OUT = ROOT / "docs/visual_qa/BREAKER_T1_canon_candidate_07_comparison.png"
items = [
    (DRAFTS / "BREAKER_T1_profile_cutout_candidate_02.png", "APPROVED PROFILE — APPEARANCE ANCHOR"),
    (DRAFTS / "BREAKER_T1_guarded_pose_review_candidate_05.png", "GUARD DRAFT 05 — ARM EXTENT FROM REF"),
    (DRAFTS / "BREAKER_T1_tier1_canon_review_candidate_07.png", "DRAFT 07 — ARM EXTENT FROM TIER I SPEC"),
]
panel_w, panel_h = 440, 370
image_height = 256
ground_y = 335
canvas = Image.new("RGBA", (panel_w * len(items), panel_h), "#11161c")
draw = ImageDraw.Draw(canvas)
font = ImageFont.load_default()

for index, (path, label) in enumerate(items):
    source = Image.open(path).convert("RGBA")
    alpha = source.getchannel("A").point(lambda value: 255 if value >= 245 else 0)
    bounds = alpha.getbbox()
    assert bounds is not None
    figure = source.crop(bounds)
    scale = image_height / figure.height
    resized = figure.resize((round(figure.width * scale), image_height), Image.Resampling.LANCZOS)
    x = index * panel_w + (panel_w - resized.width) // 2
    y = ground_y - image_height
    canvas.alpha_composite(resized, (x, y))
    draw.text((index * panel_w + 16, 24), label, fill="#f1d5a0", font=font)
    draw.line((index * panel_w + 24, ground_y, (index + 1) * panel_w - 24, ground_y), fill="#57dce3", width=2)
    draw.text((index * panel_w + 16, panel_h - 23), "256 px visible height • shared ground baseline", fill="#aab8c7", font=font)

canvas.convert("RGB").save(OUT, quality=95)
print(OUT)
