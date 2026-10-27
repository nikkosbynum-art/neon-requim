from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
D=ROOT/'assets/characters/breaker/tier_01_drafts'
out=ROOT/'docs/visual_qa/BREAKER_T1_candidate_08_neutral_anatomy_comparison.png'
items=[
(D/'BREAKER_T1_guarded_pose_review_candidate_01.png','APPROVED PROFILE DRAFT 01\nshoulder extent remains source conflict'),
(D/'BREAKER_T1_tier1_canon_review_candidate_07.png','CANDIDATE 07\nguarded; written forearm-only reading'),
(D/'BREAKER_T1_neutral_anatomy_review_candidate_08.png','CANDIDATE 08\nneutral anatomy review; same arm reading'),
]
panel_w,panel_h=440,390; target_h=256; ground_y=345
canvas=Image.new('RGBA',(panel_w*len(items),panel_h),'#11161c'); draw=ImageDraw.Draw(canvas); font=ImageFont.load_default()
for i,(path,label) in enumerate(items):
 src=Image.open(path).convert('RGBA'); mask=src.getchannel('A').point(lambda a:255 if a>=245 else 0); bounds=mask.getbbox(); assert bounds
 fig=src.crop(bounds); scale=target_h/fig.height; fig=fig.resize((round(fig.width*scale),target_h),Image.Resampling.LANCZOS)
 x=i*panel_w+(panel_w-fig.width)//2; y=ground_y-target_h
 canvas.alpha_composite(fig,(x,y)); draw.multiline_text((i*panel_w+14,16),label,fill='#f1d5a0',font=font,spacing=3)
 draw.line((i*panel_w+20,ground_y,(i+1)*panel_w-20,ground_y),fill='#57dce3',width=2)
 draw.text((i*panel_w+14,panel_h-20),'256 px visible height • shared ground baseline',fill='#aab8c7',font=font)
canvas.convert('RGB').save(out)
print(out)
