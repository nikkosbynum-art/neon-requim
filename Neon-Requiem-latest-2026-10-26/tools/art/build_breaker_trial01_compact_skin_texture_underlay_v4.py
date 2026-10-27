from pathlib import Path
import base64
root=Path('.')
trial=root/'assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy'
base=(trial/'candidate01_upper_arm_vector_underlay_v2.svg').read_text(encoding='utf-8')
base=base.replace('  </defs>\n', '  </defs>\n  <g transform="translate(57.6 0) scale(0.84 1)">\n', 1)
donor=base64.b64encode((trial/'candidate01_same_source_skin_upper_arm_underlay_v1.png').read_bytes()).decode('ascii')
layer=f'<image x="0" y="0" width="1024" height="1536" opacity="0.08" href="data:image/png;base64,{donor}"/>'
needle='  </g>\n</svg>'
if needle not in base: raise SystemExit('SVG group boundary not found')
base=base.replace(needle, f'    {layer}\n  </g>\n  </g>\n</svg>')
(trial/'candidate01_upper_arm_compact_skin_texture_underlay_v4.svg').write_text(base,encoding='utf-8')
print('Rebuilt v4 with a valid outer transform group around the complete underlay.')
