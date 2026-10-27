"""Widen the provisional upper arm into the torso's hidden shoulder socket.

Review-only builder. It preserves v7 and creates a separate v10 underlay whose
inner edge extends under the torso cutout for a continuous shoulder attachment.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01_candidate01_hidden_anatomy"
PARTS = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01"
SOURCE = TRIAL / "candidate01_upper_arm_constrained_painted_underlay_v7.png"
TORSO = PARTS / "torso.png"
OUTPUT = TRIAL / "candidate01_upper_arm_connected_underlay_v10.png"
OVERLAP_PX = 18


def attachment_factor(y: int) -> float:
    if y < 285 or y > 455:
        return 0.0
    if y < 315:
        return (y - 285) / 30.0
    if y <= 405:
        return 1.0
    return (455 - y) / 50.0


def main() -> None:
    if OUTPUT.exists():
        raise SystemExit(f"Refusing to overwrite existing review output: {OUTPUT}")
    arm = Image.open(SOURCE).convert("RGBA")
    torso = Image.open(TORSO).convert("RGBA")
    if arm.size != (1024, 1536) or torso.size != arm.size:
        raise AssertionError("Expected aligned 1024×1536 arm and torso layers")
    arm_alpha = arm.getchannel("A")
    torso_alpha = torso.getchannel("A")
    arm_px, torso_px = arm_alpha.load(), torso_alpha.load()
    result = Image.new("RGBA", arm.size, (0, 0, 0, 0))
    result_px = result.load()
    for y in range(arm.height):
        xs = [x for x in range(arm.width) if arm_px[x, y] >= 16]
        if not xs:
            continue
        left, right = min(xs), max(xs) + 1
        row = arm.crop((left, y, right, y + 1))
        factor = attachment_factor(y)
        torso_xs = [x for x in range(arm.width) if torso_px[x, y] >= 245]
        if factor > 0.0 and torso_xs:
            target_right = min(arm.width, min(torso_xs) + OVERLAP_PX)
            right = max(right, round(right + (target_right - right) * factor))
        else:
            right = max(right, left + 1)
        stretched = row.resize((right - left, 1), Image.Resampling.BICUBIC)
        result.alpha_composite(stretched, (left, y))
    overlap = sum(
        1
        for y in range(arm.height)
        for x in range(arm.width)
        if result.getpixel((x, y))[3] >= 245 and torso_px[x, y] >= 245
    )
    if overlap < 1000:
        raise AssertionError(f"Underarm still fails to overlap the torso socket: {overlap} pixels")
    result.save(OUTPUT, optimize=True)
    print(f"PASS: connected underlay overlaps the torso layer by {overlap} opaque pixels.")
    print("LIMIT: inferred shoulder attachment and stretched paint are provisional; review style, anatomy, and poses.")


if __name__ == "__main__":
    main()
