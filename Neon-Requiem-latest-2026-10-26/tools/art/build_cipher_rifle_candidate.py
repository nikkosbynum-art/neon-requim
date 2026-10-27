#!/usr/bin/env python3
"""Draw a quarantined, editable high-contrast rifle attachment for CIPHER's rig."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01/CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png"
S = 3
im = Image.new("RGBA", (420*S, 150*S), (0, 0, 0, 0))
d = ImageDraw.Draw(im)
def poly(points, fill, outline=(11, 13, 18, 255), width=4):
    ps = [(int(x*S), int(y*S)) for x,y in points]
    d.polygon(ps, fill=fill)
    d.line(ps + [ps[0]], fill=outline, width=width*S, joint="curve")
def line(points, fill, width=3):
    d.line([(int(x*S),int(y*S)) for x,y in points], fill=fill, width=width*S, joint="curve")
# Suppressed precision rifle: stock at left, muzzle at right; restrained faction accents.
poly([(20,57),(74,48),(110,52),(134,60),(354,60),(387,65),(405,72),(387,80),(345,84),(147,84),(127,96),(94,98),(77,82),(27,79)], (37,42,51,255))
poly([(60,57),(99,54),(124,63),(126,82),(99,87),(79,78)], (57,64,75,255))
poly([(110,58),(333,58),(350,63),(348,79),(126,82)], (48,54,64,255))
poly([(173,82),(212,82),(206,122),(194,130),(180,126)], (31,36,45,255))
poly([(184,120),(205,120),(209,132),(181,132)], (63,69,79,255))
poly([(145,50),(204,50),(213,60),(147,62)], (52,59,70,255))
poly([(154,37),(214,37),(218,51),(155,51)], (26,30,38,255))
poly([(165,39),(200,39),(204,47),(162,47)], (77,83,93,255))
poly([(340,64),(389,66),(396,71),(388,76),(342,77)], (72,78,88,255))
# Cyan optic lens, magenta power strip, crimson rail marks.
poly([(168,42),(196,42),(199,46),(168,46)], (28,176,206,255), outline=(5,28,38,255), width=2)
line([(223,59),(253,59)], (225,36,89,255), 4)
line([(286,82),(311,82)], (35,194,215,255), 4)
line([(34,60),(65,58)], (230,39,111,255), 3)
for x,y in [(83,64),(137,67),(320,69),(368,71)]:
    d.ellipse((x*S-2*S,y*S-2*S,x*S+2*S,y*S+2*S),fill=(169,179,190,255))
# Edge highlight and segmented barrel lines.
line([(76,53),(118,56),(136,63),(330,63)], (105,115,128,230), 2)
line([(18,82),(74,86),(95,94)], (83,91,103,230), 2)
im=im.resize((420,150),Image.Resampling.LANCZOS)
im=ImageOps.expand(im,border=60,fill=(0,0,0,0))
OUT.parent.mkdir(parents=True,exist_ok=True)
im.save(OUT)
