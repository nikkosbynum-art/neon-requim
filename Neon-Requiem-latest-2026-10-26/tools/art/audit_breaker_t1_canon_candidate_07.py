"""Structural checks for the quarantined BREAKER Tier I canon review image.

Visual canon items are recorded in the candidate sidecar and still require human review.
This script cannot infer or certify artistic meaning or hidden anatomy.
"""
from pathlib import Path
from PIL import Image
import json

ROOT = Path(__file__).resolve().parents[2]
IMAGE_PATH = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.png"
META_PATH = IMAGE_PATH.with_suffix(".json")
image = Image.open(IMAGE_PATH)
assert image.format == "PNG"
assert image.mode == "RGBA"
assert image.size == (1024, 1536), f"unexpected canvas: {image.size}"
alpha = image.getchannel("A")
assert alpha.getextrema()[0] == 0, "image must contain transparent pixels"
assert all(alpha.getpixel(point) == 0 for point in [(0, 0), (1023, 0), (0, 1535), (1023, 1535)]), "all canvas corners must be transparent"
solid = alpha.point(lambda value: 255 if value >= 245 else 0)
bounds = solid.getbbox()
assert bounds is not None, "character silhouette is empty"
left, top, right, bottom = bounds
visible_height = bottom - top
assert left >= 20 and top >= 20 and right <= 1004 and bottom <= 1516, f"silhouette clipped or too close to canvas edge: {bounds}"
assert 1400 <= visible_height <= 1500, f"unexpected visible height: {visible_height}"

# The two boot regions are spatially distinct in this right-facing review pose.
rear_boot = solid.crop((120, 1200, 460, 1536)).getbbox()
front_boot = solid.crop((600, 1200, 980, 1536)).getbbox()
assert rear_boot is not None and front_boot is not None, "both lower-leg/boot regions must be present"
rear_bottom = 1200 + rear_boot[3] - 1
front_bottom = 1200 + front_boot[3] - 1
foot_delta_source_px = abs(rear_bottom - front_bottom)
display_scale = 256.0 / visible_height
foot_delta_display_px = foot_delta_source_px * display_scale
assert foot_delta_display_px <= 6.0, f"boot-floor mismatch {foot_delta_display_px:.2f}px at 256px visible height"

meta = json.loads(META_PATH.read_text(encoding="utf-8"))
assert meta["status"].startswith("QUARANTINED")
assert meta["anatomy_status"] == "VISIBLE STATIC ANATOMY REVIEW ONLY; HIDDEN / DEFORMED ANATOMY NOT VERIFIED"
assert meta["runtime_status"].startswith("Not used by runtime")
print(f"PASS: transparent RGBA canvas, uncut figure bounds={bounds}, visible height={visible_height}px.")
print(f"PASS: both boots present; baseline delta={foot_delta_source_px}px source / {foot_delta_display_px:.2f}px at 256px review height.")
print("LIMIT: structural test only; canonical appearance is manually reviewed, and hidden anatomy/animation remain unverified.")
