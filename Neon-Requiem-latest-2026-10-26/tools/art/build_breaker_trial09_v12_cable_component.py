"""Extract a disconnected cable-like component from the quarantined v4 pelvis mask.

This is a pose-fit experiment only. It does not modify v4 or runtime art.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_manual_skin/pelvis.png"
OUTPUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v12_cable_component"
TARGET_BOUNDS = (240, 553, 279, 598)
TARGET_PIXELS = 264


def components(image: Image.Image) -> list[tuple[int, tuple[int, int, int, int], bytearray]]:
    width, height = image.size
    alpha = image.getchannel("A")
    pixels = alpha.load()
    visited = bytearray(width * height)
    found = []
    for y in range(height):
        for x in range(width):
            start = y * width + x
            if visited[start] or pixels[x, y] == 0:
                continue
            queue = deque([(x, y)])
            visited[start] = 1
            mask = bytearray(width * height)
            count = 0
            min_x = max_x = x
            min_y = max_y = y
            while queue:
                cx, cy = queue.popleft()
                index = cy * width + cx
                mask[index] = 1
                count += 1
                min_x = min(min_x, cx)
                max_x = max(max_x, cx)
                min_y = min(min_y, cy)
                max_y = max(max_y, cy)
                for ny in range(max(0, cy - 1), min(height, cy + 2)):
                    for nx in range(max(0, cx - 1), min(width, cx + 2)):
                        neighbor = ny * width + nx
                        if not visited[neighbor] and pixels[nx, ny] > 0:
                            visited[neighbor] = 1
                            queue.append((nx, ny))
            found.append((count, (min_x, min_y, max_x, max_y), mask))
    return found


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    selected = [part for part in components(source) if part[:2] == (TARGET_PIXELS, TARGET_BOUNDS)]
    if len(selected) != 1:
        raise SystemExit(f"Expected one {TARGET_PIXELS}-pixel component at {TARGET_BOUNDS}; found {len(selected)}")
    count, bounds, mask_data = selected[0]
    width, height = source.size
    mask = Image.frombytes("L", source.size, bytes(255 if value else 0 for value in mask_data))

    cable = Image.new("RGBA", source.size, (0, 0, 0, 0))
    cable.paste(source, (0, 0), mask)
    cleaned_pelvis = source.copy()
    cleaned_pelvis.paste((0, 0, 0, 0), (0, 0, width, height), mask)
    recomposed = Image.alpha_composite(cleaned_pelvis, cable)
    if list(recomposed.getdata()) != list(source.getdata()):
        raise SystemExit("Exact source partition/recomposition check failed")

    OUTPUT.mkdir(parents=False, exist_ok=False)
    (OUTPUT / ".gdignore").write_text("Quarantined review art; not runtime content.\n", encoding="utf-8")
    cleaned_pelvis.save(OUTPUT / "pelvis_without_cable_component.png")
    cable.save(OUTPUT / "cable_component.png")
    print(f"PASS: isolated {count} source pixels at {bounds}; exact RGBA recomposition passes.")
    print("LIMIT: component semantics and animation attachment are hypotheses to compare in Godot.")
    print(f"OUTPUT: {OUTPUT}")


if __name__ == "__main__":
    main()
