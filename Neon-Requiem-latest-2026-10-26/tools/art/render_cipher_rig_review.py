#!/usr/bin/env python3
"""Render pose contact sheet for the quarantined CIPHER reference-cutout rig."""
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
ASSET = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01"
OUT = ROOT / "docs/visual_qa/CIPHER_T1_RIG_POSE_REVIEW_CANDIDATE_01.png"
manifest = json.loads((ASSET / "parts_manifest.json").read_text(encoding="utf-8"))
W, H, XSHIFT = 700, 1040, 185
SOURCE_GROUND = (182.0, 954.0)

PART_INFO = {
    "head": ("head_hood_hair_face", "neck_socket", (205,193), 6),
    "backpack": ("backpack_mount", "torso", (175,610), -3),
    "torso": ("torso_jacket", "torso", (175,610), 1),
    "pelvis": ("pelvis_belt_gear", "torso", (175,610), 2),
    "upper_arm": ("near_upper_arm", "near_shoulder", (160,220), 3),
    "forearm": ("near_forearm", "near_elbow", (148,338), 4),
    "hand": ("near_hand", "near_wrist", (146,417), 5),
    "thigh": ("near_thigh", "near_hip", (168,640), 0),
    "shin": ("near_shin", "near_knee", (173,810), 0),
    "boot": ("near_boot", "near_ankle", (160,880), 1),
    "rifle": (None, "near_wrist", (250,140), 4),
}

def rotate(v, a):
    x,y=v; c,s=math.cos(a),math.sin(a)
    return (x*c-y*s, x*s+y*c)

def pose_angles(name):
    a={}
    if name == "idle": a.update(torso=.008, neck=-.008)
    if name == "walk": a.update(near_hip=-.15,near_knee=0.0,near_shoulder=.14,near_elbow=0.0,far_hip=.14,far_knee=0.0,far_shoulder=-.10,far_elbow=.05)
    if name == "aim_fire": a.update(near_shoulder=-1.20)
    if name == "hit": a.update(torso=-.07,neck=.06)
    if name == "defeat": a.update(torso=.20,near_hip=.31,near_knee=0.0,far_hip=-.14)
    return a

def build_bones(angles):
    # name -> (global pivot, cumulative rotation)
    data={"ground_root":((0.0,0.0),0.0)}
    hierarchy={
        "torso":("ground_root",(175,610)), "neck_socket":("torso",(30,-417)),
        "near_shoulder":("torso",(-15,-390)), "near_elbow":("near_shoulder",(-12,118)), "near_wrist":("near_elbow",(-2,79)),
        "near_hip":("torso",(-7,30)), "near_knee":("near_hip",(5,170)), "near_ankle":("near_knee",(-13,70)),
        "far_shoulder":("torso",(-18,-390)), "far_elbow":("far_shoulder",(-12,118)), "far_wrist":("far_elbow",(-2,79)),
        "far_hip":("torso",(-10,30)), "far_knee":("far_hip",(5,170)), "far_ankle":("far_knee",(-13,70)),
    }
    local_rot={"torso":angles.get("torso",0),"neck_socket":angles.get("neck",0),
               "near_shoulder":angles.get("near_shoulder",0),"near_elbow":angles.get("near_elbow",0),"near_wrist":angles.get("near_wrist",0),
               "near_hip":angles.get("near_hip",0),"near_knee":angles.get("near_knee",0),
               "far_shoulder":angles.get("far_shoulder",0),"far_elbow":angles.get("far_elbow",0),
               "far_hip":angles.get("far_hip",0),"far_knee":angles.get("far_knee",0)}
    pending=set(hierarchy)
    while pending:
        for child in list(pending):
            parent,local=hierarchy[child]
            if parent not in data: continue
            pp,pa=data[parent]
            delta=rotate(local,pa)
            data[child]=((pp[0]+delta[0],pp[1]+delta[1]),pa+local_rot.get(child,0))
            pending.remove(child)
    return data

def render_pose(name):
    canvas=Image.new("RGBA",(W,H),(0,0,0,0))
    bones=build_bones(pose_angles(name))
    order=["backpack","thigh","shin","boot","pelvis","torso","upper_arm","forearm","rifle","hand","head"]
    for part in order:
        if part=="rifle" and name!="aim_fire":
            continue
        asset_key,bone,pivot,z=PART_INFO[part]
        if part=="rifle":
            image=Image.open(ASSET/"CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png").convert("RGBA")
            origin=(0,0)
        else:
            pdata=manifest["parts"][asset_key]
            image=Image.open(ASSET/pdata["file"]).convert("RGBA")
            origin=tuple(pdata["source_crop_xy"])
        p,ang=bones[bone]
        if part=="rifle":
            # Grip remains aligned to the wrist while the barrel stays level.
            dx,dy=rotate((0,50),ang)
            p=(p[0]+dx,p[1]+dy)
            origin=(p[0]-190,p[1]-80)
            ang=0.0
        full=Image.new("RGBA",(W,H),(0,0,0,0))
        left=round(XSHIFT+origin[0]); top=round(origin[1])
        full.alpha_composite(image,(left,top))
        if part=="rifle":
            # Independent horizontal barrel attached by the receiver pivot.
            canvas.alpha_composite(full)
        else:
            # Rotate the cutout about its authored source-space pivot, then
            # translate that pivot to the hierarchical Skeleton2D joint.
            pivot_center=(XSHIFT+pivot[0],pivot[1])
            rotated=full.rotate(-math.degrees(ang),resample=Image.Resampling.BICUBIC,center=pivot_center,expand=False)
            shifted=Image.new("RGBA",(W,H),(0,0,0,0))
            shifted.alpha_composite(rotated,(round(p[0]-pivot[0]),round(p[1]-pivot[1])))
            canvas.alpha_composite(shifted)
    # Dark neutral panel and floor line, purely for visual review.
    bg=Image.new("RGBA",canvas.size,(17,23,35,255))
    bg.alpha_composite(canvas)
    d=ImageDraw.Draw(bg)
    ground_y=round(SOURCE_GROUND[1])
    d.line((80,ground_y,620,ground_y),fill=(74,91,112,255),width=2)
    return bg

def main():
    poses=["neutral","walk","aim_fire","defeat"]
    sheet=Image.new("RGB",(1280,720),(10,14,23))
    draw=ImageDraw.Draw(sheet)
    try: font=ImageFont.truetype("arial.ttf",20)
    except OSError: font=ImageFont.load_default()
    for i,name in enumerate(poses):
        panel=render_pose(name)
        # Show review characters at the same scale and crop all panels consistently.
        left=XSHIFT-20
        right=XSHIFT+(480 if name=="aim_fire" else 350)
        crop=panel.crop((left,0,right,H))
        factor=620.0/H
        resized=crop.resize((round(crop.width*factor),620),Image.Resampling.LANCZOS)
        frame=Image.new("RGB",(300,620),(17,23,35))
        frame.paste(resized.convert("RGB"),((300-resized.width)//2,0))
        x=20+i*315; y=60
        sheet.paste(frame,(x,y))
        draw.text((x,y-30),name.replace("_"," ").upper(),font=font,fill=(210,222,239))
    draw.text((20,14),"CIPHER TIER I — QUARANTINED REFERENCE-CUTOUT RIG REVIEW",font=font,fill=(236,55,126))
    draw.text((20,690),"Pivots and dark far-side underpaint are inferred; pose sheet is a review render, not production approval.",font=font,fill=(174,188,207))
    sheet.save(OUT)

if __name__=="__main__": main()
