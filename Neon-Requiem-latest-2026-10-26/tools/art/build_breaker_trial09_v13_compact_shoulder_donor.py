"""Extract a new generated shoulder-underlay hypothesis for quarantined QA.

Only pixels inside the existing v4 shell's opaque mask are copied from the
generated shell-off study. No reference-visible pixels are taken from it.
"""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_manual_skin"
OUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor"
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
V9 = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v9_continuous_arm_underpaint/hidden_biological_upper_arm_donor.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v13_shoulder_donor_review.png"
ARM_ROI = (240, 235, 455, 500)
REVIEW_ROI = (220, 220, 485, 520)
SCALE = 2


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
    allowed_initial = {".gdignore", "shell_off_anatomy_study.png"}
    if OUT.exists() and any(p.name not in allowed_initial for p in OUT.iterdir()):
        raise SystemExit(f"Refusing to overwrite populated trial directory: {OUT}")
    generated = Image.open(OUT / "shell_off_anatomy_study.png").convert("RGB")
    if generated.size != (1024, 1536):
        raise ValueError(f"Expected 1024x1536 generated study, got {generated.size}")
    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA")
    manifest_path = BASE / "pivot_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

    hidden = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    source_pixels = generated.load()
    shell_pixels = shell.load()
    hidden_pixels = hidden.load()
    x0, y0, x1, y1 = ARM_ROI
    selected = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b = source_pixels[x, y]
            if shell_pixels[x, y][3] >= 245 and is_skin(r, g, b):
                hidden_pixels[x, y] = (r, g, b, 255)
                selected += 1
    if selected < 5000:
        raise AssertionError(f"Too few hidden skin pixels selected: {selected}")

    hidden.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    layers: list[str] = manifest["layers_back_to_front"]
    shell_on = composite_trial(layers, hidden)
    expected = Image.open(SOURCE).convert("RGBA")
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(shell_on, expected).getbbox() is not None:
        raise AssertionError("New underpaint changes the thresholded candidate 09 shell-on composite")

    no_donor = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    panels = [
        Image.open(SOURCE).convert("RGBA").crop(REVIEW_ROI),
        composite_trial(layers, no_donor, omit_shell=True).crop(REVIEW_ROI),
        composite_trial(layers, Image.open(V9).convert("RGBA"), omit_shell=True).crop(REVIEW_ROI),
        composite_trial(layers, hidden, omit_shell=True).crop(REVIEW_ROI),
    ]
    panels = [p.resize((p.width * SCALE, p.height * SCALE), Image.Resampling.NEAREST) for p in panels]
    labels = ["APPROVED SOURCE · SHELL ON", "SHELL OFF · NO DONOR", "SHELL OFF · V9 REJECTED", "SHELL OFF · V13 TRIAL"]
    margin, label_h, gap = 20, 32, 16
    panel_w, panel_h = panels[0].size
    board = Image.new("RGB", (margin * 2 + panel_w * 4 + gap * 3, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for i, panel in enumerate(panels):
        x = margin + i * (panel_w + gap)
        draw.text((x, margin), labels[i], fill="#e8edf2")
        board.paste(panel.convert("RGB"), (x, margin + label_h))
    QA.parent.mkdir(parents=True, exist_ok=True)
    board.save(QA)

    manifest_out = {
        "status": "QUARANTINED GENERATED UNDER-SHELL STUDY — NOT PRODUCTION ART OR RUNTIME",
        "reference": str(SOURCE.relative_to(ROOT)).replace("\\", "/"),
        "generated_donor": str((OUT / "shell_off_anatomy_study.png").relative_to(ROOT)).replace("\\", "/"),
        "extraction": "skin-classified pixels from generated shoulder-shell-off study, clipped to opaque candidate 09 v4 shell pixels inside the arm ROI",
        "arm_roi_px": list(ARM_ROI),
        "selected_hidden_skin_pixels": selected,
        "source_visible_composite_exact": True,
        "canon_boundary": "user-approved 2026-10-25: external shoulder shell over biological upper arm; mechanical prosthesis begins at elbow",
        "limitations": [
            "The donor is a generated hypothesis, not artist-authored anatomy or canonical source content.",
            "The shell-off review crop is used for shape inspection only; all original source layers remain unchanged.",
            "Exact shell-on composite and mask connectivity do not establish anatomical truth.",
            "No independent shell deformation, authored pivots, all-frame seams, or production alpha are verified.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(manifest_out, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v13 compact shoulder-underlay study\n\n"
        "**Quarantined generated hypothesis only.** The generated shell-off image is preserved for audit. The exported donor contains only skin-classified pixels inside the opaque v4 shoulder-shell mask and approved arm ROI. No original visible pixels are replaced.\n\n"
        "Python verifies exact thresholded shell-on reconstruction. The shell-off comparison is diagnostic and requires manual art review. Generated/inferred anatomy, pivots, independent shell deformation, continuous animation seams, and production readiness remain unverified. The trial is not referenced by runtime scenes.\n",
        encoding="utf-8",
    )
    print(f"PASS: extracted {selected} candidate hidden-skin pixels.")
    print("PASS: exact thresholded shell-on composite preserved.")
    print(f"REVIEW: {QA.relative_to(ROOT).as_posix()}")
    print("LIMIT: hidden anatomy remains generated and unverified; not production art.")


if __name__ == "__main__":
    main()
