"""Split candidate01 upper-arm artwork into clean shell-off skin and shell layers.

This quarantined review builder starts from the existing classified-skin mask,
keeps only its main connected region, and assigns every other source pixel to
the shell layer. The original source layer is never modified.
"""
from collections import deque
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
PARTS = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01"
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy"
SOURCE = PARTS / "cyber_upper_arm.png"
MASK_SOURCE = TRIAL / "candidate01_biological_upper_arm_visible_v4.png"
SKIN_OUT = TRIAL / "candidate01_biological_upper_arm_visible_v5_main_component.png"
SHELL_OUT = TRIAL / "candidate01_external_shoulder_shell_v5_complement.png"
MIN_COMPONENT_AREA = 1000


def largest_component(alpha: Image.Image) -> Image.Image:
    width, height = alpha.size
    source = alpha.load()
    visited = bytearray(width * height)
    largest: list[int] = []
    for y in range(height):
        for x in range(width):
            start = y * width + x
            if source[x, y] < 245 or visited[start]:
                continue
            visited[start] = 1
            queue = deque([start])
            component: list[int] = []
            while queue:
                index = queue.popleft()
                component.append(index)
                px, py = index % width, index // width
                for ny in range(max(0, py - 1), min(height, py + 2)):
                    for nx in range(max(0, px - 1), min(width, px + 2)):
                        neighbor = ny * width + nx
                        if not visited[neighbor] and source[nx, ny] >= 245:
                            visited[neighbor] = 1
                            queue.append(neighbor)
            if len(component) > len(largest):
                largest = component
    if len(largest) < MIN_COMPONENT_AREA:
        raise AssertionError(f"Main skin region unexpectedly small: {len(largest)} pixels")
    mask = Image.new("L", alpha.size, 0)
    output = mask.load()
    for index in largest:
        output[index % width, index // width] = 255
    return mask


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    prior_skin = Image.open(MASK_SOURCE).convert("RGBA")
    if source.size != (1024, 1536) or prior_skin.size != source.size:
        raise AssertionError("Expected aligned 1024×1536 source layers")
    skin_mask = largest_component(prior_skin.getchannel("A"))
    skin = source.copy()
    skin.putalpha(Image.composite(source.getchannel("A"), Image.new("L", source.size, 0), skin_mask))
    shell_mask = Image.eval(skin_mask, lambda value: 0 if value >= 245 else 255)
    shell = source.copy()
    shell.putalpha(Image.composite(source.getchannel("A"), Image.new("L", source.size, 0), shell_mask))
    reconstructed = Image.alpha_composite(shell, skin)
    if reconstructed.tobytes() != source.tobytes():
        raise AssertionError("Skin and shell layers failed exact source reconstruction")
    for path in (SKIN_OUT, SHELL_OUT):
        if path.exists():
            raise SystemExit(f"Refusing to overwrite existing review output: {path}")
    skin.save(SKIN_OUT, optimize=True)
    shell.save(SHELL_OUT, optimize=True)
    print(f"PASS: exact source reconstruction; kept {sum(skin_mask.getdata()) // 255} main skin-mask pixels.")
    print("LIMIT: pixel partition is a review cleanup only; it does not approve anatomy, style, or animation readiness.")


if __name__ == "__main__":
    main()
