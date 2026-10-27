"""Build v13 v5 full shell-mask donor from the quarantined correction study."""
from __future__ import annotations
import json
from pathlib import Path
from PIL import Image, ImageChops
ROOT=Path(__file__).resolve().parents[2]
TRIAL=ROOT/"assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor"
BASE=ROOT/"assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_manual_skin"
SOURCE=ROOT/"assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
OUTPUT=TRIAL/"hidden_biological_upper_arm_donor_v5_full_shell.png"
def main()->None:
    verify_only = "--verify-existing" in __import__("sys").argv
    generated=Image.open(TRIAL/"shell_off_anatomy_study_v2.png").convert("RGB")
    shell=Image.open(BASE/"cyber_shoulder_shell.png").convert("RGBA")
    if generated.size != shell.size or generated.size != (1024,1536): raise AssertionError("Unexpected canvas size")
    donor=Image.new("RGBA",generated.size,(0,0,0,0)); src=generated.load(); mask=shell.load(); dst=donor.load(); selected=0
    for y in range(generated.height):
        for x in range(generated.width):
            if mask[x,y][3]>=245: dst[x,y]=(*src[x,y],255); selected+=1
    manifest=json.loads((BASE/"pivot_manifest.json").read_text(encoding="utf-8"))
    assembled=Image.new("RGBA",generated.size,(0,0,0,0)); assembled.alpha_composite(donor)
    for name in manifest["layers_back_to_front"]: assembled.alpha_composite(Image.open(BASE/f"{name}.png").convert("RGBA"))
    expected=Image.open(SOURCE).convert("RGBA"); expected.putalpha(expected.getchannel("A").point(lambda a:255 if a>=245 else 0))
    if ImageChops.difference(assembled,expected).getbbox() is not None: raise AssertionError("Shell-on composite changed")
    if OUTPUT.exists():
        if not verify_only: raise SystemExit(f"Refusing to overwrite existing review donor: {OUTPUT}")
        existing=Image.open(OUTPUT).convert("RGBA")
        if ImageChops.difference(existing,donor).getbbox() is not None: raise AssertionError("Existing v5 donor differs from deterministic rebuild")
        print(f"PASS: existing v5 donor matches deterministic rebuild ({selected} opaque shell-mask pixels).")
    else:
        if verify_only: raise SystemExit("--verify-existing requested but v5 donor is missing")
        donor.save(OUTPUT,optimize=True)
        (TRIAL/"v5_readiness.json").write_text(json.dumps({"status":"QUARANTINED GENERATED CORRECTION STUDY — NOT PRODUCTION ART","source":"shell_off_anatomy_study_v2.png","extraction":"all generated pixels inside complete opaque v4 shoulder-shell mask","pixels":selected,"exact_shell_on_composite":True,"limitation":"Shell-off shoulder remains oversized relative to approved character art; visual review required."},indent=2)+"\n",encoding="utf-8")
        print(f"PASS: wrote v5 donor with {selected} opaque shell-mask pixels; thresholded shell-on composite is exact.")
    print("LIMIT: does not verify anatomy, visual acceptance, or production readiness.")
if __name__=="__main__": main()
