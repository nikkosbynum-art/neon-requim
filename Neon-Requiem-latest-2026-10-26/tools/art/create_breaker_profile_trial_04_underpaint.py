"""Create an isolated, inferred joint-underpaint experiment for BREAKER.

The visible art is preserved as source-pixel masks. New underpaint is copied
from the same anatomical region along its visible long axis and kept beneath
all visible layers. It is a test-only extrapolation, not source-authored art.
"""

from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE_PATH = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_hidden_anatomy_candidate_03.png"
SOURCE_MANIFEST = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_03/pivot_manifest.json"
OUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_04_inferred_underpaint"
RADIUS = 42
SAMPLE_DISTANCE = 26

# Each tuple is (joint center, direction from the joint into visible pixels
# belonging to this part). Directions are provisional art judgments.
EXTENSIONS: dict[str, list[tuple[tuple[int, int], tuple[float, float]]]] = {
    "pelvis": [((520, 880), (0, -1)), ((385, 900), (1, 0)), ((635, 920), (-1, 0))],
    "torso": [((520, 880), (0, -1)), ((462, 340), (1, 0)), ((615, 330), (-1, 0))],
    "head_neck": [((545, 320), (0, -1))],
    "cyber_upper_arm": [((462, 340), (-0.48, 0.88)), ((345, 495), (-0.20, 0.98))],
    "cyber_forearm": [((345, 495), (-0.06, 1.0)), ((390, 800), (0.06, 1.0))],
    "natural_upper_arm": [((615, 330), (0.14, 0.99)), ((650, 580), (0.14, 0.99))],
    "natural_forearm": [((650, 580), (0.25, 0.97)), ((720, 820), (0.2, 0.98))],
    "left_thigh": [((385, 900), (-0.07, 1.0)), ((375, 1035), (0.05, -1.0))],
    "left_shin": [((375, 1035), (-0.1, 1.0)), ((355, 1240), (0.05, -1.0))],
    "left_boot": [((355, 1240), (-0.15, 1.0))],
    "right_thigh": [((635, 920), (-0.38, 0.93)), ((590, 1030), (0.35, -0.94))],
    "right_shin": [((590, 1030), (-0.08, 1.0)), ((580, 1240), (0.08, -1.0))],
    "right_boot": [((580, 1240), (0.1, 1.0))],
}


def main() -> None:
    source = Image.open(SOURCE_PATH).convert("RGBA")
    source_rgb = source.convert("RGB")
    silhouette = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    source_pixels = source_rgb.load()
    silhouette_pixels = silhouette.load()
    manifest = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8"))
    OUT.mkdir(parents=True, exist_ok=False)

    total_underpaint_pixels = 0
    total_changed_colors = 0
    for part in manifest["layers_back_to_front"]:
        layer = Image.new("RGBA", source.size, (0, 0, 0, 0))
        layer_pixels = layer.load()
        draw_mask = Image.new("L", source.size, 0)
        draw = ImageDraw.Draw(draw_mask)
        for (cx, cy), _direction in EXTENSIONS.get(part, []):
            draw.ellipse((cx - RADIUS, cy - RADIUS, cx + RADIUS, cy + RADIUS), fill=255)
        mask = draw_mask.load()
        for y in range(max(0, min(cy for (cx, cy), _ in EXTENSIONS.get(part, [( (0, 0), (0, 0))])) - RADIUS),
                       min(source.height, max(cy for (cx, cy), _ in EXTENSIONS.get(part, [( (0, 0), (0, 0))])) + RADIUS + 1)):
            for x in range(source.width):
                if not mask[x, y] or not silhouette_pixels[x, y]:
                    continue
                direction = min(
                    EXTENSIONS[part],
                    key=lambda item: (x - item[0][0]) ** 2 + (y - item[0][1]) ** 2,
                )[1]
                sx = round(x + direction[0] * SAMPLE_DISTANCE)
                sy = round(y + direction[1] * SAMPLE_DISTANCE)
                sx = max(0, min(source.width - 1, sx))
                sy = max(0, min(source.height - 1, sy))
                layer_pixels[x, y] = (*source_pixels[sx, sy], 255)
                total_underpaint_pixels += 1
                if source_pixels[x, y] != source_pixels[sx, sy]:
                    total_changed_colors += 1
        layer.save(OUT / f"underpaint_{part}.png", optimize=True)

    # Copy trial 03's visible masks and neutral proof without overwriting it.
    source_trial = SOURCE_MANIFEST.parent
    for part in manifest["layers_back_to_front"]:
        (Image.open(source_trial / f"{part}.png").convert("RGBA")).save(OUT / f"{part}.png", optimize=True)
    (Image.open(source_trial / "assembled_neutral.png").convert("RGBA")).save(OUT / "assembled_neutral.png", optimize=True)
    (Image.open(source_trial / "uncovered_mask.png").convert("RGBA")).save(OUT / "uncovered_mask.png", optimize=True)

    manifest.update({
        "status": "INFERRED UNDERPAINT EXPERIMENT — REVIEW ONLY; NOT PRODUCTION ART",
        "underpaint_method": "Local source-color extrapolation along inferred segment axes inside joint-radius disks; 42 px radius, 26 px sample offset; separate layers render beneath visible source-pixel parts.",
        "underpaint_radius_px": RADIUS,
        "underpaint_sample_distance_px": SAMPLE_DISTANCE,
        "hidden_anatomy_verified": False,
        "inferred_underpaint_pixel_count": total_underpaint_pixels,
        "underpaint_pixels_with_rgb_different_from_same_coordinate_source": total_changed_colors,
        "notes": list(manifest.get("notes", [])) + [
            "This is a reversible local experiment built under user permission because no layered original was found.",
            "Underpaint is inferred by extending local source colors along provisional anatomy axes; it is not canon or artist-approved anatomy.",
            "Visible source masks and trial 03 remain unchanged; all trial 04 underpaint must remain below source-visible parts.",
        ],
        "validation": {
            "static_visible_layers_preserved_from_trial_03": True,
            "neutral_reference_visual_preserved_by_underlay_order": True,
            "godot_rig_tested": False,
            "hidden_anatomy_verified": False,
        },
    })
    (OUT / "pivot_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Output: {OUT.relative_to(ROOT)}")
    print(f"Underpaint pixels: {total_underpaint_pixels}")
    print(f"Underpaint pixels extrapolated from a different source color: {total_changed_colors}")
    print("Status: inferred experiment only; semantic anatomy and animation quality require visual review.")


if __name__ == "__main__":
    main()
