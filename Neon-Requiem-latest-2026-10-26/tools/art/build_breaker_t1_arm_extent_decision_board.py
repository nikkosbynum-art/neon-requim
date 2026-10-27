from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "assets/characters/breaker/tier_01_drafts"
OUT = ROOT / "docs/visual_qa/BREAKER_T1_arm_extent_decision_board.png"
SOURCES = [
    (
        "A — Written Tier I spec",
        "Candidate 07: human shoulder/upper arm; cybernetic forearm/fist",
        ART / "BREAKER_T1_tier1_canon_review_candidate_07.png",
        (285, 180, 760, 900),
    ),
    (
        "B — Approved profile silhouette",
        "Candidate 05: machinery continues through shoulder/upper arm",
        ART / "BREAKER_T1_guarded_pose_review_candidate_05.png",
        (285, 180, 760, 900),
    ),
]

W, H = 1800, 1370
BG = (15, 19, 25)
PANEL = (25, 31, 39)
INK = (237, 241, 245)
MUTED = (169, 181, 194)
CYAN = (71, 220, 235)
CRIMSON = (236, 67, 83)
img = Image.new("RGB", (W, H), BG)
draw = ImageDraw.Draw(img)
font_path = "C:/Windows/Fonts/segoeui.ttf"
bold_path = "C:/Windows/Fonts/segoeuib.ttf"
font_title = ImageFont.truetype(bold_path, 36)
font_sub = ImageFont.truetype(font_path, 22)
font_label = ImageFont.truetype(bold_path, 23)
font_note = ImageFont.truetype(font_path, 18)

draw.text((50, 34), "BREAKER TIER I — ARM EXTENT DECISION", fill=INK, font=font_title)
draw.text((50, 84), "Two quarantined readings of the conflicting written spec and approved visual reference", fill=MUTED, font=font_sub)

margin, gap = 50, 30
panel_w = (W - 2 * margin - gap) // 2
panel_y, panel_h = 140, 1110
for idx, (title, subtitle, path, crop_box) in enumerate(SOURCES):
    x = margin + idx * (panel_w + gap)
    draw.rounded_rectangle((x, panel_y, x + panel_w, panel_y + panel_h), radius=18, fill=PANEL)
    accent = CYAN if idx == 0 else CRIMSON
    draw.rounded_rectangle((x + 24, panel_y + 22, x + 34, panel_y + 91), radius=5, fill=accent)
    draw.text((x + 52, panel_y + 22), title, fill=INK, font=font_label)
    draw.text((x + 52, panel_y + 57), subtitle, fill=MUTED, font=font_note)

    source = Image.open(path).convert("RGBA")
    alpha = source.getchannel("A")
    box = alpha.point(lambda a: 255 if a >= 245 else 0).getbbox()
    if not box:
        raise RuntimeError(f"No visible alpha silhouette in {path}")
    figure = source.crop(box)
    target_h = 590
    target_w = round(figure.width * target_h / figure.height)
    figure = figure.resize((target_w, target_h), Image.Resampling.LANCZOS)
    figure_x = x + (panel_w - target_w) // 2
    figure_y = panel_y + 105
    stage = Image.new("RGBA", (panel_w - 40, target_h + 22), (0, 0, 0, 0))
    stage.alpha_composite(figure, ((stage.width - target_w) // 2, 0))
    img.paste(stage.convert("RGB"), (x + 20, figure_y), stage.getchannel("A"))
    floor_y = figure_y + target_h + 5
    draw.line((x + 35, floor_y, x + panel_w - 35, floor_y), fill=accent, width=2)
    draw.text((x + 38, floor_y + 9), "Same 256 px visible-height review scale", fill=MUTED, font=font_note)

    detail_label_y = floor_y + 45
    draw.text((x + 38, detail_label_y), "SHOULDER → ELBOW → FOREARM DETAIL", fill=accent, font=font_note)
    detail = source.crop(crop_box)
    detail.thumbnail((panel_w - 76, 330), Image.Resampling.LANCZOS)
    detail_x = x + (panel_w - detail.width) // 2
    detail_y = detail_label_y + 34 + (330 - detail.height) // 2
    checker = Image.new("RGB", detail.size, (31, 38, 47))
    checker_draw = ImageDraw.Draw(checker)
    cell = 24
    for yy in range(0, detail.height, cell):
        for xx in range(0, detail.width, cell):
            if ((xx // cell) + (yy // cell)) % 2:
                checker_draw.rectangle((xx, yy, xx + cell, yy + cell), fill=(38, 46, 57))
    img.paste(checker, (detail_x, detail_y))
    img.paste(detail.convert("RGB"), (detail_x, detail_y), detail.getchannel("A"))

draw.text((50, H - 78), "Both are drafts, not final art. The user's arm-scope choice is still pending; neither version has been promoted.", fill=INK, font=font_note)
draw.text((50, H - 48), "Static images only: the board compares visible design language. Hidden anatomy, pivots, and animation require separate validation.", fill=MUTED, font=font_note)

OUT.parent.mkdir(parents=True, exist_ok=True)
img.save(OUT, optimize=True)
print(f"Wrote {OUT} ({W}×{H})")
