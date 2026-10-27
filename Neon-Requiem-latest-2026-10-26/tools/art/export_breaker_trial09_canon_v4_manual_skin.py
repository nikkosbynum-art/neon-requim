"""Split candidate 09's bicep and shoulder shell with hand-bounded skin ROIs."""
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
BASE = DRAFTS / "profile_rig_trial_09_canon_v2"
OUT = DRAFTS / "profile_rig_trial_09_canon_v4_manual_skin"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_v4_manual_skin_split.png"

# Hand-traced areas from the source crop. Warm-color classification only runs
# inside these exposed skin shapes, so red/silver armor highlights are excluded.
SKIN_POLYGONS = [
    [(255, 380), (410, 380), (410, 470), (255, 470)],
    [(333, 320), (351, 310), (378, 315), (398, 327), (413, 342), (418, 360), (410, 377), (396, 389), (378, 395), (356, 387), (340, 377), (332, 358)],
    [(249, 388), (270, 386), (293, 394), (322, 400), (342, 411), (350, 428), (346, 445), (331, 457), (308, 463), (286, 456), (267, 447), (253, 432), (245, 411)],
    [(342, 392), (361, 394), (383, 399), (398, 409), (407, 424), (399, 441), (380, 455), (355, 452), (345, 440), (343, 420)],
    [(416, 278), (435, 276), (446, 288), (449, 313), (446, 345), (439, 367), (427, 368), (419, 354), (422, 330), (417, 309)],
]


def is_skin(r: int, g: int, b: int) -> bool:
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite existing trial: {OUT}")
    shutil.copytree(BASE, OUT)

    original = Image.open(BASE / "cyber_upper_arm.png").convert("RGBA")
    source_px = original.load()
    roi = Image.new("L", original.size, 0)
    ImageDraw.Draw(roi).polygon(SKIN_POLYGONS[0], fill=255)
    for polygon in SKIN_POLYGONS[1:]:
        ImageDraw.Draw(roi).polygon(polygon, fill=255)
    roi_px = roi.load()

    mask = Image.new("L", original.size, 0)
    mask_px = mask.load()
    seed_count = 0
    for y in range(original.height):
        for x in range(original.width):
            r, g, b, a = source_px[x, y]
            if roi_px[x, y] and a >= 245 and is_skin(r, g, b):
                mask_px[x, y] = 255
                seed_count += 1
    assert seed_count >= 5000, f"Expected exposed bicep pixels not found: {seed_count}"

    skin = Image.new("RGBA", original.size, (0, 0, 0, 0))
    shell = Image.new("RGBA", original.size, (0, 0, 0, 0))
    skin_px, shell_px = skin.load(), shell.load()
    for y in range(original.height):
        for x in range(original.width):
            pixel = source_px[x, y]
            if pixel[3] == 0:
                continue
            if mask_px[x, y]:
                skin_px[x, y] = pixel
            else:
                shell_px[x, y] = pixel

    composite = Image.new("RGBA", original.size, (0, 0, 0, 0))
    composite.alpha_composite(skin)
    composite.alpha_composite(shell)
    assert ImageChops.difference(composite, original).getbbox() is None, "split changed source visible pixels"
    assert ImageChops.multiply(skin.getchannel("A"), shell.getchannel("A")).getbbox() is None, "skin/shell ownership overlaps"
    assert ImageChops.lighter(skin.getchannel("A"), shell.getchannel("A")).getbbox() == original.getchannel("A").getbbox(), "split changed visible bounds"

    skin.save(OUT / "cyber_upper_arm_skin.png", optimize=True)
    shell.save(OUT / "cyber_shoulder_shell.png", optimize=True)
    (OUT / "cyber_upper_arm.png").unlink()
    (OUT / "underpaint_cyber_upper_arm.png").unlink(missing_ok=True)
    shutil.copy2(BASE / "underpaint_cyber_upper_arm.png", OUT / "underpaint_cyber_arm_shared.png")

    manifest_path = OUT / "pivot_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    layers = manifest["layers_back_to_front"]
    layer_index = layers.index("cyber_upper_arm")
    layers[layer_index:layer_index + 1] = ["cyber_upper_arm_skin", "cyber_shoulder_shell"]
    pivot = manifest["pivots_px"]["cyber_shoulder"]
    manifest["pivots_px"]["cyber_upper_arm_skin"] = pivot
    manifest["pivots_px"]["cyber_shoulder_shell"] = pivot
    manifest["version"] = 4
    manifest["status"] = "QUARANTINED HAND-BOUNDED ARM SPLIT — NOT PRODUCTION ART / NOT RUNTIME"
    manifest["shell_skin_split"] = {
        "method": "hand-traced exposed-skin ROIs with color classification constrained inside polygons",
        "skin_seed_pixels": seed_count,
        "skin_layer_pixels": sum(1 for y in range(skin.height) for x in range(skin.width) if skin.getpixel((x, y))[3] > 0),
        "shell_layer_pixels": sum(1 for y in range(shell.height) for x in range(shell.width) if shell.getpixel((x, y))[3] > 0),
        "same_parent_bone": "CyberShoulder",
        "shared_inferred_underpaint": "copied from v2 underpaint_cyber_upper_arm; follows both split sprites and is not verified hidden anatomy",
        "neutral_composite_exact": True,
        "hidden_anatomy_verified": False,
        "limitations": [
            "Skin pixels fully occluded by the shoulder shell are not reconstructed.",
            "Shell and biological upper-arm layer share one bone and cannot move independently.",
            "Hand-traced skin bounds and inherited pivots are provisional estimates.",
            "This is a one-pose extraction; animation contacts must be tested in Godot.",
        ],
    }
    manifest["arm_layer_ownership"]["hidden_anatomy"] = "concealed skin is not present in this v4 visible-pixel split; see quarantined v5 generated-underpaint study"
    manifest["arm_layer_ownership"]["external_shell"] = "exported as cyber_shoulder_shell in v4 using a provisional hand-bounded visible mask; not artist-authored production art"
    manifest["validation"]["godot_tested"] = True
    manifest["validation"]["godot_tests"] = [
        "tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin.gd",
        "tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin_contacts.gd",
    ]
    manifest["validation"]["godot_scope"] = "visible-layer loading, canon ROI ownership, five poses, shared-bone registration at 206 samples/60 Hz; hidden anatomy and independent shell motion not validated"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER Tier I candidate 09 v4 hand-bounded arm split\n\n"
        "**Quarantined rig feasibility trial; not production art or runtime content.** Derived from v2. Hand-traced ROIs constrain the skin classifier to the visible upper arm, separating exposed skin from the external shoulder shell while preserving all visible source pixels. The two components share the estimated CyberShoulder bone.\n\n"
        "The export and audit prove exact neutral RGBA reconstruction and exclusive visible-pixel ownership only. No skin is reconstructed beneath the opaque shell; concealed anatomy remains **NOT VERIFIED**. Shell-independent movement is intentionally not supported in this trial. Pivots are inherited estimates.\n\n"
        "Run `python tools/art/audit_breaker_trial09_canon_v4_manual_skin.py`, then Godot tests `tests/test_breaker_profile_rig_trial_09_canon_v4_manual_skin.gd` and `_contacts.gd`.\n",
        encoding="utf-8",
    )

    box = (220, 220, 520, 640)
    crop_size = ((box[2] - box[0]) * 3, (box[3] - box[1]) * 3)
    source_crop = Image.open(SOURCE).convert("RGBA").crop(box).resize(crop_size, Image.Resampling.NEAREST)
    skin_crop = skin.crop(box).resize(crop_size, Image.Resampling.NEAREST)
    shell_crop = shell.crop(box).resize(crop_size, Image.Resampling.NEAREST)
    board = source_crop.copy()
    for layer, color in ((skin_crop, (0, 230, 130, 100)), (shell_crop, (235, 30, 150, 80))):
        paint = Image.new("RGBA", crop_size, color)
        board.alpha_composite(Image.composite(paint, Image.new("RGBA", crop_size, (0, 0, 0, 0)), layer.getchannel("A")))
    QA.parent.mkdir(parents=True, exist_ok=True)
    board.save(QA)
    print(f"PASS: {seed_count} visible warm-skin pixels assigned within three hand-traced skin regions.")
    print("PASS: exclusive pixel ownership and exact neutral RGBA reconstruction.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")
    print("LIMIT: concealed anatomy, independent shell movement, pivots, and animation remain NOT VERIFIED.")


if __name__ == "__main__":
    main()
