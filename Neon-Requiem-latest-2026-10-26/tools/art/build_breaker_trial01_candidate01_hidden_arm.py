"""Build a quarantined hidden upper-arm study from approved BREAKER candidate 01."""
from __future__ import annotations
from collections import deque
import json, sys
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
DRAFTS=ROOT/"assets/characters/breaker/tier_01_drafts"
BASE=DRAFTS/"profile_rig_trial_01"
TRIAL=DRAFTS/"profile_rig_trial_01_candidate01_hidden_anatomy"
SOURCE=DRAFTS/"BREAKER_T1_profile_rebuild_candidate_01.png"
STUDY=TRIAL/"shell_off_anatomy_study_v1.png"
OUTPUT=TRIAL/"hidden_biological_upper_arm_candidate01_v2.png"
COMPACT_OUTPUT=TRIAL/"hidden_biological_upper_arm_candidate01_v3_compact72.png"
POLYGON=[(308,278),(326,267),(350,261),(375,261),(398,269),(416,286),(428,310),(433,333),(429,353),(418,373),(411,385),(422,398),(431,419),(430,439),(420,455),(401,467),(382,476),(363,473),(344,465),(325,456),(307,450),(293,438),(285,421),(285,402),(289,382),(297,361),(297,341),(294,324),(296,307),(301,290)]
def components(mask: bytearray,w:int,h:int)->list[list[tuple[int,int]]]:
    seen=bytearray(w*h); out=[]
    for y in range(h):
        for x in range(w):
            i=y*w+x
            if not mask[i] or seen[i]: continue
            q=deque([(x,y)]);seen[i]=1;pts=[]
            while q:
                cx,cy=q.popleft();pts.append((cx,cy))
                for ny in range(max(0,cy-1),min(h,cy+2)):
                    for nx in range(max(0,cx-1),min(w,cx+2)):
                        j=ny*w+nx
                        if mask[j] and not seen[j]:seen[j]=1;q.append((nx,ny))
            out.append(pts)
    return sorted(out,key=len,reverse=True)
def main()->None:
    study=Image.open(STUDY).convert("RGB");w,h=study.size
    if study.size!=(1024,1536):raise AssertionError("Unexpected study canvas")
    polygon=Image.new("L",study.size,0);ImageDraw.Draw(polygon).polygon(POLYGON,fill=255); pp=polygon.load();rgb=study.load()
    mask=bytearray(w*h)
    for y in range(h):
        for x in range(w):
            if not pp[x,y]:continue
            r,g,b=rgb[x,y]
            if r>=45 and r>g*1.01 and g>b*.92:mask[y*w+x]=1
    comps=components(mask,w,h);major=[c for c in comps if len(c)>=100]
    if not major or len(major[0])<10000:raise AssertionError("No connected upper-arm skin component")
    points=[pt for c in major for pt in c]
    donor=Image.new("RGBA",study.size,(0,0,0,0));dp=donor.load()
    for x,y in points:dp[x,y]=(*rgb[x,y],255)
    compact=donor.transform(donor.size,Image.Transform.AFFINE,(1/0.72,0,(1-1/0.72)*360,0,1,0),resample=Image.Resampling.BICUBIC)
    compact.putalpha(compact.getchannel("A").point(lambda a:255 if a>=96 else 0))
    donor_a=donor.getchannel("A").load()
    forearm=Image.open(BASE/"cyber_forearm.png").convert("RGBA").getchannel("A")
    forearm_a=forearm.load()
    overlap=sum(1 for y in range(h) for x in range(w) if donor_a[x,y]>=245 and forearm_a[x,y]>=245)
    union=bytearray(w*h)
    for y in range(h):
            for x in range(w): union[y*w+x]=1 if donor_a[x,y]>=245 or forearm_a[x,y]>=245 else 0
    union_components=components(union,w,h)
    if overlap==0 or len(union_components)!=1:
        raise AssertionError(f"Biological upper arm does not connect to mechanical elbow-start forearm: overlap={overlap}, components={len(union_components)}")
    manifest=json.loads((BASE/"pivot_manifest.json").read_text(encoding="utf-8"))
    def compose(add_donor:bool)->Image.Image:
        out=Image.new("RGBA",study.size,(0,0,0,0))
        if add_donor:out.alpha_composite(donor)
        for name in manifest["layers_back_to_front"]:out.alpha_composite(Image.open(BASE/f"{name}.png").convert("RGBA"))
        return out
    expected=Image.open(SOURCE).convert("RGBA");expected.putalpha(expected.getchannel("A").point(lambda a:255 if a>=245 else 0))
    actual=compose(True);actual.putalpha(actual.getchannel("A").point(lambda a:255 if a>=245 else 0))
    if ImageChops.difference(actual,expected).getbbox() is not None:raise AssertionError("Donor changed shell-on source composite")
    compact_scene=Image.new("RGBA",study.size,(0,0,0,0));compact_scene.alpha_composite(compact)
    for name in manifest["layers_back_to_front"]:compact_scene.alpha_composite(Image.open(BASE/f"{name}.png").convert("RGBA"))
    compact_scene.putalpha(compact_scene.getchannel("A").point(lambda a:255 if a>=245 else 0))
    if ImageChops.difference(compact_scene,expected).getbbox() is not None:raise AssertionError("Compact donor changed shell-on source composite")
    verify="--verify-existing" in sys.argv
    if OUTPUT.exists():
        if not verify:raise SystemExit(f"Refusing to overwrite existing donor: {OUTPUT}")
        if ImageChops.difference(Image.open(OUTPUT).convert("RGBA"),donor).getbbox() is not None:raise AssertionError("Existing donor differs from deterministic rebuild")
        print(f"PASS: existing candidate01 v2 donor matches deterministic build ({len(points)} pixels, {len(major)} connected component).")
    else:
        if verify:raise SystemExit("Requested verify-only but donor is absent")
        donor.save(OUTPUT,optimize=True)
        print(f"PASS: wrote candidate01 v2 donor ({len(points)} pixels, {len(major)} connected component).")
    if COMPACT_OUTPUT.exists():
        if not verify:raise SystemExit(f"Refusing to overwrite existing compact donor: {COMPACT_OUTPUT}")
        if ImageChops.difference(Image.open(COMPACT_OUTPUT).convert("RGBA"),compact).getbbox() is not None:raise AssertionError("Existing compact donor differs from deterministic rebuild")
        compact_a=compact.getchannel("A").load()
        print(f"PASS: existing candidate01 v3 compact donor matches deterministic build ({sum(1 for y in range(h) for x in range(w) if compact_a[x,y]>=245)} pixels).")
    else:
        if verify:raise SystemExit("Requested verify-only but compact donor is absent")
        compact.save(COMPACT_OUTPUT,optimize=True)
        print("PASS: wrote candidate01 v3 compact 72%-width donor.")
    c_a=compact.getchannel("A").load()
    compact_overlap=sum(1 for y in range(h) for x in range(w) if c_a[x,y]>=245 and forearm_a[x,y]>=245)
    compact_union=bytearray(w*h)
    for y in range(h):
        for x in range(w):compact_union[y*w+x]=1 if c_a[x,y]>=245 or forearm_a[x,y]>=245 else 0
    compact_components=components(compact_union,w,h)
    if compact_overlap==0 or len(compact_components)!=1:raise AssertionError(f"Compact donor does not connect at elbow: overlap={compact_overlap}, components={len(compact_components)}")
    print("PASS: candidate01 shell-on composite remains exact under the 245 alpha threshold.")
    print(f"PASS: upper-arm donor overlaps elbow-start mechanical forearm by {overlap} opaque pixels; their binary-alpha union is one connected component.")
    print(f"PASS: compact donor preserves shell-on pixels and overlaps the mechanical forearm by {compact_overlap} pixels; binary-alpha union is one component.")
    print("LIMIT: imagegen source and hand-traced boundary are review-only; no anatomical or production-art approval.")
if __name__=="__main__":main()
