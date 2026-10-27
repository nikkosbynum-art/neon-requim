"""Static image checks for quarantined BREAKER Tier I candidate 09.

Checks image structure only. It does not decide canon or verify anatomy.
"""
from hashlib import sha256
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
IMAGE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
MANIFEST = IMAGE.with_suffix(".json")
im = Image.open(IMAGE)
assert im.format == "PNG" and im.mode == "RGBA", (im.format, im.mode)
assert im.size == (1024, 1536), im.size
alpha = im.getchannel("A")
assert all(alpha.getpixel(p) == 0 for p in ((0, 0), (1023, 0), (0, 1535), (1023, 1535)))
solid = alpha.point(lambda v: 255 if v >= 245 else 0)
bounds = solid.getbbox()
assert bounds is not None
left, top, right, bottom = bounds
height = bottom - top
assert left >= 20 and top >= 20 and right <= 1004 and bottom <= 1516, bounds
assert 1400 <= height <= 1500, height
boots_l = solid.crop((120, 1200, 460, 1536)).getbbox()
boots_r = solid.crop((600, 1200, 980, 1536)).getbbox()
assert boots_l and boots_r, (boots_l, boots_r)
left_bottom = 1200 + boots_l[3] - 1
right_bottom = 1200 + boots_r[3] - 1
ground_delta = abs(left_bottom - right_bottom) * 256 / height
assert ground_delta <= 6.0, ground_delta
flat = alpha.get_flattened_data()
transparent = sum(v == 0 for v in flat)
semi = sum(0 < v < 255 for v in flat)
digest = sha256(IMAGE.read_bytes()).hexdigest()
metadata = MANIFEST.read_text(encoding="utf-8")
MANIFEST.write_text(metadata.replace("pending audit", digest), encoding="utf-8")
print(f"PASS: RGBA/corners/solid bounds={bounds}, visible_height={height}px, projected boot delta={ground_delta:.2f}px/256px.")
print(f"INFO: transparent={transparent}; semi-transparent={semi}; SHA256={digest}")
print("LIMIT: static pixels only; hidden anatomy, pivots, rig, motion, all-frame seams, and canon remain NOT VERIFIED.")
