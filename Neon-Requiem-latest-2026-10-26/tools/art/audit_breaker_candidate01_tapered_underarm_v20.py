"""Audit the quarantined v20 underarm's shell-on source fidelity and coverage."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01"
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy"
REFERENCE = BASE / "reference_cutout.png"
DONOR = TRIAL / "candidate01_tapered_underarm_v20.png"
OCCLUDERS = (
    BASE / "torso.png",
    TRIAL / "candidate01_biological_upper_arm_visible_v4.png",
    TRIAL / "candidate01_external_shoulder_shell_v4.png",
    BASE / "cyber_forearm.png",
)


def binary_alpha(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA").getchannel("A").point(lambda a: 255 if a >= 250 else 0)


def main() -> None:
    reference = Image.open(REFERENCE).convert("RGBA")
    donor = Image.open(DONOR).convert("RGBA")
    if donor.size != reference.size:
        raise SystemExit(f"FAIL: donor canvas {donor.size} differs from reference {reference.size}.")

    coverage = Image.new("L", reference.size, 0)
    for path in OCCLUDERS:
        layer = binary_alpha(path)
        if layer.size != reference.size:
            raise SystemExit(f"FAIL: occluder canvas differs: {path}")
        coverage = ImageChops.lighter(coverage, layer)

    donor_alpha = donor.getchannel("A").point(lambda a: 255 if a >= 250 else 0)
    uncovered = ImageChops.subtract(donor_alpha, coverage)
    uncovered_count = sum(1 for value in uncovered.getdata() if value)
    if uncovered_count:
        raise SystemExit(f"FAIL: {uncovered_count} opaque donor pixels are not covered by source layers.")

    # Composite the donor behind the approved source image, matching its intended
    # role as hidden backing rather than a visible replacement layer.
    result = Image.alpha_composite(donor, reference)
    diff = ImageChops.difference(reference, result)
    changed = sum(
        1
        for source_pixel, result_pixel in zip(reference.getdata(), result.getdata())
        if source_pixel[3] >= 250 and source_pixel != result_pixel
    )
    if changed:
        raise SystemExit(f"FAIL: adding v20 changes {changed} shell-on source pixels (bounds {diff.getbbox()}).")

    donor_pixels = sum(1 for value in donor_alpha.getdata() if value)
    print(f"PASS: all {donor_pixels} opaque v20 underlay pixels are occluded by approved source layers.")
    print("PASS: shell-on composite matches the approved candidate01 source exactly (0 changed pixels).")
    print("LIMIT: source fidelity does not authenticate hidden anatomy, pivots, or production readiness.")


if __name__ == "__main__":
    main()
