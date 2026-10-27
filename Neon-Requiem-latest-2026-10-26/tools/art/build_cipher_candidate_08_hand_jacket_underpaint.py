from __future__ import annotations

import json
import shutil
from pathlib import Path
from statistics import median

from PIL import Image

ROOT = Path.cwd()
SRC = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07"
OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_08_hand_jacket_underpaint"
MANIFEST = SRC / "parts_manifest.json"

if OUT.exists():
    raise SystemExit(f"Refusing to overwrite: {OUT}")
source_manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
W, H = 330, 960
parts = source_manifest["parts"]
pad = 60

def aligned_part(part_id: str) -> Image.Image:
    info = parts[part_id]
    img = Image.open(SRC / info["file"]).convert("RGBA")
    x0, y0, x1, y1 = info["source_bbox_xyxy"]
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    canvas.alpha_composite(img, (x0 - pad, y0 - pad))
    return canvas

# Align each part to the original 330x960 source crop.
aligned = {part_id: aligned_part(part_id) for part_id in parts}
hand_alpha = aligned["near_hand"].getchannel("A")

# Make a small, explicitly inferred underpaint wholly beneath the current hand
# silhouette. Its neutral pose is fully occluded by near_hand. Use a median
# charcoal sample from the lower jacket pixels; do not invent surface details.
torso = aligned["torso_jacket"]
colors = []
for y in range(430, 483):
    for x in range(95, 176):
        if hand_alpha.getpixel((x, y)) == 0:
            continue
        r, g, b, a = torso.getpixel((x, y))
        if a and max(r, g, b) < 115 and max(r, g, b) - min(r, g, b) < 50:
            colors.append((r, g, b))
if colors:
    base = tuple(int(median(c[i] for c in colors)) for i in range(3))
else:
    # Neutral charcoal sampled from the source jacket silhouette.
    base = (38, 39, 43)
underpaint = Image.new("RGBA", (W, H), (0, 0, 0, 0))
underpaint_pixels = underpaint.load()
hand_pixels = hand_alpha.load()
for y in range(H):
    for x in range(W):
        if hand_pixels[x, y]:
            underpaint_pixels[x, y] = (*base, 255)

# Save a new draft folder from candidate 07 without touching its files.
shutil.copytree(
    SRC,
    OUT,
    ignore=shutil.ignore_patterns(
        "CIPHER_T1_PART_AUTHORING_WORKSPACE_07_QUARANTINED.ora",
        "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_07_QUARANTINED.png",
    ),
)
# Give every part in this revision a candidate-08 filename so files cannot be
# confused with candidate 07 when the draft is reviewed or selectively opened.
for info in parts.values():
    old_name = info["file"]
    new_name = old_name.replace("CANDIDATE_07", "CANDIDATE_08")
    if old_name != new_name:
        (OUT / old_name).rename(OUT / new_name)
        info["file"] = new_name
underpaint_name = "CIPHER_T1_JACKET_UNDER_HAND_INFERRED_CANDIDATE_08_QUARANTINED.png"
underpaint.save(OUT / underpaint_name)

# Build a neutral assembly using the source crop's documented layer order,
# with the inferred fill behind the foreground arm/hand.
order = source_manifest["layer_order_back_to_front"]
assembly = Image.new("RGBA", (W, H), (0, 0, 0, 0))
for part_id in order:
    if part_id == "near_upper_arm":
        assembly.alpha_composite(underpaint)
    assembly.alpha_composite(aligned[part_id])
assembly_name = "CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_08_QUARANTINED.png"
assembly.save(OUT / assembly_name)

new_manifest = dict(source_manifest)
new_manifest["status"] = "QUARANTINED REVIEW CANDIDATE - NOT RIG INPUT"
new_manifest["semantic_review_status"] = "NOT_VERIFIED"
new_manifest["production_approved"] = False
new_manifest["revision_from_candidate_07"] = "Adds a separate inferred jacket underpaint layer beneath the hand footprint; candidate 07 already assigns the visible hand exclusively to near_hand."
new_manifest["semantic_review_evidence"] = "docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_08_QUARANTINED.png"
new_manifest["semantic_review_note"] = (
    "User-approved interpretation: the visible near hand is its own foreground part; the jacket continues behind it. "
    "Candidate 07 already assigns the visible hand exclusively to near_hand, with no shared hand pixels in pelvis_belt_gear or torso_jacket. "
    "Candidate 08 preserves those source-derived parts and adds a separate flat charcoal underpaint only beneath the current hand silhouette. "
    "Underpaint is inferred because the flattened reference occludes it; it is a continuity placeholder without authored texture or deformation approval. Candidate remains quarantined."
)
new_manifest["inferred_underpaint"] = {
    "file": underpaint_name,
    "owner": "torso_jacket",
    "provenance": "inferred_underpaint_user_approved_continuity",
    "draw_order": "behind near_upper_arm, near_forearm, and near_hand",
    "shape": "exact current near_hand alpha footprint",
    "rgb_method": "neutral charcoal fallback RGB (38,39,43); no source pixels sampled; flat fill with no added markings",
    "status": "NOT_VERIFIED - neutral-pose occlusion only; articulation coverage and visual texture require human review"
}
new_manifest["parts"]["pelvis_belt_gear"]["boundary_status"] = "candidate 07 source mask has no shared hand pixels; remaining source ownership is provisional and requires visual review"
new_manifest["parts"]["near_hand"]["boundary_status"] = "candidate 07 source mask assigns the visible hand exclusively to near_hand; visual review required"
new_manifest["assembly_preview"] = assembly_name
new_manifest["scale_review_evidence"] = [
    "docs/visual_qa/CIPHER_T1_CANDIDATE_08_ISOLATED_SCALE_1280x720_QUARANTINED.png",
    "docs/visual_qa/CIPHER_T1_CANDIDATE_08_ISOLATED_SCALE_800x450_QUARANTINED.png",
]
new_manifest["open_semantic_review"] = {
    "question": "Whether the visibly distinct knee guard remains overlapped across near_thigh and near_shin or becomes a separate near_knee_guard part.",
    "evidence": "docs/visual_qa/CIPHER_T1_CANDIDATE_08_KNEE_BOUNDARY_REVIEW_QUARANTINED.png",
    "shared_thresholded_pixels": 3520,
    "status": "AWAITING_USER_REVIEW; no leg pixels changed",
}
(OUT / "parts_manifest.json").write_text(json.dumps(new_manifest, indent=2), encoding="utf-8")
readme = (
    "# CIPHER Tier I candidate 08 — inferred hand/jacket continuity study\n\n"
    "Status: QUARANTINED REVIEW CANDIDATE; NOT RIG INPUT. Candidate 07 is unchanged.\n\n"
    "This revision follows the user's semantic instruction: near_hand is foreground. Candidate 07 already assigns "
    "visible hand pixels exclusively to near_hand. A separate flat charcoal underpaint sits only beneath the current hand silhouette and is "
    "labeled inferred because the approved source is flattened. The underpaint is not authored texture or proof of "
    "deformation coverage. It is fully hidden in the neutral assembly.\n\n"
    "Review the assembly and underpaint layer visually before any pivoting or rig use. Semantic correctness, hidden "
    "surface shape, deformation, far-side anatomy, and production readiness remain NOT VERIFIED.\n"
)
(OUT / "README_QUARANTINED.md").write_text(readme, encoding="utf-8")
print(f"Created {OUT}")
print(f"Underpaint color RGB: {base}; covered pixels: {sum(1 for y in range(H) for x in range(W) if hand_pixels[x, y])}")
