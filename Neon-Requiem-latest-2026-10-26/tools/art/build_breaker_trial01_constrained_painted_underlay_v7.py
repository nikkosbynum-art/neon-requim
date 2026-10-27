from pathlib import Path
from PIL import Image
root=Path('assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy')
base=Image.open(root/'candidate01_upper_arm_vector_base_v2.png').convert('RGBA')
source=Image.open(root/'generated_upper_arm_texture_source_v1.png').convert('RGBA')
alpha=base.getchannel('A')
bbox=alpha.getbbox(); mask=alpha.crop(bbox)
w,h=mask.size
compact_w=round(w*0.84)
mask=mask.resize((compact_w,h),Image.Resampling.LANCZOS)
src_alpha=source.getchannel('A'); src_box=src_alpha.getbbox()
arm=source.crop(src_box).resize((compact_w,h),Image.Resampling.LANCZOS)
# Use generated paint at 72%, retaining the hand-authored source-palette shading at 28%.
base_crop=base.crop(bbox).resize((compact_w,h),Image.Resampling.LANCZOS)
result=Image.new('RGBA',(1024,1536),(0,0,0,0))
x=bbox[0]+(w-compact_w)//2; y=bbox[1]
mask_px=mask.load(); ap=arm.load(); bp=base_crop.load(); out=result.load()
for yy in range(h):
 for xx in range(compact_w):
  a=mask_px[xx,yy]
  if a<8: continue
  g=ap[xx,yy]; b=bp[xx,yy]
  out[x+xx,y+yy]=(round(g[0]*.72+b[0]*.28),round(g[1]*.72+b[1]*.28),round(g[2]*.72+b[2]*.28),a)
path=root/'candidate01_upper_arm_constrained_painted_underlay_v7.png'
result.save(path)
print('Wrote v7: generated painted arm fitted to compact mask', (x,y,x+compact_w,y+h), 'donor source', src_box)
