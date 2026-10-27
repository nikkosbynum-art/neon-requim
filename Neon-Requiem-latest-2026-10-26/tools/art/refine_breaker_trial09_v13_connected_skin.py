"""Build a cleaner connected skin-mask variant of the v13 under-shell study.

The full-body generated image remains quarantined. The donor is restricted to
the source shell mask and retains only the largest connected skin component.
"""
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor"
BASE = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_manual_skin"
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
OUTPUT = TRIAL / "hidden_biological_upper_arm_donor_v2.png"
ROI = (240, 235, 455, 500)


def main() -> None:
    generated = Image.open(TRIAL / "shell_off_anatomy_study.png").convert("RGB")
    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA")
    rgb = generated.load()
    shell_a = shell.getchannel("A").load()
    width, height = generated.size
    mask = bytearray(width * height)
    x0, y0, x1, y1 = ROI
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b = rgb[x, y]
            # Broader than v1 to retain natural skin shadows/highlights.
            if r >= 65 and r > g * 1.01 and g > b * 0.90:
                mask[y * width + x] = 1

    seen = bytearray(width * height)
    largest: list[tuple[int, int]] = []
    for y in range(y0, y1):
        for x in range(x0, x1):
            index = y * width + x
            if seen[index] or not mask[index]:
                continue
            queue = deque([(x, y)])
            seen[index] = 1
            points: list[tuple[int, int]] = []
            while queue:
                cx, cy = queue.popleft()
                points.append((cx, cy))
                for ny in range(max(y0, cy - 1), min(y1, cy + 2)):
                    for nx in range(max(x0, cx - 1), min(x1, cx + 2)):
                        neighbor = ny * width + nx
                        if mask[neighbor] and not seen[neighbor]:
                            seen[neighbor] = 1
                            queue.append((nx, ny))
            if len(points) > len(largest):
                largest = points
    if len(largest) < 25000:
        raise AssertionError(f"Connected generated skin mask too small: {len(largest)} pixels.")

    donor = Image.new("RGBA", generated.size, (0, 0, 0, 0))
    dp = donor.load()
    selected = 0
    for x, y in largest:
        if shell_a[x, y] >= 245:
            dp[x, y] = (*rgb[x, y], 255)
            selected += 1
    if selected < 5000:
        raise AssertionError(f"Too few connected pixels under the original shell: {selected}")

    manifest_path = BASE / "pivot_manifest.json"
    import json
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assembled = Image.new("RGBA", generated.size, (0, 0, 0, 0))
    assembled.alpha_composite(donor)
    for name in manifest["layers_back_to_front"]:
        assembled.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    expected = Image.open(SOURCE).convert("RGBA")
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("Connected v2 donor changes the thresholded shell-on composite.")

    if OUTPUT.exists():
        existing = Image.open(OUTPUT).convert("RGBA")
        if ImageChops.difference(existing, donor).getbbox() is not None:
            raise SystemExit(f"Existing v2 donor differs; preserving it instead of overwriting: {OUTPUT}")
        print(f"PASS: existing v2 donor exactly matches deterministic extraction ({selected} pixels).")
    else:
        donor.save(OUTPUT, optimize=True)
        print(f"PASS: wrote connected v2 donor ({selected} pixels): {OUTPUT.relative_to(ROOT).as_posix()}")
    print(f"PASS: source skin component {len(largest)} px; exact thresholded shell-on composite.")
    print("LIMIT: color segmentation and connectivity do not establish anatomical accuracy.")


if __name__ == "__main__":
    main()
