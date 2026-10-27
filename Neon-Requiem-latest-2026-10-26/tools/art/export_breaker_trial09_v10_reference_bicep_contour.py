"""Build a quarantined arm underlayer from the approved visible bicep contour."""
from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V5 = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
OUT = DRAFTS / "profile_rig_trial_09_canon_v10_reference_bicep_contour"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v10_reference_bicep_contour.png"
ROI = (230, 220, 465, 480)
CROP = (220, 220, 485, 520)
RADIUS_X = 10
RADIUS_UP = 60
RADIUS_DOWN = 14


def components(mask: Image.Image) -> list[set[tuple[int, int]]]:
    px = mask.load()
    w, h = mask.size
    remaining = {(x, y) for y in range(h) for x in range(w) if px[x, y]}
    groups: list[set[tuple[int, int]]] = []
    while remaining:
        point = remaining.pop()
        group = {point}
        stack = [point]
        while stack:
            x, y = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    neighbor = (x + dx, y + dy)
                    if neighbor in remaining:
                        remaining.remove(neighbor)
                        group.add(neighbor)
                        stack.append(neighbor)
        groups.append(group)
    return sorted(groups, key=len, reverse=True)


def composite(layers: list[str], donor: Image.Image, omit_shell: bool = False) -> Image.Image:
    output = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    output.alpha_composite(donor)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        output.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return output


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE).convert("RGBA")
    visible_image = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA")
    visible_alpha = visible_image.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    source_mask = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    v5 = Image.open(V5 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    v5_mask = v5.getchannel("A").point(lambda a: 255 if a >= 245 else 0)

    # Expand only the real exposed skin mask, with a longer proximal extension
    # under the shoulder shell and a short distal taper near the elbow.
    seeds = [(x, y) for y in range(ROI[1], ROI[3]) for x in range(ROI[0], ROI[2]) if visible_alpha.getpixel((x, y))]
    if len(seeds) < 8000:
        raise AssertionError(f"Visible reference arm mask is unexpectedly small: {len(seeds)}")
    shape = Image.new("L", source.size, 0)
    shape_px, source_mask_px = shape.load(), source_mask.load()
    for sx, sy in seeds:
        for dy in range(-RADIUS_UP, RADIUS_DOWN + 1):
            radius_y = RADIUS_UP if dy <= 0 else RADIUS_DOWN
            normalized = dy / radius_y
            dx_limit = round(RADIUS_X * (max(0.0, 1.0 - normalized * normalized) ** 0.5))
            y = sy + dy
            if not ROI[1] <= y < ROI[3]:
                continue
            for x in range(max(ROI[0], sx - dx_limit), min(ROI[2], sx + dx_limit + 1)):
                if source_mask_px[x, y]:
                    shape_px[x, y] = 255

    groups = components(shape)
    if not groups or len(groups[0]) < len(seeds):
        raise AssertionError("The reference-derived arm shape did not preserve the visible source mask.")
    major_visible = [g for g in components(visible_alpha) if len(g) >= 100]
    if any(not g <= groups[0] for g in major_visible):
        raise AssertionError("The expanded reference contour failed to join all substantial visible arm regions.")

    # Color only hidden pixels from the nearest actual visible skin pixel.
    # This preserves the reference palette and avoids importing the oversized
    # generated deltoid shape. Multi-source 8-neighbor propagation is deterministic.
    donor = Image.new("RGBA", source.size, (0, 0, 0, 0))
    donor_px, visible_px = donor.load(), visible_image.load()
    shape_px = shape.load()
    queue: deque[tuple[int, int]] = deque()
    seen: set[tuple[int, int]] = set()
    for sx, sy in seeds:
        queue.append((sx, sy)); seen.add((sx, sy))
    filled = 0
    while queue:
        x, y = queue.popleft()
        color = visible_px[x, y]
        if color[3] < 245:
            color = donor_px[x, y]
        if color[3] >= 245:
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    point = (x + dx, y + dy)
                    if ROI[0] <= point[0] < ROI[2] and ROI[1] <= point[1] < ROI[3] and shape_px[point] and point not in seen:
                        seen.add(point); queue.append(point)
                        if not visible_alpha.getpixel(point):
                            donor_px[point[0], point[1]] = color
                            filled += 1

    if filled < 1000:
        raise AssertionError(f"Reference-derived hidden surface unexpectedly small: {filled}")
    if any(donor.getpixel(p)[3] and not source_mask.getpixel(p) for p in groups[0]):
        raise AssertionError("Underlayer escaped the approved source character silhouette.")

    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    assembled = composite(layers, donor)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("Reference-derived donor altered the visible neutral composite.")

    hidden_mask = donor.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    union = ImageChops.lighter(visible_alpha, hidden_mask)
    union_groups = components(union)
    if not union_groups or any(not g <= union_groups[0] for g in major_visible):
        largest = len(union_groups[0]) if union_groups else 0
        joined = sum(g <= union_groups[0] for g in major_visible) if union_groups else 0
        raise AssertionError(f"Visible and hidden reference-derived skin failed connectivity: largest={largest}, visible={joined}/{len(major_visible)}")
    uncovered = sum(1 for x, y in groups[0] if not visible_alpha.getpixel((x, y)) and not hidden_mask.getpixel((x, y)))
    if uncovered:
        raise AssertionError(f"Reference contour has {uncovered} unpainted hidden pixels.")
    v5_count = sum(v5_mask.histogram()[245:])
    hidden_count = sum(hidden_mask.histogram()[245:])
    shape_px = shape.load()
    v5_px = v5_mask.load()
    y0, y1 = 250, 390
    v10_width = max(sum(1 for x in range(ROI[0], ROI[2]) if shape_px[x, y]) for y in range(y0, y1))
    v5_width = max(sum(1 for x in range(ROI[0], ROI[2]) if v5_px[x, y]) for y in range(y0, y1))
    if v10_width >= v5_width:
        raise AssertionError(f"Reference-derived proximal contour is not narrower: {v10_width}px vs v5 {v5_width}px")

    donor.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    v9_path = DRAFTS / "profile_rig_trial_09_canon_v9_continuous_arm_underpaint/hidden_biological_upper_arm_donor.png"
    v9 = Image.open(v9_path).convert("RGBA")
    panels = [
        ("V5 · GENERATED FULL DELTOID", composite(layers, v5, True)),
        ("V9 · CONTINUOUS GENERATED UNDERLAYER", composite(layers, v9, True)),
        ("V10 · REFERENCE-SHAPED ARM", composite(layers, donor, True)),
        ("APPROVED CANDIDATE 09 · SHELL ON", assembled),
    ]
    scale, margin, label_h, gap = 2.25, 16, 30, 12
    panel_w, panel_h = round((CROP[2] - CROP[0]) * scale), round((CROP[3] - CROP[1]) * scale)
    board = Image.new("RGB", (margin * 2 + panel_w * 4 + gap * 3, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for i, (label, image) in enumerate(panels):
        x = margin + i * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        crop = image.crop(CROP).resize((panel_w, panel_h), Image.Resampling.NEAREST)
        board.paste(crop.convert("RGB"), (x, margin + label_h))
    board.save(QA, optimize=True)

    metrics = {
        "status": "QUARANTINED REFERENCE-SHAPED ARM UNDERLAYER — NOT CANON / NOT PRODUCTION ART / NOT RUNTIME",
        "source_layers": [str((BASE / "cyber_upper_arm_skin.png").relative_to(ROOT)).replace("\\", "/"), str(SOURCE.relative_to(ROOT)).replace("\\", "/")],
        "source_visible_skin_pixels": len(seeds),
        "horizontal_radius_px": RADIUS_X,
        "proximal_radius_px": RADIUS_UP,
        "distal_radius_px": RADIUS_DOWN,
        "roi_px": list(ROI),
        "added_hidden_pixels": filled,
        "v5_hidden_pixels": v5_count,
        "reference_contour_max_width_y250_390_px": v10_width,
        "v5_hidden_max_width_y250_390_px": v5_width,
        "largest_visible_hidden_component_px": len(union_groups[0]),
        "major_visible_skin_regions_connected": len(major_visible),
        "source_visible_composite_exact": True,
        "canon_boundary": "user-approved 2026-10-25: external shoulder shell over biological upper arm; mechanical prosthesis begins at elbow",
        "limitations": [
            "Silhouette is an explicit 2D reconstruction from visible candidate 09 skin, not recovered hidden source anatomy.",
            "Color is propagated from visible source skin, so fine texture/detail quality requires visual review.",
            "The underlayer is confined to the candidate's existing opaque character silhouette and rendered beneath all source layers.",
            "No independent shell movement, authored pivot, continuous deformation, or production art approval is claimed.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v10 reference-shaped upper-arm underlayer\n\n"
        "**Quarantined anatomy reconstruction; not canon, production art, or runtime content.** The continuous arm shape is derived only from candidate 09's visible biological upper-arm mask with a narrow horizontal expansion and longer proximal reach beneath the external shoulder shell. Hidden pixels sample color from the visible source skin. No generated deltoid silhouette is reused.\n\n"
        "Python checks enforce the approved shell-on neutral composite, source silhouette bounds, and connected mask. Godot registration and manual visual fit remain separate acceptance checks. The inferred hidden shape still requires owner review.\n",
        encoding="utf-8",
    )
    print(f"PASS: exact visible source composite; {filled} hidden skin pixels added beneath source layers.")
    print(f"PASS: {len(major_visible)} substantial visible regions connect; arm mask derived from approved visible skin and stays inside source silhouette.")
    print(f"PASS: proximal contour width {v10_width}px vs generated v5 {v5_width}px; hidden area={hidden_count}px.")
    print("LIMIT: hidden anatomy and propagated texture are inferred; no art or rig approval.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
