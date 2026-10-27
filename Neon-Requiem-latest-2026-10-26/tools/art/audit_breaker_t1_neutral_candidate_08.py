"""Static structural check for quarantined BREAKER candidate 08.

This does not determine artistic canon or hidden anatomy.
"""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
IMAGE=ROOT/"assets/characters/breaker/tier_01_drafts/BREAKER_T1_neutral_anatomy_review_candidate_08.png"
im=Image.open(IMAGE)
assert im.format=="PNG" and im.mode=="RGBA"
assert im.size==(1024,1536),im.size
a=im.getchannel("A")
assert all(a.getpixel(p)==0 for p in [(0,0),(1023,0),(0,1535),(1023,1535)])
solid=a.point(lambda v:255 if v>=245 else 0)
bounds=solid.getbbox(); assert bounds is not None
l,t,r,b=bounds; height=b-t
assert l>=20 and t>=20 and r<=1004 and b<=1516,bounds
assert 1400<=height<=1500,height
left=solid.crop((120,1200,460,1536)).getbbox()
right=solid.crop((600,1200,980,1536)).getbbox()
assert left and right,(left,right)
left_bottom=1200+left[3]-1; right_bottom=1200+right[3]-1
delta=abs(left_bottom-right_bottom)*256/height
assert delta<=6.0,delta
zero=sum(v==0 for v in a.get_flattened_data())
semi=sum(0<v<255 for v in a.get_flattened_data())
print(f"PASS: RGBA/corners/bounds={bounds}, visible_height={height}px, projected boot delta={delta:.2f}px/256px.")
print(f"INFO: transparent pixels={zero}; semi-transparent pixels={semi}. Low-alpha fringe is recorded for review, not treated as proof of clean production cutout.")
print("LIMIT: static pixels only; no hidden anatomy, authored pivots, rig, or motion verified.")
