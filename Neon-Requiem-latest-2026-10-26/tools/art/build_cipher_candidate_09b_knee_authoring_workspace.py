"""Build an editable, quarantined CIPHER 09B knee-part OpenRaster workspace.

The source cutouts and approved underpaint remain unchanged. This packages
canvas-aligned copies for a Krita save/reopen and explicit-layer export pilot.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path
import xml.etree.ElementTree as ET
import zipfile

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
CANDIDATE = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02"
CONCEPT = ROOT / "docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png"
ANATOMY = ROOT / "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
WORKSPACE_DIR = CANDIDATE / "krita_authoring_workspace_09b"
WORKSPACE = WORKSPACE_DIR / "CIPHER_T1_KNEE_PARTS_EDIT_WORKSPACE_09B_QUARANTINED.ora"
SELECTION = WORKSPACE_DIR / "CIPHER_T1_KNEE_PART_EXPORT_SELECTION_09B_QUARANTINED.json"
MANIFEST = CANDIDATE / "parts_manifest.json"
CANVAS_SIZE = (330, 960)
EXPORT_PARTS = ("near_thigh", "near_shin", "near_knee_guard", "near_boot")


def _png_bytes(image: Image.Image) -> bytes:
    stream = io.BytesIO()
    image.save(stream, format="PNG", optimize=False)
    return stream.getvalue()


def _canvas_aligned(part: dict, canvas: tuple[int, int]) -> Image.Image:
    path = CANDIDATE / part["file"]
    with Image.open(path) as opened:
        cutout = opened.convert("RGBA")
    x0, y0, _, _ = part["source_bbox_xyxy"]
    padding = part["padding_px"]
    destination = (x0 - padding, y0 - padding)
    aligned = Image.new("RGBA", canvas, (0, 0, 0, 0))
    left, top = max(0, destination[0]), max(0, destination[1])
    right = min(canvas[0], destination[0] + cutout.width)
    bottom = min(canvas[1], destination[1] + cutout.height)
    if right > left and bottom > top:
        clipped = cutout.crop((left - destination[0], top - destination[1], right - destination[0], bottom - destination[1]))
        aligned.alpha_composite(clipped, (left, top))
    return aligned


def build() -> tuple[Path, Path]:
    if WORKSPACE.exists() or SELECTION.exists():
        raise FileExistsError("Refusing to overwrite an existing CIPHER 09B workspace or selection file.")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    crop = manifest["crop_xywh"]
    if crop[2:] != list(CANVAS_SIZE):
        raise ValueError(f"Candidate canvas mismatch: expected {CANVAS_SIZE}, got {crop[2:]}")
    parts = manifest["parts"]
    order = manifest["layer_order_back_to_front"]
    if any(part_id not in parts for part_id in order):
        raise ValueError("Candidate layer order refers to a missing semantic part.")

    aligned_parts = {part_id: _canvas_aligned(parts[part_id], CANVAS_SIZE) for part_id in order}
    merged = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    for part_id in order:
        merged.alpha_composite(aligned_parts[part_id])
    expected_path = CANDIDATE / manifest["assembly_preview"]
    if expected_path.exists():
        with Image.open(expected_path) as expected_opened:
            expected = expected_opened.convert("RGBA")
        if expected.size != CANVAS_SIZE or ImageChops_difference_count(merged, expected) != 0:
            raise ValueError("Canvas-aligned authoring layers do not reproduce the recorded neutral assembly exactly.")

    source = Image.open(ANATOMY).convert("RGBA")
    x, y, width, height = crop
    reference = source.crop((x, y, x + width, y + height))
    if reference.size != CANVAS_SIZE:
        raise ValueError("Approved CIPHER anatomy crop does not match the candidate canvas.")
    underpaint_file = manifest["inferred_underpaint_review"]["file"]
    with Image.open(CANDIDATE / underpaint_file) as opened:
        underpaint = opened.convert("RGBA")
    if underpaint.size != CANVAS_SIZE:
        raise ValueError("Approved inferred underpaint is not aligned to the candidate canvas.")

    layers: list[tuple[str, Image.Image, bool]] = [("REFERENCE - approved CIPHER anatomy profile crop", reference, False)]
    layers.append(("INFERRED - approved knee continuity underpaint - review only; excluded from export", underpaint, False))
    # OpenRaster stack children are top-to-bottom; reverse back-to-front order.
    for part_id in reversed(order):
        layers.append((f"ART - {part_id} - quarantined 09B source cutout; boundary status in manifest", aligned_parts[part_id], True))

    root = ET.Element("image", {"w": str(CANVAS_SIZE[0]), "h": str(CANVAS_SIZE[1]), "name": "CIPHER Tier I knee parts - EDIT PREP ONLY - QUARANTINED", "version": "0.0.3"})
    stack = ET.SubElement(root, "stack", {"name": "CIPHER candidate 09B editable source-derived layers"})
    layer_names: list[str] = []
    pngs: dict[str, bytes] = {}
    for index, (name, image, visible) in enumerate(layers):
        src = f"data/layer{index:03d}.png"
        layer_names.append(name)
        pngs[src] = _png_bytes(image)
        ET.SubElement(stack, "layer", {
            "name": name,
            "src": src,
            "x": "0",
            "y": "0",
            "opacity": "1.0",
            "visibility": "visible" if visible else "hidden",
            "composite-op": "svg:src-over",
        })

    metadata = {
        "status": "EDIT PREP ONLY - QUARANTINED",
        "character_id": "CIPHER",
        "tier_id": 1,
        "workspace_batch": "candidate_09b_knee_roundtrip_pilot",
        "canvas_px": list(CANVAS_SIZE),
        "concept_reference": "docs/visual_qa/CIPHER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png",
        "anatomy_reference": "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
        "source_candidate": "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_09_knee_guard_review_02/",
        "source_candidate_manifest_sha256": hashlib.sha256(MANIFEST.read_bytes()).hexdigest(),
        "layer_names": layer_names,
        "export_selection": SELECTION.relative_to(ROOT).as_posix(),
        "selected_export_parts": list(EXPORT_PARTS),
        "inferred_underpaint_layer": "INFERRED - approved knee continuity underpaint - review only; excluded from export",
        "underpaint_default_visibility": "hidden; toggle only for the approved flex review range",
        "approved_gate": "near_knee_guard owner split, traced boundary, hinge pivot, and v04 review underpaint only",
        "semantic_parts_created": False,
        "art_pixels_changed": False,
        "krita_round_trip": "NOT_YET_VERIFIED",
        "production_approved": False,
        "runtime_integrated": False,
    }
    selection = {
        "schema_version": 1,
        "character_id": "CIPHER",
        "tier_id": 1,
        "parts": [
            {"part_id": part_id, "layer_name": f"ART - {part_id} - quarantined 09B source cutout; boundary status in manifest", "category": "body_part"}
            for part_id in EXPORT_PARTS
        ],
    }
    WORKSPACE_DIR.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(WORKSPACE, "w") as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
        archive.writestr("stack.xml", ET.tostring(root, encoding="utf-8", xml_declaration=True), compress_type=zipfile.ZIP_DEFLATED)
        archive.writestr("edit_workspace_manifest.json", json.dumps(metadata, indent=2) + "\n", compress_type=zipfile.ZIP_DEFLATED)
        for name, data in pngs.items():
            archive.writestr(name, data, compress_type=zipfile.ZIP_DEFLATED)
        archive.writestr("mergedimage.png", _png_bytes(merged), compress_type=zipfile.ZIP_DEFLATED)
        thumb = merged.copy()
        thumb.thumbnail((256, 256))
        archive.writestr("Thumbnails/thumbnail.png", _png_bytes(thumb), compress_type=zipfile.ZIP_DEFLATED)
    SELECTION.write_text(json.dumps(selection, indent=2) + "\n", encoding="utf-8")
    return WORKSPACE, SELECTION


def ImageChops_difference_count(actual: Image.Image, expected: Image.Image) -> int:
    if actual.size != expected.size:
        return actual.width * actual.height
    a = actual.tobytes()
    b = expected.tobytes()
    return sum(1 for i in range(0, len(a), 4) if a[i:i + 4] != b[i:i + 4])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    workspace, selection = build()
    print(f"Created: {workspace.relative_to(ROOT).as_posix()}")
    print(f"Selection: {selection.relative_to(ROOT).as_posix()}")
    print("Knee guard ownership/pivot and underpaint approvals are recorded; all outputs remain quarantined.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
