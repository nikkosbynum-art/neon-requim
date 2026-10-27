"""Build a quarantined continuous 2D backing for the BREAKER cyber upper arm.

This preserves every visible source pixel. The added skin surface is inferred
from the exposed bicep and exists only as underpaint beneath the unchanged arm
layers; it is a feasibility study, not verified hidden anatomy or production art.
"""
from __future__ import annotations

import json
import math
import shutil
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
BASE = DRAFTS / "profile_rig_trial_09_canon_v2"
OUT = DRAFTS / "profile_rig_trial_09_canon_v3_continuous_underpaint"
QA = ROOT / "docs/visual_qa/breaker_candidate09_v3_underpaint_qa.png"
ROI = (255, 380, 410, 470)
SHOULDER = (354.0, 333.0)
ELBOW = (383.0, 476.0)
RADIUS = 42.0
SCALE = 4


def is_skin(r: int, g: int, b: int) -> bool:
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite existing draft: {OUT}")
    source = Image.open(SOURCE).convert("RGBA")
    manifest = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))
    width, height = source.size
    visible_upper = Image.open(BASE / "cyber_upper_arm.png").convert("RGBA")
    visible_forearm = Image.open(BASE / "cyber_forearm.png").convert("RGBA")
    allowed = ImageChops.lighter(visible_upper.getchannel("A"), visible_forearm.getchannel("A"))

    # Make an antialiased capsule connecting the estimated shoulder and elbow.
    high = Image.new("L", (width * SCALE, height * SCALE), 0)
    draw = ImageDraw.Draw(high)
    a = tuple(round(v * SCALE) for v in SHOULDER)
    b = tuple(round(v * SCALE) for v in ELBOW)
    r = round(RADIUS * SCALE)
    draw.line((a, b), fill=255, width=r * 2)
    for cx, cy in (a, b):
        draw.ellipse((cx-r, cy-r, cx+r, cy+r), fill=255)
    capsule = high.resize((width, height), Image.Resampling.LANCZOS)
    capsule = ImageChops.multiply(capsule, allowed)

    # Use nearest locally sampled source skin color, preserving source texture
    # variation without moving or modifying any visible source pixel.
    source_px = source.load()
    skin_points: list[tuple[int, int, tuple[int, int, int]]] = []
    x0, y0, x1, y1 = ROI
    for y in range(y0, y1):
        for x in range(x0, x1):
            r0, g0, b0, alpha = source_px[x, y]
            if alpha >= 245 and is_skin(r0, g0, b0):
                skin_points.append((x, y, (r0, g0, b0)))
    assert len(skin_points) >= 2500, f"Expected visible bicep texture sample, got {len(skin_points)}"
    avg = tuple(sum(p[2][i] for p in skin_points) // len(skin_points) for i in range(3))
    buckets: dict[tuple[int, int], list[tuple[int, int, tuple[int, int, int]]]] = {}
    for point in skin_points:
        buckets.setdefault((point[0] // 12, point[1] // 12), []).append(point)

    upper = Image.new("RGBA", source.size, (0, 0, 0, 0))
    alpha_mask = capsule.load()
    out_px = upper.load()
    ax, ay = SHOULDER
    vx, vy = ELBOW[0] - ax, ELBOW[1] - ay
    length_sq = vx * vx + vy * vy
    length = math.sqrt(length_sq)
    x_min, y_min, x_max, y_max = capsule.getbbox()
    filled = 0
    for y in range(y_min, y_max):
        for x in range(x_min, x_max):
            coverage = alpha_mask[x, y]
            if coverage < 8:
                continue
            t = max(0.0, min(1.0, ((x-ax)*vx + (y-ay)*vy) / length_sq))
            px = x - (ax + t*vx)
            py = y - (ay + t*vy)
            signed_d = (vx*py - vy*px) / length
            # Map along/across the capsule into the exposed bicep sample area.
            target_x = 330.0 + max(-1.0, min(1.0, signed_d / RADIUS)) * 28.0
            target_y = 390.0 + t * 78.0
            candidates = []
            bx, by = round(target_x / 12), round(target_y / 12)
            for yy in range(by-2, by+3):
                for xx in range(bx-2, bx+3):
                    candidates.extend(buckets.get((xx, yy), ()))
            if candidates:
                _, _, color = min(candidates, key=lambda q: (q[0]-target_x)**2 + (q[1]-target_y)**2)
            else:
                color = avg
            out_px[x, y] = (*color, coverage)
            filled += 1

    OUT.mkdir(parents=True)
    for f in BASE.iterdir():
        if f.is_file():
            shutil.copy2(f, OUT / f.name)
    upper.save(OUT / "underpaint_cyber_upper_arm.png", optimize=True)

    # Review board shows source, the underpaint masked to original arm extents,
    # and the new contiguous backing by itself on a dark neutral background.
    crop_box = (220, 210, 510, 630)
    board = Image.new("RGB", (1350, 930), (18, 22, 28))
    labels = ["SOURCE REFERENCE", "V3 CONTINUOUS ARM UNDERPAINT", "SHELL / BIOLOGICAL ARM OVERLAY"]
    font = ImageFont.truetype("arial.ttf", 22) if Path("C:/Windows/Fonts/arial.ttf").exists() else ImageFont.load_default()
    d = ImageDraw.Draw(board)
    panels = [
        source.crop(crop_box),
        upper,
        source.copy(),
    ]
    # Reconstruct only the arm owner union to compare the backing silhouette.
    arm_overlay = Image.new("RGBA", source.size, (0, 0, 0, 0))
    arm_overlay.alpha_composite(upper)
    arm_overlay.alpha_composite(visible_upper)
    arm_overlay.alpha_composite(visible_forearm)
    panels[2] = arm_overlay
    for i, title in enumerate(labels):
        x = 20 + i * 445
        d.text((x, 16), title, fill=(230, 235, 242), font=font)
        part = panels[i].crop(crop_box).convert("RGBA")
        bg = Image.new("RGBA", part.size, (27, 32, 39, 255)); bg.alpha_composite(part)
        bg = bg.convert("RGB").resize((420, 740), Image.Resampling.LANCZOS)
        board.paste(bg, (x, 56))
    board.save(QA)

    manifest.update({
        "status": "QUARANTINED CONTINUOUS UNDERPAINT STUDY — NOT PRODUCTION ART / NOT RUNTIME",
        "version": 3,
        "continuous_underpaint": {
            "method": "antialiased shoulder-to-elbow capsule sampled from the visible right bicep; clipped to existing arm-owner union",
            "shoulder_px": list(SHOULDER), "elbow_px": list(ELBOW), "radius_px": RADIUS,
            "coverage_pixels": filled, "skin_sample_pixels": len(skin_points),
            "external_shell_separate": False,
            "hidden_anatomy_verified": False,
            "status": "2D inferred texture backing only; biological volume and concealed surfaces remain unverified"
        },
        "hidden_anatomy_verified": False,
        "limitations": list(dict.fromkeys(manifest.get("limitations", []) + [
            "The v3 continuous upper-arm underpaint is a sampled 2D backing, not verified anatomical structure.",
            "The external shoulder shell remains fused to the visible upper-arm composite.",
            "Estimated pivots and pose tests do not certify production deformation or animation seams."
        ]))
    })
    (OUT / "pivot_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER candidate 09 canon v3 — continuous arm underpaint\n\n"
        "**Quarantined feasibility draft only.** The original candidate 09 visible pixels and v2 arm-layer ownership are preserved. This revision replaces the two small inferred upper-arm patches with one antialiased capsule backing sampled from the visible bicep, clipped to the original arm extent.\n\n"
        "This makes a continuous 2D texture surface available behind the arm in the sampled neutral silhouette. It does not establish hidden 3D anatomy, anatomical accuracy, a separately authored shoulder shell, correct movement pivots, or production animation.\n\n"
        f"Coverage: {filled} pixels; source skin samples: {len(skin_points)}. QA board: `{QA.relative_to(ROOT).as_posix()}`.\n",
        encoding="utf-8"
    )
    print(f"PASS: built separate draft {OUT.relative_to(ROOT).as_posix()}; continuous mask pixels={filled}; source skin sample pixels={len(skin_points)}.")
    print("LIMIT: inferred 2D backing only; hidden anatomical volume remains NOT VERIFIED.")


if __name__ == "__main__":
    from PIL import ImageFont
    main()
