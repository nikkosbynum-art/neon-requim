#!/usr/bin/env python3
"""Build quarantined, non-destructive Krita/OpenRaster edit prep for all recruits.

This packages approved references, blank semantic art layers, and any explicitly
quarantined source-derived candidate layers. It never paints, extracts, resizes,
renames, or approves character art.
"""
from __future__ import annotations

import argparse
import io
import json
from pathlib import Path
import sys
import xml.etree.ElementTree as ET
import zipfile
from typing import Any

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
PLAN_PATH = ROOT / "tools/art/rigging_prep_all_12.json"
WORKSPACE_NAME = "{character}_T1_ART_EDIT_WORKSPACE_{version:02d}_QUARANTINED.ora"
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}

PROFILE_PART_LAYERS = [
    "ART - head / hair / face",
    "ART - headgear / optic / neck gear",
    "ART - torso front",
    "ART - torso back",
    "ART - pelvis / belt / hip gear",
    "ART - profile arm set A / upper segment",
    "ART - profile arm set A / forearm segment",
    "ART - profile arm set A / hand",
    "ART - profile arm set B / upper segment",
    "ART - profile arm set B / forearm segment",
    "ART - profile arm set B / hand",
    "ART - profile leg set A / thigh",
    "ART - profile leg set A / shin",
    "ART - profile leg set A / foot",
    "ART - profile leg set B / thigh",
    "ART - profile leg set B / shin",
    "ART - profile leg set B / foot",
    "ART - cyberware / armor overlays",
    "UNDERPAINT - inferred hidden anatomy; label every inference",
    "PIVOT GUIDES - provisional; artist-authored values required",
    "VFX - ability presentation only; combat simulation remains authoritative",
]
BREAKER_PART_LAYERS = [
    "BREAKER - head / hair / face",
    "BREAKER - torso / vest",
    "BREAKER - pelvis / belt",
    "BREAKER - right external shoulder shell",
    "BREAKER - right biological upper arm",
    "BREAKER - right mechanical forearm and signature fist (elbow start)",
    "BREAKER - left upper arm / forearm / hand",
    "BREAKER - profile leg set A / thigh / shin / foot",
    "BREAKER - profile leg set B / thigh / shin / foot",
    "BREAKER - neck regulator / spine cables",
    "UNDERPAINT - inferred hidden anatomy; label every inference",
    "PIVOT GUIDES - provisional; artist-authored values required",
    "VFX - ability presentation only; combat simulation remains authoritative",
]


def _project_file(relative: str, label: str) -> Path:
    path = Path(relative)
    if path.is_absolute():
        raise ValueError(f"{label} must be project-relative")
    resolved = (ROOT / path).resolve()
    try:
        resolved.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError(f"{label} escapes the project") from exc
    if not resolved.is_file():
        raise FileNotFoundError(f"{label} is missing: {relative}")
    return resolved


def _first_image_reference(reference: str, label: str) -> tuple[str, Path]:
    for item in reference.split(" and "):
        candidate = Path(item)
        if candidate.suffix.lower() in IMAGE_EXTENSIONS:
            return item, _project_file(item, label)
    raise ValueError(f"{label} contains no local image reference: {reference}")


def load_plan() -> dict[str, Any]:
    plan = json.loads(PLAN_PATH.read_text(encoding="utf-8"))
    records = plan.get("characters")
    if not isinstance(records, list) or len(records) != 12:
        raise ValueError("the edit batch must contain exactly twelve character records")
    ids = [item.get("id") for item in records]
    if len(ids) != len(set(ids)):
        raise ValueError("duplicate character IDs in edit batch")
    batch = plan.get("active_workspace_batch", "edit_batch_01")
    version = plan.get("active_workspace_version", 1)
    if not isinstance(batch, str) or not batch.strip() or type(version) is not int or version < 1:
        raise ValueError("active workspace batch/version is invalid")
    for item in records:
        item.setdefault("workspace_batch", batch)
        item.setdefault("workspace_version", version)
        for field in ("concept_reference", "anatomy_reference", "attachment_workspace_layers"):
            if not item.get(field):
                raise ValueError(f"{item.get('id')}: missing {field}")
        _first_image_reference(item["concept_reference"], f"{item['id']} concept reference")
        _first_image_reference(item["anatomy_reference"], f"{item['id']} anatomy reference")
    return plan


def _png_bytes(image: Image.Image) -> bytes:
    output = io.BytesIO()
    image.save(output, format="PNG")
    return output.getvalue()


def _profile_bounds(record: dict[str, Any]) -> tuple[int, int, int, int] | None:
    for candidate_rel in record["existing_candidate"].split(" and "):
        candidate = ROOT / candidate_rel
        manifest_path = candidate / "parts_manifest.json"
        if not manifest_path.is_file():
            continue
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        bounds = manifest.get("source_view_bounds_xyxy")
        if bounds is not None and len(bounds) == 4 and all(type(v) is int for v in bounds):
            return tuple(bounds)
        crop = manifest.get("crop_xywh")
        if crop is not None and len(crop) == 4 and all(type(v) is int for v in crop):
            x, y, w, h = crop
            return (x, y, x + w, y + h)
    return None


def _cipher_candidate_layers(record: dict[str, Any], canvas_size: tuple[int, int]) -> list[tuple[str, Image.Image]]:
    if record["id"] != "CIPHER":
        return []
    candidate = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05"
    manifest = json.loads((candidate / "parts_manifest.json").read_text(encoding="utf-8"))
    if manifest.get("semantic_review_status") != "PREVIEW_SCREEN_FAIL":
        raise ValueError("CIPHER candidate 05 must retain its recorded preview-screen failure")
    sx, sy, _, _ = manifest["crop_xywh"]
    layers: list[tuple[str, Image.Image]] = []
    for name, info in manifest["parts"].items():
        x0, y0, x1, y1 = info["source_bbox_xyxy"]
        pad = info["padding_px"]
        part_path = _project_file(
            f"assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05/{info['file']}",
            f"CIPHER candidate-05 part {name}",
        )
        with Image.open(part_path) as opened:
            part = opened.convert("RGBA")
        content = part.crop((pad, pad, pad + x1 - x0, pad + y1 - y0))
        if content.size != (x1 - x0, y1 - y0):
            raise ValueError(f"CIPHER candidate-05 bounds mismatch for {name}")
        aligned = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
        aligned.alpha_composite(content, (sx + x0, sy + y0))
        layers.append((f"DIAGNOSTIC ONLY - CIPHER candidate 05 failed screen - {name}", aligned))
    return layers


def _guide_layer(size: tuple[int, int], bounds: tuple[int, int, int, int] | None) -> Image.Image:
    guide = Image.new("RGBA", size, (0, 0, 0, 0))
    if bounds:
        x0, y0, x1, y1 = bounds
        draw = ImageDraw.Draw(guide)
        draw.rectangle((x0, y0, x1 - 1, y1 - 1), outline=(65, 220, 255, 210), width=2)
    return guide


def build_workspace(record: dict[str, Any], output: Path) -> Path:
    output = output.resolve()
    try:
        output.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError("workspace output must remain inside the project") from exc
    if output.exists():
        raise FileExistsError(f"refusing to overwrite {output}")

    anatomy_rel, anatomy_path = _first_image_reference(record["anatomy_reference"], f"{record['id']} anatomy")
    concept_rel, concept_path = _first_image_reference(record["concept_reference"], f"{record['id']} concept")
    with Image.open(anatomy_path) as opened:
        anatomy = opened.convert("RGBA")
    with Image.open(concept_path) as opened:
        concept = opened.convert("RGBA")
    size = anatomy.size
    if size[0] <= 0 or size[1] <= 0:
        raise ValueError("reference image has invalid dimensions")

    layer_defs: list[tuple[str, str, str]] = []
    pngs: dict[str, bytes] = {}

    def add_layer(name: str, image: Image.Image, visibility: str) -> None:
        if image.size != size:
            raise ValueError(f"layer {name!r} size {image.size} does not match canvas {size}")
        filename = f"data/layer{len(layer_defs):03d}.png"
        layer_defs.append((name, filename, visibility))
        pngs[filename] = _png_bytes(image)

    guide_bounds = _profile_bounds(record)
    add_layer("GUIDE - profile bounds from existing preflight; verify before cutting", _guide_layer(size, guide_bounds), "hidden")
    add_layer("AUTHORING - provisional pivot/anchor marks; not approved values", Image.new("RGBA", size), "hidden")
    add_layer("AUTHORING - inferred hidden anatomy; label every inference", Image.new("RGBA", size), "hidden")

    part_layers = BREAKER_PART_LAYERS if record["id"] == "BREAKER" else PROFILE_PART_LAYERS
    for label in part_layers:
        add_layer(label, Image.new("RGBA", size, (0, 0, 0, 0)), "hidden")
    for label in record["attachment_workspace_layers"]:
        add_layer(f"ATTACHMENT - {label}", Image.new("RGBA", size, (0, 0, 0, 0)), "hidden")

    for name, image in _cipher_candidate_layers(record, size):
        add_layer(name, image, "hidden")

    concept_embedded = concept.size == size
    if concept_embedded:
        add_layer("REFERENCE - approved concept sheet; hidden for clean anatomy review", concept, "hidden")
    add_layer("REFERENCE - approved anatomy/target image; visible, not production art", anatomy, "visible")

    root = ET.Element("image", {"w": str(size[0]), "h": str(size[1]), "name": f"{record['id']} Tier I - EDIT PREP ONLY - QUARANTINED", "version": "0.0.1"})
    stack = ET.SubElement(root, "stack", {"name": "Editable preparation layers; no production parts"})
    for name, src, visibility in layer_defs:
        ET.SubElement(stack, "layer", {
            "name": name,
            "src": src,
            "x": "0",
            "y": "0",
            "opacity": "1.0",
            "visibility": visibility,
            "composite-op": "svg:src-over",
        })

    metadata = {
        "status": "EDIT PREP ONLY - QUARANTINED",
        "character_id": record["id"],
        "workspace_batch": record.get("workspace_batch", "edit_batch_01"),
        "workspace_version": record.get("workspace_version", 1),
        "canvas_px": list(size),
        "anatomy_reference": anatomy_rel,
        "concept_reference": concept_rel,
        "concept_embedded_same_scale": concept_embedded,
        "candidate_inventory": record["existing_candidate"],
        "candidate_status": record["candidate_status"],
        "special_rig_items": record["special_rig_items"],
        "attachment_workspace_layers": record["attachment_workspace_layers"],
        "attachment_layer_policy": "One independently moving semantic item per ATTACHMENT layer. Fixed components may share one rigid assembly layer only when the approved source shows they remain attached (for example, CIPHER's rifle-mounted optic). Split by joint/owner; author each physical cable route as its own layer. Layer labels are prep guidance, not proof of ownership or source visibility.",
        "functional_attachment_contract": record.get("functional_attachment_contract", []),
        "attachment_open_questions": record.get("attachment_open_questions", []),
        "profile_guide_xyxy": list(guide_bounds) if guide_bounds else None,
        "side_label_status": "PROFILE SIDE A/B LABELS ARE PROVISIONAL; verify against approved front/profile/back references",
        "semantic_parts_created": False,
        "art_pixels_changed": False,
        "production_approved": False,
        "runtime_integrated": False,
        "krita_round_trip": "NOT_YET_VERIFIED",
        "layer_names": [name for name, _, _ in layer_defs],
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w") as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
        archive.writestr("stack.xml", ET.tostring(root, encoding="utf-8"))
        archive.writestr("mergedimage.png", _png_bytes(anatomy))
        archive.writestr("edit_workspace_manifest.json", json.dumps(metadata, indent=2).encode("utf-8"))
        for filename, content in pngs.items():
            archive.writestr(filename, content, compress_type=zipfile.ZIP_DEFLATED)

    readme = [
        f"# {record['id']} Tier I editable art preparation",
        "",
        f"Workspace: `{record.get('workspace_batch', 'edit_batch_01')}` version {record.get('workspace_version', 1)}.",
        "",
        "Status: EDIT PREP ONLY / QUARANTINED. This OpenRaster file contains source references and blank authoring layers; it contains no approved modular parts and is not a rig or runtime asset.",
        "",
        f"- Anatomy/target reference: `{anatomy_rel}`",
        f"- Concept reference: `{concept_rel}`",
        ("- Concept is embedded as a hidden layer in this workspace." if concept_embedded else f"- Concept is NOT embedded because its canvas differs; open the source separately in Krita: `{concept_rel}`."),
        f"- Existing candidate: `{record['existing_candidate']}`",
        f"- Current candidate status: {record['candidate_status']}",
        "- Attachment requirements from the current roster work plan:",
        *[f"  - {item}" for item in record["special_rig_items"]],
        "- Blank attachment layers:",
        *[f"  - {item}" for item in record["attachment_workspace_layers"]],
        "- Attachment layer rule: one independently moving semantic item per layer; split joint-owned armor, separate gear, drones, cloth panels, and physical cable routes. A fixed subpart may share a rigid assembly only when the approved reference supports it. Validate every owner and boundary against the approved views before painting/export.",
        "- These labels are authoring guidance, not proof that hidden anatomy, pivots, exact attachment count, or behavior is known.",
        "- Side A/B labels and all pivot guides are provisional until checked against the approved views.",
        "- The visible reference is flattened concept/anatomy art, not production sprite parts.",
        "- Functional attachments need separate mounts/ownership and tests through idle, walk, attack, hit, defeat, and facing changes; combat simulation remains authoritative.",
        "- Functional requirements and unresolved gameplay details: `docs/ATTACHMENT_FUNCTION_CONTRACT.md`; this reference is not runtime implementation.",
        *(["- Open questions:", *[f"  - {item}" for item in record.get("attachment_open_questions", [])]] if record.get("attachment_open_questions") else []),
        "",
    ]
    (output.parent / "README_EDIT_PREP.md").write_text("\n".join(readme), encoding="utf-8")
    return output


def build_all(output_root: Path | None = None, character_id: str | None = None) -> list[Path]:
    plan = load_plan()
    records = plan["characters"]
    if character_id:
        records = [item for item in records if item["id"].upper() == character_id.upper()]
        if not records:
            raise ValueError(f"unknown character ID: {character_id}")
    if output_root is not None:
        output_root = output_root.resolve()
        try:
            output_root.relative_to(ROOT.resolve())
        except ValueError as exc:
            raise ValueError("output root must remain inside the project") from exc

    outputs: list[tuple[dict[str, Any], Path]] = []
    for record in records:
        if output_root is None:
            batch = record.get("workspace_batch", "edit_batch_01")
            folder = ROOT / f"assets/characters/{record['id'].lower()}/tier_01_drafts/{batch}"
        else:
            folder = output_root / record["id"].lower()
        version = record.get("workspace_version", 1)
        if type(version) is not int or version < 1:
            raise ValueError(f"{record['id']}: workspace_version must be a positive integer")
        output = folder / WORKSPACE_NAME.format(character=record["id"], version=version)
        if output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
        outputs.append((record, output))

    # Preflight every reference and output collision before creating any batch file.
    for record, _ in outputs:
        _first_image_reference(record["anatomy_reference"], f"{record['id']} anatomy")
        _first_image_reference(record["concept_reference"], f"{record['id']} concept")
    built: list[Path] = []
    for record, output in outputs:
        built.append(build_workspace(record, output))
    return built


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--character", help="build one roster entry; defaults to all twelve")
    parser.add_argument("--output-root", type=Path, help="project-relative test/output root; must remain inside the project")
    args = parser.parse_args()
    try:
        outputs = build_all(args.output_root, args.character)
    except (OSError, ValueError, KeyError, json.JSONDecodeError, zipfile.BadZipFile) as exc:
        print(f"FAIL: {exc}")
        return 1
    print(f"Created {len(outputs)} quarantined editable-reference workspaces.")
    print("Blank authoring layers only; no character pixels were changed; Krita round-trip, semantics, pivots, and deformation remain unverified.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
