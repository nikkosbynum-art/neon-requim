"""Extract an occluded skin donor into candidate 09's shell mask for QA only."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
OUT = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
DONOR = OUT / "donor_no_shell.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v5_underpaint_shell_off.png"

# This ROI bounds only the approved biological right upper arm and shell.
ARM_ROI = (240, 235, 455, 500)


def is_skin(r: int, g: int, b: int) -> bool:
    return r >= 105 and g >= 55 and b >= 35 and r > g * 1.08 and g > b * 1.05


def composite_trial(layers: list[str], underpaint: Image.Image, omit_shell: bool = False) -> Image.Image:
    result = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    result.alpha_composite(underpaint)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        result.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return result


def main() -> None:
    if not DONOR.exists():
        raise FileNotFoundError(f"Generated no-shell donor missing: {DONOR}")
    donor = Image.open(DONOR).convert("RGBA")
    if donor.size != (1024, 1536):
        raise ValueError(f"Expected 1024x1536 donor, got {donor.size}")
    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA")
    source = Image.open(SOURCE).convert("RGBA")
    manifest_path = BASE / "pivot_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    arm = Image.new("L", (1024, 1536), 0)
    ImageDraw.Draw(arm).rectangle(ARM_ROI, fill=255)
    arm_px, shell_px, donor_px = arm.load(), shell.load(), donor.load()
    hidden = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    hidden_px = hidden.load()
    selected = 0
    x0, y0, x1, y1 = ARM_ROI
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b, a = donor_px[x, y]
            if arm_px[x, y] and shell_px[x, y][3] >= 245 and a >= 245 and is_skin(r, g, b):
                hidden_px[x, y] = (r, g, b, 255)
                selected += 1
    if selected < 5000:
        raise AssertionError(f"Too few generated hidden skin pixels selected: {selected}")

    # The donor is underneath the exact source layers; their visible alpha must
    # occlude it perfectly in the approved neutral composite.
    assembled = composite_trial(manifest["layers_back_to_front"], hidden)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("Hidden donor changes the neutral source composite")

    hidden.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    shell_off = composite_trial(manifest["layers_back_to_front"], hidden, omit_shell=True)
    expected_shell_off = composite_trial(manifest["layers_back_to_front"], Image.new("RGBA", (1024, 1536)), omit_shell=True)
    crop = (220, 220, 485, 520)
    factor = 2
    a = expected_shell_off.crop(crop).resize(((crop[2]-crop[0])*factor, (crop[3]-crop[1])*factor), Image.Resampling.NEAREST)
    b = shell_off.crop(crop).resize(a.size, Image.Resampling.NEAREST)
    labels = ["SHELL OFF · SOURCE LAYERS", "SHELL OFF · WITH HIDDEN SKIN DONOR"]
    margin, label_h, gap = 20, 28, 20
    board = Image.new("RGBA", (margin*2 + a.width*2 + gap, margin*2 + label_h + a.height), "#151a20")
    draw = ImageDraw.Draw(board)
    for index, (label, img) in enumerate(zip(labels, [a, b])):
        x = margin + index * (a.width + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.alpha_composite(img, (x, margin + label_h))
    QA.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(QA)
    manifest["v5_hidden_arm_donor_trial"] = {
        "status": "QUARANTINED GENERATED UNDERPAINT STUDY — NOT PRODUCTION ART / NOT RUNTIME",
        "donor": str(DONOR.relative_to(ROOT)).replace("\\", "/"),
        "extraction": "warm skin pixels from shell-removed generated donor, bounded by the existing visible shell alpha and arm ROI",
        "arm_roi_px": list(ARM_ROI),
        "selected_hidden_skin_pixels": selected,
        "source_visible_composite_exact": True,
        "canon_boundary": "user-approved 2026-10-25: external shell over biological upper arm; prosthesis begins at elbow",
        "limitations": [
            "Generated donor changed visible pixels across the full reference and is never used as a replacement character image.",
            "Only masked pixels are stored as a hidden-skin donor beneath the unchanged source art.",
            "The shell-off donor reads rounder than the source and requires visual proportion review.",
            "Godot tests confirm registration only; the shell and hidden skin share one bone and are not independently animated.",
            "Source art remains a single generated concept pose; hidden anatomy is reconstructed, not canonically authored or production-verified.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v5 hidden-arm donor study\n\n"
        "**Quarantined anatomy trial; not production art or runtime content.** A generated shell-removed anatomy donor was used only to extract skin pixels beneath the unchanged candidate 09 shell mask. The full generated edit changed the character broadly and is rejected as a replacement image; the masked donor is an exploratory underlayer only.\n\n"
        "Python confirms an exact neutral composite; Godot registration passes 206 neutral/60 Hz samples across idle, walk, punch, hit, and defeat. The shell-off board shows a continuous human upper-arm volume, but its deltoid reads rounder than the source and residual source fragments remain. Keep it quarantined pending visual proportion review. Hidden anatomy remains reconstructed, not artist-authored.\n",
        encoding="utf-8",
    )
    print(f"PASS: selected {selected} hidden skin pixels beneath the original shell mask.")
    print("PASS: neutral composite remains pixel-identical to the thresholded candidate 09 source.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")
    print("LIMIT: generated hidden anatomy remains a quarantined visual hypothesis, not production art.")


if __name__ == "__main__":
    main()
