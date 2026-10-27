"""Split candidate 09's visible bicep and external shoulder shell for a rig trial.

The split preserves the v2 source pixels exactly. The two parts share one
shoulder bone; this does not invent concealed anatomy or independent shell
motion.
"""
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v2"
OUT = DRAFTS / "profile_rig_trial_09_canon_v3_shell_split"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v3_shell_split.png"


def is_skin(r: int, g: int, b: int) -> bool:
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite existing trial: {OUT}")
    shutil.copytree(BASE, OUT)

    original = Image.open(BASE / "cyber_upper_arm.png").convert("RGBA")
    source_px = original.load()
    mask = Image.new("L", original.size, 0)
    mask_px = mask.load()
    x0, y0, x1, y1 = original.getchannel("A").getbbox()
    seed_count = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b, a = source_px[x, y]
            if a >= 245 and is_skin(r, g, b):
                mask_px[x, y] = 255
                seed_count += 1
    assert seed_count >= 9000, f"Expected visible bicep skin is missing or changed: {seed_count}"

    # Keep a 1 px antialiased/dark contour with the biological component.
    mask = mask.filter(ImageFilter.MaxFilter(3))
    mask = ImageChops.multiply(mask, original.getchannel("A"))
    mask_px = mask.load()
    upper = Image.new("RGBA", original.size, (0, 0, 0, 0))
    shell = Image.new("RGBA", original.size, (0, 0, 0, 0))
    upper_px, shell_px = upper.load(), shell.load()
    for y in range(original.height):
        for x in range(original.width):
            if source_px[x, y][3] == 0:
                continue
            if mask_px[x, y] > 0:
                upper_px[x, y] = source_px[x, y]
            else:
                shell_px[x, y] = source_px[x, y]

    composite = Image.new("RGBA", original.size, (0, 0, 0, 0))
    composite.alpha_composite(upper)
    composite.alpha_composite(shell)
    assert ImageChops.difference(composite, original).getbbox() is None, "arm split changed the visible source"
    assert ImageChops.multiply(upper.getchannel("A"), shell.getchannel("A")).getbbox() is None, "skin and shell owners overlap"
    assert ImageChops.lighter(upper.getchannel("A"), shell.getchannel("A")).getbbox() == original.getchannel("A").getbbox(), "arm split silhouette bounds changed"

    upper.save(OUT / "cyber_upper_arm_skin.png", optimize=True)
    shell.save(OUT / "cyber_shoulder_shell.png", optimize=True)
    (OUT / "cyber_upper_arm.png").unlink()
    (OUT / "underpaint_cyber_upper_arm.png").unlink(missing_ok=True)

    manifest_path = OUT / "pivot_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    names = manifest["layers_back_to_front"]
    index = names.index("cyber_upper_arm")
    names[index:index + 1] = ["cyber_upper_arm_skin", "cyber_shoulder_shell"]
    pivot = manifest["pivots_px"]["cyber_shoulder"]
    manifest["pivots_px"]["cyber_upper_arm_skin"] = pivot
    manifest["pivots_px"]["cyber_shoulder_shell"] = pivot
    manifest["version"] = 3
    manifest["status"] = "QUARANTINED VISIBLE ARM COMPONENT TRIAL — NOT PRODUCTION ART / NOT RUNTIME"
    manifest["shell_skin_split"] = {
        "method": "warm-skin color ownership split from candidate 09 v2 cyber_upper_arm; remaining pixels assigned to separate shell/overlay component",
        "skin_seed_pixels": seed_count,
        "skin_layer_pixels": sum(1 for y in range(upper.height) for x in range(upper.width) if upper.getpixel((x, y))[3] > 0),
        "shell_layer_pixels": sum(1 for y in range(shell.height) for x in range(shell.width) if shell.getpixel((x, y))[3] > 0),
        "same_parent_bone": "CyberShoulder",
        "neutral_source_reconstruction": "exact RGBA; verified by exporter and audit",
        "hidden_anatomy_verified": False,
        "limitations": [
            "Skin under fully occluding shell pixels is not reconstructed.",
            "Shell and upper-arm skin share the same shoulder bone; independent shell motion is not supported.",
            "Color-based ownership may misclassify shaded or reflected pixels; manual visual inspection required.",
            "Existing pivots remain estimates transferred from the source extraction.",
        ],
    }
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER Tier I candidate 09 v3 visible shell split\n\n"
        "**Quarantined feasibility rig; not production art and not runtime content.** Derived from candidate 09 v2 without modifying that trial. The visible bicep skin and shoulder shell are separate transparent layers on the same estimated shoulder bone. Candidate RGB/alpha pixels are partitioned exactly, and the neutral visible composite is preserved.\n\n"
        "This split tests the approved visual reading and common-bone motion. It does not create skin pixels beneath the opaque shell, so hidden anatomy remains **NOT VERIFIED**. The shell cannot move independently from the upper arm. The color-mask and pivots are provisional.\n\n"
        "Run `python tools/art/audit_breaker_trial09_canon_v3_shell_split.py` and Godot tests `tests/test_breaker_profile_rig_trial_09_canon_v3_shell_split.gd` and `tests/test_breaker_profile_rig_trial_09_canon_v3_shell_split_contacts.gd`.\n",
        encoding="utf-8",
    )

    # A manual-review board shows ownership colors over the source arm.
    box = (220, 220, 520, 640)
    scale = 3
    size = ((box[2] - box[0]) * scale, (box[3] - box[1]) * scale)
    source_crop = Image.open(DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png").convert("RGBA").crop(box).resize(size, Image.Resampling.NEAREST)
    upper_crop = upper.crop(box).resize(size, Image.Resampling.NEAREST)
    shell_crop = shell.crop(box).resize(size, Image.Resampling.NEAREST)
    board = source_crop.copy()
    for layer, color in ((upper_crop, (0, 230, 130, 110)), (shell_crop, (235, 30, 150, 95))):
        paint = Image.new("RGBA", size, color)
        board.alpha_composite(Image.composite(paint, Image.new("RGBA", size, (0, 0, 0, 0)), layer.getchannel("A")))
    draw = ImageDraw.Draw(board)
    draw.rectangle((4, 4, 570, 40), fill=(10, 15, 20, 225))
    draw.text((12, 12), "GREEN: BIOLOGICAL UPPER ARM | MAGENTA: SHOULDER SHELL", fill=(255, 255, 255, 255))
    QA.parent.mkdir(parents=True, exist_ok=True)
    board.save(QA)
    print(f"PASS: separated visible arm pixels exactly; {seed_count} warm-skin seed pixels.")
    print(f"PASS: no ownership overlap; neutral composite equals source RGBA.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")
    print("LIMIT: concealed skin under shell, independent shell motion, pivots, and production readiness NOT VERIFIED.")


if __name__ == "__main__":
    main()
