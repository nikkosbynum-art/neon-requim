"""Verify provenance boundaries and 2D continuity for the v13 review donor."""
from __future__ import annotations

from collections import deque
import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
TRIAL = DRAFTS / "profile_rig_trial_09_canon_v13_compact_shoulder_donor"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
ROI = (240, 235, 455, 500)


def components(mask: Image.Image) -> list[int]:
    px = mask.load()
    width, height = mask.size
    seen = bytearray(width * height)
    sizes: list[int] = []
    for y in range(height):
        for x in range(width):
            index = y * width + x
            if seen[index] or not px[x, y]:
                continue
            queue = deque([(x, y)])
            seen[index] = 1
            size = 0
            while queue:
                cx, cy = queue.popleft()
                size += 1
                for ny in range(max(0, cy - 1), min(height, cy + 2)):
                    for nx in range(max(0, cx - 1), min(width, cx + 2)):
                        neighbor = ny * width + nx
                        if not seen[neighbor] and px[nx, ny]:
                            seen[neighbor] = 1
                            queue.append((nx, ny))
            sizes.append(size)
    return sorted(sizes, reverse=True)


def main() -> None:
    manifest = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))
    donor = Image.open(TRIAL / "hidden_biological_upper_arm_donor_v2.png").convert("RGBA")
    study = Image.open(TRIAL / "shell_off_anatomy_study.png").convert("RGB")
    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA")
    visible = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA")
    source = Image.open(SOURCE).convert("RGBA")
    if any(image.size != (1024, 1536) for image in (donor, study, shell, visible, source)):
        raise AssertionError("The source, donor, shell, visible skin, and generated study must share 1024x1536 canvas.")

    donor_a = donor.getchannel("A").load()
    shell_a = shell.getchannel("A").load()
    donor_count = 0
    for y in range(1536):
        for x in range(1024):
            alpha = donor_a[x, y]
            if alpha == 0:
                continue
            donor_count += 1
            if not (ROI[0] <= x < ROI[2] and ROI[1] <= y < ROI[3]):
                raise AssertionError(f"Donor escaped the approved upper-arm ROI at {(x, y)}")
            if shell_a[x, y] < 245:
                raise AssertionError(f"Donor escaped the opaque shell mask at {(x, y)}")
    if donor_count < 5000:
        raise AssertionError(f"Unexpectedly sparse generated donor ({donor_count} pixels).")

    assembled = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    assembled.alpha_composite(donor)
    for name in manifest["layers_back_to_front"]:
        assembled.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("The under-shell donor changed the thresholded shell-on reference composite.")

    visible_mask = visible.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    donor_mask = donor.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    combined = ImageChops.lighter(visible_mask, donor_mask)
    sizes = components(combined)
    if not sizes or sizes[0] < 25000:
        raise AssertionError(f"Visible and hidden skin fail the 2D continuity threshold: largest={sizes[0] if sizes else 0}")
    visible_components = components(visible_mask)
    if sum(size >= 100 for size in visible_components) < 2:
        raise AssertionError("Expected separate major visible skin regions were not found.")

    print(f"PASS: donor is confined to opaque shell pixels in the upper-arm ROI ({donor_count} pixels).")
    print("PASS: thresholded shell-on composite exactly matches the approved visible source.")
    print(f"PASS: visible-plus-hidden skin has {sizes[0]} pixels in its largest 8-connected component ({len(sizes)} total components).")
    print("LIMIT: 2D connectivity does not verify artistic anatomy, independent shell motion, pivots, or production deformation.")


if __name__ == "__main__":
    main()
