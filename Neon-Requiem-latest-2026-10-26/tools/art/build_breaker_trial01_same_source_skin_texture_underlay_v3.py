from pathlib import Path
import base64

root = Path('.')
trial = root / 'assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy'
base_svg = (trial / 'candidate01_upper_arm_vector_underlay_v2.svg').read_text(encoding='utf-8')
donor = base64.b64encode((trial / 'candidate01_same_source_skin_upper_arm_underlay_v1.png').read_bytes()).decode('ascii')
layer = f'<image x="0" y="0" width="1024" height="1536" opacity="0.28" href="data:image/png;base64,{donor}"/>'
needle = '  </g>\n</svg>'
if needle not in base_svg:
    raise SystemExit('Could not find SVG texture insertion point')
updated = base_svg.replace(needle, f'    {layer}\n  </g>\n</svg>')
(trial / 'candidate01_upper_arm_same_source_skin_texture_underlay_v3.svg').write_text(updated, encoding='utf-8')
print('Wrote v3 SVG with the same-character skin texture at 28% opacity.')
