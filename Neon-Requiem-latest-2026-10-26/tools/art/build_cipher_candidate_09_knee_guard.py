from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

ROOT = Path.cwd()
SRC = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_08_hand_jacket_underpaint"
OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02"
REF = ROOT / "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
PAD = 60
CANVAS = (330, 960)

if OUT.exists():
    raise SystemExit(f"Refusing to overwrite: {OUT}")
manifest = json.loads((SRC / "parts_manifest.json").read_text(encoding="utf-8"))
parts = manifest["parts"]


def aligned(part_id: str) -> Image.Image:
    info = parts[part_id]
    source = Image.open(SRC / info["file"]).convert("RGBA")
    x0, y0, _, _ = info["source_bbox_xyxy"]
    canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    canvas.alpha_composite(source, (x0 - PAD, y0 - PAD))
    return canvas

thigh = aligned("near_thigh")
shin = aligned("near_shin")
t_alpha = thigh.getchannel("A")
s_alpha = shin.getchannel("A")

# Conservative source-traced polygon around the clearly visible knee armor,
# including its side joint. Coordinates are local to the approved 330x960
# right-profile crop (turnaround origin x=600, y=10).
source_xy = [
    (773, 620), (779, 614), (790, 610), (804, 612), (819, 616), (829, 623),
    (833, 632), (833, 643), (829, 654), (824, 663), (816, 670), (806, 675),
    (795, 676), (784, 672), (775, 666), (770, 657), (768, 647), (770, 637),
    (757, 640), (753, 634), (756, 627), (764, 622),
]
profile_polygon = [(x - 600, y - 10) for x, y in source_xy]
region = Image.new("L", CANVAS, 0)
ImageDraw.Draw(region).polygon(profile_polygon, fill=255)

# In the existing back-to-front order, near_shin is above near_thigh. Both
# currently contain the guard in their joint overlap. Extract their source
# composited pixels inside the conservative guard outline into one owner.
guard_alpha = Image.new("L", CANVAS, 0)
ga, ta, sa, ra = guard_alpha.load(), t_alpha.load(), s_alpha.load(), region.load()
for y in range(CANVAS[1]):
    for x in range(CANVAS[0]):
        if not ra[x, y]:
            continue
        a_t, a_s = ta[x, y], sa[x, y]
        if not (a_t or a_s):
            continue
        # Source-over alpha for near_shin above near_thigh.
        ga[x, y] = min(255, a_s + round(a_t * (255 - a_s) / 255))

bbox = guard_alpha.getbbox()
if bbox is None:
    raise SystemExit("No source pixels found inside the knee-guard outline")

# Clear the traced region from each parent layer, leaving the newly named
# guard as its sole visible owner. Pixels outside this shape remain untouched.
for layer in (thigh, shin):
    alpha = layer.getchannel("A")
    ap, rp = alpha.load(), region.load()
    for y in range(CANVAS[1]):
        for x in range(CANVAS[0]):
            if rp[x, y]:
                ap[x, y] = 0
    layer.putalpha(alpha)

# Pack the guard with the same 60 px transparent margin used by the other parts.
x0, y0, x1, y1 = bbox
ref = Image.open(REF).convert("RGBA").crop((600, 10, 930, 970))
guard_crop = Image.new("RGBA", (x1 - x0 + PAD * 2, y1 - y0 + PAD * 2), (0, 0, 0, 0))
rgb = ref.crop((x0, y0, x1, y1))
guard_crop.alpha_composite(rgb, (PAD, PAD))
alpha_crop = Image.new("L", guard_crop.size, 0)
alpha_crop.paste(guard_alpha.crop(bbox), (PAD, PAD))
guard_crop.putalpha(alpha_crop)

shutil.copytree(
    SRC,
    OUT,
    ignore=shutil.ignore_patterns("CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_08_QUARANTINED.png"),
)
# Version the source-derived part files in this new draft folder.
for info in parts.values():
    old_name = info["file"]
    new_name = old_name.replace("CANDIDATE_08", "CANDIDATE_09B")
    if old_name != new_name:
        (OUT / old_name).rename(OUT / new_name)
        info["file"] = new_name

# Write the updated parent cutouts, preserving each original canvas and RGB.
for part_id, canvas in (("near_thigh", thigh), ("near_shin", shin)):
    info = parts[part_id]
    part_bbox = canvas.getchannel("A").getbbox()
    if part_bbox is None:
        raise SystemExit(f"No source pixels remain in {part_id}")
    x0p, y0p, x1p, y1p = part_bbox
    info["source_bbox_xyxy"] = [x0p, y0p, x1p, y1p]
    info["size_px"] = [x1p - x0p + PAD * 2, y1p - y0p + PAD * 2]
    crop = canvas.crop((x0p - PAD, y0p - PAD, x1p + PAD, y1p + PAD))
    crop.save(OUT / info["file"])

guard_name = "CIPHER_T1_NEAR_KNEE_GUARD_REF_CUTOUT_CANDIDATE_09B_QUARANTINED.png"
guard_crop.save(OUT / guard_name)

new_parts = dict(parts)
new_parts["near_thigh"]["boundary_status"] = "Candidate 09 removes the traced knee-guard region; remaining thigh boundary is provisional and requires review."
new_parts["near_shin"]["boundary_status"] = "Candidate 09 removes the traced knee-guard region; remaining shin boundary is provisional and requires review."
new_parts["near_knee_guard"] = {
    "file": guard_name,
    "size_px": list(guard_crop.size),
    "source_bbox_xyxy": [x0, y0, x1, y1],
    "padding_px": PAD,
    "boundary_status": "Provisional source-traced polygon around visible knee armor and side joint; awaiting native-scale review.",
    "pivot_status": "not authored",
    "semantic_role": "independent articulated knee guard",
    "planned_anchor": "near_knee"
}
manifest["parts"] = new_parts
order = list(manifest["layer_order_back_to_front"])
order.insert(order.index("near_boot"), "near_knee_guard")
manifest["layer_order_back_to_front"] = order
manifest["status"] = "QUARANTINED REVIEW CANDIDATE - NOT RIG INPUT"
manifest["semantic_review_status"] = "NOT_VERIFIED"
manifest["production_approved"] = False
manifest["semantic_review_evidence"] = "docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_09B_QUARANTINED.png"
manifest["ownership_map_evidence"] = "docs/visual_qa/CIPHER_T1_PART_OWNERSHIP_MAP_09B_QUARANTINED.png"
manifest["boundary_review_evidence"] = "docs/visual_qa/CIPHER_T1_KNEE_GUARD_CANDIDATE_09B_BOUNDARY_REVIEW_QUARANTINED.png"
manifest["revision_from_candidate_08"] = "Separates the visible knee armor and side joint into near_knee_guard; thigh/shin parent masks relinquish the traced guard region."
manifest["knee_guard_split"] = {
    "source": "approved CIPHER right-profile anatomy turnaround; no new RGB pixels",
    "method": "source-over alpha extracted from near_thigh and near_shin inside a conservative source-traced polygon; parent masks cleared only inside that polygon",
    "polygon_profile_crop_xy": profile_polygon,
    "prior_shared_thresholded_pixels": 3520,
    "pivot_status": "not authored",
    "planned_anchor": "near_knee",
    "status": "User approved separate knee-guard part; front plate/red optic and upper side lug are isolated. Lower round hinge/strap remain with leg layers pending boundary review."
}
manifest.pop("open_semantic_review", None)
manifest["semantic_review_note"] = (
    "Candidate 09 implements the user-approved decision to give the visible armored kneecap its own near_knee_guard part. "
    "The current traced mask isolates the front armor plate/red optic and upper side lug; the lower round hinge/strap remain with the leg layers for user boundary review. "
    "The guard uses only source RGB; near_thigh and near_shin relinquish the selected region. Hidden anatomy, pivots, deformation, and production approval remain unverified."
)
manifest["assembly_preview"] = "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_09B_QUARANTINED.png"
(OUT / "parts_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

# Recompose the neutral assembly in the manifest draw order.
assembly = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
for part_id in order:
    if part_id == "near_upper_arm":
        assembly.alpha_composite(Image.open(OUT / manifest["inferred_underpaint"]["file"]).convert("RGBA"))
    if part_id == "near_knee_guard":
        assembly.alpha_composite(guard_crop, (x0 - PAD, y0 - PAD))
    else:
        info = manifest["parts"][part_id]
        img = Image.open(OUT / info["file"]).convert("RGBA")
        px, py, _, _ = info["source_bbox_xyxy"]
        assembly.alpha_composite(img, (px - PAD, py - PAD))
assembly_name = manifest["assembly_preview"]
assembly.save(OUT / assembly_name)

# Record an exact neutral-composite comparison against candidate 08.
old = Image.open(SRC / "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_08_QUARANTINED.png").convert("RGBA")
diff = ImageChops.difference(old, assembly)
report = {
    "candidate": "09B",
    "comparison": "candidate08 neutral assembly vs candidate09B neutral assembly",
    "pixel_identical": diff.getbbox() is None,
    "difference_bbox_xyxy": list(diff.getbbox()) if diff.getbbox() else None,
    "guard_alpha_pixels": sum(1 for v in guard_alpha.get_flattened_data() if v >= 32),
    "semantic_review_status": "NOT_VERIFIED",
    "production_approved": False,
}
(OUT / "neutral_assembly_comparison.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
(OUT / "README_QUARANTINED.md").write_text(
    "# CIPHER Tier I candidate 09B — separate knee guard study\n\n"
    "Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. Candidate 08 remains unchanged.\n\n"
    "This revision follows the user's approval to make the visible knee armor a separate `near_knee_guard` part "
    "anchored at the knee. The current traced mask isolates the front plate/red optic and upper side lug; the lower round hinge/strap remain with the leg layers for review. "
    "It reuses source RGB only; the thigh and shin parent masks relinquish the selected region. The pivot remains unauthored.\n\n"
    "Review the isolated knee-guard PNG, contact sheet, ownership map, and neutral assembly before pivots or rig use. "
    "The mask boundary is provisional. Semantic ownership, knee deformation, hidden surfaces, far-side anatomy, and "
    "production readiness remain NOT VERIFIED.\n",
    encoding="utf-8",
)
print(json.dumps(report, indent=2))
print(f"Created {OUT}")
