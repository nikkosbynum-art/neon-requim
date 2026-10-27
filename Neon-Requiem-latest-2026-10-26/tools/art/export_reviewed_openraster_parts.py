#!/usr/bin/env python3
"""Export explicitly selected, non-empty Krita/OpenRaster layers to quarantine.

The exporter preserves the source canvas and refuses to infer pivots, owners,
or gameplay behavior. Its output is a review candidate, never runtime art.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import uuid
import xml.etree.ElementTree as ET
import zipfile
from typing import Any

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
EXPORTABLE_PREFIXES = ("ART - ", "BREAKER - ", "ATTACHMENT - ")
ALLOWED_CATEGORIES = {"body_part", "weapon", "accessory", "cyberware", "drone", "cloth", "cable", "effect"}
ATTACHMENT_CATEGORIES = ALLOWED_CATEGORIES - {"body_part"}
PART_ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]*$")


def _project_file(path_value: str | Path, label: str) -> Path:
    path = Path(path_value)
    resolved = (ROOT / path).resolve() if not path.is_absolute() else path.resolve()
    try:
        resolved.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError(f"{label} must remain inside the project") from exc
    if not resolved.is_file():
        raise FileNotFoundError(f"{label} does not exist: {resolved}")
    return resolved


def _project_directory(path_value: str | Path, label: str) -> Path:
    path = Path(path_value)
    resolved = (ROOT / path).resolve() if not path.is_absolute() else path.resolve()
    try:
        resolved.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError(f"{label} must remain inside the project") from exc
    return resolved


def _safe_archive_member(value: str) -> str:
    member = PurePosixPath(value)
    if member.is_absolute() or ".." in member.parts or not value or "\\" in value or ":" in value:
        raise ValueError(f"unsafe OpenRaster layer path: {value!r}")
    return str(member)


def _decode_layer(archive: zipfile.ZipFile, element: ET.Element, canvas: tuple[int, int]) -> Image.Image:
    source = _safe_archive_member(element.attrib.get("src", ""))
    opacity = float(element.attrib.get("opacity", "1"))
    if opacity != 1.0:
        raise ValueError(f"layer {element.attrib.get('name')!r} has non-unit opacity; restore full opacity before export")
    if element.attrib.get("composite-op", "svg:src-over") != "svg:src-over":
        raise ValueError(f"layer {element.attrib.get('name')!r} uses a nonstandard composite mode")
    try:
        x, y = int(element.attrib.get("x", "0")), int(element.attrib.get("y", "0"))
        with Image.open(io.BytesIO(archive.read(source))) as opened:
            layer = opened.convert("RGBA")
    except (KeyError, OSError, ValueError) as exc:
        raise ValueError(f"cannot decode OpenRaster layer {source!r}: {exc}") from exc

    width, height = canvas
    aligned = Image.new("RGBA", canvas, (0, 0, 0, 0))
    left, top = max(0, x), max(0, y)
    right, bottom = min(width, x + layer.width), min(height, y + layer.height)
    if right <= left or bottom <= top:
        return aligned
    crop = layer.crop((left - x, top - y, right - x, bottom - y))
    aligned.alpha_composite(crop, (left, top))
    return aligned


def _png_bytes(image: Image.Image) -> bytes:
    stream = io.BytesIO()
    image.save(stream, format="PNG", optimize=False)
    return stream.getvalue()


def export_layers(workspace_path: str | Path, selection_path: str | Path, output_path: str | Path) -> Path:
    workspace = _project_file(workspace_path, "workspace")
    selection_file = _project_file(selection_path, "selection manifest")
    output = _project_directory(output_path, "export directory")
    if output.exists():
        raise FileExistsError(f"refusing to overwrite existing export directory: {output}")

    selection = json.loads(selection_file.read_text(encoding="utf-8"))
    if selection.get("schema_version") != 1:
        raise ValueError("selection schema_version must be 1")
    character_id = selection.get("character_id")
    if not isinstance(character_id, str) or not re.fullmatch(r"[A-Z][A-Z0-9_]*", character_id):
        raise ValueError("selection character_id must be a canonical uppercase ID")
    quarantine_root = (ROOT / "assets" / "characters" / character_id.lower() / "tier_01_drafts").resolve()
    for candidate, label in ((workspace, "workspace"), (output, "export directory")):
        try:
            candidate.relative_to(quarantine_root)
        except ValueError as exc:
            raise ValueError(f"{label} must remain inside {quarantine_root.relative_to(ROOT)}") from exc
    tier_id = selection.get("tier_id")
    if type(tier_id) is not int or tier_id < 1:
        raise ValueError("selection tier_id must be a positive integer")
    parts = selection.get("parts")
    if not isinstance(parts, list) or not parts:
        raise ValueError("selection parts must be a non-empty list")

    with zipfile.ZipFile(workspace, "r") as archive:
        if archive.testzip() is not None:
            raise ValueError("workspace archive failed its ZIP integrity check")
        if "mimetype" not in archive.namelist() or archive.read("mimetype") != b"image/openraster":
            raise ValueError("source archive is not a valid OpenRaster workspace")
        workspace_meta = json.loads(archive.read("edit_workspace_manifest.json"))
        if workspace_meta.get("status") != "EDIT PREP ONLY - QUARANTINED":
            raise ValueError("source workspace is not marked as quarantined edit preparation")
        if workspace_meta.get("production_approved") is not False or workspace_meta.get("runtime_integrated") is not False:
            raise ValueError("source workspace has unsafe approval/runtime metadata")
        if workspace_meta.get("character_id") != character_id:
            raise ValueError("selection and workspace character IDs differ")
        canvas_value = workspace_meta.get("canvas_px")
        if not isinstance(canvas_value, list) or len(canvas_value) != 2 or any(type(v) is not int or v < 1 for v in canvas_value):
            raise ValueError("workspace canvas metadata is invalid")
        canvas = (canvas_value[0], canvas_value[1])
        stack_root = ET.fromstring(archive.read("stack.xml"))
        try:
            stack_canvas = (int(stack_root.attrib["w"]), int(stack_root.attrib["h"]))
        except (KeyError, TypeError, ValueError) as exc:
            raise ValueError("OpenRaster stack canvas dimensions are invalid") from exc
        if stack_canvas != canvas:
            raise ValueError("workspace manifest canvas dimensions do not match stack.xml")
        stack = stack_root.find("./stack")
        if stack is None:
            raise ValueError("workspace layer stack is missing")
        layer_elements = stack.findall("./layer")
        by_name: dict[str, list[ET.Element]] = {}
        for element in layer_elements:
            by_name.setdefault(element.attrib.get("name", ""), []).append(element)

        staged: list[tuple[dict[str, Any], Image.Image, str]] = []
        seen_part_ids: set[str] = set()
        seen_layers: set[str] = set()
        for part in parts:
            if not isinstance(part, dict):
                raise ValueError("each selection part must be an object")
            part_id = part.get("part_id")
            layer_name = part.get("layer_name")
            category = part.get("category")
            if not isinstance(part_id, str) or not PART_ID_RE.fullmatch(part_id) or part_id in seen_part_ids:
                raise ValueError(f"invalid or duplicate part_id: {part_id!r}")
            if not isinstance(layer_name, str) or not layer_name.strip() or layer_name in seen_layers:
                raise ValueError(f"invalid or duplicate layer_name: {layer_name!r}")
            if category not in ALLOWED_CATEGORIES:
                raise ValueError(f"unsupported category for {part_id}: {category!r}")
            if not any(layer_name.startswith(prefix) for prefix in EXPORTABLE_PREFIXES):
                raise ValueError(f"layer {layer_name!r} is not a semantic authoring layer")
            matches = by_name.get(layer_name, [])
            if len(matches) != 1:
                raise ValueError(f"expected exactly one layer named {layer_name!r}, found {len(matches)}")
            element = matches[0]
            if element.findall("./layer") or element.findall("./stack"):
                raise ValueError(f"nested layer {layer_name!r} is not supported; select a leaf semantic layer")
            layer_source = _safe_archive_member(element.attrib["src"])
            aligned = _decode_layer(archive, element, canvas)
            alpha = aligned.getchannel("A")
            bbox = alpha.getbbox()
            if bbox is None:
                raise ValueError(f"selected layer is fully transparent: {layer_name}")

            record: dict[str, Any] = {
                "part_id": part_id,
                "layer_name": layer_name,
                "category": category,
                "file": f"parts/{part_id}.png",
                "canvas_px": list(canvas),
                "alpha_bbox_xyxy_exclusive": list(bbox),
                "sha256": hashlib.sha256(_png_bytes(aligned)).hexdigest(),
                "source_layer_sha256": hashlib.sha256(archive.read(layer_source)).hexdigest(),
            }
            if category in ATTACHMENT_CATEGORIES:
                attachment_role_id = part.get("attachment_role_id")
                owner = part.get("owner_character_id")
                behavior = part.get("known_behavior")
                function_status = part.get("function_status")
                triggers = part.get("presentation_triggers")
                if not isinstance(attachment_role_id, str) or not attachment_role_id.strip():
                    raise ValueError(f"{part_id} requires an attachment_role_id; component layers may share the same role")
                if owner != character_id:
                    raise ValueError(f"{part_id} owner_character_id must equal {character_id}")
                if not isinstance(behavior, str) or not behavior.strip():
                    raise ValueError(f"{part_id} requires a source-backed known_behavior or explicit unresolved note")
                if function_status not in {"source_backed", "unresolved"}:
                    raise ValueError(f"{part_id} function_status must be source_backed or unresolved")
                if not isinstance(triggers, list) or not triggers or any(not isinstance(item, str) or not item.strip() for item in triggers):
                    raise ValueError(f"{part_id} presentation_triggers must be non-empty event names or an explicit unresolved marker")
                if part.get("gameplay_authority") not in {"combat_simulation", "presentation_only", "none"}:
                    raise ValueError(f"{part_id} gameplay_authority must be combat_simulation, presentation_only, or none")
                record.update({
                    "attachment_role_id": attachment_role_id,
                    "owner_character_id": owner,
                    "known_behavior": behavior,
                    "function_status": function_status,
                    "presentation_triggers": triggers,
                    "gameplay_authority": part["gameplay_authority"],
                    "runtime_attachment_id": None,
                    "runtime_attachment_id_status": "assigned_per_owner_instance_at_runtime",
                })
            staged.append((record, aligned, record["source_layer_sha256"]))
            seen_part_ids.add(part_id)
            seen_layers.add(layer_name)

        result_manifest = {
            "schema_version": 1,
            "status": "REVIEW CANDIDATE - QUARANTINED",
            "character_id": character_id,
            "tier_id": tier_id,
            "source_workspace": workspace.relative_to(ROOT).as_posix(),
            "source_workspace_sha256": hashlib.sha256(workspace.read_bytes()).hexdigest(),
            "source_reference": workspace_meta.get("anatomy_reference"),
            "canvas_px": list(canvas),
            "parts": [record for record, _, _ in staged],
            "production_approved": False,
            "runtime_integrated": False,
            "pivots_authored": False,
            "animation_reviewed": False,
        }

    temp = output.with_name(f"{output.name}.tmp-{uuid.uuid4().hex}")
    try:
        temp.mkdir(parents=True, exist_ok=False)
        parts_folder = temp / "parts"
        parts_folder.mkdir()
        for record, image, _ in staged:
            image.save(parts_folder / Path(record["file"]).name, format="PNG", optimize=False)
        (temp / "review_manifest.json").write_text(json.dumps(result_manifest, indent=2) + "\n", encoding="utf-8")
        (temp / "README_QUARANTINE.md").write_text(
            "# Quarantined character-part review export\n\n"
            "This export preserves selected OpenRaster layers at their original canvas coordinates. "
            "It is a review candidate only: no pivots, anatomy, semantic quality, animation, or production readiness is inferred. "
            "Equipment behavior remains owned by the combat simulation; presentation metadata cannot apply gameplay effects.\n",
            encoding="utf-8",
        )
        temp.rename(output)
    except Exception:
        if temp.exists():
            shutil.rmtree(temp)
        raise
    return output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    parser.add_argument("selection", type=Path, help="Explicit semantic layer/attachment selection JSON")
    parser.add_argument("output", type=Path, help="New quarantined candidate directory; existing paths are refused")
    args = parser.parse_args()
    try:
        output = export_layers(args.workspace, args.selection, args.output)
    except (OSError, ValueError, KeyError, json.JSONDecodeError, zipfile.BadZipFile, ET.ParseError) as exc:
        print(f"FAIL: {exc}")
        return 1
    print(f"Exported a quarantined review candidate: {output.relative_to(ROOT)}")
    print("Canvas-aligned layers only; production approval, authored pivots, animation, and runtime integration remain false.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
