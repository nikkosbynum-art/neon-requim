"""Build a connected hidden upper-arm underlayer beneath armor and straps."""
from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V6 = DRAFTS / "profile_rig_trial_09_canon_v6_reference_contour"
OUT = DRAFTS / "profile_rig_trial_09_canon_v9_continuous_arm_underpaint"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v9_continuous_arm_underpaint.png"
ROI = (230, 220, 465, 480)
CROP = (220, 220, 485, 520)
CLOSE_SIZE = 11


def components(mask: Image.Image) -> list[set[tuple[int, int]]]:
    px = mask.load()
    w, h = mask.size
    remaining = {(x, y) for y in range(h) for x in range(w) if px[x, y]}
    groups: list[set[tuple[int, int]]] = []
    while remaining:
        p = remaining.pop()
        group = {p}
        stack = [p]
        while stack:
            x, y = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    q = (x + dx, y + dy)
                    if q in remaining:
                        remaining.remove(q); group.add(q); stack.append(q)
        groups.append(group)
    return sorted(groups, key=len, reverse=True)


def composite(layers: list[str], donor: Image.Image, omit_shell: bool = False) -> Image.Image:
    result = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    result.alpha_composite(donor)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        result.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return result


def fill_holes(mask: Image.Image) -> tuple[Image.Image, int]:
    x0, y0, x1, y1 = ROI
    px = mask.load()
    outside: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()
    for x in range(x0, x1):
        for y in (y0, y1 - 1):
            if px[x, y] == 0 and (x, y) not in outside:
                outside.add((x, y)); queue.append((x, y))
    for y in range(y0, y1):
        for x in (x0, x1 - 1):
            if px[x, y] == 0 and (x, y) not in outside:
                outside.add((x, y)); queue.append((x, y))
    while queue:
        x, y = queue.popleft()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                q = (x + dx, y + dy)
                if x0 <= q[0] < x1 and y0 <= q[1] < y1 and px[q] == 0 and q not in outside:
                    outside.add(q); queue.append(q)
    holes = [(x, y) for y in range(y0, y1) for x in range(x0, x1) if px[x, y] == 0 and (x, y) not in outside]
    for p in holes:
        px[p] = 255
    return mask, len(holes)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    v6 = Image.open(V6 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    visible_image = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA")
    visible = visible_image.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    hidden_seed = v6.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    seed_mask = ImageChops.lighter(visible, hidden_seed)
    closed = seed_mask.filter(ImageFilter.MaxFilter(CLOSE_SIZE)).filter(ImageFilter.MinFilter(CLOSE_SIZE))
    roi_mask = Image.new("L", closed.size, 0)
    roi_mask.paste(closed.crop(ROI), (ROI[0], ROI[1]))
    main_group = components(roi_mask)
    if not main_group or len(main_group[0]) < 15000:
        raise AssertionError("Unable to identify the connected upper-arm silhouette")
    shape = Image.new("L", roi_mask.size, 0)
    sp = shape.load()
    for point in main_group[0]:
        sp[point] = 255
    shape, hole_count = fill_holes(shape)

    v6_px, vis_px = v6.load(), visible_image.load()
    donor = Image.new("RGBA", shape.size, (0, 0, 0, 0))
    donor_px = donor.load()
    queue: deque[tuple[int, int]] = deque()
    seen: set[tuple[int, int]] = set()
    x0, y0, x1, y1 = ROI
    for x in range(x0, x1):
        for y in range(y0, y1):
            if shape.getpixel((x, y)):
                seed = v6_px[x, y] if v6_px[x, y][3] >= 245 else vis_px[x, y]
                if seed[3] >= 245:
                    queue.append((x, y)); seen.add((x, y))
                    # The donor is only hidden under existing source layers; the
                    # visible upper-arm layer remains responsible for visible pixels.
                    if not visible.getpixel((x, y)):
                        donor_px[x, y] = seed
    added = 0
    while queue:
        x, y = queue.popleft()
        color = donor_px[x, y]
        if color[3] < 245:
            color = v6_px[x, y] if v6_px[x, y][3] >= 245 else vis_px[x, y]
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                p = (x + dx, y + dy)
                if x0 <= p[0] < x1 and y0 <= p[1] < y1 and shape.getpixel(p) and p not in seen:
                    seen.add(p); queue.append(p)
                    if not visible.getpixel(p):
                        donor_px[p[0], p[1]] = color[:3] + (255,)
                        added += 1

    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    source = Image.open(SOURCE).convert("RGBA")
    assembled = composite(layers, donor)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("v9 underpaint changed the approved source-visible composite")

    output_mask = donor.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    union = ImageChops.lighter(visible, output_mask)
    union_groups = components(union)
    visible_groups = [g for g in components(visible) if len(g) >= 100]
    if not union_groups or len(union_groups[0]) < 25000 or any(not g <= union_groups[0] for g in visible_groups):
        raise AssertionError("v9 visible and inferred skin fail the connected arm-surface test")

    donor.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    v5 = Image.open(DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint/hidden_biological_upper_arm_donor.png").convert("RGBA")
    panels = [
        ("V5 · SKIN-PIXEL DONOR", composite(layers, v5, True)),
        ("V6 · REFERENCE-GUIDED DONOR", composite(layers, v6, True)),
        ("V9 · CONTINUOUS UNDERLAYER", composite(layers, donor, True)),
        ("APPROVED SOURCE · SHELL ON", assembled),
    ]
    scale, margin, label_h, gap = 2, 16, 32, 12
    panel_w, panel_h = (CROP[2] - CROP[0]) * scale, (CROP[3] - CROP[1]) * scale
    board = Image.new("RGBA", (margin * 2 + panel_w * 4 + gap * 3, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for i, (label, image) in enumerate(panels):
        x = margin + i * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.alpha_composite(image.crop(CROP).resize((panel_w, panel_h), Image.Resampling.NEAREST), (x, margin + label_h))
    board.convert("RGB").save(QA)

    manifest = {
        "status": "QUARANTINED CONTINUOUS ARM UNDERLAYER — ART FIT NOT ACCEPTED",
        "source_masks": [str((V6 / "hidden_biological_upper_arm_donor.png").relative_to(ROOT)).replace("\\", "/"), str((BASE / "cyber_upper_arm_skin.png").relative_to(ROOT)).replace("\\", "/")],
        "roi_px": list(ROI),
        "morphological_close_size": CLOSE_SIZE,
        "enclosed_holes_filled": hole_count,
        "added_hidden_underlayer_pixels": added,
        "source_visible_composite_exact": True,
        "largest_8_connected_biological_surface_px": len(union_groups[0]),
        "major_visible_skin_regions_connected": len(visible_groups),
        "canon_boundary": "user-approved 2026-10-25: external shell over biological upper arm; prosthesis begins at elbow",
        "limitations": [
            "The underlayer is a shape/color reconstruction from existing concept pixels, not artist-authored anatomy.",
            "It deliberately continues behind the shell and arm straps; only shell-on source composition is authoritative.",
            "The shell-off view remains a diagnostic, not an approved final character appearance.",
            "The shell-off view still differs substantially from the approved reference; this is not accepted art.",
            "No pivots, independent shell deformation, production alpha, or animation seams are verified.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v9 continuous arm underlayer\n\n"
        "**Quarantined local reconstruction; art fit not accepted.** This study joins the visible v4 skin mask and v6 inferred donor, closes small gaps, fills enclosed holes, and extends the skin layer beneath the existing shoulder shell and straps. It is clipped to the arm review ROI and rendered below all unchanged source layers.\n\n"
        "The shell-on neutral composite remains pixel-identical. This tests coverage and continuity only; the underlying anatomy is inferred from a flattened concept and remains unverified.\n",
        encoding="utf-8",
    )
    print(f"PASS: source-visible neutral composite remains exact; {added} hidden pixels added behind source layers.")
    print(f"PASS: largest visible/hidden 8-connected region={len(union_groups[0])} px; {len(visible_groups)} substantial visible regions connect.")
    print("LIMIT: anatomy is reconstructed from concept pixels; no rig or motion validity is established.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
