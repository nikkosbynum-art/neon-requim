from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy")
SOURCE = ROOT / "candidate01_upper_arm_source_edit_v13_shell_off.png"
BASE_MASK = ROOT / "candidate01_upper_arm_vector_base_v2.png"
SKIN = ROOT / "candidate01_biological_upper_arm_visible_v4.png"
SHELL = ROOT / "candidate01_external_shoulder_shell_v4.png"
TORSO = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/torso.png")
FOREARM = Path("assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/cyber_forearm.png")
OUTPUT = ROOT / "candidate01_generated_skin_fitted_underlay_v15.png"


def opaque_alpha(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA").getchannel("A").point(lambda value: 255 if value >= 250 else 0)


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    donor_alpha = Image.new("L", source.size, 0)
    ImageDraw.Draw(donor_alpha).polygon(
        [
            (334, 267), (369, 259), (405, 264), (434, 284), (452, 317),
            (443, 354), (428, 391), (418, 432), (402, 470), (380, 499),
            (348, 520), (319, 508), (298, 481), (286, 448), (282, 398),
            (288, 352), (304, 309), (318, 282),
        ],
        fill=255,
    )
    source.putalpha(donor_alpha)
    donor_box = donor_alpha.getbbox()
    if donor_box is None:
        raise RuntimeError("The donor polygon is empty.")
    cutout = source.crop(donor_box)

    base = Image.open(BASE_MASK).convert("RGBA")
    base_alpha = base.getchannel("A")
    base_box = base_alpha.getbbox()
    if base_box is None:
        raise RuntimeError("The source-aligned arm envelope is empty.")

    # Keep the shoulder cap/source-facing contour compact; flare only the inner,
    # torso-facing half through the axilla toward the elbow. This supplies a
    # rounded connection rather than stretching entire image rows into streaks.
    target_left, target_top, _, target_bottom = base_box
    target_width = 132
    target_height = target_bottom - target_top
    fitted = cutout.resize((target_width, target_height), Image.Resampling.LANCZOS)
    shape = Image.new("L", (target_width, target_height), 0)
    ImageDraw.Draw(shape).polygon(
        [
            (0, 0), (102, 0), (104, 42), (110, 82), (122, 118),
            (132, 150), (128, 184), (116, target_height - 1), (0, target_height - 1),
        ],
        fill=255,
    )
    fitted.putalpha(ImageChops.darker(fitted.getchannel("A"), shape))

    canvas = Image.new("RGBA", source.size, (0, 0, 0, 0))
    canvas.alpha_composite(fitted, (target_left, target_top))

    coverage = Image.new("L", source.size, 0)
    for path in (SHELL, SKIN, TORSO, FOREARM):
        coverage = ImageChops.lighter(
            coverage,
            Image.open(path).convert("RGBA").getchannel("A").point(lambda value: 255 if value >= 250 else 0),
        )
    alpha = canvas.getchannel("A")
    alpha_px = alpha.load()
    coverage_px = coverage.load()
    for y in range(source.height):
        for x in range(source.width):
            if coverage_px[x, y] == 0:
                alpha_px[x, y] = 0
    canvas.putalpha(alpha)
    canvas.save(OUTPUT)

    print(f"Donor source bounds: {donor_box}")
    print(f"Fitted source-space envelope: ({target_left}, {target_top}, {target_left + target_width}, {target_bottom})")
    print(f"Underlay alpha bounds after source occlusion clip: {canvas.getchannel('A').getbbox()}")
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
