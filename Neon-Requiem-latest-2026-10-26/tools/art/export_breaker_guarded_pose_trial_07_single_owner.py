"""Export an isolated 13-part BREAKER guard-pose rig draft from candidate 05 single-owner.

Polygons, pivots, and hidden joint fill are estimates. The source image and prior
trials are preserved. This creates a feasibility experiment, not production art.
"""

from __future__ import annotations

import json
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_05.png"
OUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v7"
SCALE = 4
OVERLAP = 0
UNDERPAINT_RADIUS = 64
SAMPLE_OFFSET = 22

# Back-to-front, anatomical L/R. Character faces right; anatomical left is the
# guarded human arm and forward screen-right leg with the knee brace.
POLYGONS = {
    "right_thigh": [(390, 630), (525, 640), (548, 704), (540, 782), (535, 850), (523, 900), (512, 944), (478, 980), (455, 1022), (432, 1045), (398, 1060), (354, 1058), (315, 1036), (300, 1000), (322, 920), (338, 850), (352, 780), (367, 700)],
    "right_shin": [(294, 978), (418, 1004), (438, 1050), (420, 1110), (391, 1172), (365, 1246), (337, 1297), (285, 1302), (230, 1285), (200, 1260), (205, 1210), (236, 1135), (251, 1080), (271, 1030)],
    "right_boot": [(196, 1180), (316, 1188), (368, 1230), (403, 1305), (443, 1380), (442, 1431), (425, 1460), (407, 1498), (381, 1510), (325, 1510), (256, 1492), (196, 1466), (132, 1455), (126, 1412), (145, 1340), (171, 1270)],
    "left_thigh": [(510, 624), (635, 635), (719, 691), (798, 780), (835, 872), (826, 928), (787, 972), (751, 999), (720, 1006), (690, 985), (670, 955), (643, 925), (620, 900), (590, 866), (560, 850), (545, 741), (511, 681)],
    "left_shin": [(697, 917), (791, 925), (838, 968), (840, 1010), (818, 1080), (792, 1140), (766, 1197), (739, 1252), (698, 1280), (657, 1275), (626, 1245), (615, 1210), (619, 1174), (642, 1110), (655, 1051), (666, 1020), (685, 980)],
    "left_boot": [(626, 1174), (753, 1188), (800, 1232), (840, 1287), (879, 1338), (910, 1360), (922, 1396), (946, 1438), (942, 1454), (860, 1458), (760, 1455), (680, 1453), (625, 1449), (605, 1388), (617, 1305)],
    "pelvis": [(354, 590), (632, 594), (661, 630), (676, 685), (663, 742), (630, 801), (584, 851), (520, 871), (458, 854), (394, 829), (352, 788), (344, 723), (350, 652)],
    "torso": [(389, 215), (450, 195), (520, 214), (576, 218), (628, 258), (669, 315), (685, 382), (674, 463), (651, 537), (649, 615), (668, 688), (645, 736), (590, 727), (530, 700), (464, 672), (405, 644), (368, 596), (366, 515), (370, 422), (372, 329)],
    "head_neck": [(448, 221), (447, 165), (461, 113), (478, 71), (517, 35), (575, 22), (631, 36), (681, 71), (711, 111), (714, 153), (690, 192), (671, 222), (660, 269), (676, 311), (658, 341), (601, 326), (540, 304), (486, 276)],
    "cyber_upper_arm": [(281, 254), (326, 224), (379, 235), (425, 274), (447, 328), (442, 387), (418, 442), (386, 489), (343, 498), (294, 469), (260, 420), (246, 357)],
    "cyber_forearm": [(238, 390), (300, 390), (357, 410), (405, 440), (451, 466), (496, 457), (545, 420), (596, 415), (634, 443), (651, 490), (636, 532), (606, 569), (570, 599), (524, 613), (477, 598), (436, 574), (385, 578), (332, 601), (284, 585), (248, 549), (227, 497)],
    "natural_upper_arm": [(609, 278), (653, 286), (695, 320), (731, 366), (760, 410), (790, 447), (804, 485), (796, 518), (776, 540), (748, 533), (723, 506), (687, 480), (658, 442), (634, 399), (611, 356)],
    "natural_forearm": [(666, 204), (700, 190), (744, 202), (780, 226), (812, 260), (831, 296), (832, 340), (826, 382), (835, 423), (844, 462), (834, 505), (815, 540), (788, 556), (758, 548), (730, 526), (716, 482), (724, 456), (742, 431), (747, 401), (728, 375)],
}

ORDER = list(POLYGONS)
PIVOTS = {
    "ground_anchor": [523, 1492],
    "pelvis": [520, 720],
    "torso": [520, 640],
    "head_neck": [565, 300],
    "cyber_shoulder": [354, 333],
    "cyber_elbow": [383, 476],
    "natural_shoulder": [640, 326],
    "natural_elbow": [765, 467],
    "left_hip": [605, 740],
    "left_knee": [758, 960],
    "left_ankle": [700, 1222],
    "right_hip": [435, 740],
    "right_knee": [365, 1020],
    "right_ankle": [270, 1245],
}

# Inferred sample axes used only to extend hidden joint pixels.
EXTENSIONS = {
    "right_thigh": [((435, 740), (0.0, -1.0)), ((365, 1020), (0.25, -0.97))],
    "right_shin": [((365, 1020), (-0.1, 1.0)), ((270, 1245), (0.0, -1.0))],
    "right_boot": [((270, 1245), (-0.4, 0.9))],
    "left_thigh": [((605, 740), (0.5, 0.86)), ((758, 960), (-0.65, -0.76))],
    "left_shin": [((758, 960), (-0.15, 0.98)), ((700, 1222), (0.2, -0.98))],
    "left_boot": [((700, 1222), (0.3, 0.95))],
    "pelvis": [((520, 820), (0, -1)), ((435, 740), (1, 0)), ((605, 740), (-1, 0))],
    "torso": [((520, 640), (0, 1)), ((565, 300), (0, 1)), ((354, 333), (1, 0)), ((640, 326), (-1, 0))],
    "head_neck": [((565, 300), (0, -1))],
    "cyber_upper_arm": [((354, 333), (-0.1, 1)), ((383, 476), (0, -1))],
    "cyber_forearm": [((383, 476), (0.8, 0.6))],
    "natural_upper_arm": [((640, 326), (0.7, 0.7)), ((765, 467), (-0.7, -0.7))],
    "natural_forearm": [((765, 467), (-0.2, -1))],
}


def polygon_mask(size: tuple[int, int], points: list[tuple[int, int]]) -> Image.Image:
    mask = Image.new("L", (size[0] * SCALE, size[1] * SCALE), 0)
    ImageDraw.Draw(mask).polygon([(x * SCALE, y * SCALE) for x, y in points], fill=255)
    return mask.resize(size, Image.Resampling.LANCZOS)


def grow(mask: Image.Image, radius: int) -> Image.Image:
    for _ in range(radius):
        mask = mask.filter(ImageFilter.MaxFilter(3))
    return mask


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite existing trial: {OUT}")
    image = Image.open(SOURCE).convert("RGBA")
    size = image.size
    silhouette = image.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    owner_map = Image.new("L", size, 0)
    for index, name in enumerate(ORDER, 1):
        mask = ImageChops.multiply(grow(polygon_mask(size, POLYGONS[name]), 4), silhouette)
        owner_map.paste(index, (0, 0), mask)

    visible: dict[str, Image.Image] = {}
    for index, name in enumerate(ORDER, 1):
        owner = owner_map.point(lambda value, target=index: 255 if value == target else 0)
        grown = ImageChops.multiply(grow(owner, OVERLAP), silhouette)
        part = image.copy()
        part.putalpha(grown)
        visible[name] = part

    composite = Image.new("RGBA", size, (0, 0, 0, 0))
    union = Image.new("L", size, 0)
    for name in ORDER:
        composite.alpha_composite(visible[name])
        union = ImageChops.lighter(union, visible[name].getchannel("A"))
    reference = image.copy()
    reference.putalpha(silhouette)
    difference = ImageChops.difference(composite, reference)
    uncovered = ImageChops.subtract(silhouette, union)
    uncovered_count = sum(1 for value in uncovered.getdata() if value)
    exact = difference.getbbox() is None
    if uncovered_count or not exact:
        # Keep the mask diagnostics outside the trial folder so the next polygon
        # correction can be inspected without leaving a partial export behind.
        diagnostic = ROOT / "docs/visual_qa/BREAKER_T1_guarded_trial_05_uncovered.png"
        uncovered.save(diagnostic)
        pixels = uncovered.load()
        pending = {(x, y) for y in range(size[1]) for x in range(size[0]) if pixels[x, y]}
        components = []
        while pending:
            start = pending.pop()
            stack = [start]
            xs = [start[0]]
            ys = [start[1]]
            while stack:
                x, y = stack.pop()
                for neighbor in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if neighbor in pending:
                        pending.remove(neighbor)
                        stack.append(neighbor)
                        xs.append(neighbor[0])
                        ys.append(neighbor[1])
            components.append((len(xs), min(xs), min(ys), max(xs) + 1, max(ys) + 1))
        print("Largest uncovered components (pixels, x0, y0, x1, y1):", sorted(components, reverse=True)[:20])
        raise RuntimeError(f"neutral export failed: {uncovered_count} uncovered silhouette pixels; diagnostic={diagnostic}")

    OUT.mkdir(parents=True)
    for name, part in visible.items():
        part.save(OUT / f"{name}.png", optimize=True)
    composite.save(OUT / "assembled_neutral.png", optimize=True)
    reference.save(OUT / "reference_cutout.png", optimize=True)
    uncovered.save(OUT / "uncovered_mask.png", optimize=True)

    source_rgb = image.convert("RGB")
    source_px = source_rgb.load()
    alpha_px = silhouette.load()
    underpaint_count = 0
    changed_count = 0
    for name in ORDER:
        mask_img = Image.new("L", size, 0)
        draw = ImageDraw.Draw(mask_img)
        for (cx, cy), _direction in EXTENSIONS[name]:
            draw.ellipse((cx - UNDERPAINT_RADIUS, cy - UNDERPAINT_RADIUS, cx + UNDERPAINT_RADIUS, cy + UNDERPAINT_RADIUS), fill=255)
        mask_px = mask_img.load()
        under = Image.new("RGBA", size, (0, 0, 0, 0))
        under_px = under.load()
        y_values = [center[1] for center, _ in EXTENSIONS[name]]
        for y in range(max(0, min(y_values) - UNDERPAINT_RADIUS), min(size[1], max(y_values) + UNDERPAINT_RADIUS + 1)):
            for x in range(size[0]):
                if not mask_px[x, y] or not alpha_px[x, y]:
                    continue
                center, direction = min(EXTENSIONS[name], key=lambda item: (x - item[0][0]) ** 2 + (y - item[0][1]) ** 2)
                sx = max(0, min(size[0] - 1, round(x + direction[0] * SAMPLE_OFFSET)))
                sy = max(0, min(size[1] - 1, round(y + direction[1] * SAMPLE_OFFSET)))
                under_px[x, y] = (*source_px[sx, sy], 255)
                underpaint_count += 1
                changed_count += int(source_px[x, y] != source_px[sx, sy])
        under.save(OUT / f"underpaint_{name}.png", optimize=True)

    manifest = {
        "status": "INFERRED GUARD-POSE RIG FEASIBILITY DRAFT — NOT APPROVED / NOT PRODUCTION ART",
        "source": SOURCE.relative_to(ROOT).as_posix(),
        "source_canvas_px": list(size),
        "source_visible_height_px": 1466,
        "layers_back_to_front": ORDER,
        "pivots_px": PIVOTS,
        "pivot_status": "estimated from visible candidate 05 single-owner pose; not artist-authored",
        "polygon_masks_px": POLYGONS,
        "joint_overlap_px": OVERLAP,
        "inferred_underpaint": {"method": "local color-axis extrapolation", "radius_px": UNDERPAINT_RADIUS, "sample_offset_px": SAMPLE_OFFSET, "pixel_count": underpaint_count, "changed_rgb_count": changed_count},
        "hidden_anatomy_verified": False,
        "limitations": [
            "Single flattened generated pose is not a layered art source.",
            "Hands remain attached to forearms and feet remain attached to boots.",
            "Pivots, segmentation, layer order, and underpaint are manual estimates.",
            "Neutral pixel reconstruction and clip seam tests do not certify semantic anatomy or final canon.",
        ],
        "validation": {"uncovered_silhouette_pixels": uncovered_count, "neutral_composite_exact": exact, "godot_tested": False},
    }
    (OUT / "pivot_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"PASS neutral exact reconstruction; pelvis pivot refit; parts={len(ORDER)} canvas={size}; uncovered={uncovered_count}; inferred underpaint={underpaint_count} pixels ({changed_count} changed colors)")
    print(f"Output: {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

