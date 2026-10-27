"""Build a full-coverage hidden-surface hypothesis from the v13 shell-off study."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v13_compact_shoulder_donor"
BASE = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_09_canon_v4_manual_skin"
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_arm_extent_reconciliation_study_candidate_09.png"
OUTPUT = TRIAL / "hidden_biological_upper_arm_donor_v4_full_shell.png"


def main() -> None:
    if OUTPUT.exists():
        raise SystemExit(f"Refusing to overwrite existing review donor: {OUTPUT}")
    generated = Image.open(TRIAL / "shell_off_anatomy_study.png").convert("RGB")
    shell = Image.open(BASE / "cyber_shoulder_shell.png").convert("RGBA")
    canvas = Image.new("RGBA", generated.size, (0, 0, 0, 0))
    source_px, shell_px, canvas_px = generated.load(), shell.load(), canvas.load()
    selected = 0
    for y in range(generated.height):
        for x in range(generated.width):
            if shell_px[x, y][3] >= 245:
                canvas_px[x, y] = (*source_px[x, y], 255)
                selected += 1

    manifest = json.loads((BASE / "pivot_manifest.json").read_text(encoding="utf-8"))
    composed = Image.new("RGBA", generated.size, (0, 0, 0, 0))
    composed.alpha_composite(canvas)
    for name in manifest["layers_back_to_front"]:
        composed.alpha_composite(Image.open(BASE / f"{name}.png").convert("RGBA"))
    expected = Image.open(SOURCE).convert("RGBA")
    expected.putalpha(expected.getchannel("A").point(lambda a: 255 if a >= 245 else 0))
    if ImageChops.difference(composed, expected).getbbox() is not None:
        raise AssertionError("Full-shell donor changed the thresholded shell-on source image.")

    canvas.save(OUTPUT, optimize=True)
    (TRIAL / "v4_readiness.json").write_text(json.dumps({
        "status": "QUARANTINED COMPLETE-SHELL-MASK STUDY — NOT PRODUCTION ART",
        "extraction": "all generated pixels inside the complete opaque v4 shoulder-shell mask; no skin classifier",
        "pixels": selected,
        "exact_shell_on_composite": True,
        "limitation": "Full mask coverage supports shell-offset inspection but may reveal generated non-skin pixels; artistic surface review required.",
    }, indent=2) + "\n", encoding="utf-8")
    print(f"PASS: filled all {selected} opaque source shell-mask pixels from the quarantined v13 study.")
    print("PASS: thresholded shell-on reference composite remains exact.")
    print("LIMIT: shell coverage is mechanical evidence only; generated surface pixels are not canon or approved anatomy.")


if __name__ == "__main__":
    main()
