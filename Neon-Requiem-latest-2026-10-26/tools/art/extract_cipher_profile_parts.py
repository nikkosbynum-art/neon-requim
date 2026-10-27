#!/usr/bin/env python3
"""Create quarantined, overlapping CIPHER cutout layers from the approved side turnaround.

The source drawing is a flattened reference. These masks preserve visible pixels;
joint overlap and far-side anatomy are inferred and must remain review candidates.
"""

from collections import deque
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01"
SOURCE_CROP = (600, 10, 930, 970)
PAD = 60

# 330 x 960 crop-space polygons. Each neighboring joint part deliberately
# overlaps by 12-20 px so small rotations do not immediately expose the canvas.
MASKS = {
    "backpack_mount": [(20, 25), (165, 25), (170, 484), (115, 470), (58, 445), (20, 390)],
    "head_hood_hair_face": [(68, 0), (288, 0), (288, 210), (205, 224), (154, 200), (95, 174)],
    "torso_jacket": [(126, 150), (278, 168), (302, 340), (287, 515), (278, 625), (125, 618), (124, 500), (144, 425), (154, 337), (130, 270)],
    "near_upper_arm": [(115, 154), (175, 154), (193, 190), (181, 253), (178, 300), (168, 347), (127, 351), (108, 313), (106, 246)],
    "near_forearm": [(112, 325), (158, 320), (174, 346), (164, 394), (174, 424), (161, 451), (128, 438), (108, 410), (105, 366)],
    "near_hand": [(117, 414), (160, 420), (174, 474), (168, 515), (155, 532), (127, 526), (111, 494), (109, 450)],
    "pelvis_belt_gear": [(101, 505), (276, 510), (281, 678), (242, 704), (126, 693), (98, 648)],
    "near_thigh": [(111, 634), (263, 645), (268, 805), (226, 840), (133, 828), (101, 779)],
    "near_shin": [(113, 785), (250, 790), (246, 888), (205, 911), (127, 900), (100, 860)],
    "near_boot": [(101, 865), (249, 858), (289, 938), (286, 960), (82, 960), (83, 914)],
}

# Main silhouette layers must not copy the arm/hand pixels; the backpack and
# equipment sit behind the anatomy. A simple source-space exclusion prevents
# doubled limbs when the parts move.
EXCLUDE = {
    "torso_jacket": ("near_upper_arm", "near_forearm", "near_hand", "pelvis_belt_gear", "near_thigh", "near_shin", "near_boot"),
    "pelvis_belt_gear": ("near_hand", "near_thigh", "near_shin", "near_boot"),
    "near_thigh": ("near_shin", "near_boot"),
    "near_shin": ("near_boot",),
    "backpack_mount": ("head_hood_hair_face",),
}


def exterior_background_mask(image: Image.Image) -> Image.Image:
    """Flood-fill the neutral board background, retaining connected character pixels."""
    rgba = image.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    seen = bytearray(w * h)
    queue = deque()

    def is_board(x: int, y: int) -> bool:
        r, g, b, _ = px[x, y]
        return max(r, g, b) - min(r, g, b) < 24 and min(r, g, b) > 155

    for x in range(w):
        for y in (0, h - 1):
            if is_board(x, y):
                seen[y * w + x] = 1
                queue.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if is_board(x, y):
                seen[y * w + x] = 1
                queue.append((x, y))
    while queue:
        x, y = queue.popleft()
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if nx < 0 or ny < 0 or nx >= w or ny >= h:
                continue
            i = ny * w + nx
            if not seen[i] and is_board(nx, ny):
                seen[i] = 1
                queue.append((nx, ny))
    alpha = Image.new("L", (w, h), 255)
    ap = alpha.load()
    for y in range(h):
        for x in range(w):
            if seen[y * w + x]:
                ap[x, y] = 0
    rgba.putalpha(alpha)
    return rgba


def poly_mask(size: tuple[int, int], points: list[tuple[int, int]]) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).polygon(points, fill=255)
    return mask


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    source = exterior_background_mask(Image.open(SOURCE).crop(SOURCE_CROP))
    masks = {name: poly_mask(source.size, points) for name, points in MASKS.items()}
    final = {}
    for name, mask in masks.items():
        layer = mask.copy()
        for excluded in EXCLUDE.get(name, ()):
            # Only subtract the interior of a joint part when the parent is in
            # front of it; overlaps are preserved on the back-facing layers.
            layer.paste(0, mask=masks[excluded])
        layer = Image.eval(layer, lambda value: value)
        # Preserve antialiased source RGB and the extraction alpha.
        combined_alpha = ImageChops.multiply(source.getchannel("A"), layer)
        cropped = source.copy()
        cropped.putalpha(combined_alpha)
        bbox = combined_alpha.getbbox()
        if bbox is None:
            raise RuntimeError(f"empty semantic cutout: {name}")
        final[name] = ImageOps.expand(cropped.crop(bbox), border=PAD, fill=(0, 0, 0, 0))

    # Assemble in back-to-front order for human review.
    order = ["backpack_mount", "near_thigh", "near_shin", "near_boot", "pelvis_belt_gear", "torso_jacket", "near_upper_arm", "near_forearm", "near_hand", "head_hood_hair_face"]
    composite = Image.new("RGBA", source.size, (0, 0, 0, 0))
    manifest = {
        "status": "QUARANTINED REVIEW CANDIDATE",
        "source": "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
        "source_view": "right-facing side profile; original flattened reference preserved",
        "crop_xywh": [SOURCE_CROP[0], SOURCE_CROP[1], source.width, source.height],
        "pivot_and_overlap_status": "provisional; inferred from visible seams; no hidden anatomy is source-backed",
        "parts": {},
    }
    for name in order:
        alpha = final[name].getchannel("A")
        bbox = alpha.getbbox()
        # Retain the crop origin before it was applied, for a shared source-space rig.
        full_alpha = ImageChops.multiply(source.getchannel("A"), masks[name])
        for excluded in EXCLUDE.get(name, ()):
            full_alpha.paste(0, mask=masks[excluded])
        part_bbox = full_alpha.getbbox()
        if part_bbox is None or bbox is None:
            raise RuntimeError(f"empty cutout after alpha segmentation: {name}")
        x0, y0, _, _ = part_bbox
        composite.alpha_composite(final[name], (x0 - PAD, y0 - PAD))
        filename = f"CIPHER_T1_{name.upper()}_REF_CUTOUT_CANDIDATE_01.png"
        final[name].save(OUT / filename)
        manifest["parts"][name] = {
            "file": filename,
            "size_px": list(final[name].size),
            "source_crop_xy": [x0 - PAD, y0 - PAD],
            "safety_margin_px": PAD,
            "source_bbox_xyxy": list(part_bbox),
            "readiness": "reference-derived pixels; semantic boundary and pivot provisional",
        }
    composite.save(OUT / "CIPHER_T1_REFERENCE_CUTOUT_ASSEMBLY_CANDIDATE_01.png")
    (OUT / "parts_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
