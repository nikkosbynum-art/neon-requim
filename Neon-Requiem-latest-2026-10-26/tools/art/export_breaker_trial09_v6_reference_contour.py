"""Extract a reference-guided hidden-skin contour for candidate 09 review only."""
from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
V5 = DRAFTS / "profile_rig_trial_09_canon_v5_generated_underpaint"
OUT = DRAFTS / "profile_rig_trial_09_canon_v6_reference_contour"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
EDIT = OUT / "reference_contour_full_edit.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v6_reference_contour.png"
ARM_ROI = (240, 235, 455, 500)
REVIEW_CROP = (220, 220, 485, 520)


def is_skin(r: int, g: int, b: int) -> bool:
    return r >= 105 and g >= 55 and b >= 35 and r > g * 1.08 and g > b * 1.05


def composite(layers: list[str], hidden: Image.Image, omit_shell: bool = False) -> Image.Image:
    result = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    result.alpha_composite(hidden)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        result.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return result


def components(mask: Image.Image) -> list[list[tuple[int, int]]]:
    px = mask.load()
    w, h = mask.size
    remaining = {(x, y) for y in range(h) for x in range(w) if px[x, y]}
    found: list[list[tuple[int, int]]] = []
    while remaining:
        first = remaining.pop()
        stack = [first]
        group = [first]
        while stack:
            x, y = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    pos = (x + dx, y + dy)
                    if pos in remaining:
                        remaining.remove(pos)
                        stack.append(pos)
                        group.append(pos)
        found.append(group)
    return sorted(found, key=len, reverse=True)


def main() -> None:
    if not EDIT.exists():
        raise FileNotFoundError(f"Generated reference-contour study missing: {EDIT}")
    edited = Image.open(EDIT).convert("RGBA")
    if edited.size != (1024, 1536):
        raise ValueError(f"Expected 1024x1536 edit, got {edited.size}")

    v4 = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))
    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA")
    source = Image.open(SOURCE).convert("RGBA")
    donor = Image.new("RGBA", edited.size, (0, 0, 0, 0))
    edit_px, shell_px, donor_px = edited.load(), shell.load(), donor.load()
    x0, y0, x1, y1 = ARM_ROI
    selected = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b, a = edit_px[x, y]
            if shell_px[x, y][3] >= 245 and a >= 245 and is_skin(r, g, b):
                donor_px[x, y] = (r, g, b, 255)
                selected += 1
    if selected < 5000:
        raise AssertionError(f"Too few hidden biological skin pixels: {selected}")

    assembled = composite(v4["layers_back_to_front"], donor)
    expected = source.copy()
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(assembled, expected).getbbox() is not None:
        raise AssertionError("v6 underpaint changed the approved neutral source composite")

    visible = Image.open(BASE / "cyber_upper_arm_skin.png").convert("RGBA").getchannel("A")
    visible = visible.point(lambda a: 255 if a >= 245 else 0)
    hidden = donor.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    union = ImageChops.lighter(visible, hidden)
    groups = components(union)
    major_visible = [c for c in components(visible) if len(c) >= 100]
    largest = set(groups[0]) if groups else set()
    if not groups or len(groups[0]) < 25000 or any(not all(p in largest for p in group) for group in major_visible):
        raise AssertionError("v6 visible and hidden biological masks fail the connected-surface check")

    v5_hidden = Image.open(V5 / "hidden_biological_upper_arm_donor.png").convert("RGBA")
    v5_pixels = sum(v5_hidden.getchannel("A").histogram()[245:])
    if selected >= v5_pixels:
        raise AssertionError(f"Reference-guided donor did not reduce selected hidden pixels: v6={selected}, v5={v5_pixels}")

    donor.save(OUT / "hidden_biological_upper_arm_donor.png", optimize=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    shell_off_v5 = composite(v4["layers_back_to_front"], v5_hidden, omit_shell=True)
    shell_off_v6 = composite(v4["layers_back_to_front"], donor, omit_shell=True)
    panels = [
        ("V5 SHELL OFF · FULLER DONOR", shell_off_v5.crop(REVIEW_CROP)),
        ("V6 SHELL OFF · REFERENCE-GUIDED", shell_off_v6.crop(REVIEW_CROP)),
        ("V6 SOURCE · EXTERNAL SHELL ON", assembled.crop(REVIEW_CROP)),
    ]
    scale = 2
    margin, label_h, gap = 18, 32, 16
    panel_w = (REVIEW_CROP[2] - REVIEW_CROP[0]) * scale
    panel_h = (REVIEW_CROP[3] - REVIEW_CROP[1]) * scale
    board = Image.new("RGBA", (margin * 2 + panel_w * 3 + gap * 2, margin * 2 + label_h + panel_h), "#151a20")
    draw = ImageDraw.Draw(board)
    for i, (label, panel) in enumerate(panels):
        x = margin + i * (panel_w + gap)
        draw.text((x, margin), label, fill="#e8edf2")
        board.alpha_composite(panel.resize((panel_w, panel_h), Image.Resampling.NEAREST), (x, margin + label_h))
    board.convert("RGB").save(QA)

    manifest = {
        "status": "QUARANTINED REFERENCE-GUIDED UNDERPAINT STUDY — VISUAL MATCH NOT ESTABLISHED",
        "source_art": str(SOURCE.relative_to(ROOT)).replace("\\", "/"),
        "generated_edit": str(EDIT.relative_to(ROOT)).replace("\\", "/"),
        "extraction": "skin-classified pixels from reference-guided edit, clipped to the original candidate 09 shoulder-shell alpha and arm ROI",
        "arm_roi_px": list(ARM_ROI),
        "selected_hidden_skin_pixels": selected,
        "v5_selected_hidden_skin_pixels": v5_pixels,
        "pixel_delta": "only hidden donor pixels are supplied beneath unchanged candidate 09 visible layers",
        "source_visible_composite_exact": True,
        "largest_8_connected_biological_surface_px": len(groups[0]),
        "major_visible_skin_regions_connected": len(major_visible),
        "canon_boundary": "user-approved 2026-10-25: external shell over biological upper arm; prosthesis begins at elbow",
        "limitations": [
            "Generated hidden anatomy is a hypothesis, not artist-authored or canonically sourced.",
            "Manual shell-off review still sees a substantially rounder deltoid and residual edge fragments.",
            "Visible shell-on composite preservation and 2D connected masks do not validate anatomy, pivots, independent shell motion, or deformation.",
            "The full generated image is retained as a quarantined source study and must not replace the approved reference.",
            "Godot rig registration and production-art acceptance have not been established by this export script.",
        ],
    }
    (OUT / "trial_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v6 reference-contour study\n\n"
        "**Quarantined local anatomy comparison; not production art or runtime content. Visual match not established.** A constrained image edit using the approved candidate 09 full-body profile as a silhouette reference was clipped to the original shoulder-shell mask and upper-arm ROI. Only the under-shell skin donor differs; the source-visible neutral composition remains exact. Manual review still sees a substantially rounder deltoid and residual edge fragments.\n\n"
        "Python verifies exact neutral reconstruction and connected 2D visible/hidden biological masks. This does not establish anatomical correctness, authored pivots, independent shell deformation, animation seams, or production alpha.\n",
        encoding="utf-8",
    )
    print(f"PASS: v6 selected {selected} hidden-skin pixels versus v5 {v5_pixels}.")
    print("PASS: candidate 09 neutral composite remains pixel-identical after underpaint extraction.")
    print(f"PASS: largest 8-connected visible/hidden biological region is {len(groups[0])} pixels; {len(major_visible)} substantial visible regions connect.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")
    print("LIMIT: 2D continuity and exact compositing do not prove anatomy or production-ready rigging.")


if __name__ == "__main__":
    main()
