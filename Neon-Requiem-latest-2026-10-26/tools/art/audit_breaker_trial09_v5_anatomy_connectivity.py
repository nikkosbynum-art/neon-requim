"""Audit 2D continuity of candidate 09's biological upper arm under the shell."""
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
V4 = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V5 = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
OUTPUT = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v5_connected_anatomy_overlay.png"
CROP = (220, 220, 485, 520)


def binary(mask: Image.Image, threshold: int = 245) -> Image.Image:
    return mask.point(lambda alpha: 255 if alpha >= threshold else 0)


def connected_components(mask: Image.Image) -> list[tuple[int, list[tuple[int, int]]]]:
    pixels = mask.load()
    width, height = mask.size
    remaining = {(x, y) for y in range(height) for x in range(width) if pixels[x, y]}
    result: list[tuple[int, list[tuple[int, int]]]] = []
    while remaining:
        start = remaining.pop()
        queue = deque([start])
        members = [start]
        while queue:
            x, y = queue.popleft()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    point = (x + dx, y + dy)
                    if point in remaining:
                        remaining.remove(point)
                        queue.append(point)
                        members.append(point)
        result.append((len(members), members))
    return sorted(result, key=lambda item: item[0], reverse=True)


def main() -> None:
    skin = Image.open(V4 / "cyber_upper_arm_skin.png").convert("RGBA")
    shell = Image.open(V4 / "cyber_shoulder_shell.png").convert("RGBA")
    hidden = Image.open(V5 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    source = Image.open(SOURCE).convert("RGBA")
    if skin.size != (1024, 1536) or shell.size != skin.size or hidden.size != skin.size or source.size != skin.size:
        raise ValueError("All anatomy study layers must share the 1024x1536 source canvas.")

    visible_skin = binary(skin.getchannel("A"))
    hidden_skin = binary(hidden.getchannel("A"))
    shell_mask = binary(shell.getchannel("A"))
    biology = ImageChops.lighter(visible_skin, hidden_skin)
    components = connected_components(biology)
    if not components:
        raise AssertionError("No biological upper-arm surface pixels found.")
    largest_size, largest_points = components[0]
    largest = Image.new("L", biology.size, 0)
    largest_px = largest.load()
    for x, y in largest_points:
        largest_px[x, y] = 255

    skin_components = connected_components(visible_skin)
    large_visible = [(size, points) for size, points in skin_components if size >= 100]
    for size, points in large_visible:
        if any(not largest_px[x, y] for x, y in points):
            raise AssertionError(f"A substantial visible skin component ({size}px) is outside the continuous arm surface.")
    if largest_size < 25000 or len(large_visible) < 2:
        raise AssertionError(f"Continuous arm union below expected scope: largest={largest_size}, visible regions={len(large_visible)}")

    overlay_biology = Image.new("RGBA", source.size, (35, 235, 130, 115))
    overlay_shell = Image.new("RGBA", source.size, (235, 35, 155, 105))
    crop_source = source.crop(CROP).resize(((CROP[2]-CROP[0])*2, (CROP[3]-CROP[1])*2), Image.Resampling.NEAREST)
    crop_biology = biology.crop(CROP).resize(crop_source.size, Image.Resampling.NEAREST)
    crop_shell = shell_mask.crop(CROP).resize(crop_source.size, Image.Resampling.NEAREST)
    panels: list[tuple[str, Image.Image]] = []
    under = crop_source.copy()
    under.alpha_composite(Image.composite(overlay_biology.crop(CROP).resize(crop_source.size, Image.Resampling.NEAREST), Image.new("RGBA", crop_source.size), crop_biology))
    panels.append(("CONNECTED BIOLOGICAL SURFACE", under))
    assembled = crop_source.copy()
    assembled.alpha_composite(Image.composite(overlay_biology.crop(CROP).resize(crop_source.size, Image.Resampling.NEAREST), Image.new("RGBA", crop_source.size), crop_biology))
    assembled.alpha_composite(Image.composite(overlay_shell.crop(CROP).resize(crop_source.size, Image.Resampling.NEAREST), Image.new("RGBA", crop_source.size), crop_shell))
    panels.append(("SOURCE WITH SHELL OVERLAY", assembled))

    margin, label_h, gap = 20, 34, 20
    panel_w, panel_h = panels[0][1].size
    board = Image.new("RGBA", (margin*2 + panel_w*2 + gap, margin*2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for index, (label, panel) in enumerate(panels):
        x = margin + index * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.alpha_composite(panel, (x, margin + label_h))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(OUTPUT)
    print(f"PASS: visible and hidden biological surface union has a {largest_size}px largest 8-connected component.")
    print(f"PASS: all {len(large_visible)} visible skin components >=100px join that continuous arm surface.")
    print(f"QA: {OUTPUT.relative_to(ROOT).as_posix()}")
    print("LIMIT: mask connectivity is 2D evidence; it does not verify anatomy quality, authored pivots, or deformation.")


if __name__ == "__main__":
    main()
