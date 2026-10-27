from pathlib import Path
import json

from PIL import Image, ImageDraw, ImageFont, ImageChops


ROOT = Path.cwd()
CANDIDATE = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02"
MANIFEST = CANDIDATE / "parts_manifest.json"
UNDERPAINT = CANDIDATE / "CIPHER_T1_NEAR_KNEE_LEG_UNDERPAINT_INFERRED_CANDIDATE_09B_02_QUARANTINED.png"
ISOLATED_REVIEW = ROOT / "docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_ISOLATED_02_QUARANTINED.png"
CANVAS_SIZE = (330, 960)
PAD = 60
KNEE_REGION = (90, 580, 240, 760)  # Profile-crop coordinates; contains the entire local joint silhouette.
FILL_RGB = (40, 35, 36)  # Median sampled from adjacent opaque trouser fabric.
SOURCE_SAMPLE = (155, 680, 175, 700)

if UNDERPAINT.exists() or ISOLATED_REVIEW.exists():
    raise SystemExit("Refusing to overwrite an existing underpaint candidate or review image.")

manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
parts = manifest["parts"]
union = Image.new("L", CANVAS_SIZE, 0)
for part_id in ("near_thigh", "near_shin", "near_knee_guard"):
    info = parts[part_id]
    image = Image.open(CANDIDATE / info["file"]).convert("RGBA")
    x0, y0, _, _ = info["source_bbox_xyxy"]
    aligned = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    aligned.alpha_composite(image, (x0 - PAD, y0 - PAD))
    union = ImageChops.lighter(union, aligned.getchannel("A"))

# Keep only opaque source-owned interior pixels in a tight knee neighborhood.
# This guarantees the underpaint stays hidden in the neutral view; its RGB is
# inferred and deliberately carries no source marks or seam details.
interior = union.point(lambda value: 255 if value >= 250 else 0)
region = Image.new("L", CANVAS_SIZE, 0)
ImageDraw.Draw(region).rectangle(KNEE_REGION, fill=255)
alpha = ImageChops.multiply(interior, region)
layer = Image.new("RGBA", CANVAS_SIZE, (*FILL_RGB, 0))
layer.putalpha(alpha)
layer.save(UNDERPAINT)

# Render an isolated view of the exact underpaint footprint over transparency.
crop_box = (50, 560, 285, 840)
scale = 2
body = layer.crop(crop_box).resize(((crop_box[2] - crop_box[0]) * scale, (crop_box[3] - crop_box[1]) * scale), Image.Resampling.NEAREST)
header, margin = 68, 20
board = Image.new("RGB", (body.width + margin * 2, header + body.height + margin), "#171a20")
draw = ImageDraw.Draw(board)
title = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 18)
note = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 13)
draw.text((margin, 12), "INFERRED KNEE LEG UNDERPAINT — isolated review", fill="#ffffff", font=title)
draw.text((margin, 40), "Flat, unlabeled fabric fill. Its silhouette follows the approved opaque leg/joint footprint.", fill="#d8dde6", font=note)
checker = Image.new("RGBA", body.size, (55, 63, 73, 255))
checker_draw = ImageDraw.Draw(checker)
tile = 20
for yy in range(0, body.height, tile):
    for xx in range(0, body.width, tile):
        if ((xx // tile) + (yy // tile)) % 2:
            checker_draw.rectangle((xx, yy, xx + tile - 1, yy + tile - 1), fill="#303842")
checker.alpha_composite(body)
board.paste(checker.convert("RGB"), (margin, header))
board.save(ISOLATED_REVIEW)
print(UNDERPAINT)
print(ISOLATED_REVIEW)
