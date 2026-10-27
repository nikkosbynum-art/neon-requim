from pathlib import Path
from PIL import Image
root=Path('assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy')
base=Image.open(root/'candidate01_upper_arm_vector_base_v2.png').convert('RGBA')
donor=Image.open(root/'generated_upper_arm_texture_source_v1.png').convert('RGBA')
base_a=base.getchannel('A'); donor_a=donor.getchannel('A')
bx0,by0,bx1,by1=base_a.getbbox(); dx0,dy0,dx1,dy1=donor_a.getbbox()
out=base.copy(); bp=base.load(); ap=base_a.load(); da=donor_a.load(); dp=donor.load(); op=out.load()
for y in range(by0,by1):
    bx=[x for x in range(bx0,bx1) if ap[x,y]>32]
    if not bx: continue
    yn=(y-by0)/max(1,by1-by0-1); sy=round(dy0+yn*(dy1-dy0-1))
    dx=[x for x in range(dx0,dx1) if da[x,sy]>128]
    if len(dx)<4: continue
    trim=max(1,round(len(dx)*0.12)); dx=dx[trim:-trim] if len(dx)>2*trim else dx
    for x in bx:
        xn=(x-bx[0])/max(1,bx[-1]-bx[0]); sx=round(dx[0]+xn*(dx[-1]-dx[0]))
        old=bp[x,y]; tex=dp[sx,sy]
        op[x,y]=(round(old[0]*.86+tex[0]*.14),round(old[1]*.86+tex[1]*.14),round(old[2]*.86+tex[2]*.14),ap[x,y])
out.save(root/'candidate01_upper_arm_generated_texture_underlay_v5.png')
print('Wrote v5, donor bbox', (dx0,dy0,dx1,dy1), 'arm bbox', (bx0,by0,bx1,by1))
