"""Build quarantined BREAKER candidate01 elbow-boundary fit studies.

This script never edits approved artwork or runtime assets. It preserves the
source shell-on image, creates independent shell/forearm partitions, and emits
slim/broad generated-underarm hypotheses for review only.
"""
from __future__ import annotations
from collections import deque
from pathlib import Path
import json, math, sys
from PIL import Image, ImageChops

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'assets/characters/breaker/tier_01_drafts/profile_rig_trial_01'
TRIAL=ROOT/'assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy'
SOURCE=ROOT/'assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png'
RAW=TRIAL/'isolated_upper_arm_generated_fit_study.png'
VISIBLE_SKIN=TRIAL/'candidate01_biological_upper_arm_visible_v4.png'
UPPER_SHELL=TRIAL/'candidate01_external_shoulder_shell_v4.png'
ELBOW_Y=495  # provisional source pivot from pivot_manifest.json, not canon
SRC_TOP=(459.5,0.0)  # coordinates in crop y=172..950
SRC_BOTTOM=(521.0,778.0)
DST_TOP=(375.0,278.0)
DST_BOTTOM=(345.0,515.0)
CROP_TOP=172
CROP_BOTTOM=950
VARIANTS={'slim':0.20,'broad':0.28}

def comps(mask:bytearray,w:int,h:int)->list[list[int]]:
    seen=bytearray(w*h); out=[]
    for i,v in enumerate(mask):
        if not v or seen[i]:continue
        q=deque([i]);seen[i]=1;group=[]
        while q:
            j=q.popleft();group.append(j);x=j%w;y=j//w
            for ny in range(max(0,y-1),min(h,y+2)):
                for nx in range(max(0,x-1),min(w,x+2)):
                    k=ny*w+nx
                    if mask[k] and not seen[k]:seen[k]=1;q.append(k)
        out.append(group)
    return sorted(out,key=len,reverse=True)

def mask_rows(size, y_split, above):
    m=Image.new('L',size,0);p=m.load()
    for y in range(size[1]):
        if (y<y_split)==above:
            for x in range(size[0]):p[x,y]=255
    return m

def make_underlay(raw, cover, width_scale):
    part=raw.crop((0,CROP_TOP,1024,CROP_BOTTOM))
    dx0=SRC_BOTTOM[0]-SRC_TOP[0];dy0=SRC_BOTTOM[1]-SRC_TOP[1]
    dx=dx0*width_scale; target_dx=DST_BOTTOM[0]-DST_TOP[0];target_dy=DST_BOTTOM[1]-DST_TOP[1]
    target_length=math.hypot(target_dx,target_dy)
    sy=math.sqrt(max(0.0,target_length**2-dx**2))/dy0
    angle=math.atan2(target_dy,target_dx)-math.atan2(sy*dy0,dx)
    co=math.cos(angle);si=math.sin(angle)
    mapped_dx=dx*co-sy*dy0*si
    mapped_dy=dx*si+sy*dy0*co
    if math.hypot(DST_TOP[0]+mapped_dx-DST_BOTTOM[0],DST_TOP[1]+mapped_dy-DST_BOTTOM[1])>0.05:
        raise AssertionError('Affine fit does not land on the approved elbow pivot.')
    # PIL destination-to-source affine for x' = R(angle) * S(sx,sy) * (p-src_anchor) + dst_anchor.
    a=co/width_scale;b=si/width_scale;d=-si/sy;e=co/sy
    c=SRC_TOP[0]-(DST_TOP[0]*co+DST_TOP[1]*si)/width_scale
    f=SRC_TOP[1]-(-DST_TOP[0]*si+DST_TOP[1]*co)/sy
    out=part.transform((1024,1536),Image.Transform.AFFINE,(a,b,c,d,e,f),resample=Image.Resampling.BICUBIC)
    out.putalpha(ImageChops.multiply(out.getchannel('A'),cover))
    return out,sy,angle

def main():
    verify='--verify-existing' in sys.argv
    raw=Image.open(RAW).convert('RGBA'); skin=Image.open(VISIBLE_SKIN).convert('RGBA'); shell=Image.open(UPPER_SHELL).convert('RGBA')
    fore=Image.open(BASE/'cyber_forearm.png').convert('RGBA'); upper=Image.open(BASE/'cyber_upper_arm.png').convert('RGBA')
    source=Image.open(SOURCE).convert('RGBA'); manifest=json.loads((BASE/'pivot_manifest.json').read_text(encoding='utf-8'));names=manifest['layers_back_to_front']
    if raw.size!=(1024,1536) or skin.size!=raw.size or fore.size!=raw.size or upper.size!=raw.size:raise AssertionError('Unexpected candidate01 art canvas.')
    upper_overlap=fore.copy(); upper_overlap.putalpha(ImageChops.multiply(fore.getchannel('A'),mask_rows(raw.size,ELBOW_Y,True)))
    forearm=fore.copy(); forearm.putalpha(ImageChops.multiply(fore.getchannel('A'),mask_rows(raw.size,ELBOW_Y,False)))
    if ImageChops.difference(Image.alpha_composite(upper_overlap,forearm),fore).getbbox() is not None:raise AssertionError('Forearm partition does not reconstruct source layer.')
    cover=ImageChops.lighter(upper.getchannel('A'),fore.getchannel('A')).point(lambda v:255 if v>=245 else 0)
    parts={n:Image.open(BASE/f'{n}.png').convert('RGBA') for n in names}
    expected=source.copy();expected.putalpha(expected.getchannel('A').point(lambda v:255 if v>=245 else 0))
    for name,sx in VARIANTS.items():
        donor,sy,angle=make_underlay(raw,cover,sx);out_path=TRIAL/f'candidate01_fitted_underarm_{name}_affinefix_v2_review.png'
        on=Image.new('RGBA',raw.size,(0,0,0,0));on.alpha_composite(donor)
        for layer in names:
            if layer=='cyber_upper_arm':on.alpha_composite(shell);on.alpha_composite(skin)
            elif layer=='cyber_forearm':on.alpha_composite(upper_overlap);on.alpha_composite(forearm)
            else:on.alpha_composite(parts[layer])
        on.putalpha(on.getchannel('A').point(lambda v:255 if v>=245 else 0))
        if ImageChops.difference(on,expected).getbbox() is not None:raise AssertionError(f'{name}: fitted donor changed shell-on source.')
        da=donor.getchannel('A').load();fa=forearm.getchannel('A').load();overlap=sum(1 for y in range(1536) for x in range(1024) if da[x,y]>=245 and fa[x,y]>=245)
        union=bytearray(1024*1536)
        for y in range(1536):
            for x in range(1024):union[y*1024+x]=int(da[x,y]>=245 or fa[x,y]>=245)
        components=comps(union,1024,1536)
        if overlap==0 or len(components)!=1:raise AssertionError(f'{name}: upper arm does not connect at elbow (overlap={overlap}, components={len(components)}).')
        if out_path.exists():
            if not verify:raise SystemExit(f'Refusing to overwrite existing output: {out_path}')
            if ImageChops.difference(Image.open(out_path).convert('RGBA'),donor).getbbox() is not None:raise AssertionError(f'{name}: existing donor differs from deterministic output.')
        else:
            if verify:raise SystemExit(f'Expected existing output: {out_path}')
            donor.save(out_path,optimize=True)
        print(f'PASS {name}: exact shell-on reconstruction; {sum(1 for a in donor.getchannel("A").get_flattened_data() if a>=245)} donor pixels; {overlap} elbow-overlap pixels; connected union; x-scale={sx:.3f}, y-scale={sy:.4f}, rotation={math.degrees(angle):.2f}deg.')
    print('LIMIT: generated skin texture and inferred anatomy are quarantined review studies; pixel/pose checks do not establish artistic or anatomical acceptance.')
if __name__=='__main__':main()



