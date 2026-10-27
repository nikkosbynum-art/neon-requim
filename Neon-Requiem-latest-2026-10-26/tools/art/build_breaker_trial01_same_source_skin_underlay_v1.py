from PIL import Image, ImageFilter
from pathlib import Path

root = Path('.')
src = Image.open(root / 'assets/characters/breaker/tier_01_drafts/BREAKER_T1_profile_rebuild_candidate_01.png').convert('RGBA')
# Candidate01's own exposed upper-arm skin, on the non-cybernetic arm.
roi = (590, 330, 638, 457)
crop = src.crop(roi)
pix = crop.load()
mask = Image.new('L', crop.size, 0)
mp = mask.load()
for y in range(crop.height):
    for x in range(crop.width):
        r, g, b, a = pix[x, y]
        # Keep warm skin-colored source pixels only; exclude the dark outline, vest, trim and background.
        if a > 0 and r > 95 and g > 38 and b > 20 and r > g * 1.10 and r > b * 1.28 and g > b * 1.06:
            mp[x, y] = 255
# Soften only the extracted antialiased edge, preserving source texture.
mask = mask.filter(ImageFilter.GaussianBlur(0.55))
donor = crop.copy()
donor.putalpha(mask)
# Fit the same-character skin texture to a narrow, elongated upper-arm hypothesis.
# The x scale is deliberately restrained relative to prior bulky generated trials.
scaled = donor.resize((66, 205), Image.Resampling.LANCZOS)
out = Image.new('RGBA', (1024, 1536), (0, 0, 0, 0))
# Center the donor under the shoulder shell, with its lower edge overlapping the elbow start.
x = 367 - scaled.width // 2
y = 302
out.alpha_composite(scaled, (x, y))
path = root / 'assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy/candidate01_same_source_skin_upper_arm_underlay_v1.png'
out.save(path)
# Human-readable cropped source donor for review.
preview_bg = Image.new('RGBA', crop.size, (42, 45, 52, 255))
preview_bg.alpha_composite(donor)
preview_bg.resize((crop.width * 8, crop.height * 8), Image.Resampling.LANCZOS).convert('RGB').save(root / 'docs/visual_qa/BREAKER_T1_candidate01_same_source_skin_donor_mask_v1.png')
print(f'Wrote {path}; donor alpha bbox={mask.getbbox()}, target alpha bbox={out.getchannel("A").getbbox()}')


