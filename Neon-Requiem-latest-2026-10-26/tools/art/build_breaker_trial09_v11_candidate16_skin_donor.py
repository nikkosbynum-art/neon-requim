"""Create a quarantined skin-only donor fit from candidate 16."""
from __future__ import annotations

import json
import math
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
DONOR = DRAFTS / "BREAKER_T1_pose_matched_arm_assembly_candidate_16.png"
OUT = DRAFTS / "profile_rig_trial_09_canon_v11_candidate16_skin_donor"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v11_candidate16_skin_donor.png"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
ROI = (220, 220, 485, 520)

# Landmark placement is an explicitly estimated concept fit, not an authored pivot.
# The largest two candidate-16 skin regions are aligned with candidate 09's two
# exposed biological upper-arm patches, rather than fitting the mismatched fist.
DONOR_UPPER_SKIN_CENTER = (996.0, 440.0)
DONOR_LOWER_SKIN_CENTER = (769.0, 563.0)
SOURCE_UPPER_SKIN_CENTER = (385.0, 335.0)
SOURCE_LOWER_SKIN_CENTER = (330.0, 415.0)


def main_regions(image: Image.Image) -> tuple[Image.Image, list[dict[str, object]]]:
    width, height = image.size
    src = image.load()
    selected = bytearray(width * height)
    for y in range(height):
        for x in range(width):
            r, g, b, a = src[x, y]
            if a > 96 and r > 145 and g > 75 and b > 40 and r > g * 1.12 and g > b * 1.10 and r - b > 45:
                selected[y * width + x] = 1

    seen = bytearray(len(selected))
    groups: list[list[int]] = []
    for start, value in enumerate(selected):
        if not value or seen[start]:
            continue
        seen[start] = 1
        members = [start]
        queue: deque[int] = deque([start])
        while queue:
            index = queue.popleft()
            x, y = index % width, index // width
            for ny in range(max(0, y - 1), min(height, y + 2)):
                for nx in range(max(0, x - 1), min(width, x + 2)):
                    neighbor = ny * width + nx
                    if selected[neighbor] and not seen[neighbor]:
                        seen[neighbor] = 1
                        members.append(neighbor)
                        queue.append(neighbor)
        groups.append(members)
    groups.sort(key=len, reverse=True)
    keep = groups[:3]
    keep_pixels = bytearray(len(selected))
    details: list[dict[str, object]] = []
    for members in keep:
        min_x, min_y, max_x, max_y = width, height, 0, 0
        for index in members:
            keep_pixels[index] = 1
            x, y = index % width, index // width
            min_x, min_y = min(min_x, x), min(min_y, y)
            max_x, max_y = max(max_x, x), max(max_y, y)
        details.append({"pixels": len(members), "bounds": [min_x, min_y, max_x + 1, max_y + 1]})

    mask = Image.frombytes("L", (width, height), bytes(255 if v else 0 for v in keep_pixels))
    return mask, details


def fit_skin(donor: Image.Image, mask: Image.Image) -> tuple[Image.Image, dict[str, float]]:
    donor = donor.convert("RGBA")
    dx = DONOR_LOWER_SKIN_CENTER[0] - DONOR_UPPER_SKIN_CENTER[0]
    dy = DONOR_LOWER_SKIN_CENTER[1] - DONOR_UPPER_SKIN_CENTER[1]
    sx = SOURCE_LOWER_SKIN_CENTER[0] - SOURCE_UPPER_SKIN_CENTER[0]
    sy = SOURCE_LOWER_SKIN_CENTER[1] - SOURCE_UPPER_SKIN_CENTER[1]
    scale = math.hypot(sx, sy) / math.hypot(dx, dy)
    rotation = math.atan2(sy, sx) - math.atan2(dy, dx)
    cosine, sine = math.cos(rotation), math.sin(rotation)

    # PIL expects a destination-to-source affine transform.
    a, b = cosine / scale, sine / scale
    d, e = -sine / scale, cosine / scale
    c = DONOR_UPPER_SKIN_CENTER[0] - a * SOURCE_UPPER_SKIN_CENTER[0] - b * SOURCE_UPPER_SKIN_CENTER[1]
    f = DONOR_UPPER_SKIN_CENTER[1] - d * SOURCE_UPPER_SKIN_CENTER[0] - e * SOURCE_UPPER_SKIN_CENTER[1]
    texture = Image.new("RGBA", donor.size, (0, 0, 0, 0))
    texture.paste(donor, mask=mask)
    fitted = texture.transform(
        (1024, 1536), Image.Transform.AFFINE, (a, b, c, d, e, f),
        resample=Image.Resampling.BICUBIC,
    )
    return fitted, {"uniform_scale": scale, "rotation_degrees": math.degrees(rotation)}


def composite(layers: list[str], donor: Image.Image, omit_shell: bool = False) -> Image.Image:
    result = Image.new("RGBA", (1024, 1536), (0, 0, 0, 0))
    result.alpha_composite(donor)
    for name in layers:
        if omit_shell and name == "cyber_shoulder_shell":
            continue
        result.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    return result


def opaque_coverage(layers: list[str]) -> Image.Image:
    """Pixels that are fully covered by the source artwork and hide underpaint."""
    result = Image.new("L", (1024, 1536), 0)
    rp = result.load()
    for name in layers:
        alpha = Image.open(BASE / f"{name}.png").convert("RGBA").getchannel("A")
        ap = alpha.load()
        for y in range(1536):
            for x in range(1024):
                if ap[x, y] == 255:
                    rp[x, y] = 255
    return result


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    source = Image.open(SOURCE).convert("RGBA")
    donor_source = Image.open(DONOR).convert("RGBA")
    skin_mask, regions = main_regions(donor_source)
    fitted, fit_data = fit_skin(donor_source, skin_mask)
    layers = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))["layers_back_to_front"]
    coverage = opaque_coverage(layers)
    fitted.putalpha(ImageChops.multiply(fitted.getchannel("A"), coverage))
    shell_on = composite(layers, fitted)
    expected = Image.open(BASE / "assembled_neutral.png").convert("RGBA")
    diff = ImageChops.difference(shell_on, expected)
    diff_bbox = diff.getbbox()
    # The donor must remain behind the visible forearm and shoulder; inspect skin ownership in that region.
    fitted_alpha = fitted.getchannel("A")
    forearm = Image.open(BASE / "cyber_forearm.png").convert("RGBA").getchannel("A")
    forearm_overlap = ImageChops.multiply(fitted_alpha, forearm).getbbox()
    shell_off = composite(layers, fitted, omit_shell=True)

    # Review sheet: original, fitted shell-on, and shell-off with the inferred donor.
    crop = ROI
    panels = [
        (source.crop(crop), "SOURCE CANDIDATE 09"),
        (shell_on.crop(crop), "CANDIDATE 16 SKIN DONOR · SHELL ON"),
        (shell_off.crop(crop), "SHELL OFF · INFERRED SKIN SHOWN"),
    ]
    panel_w, panel_h = 530, 600
    board = Image.new("RGB", (panel_w * 3, panel_h + 34), (18, 20, 26))
    draw = ImageDraw.Draw(board)
    for i, (panel, title) in enumerate(panels):
        panel = panel.resize((panel_w, panel_h), Image.Resampling.LANCZOS)
        background = Image.new("RGBA", panel.size, (18, 20, 26, 255))
        background.alpha_composite(panel)
        board.paste(background.convert("RGB"), (i * panel_w, 34))
        draw.text((i * panel_w + 10, 10), title, fill=(235, 240, 245))
    board.save(QA)

    fitted.save(OUT / "inferred_biological_upper_arm_underpaint.png")
    (OUT / "trial_manifest.json").write_text(json.dumps({
        "status": "QUARANTINED_REVIEW_ONLY",
        "source_candidate": str(SOURCE.relative_to(ROOT)).replace("\\", "/"),
        "donor_candidate": str(DONOR.relative_to(ROOT)).replace("\\", "/"),
        "donor_method": "top three connected warm-skin regions from a diagnostic threshold; clipped to fully opaque source-art coverage so it stays hidden in the shell-on source composite",
        "regions": regions,
        "fit": fit_data,
        "landmarks_px": {"donor_upper_skin_center": DONOR_UPPER_SKIN_CENTER, "donor_lower_skin_center": DONOR_LOWER_SKIN_CENTER, "source_upper_skin_center": SOURCE_UPPER_SKIN_CENTER, "source_lower_skin_center": SOURCE_LOWER_SKIN_CENTER},
        "shell_on_diff_bbox": diff_bbox,
        "donor_overlaps_visible_forearm_bbox": forearm_overlap,
        "hidden_anatomy_verified": False,
        "production_ready": False,
        "visual_review": "REJECTED: shell-off fit shows disconnected skin patches and texture artifacts; shell-on image remains exact after opaque-coverage clipping.",
        "qa_board": str(QA.relative_to(ROOT)).replace("\\", "/"),
        "limitations": ["manual estimated registration", "skin threshold may include reflective metal", "no authored components or pivots", "no deformation or continuous animation-seam test"],
    }, indent=2), encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 v11 candidate 16 skin donor\n\n"
        "**Quarantined visual reconstruction; not canon, production art, or runtime content.** "
        "This trial reuses only the largest three connected warm-skin regions from candidate 16 and registers them under candidate 09's unchanged shoulder shell/forearm using manually estimated shoulder-hub and fist landmarks.\n\n"
        "The source and generated donor are concept/reference material. The skin threshold and registration are hypotheses. Shell-on assembly is pixel-identical after clipping the donor to fully opaque source-art coverage, but manual review **rejects the shell-off fit**: it shows disconnected patches and texture artifacts. `trial_manifest.json` records measurements and limitations. Review `docs/visual_qa/BREAKER_T1_candidate09_v11_candidate16_skin_donor.png`; do not infer anatomy correctness from shell-on preservation.\n",
        encoding="utf-8",
    )

    if diff_bbox is None:
        print("PASS: shell-on candidate 09 composite is pixel-identical to the existing v4 assembly.")
    else:
        print(f"FAIL: donor alters shell-on source composite within bbox {diff_bbox}.")
    print(f"REGION: selected top-three donor skin regions totaling {sum(int(x['pixels']) for x in regions):,} threshold pixels.")
    print(f"FIT: scale={fit_data['uniform_scale']:.4f}, rotation={fit_data['rotation_degrees']:.2f} degrees (manual landmark estimate).")
    print(f"LIMIT: visible-forearm overlap bbox={forearm_overlap}; hidden anatomy remains unverified.")
    print(f"QA: {QA.relative_to(ROOT)}")
    if diff_bbox is not None:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
