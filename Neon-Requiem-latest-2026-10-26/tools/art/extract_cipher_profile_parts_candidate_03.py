"""Build quarantined, source-preserving CIPHER profile cutout candidate 03.

This is a manual polygon-mask revision for visual review, not production approval.
All original reference artwork and candidate 01 files remain untouched.
"""
from __future__ import annotations

from collections import deque
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_03"
SOURCE_CROP = (600, 10, 930, 970)
PAD = 60

# Manually revised polygons in the profile crop coordinate frame (330x960).
# The boundaries are still provisional and must be visually checked at 100%.
MASKS = {
    "backpack_mount": [(22, 20), (114, 22), (145, 70), (148, 175), (151, 285), (154, 390), (142, 454), (108, 468), (64, 438), (28, 376)],
    "head_hood_hair_face": [(68, 132), (96, 94), (118, 48), (140, 12), (171, 0), (220, 7), (259, 34), (287, 63), (280, 105), (259, 127), (244, 155), (227, 194), (207, 220), (187, 205), (171, 174), (143, 154), (110, 151)],
    "torso_jacket": [(115, 150), (162, 144), (205, 162), (258, 184), (282, 232), (300, 322), (292, 427), (280, 512), (274, 557), (247, 581), (188, 573), (129, 554), (105, 493), (101, 372), (108, 269)],
    "near_upper_arm": [(108, 153), (157, 151), (187, 174), (190, 232), (180, 292), (173, 352), (160, 382), (125, 373), (109, 334), (104, 251)],
    "near_forearm": [(113, 340), (158, 334), (173, 366), (170, 417), (164, 454), (129, 461), (111, 429), (103, 389)],
    "near_hand": [(113, 423), (160, 421), (174, 451), (177, 499), (163, 530), (133, 535), (113, 510), (105, 474)],
    "pelvis_belt_gear": [(101, 482), (272, 480), (283, 525), (277, 593), (252, 627), (128, 619), (100, 575)],
    "near_thigh": [(108, 535), (250, 532), (258, 609), (241, 644), (190, 649), (126, 637), (102, 597)],
    "near_shin": [(105, 606), (242, 605), (246, 790), (227, 819), (167, 819), (110, 795), (96, 733)],
    "near_boot": [(81, 784), (247, 781), (279, 842), (292, 914), (288, 960), (82, 960), (78, 905)],
}
# Preserve overlap hierarchy while preventing duplicate visible-side anatomy.
EXCLUDE = {
    "backpack_mount": ("near_upper_arm", "near_forearm", "near_hand"),
    "head_hood_hair_face": ("torso_jacket", "near_upper_arm", "near_forearm", "near_hand"),
    "torso_jacket": ("near_upper_arm", "near_forearm", "near_hand", "pelvis_belt_gear", "near_thigh", "near_shin", "near_boot"),
    "pelvis_belt_gear": ("near_hand", "near_thigh", "near_shin", "near_boot"),
    "near_thigh": ("near_shin", "near_boot"),
    "near_shin": ("near_boot",),
}
ORDER = ["backpack_mount", "near_boot", "near_shin", "near_thigh", "pelvis_belt_gear", "torso_jacket", "near_upper_arm", "near_forearm", "near_hand", "head_hood_hair_face"]


def remove_exterior_board(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    px = rgba.load(); w, h = rgba.size
    seen = bytearray(w * h); queue = deque()
    def board(x: int, y: int) -> bool:
        r, g, b, _ = px[x, y]
        return max(r, g, b) - min(r, g, b) < 24 and min(r, g, b) > 155
    for x in range(w):
        for y in (0, h - 1):
            if board(x, y): seen[y*w+x] = 1; queue.append((x,y))
    for y in range(h):
        for x in (0, w - 1):
            if board(x, y) and not seen[y*w+x]: seen[y*w+x] = 1; queue.append((x,y))
    while queue:
        x,y=queue.popleft()
        for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
            if 0<=nx<w and 0<=ny<h:
                i=ny*w+nx
                if not seen[i] and board(nx,ny): seen[i]=1; queue.append((nx,ny))
    alpha=Image.new("L",(w,h),255); ap=alpha.load()
    for y in range(h):
        for x in range(w):
            if seen[y*w+x]: ap[x,y]=0
    rgba.putalpha(alpha)
    return rgba


def polygon_mask(size: tuple[int,int], points: list[tuple[int,int]]) -> Image.Image:
    mask=Image.new("L",size,0); ImageDraw.Draw(mask).polygon(points,fill=255); return mask


def main() -> None:
    if OUT.exists(): raise FileExistsError(f"Refusing to overwrite {OUT}")
    OUT.mkdir(parents=True)
    source=remove_exterior_board(Image.open(SOURCE).crop(SOURCE_CROP))
    masks={name:polygon_mask(source.size,points) for name,points in MASKS.items()}
    layers={}; manifest={"status":"QUARANTINED SEMANTIC REMAP CANDIDATE","source":"docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png","source_view":"approved right-facing side profile","crop_xywh":[SOURCE_CROP[0],SOURCE_CROP[1],source.width,source.height],"pivot_and_overlap_status":"provisional manual polygon boundaries; no hidden/far-side anatomy authored","parts":{}}
    for name in ORDER:
        mask=masks[name].copy()
        for excluded in EXCLUDE.get(name,()): mask.paste(0,mask=masks[excluded])
        alpha=ImageChops.multiply(source.getchannel("A"),mask)
        part=source.copy(); part.putalpha(alpha); bbox=alpha.getbbox()
        if bbox is None: raise RuntimeError(f"empty part {name}")
        layers[name]=ImageOps.expand(part.crop(bbox),border=PAD,fill=(0,0,0,0))
        fn=f"CIPHER_T1_{name.upper()}_REF_CUTOUT_CANDIDATE_03_QUARANTINED.png"; layers[name].save(OUT/fn)
        manifest["parts"][name]={"file":fn,"size_px":list(layers[name].size),"source_bbox_xyxy":list(bbox),"padding_px":PAD,"boundary_status":"manual polygon; requires 100-percent review","pivot_status":"not authored"}
    # Assemble aligned layers and measure how much reference silhouette is represented.
    assembly=Image.new("RGBA",source.size,(0,0,0,0))
    for name in ORDER:
        mask=masks[name].copy()
        for excluded in EXCLUDE.get(name,()): mask.paste(0,mask=masks[excluded])
        layer=source.copy(); layer.putalpha(ImageChops.multiply(source.getchannel("A"),mask)); assembly.alpha_composite(layer)
    assembly.save(OUT/"CIPHER_T1_REFERENCE_ASSEMBLY_CANDIDATE_03_QUARANTINED.png")
    (OUT/"parts_manifest.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
    (OUT/"README_QUARANTINED.md").write_text("# CIPHER Tier I cutout remap candidate 03\n\nStatus: QUARANTINED. This is a manual polygon-mask remap of visible source pixels, not finished production art. Candidate 01 remains untouched. Boundaries, overlaps, and pivots require visual review; far-side anatomy and hidden joint surfaces are absent. Do not integrate into runtime.\n",encoding="utf-8")
    print(f"Created {len(layers)} candidate layers; assembly coverage {sum(1 for a in assembly.getchannel('A').getdata() if a>0)} source-crop pixels.")

if __name__ == "__main__": main()
