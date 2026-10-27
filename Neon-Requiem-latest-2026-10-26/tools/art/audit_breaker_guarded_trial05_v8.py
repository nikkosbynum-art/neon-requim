"""Audit the quarantined BREAKER trial-05 v8 single-owner masks."""
from pathlib import Path
import json
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
TRIAL = DRAFTS / "profile_rig_trial_05_guarded_pose_v8"
SOURCE = DRAFTS / "BREAKER_T1_guarded_pose_review_candidate_05.png"
manifest = json.loads((TRIAL / "pivot_manifest.json").read_text(encoding="utf-8"))
parts = manifest["layers_back_to_front"]
source = Image.open(SOURCE).convert("RGBA")
source_alpha = source.getchannel("A")
target = source_alpha.point(lambda a: 255 if a >= 245 else 0)
assembled = Image.new("RGBA", source.size, (0, 0, 0, 0))
union = Image.new("L", source.size, 0)
visible_layers = []

for part in parts:
    layer = Image.open(TRIAL / f"{part}.png").convert("RGBA")
    assert layer.size == source.size, f"{part}: wrong canvas {layer.size}"
    visible_layers.append((part, layer))
    assembled.alpha_composite(layer)
    union = ImageChops.lighter(union, layer.getchannel("A"))

uncovered = ImageChops.subtract(target, union)
outside = ImageChops.subtract(union, target)
assert uncovered.getbbox() is None, f"uncovered silhouette bounds={uncovered.getbbox()}"
assert outside.getbbox() is None, f"visible pixels extend beyond target silhouette: {outside.getbbox()}"
for index, (name_a, layer_a) in enumerate(visible_layers):
    alpha_a = layer_a.getchannel("A")
    for name_b, layer_b in visible_layers[index + 1:]:
        overlap = ImageChops.multiply(alpha_a, layer_b.getchannel("A"))
        assert overlap.getbbox() is None, f"visible ownership overlaps: {name_a}/{name_b}"
expected = source.copy()
expected.putalpha(target)
assert ImageChops.difference(assembled, expected).getbbox() is None, "neutral composite differs from the alpha-thresholded source"

underpaint_pixels = 0
changed_rgb = 0
for part in parts:
    under = Image.open(TRIAL / f"underpaint_{part}.png").convert("RGBA")
    assert under.size == source.size, f"underpaint {part}: wrong canvas {under.size}"
    under_data = under.getdata()
    source_data = source.getdata()
    for (r, g, b, a), (sr, sg, sb, _sa) in zip(under_data, source_data):
        if a:
            underpaint_pixels += 1
            changed_rgb += int((r, g, b) != (sr, sg, sb))

assert manifest["hidden_anatomy_verified"] is False
assert underpaint_pixels == manifest["inferred_underpaint"]["pixel_count"]
assert changed_rgb == manifest["inferred_underpaint"]["changed_rgb_count"]
print(f"PASS: {len(parts)} single-owner visible layers; uncovered=0; multiply-owned=0; exact neutral composite.")
print(f"PASS: inferred underpaint pixels={underpaint_pixels}; changed RGB={changed_rgb}; manifest agrees.")
print("LIMIT: underpaint is extrapolated color texture. This audit cannot verify hidden anatomy or animation quality.")
