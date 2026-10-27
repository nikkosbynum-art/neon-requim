from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path.cwd()
SOURCE = ROOT / "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
GUARD = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/CIPHER_T1_NEAR_KNEE_GUARD_REF_CUTOUT_CANDIDATE_09B_QUARANTINED.png"
OUT = ROOT / "docs/visual_qa/CIPHER_T1_CANDIDATE_09B_PIVOT_APPROVED_QUARANTINED.png"

# Proposed location is the center of the visible lower hinge, which the user
# approved to remain owned by the leg. Coordinates are in the full source image.
PIVOT_SOURCE = (770, 665)
SOURCE_CROP = (735, 635, 810, 690)
PROFILE_CROP_ORIGIN = (600, 10)
GUARD_SOURCE_BBOX_LOCAL = (153, 600, 220, 667)
GUARD_PADDING = 60

scale = 7
margin = 24
header_h = 90
gap = 28
source = Image.open(SOURCE).convert("RGB").crop(SOURCE_CROP)
source = source.resize((source.width * scale, source.height * scale), Image.Resampling.NEAREST)
guard = Image.open(GUARD).convert("RGBA")
guard = guard.resize((guard.width * 2, guard.height * 2), Image.Resampling.NEAREST)

left_w = source.width
right_w = guard.width
canvas = Image.new("RGB", (margin * 2 + left_w + gap + right_w, header_h + max(source.height, guard.height) + margin), "#171a20")
draw = ImageDraw.Draw(canvas)
font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 18)
small = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 14)
draw.text((margin, 16), "CIPHER T1 — approved knee pivot (review evidence)", fill="#ffffff", font=font)
draw.text((margin, 43), "User approved source pixel: (770, 665) • candidate remains quarantined", fill="#d8dde6", font=small)

left_x, top = margin, header_h
canvas.paste(source, (left_x, top))
draw = ImageDraw.Draw(canvas)
draw.text((left_x, top - 20), "Approved side-profile source", fill="#e9edf5", font=small)

# Overlay source grid at 5 px intervals, matching the earlier grid study.
for x in range(SOURCE_CROP[0], SOURCE_CROP[2] + 1, 5):
    px = left_x + (x - SOURCE_CROP[0]) * scale
    draw.line((px, top, px, top + source.height), fill="#44dce3", width=1)
for y in range(SOURCE_CROP[1], SOURCE_CROP[3] + 1, 5):
    py = top + (y - SOURCE_CROP[1]) * scale
    draw.line((left_x, py, left_x + source.width, py), fill="#44dce3", width=1)

px = left_x + (PIVOT_SOURCE[0] - SOURCE_CROP[0]) * scale
py = top + (PIVOT_SOURCE[1] - SOURCE_CROP[1]) * scale
draw.ellipse((px - 9, py - 9, px + 9, py + 9), outline="#fff36b", width=3)
draw.line((px - 15, py, px + 15, py), fill="#ff345d", width=3)
draw.line((px, py - 15, px, py + 15), fill="#ff345d", width=3)

right_x = left_x + left_w + gap
checker = Image.new("RGB", guard.size, "#252a32")
cd = ImageDraw.Draw(checker)
tile = 16
for yy in range(0, guard.height, tile):
    for xx in range(0, guard.width, tile):
        if ((xx // tile) + (yy // tile)) % 2:
            cd.rectangle((xx, yy, xx + tile - 1, yy + tile - 1), fill="#343b46")
checker.paste(guard, (0, 0), guard)
canvas.paste(checker, (right_x, top))
draw = ImageDraw.Draw(canvas)
draw.text((right_x, top - 20), "Isolated guard with same aligned pivot", fill="#e9edf5", font=small)

guard_px = PIVOT_SOURCE[0] - (PROFILE_CROP_ORIGIN[0] + GUARD_SOURCE_BBOX_LOCAL[0]) + GUARD_PADDING
guard_py = PIVOT_SOURCE[1] - (PROFILE_CROP_ORIGIN[1] + GUARD_SOURCE_BBOX_LOCAL[1]) + GUARD_PADDING
gx, gy = right_x + guard_px * 2, top + guard_py * 2
draw.ellipse((gx - 10, gy - 10, gx + 10, gy + 10), outline="#fff36b", width=3)
draw.line((gx - 17, gy, gx + 17, gy), fill="#ff345d", width=3)
draw.line((gx, gy - 17, gx, gy + 17), fill="#ff345d", width=3)

draw.text((right_x, top + guard.height + 9), "Approved pivot aligns to the leg-owned hinge.", fill="#d8dde6", font=small)
canvas.save(OUT)
print(OUT)
