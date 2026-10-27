"""Create quarantined CIPHER candidate 05 with explicit hood/backpack ownership.

This candidate changes one evidence-backed boundary from candidate 04: pixels
inside the head/hood mask can no longer be owned by the backpack layer. It
remains a review candidate, not production art.
"""
from __future__ import annotations

import json
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageOps

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.art.extract_cipher_profile_parts_candidate_04 import (  # noqa: E402
    EXCLUDE as PREVIOUS_EXCLUDE,
    MASKS,
    ORDER,
    PAD,
    SOURCE,
    SOURCE_CROP,
    polygon_mask,
    remove_exterior_board,
)

OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05"
EXCLUDE = dict(PREVIOUS_EXCLUDE)
EXCLUDE["backpack_mount"] = (
    "head_hood_hair_face",
    *PREVIOUS_EXCLUDE["backpack_mount"],
)


def main() -> None:
    if OUT.exists():
        raise FileExistsError(f"Refusing to overwrite {OUT}")
    OUT.mkdir(parents=True)
    source = remove_exterior_board(Image.open(SOURCE).crop(SOURCE_CROP))
    masks = {name: polygon_mask(source.size, points) for name, points in MASKS.items()}
    layers: dict[str, Image.Image] = {}
    manifest = {
        "status": "REJECTED AFTER PREVIEW SCREEN - QUARANTINED DIAGNOSTIC ONLY",
        "semantic_review_status": "PREVIEW_SCREEN_FAIL",
        "semantic_review_evidence": "docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_05_QUARANTINED.png",
        "semantic_review_note": "Preliminary native-resolution alpha-checkerboard screen flags an incomplete near_thigh fragment and detached neighboring torso_jacket pixels; full Krita review remains unverified.",
        "production_approved": False,
        "ownership_diagnostic": "docs/visual_qa/CIPHER_T1_PART_OWNERSHIP_MAP_05_QUARANTINED.png",
        "revision_from_candidate_04": "backpack_mount excludes the head_hood_hair_face mask",
        "source": "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
        "source_view": "approved right-facing side profile",
        "crop_xywh": [SOURCE_CROP[0], SOURCE_CROP[1], source.width, source.height],
        "pivot_and_overlap_status": "provisional polygon boundaries; no hidden/far-side anatomy or authored pivots",
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
        layers[name] = ImageOps.expand(part.crop(bbox), border=PAD, fill=(0, 0, 0, 0))
        filename = f"CIPHER_T1_{name.upper()}_REF_CUTOUT_CANDIDATE_05_QUARANTINED.png"
        layers[name].save(OUT / filename)
        manifest["parts"][name] = {
            "file": filename,
            "size_px": list(layers[name].size),
            "source_bbox_xyxy": list(bbox),
            "padding_px": PAD,
            "boundary_status": "provisional polygon; full-resolution semantic review required",
            "pivot_status": "not authored",
        }

    assembly = Image.new("RGBA", source.size, (0, 0, 0, 0))
    for name in ORDER:
        mask = masks[name].copy()
        for excluded in EXCLUDE.get(name, ()):
            mask.paste(0, mask=masks[excluded])
        layer = source.copy()
        layer.putalpha(ImageChops.multiply(source.getchannel("A"), mask))
        assembly.alpha_composite(layer)
    assembly.save(OUT / "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_05_QUARANTINED.png")
    (OUT / "parts_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "README_QUARANTINED.md").write_text(
        "# CIPHER Tier I cutout remap candidate 05\n\n"
        "Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. This makes one measured ownership change from candidate 04: the backpack layer excludes pixels owned by the head/hood mask. The source-aligned ownership diagnostic records 4,549 multiply-owned pixels, down from candidate 04's 9,205, while preserving 100% of the thresholded source silhouette. This is a mechanical improvement only; semantic labels remain unreviewed. It preserves the approved source and does not infer hidden anatomy. Full-resolution part review, remaining boundary corrections, pivots, hidden/far-side art, and deformation review are outstanding. Do not integrate into runtime.\n",
        encoding="utf-8",
    )
    print(f"Created {len(layers)} quarantined candidate-05 cutouts and a source-aligned assembly at {OUT}")


if __name__ == "__main__":
    main()
