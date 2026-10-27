"""Audit candidate 11 as a concept sheet; report its production-art gate honestly."""

from pathlib import Path
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
IMAGE_PATH = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_component_sheet_candidate_11.png"


def main() -> int:
    image = Image.open(IMAGE_PATH).convert("RGBA")
    width, height = image.size
    alpha = image.getchannel("A")
    alpha_values = alpha.tobytes()
    transparent = fringe = soft = opaque = 0
    for value in alpha_values:
        if value == 0:
            transparent += 1
        elif value <= 127:
            fringe += 1
        elif value <= 244:
            soft += 1
        else:
            opaque += 1

    corners = [image.getpixel(point)[3] for point in ((0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1))]
    solid_bounds = alpha.point(lambda value: 255 if value >= 245 else 0).getbbox()
    print(f"PASS: PNG decodes as {width}x{height} RGBA; transparent corners={corners}.")
    print(f"Alpha counts: zero={transparent}, fringe(1-127)={fringe}, soft(128-244)={soft}, cutout(245-255)={opaque}.")
    print(f"Solid-alpha bounds (threshold 245): {solid_bounds}.")
    print("VISIBLE CANON REVIEW ONLY: external shoulder shell over human upper arm; mechanical forearm/fist begins at elbow.")

    failures: list[str] = []
    if image.size != (1024, 1536):
        failures.append("canvas size differs from reference canvas")
    if any(value != 0 for value in corners):
        failures.append("transparent canvas corners are not clean")
    if fringe or soft:
        failures.append("semi-transparent haze/fringe remains")
    if opaque == 0:
        failures.append("no sufficiently opaque art pixels")

    if failures:
        print("PRODUCTION ART GATE: NOT PASSED - " + "; ".join(failures) + ".")
        print("This static audit cannot verify panel scale, pivots, attachment geometry, hidden anatomy, or animation.")
        return 2

    print("Static image gate passed; independent layers, pivots, anatomy and animation still need separate validation.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
