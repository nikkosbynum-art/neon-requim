"""Build a deterministic, review-only narrower under-shell contour variant."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V5 = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
V6 = DRAFTS / "profile_rig_trial_09_canon_v6_reference_contour"
OUT = DRAFTS / "profile_rig_trial_09_canon_v7_narrow_contour"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v7_narrow_contour.png"
CENTER_X = 365.0
X_SCALE = 0.92
CROP = (220, 220, 485, 520)


def composite(layers: list[str], donor: Image.Image, omit_shell: bool = False) -> Image.Image:
    result = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    result.alpha_composite(donor)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        result.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return result


def connected_components(mask: Image.Image) -> list[set[tuple[int, int]]]:
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
                        remaining.remove(p)
                        group.add(p)
                        stack.append(p)
        groups.append(group)
    return sorted(groups, key=len, reverse=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    seed = Image.open(V6 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    donor = Image.new("RGBA", seed.size, (0, 0, 0, 0))
    src, dst = seed.load(), donor.load()
    for y in range(seed.height):
        for x in range(seed.width):
            pixel = src[x, y]
            if pixel[3] >= 245:
                target_x = round(CENTER_X + (x - CENTER_X) * X_SCALE)
                if 0 <= target_x < seed.width:
                    # Unioning collisions preserves opaque color and avoids gaps.
                    if pixel[3] > dst[target_x, y][3]:
                        dst[target_x, y] = pixel

    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    source = Image.open(SOURCE).convert("RGBA")
    assembled = composite(layers, donor)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("v7 underpaint changed source-visible neutral composite")

    visible = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA").getchannel("A")
    visible = visible.point(lambda a: 255 if a >= 245 else 0)
    hidden = donor.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    union = ImageChops.lighter(visible, hidden)
    groups = connected_components(union)
    visible_groups = [g for g in connected_components(visible) if len(g) >= 100]
    v6 = Image.open(V6 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    v6_visible = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA").getchannel("A")
    v6_hidden = v6.getchannel("A")
    v6_union = ImageChops.lighter(
        v6_visible.point(lambda a: 255 if a >= 245 else 0),
        v6_hidden.point(lambda a: 255 if a >= 245 else 0),
    )
    v6_largest = connected_components(v6_union)[0]
    if not groups or len(groups[0]) < len(v6_largest) * 0.90 or any(not g <= groups[0] for g in visible_groups):
        largest = len(groups[0]) if groups else 0
        joined = sum(g <= groups[0] for g in visible_groups) if groups else 0
        raise AssertionError(f"v7 narrowing broke the connected biological surface: largest={largest}, visible_regions={joined}/{len(visible_groups)}")

    count = sum(donor.getchannel("A").histogram()[245:])
    v5 = Image.open(V5 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    v5_count = sum(v5.getchannel("A").histogram()[245:])
    if not 5000 < count < v5_count:
        raise AssertionError(f"Unexpected narrowed donor area: v7={count}, v5={v5_count}")

    donor.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    v5_assembled = composite(layers, v5, omit_shell=True).crop(CROP)
    v6 = Image.open(V6 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    v6_assembled = composite(layers, v6, omit_shell=True).crop(CROP)
    v7_assembled = composite(layers, donor, omit_shell=True).crop(CROP)
    shell_on = assembled.crop(CROP)
    panels = [
        ("V5 · GENERATED, FULLER", v5_assembled),
        ("V6 · REFERENCE-GUIDED EDIT", v6_assembled),
        ("V7 · 8% NARROWER MASK", v7_assembled),
        ("APPROVED SOURCE · SHELL ON", shell_on),
    ]
    scale, margin, label_h, gap = 2, 18, 32, 14
    panel_w = (CROP[2] - CROP[0]) * scale
    panel_h = (CROP[3] - CROP[1]) * scale
    board = Image.new("RGBA", (margin * 2 + panel_w * 4 + gap * 3, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for i, (label, panel) in enumerate(panels):
        x = margin + i * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.alpha_composite(panel.resize((panel_w, panel_h), Image.Resampling.NEAREST), (x, margin + label_h))
    board.convert("RGB").save(QA)

    manifest = {
        "status": "REJECTED AFTER VISUAL REVIEW — QUARANTINED, NOT PRODUCTION ART / NOT RUNTIME",
        "source_donor": str((V6 / "hidden_biological_upper_arm_donor.png").relative_to(ROOT)).replace("\\", "/"),
        "horizontal_scale": X_SCALE,
        "horizontal_center_px": CENTER_X,
        "selected_hidden_skin_pixels": count,
        "v5_hidden_skin_pixels": v5_count,
        "largest_8_connected_biological_surface_px": len(groups[0]),
        "major_visible_skin_regions_connected": len(visible_groups),
        "source_visible_composite_exact": True,
        "canon_boundary": "user-approved 2026-10-25: external shell over biological upper arm; prosthesis begins at elbow",
        "limitations": [
            "The 8% geometric narrowing is a comparison parameter, not a canonical anatomy measurement.",
            "Manual review rejects this version: the contour change is insufficient and introduces visibly fragmented edges.",
            "Connected masks and exact compositing do not establish anatomy, pivots, or deformation quality.",
            "The source is still a flattened concept illustration and hidden surfaces remain inferred.",
            "Not tested in Godot; not a production rig or runtime asset.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v7 contour comparison\n\n"
        "**Rejected after visual review.** A deterministic 8% horizontal mask contraction around x=365 px was applied only to the v6 under-shell donor. It preserves the approved source-visible shell-on composite and passes the scoped 2D connectivity check, but does not correct the round silhouette and leaves fragmented edges. Keep only as a rejected comparison.\n\n"
        "The width value is not canon. Godot registration, anatomy, pivots, independent shell deformation, and animation seams are not verified.\n",
        encoding="utf-8",
    )
    print(f"PASS: source-visible composite remains pixel-identical; donor={count} px versus v5={v5_count} px.")
    print(f"PASS: largest 8-connected surface={len(groups[0])} px; {len(visible_groups)} visible skin regions connect.")
    print("LIMIT: 8% width reduction is a comparison parameter, not canon; no Godot test or production-art approval.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
