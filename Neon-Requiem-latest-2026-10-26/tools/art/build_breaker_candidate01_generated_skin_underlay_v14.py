from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy")
SOURCE = ROOT / "candidate01_upper_arm_source_edit_v13_shell_off.png"
BASE_MASK = ROOT / "candidate01_upper_arm_vector_base_v2.png"
SKIN = ROOT / "candidate01_biological_upper_arm_visible_v4.png"
SHELL = ROOT / "candidate01_external_shoulder_shell_v4.png"
TORSO = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/torso.png")
FOREARM = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/cyber_forearm.png")
OUTPUT = ROOT / "candidate01_generated_skin_fitted_underlay_v14.png"
MASK_PREVIEW = ROOT / "candidate01_generated_skin_fitted_underlay_v14_mask_review.png"


def opaque_alpha(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA").getchannel("A").point(lambda value: 255 if value >= 250 else 0)


def main() -> None:
    donor = Image.open(SOURCE).convert("RGBA")
    base = Image.open(BASE_MASK).convert("RGBA")
    donor_alpha = Image.new("L", donor.size, 0)
    draw = ImageDraw.Draw(donor_alpha)
    # The polygon selects the human shoulder/upper arm only, avoiding vest and elbow hardware.
    draw.polygon(
        [
            (334, 267), (369, 259), (405, 264), (434, 284), (452, 317),
            (443, 354), (428, 391), (418, 432), (402, 470), (380, 499),
            (348, 520), (319, 508), (298, 481), (286, 448), (282, 398),
            (288, 352), (304, 309), (318, 282),
        ],
        fill=255,
    )
    donor.putalpha(donor_alpha)
    bbox = donor_alpha.getbbox()
    if bbox is None:
        raise RuntimeError("The upper-arm donor polygon is empty.")
    cutout = donor.crop(bbox)

    # Use the existing source-aligned provisional arm envelope as a measured fit target.
    target_bbox = base.getchannel("A").getbbox()
    if target_bbox is None:
        raise RuntimeError("The source-aligned fit envelope is empty.")
    target_size = (target_bbox[2] - target_bbox[0], target_bbox[3] - target_bbox[1])
    fitted = cutout.resize(target_size, Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", donor.size, (0, 0, 0, 0))
    canvas.alpha_composite(fitted, (target_bbox[0], target_bbox[1]))

    # Keep the donor wholly beneath existing torso, shoulder-shell, visible-skin,
    # and forearm pixels so the approved flattened shell-on image is preserved.
    coverage = Image.new("L", donor.size, 0)
    for path in (SHELL, SKIN, TORSO, FOREARM):
        coverage = ImageChops.lighter(coverage, opaque_alpha(path))
    alpha = canvas.getchannel("A")
    alpha_pixels = alpha.load()
    coverage_pixels = coverage.load()
    for y in range(donor.height):
        for x in range(donor.width):
            if coverage_pixels[x, y] == 0:
                alpha_pixels[x, y] = 0
    canvas.putalpha(alpha)
    canvas.save(OUTPUT)

    preview = Image.new("RGBA", donor.size, (18, 20, 25, 255))
    preview.alpha_composite(canvas)
    preview.convert("RGB").save(MASK_PREVIEW)

    print(f"Donor source bounds: {bbox}")
    print(f"Fitted to source envelope: {target_bbox} ({target_size[0]}x{target_size[1]})")
    print(f"Underlay alpha bounds after source occlusion clip: {canvas.getchannel('A').getbbox()}")
    print(f"Wrote {OUTPUT}")
    print(f"Wrote {MASK_PREVIEW}")


if __name__ == "__main__":
    from PIL import ImageChops

    main()
