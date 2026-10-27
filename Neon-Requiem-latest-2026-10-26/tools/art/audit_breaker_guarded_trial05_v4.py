"""Audit static reconstruction and evidence boundaries for BREAKER trial 05 v4."""
from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
TRIAL = DRAFTS / "profile_rig_trial_05_guarded_pose_v4"
SOURCE = DRAFTS / "BREAKER_T1_guarded_pose_review_candidate_05.png"
PARTS = ["right_thigh", "right_shin", "right_boot", "left_thigh", "left_shin", "left_boot", "pelvis", "torso", "head_neck", "cyber_upper_arm", "cyber_forearm", "natural_upper_arm", "natural_forearm"]
source = Image.open(SOURCE).convert("RGBA")
silhouette = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
assembled = Image.new("RGBA", source.size, (0, 0, 0, 0))
union = Image.new("L", source.size, 0)
for part in PARTS:
    image = Image.open(TRIAL / f"{part}.png").convert("RGBA")
    assert image.size == source.size, (part, image.size)
    assembled.alpha_composite(image)
    union = ImageChops.lighter(union, image.getchannel("A"))
uncovered = ImageChops.subtract(silhouette, union)
assert uncovered.getbbox() is None, f"uncovered pixels: {uncovered.getbbox()}"
reference = source.copy(); reference.putalpha(silhouette)
difference = ImageChops.difference(assembled, reference)
assert difference.getbbox() is None, "neutral composite differs from alpha-thresholded source"
underpaint_pixels = 0
changed_rgb = 0
source_rgb = source.convert("RGB")
for part in PARTS:
    under = Image.open(TRIAL / f"underpaint_{part}.png").convert("RGBA")
    assert under.size == source.size
    for (r, g, b, a), (sr, sg, sb) in zip(under.getdata(), source_rgb.getdata()):
        if a:
            underpaint_pixels += 1
            changed_rgb += int((r, g, b) != (sr, sg, sb))
manifest = __import__("json").loads((TRIAL / "pivot_manifest.json").read_text(encoding="utf-8"))
assert manifest["hidden_anatomy_verified"] is False
assert underpaint_pixels == manifest["inferred_underpaint"]["pixel_count"]
assert changed_rgb == manifest["inferred_underpaint"]["changed_rgb_count"]
print(f"PASS: 13-layer exact neutral assembly; uncovered=0; inferred underpaint={underpaint_pixels}; changed RGB at same source coordinates={changed_rgb}.")
print("LIMIT: the underpaint is extrapolated texture, not semantic anatomy verification.")
