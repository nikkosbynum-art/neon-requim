"""Structural QA for the isolated BREAKER Tier I guarded-pose art review."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
REFERENCE = DRAFTS / "BREAKER_T1_profile_rebuild_candidate_01.png"
CANDIDATE = DRAFTS / "BREAKER_T1_guarded_pose_review_candidate_02.png"
OUTPUT = ROOT / "docs/visual_qa/BREAKER_T1_guarded_pose_canon_review_02.png"
SCALE_OUTPUT = ROOT / "docs/visual_qa/BREAKER_T1_guarded_pose_256px_review_02.png"

ref = Image.open(REFERENCE).convert("RGBA")
candidate = Image.open(CANDIDATE).convert("RGBA")
assert candidate.size == ref.size == (1024, 1536), (ref.size, candidate.size)
alpha = candidate.getchannel("A")
assert alpha.getextrema()[0] == 0, f"candidate alpha has no fully transparent pixels: {alpha.getextrema()}"
assert all(alpha.getpixel(p) == 0 for p in ((0, 0), (1023, 0), (0, 1535), (1023, 1535))), "candidate corners must be transparent"
foreground = alpha.point(lambda value: 255 if value >= 32 else 0).getbbox()
assert foreground is not None
x0, y0, x1, y1 = foreground
height = y1 - y0
assert height >= 1250, f"unexpectedly cropped/undersized figure: {foreground}"
assert x0 > 0 and y0 > 0 and x1 < candidate.width and y1 < candidate.height, "unexpected crop against canvas edge"

# A neutral reference/candidate comparison at the specification's actual 256 px
# hair-to-foot height. Both figures share a ground line; the approved reference's
# soft backdrop is removed only for this QA display using its alpha threshold.
try:
    small = ImageFont.truetype("arial.ttf", 16)
except OSError:
    small = ImageFont.load_default()

def alpha_cutout(image: Image.Image, threshold: int) -> tuple[Image.Image, tuple[int, int, int, int]]:
    mask = image.getchannel("A").point(lambda value: 255 if value >= threshold else 0)
    bounds = mask.getbbox()
    assert bounds is not None
    crop = image.crop(bounds)
    cropped_mask = mask.crop(bounds)
    crop.putalpha(cropped_mask)
    return crop, bounds

ref_cut, ref_bounds = alpha_cutout(ref, 245)
candidate_cut, candidate_bounds = alpha_cutout(candidate, 32)
TARGET_HEIGHT = 256
ref_scale = TARGET_HEIGHT / (ref_bounds[3] - ref_bounds[1])
candidate_scale = TARGET_HEIGHT / (candidate_bounds[3] - candidate_bounds[1])
assert round((ref_bounds[3] - ref_bounds[1]) * ref_scale) == TARGET_HEIGHT
assert round((candidate_bounds[3] - candidate_bounds[1]) * candidate_scale) == TARGET_HEIGHT

def resize_to_target(image: Image.Image) -> Image.Image:
    width = round(image.width * TARGET_HEIGHT / image.height)
    return image.resize((width, TARGET_HEIGHT), Image.Resampling.LANCZOS)

ref_scaled = resize_to_target(ref_cut)
candidate_scaled = resize_to_target(candidate_cut)
scale_canvas = Image.new("RGB", (1080, 370), (25, 29, 36))
scale_draw = ImageDraw.Draw(scale_canvas)
scale_draw.text((28, 14), "APPROVED PROFILE — 256 PX VISIBLE HEIGHT", fill=(130, 210, 220), font=small)
scale_draw.text((568, 14), "GUARDED DRAFT — 256 PX VISIBLE HEIGHT", fill=(244, 180, 110), font=small)
floor_y = 330
scale_draw.line((20, floor_y, 1060, floor_y), fill=(87, 220, 227), width=2)
scale_canvas.paste(ref_scaled, (270 - ref_scaled.width // 2, floor_y - TARGET_HEIGHT), ref_scaled)
scale_canvas.paste(candidate_scaled, (810 - candidate_scaled.width // 2, floor_y - TARGET_HEIGHT), candidate_scaled)
SCALE_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
scale_canvas.save(SCALE_OUTPUT)

# Create a labeled review sheet. This is for visual comparison only; it is not runtime art.
canvas = Image.new("RGB", (1120, 860), (26, 29, 36))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 22)
    small = ImageFont.truetype("arial.ttf", 16)
except OSError:
    font = ImageFont.load_default()
    small = font
draw.text((36, 20), "BREAKER TIER I — CANON REVIEW (DRAFT ONLY)", fill=(238, 241, 246), font=font)
draw.text((36, 56), "Approved profile reference", fill=(130, 210, 220), font=small)
draw.text((580, 56), "Guarded pose exploration — not approved production art", fill=(244, 180, 110), font=small)

def fit(image: Image.Image, box: tuple[int, int, int, int], transparent_bg: bool) -> Image.Image:
    x0, y0, x1, y1 = box
    # The approved concept has a baked dark background; keep it intact. The candidate is
    # composited over the same dark field so silhouette, scale and rendering can be compared.
    if transparent_bg:
        panel = Image.new("RGBA", image.size, (19, 22, 28, 255))
        panel.alpha_composite(image)
        image = panel
    image.thumbnail((x1 - x0, y1 - y0), Image.Resampling.LANCZOS)
    result = Image.new("RGB", (x1 - x0, y1 - y0), (19, 22, 28))
    result.paste(image.convert("RGB"), ((result.width - image.width) // 2, (result.height - image.height) // 2))
    return result

canvas.paste(fit(ref, (30, 86, 540, 836), False), (30, 86))
canvas.paste(fit(candidate, (580, 86, 1090, 836), True), (580, 86))
OUTPUT.parent.mkdir(parents=True, exist_ok=True)
canvas.save(OUTPUT)
print(f"PASS: {CANDIDATE.relative_to(ROOT)} is RGBA {candidate.size}; alpha range={alpha.getextrema()}; figure bbox@A>=32={foreground}; visible height={height}px")
print(f"Visual comparison sheet: {OUTPUT.relative_to(ROOT)}")
print(f"256 px grounded comparison: {SCALE_OUTPUT.relative_to(ROOT)} (source scale {candidate_scale:.6f}; both baselines share y={floor_y})")
print("Manual canon review still required; this script does not certify identity, outfit, tier, or anatomy.")
