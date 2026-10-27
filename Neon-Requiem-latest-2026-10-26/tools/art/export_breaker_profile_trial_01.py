"""Export quarantined BREAKER profile cutouts from the user-approved concept.

These hand-authored masks are a review experiment, not production art. The
source is preserved unchanged. The contour points are in the 1024x1536 source
canvas; each output retains that shared canvas so the parts reassemble in place.
"""

from __future__ import annotations

import json
import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png"
OUTPUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01"
SCALE = 4

# Per-part masks deliberately overlap around shoulders, waist/hips, knees,
# ankles, and arm joints. Coordinates follow the approved profile candidate.
PARTS = [
    ("right_boot", [(507, 1208), (644, 1212), (660, 1270), (706, 1322), (766, 1357), (791, 1382), (790, 1418), (766, 1434), (696, 1437), (640, 1442), (585, 1443), (548, 1438), (526, 1441), (520, 1428), (514, 1395), (514, 1365), (514, 1334)]),
    ("right_shin", [(506, 997), (638, 1001), (652, 1061), (652, 1168), (642, 1235), (621, 1275), (574, 1285), (536, 1260), (514, 1213), (502, 1144), (498, 1077)]),
    ("left_boot", [(281, 1209), (386, 1215), (417, 1270), (444, 1325), (482, 1371), (503, 1406), (515, 1440), (512, 1464), (489, 1472), (415, 1470), (344, 1459), (287, 1443), (275, 1420), (282, 1382), (293, 1334)]),
    ("left_shin", [(304, 1000), (496, 992), (491, 1040), (480, 1090), (462, 1150), (446, 1205), (430, 1250), (389, 1248), (360, 1275), (324, 1260), (302, 1225), (298, 1168), (304, 1091)]),
    ("right_thigh", [(495, 824), (660, 820), (666, 872), (660, 929), (660, 992), (631, 1034), (590, 1055), (548, 1040), (516, 1016), (500, 973), (494, 914)]),
    ("left_thigh", [(365, 831), (499, 832), (515, 878), (505, 931), (482, 986), (443, 1034), (401, 1054), (359, 1037), (334, 1006), (341, 955), (357, 900)]),
    ("pelvis", [(392, 588), (627, 582), (651, 625), (646, 710), (653, 803), (645, 874), (616, 925), (570, 944), (520, 932), (466, 914), (408, 890), (377, 860), (373, 810), (389, 744)]),
    ("torso", [(411, 201), (476, 199), (520, 213), (575, 218), (624, 240), (651, 278), (664, 338), (660, 411), (649, 486), (641, 555), (647, 619), (640, 696), (628, 764), (640, 832), (615, 882), (565, 900), (508, 877), (451, 865), (405, 842), (397, 775), (402, 690), (397, 603), (404, 518), (393, 437), (391, 350), (397, 275)]),
    ("cyber_upper_arm", [(292, 259), (344, 244), (396, 252), (431, 279), (451, 326), (451, 379), (434, 428), (415, 470), (382, 490), (337, 476), (297, 445), (276, 407), (274, 349)]),
    ("cyber_forearm", [(239, 405), (316, 409), (359, 435), (396, 470), (419, 516), (426, 566), (447, 619), (472, 680), (473, 723), (451, 766), (423, 800), (389, 819), (350, 830), (337, 824), (316, 770), (286, 737), (267, 690), (239, 642), (238, 590), (248, 540), (248, 488)]),
    ("natural_upper_arm", [(586, 281), (629, 277), (666, 298), (691, 337), (710, 398), (725, 467), (729, 516), (716, 555), (692, 590), (662, 614), (633, 594), (610, 552), (591, 502), (579, 443), (576, 374)]),
    ("natural_forearm", [(643, 526), (683, 539), (706, 570), (710, 613), (704, 653), (719, 686), (740, 717), (751, 751), (748, 784), (738, 833), (711, 846), (689, 850), (661, 846), (661, 816), (674, 793), (670, 759), (658, 726), (644, 689), (637, 647), (637, 596)]),
    ("head_neck", [(453, 183), (432, 156), (425, 117), (443, 80), (482, 52), (535, 36), (588, 34), (632, 51), (667, 82), (682, 116), (672, 149), (651, 177), (633, 202), (617, 230), (619, 264), (638, 294), (624, 325), (565, 319), (505, 301), (462, 266), (442, 229)]),
]

# Drawing order moves from back to front. The masks use source positions, not
# cropped-and-rescaled replacements.
LAYER_ORDER = [
    "right_thigh", "right_shin", "right_boot",
    "left_thigh", "left_shin", "left_boot",
    "pelvis", "torso", "head_neck",
    "cyber_upper_arm", "cyber_forearm", "natural_upper_arm", "natural_forearm",
]

# Provisional source-pixel pivots for the isolated Godot deformation test.
# These are estimates for this profile drawing, not approved reusable rig data.
PIVOTS = {
    "ground_anchor": [535, 1472],
    "pelvis": [520, 850],
    "torso": [520, 620],
    "head_neck": [535, 230],
    "cyber_shoulder": [350, 340],
    "cyber_elbow": [345, 495],
    "natural_shoulder": [615, 330],
    "natural_elbow": [650, 580],
    "left_hip": [420, 860],
    "left_knee": [375, 1035],
    "left_ankle": [355, 1240],
    "right_hip": [580, 860],
    "right_knee": [590, 1030],
    "right_ankle": [580, 1240],
}


def make_mask(size: tuple[int, int], points: list[tuple[int, int]]) -> Image.Image:
    mask = Image.new("L", (size[0] * SCALE, size[1] * SCALE), 0)
    draw = ImageDraw.Draw(mask)
    draw.polygon([(x * SCALE, y * SCALE) for x, y in points], fill=255)
    return mask.resize(size, Image.Resampling.LANCZOS)


def grow_mask(mask: Image.Image, radius_px: int = 12) -> Image.Image:
    for _ in range(radius_px):
        mask = mask.filter(ImageFilter.MaxFilter(3))
    return mask


def make_silhouette(source: Image.Image) -> Image.Image:
    # The approved candidate has a soft alpha matte: central character pixels
    # are ~250 alpha while the background glow is mostly below this threshold.
    return source.getchannel("A").point(lambda value: 255 if value >= 245 else 0)


def main(source_path: Path = SOURCE, output_dir: Path = OUTPUT, joint_overlap_radius_px: int = 4) -> None:
    source_path = source_path.resolve()
    output_dir = output_dir.resolve()
    if not source_path.is_file():
        raise FileNotFoundError(source_path)
    output_dir.mkdir(parents=True, exist_ok=True)
    source = Image.open(source_path).convert("RGBA")
    size = source.size
    source_rgb = source.convert("RGB")
    silhouette = make_silhouette(source)
    silhouette.save(output_dir / "silhouette_mask.png", optimize=True)
    # Create a single-owner segmentation map first. Later/front layers claim
    # overlapping source pixels, preventing one limb from being baked into the
    # neighboring torso or pelvis piece. A small second expansion provides the
    # shared seam margin needed when parts are reassembled in their source pose.
    owner_map = Image.new("L", size, 0)
    owner_ids = {name: index + 1 for index, name in enumerate(LAYER_ORDER)}
    for name in LAYER_ORDER:
        points = next(points for part_name, points in PARTS if part_name == name)
        mask = ImageChops.multiply(grow_mask(make_mask(size, points)), silhouette)
        owner_map.paste(owner_ids[name], (0, 0), mask.point(lambda value: 255 if value else 0))

    parts: dict[str, Image.Image] = {}
    for name in LAYER_ORDER:
        owner_mask = owner_map.point(lambda value, owner_id=owner_ids[name]: 255 if value == owner_id else 0).convert("L")
        mask = ImageChops.multiply(grow_mask(owner_mask, radius_px=joint_overlap_radius_px), silhouette)
        part = source_rgb.copy().convert("RGBA")
        part.putalpha(mask)
        part.save(output_dir / f"{name}.png", optimize=True)
        parts[name] = part

    assembly = Image.new("RGBA", size, (0, 0, 0, 0))
    for name in LAYER_ORDER:
        assembly.alpha_composite(parts[name])
    assembly.save(output_dir / "assembled_neutral.png", optimize=True)

    union = Image.new("L", size, 0)
    for name in LAYER_ORDER:
        union = ImageChops.lighter(union, parts[name].getchannel("A"))
    union.save(output_dir / "union_mask.png", optimize=True)
    uncovered = ImageChops.subtract(silhouette, union)
    uncovered.save(output_dir / "uncovered_mask.png", optimize=True)
    reference = source.copy()
    reference.putalpha(silhouette)
    reference.save(output_dir / "reference_cutout.png", optimize=True)
    difference = ImageChops.difference(assembly, reference)
    difference.save(OUTPUT / "assembly_difference.png", optimize=True)
    uncovered_pixels = sum(1 for value in uncovered.get_flattened_data() if value)
    exact_reconstruction = difference.getbbox() is None
    if uncovered_pixels != 0 or not exact_reconstruction:
        raise RuntimeError(f"neutral reconstruction failed: {uncovered_pixels} silhouette pixels uncovered")
    manifest = {
        "status": "REVIEW ONLY — MASKS NOT ANIMATION READY",
        "source": source_path.resolve().relative_to(ROOT).as_posix(),
        "source_canvas_px": list(size),
        "mask_supersampling": SCALE,
        "joint_overlap_radius_px": joint_overlap_radius_px,
        "layers_back_to_front": LAYER_ORDER,
        "pivots_px": PIVOTS,
        "pivot_status": "PROVISIONAL — source-pose estimates for isolated Godot test only",
        "parts": [
            {"name": name, "file": f"{name}.png", "polygon_points_px": points}
            for name, points in PARTS
        ],
        "notes": [
            "Masks are hand-estimated polygons clipped to the source alpha matte, with configurable visible-pixel overlap at joints.",
            "The alpha threshold removes most backdrop glow but can trim soft edge pixels; the silhouette still needs visual review.",
            "Latest neutral composite reconstructs the thresholded source exactly with zero uncovered silhouette pixels.",
            "Pivots are not authored, hidden joint anatomy is not reconstructed, and no motion/deformation is validated.",
        ],
        "validation": {
            "all_parts_same_canvas": all(part.size == size for part in parts.values()),
            "uncovered_silhouette_pixels": uncovered_pixels,
            "neutral_reconstruction_exact": exact_reconstruction,
            "godot_rig_tested": False,
        },
    }
    (output_dir / "pivot_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(f"exported={len(parts)} canvas={size[0]}x{size[1]} uncovered_pixels={uncovered_pixels} exact_reconstruction={exact_reconstruction} output={output_dir.relative_to(ROOT)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE, help="RGBA source image (default: approved candidate 01)")
    parser.add_argument("--output", type=Path, default=OUTPUT, help="Quarantined output folder (default: profile rig trial 01)")
    parser.add_argument("--joint-overlap-radius", type=int, default=4, help="Additional source-pixel overlap for extracted parts (default: 4)")
    args = parser.parse_args()
    if args.joint_overlap_radius < 0:
        parser.error("--joint-overlap-radius must be >= 0")
    main(args.source, args.output, args.joint_overlap_radius)
