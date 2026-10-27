"""Fill small holes in the inferred upper-arm donor for a quarantined review."""
from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V5 = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
V6 = DRAFTS / "profile_rig_trial_09_canon_v6_reference_contour"
OUT = DRAFTS / "profile_rig_trial_09_canon_v8_clean_underpaint"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v8_clean_underpaint.png"
ROI = (230, 220, 465, 480)
CROP = (220, 220, 485, 520)


def components(mask: Image.Image) -> list[list[tuple[int, int]]]:
    px = mask.load()
    w, h = mask.size
    remaining = {(x, y) for y in range(h) for x in range(w) if px[x, y]}
    groups: list[list[tuple[int, int]]] = []
    while remaining:
        p = remaining.pop()
        group = [p]
        stack = [p]
        while stack:
            x, y = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    q = (x + dx, y + dy)
                    if q in remaining:
                        remaining.remove(q)
                        group.append(q)
                        stack.append(q)
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


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    v6 = Image.open(V6 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    seed_mask = v6.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    # Closing heals pinholes in the generated skin classification while retaining
    # the existing contour; only the largest arm component is considered.
    candidate = seed_mask.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))
    crop_mask = Image.new("L", candidate.size, 0)
    crop_mask.paste(candidate.crop(ROI), (ROI[0], ROI[1]))
    groups = components(crop_mask)
    if not groups or len(groups[0]) < 10000:
        raise AssertionError("Could not identify the main under-shell arm component")
    contour = Image.new("L", crop_mask.size, 0)
    contour_px = contour.load()
    for x, y in groups[0]:
        contour_px[x, y] = 255

    # Fill only enclosed holes in the arm contour, not the surrounding canvas.
    x0, y0, x1, y1 = ROI
    cp = contour.load()
    outside: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()
    for x in range(x0, x1):
        for y in (y0, y1 - 1):
            if cp[x, y] == 0 and (x, y) not in outside:
                outside.add((x, y)); queue.append((x, y))
    for y in range(y0, y1):
        for x in (x0, x1 - 1):
            if cp[x, y] == 0 and (x, y) not in outside:
                outside.add((x, y)); queue.append((x, y))
    while queue:
        x, y = queue.popleft()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                q = (x + dx, y + dy)
                if x0 <= q[0] < x1 and y0 <= q[1] < y1 and cp[q] == 0 and q not in outside:
                    outside.add(q); queue.append(q)
    hole_pixels = [(x, y) for y in range(y0, y1) for x in range(x0, x1) if cp[x, y] == 0 and (x, y) not in outside]
    for x, y in hole_pixels:
        cp[x, y] = 255

    # Propagate existing skin colors into only the newly filled holes using a
    # deterministic multi-source 8-neighbor flood fill.
    source_px = v6.load()
    out = Image.new("RGBA", v6.size, (0, 0, 0, 0))
    out_px = out.load()
    q: deque[tuple[int, int]] = deque()
    seen: set[tuple[int, int]] = set()
    for x in range(x0, x1):
        for y in range(y0, y1):
            if cp[x, y] and seed_mask.getpixel((x, y)):
                out_px[x, y] = source_px[x, y]
                q.append((x, y)); seen.add((x, y))
    filled = 0
    while q:
        x, y = q.popleft()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                p = (x + dx, y + dy)
                if x0 <= p[0] < x1 and y0 <= p[1] < y1 and cp[p] and p not in seen:
                    seen.add(p)
                    if not seed_mask.getpixel(p):
                        out_px[p[0], p[1]] = source_px[x, y][:3] + (255,)
                        filled += 1
                    q.append(p)

    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA").getchannel("A")
    for y in range(out.height):
        for x in range(out.width):
            if out.getpixel((x, y))[3] and shell.getpixel((x, y)) < 245:
                out.putpixel((x, y), (0, 0, 0, 0))
    out_a = out.getchannel("A")
    for y in range(out.height):
        for x in range(out.width):
            if out_a.getpixel((x, y)) and shell.getpixel((x, y)) < 245:
                raise AssertionError(f"Underpaint escaped source shell at {(x, y)}")

    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    source = Image.open(SOURCE).convert("RGBA")
    assembled = composite(layers, out)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("v8 underpaint changed source-visible neutral composite")

    visible = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA").getchannel("A")
    visible = visible.point(lambda a: 255 if a >= 245 else 0)
    hidden = out.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    union = ImageChops.lighter(visible, hidden)
    union_groups = components(union)
    visible_groups = [g for g in components(visible) if len(g) >= 100]
    if not union_groups or len(union_groups[0]) < 25000 or any(not set(g) <= set(union_groups[0]) for g in visible_groups):
        raise AssertionError("v8 visible and hidden skin do not form one connected arm surface")

    out.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    v5 = Image.open(V5 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    variants = [
        ("V5 · GENERATED UNDERPAINT", composite(layers, v5, True)),
        ("V6 · REFERENCE-GUIDED UNDERPAINT", composite(layers, v6, True)),
        ("V8 · GAP-FILLED UNDERPAINT", composite(layers, out, True)),
        ("APPROVED SOURCE · SHELL ON", assembled),
    ]
    scale, margin, label_h, gap = 2, 16, 32, 12
    panel_w, panel_h = (CROP[2] - CROP[0]) * scale, (CROP[3] - CROP[1]) * scale
    board = Image.new("RGBA", (margin * 2 + panel_w * 4 + gap * 3, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for index, (label, image) in enumerate(variants):
        x = margin + index * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.alpha_composite(image.crop(CROP).resize((panel_w, panel_h), Image.Resampling.NEAREST), (x, margin + label_h))
    board.convert("RGB").save(QA)

    manifest = {
        "status": "QUARANTINED GAP-FILL UNDERPAINT STUDY — VISUAL IMPROVEMENT NOT ESTABLISHED",
        "source_donor": str((V6 / "hidden_biological_upper_arm_donor.png").relative_to(ROOT)).replace("\\", "/"),
        "morphological_close_px": 5,
        "enclosed_holes_filled_px": len(hole_pixels),
        "newly_color_filled_px": filled,
        "source_visible_composite_exact": True,
        "largest_8_connected_biological_surface_px": len(union_groups[0]),
        "major_visible_skin_regions_connected": len(visible_groups),
        "canon_boundary": "user-approved 2026-10-25: external shell over biological upper arm; prosthesis begins at elbow",
        "limitations": [
            "This deterministic gap fill copies nearby generated skin colors; it is not artist-authored anatomy.",
            "Manual review found no meaningful shell-off silhouette improvement; edge fragments remain.",
            "The 2D mask does not verify biology, pivots, independent shell motion, or animation seams.",
            "The shell-off proportion still requires visual review and the study is not runtime content.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v8 gap-filled underpaint\n\n"
        "**Quarantined comparison study; no visual improvement established.** A 5px morphological close and enclosed-hole fill were applied to the v6 underpaint mask. Newly filled pixels copy the nearest generated skin color. The donor is clipped to the source shell mask and the shell-on visible composite remains exact. Manual review still sees a round shell-off contour and edge fragments.\n\n"
        "This is still inferred generated anatomy. Python verifies connectivity and source fidelity only; no claim is made about biological accuracy, authored pivots, independent shell motion, or production animation.\n",
        encoding="utf-8",
    )
    print(f"PASS: exact visible composite; filled {filled} new underpaint pixels across {len(hole_pixels)} enclosed mask holes.")
    print(f"PASS: largest connected visible/hidden surface {len(union_groups[0])} px; {len(visible_groups)} visible skin regions join.")
    print("LIMIT: filled texture remains generated/inferred; shell-off proportion and production rig remain unverified.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
