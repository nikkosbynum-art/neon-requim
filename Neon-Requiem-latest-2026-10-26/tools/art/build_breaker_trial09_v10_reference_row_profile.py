"""Build a quarantined continuous underarm from candidate 09's visible contour."""
from __future__ import annotations

import json
import math
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V5_DIR = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
V9_DIR = DRAFTS / "profile_rig_trial_09_canon_v9_continuous_arm_underpaint"
OUT = DRAFTS / "profile_rig_trial_09_canon_v10_reference_row_profile"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v10_reference_row_profile.png"
ROI = (230, 250, 465, 475)
CROP = (220, 220, 485, 520)
SIDE_MARGIN = 8
TOP_Y = 260
BOTTOM_Y = 468
TOP_WIDTH = 48
BOTTOM_WIDTH = 74


def components(mask: Image.Image) -> list[set[tuple[int, int]]]:
    px = mask.load()
    w, h = mask.size
    remaining = {(x, y) for y in range(h) for x in range(w) if px[x, y]}
    groups: list[set[tuple[int, int]]] = []
    while remaining:
        first = remaining.pop()
        group = {first}
        stack = [first]
        while stack:
            x, y = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    p = (x + dx, y + dy)
                    if p in remaining:
                        remaining.remove(p); group.add(p); stack.append(p)
        groups.append(group)
    return sorted(groups, key=len, reverse=True)


def composite(layers: list[str], donor: Image.Image, omit_shell: bool = False) -> Image.Image:
    out = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    out.alpha_composite(donor)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        out.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE).convert("RGBA")
    source_mask = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    visible_image = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA")
    visible_mask = visible_image.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    seed_groups = [group for group in components(visible_mask) if len(group) >= 100]
    if len(seed_groups) < 2:
        raise AssertionError("Expected both substantial visible upper-arm skin regions.")
    seed = set().union(*seed_groups)
    rows: dict[int, tuple[int, int]] = {}
    for y in range(ROI[1], ROI[3]):
        xs = [x for x, yy in seed if yy == y]
        if xs:
            rows[y] = (min(xs), max(xs))
    if len(rows) < 80:
        raise AssertionError(f"Visible row profile too sparse: {len(rows)} rows")

    first_y, last_y = min(rows), max(rows)
    known_y = sorted(rows)
    profiles: dict[int, tuple[int, int]] = {}
    for y in range(first_y, last_y + 1):
        if y in rows:
            profiles[y] = rows[y]
            continue
        before = max((k for k in known_y if k < y), default=None)
        after = min((k for k in known_y if k > y), default=None)
        if before is not None and after is not None and after - before <= 18:
            t = (y - before) / (after - before)
            left = round(rows[before][0] + t * (rows[after][0] - rows[before][0]))
            right = round(rows[before][1] + t * (rows[after][1] - rows[before][1]))
            profiles[y] = (left, right)

    top_profile = profiles[first_y]
    top_center = (top_profile[0] + top_profile[1]) / 2
    for y in range(TOP_Y, first_y):
        t = (y - TOP_Y) / (first_y - TOP_Y)
        target_width = top_profile[1] - top_profile[0] + 1
        width = round(TOP_WIDTH + (target_width - TOP_WIDTH) * math.sqrt(t))
        if y == TOP_Y:
            width = 1
        profiles[y] = (round(top_center - (width - 1) / 2), round(top_center + (width - 1) / 2))

    bottom_profile = profiles[last_y]
    bottom_center = (bottom_profile[0] + bottom_profile[1]) / 2
    for y in range(last_y + 1, BOTTOM_Y + 1):
        t = (y - last_y) / (BOTTOM_Y - last_y)
        width = round((bottom_profile[1] - bottom_profile[0] + 1) * (1 - t) + BOTTOM_WIDTH * t)
        profiles[y] = (round(bottom_center - (width - 1) / 2), round(bottom_center + (width - 1) / 2))

    shape = Image.new("L", source.size, 0)
    sp, sm = shape.load(), source_mask.load()
    for y, (left, right) in profiles.items():
        left -= SIDE_MARGIN
        right += SIDE_MARGIN
        for x in range(max(ROI[0], left), min(ROI[2], right + 1)):
            if sm[x, y]:
                sp[x, y] = 255
    for x, y in seed:
        sp[x, y] = 255
    shape_groups = components(shape)
    if not shape_groups or any(not group <= shape_groups[0] for group in seed_groups):
        raise AssertionError("Reference row-profile failed to form one continuous arm silhouette.")

    donor = Image.new("RGBA", source.size, (0, 0, 0, 0))
    dp, vp = donor.load(), visible_image.load()
    generated = Image.open(V5_DIR / "donor_no_shell.png").convert("RGBA")
    gp = generated.load()
    queue: deque[tuple[int, int]] = deque()
    seen: set[tuple[int, int]] = set()
    for point in seed:
        queue.append(point); seen.add(point)
    for x, y in shape_groups[0]:
        if visible_mask.getpixel((x, y)):
            continue
        r, g, b, a = gp[x, y]
        if a >= 245 and r >= 105 and g >= 55 and b >= 35 and r > g * 1.08 and g > b * 1.05:
            dp[x, y] = (r, g, b, 255)
            queue.append((x, y)); seen.add((x, y))
    added = 0
    x0, y0, x1, y1 = ROI
    while queue:
        x, y = queue.popleft()
        color = vp[x, y] if vp[x, y][3] >= 245 else dp[x, y]
        if color[3] < 245:
            continue
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                p = (x + dx, y + dy)
                if x0 <= p[0] < x1 and y0 <= p[1] < y1 and sp[p] and p not in seen:
                    seen.add(p); queue.append(p)
                    if not visible_mask.getpixel(p):
                        dp[p[0], p[1]] = color
                        added += 1

    hidden_mask = donor.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    uncovered = sum(1 for x, y in shape_groups[0] if not visible_mask.getpixel((x, y)) and not hidden_mask.getpixel((x, y)))
    if uncovered:
        raise AssertionError(f"Reference-derived arm has {uncovered} uncovered pixels.")

    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    assembled = composite(layers, donor)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("Reference-derived underlayer changes the approved source-visible composite.")

    union = ImageChops.lighter(visible_mask, hidden_mask)
    union_groups = components(union)
    if not union_groups or any(not group <= union_groups[0] for group in seed_groups):
        raise AssertionError("Visible and hidden skin do not form a connected arm surface.")
    v5 = Image.open(V5_DIR / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    v5_mask = v5.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    v5_px = v5_mask.load()
    v10_px = shape.load()
    y_slice = range(TOP_Y, min(first_y + 1, 390))
    width10 = max(sum(1 for x in range(ROI[0], ROI[2]) if v10_px[x, y]) for y in y_slice)
    width5 = max(sum(1 for x in range(ROI[0], ROI[2]) if v5_px[x, y]) for y in y_slice)
    if width10 >= width5:
        raise AssertionError(f"Proximal row contour is not narrower than v5: {width10}px vs {width5}px")

    donor.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    v9_path = V9_DIR / "hidden_biological_upper_arm_donor.png"
    v9 = Image.open(v9_path).convert("RGBA")
    panels = [
        ("V5 · GENERATED FULL DELTOID", composite(layers, v5, True)),
        ("V9 · CONTINUOUS GENERATED UNDERLAYER", composite(layers, v9, True)),
        ("V10 · SOURCE ROW PROFILE", composite(layers, donor, True)),
        ("APPROVED CANDIDATE 09 · SHELL ON", assembled),
    ]
    scale, margin, label_h, gap = 2.25, 16, 32, 12
    panel_w, panel_h = round((CROP[2] - CROP[0]) * scale), round((CROP[3] - CROP[1]) * scale)
    board = Image.new("RGB", (margin * 2 + panel_w * 4 + gap * 3, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for i, (label, image) in enumerate(panels):
        x = margin + i * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.paste(image.crop(CROP).resize((panel_w, panel_h), Image.Resampling.NEAREST).convert("RGB"), (x, margin + label_h))
    board.save(QA, optimize=True)

    metrics = {
        "status": "QUARANTINED SOURCE-ROW-PROFILE UNDERLAYER — NOT CANON / NOT PRODUCTION ART / NOT RUNTIME",
        "source_skin": str((BASE / "cyber_upper_arm_skin.png").relative_to(ROOT)).replace("\\", "/"),
        "roi_px": list(ROI),
        "row_profile_visible_skin_bounds": [first_y, last_y],
        "side_margin_px": SIDE_MARGIN,
        "proximal_extension_y": TOP_Y,
        "proximal_start_width_px": TOP_WIDTH,
        "distal_extension_y": BOTTOM_Y,
        "distal_end_width_px": BOTTOM_WIDTH,
        "added_hidden_pixels": added,
        "proximal_width_px": width10,
        "v5_proximal_width_px": width5,
        "largest_visible_hidden_component_px": len(union_groups[0]),
        "major_visible_skin_regions_connected": len(seed_groups),
        "source_visible_composite_exact": True,
        "canon_boundary": "user-approved 2026-10-25: external shoulder shell over biological upper arm; mechanical prosthesis begins at elbow",
        "limitations": [
            "Hidden silhouette is interpolated from visible skin rows and is not recovered source anatomy.",
            "Generated skin texture is clipped to the source-derived contour; surface detail and artwork quality require visual review.",
            "The continuous 2D layer does not prove 3D anatomy, independent shell motion, or animation deformation.",
            "This remains a feasibility draft and is not approved for runtime or production art.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v10 source-row-profile underlayer\n\n"
        "**Quarantined reconstruction; not canon, production art, or runtime content.** The hidden upper-arm contour is derived from the row-by-row bounds of the two substantial visible skin regions in candidate 09. It bridges short gaps beneath source straps, adds a tapered proximal extension under the external shell, and clips generated skin texture to this source-derived contour. The generated rounded deltoid silhouette is not used.\n\n"
        "The Python export checks preserve the exact shell-on image, connect both visible skin regions, keep the donor inside the source silhouette, and compare proximal widths with v5. A Godot test is required before claiming pose registration; manual visual fit is not yet approved.\n",
        encoding="utf-8",
    )
    print(f"PASS: source-visible composite remains pixel-identical; {added} hidden pixels reconstructed from visible skin rows.")
    print(f"PASS: {len(seed_groups)} major visible skin regions join one {len(union_groups[0])}px connected surface.")
    print(f"PASS: proximal contour is {width10}px wide versus v5 {width5}px.")
    print("LIMIT: hidden shape/texture remain inferred; requires manual review and Godot registration test.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
