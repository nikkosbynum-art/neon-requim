from pathlib import Path
import json

from PIL import Image, ImageDraw, ImageFont


ROOT = Path.cwd()
CANDIDATE = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02"
UNDERPAINT = CANDIDATE / "CIPHER_T1_NEAR_KNEE_LEG_UNDERPAINT_INFERRED_CANDIDATE_09B_04_QUARANTINED.png"
OUT = ROOT / "docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_BEND_REVIEW_04_QUARANTINED.png"
CANVAS_SIZE = (330, 960)
PAD = 60
PIVOT = (170, 655)  # Profile-crop coordinates; source turnaround (770, 665).
CROP = (50, 560, 285, 840)
SCALE = 2

manifest = json.loads((CANDIDATE / "parts_manifest.json").read_text(encoding="utf-8"))
parts = manifest["parts"]
underpaint = Image.open(UNDERPAINT).convert("RGBA")
part_ids = ("near_thigh", "near_shin", "near_knee_guard", "near_boot")
aligned: dict[str, Image.Image] = {}
for part_id in part_ids:
    info = parts[part_id]
    image = Image.open(CANDIDATE / info["file"]).convert("RGBA")
    x0, y0, _, _ = info["source_bbox_xyxy"]
    layer = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    layer.alpha_composite(image, (x0 - PAD, y0 - PAD))
    aligned[part_id] = layer


def render_pose(angle: float) -> Image.Image:
    result = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    result.alpha_composite(underpaint)
    for part_id in part_ids:
        layer = aligned[part_id]
        if part_id in ("near_shin", "near_knee_guard", "near_boot") and angle:
            layer = layer.rotate(
                angle,
                resample=Image.Resampling.BICUBIC,
                center=PIVOT,
                expand=False,
            )
        result.alpha_composite(layer)
    return result.crop(CROP)


panels = [("NEUTRAL", 0), ("SMALL BACK FLEX — 12°", -12), ("BACK FLEX — 20°", -20)]
panel_w = (CROP[2] - CROP[0]) * SCALE
panel_h = (CROP[3] - CROP[1]) * SCALE
margin, gap, header = 24, 18, 124
canvas = Image.new("RGB", (margin * 2 + panel_w * 3 + gap * 2, header + panel_h + margin), "#171a20")
draw = ImageDraw.Draw(canvas)
font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 19)
small = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 14)
draw.text((margin, 16), "CIPHER T1 — inferred knee underpaint bend review 04", fill="#ffffff", font=font)
draw.text((margin, 46), "Rigid cutout transform study around approved pivot (770, 665); review proxy, not a deforming production rig.", fill="#d8dde6", font=small)
draw.text((margin, 68), "Flat inferred fill is behind source layers; checkerboard shows remaining gaps. Review at 12° and 20°.", fill="#d8dde6", font=small)

for index, (label, angle) in enumerate(panels):
    x = margin + index * (panel_w + gap)
    draw.text((x, header - 21), label, fill="#f0f2f7", font=small)
    crop = render_pose(angle).resize((panel_w, panel_h), Image.Resampling.LANCZOS)
    panel = Image.new("RGBA", crop.size, (55, 63, 73, 255))
    panel_draw = ImageDraw.Draw(panel)
    tile = 20
    for yy in range(0, panel_h, tile):
        for xx in range(0, panel_w, tile):
            if ((xx // tile) + (yy // tile)) % 2:
                panel_draw.rectangle((xx, yy, xx + tile - 1, yy + tile - 1), fill="#303842")
    panel.alpha_composite(crop)
    canvas.paste(panel.convert("RGB"), (x, header))
    marker = (x + (PIVOT[0] - CROP[0]) * SCALE, header + (PIVOT[1] - CROP[1]) * SCALE)
    marker_draw = ImageDraw.Draw(canvas)
    marker_draw.ellipse((marker[0] - 6, marker[1] - 6, marker[0] + 6, marker[1] + 6), outline="#fff36b", width=2)
    marker_draw.line((marker[0] - 10, marker[1], marker[0] + 10, marker[1]), fill="#ff345d", width=2)
    marker_draw.line((marker[0], marker[1] - 10, marker[0], marker[1] + 10), fill="#ff345d", width=2)

canvas.save(OUT)
print(OUT)
