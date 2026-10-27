"""Structural audit for candidate 12; deliberately not a semantic anatomy gate."""
from __future__ import annotations

from pathlib import Path
import hashlib
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
IMAGE_PATH = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_12.png"
EXPECTED_SPANS = [(150, 358), (485, 822), (928, 1255), (1360, 1730)]


def main() -> int:
    image = Image.open(IMAGE_PATH).convert("RGBA")
    if image.size != (1774, 887):
        raise SystemExit(f"FAIL: unexpected canvas size {image.size}")
    alpha = image.getchannel("A")
    corners = [alpha.getpixel(point) for point in ((0, 0), (1773, 0), (0, 886), (1773, 886))]
    if any(corners):
        raise SystemExit(f"FAIL: nontransparent canvas corners {corners}")

    pixels = alpha.load()
    active = []
    for x in range(image.width):
        if any(pixels[x, y] >= 245 for y in range(image.height)):
            active.append(x)
    spans: list[tuple[int, int]] = []
    if active:
        start = previous = active[0]
        for x in active[1:]:
            if x > previous + 1:
                spans.append((start, previous))
                start = x
            previous = x
        spans.append((start, previous))
    if spans != EXPECTED_SPANS:
        raise SystemExit(f"FAIL: expected four high-alpha panels {EXPECTED_SPANS}, found {spans}")

    gutters = [(spans[i][1] + 1, spans[i + 1][0] - 1) for i in range(3)]
    for low, high in gutters:
        if any(pixels[x, y] >= 245 for x in range(low, high + 1) for y in range(image.height)):
            raise SystemExit(f"FAIL: opaque pixels join neighboring panels in gutter {low}..{high}")

    raw = alpha.tobytes()
    counts = [sum(1 for value in raw if lo <= value <= hi) for lo, hi in ((0, 0), (1, 127), (128, 244), (245, 255))]
    digest = hashlib.sha256(IMAGE_PATH.read_bytes()).hexdigest()
    print(f"PASS: RGBA {image.width}x{image.height}; transparent corners; four separated high-alpha panel spans {spans}.")
    print(f"Alpha counts transparent/fringe/soft/cutout={counts}; SHA256={digest}.")
    print("LIMIT: validates board structure only; visible anatomy requires human review and hidden anatomy/rig readiness remain NOT VERIFIED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
