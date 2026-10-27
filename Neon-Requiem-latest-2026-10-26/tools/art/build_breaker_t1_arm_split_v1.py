"""Split BREAKER trial-05's visible upper-arm composite into two exact layers.

The skin layer contains only visible warm-skin pixels already present in the
flattened source. It does not fabricate a complete hidden arm under the shell.
"""
from __future__ import annotations

import json
from hashlib import sha256
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
TRIAL = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_guarded_pose_v8"
SOURCE_DRAFT = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_guarded_pose_review_candidate_05.png"
SOURCE_META = SOURCE_DRAFT.with_suffix(".json")
OUTPUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_05_arm_split_v1"
QA = ROOT / "docs/visual_qa/BREAKER_T1_trial05_v8_arm_split_neutral_compare.png"


def is_skin_color(r: int, g: int, b: int) -> bool:
    return r >= 110 and g >= 55 and b >= 35 and r > g * 1.10 and g > b * 1.10 and r - g > 12


def main() -> None:
    source_hash = sha256(SOURCE_DRAFT.read_bytes()).hexdigest().upper()
    source_meta = json.loads(SOURCE_META.read_text(encoding="utf-8"))
    assert source_hash == source_meta["sha256"].upper()
    upper_arm = Image.open(TRIAL / "cyber_upper_arm.png").convert("RGBA")
    assert upper_arm.size == (1024, 1536)

    original = upper_arm.tobytes()
    skin_bytes = bytearray(len(original))
    shell_bytes = bytearray(len(original))
    skin_pixels = 0
    shell_pixels = 0
    for index in range(upper_arm.width * upper_arm.height):
        offset = index * 4
        r, g, b, a = original[offset : offset + 4]
        if a == 0:
            continue
        target = skin_bytes if is_skin_color(r, g, b) else shell_bytes
        target[offset : offset + 4] = original[offset : offset + 4]
        if target is skin_bytes:
            skin_pixels += 1
        else:
            shell_pixels += 1
    assert skin_pixels > 3000 and shell_pixels > 10000

    OUTPUT.mkdir(parents=True, exist_ok=True)
    skin_path = OUTPUT / "visible_human_upper_arm_surface.png"
    shell_path = OUTPUT / "external_shoulder_shell.png"
    skin = Image.frombytes("RGBA", upper_arm.size, bytes(skin_bytes))
    shell = Image.frombytes("RGBA", upper_arm.size, bytes(shell_bytes))
    skin.save(skin_path)
    shell.save(shell_path)

    rebuilt = Image.new("RGBA", upper_arm.size, (0, 0, 0, 0))
    rebuilt.alpha_composite(skin)
    rebuilt.alpha_composite(shell)
    original_data = upper_arm.tobytes()
    rebuilt_data = rebuilt.tobytes()
    diff_pixels = 0
    for offset in range(0, len(original_data), 4):
        if original_data[offset + 3] > 0 and original_data[offset : offset + 4] != rebuilt_data[offset : offset + 4]:
            diff_pixels += 1
        elif original_data[offset + 3] == 0 and rebuilt_data[offset + 3] != 0:
            diff_pixels += 1
    assert diff_pixels == 0, diff_pixels

    manifest = {
        "status": "QUARANTINED ART FEASIBILITY SPLIT — NOT PRODUCTION ART / NOT RUNTIME",
        "canon_decision": "2026-10-25 user-approved: external shoulder shell over biological upper arm; mechanical prosthesis begins at elbow",
        "source_draft": source_meta["file"],
        "source_draft_sha256": source_hash,
        "source_layer": "profile_rig_trial_05_guarded_pose_v8/cyber_upper_arm.png",
        "canvas_px": [1024, 1536],
        "components": {
            "visible_human_upper_arm_surface.png": {
                "role": "visible source skin-tone pixels only",
                "pixel_count": skin_pixels,
                "hidden_anatomy": "not included; remains inferred/unknown",
            },
            "external_shoulder_shell.png": {
                "role": "remaining visible shoulder/upper-arm hardware and outlines",
                "pixel_count": shell_pixels,
            },
        },
        "neutral_reconstruction": {"different_pixels": diff_pixels, "result": "exact source-layer pixel reconstruction"},
        "classification": "warm RGB heuristic applied only inside the original cyber_upper_arm mask; no pixels synthesized",
        "limitations": [
            "The input is a flattened generated concept, not authored source anatomy.",
            "The visible skin surface is a mask split, not a complete independent arm drawing.",
            "Surfaces hidden beneath the shell remain absent/inferred.",
            "No animation or deformation test is part of this build step.",
            "Keep all outputs quarantined until the production-art gate passes.",
        ],
        "sha256": {
            skin_path.name: sha256(skin_path.read_bytes()).hexdigest(),
            shell_path.name: sha256(shell_path.read_bytes()).hexdigest(),
        },
    }
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUTPUT / "README.md").write_text(
        "# BREAKER Tier I arm split — feasibility v1\n\n"
        "**Quarantined; not production art or runtime content.** This split separates visible warm-skin pixels from the shoulder/upper-arm hardware in the existing flattened candidate 05 upper-arm composite. The skin layer is only the visible source surface, not a complete hidden anatomical arm.\n\n"
        "The 2026-10-25 user-approved reading is external shoulder armor over a human upper arm, with the mechanical prosthesis beginning at the elbow. This data split tests that presentation reading without generating or claiming the missing anatomy.\n\n"
        "Run `python tools/art/build_breaker_t1_arm_split_v1.py` to regenerate. It asserts provenance and exact neutral pixel reconstruction. Godot round-trip validation is in `tests/test_breaker_trial05_v8_arm_split_v1.gd`.\n",
        encoding="utf-8",
    )
    make_qa_board(upper_arm, skin, shell, diff_pixels, skin_pixels, shell_pixels)
    print(f"PASS: source split into {skin_pixels} visible skin pixels and {shell_pixels} shell/hardware pixels; layers are disjoint by construction.")
    print(f"PASS: exact neutral reconstruction; differing pixels={diff_pixels}.")
    print(f"PASS: wrote {OUTPUT.relative_to(ROOT).as_posix()} and {QA.relative_to(ROOT).as_posix()}.")
    print("LIMIT: hidden anatomy, rig seams, motion, and production readiness are not asserted.")


def make_qa_board(source: Image.Image, skin: Image.Image, shell: Image.Image, diff: int, skin_count: int, shell_count: int) -> None:
    width, height = 1280, 560
    panel_w = 390
    canvas = Image.new("RGB", (width, height), (18, 22, 28))
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()
    parts = [("ORIGINAL COMPOSITE", source), ("SKIN SURFACE", skin), ("SHELL + REBUILT", shell)]
    bounds = source.getchannel("A").getbbox()
    assert bounds is not None
    crop_box = (max(0, bounds[0] - 24), max(0, bounds[1] - 24), min(source.width, bounds[2] + 24), min(source.height, bounds[3] + 24))
    crop_size = (crop_box[2] - crop_box[0], crop_box[3] - crop_box[1])
    scale = min((panel_w - 28) / crop_size[0], (height - 78) / crop_size[1])
    size = (round(crop_size[0] * scale), round(crop_size[1] * scale))
    for index, (label, part) in enumerate(parts):
        x = 24 + index * 416
        draw.text((x, 18), label, font=font, fill=(236, 240, 244))
        bg = Image.new("RGBA", size, (38, 43, 50, 255))
        if index == 2:
            skin_crop = skin.crop(crop_box).resize(size, Image.Resampling.LANCZOS)
            shell_crop = shell.crop(crop_box).resize(size, Image.Resampling.LANCZOS)
            bg.alpha_composite(skin_crop)
            bg.alpha_composite(shell_crop)
        else:
            bg.alpha_composite(part.crop(crop_box).resize(size, Image.Resampling.LANCZOS))
        canvas.paste(bg.convert("RGB"), (x, 44))
    draw.text((24, height - 20), f"Heuristic skin pixels={skin_count}; shell/hardware pixels={shell_count}; exact source reconstruction diff={diff}.", font=font, fill=(160, 225, 230))
    QA.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(QA)


if __name__ == "__main__":
    main()
