"""Add a narrow, source-hidden shoulder socket behind candidate01's vest.

This quarantined review study keeps v7's arm contour intact. It extends only
the inner/right edge toward the torso and clips the new pixels to existing
torso, skin, shell, and prosthesis coverage so the shell-on source is unchanged.
"""
from math import floor
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy"
PARTS = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01"
SOURCE = TRIAL / "candidate01_upper_arm_constrained_painted_underlay_v7.png"
TORSO = PARTS / "torso.png"
SHELL = TRIAL / "candidate01_external_shoulder_shell_v6_complement.png"
SKIN = TRIAL / "candidate01_biological_upper_arm_visible_v6_warm_pixels.png"
FOREARM = PARTS / "cyber_forearm.png"
OUTPUT = TRIAL / "candidate01_upper_arm_underarm_socket_v11.png"
ELBOW_Y = 495


def ramp(y: int) -> float:
    if y < 285 or y > 455:
        return 0.0
    t = (y - 285) / 30.0 if y < 315 else (455 - y) / 50.0 if y > 405 else 1.0
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def main() -> None:
    if OUTPUT.exists():
        raise SystemExit(f"Refusing to overwrite existing review output: {OUTPUT}")
    base = Image.open(SOURCE).convert("RGBA")
    torso = Image.open(TORSO).convert("RGBA")
    shell = Image.open(SHELL).convert("RGBA")
    skin = Image.open(SKIN).convert("RGBA")
    forearm = Image.open(FOREARM).convert("RGBA")
    if any(image.size != (1024, 1536) for image in (base, torso, shell, skin, forearm)):
        raise AssertionError("All review layers must share candidate01's 1024×1536 canvas")
    bp, tp, sp, kp, fp = (image.load() for image in (base, torso, shell, skin, forearm))
    output = base.copy()
    op = output.load()
    uncovered = 0
    added = 0
    for y in range(285, 456):
        existing = [x for x in range(1024) if bp[x, y][3] >= 16]
        torso_x = [x for x in range(1024) if tp[x, y][3] >= 245]
        if not existing or not torso_x:
            continue
        right = max(existing) + 1
        target = min(1023, min(torso_x) + 14)
        amount = int(round(max(0, target - right) * ramp(y)))
        if amount <= 0:
            continue
        # Continue the painted inner edge with a low-contrast texture sample
        # from the adjacent arm columns; preserve existing arm pixels exactly.
        edge_samples = [bp[max(min(existing) , right - offset - 1), y] for offset in range(4)]
        for dx in range(amount):
            x = right + dx
            covered = tp[x, y][3] >= 245 or sp[x, y][3] >= 245 or kp[x, y][3] >= 245 or (y >= ELBOW_Y and fp[x, y][3] >= 245) or (y < ELBOW_Y and fp[x, y][3] >= 245)
            if not covered:
                uncovered += 1
                continue
            # A short repeating edge sample avoids stretching the bicep's
            # internal muscle planes; a gentle shadow taper tucks it under vest.
            sample = edge_samples[min(3, floor(dx * 4 / max(1, amount)))]
            shade = 1.0 - 0.10 * (dx / max(1, amount))
            op[x, y] = (round(sample[0] * shade), round(sample[1] * shade), round(sample[2] * shade), min(255, sample[3]))
            added += 1
    if uncovered:
        raise AssertionError(f"Attachment exposed {uncovered} pixels in shell-on assembly")
    if added < 500:
        raise AssertionError(f"Attachment unexpectedly small: {added} pixels")
    output.save(OUTPUT, optimize=True)
    print(f"PASS: added {added} torso-hidden connector pixels; zero shell-on-exposed pixels.")
    print("LIMIT: underarm socket is inferred paint, not canon or production art; inspect shape and seams.")


if __name__ == "__main__":
    main()
