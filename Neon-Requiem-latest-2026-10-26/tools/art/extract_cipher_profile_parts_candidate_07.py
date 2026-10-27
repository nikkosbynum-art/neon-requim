"""Create a quarantined CIPHER revision that keeps the back mast with its pack.

The visible source mast belongs to the backpack assembly, but candidate 06's
head polygon crosses it. This revision reallocates only a source-traced mast
region to the backpack mask. It adds no pixels and remains a review candidate.
"""
from __future__ import annotations

import json
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.art.extract_cipher_profile_parts_candidate_06 import (  # noqa: E402
    EXCLUDE as CANDIDATE_06_EXCLUDE,
    MASKS as CANDIDATE_06_MASKS,
    ORDER as CANDIDATE_06_ORDER,
    PAD,
    SOURCE,
    SOURCE_CROP,
    polygon_mask,
    remove_exterior_board,
)

OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07"

# Source-crop coordinates, traced around the visible signal mast/top cap and
# its lower exposed tube. It intentionally excludes the hood and pack casing.
BACKPACK_MAST_POINTS = [
    (70, 19), (83, 20), (92, 32), (91, 52), (86, 60),
    (88, 91), (91, 99), (96, 106), (97, 121), (93, 132),
    (89, 139), (88, 179), (94, 186), (99, 195), (99, 207),
    (95, 218), (89, 225), (88, 377), (91, 388), (94, 406),
    (92, 428), (87, 451), (68, 452), (63, 437), (64, 419),
    (68, 403), (68, 228), (60, 220), (57, 208), (59, 193),
    (64, 183), (63, 146), (60, 130), (60, 110), (64, 99),
    (63, 58), (60, 49), (61, 33),
]


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite {OUT}")
    source = remove_exterior_board(Image.open(SOURCE).crop(SOURCE_CROP))
    masks = {name: polygon_mask(source.size, points) for name, points in CANDIDATE_06_MASKS.items()}
    mast = polygon_mask(source.size, BACKPACK_MAST_POINTS)
    masks["head_hood_hair_face"] = ImageChops.subtract(masks["head_hood_hair_face"], mast)
    masks["backpack_mount"] = ImageChops.lighter(masks["backpack_mount"], mast)
    excludes = {name: tuple(values) for name, values in CANDIDATE_06_EXCLUDE.items()}
    # Backpack still yields ordinary hood overlap to the head, but the mast
    # region has been removed from the head mask and is therefore backpack-owned.
    order = list(CANDIDATE_06_ORDER)

    manifest = {
        "status": "QUARANTINED REVIEW CANDIDATE - NOT RIG INPUT",
        "semantic_review_status": "NOT_VERIFIED",
        "semantic_review_evidence": "docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_07_QUARANTINED.png",
        "semantic_review_note": "Candidate 07 reallocates the visible rear signal mast/top cap/lower exposed tube from head_hood_hair_face to backpack_mount, matching the approved front/profile/rear views. The polygon is source-traced and subject to native-scale review; no pixels or hidden surfaces are invented. Pivots, far-side anatomy, and deformation remain NOT VERIFIED.",
        "approved_semantic_interpretations": {
            "hand_jacket_occlusion": {
                "status": "USER_APPROVED_INTERPRETATION_2026-10-25",
                "visible_hand_owner": "near_hand",
                "jacket_owner": "torso_jacket",
                "jacket_continues_behind_hand": True,
                "visible_hand_pixels_must_not_be_owned_by": "pelvis_belt_gear",
                "required_draw_order_back_to_front": ["torso_jacket", "near_hand"],
                "underpaint_status": "NOT_AUTHORED",
                "underpaint_provenance_if_added": "INFERRED_NOT_VISIBLE_IN_FLATTENED_SOURCE",
                "gate_effect": "INTERPRETATION_ONLY; SEMANTIC_REVIEW_AND_PRODUCTION_APPROVAL_REMAIN_FALSE",
            }
        },
        "production_approved": False,
        "revision_from_candidate_06": "Prevents the visible backpack signal mast from being divided between the head and backpack cutout layers.",
        "ownership_adjustment": {
            "from": "head_hood_hair_face",
            "to": "backpack_mount",
            "source_crop_polygon_xy": BACKPACK_MAST_POINTS,
            "rationale": "The approved turnaround shows the mast physically mounted to the backpack, behind the head and torso.",
        },
        "source": "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
        "source_view": "approved right-facing side profile; front/rear views consulted for attachment ownership",
        "crop_xywh": [SOURCE_CROP[0], SOURCE_CROP[1], source.width, source.height],
        "pivot_and_overlap_status": "leg overlap is source-backed; backpack mast ownership is revised; pivots and hidden/far-side anatomy are not authored",
        "layer_order_back_to_front": order,
        "parts": {},
    }
    layers: dict[str, Image.Image] = {}
    for name in order:
        mask = masks[name].copy()
        for excluded in excludes.get(name, ()):
            mask.paste(0, mask=masks[excluded])
        alpha = ImageChops.multiply(source.getchannel("A"), mask)
        part = source.copy()
        part.putalpha(alpha)
        bbox = alpha.getbbox()
        if bbox is None:
            raise RuntimeError(f"empty part {name}")
        cutout = ImageOps.expand(part.crop(bbox), border=PAD, fill=(0, 0, 0, 0))
        filename = f"CIPHER_T1_{name.upper()}_REF_CUTOUT_CANDIDATE_07_QUARANTINED.png"
        layers[name] = cutout
        manifest["parts"][name] = {
            "file": filename,
            "size_px": list(cutout.size),
            "source_bbox_xyxy": list(bbox),
            "padding_px": PAD,
            "boundary_status": "provisional source-mask boundary; visual review required",
            "pivot_status": "not authored",
        }

    OUT.mkdir(parents=True)
    for name, cutout in layers.items():
        cutout.save(OUT / manifest["parts"][name]["file"])

    assembly = Image.new("RGBA", source.size, (0, 0, 0, 0))
    for name in order:
        mask = masks[name].copy()
        for excluded in excludes.get(name, ()):
            mask.paste(0, mask=masks[excluded])
        layer = source.copy()
        layer.putalpha(ImageChops.multiply(source.getchannel("A"), mask))
        assembly.alpha_composite(layer)
    assembly.save(OUT / "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_07_QUARANTINED.png")
    (OUT / "parts_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README_QUARANTINED.md").write_text(
        "# CIPHER Tier I cutout remap candidate 07\n\n"
        "Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. This revision keeps the visible rear signal mast with `backpack_mount` instead of splitting it between that layer and `head_hood_hair_face`. The ownership follows the approved turnaround; the traced mask is provisional and must pass full-size visual review. Candidate 06 remains unchanged. No source pixels or hidden anatomy were invented. Pivots, far-side anatomy, deformation, and production approval remain unverified.\n",
        encoding="utf-8",
    )
    print(f"Created {len(layers)} quarantined candidate-07 cutouts at {OUT}")


if __name__ == "__main__":
    main()
