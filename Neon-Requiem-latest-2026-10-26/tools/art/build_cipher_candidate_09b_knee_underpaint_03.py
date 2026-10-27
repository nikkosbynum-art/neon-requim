from pathlib import Path
import json

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageFilter


ROOT = Path.cwd()
CANDIDATE = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02"
MANIFEST = CANDIDATE / "parts_manifest.json"
UNDERPAINT = CANDIDATE / "CIPHER_T1_NEAR_KNEE_LEG_UNDERPAINT_INFERRED_CANDIDATE_09B_03_QUARANTINED.png"
ISOLATED_REVIEW = ROOT / "docs/visual_qa/CIPHER_T1_CANDIDATE_09B_KNEE_UNDERPAINT_ISOLATED_03_QUARANTINED.png"
CANVAS_SIZE = (330, 960)
PAD = 60
PIVOT = (170, 655)
KNEE_REGION = (90, 600, 240, 760)
FILL_RGB = (40, 35, 36)
POSE_ANGLES = (-12, -20)
CROP = (50, 560, 285, 840)
SCALE = 2

if UNDERPAINT.exists() or ISOLATED_REVIEW.exists():
    raise SystemExit("Refusing to overwrite an existing underpaint candidate or review image.")

manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
parts = manifest["parts"]
aligned: dict[str, Image.Image] = {}
source_union = Image.new("L", CANVAS_SIZE, 0)
for part_id in ("near_thigh", "near_shin", "near_knee_guard", "near_boot"):
    info = parts[part_id]
    image = Image.open(CANDIDATE / info["file"]).convert("RGBA")
    x0, y0, _, _ = info["source_bbox_xyxy"]
    layer = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    layer.alpha_composite(image, (x0 - PAD, y0 - PAD))
    aligned[part_id] = layer
    if part_id != "near_boot":
        source_union = ImageChops.lighter(source_union, layer.getchannel("A"))


def bent_union(angle: float) -> Image.Image:
    union = Image.new("L", CANVAS_SIZE, 0)
    for part_id in ("near_thigh", "near_shin", "near_knee_guard", "near_boot"):
        layer = aligned[part_id]
        if part_id in ("near_shin", "near_knee_guard", "near_boot"):
            layer = layer.rotate(angle, resample=Image.Resampling.BICUBIC, center=PIVOT, expand=False)
        union = ImageChops.lighter(union, layer.getchannel("A"))
    return union


# Infer only the transparent wedge exposed within the original source-derived
# leg/joint silhouette at the two reviewed flex angles. The patch is therefore
# hidden by the neutral source layers and cannot extend the approved silhouette.
region = Image.new("L", CANVAS_SIZE, 0)
ImageDraw.Draw(region).rectangle(KNEE_REGION, fill=255)
gap = Image.new("L", CANVAS_SIZE, 0)
for angle in POSE_ANGLES:
    moving = bent_union(angle)
    exposed = ImageChops.subtract(source_union, moving)
    exposed = exposed.point(lambda value: 255 if value >= 240 else 0)
    gap = ImageChops.lighter(gap, exposed)
gap = ImageChops.multiply(gap, region)
# Give the flat base a one-pixel tucked-under overlap. The source parts cover
# this margin in each reviewed pose; no boundary detail is painted into it.
gap = ImageChops.multiply(gap.filter(ImageFilter.MaxFilter(3)), source_union.point(lambda value: 255 if value >= 250 else 0))

layer = Image.new("RGBA", CANVAS_SIZE, (*FILL_RGB, 0))
layer.putalpha(gap)
layer.save(UNDERPAINT)

# Isolated view of the inferred patch, shown against a transparency checker.
body = layer.crop(CROP).resize(((CROP[2] - CROP[0]) * SCALE, (CROP[3] - CROP[1]) * SCALE), Image.Resampling.NEAREST)
header, margin = 68, 20
board = Image.new("RGB", (body.width + margin * 2, header + body.height + margin), "#171a20")
draw = ImageDraw.Draw(board)
title = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 18)
note = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 13)
draw.text((margin, 12), "INFERRED KNEE LEG UNDERPAINT — isolated review 03", fill="#ffffff", font=title)
draw.text((margin, 40), "Only the flex-exposed wedge inside the source leg silhouette; flat, unlabeled fabric fill.", fill="#d8dde6", font=note)
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
