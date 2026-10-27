"""Check candidate 13 panel structure and a rough vertical scale relationship."""
from __future__ import annotations

from pathlib import Path
import hashlib
import json
import sys

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
IMAGE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_components_candidate_13.png"
REFERENCE_DIR = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v2"
PANEL_BOUNDS = [
    (157, 157, 324, 564),
    (487, 112, 815, 372),
    (929, 298, 1258, 810),
    (1357, 17, 1733, 830),
]
HIGH_ALPHA_SPANS = [(157, 323), (487, 814), (929, 1257), (1357, 1732)]
ASSEMBLY_CANVAS = (450, 950)
# Positions match the review harness: upper arm at origin, shell (-81,-45),
# elbow (80,256), forearm art pivot at (29,51).
ASSEMBLY_OFFSETS = [(100, 100), (19, 55), (151, 305)]


def main() -> int:
    image = Image.open(IMAGE).convert("RGBA")
    if image.size != (1774, 887):
        raise SystemExit(f"FAIL: unexpected size {image.size}")
    alpha = image.getchannel("A")
    if any(alpha.getpixel(point) != 0 for point in ((0, 0), (1773, 0), (0, 886), (1773, 886))):
        raise SystemExit("FAIL: canvas corners must be transparent")

    active_columns = [
        x for x in range(image.width)
        if any(alpha.getpixel((x, y)) >= 245 for y in range(image.height))
    ]
    spans: list[tuple[int, int]] = []
    if active_columns:
        start = previous = active_columns[0]
        for x in active_columns[1:]:
            if x != previous + 1:
                spans.append((start, previous))
                start = x
            previous = x
        spans.append((start, previous))
    if spans != HIGH_ALPHA_SPANS:
        raise SystemExit(f"FAIL: expected four high-alpha panels {HIGH_ALPHA_SPANS}; got {spans}")

    measured = []
    for bounds in PANEL_BOUNDS:
        x0, y0, x1, y1 = bounds
        crop = alpha.crop(bounds).point(lambda value: 255 if value >= 245 else 0)
        relative = crop.getbbox()
        if relative is None:
            raise SystemExit(f"FAIL: empty panel at {bounds}")
        measured.append((x0 + relative[0], y0 + relative[1], x0 + relative[2], y0 + relative[3]))
    if measured != PANEL_BOUNDS:
        raise SystemExit(f"FAIL: panel bounds differ; expected {PANEL_BOUNDS}, measured {measured}")

    # Compare visible-height ratios to the approved-direction BREAKER reference
    # used by the existing quarantined rig trial. This estimates art-scale only.
    reference_manifest = json.loads((REFERENCE_DIR / "pivot_manifest.json").read_text(encoding="utf-8"))
    reference_upper = Image.open(REFERENCE_DIR / "cyber_upper_arm.png").convert("RGBA").getchannel("A")
    reference_forearm = Image.open(REFERENCE_DIR / "cyber_forearm.png").convert("RGBA").getchannel("A")
    reference_union = ImageChops.lighter(reference_upper, reference_forearm).point(lambda value: 255 if value >= 245 else 0)
    reference_bounds = reference_union.getbbox()
    if reference_bounds is None:
        raise SystemExit("FAIL: approved-direction BREAKER reference arm layers are empty")
    reference_arm_height = reference_bounds[3] - reference_bounds[1]
    reference_arm_width = reference_bounds[2] - reference_bounds[0]
    reference_body_height = int(reference_manifest["source_visible_height_px"])
    candidate_arm_height = PANEL_BOUNDS[3][3] - PANEL_BOUNDS[3][1]
    candidate_arm_width = PANEL_BOUNDS[3][2] - PANEL_BOUNDS[3][0]
    reference_aspect = reference_arm_width / reference_arm_height
    candidate_aspect = candidate_arm_width / candidate_arm_height
    metadata = json.loads(IMAGE.with_suffix(".json").read_text(encoding="utf-8"))
    review_status = metadata.get("visual_fit_review", {}).get("status", "")
    if "REJECTED AS A FULL-BODY ARM PROPORTION / SILHOUETTE MATCH" not in review_status:
        raise SystemExit("FAIL: candidate 13 must remain explicitly rejected as a full-body pose/silhouette match")
    reference_scale_factor = reference_arm_height / candidate_arm_height
    if not (0.25 <= reference_scale_factor <= 0.85):
        raise SystemExit(f"FAIL: candidate-to-reference scale factor is implausible ({reference_scale_factor:.3f})")
    reference_arm_at_256 = reference_arm_height * 256.0 / reference_body_height
    candidate_arm_at_256 = candidate_arm_height * reference_scale_factor * 256.0 / reference_body_height
    if abs(reference_arm_at_256 - candidate_arm_at_256) > 0.5:
        raise SystemExit("FAIL: candidate arm height does not match the reference ratio at 256 px character height")

    upper_h = PANEL_BOUNDS[0][3] - PANEL_BOUNDS[0][1]
    forearm_h = PANEL_BOUNDS[2][3] - PANEL_BOUNDS[2][1]
    assembled_h = PANEL_BOUNDS[3][3] - PANEL_BOUNDS[3][1]
    implied_overlap = upper_h + forearm_h - assembled_h
    overlap_fraction = implied_overlap / forearm_h
    if not (0 <= implied_overlap <= forearm_h * 0.25):
        raise SystemExit(f"FAIL: rough component span relationship is implausible ({implied_overlap}px overlap)")

    # Binary alpha assembly at the explicitly documented, estimated layout.
    # This tests visible 2D under-shell coverage and contact only; it does not
    # certify biological accuracy or animation/deformation.
    component_masks = []
    for bounds, (offset_x, offset_y) in zip(PANEL_BOUNDS[:3], ASSEMBLY_OFFSETS):
        x0, y0, x1, y1 = bounds
        region = alpha.crop(bounds).point(lambda value: 255 if value >= 128 else 0)
        placed = Image.new("L", ASSEMBLY_CANVAS, 0)
        placed.paste(region, (offset_x, offset_y), region)
        component_masks.append(placed)

    upper_arm, shell, forearm = component_masks
    def overlap_pixels(first: Image.Image, second: Image.Image) -> int:
        histogram = ImageChops.multiply(first, second).histogram()
        return sum(histogram[1:])

    shell_underlap = overlap_pixels(upper_arm, shell)
    elbow_overlap = overlap_pixels(upper_arm, forearm)
    exposed_upper = overlap_pixels(upper_arm, ImageChops.invert(shell))
    if shell_underlap < 20_000:
        raise SystemExit(f"FAIL: shell does not cover enough biological upper-arm surface ({shell_underlap}px)")
    if elbow_overlap < 10_000:
        raise SystemExit(f"FAIL: forearm does not overlap the biological upper arm at the estimated elbow ({elbow_overlap}px)")
    if exposed_upper < 15_000:
        raise SystemExit(f"FAIL: insufficient biological upper-arm surface remains visible ({exposed_upper}px)")

    union = ImageChops.lighter(ImageChops.lighter(upper_arm, shell), forearm)
    occupancy = union.load()
    width, height = union.size
    visited = bytearray(width * height)
    components = 0
    for y in range(height):
        for x in range(width):
            index = y * width + x
            if occupancy[x, y] == 0 or visited[index]:
                continue
            components += 1
            stack = [index]
            visited[index] = 1
            while stack:
                current = stack.pop()
                cx, cy = current % width, current // width
                for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                    if 0 <= nx < width and 0 <= ny < height:
                        neighbor = ny * width + nx
                        if occupancy[nx, ny] > 0 and not visited[neighbor]:
                            visited[neighbor] = 1
                            stack.append(neighbor)
    if components != 1:
        raise SystemExit(f"FAIL: estimated arm assembly has {components} disconnected alpha regions")

    raw = alpha.tobytes()
    fringe = sum(value < 128 for value in raw if value > 0)
    soft = sum(1 for value in raw if 128 <= value < 245)
    digest = hashlib.sha256(IMAGE.read_bytes()).hexdigest()
    print(f"PASS: transparent RGBA {image.width}x{image.height}; four panels and gutters; bounds={measured}.")
    print(f"PASS: rough same-scale span check implies {implied_overlap}px overlap ({overlap_fraction:.1%} of forearm height).")
    print(f"PASS: height-based reference scale factor={reference_scale_factor:.3f}; both arm extents={reference_arm_at_256:.1f}px at the 256px character target.")
    candidate_width_at_matched_height = candidate_arm_width * reference_scale_factor
    width_ratio = candidate_width_at_matched_height / reference_arm_width
    print(f"PASS: explicit fit disposition={review_status}; candidate/reference aspect={candidate_aspect:.3f}/{reference_aspect:.3f}; width at matched height={candidate_width_at_matched_height:.1f}px vs {reference_arm_width}px ({1.0-width_ratio:.1%} narrower).")
    print(f"PASS: estimated 2D assembly: shell/upper-arm overlap={shell_underlap}px; visible upper-arm={exposed_upper}px; elbow overlap={elbow_overlap}px; alpha union=1 connected region.")
    print(f"INFO: fringe pixels={fringe}; soft-alpha pixels={soft}; SHA256={digest}.")
    print("LIMIT: overlap and connectedness use the review's estimated pivots and binary alpha. This does not validate anatomical accuracy, hidden 3D structures, authored pivots, or animation seams.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
