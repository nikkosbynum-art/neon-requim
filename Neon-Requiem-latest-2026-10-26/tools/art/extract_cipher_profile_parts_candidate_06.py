"""Create a quarantined CIPHER review revision with leg-joint overlap.

Candidate 06 preserves the source pixels and CIPHER candidate-05 boundaries,
but retains source-backed overlap at thigh/shin and shin/boot seams so the
semantic pieces can be reviewed as connected layered anatomy. It does not
author hidden pixels, pivots, or production-ready parts.
"""
from __future__ import annotations

import json
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageOps

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.art.extract_cipher_profile_parts_candidate_05 import (
    EXCLUDE as CANDIDATE_05_EXCLUDE,
    MASKS,
    ORDER as CANDIDATE_05_ORDER,
    PAD,
    SOURCE,
    SOURCE_CROP,
    polygon_mask,
    remove_exterior_board,
)

OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06"

# Keep overlap at joints. The child part is rendered over its parent part;
# the shared pixels provide an inspectable seam reserve for later rig tests.
EXCLUDE = {name: tuple(excluded) for name, excluded in CANDIDATE_05_EXCLUDE.items()}
EXCLUDE["near_thigh"] = tuple(
    name for name in EXCLUDE.get("near_thigh", ()) if name not in {"near_shin", "near_boot"}
)
EXCLUDE["near_shin"] = tuple(
    name for name in EXCLUDE.get("near_shin", ()) if name != "near_boot"
)
ORDER = [
    "backpack_mount",
    "near_thigh",
    "near_shin",
    "near_boot",
    "pelvis_belt_gear",
    "torso_jacket",
    "near_upper_arm",
    "near_forearm",
    "near_hand",
    "head_hood_hair_face",
]


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite {OUT}")
    source = remove_exterior_board(Image.open(SOURCE).crop(SOURCE_CROP))
    masks = {name: polygon_mask(source.size, points) for name, points in MASKS.items()}
    layers: dict[str, Image.Image] = {}
    manifest = {
        "status": "QUARANTINED REVIEW CANDIDATE - NOT RIG INPUT",
        "semantic_review_status": "NOT_VERIFIED",
        "semantic_review_evidence": "docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_06_QUARANTINED.png",
        "semantic_review_note": "Native-scale review shows the 882 px secondary torso_jacket island maps to source-crop coordinates x=101..111, y=293..481 and follows the rear jacket outline in the approved profile. It remains in the torso_jacket layer rather than being discarded or assigned to an attachment. This is a provisional source-backed mapping; semantic approval, hidden anatomy, pivots, and deformation remain NOT VERIFIED.",
        "production_approved": False,
        "revision_from_candidate_05": "Retains source-backed alpha overlap at leg joints and draws thigh behind shin, shin behind boot.",
        "source": "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
        "source_view": "approved right-facing side profile",
        "crop_xywh": [SOURCE_CROP[0], SOURCE_CROP[1], source.width, source.height],
        "pivot_and_overlap_status": "leg overlap comes from visible source pixels; pivots and hidden/far-side anatomy are not authored",
        "layer_order_back_to_front": ORDER,
        "parts": {},
    }

    for name in ORDER:
        mask = masks[name].copy()
        for excluded in EXCLUDE.get(name, ()):
            mask.paste(0, mask=masks[excluded])
        alpha = ImageChops.multiply(source.getchannel("A"), mask)
        part = source.copy()
        part.putalpha(alpha)
        bbox = alpha.getbbox()
        if bbox is None:
            raise RuntimeError(f"empty part {name}")
        cutout = ImageOps.expand(part.crop(bbox), border=PAD, fill=(0, 0, 0, 0))
        filename = f"CIPHER_T1_{name.upper()}_REF_CUTOUT_CANDIDATE_06_QUARANTINED.png"
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
    for name in ORDER:
        mask = masks[name].copy()
        for excluded in EXCLUDE.get(name, ()):
            mask.paste(0, mask=masks[excluded])
        layer = source.copy()
        layer.putalpha(ImageChops.multiply(source.getchannel("A"), mask))
        assembly.alpha_composite(layer)
    assembly.save(OUT / "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_06_QUARANTINED.png")
    (OUT / "parts_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README_QUARANTINED.md").write_text(
        "# CIPHER Tier I cutout remap candidate 06\n\n"
        "Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. This revision preserves source-pixel overlap at the near thigh/shin and shin/boot boundaries and draws the lower child parts over their parent parts. It does not invent pixels or hidden anatomy. The extra overlap is only a seam reserve for review; semantic ownership, the detached torso detail, authored pivots, full-body assembly, hidden/far-side anatomy, and deformation remain unverified. Do not integrate into runtime.\n",
        encoding="utf-8",
    )
    print(f"Created {len(layers)} quarantined candidate-06 cutouts at {OUT}")


if __name__ == "__main__":
    main()
