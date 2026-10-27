"""Review-only warm-skin segmentation experiment for candidate 16."""

from pathlib import Path
from collections import deque

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_pose_matched_arm_assembly_candidate_16.png"
OUTPUT = ROOT / "docs/visual_qa/breaker_candidate16_skin_mask_diagnostic.png"


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    base = source.convert("RGB")
    mask = Image.new("L", source.size, 0)
    pixels = source.load()
    mask_pixels = mask.load()
    binary = bytearray(source.width * source.height)
    count = 0
    for y in range(source.height):
        for x in range(source.width):
            r, g, b, a = pixels[x, y]
            is_warm_skin = a > 96 and r > 145 and g > 75 and b > 40 and r > g * 1.12 and g > b * 1.10 and r - b > 45
            if is_warm_skin:
                mask_pixels[x, y] = 255
                binary[y * source.width + x] = 1
                count += 1

    # Connected regions help distinguish the large anatomical skin areas from
    # isolated warm specular pixels on the reflective plates.
    seen = bytearray(len(binary))
    components: list[tuple[int, tuple[int, int, int, int], list[int]]] = []
    width, height = source.size
    for start, selected in enumerate(binary):
        if not selected or seen[start]:
            continue
        seen[start] = 1
        queue = deque([start])
        area = 0
        min_x, min_y, max_x, max_y = width, height, 0, 0
        members: list[int] = []
        while queue:
            index = queue.popleft()
            members.append(index)
            x, y = index % width, index // width
            area += 1
            min_x, min_y = min(min_x, x), min(min_y, y)
            max_x, max_y = max(max_x, x), max(max_y, y)
            for ny in range(max(0, y - 1), min(height, y + 2)):
                row = ny * width
                for nx in range(max(0, x - 1), min(width, x + 2)):
                    neighbor = row + nx
                    if binary[neighbor] and not seen[neighbor]:
                        seen[neighbor] = 1
                        queue.append(neighbor)
        components.append((area, (min_x, min_y, max_x + 1, max_y + 1), members))
    components.sort(key=lambda item: item[0], reverse=True)

    overlay = Image.new("RGB", source.size, (0, 255, 90))
    board = Image.blend(base, overlay, 0.5)
    board.paste(base, mask=Image.eval(mask, lambda alpha: 255 - alpha))
    draw = ImageDraw.Draw(board)
    draw.text((12, 12), f"Warm-skin threshold diagnostic | {count:,} selected pixels", fill=(255, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))
    board.save(OUTPUT)
    print(f"Selected warm-skin pixels: {count}")
    print(f"Connected components: {len(components)}")
    for area, bounds, _members in components[:8]:
        print(f"  area={area} bounds={bounds}")
    print(f"Diagnostic only: {OUTPUT.relative_to(ROOT)}")

    # Keep only the three large, continuous warm-skin regions for a second
    # diagnostic. This filters tiny reflection speckles but is not a final mask.
    major_mask = Image.new("L", source.size, 0)
    major_pixels = major_mask.load()
    kept = 0
    for _area, _bounds, members in components[:3]:
        kept += len(members)
        for index in members:
            major_pixels[index % width, index // width] = 255
    major_overlay = Image.new("RGB", source.size, (0, 255, 90))
    major_board = Image.blend(base, major_overlay, 0.5)
    major_board.paste(base, mask=Image.eval(major_mask, lambda alpha: 255 - alpha))
    major_path = OUTPUT.with_name("breaker_candidate16_skin_main_regions.png")
    major_board.save(major_path)
    print(f"Largest 3 connected regions: {kept} pixels; review: {major_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
