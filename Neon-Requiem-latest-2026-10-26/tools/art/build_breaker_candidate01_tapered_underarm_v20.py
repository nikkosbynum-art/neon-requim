from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy")
DONOR = ROOT / "candidate01_upper_arm_source_edit_v13_shell_off.png"
BASE_MASK = ROOT / "candidate01_upper_arm_vector_base_v2.png"
SKIN = ROOT / "candidate01_biological_upper_arm_visible_v4.png"
SHELL = ROOT / "candidate01_external_shoulder_shell_v4.png"
TORSO = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/torso.png")
FOREARM = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/cyber_forearm.png")
OUTPUT = ROOT / "candidate01_tapered_underarm_v20.png"
ELBOW_PIVOT = (345.0, 495.0)


def opaque_alpha(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA").getchannel("A").point(lambda value: 255 if value >= 250 else 0)


def nearest_path(arm: Image.Image, torso: Image.Image, roi: tuple[int, int, int, int]) -> list[tuple[int, int]]:
    x0, y0, x1, y1 = roi
    width, height = x1 - x0, y1 - y0
    arm_pixels = bytes(1 if value >= 250 else 0 for value in arm.crop(roi).getdata())
    torso_pixels = bytes(1 if value >= 250 else 0 for value in torso.crop(roi).getdata())
    distances = [-1] * (width * height)
    parents = [-1] * (width * height)
    queue: deque[int] = deque()
    for index, covered in enumerate(torso_pixels):
        if covered:
            distances[index] = 0
            queue.append(index)
    found = -1
    while queue:
        index = queue.popleft()
        if arm_pixels[index]:
            found = index
            break
        x, y = index % width, index // width
        for ny in range(max(0, y - 1), min(height, y + 2)):
            for nx in range(max(0, x - 1), min(width, x + 2)):
                neighbor = ny * width + nx
                if distances[neighbor] < 0:
                    distances[neighbor] = distances[index] + 1
                    parents[neighbor] = index
                    queue.append(neighbor)
    if found < 0:
        raise RuntimeError("Could not find the arm-to-torso contour distance.")
    path = []
    while found >= 0:
        path.append((found % width + x0, found // width + y0))
        found = parents[found]
    return path


def tapered_upper_arm_transform(image: Image.Image) -> Image.Image:
    # Shear the shoulder root toward the torso with a displacement that tapers
    # to exactly zero at the elbow. Preserve the elbow and forearm contact edge.
    elbow_y = ELBOW_PIVOT[1]
    warped = image.transform(
        image.size,
        Image.Transform.AFFINE,
        (1.0, 0.1090909, -54.0, 0.0, 0.9090909, 45.0),
        resample=Image.Resampling.BICUBIC,
    )
    upper_mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(upper_mask).rectangle((0, 0, image.width, elbow_y - 1), fill=255)
    return Image.composite(warped, image, upper_mask)


def main() -> None:
    source = Image.open(DONOR).convert("RGBA")
    donor_mask = Image.new("L", source.size, 0)
    ImageDraw.Draw(donor_mask).polygon(
        [
            (334, 267), (369, 259), (405, 264), (434, 284), (452, 317),
            (443, 354), (428, 391), (418, 432), (402, 470), (380, 499),
            (348, 520), (319, 508), (298, 481), (286, 448), (282, 398),
            (288, 352), (304, 309), (318, 282),
        ],
        fill=255,
    )
    source.putalpha(donor_mask)
    donor_box = donor_mask.getbbox()
    if donor_box is None:
        raise RuntimeError("Donor silhouette is empty.")
    cutout = source.crop(donor_box)

    base = Image.open(BASE_MASK).convert("RGBA")
    base_box = base.getchannel("A").getbbox()
    if base_box is None:
        raise RuntimeError("Source-aligned arm envelope is empty.")
    target_left, target_top, _, target_bottom = base_box
    target_size = (132, target_bottom - target_top)
    fitted = cutout.resize(target_size, Image.Resampling.LANCZOS)
    shape = Image.new("L", target_size, 0)
    ImageDraw.Draw(shape).polygon(
        [(0, 0), (102, 0), (104, 42), (110, 82), (122, 118), (132, 150), (128, 184), (116, target_size[1] - 1), (0, target_size[1] - 1)],
        fill=255,
    )
    fitted.putalpha(ImageChops.darker(fitted.getchannel("A"), shape))
    canvas = Image.new("RGBA", source.size, (0, 0, 0, 0))
    canvas.alpha_composite(fitted, (target_left, target_top))

    # Move the shoulder root toward the torso while preserving the original
    # source geometry at the elbow seam, avoiding detached connector patches.
    canvas = tapered_upper_arm_transform(canvas)

    coverage = Image.new("L", source.size, 0)
    for path in (SHELL, SKIN, TORSO, FOREARM):
        coverage = ImageChops.lighter(coverage, opaque_alpha(path))
    alpha = canvas.getchannel("A")
    alpha_px, coverage_px = alpha.load(), coverage.load()
    for y in range(source.height):
        for x in range(source.width):
            if coverage_px[x, y] == 0:
                alpha_px[x, y] = 0
    canvas.putalpha(alpha)

    torso = opaque_alpha(TORSO)
    path = nearest_path(canvas.getchannel("A"), torso, (250, 220, 500, 550))
    if len(path) - 1 > 8:
        raise RuntimeError(f"Elbow-anchored fit still leaves a {len(path) - 1}px shoulder-root gap.")
    canvas.save(OUTPUT)
    print(f"Donor bounds {donor_box}; fitted size {target_size}; elbow pivot {ELBOW_PIVOT}.")
    print(f"PASS: shoulder-root gap is {len(path) - 1}px; shell-on donor exposure is clipped to source layers.")
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
