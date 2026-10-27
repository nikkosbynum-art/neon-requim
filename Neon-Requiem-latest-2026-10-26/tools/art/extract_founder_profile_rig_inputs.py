#!/usr/bin/env python3
"""Extract visible side-profile crops as quarantined mesh-rig inputs.

These are not semantic body-part cutouts. Each image remains a single flattened
reference profile with only the connected neutral board background removed.
"""

from __future__ import annotations

import json
from collections import deque
from pathlib import Path
import re

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[2]
OUT_ROOT = ROOT / "assets/characters"
PAD = 128

# Dominant right-facing side-profile component bounds measured from each
# approved anatomy turnaround (x0, y0, x1, y1), before safety padding.
SOURCES = {
    "bulwark": ((603, 33, 959, 967), "BULWARK"),
    "spark": ((530, 20, 793, 960), "SPARK"),
    "specter": ((600, 23, 893, 962), "SPECTER"),
    "ironclad": ((593, 17, 894, 943), "IRONCLAD"),
    "stitch": ((615, 19, 905, 976), "STITCH"),
    "recoil": ((647, 22, 915, 941), "RECOIL"),
    "echo": ((591, 29, 899, 969), "ECHO"),
    "vector": ((653, 22, 900, 963), "VECTOR"),
    "deadlock": ((631, 24, 955, 963), "DEADLOCK"),
    "glitch": ((639, 18, 899, 965), "GLITCH"),
}


def is_board(rgb: tuple[int, int, int]) -> bool:
    r, g, b = rgb
    return max(r, g, b) - min(r, g, b) < 24 and min(r, g, b) > 155


def remove_exterior_board(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    px = rgba.load()
    width, height = rgba.size
    seen = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def add(x: int, y: int) -> None:
        i = y * width + x
        if not seen[i] and is_board(px[x, y][:3]):
            seen[i] = 1
            queue.append((x, y))

    for x in range(width):
        add(x, 0)
        add(x, height - 1)
    for y in range(height):
        add(0, y)
        add(width - 1, y)
    while queue:
        x, y = queue.popleft()
        if x > 0:
            add(x - 1, y)
        if x + 1 < width:
            add(x + 1, y)
        if y > 0:
            add(x, y - 1)
        if y + 1 < height:
            add(x, y + 1)

    alpha = Image.new("L", (width, height), 255)
    ap = alpha.load()
    for y in range(height):
        offset = y * width
        for x in range(width):
            if seen[offset + x]:
                ap[x, y] = 0
    rgba.putalpha(alpha)
    return rgba


def build() -> None:
    rig_script = (ROOT / "tests/art/founding_t1_profile_mesh_rig_candidate.gd").read_text(encoding="utf-8")
    joint_block = re.search(r"const JOINTS := (\{.*?\})\n\nvar character_id", rig_script, re.DOTALL)
    if joint_block is None:
        raise RuntimeError("Could not read character landmark block from the rig candidate script")
    json_landmarks = re.sub(r"(?<=[{,])\s*([A-Za-z_][A-Za-z0-9_]*):", r' "\1":', joint_block.group(1))
    json_landmarks = re.sub(r",\s*([}\]])", r"\1", json_landmarks)
    landmarks_by_id = json.loads(json_landmarks)
    for character, (bounds, display_name) in SOURCES.items():
        source_path = ROOT / "docs/visual_qa" / f"{display_name}_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
        x0, y0, x1, y1 = bounds
        crop_box = (max(0, x0 - 24), max(0, y0 - 12), min(1536, x1 + 24), min(1024, y1 + 12))
        image = remove_exterior_board(Image.open(source_path).crop(crop_box))
        image = ImageOps.expand(image, border=PAD, fill=(0, 0, 0, 0))
        destination = OUT_ROOT / character / "tier_01_drafts" / "profile_mesh_rig_candidate_01"
        destination.mkdir(parents=True, exist_ok=True)
        filename = f"{display_name}_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png"
        image.save(destination / filename)
        alpha_bbox = image.getchannel("A").point(lambda v: 255 if v >= 32 else 0).getbbox()
        manifest = {
            "character": display_name,
            "status": "QUARANTINED VISIBLE-PROFILE MESH-RIG CANDIDATE",
            "art_scope": "single flattened right-facing profile; no semantic part separation",
            "source": f"docs/visual_qa/{display_name}_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
            "source_view_bounds_xyxy": list(bounds),
            "source_crop_xyxy": list(crop_box),
            "candidate_image": filename,
            "candidate_image_size_px": list(image.size),
            "alpha32_bounds_xyxy": list(alpha_bbox) if alpha_bbox else None,
            "transparent_safety_border_px": PAD,
            "provisional_bone_landmarks": "approximate source-canvas points; see rig_manifest.json; pivots not artist-authored",
            "unresolved": [
                "semantic body-part boundaries", "concealed anatomy and underpaint", "authored pivots",
                "far-side anatomy", "detached accessory ownership", "continuous deformation and production readiness"
            ],
            "runtime_approved": False,
        }
        (destination / "parts_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        rig_manifest = {
            "character": display_name,
            "status": "QUARANTINED PROFILE-MESH RIG CANDIDATE",
            "source_profile": filename,
            "rig_type": "single flattened visible-profile texture on Polygon2D contour meshes",
            "mesh_generation": "PolyRig constrained Delaunay with filtered Godot Delaunay fallback for rejected concave contours",
            "weight_generation": "PolyRig geodesic inverse-distance weights; nearest-segment fallback for disconnected vertices",
            "bone_landmarks_px": landmarks_by_id[character],
            "bone_landmark_padding_delta_px": [64, 64],
            "bone_count": 19,
            "pose_states": ["neutral", "idle", "walk", "attack", "hit", "defeat"],
            "pose_status": "generic smoke-test transforms only; not character-authored animation",
            "far_side_bones": "structural placeholders; no art bound",
            "readiness": "visible reference profile mesh rig; not modular parts or runtime-ready art",
            "unresolved": [
                "semantic modular body parts and evolution swaps", "concealed anatomy and underpaint",
                "artist-authored pivots", "far-side art", "weapon/drone/cape separation",
                "visual review of mesh deformation across every pose", "production approval"
            ],
            "runtime_approved": False,
        }
        (destination / "rig_manifest.json").write_text(json.dumps(rig_manifest, indent=2), encoding="utf-8")
        print(f"{display_name}: {image.width}x{image.height}, alpha32={alpha_bbox}")


if __name__ == "__main__":
    build()
