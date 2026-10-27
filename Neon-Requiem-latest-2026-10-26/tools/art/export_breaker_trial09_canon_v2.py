"""Move visible biological upper-arm pixels onto the BREAKER shoulder bone.

Candidate 09's first neutral extraction exactly reconstructed the image but
the inherited candidate-05 forearm polygon owned part of the exposed human
bicep. This isolated v2 trial reassigns only a bounded skin-color mask from
the elbow/upper-arm seam. It changes no visible source pixel and does not
fabricate hidden anatomy.
"""
from __future__ import annotations

import json
import shutil
from hashlib import sha256
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
DRAFTS = ROOT / "assets/characters/breaker/tier_01_drafts"
SOURCE = DRAFTS / "BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
BASE = DRAFTS / "profile_rig_trial_09_canon_v1"
OUT = DRAFTS / "profile_rig_trial_09_canon_v2"
QA = ROOT / "docs/visual_qa/BREAKER_T1_candidate09_arm_canon_v2.png"
CANON_SKIN_ROI = (255, 380, 410, 470)
MIN_SKIN_PIXELS_MOVED = 2500


def is_skin_color(r: int, g: int, b: int) -> bool:
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite existing trial: {OUT}")
    source_hash = sha256(SOURCE.read_bytes()).hexdigest()
    source = Image.open(SOURCE).convert("RGBA")
    upper_path = BASE / "cyber_upper_arm.png"
    forearm_path = BASE / "cyber_forearm.png"
    upper = Image.open(upper_path).convert("RGBA")
    forearm = Image.open(forearm_path).convert("RGBA")
    assert source.size == upper.size == forearm.size == (1024, 1536)

    # Build a color-and-location constrained visible skin mask, then dilate it
    # by 2 px to keep its antialiased contour and adjacent dark seam with the
    # biological upper arm. The mask is clipped to existing forearm ownership.
    mask = Image.new("L", source.size, 0)
    src_px, fore_px = source.load(), forearm.load()
    mask_px = mask.load()
    x0, y0, x1, y1 = CANON_SKIN_ROI
    classified = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b, _ = src_px[x, y]
            if fore_px[x, y][3] >= 245 and is_skin_color(r, g, b):
                mask_px[x, y] = 255
                classified += 1
    assert classified >= MIN_SKIN_PIXELS_MOVED, f"Expected exposed bicep region not found: {classified} pixels"
    mask = mask.filter(ImageFilter.MaxFilter(5))
    fore_alpha = forearm.getchannel("A")
    mask = ImageChops.multiply(mask, fore_alpha.point(lambda a: 255 if a >= 245 else 0))
    roi_clip = Image.new("L", source.size, 0)
    ImageDraw.Draw(roi_clip).rectangle(CANON_SKIN_ROI, fill=255)
    mask = ImageChops.multiply(mask, roi_clip)

    upper_px, fore_px = upper.load(), forearm.load()
    moved = 0
    move_px = mask.load()
    for y in range(y0, y1):
        for x in range(x0, x1):
            if move_px[x, y] == 0:
                continue
            upper_px[x, y] = fore_px[x, y]
            fore_px[x, y] = (fore_px[x, y][0], fore_px[x, y][1], fore_px[x, y][2], 0)
            moved += 1
    assert moved >= classified

    OUT.mkdir(parents=True)
    for path in BASE.iterdir():
        if path.is_file():
            shutil.copy2(path, OUT / path.name)
    upper.save(OUT / "cyber_upper_arm.png", optimize=True)
    forearm.save(OUT / "cyber_forearm.png", optimize=True)

    manifest_path = OUT / "pivot_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest.update({
        "status": "QUARANTINED CANON-ALIGNED ARM OWNERSHIP TRIAL — NOT PRODUCTION ART / NOT RUNTIME",
        "version": 2,
        "canon_boundary": "user-approved 2026-10-25: biological right upper arm with external shoulder shell; mechanical prosthesis begins at elbow",
        "source_sha256": source_hash,
        "arm_layer_ownership": {
            "method": "reassign bounded warm-skin pixels from inherited cyber_forearm mask to cyber_upper_arm, preserving source RGB",
            "skin_roi_px": list(CANON_SKIN_ROI),
            "classified_skin_pixels": classified,
            "reassigned_pixels_including_2px_contour": moved,
            "source_art_modified": False,
            "hidden_anatomy": "not reconstructed; remains inferred/unknown",
            "external_shell": "remains fused with the upper-arm visible layer; separate shell layer is not delivered",
        },
        "hidden_anatomy_verified": False,
    })
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README.md").write_text(
        "# BREAKER Tier I candidate 09 rig trial — canon arm v2\n\n"
        "**Quarantined feasibility trial; not production art and not runtime content.** The source is the flattened candidate 09 review image. The v1 polygon extraction exactly reconstructed its neutral silhouette but assigned much of the visible bicep to the cyber forearm. This v2 transfers a bounded, skin-color-classified region from the forearm layer to the shoulder/upper-arm layer. Source RGB and the neutral composite are unchanged.\n\n"
        "The user-approved boundary is a biological right upper arm beneath an external shoulder shell, with the mechanical prosthesis beginning at the elbow. This trial tests semantic layer ownership for the visible pose only. The shoulder shell is still fused into the upper-arm texture. Hidden surfaces, authored pivots, continuous deformation, and production readiness remain unverified.\n\n"
        "Rebuild with `python tools/art/export_breaker_trial09_canon_v2.py`; run `python tools/art/audit_breaker_guarded_trial09_canon_v2.py` and Godot tests `tests/test_breaker_profile_rig_trial_09_canon_v2.gd` plus `_contacts.gd`.\n",
        encoding="utf-8",
    )

    # Preserve an exact neutral composite and exclusive visible pixel owners.
    parts = manifest["layers_back_to_front"]
    composite = Image.new("RGBA", source.size, (0, 0, 0, 0))
    union = Image.new("L", source.size, 0)
    for name in parts:
        layer = Image.open(OUT / f"{name}.png").convert("RGBA")
        alpha = layer.getchannel("A")
        assert ImageChops.multiply(union, alpha).getbbox() is None, f"overlap detected before owner union: {name}"
        composite.alpha_composite(layer)
        union = ImageChops.lighter(union, alpha)
    target = source.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
    expected = source.copy()
    expected.putalpha(target)
    assert ImageChops.difference(composite, expected).getbbox() is None, "v2 changed the neutral source composite"
    assert ImageChops.subtract(target, union).getbbox() is None, "v2 leaves a gap in the visible silhouette"

    # QA image: the original arm crop with both bone ownership masks overlaid.
    crop_box = (220, 220, 520, 640)
    scale = 3
    crop_size = ((crop_box[2] - crop_box[0]) * scale, (crop_box[3] - crop_box[1]) * scale)
    base_crop = source.crop(crop_box).resize(crop_size, Image.Resampling.NEAREST)
    up_crop = upper.crop(crop_box).resize(crop_size, Image.Resampling.NEAREST)
    fo_crop = forearm.crop(crop_box).resize(crop_size, Image.Resampling.NEAREST)
    overlay = base_crop.copy()
    for layer, color in ((up_crop, (0, 235, 140, 105)), (fo_crop, (235, 0, 160, 105))):
        paint = Image.new("RGBA", crop_size, color)
        overlay.alpha_composite(Image.composite(paint, Image.new("RGBA", crop_size, (0, 0, 0, 0)), layer.getchannel("A")))
    overlay.convert("RGB").save(QA)
    print(f"PASS: reassigned {moved} pixels (warm-skin seed={classified}) to biological upper-arm ownership.")
    print("PASS: exact neutral source composite and single-owner visible pixels preserved.")
    print(f"QA: {QA.relative_to(ROOT).as_posix()}")
    print("LIMIT: hidden anatomy, authored pivots, shell separation, and deformation are not certified.")


if __name__ == "__main__":
    main()
