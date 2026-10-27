"""Create a non-destructive Krita/OpenRaster workspace from a cutout manifest.

Candidate parts are hidden initially. The workspace is always marked
quarantined: this packaging tool never approves art.
"""
from __future__ import annotations

import argparse
import io
import json
from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET
from typing import Any

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]


def _resolve_confined(base: Path, value: str, label: str) -> Path:
    relative = Path(value)
    if relative.is_absolute():
        raise ValueError(f"{label} must be project-relative")
    base = base.resolve()
    resolved = (base / relative).resolve()
    try:
        resolved.relative_to(base)
    except ValueError as exc:
        raise ValueError(f"{label} escapes its allowed directory") from exc
    if not resolved.is_file():
        raise FileNotFoundError(f"{label} does not exist: {resolved}")
    return resolved


def _int_tuple(value: Any, length: int, label: str) -> tuple[int, ...]:
    if (not isinstance(value, list) or len(value) != length
            or any(type(item) is not int for item in value)):
        raise ValueError(f"{label} must contain {length} integers")
    return tuple(value)


def _png_bytes(image: Image.Image) -> bytes:
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue()


def _part_origin_and_pixels(candidate_dir: Path, part: dict[str, Any]) -> tuple[Image.Image, tuple[int,int]]:
    part_path = _resolve_confined(candidate_dir, part["file"], "part file")
    with Image.open(part_path) as opened:
        image = opened.convert("RGBA")
    if "source_crop_xy" in part:
        return image, _int_tuple(part["source_crop_xy"], 2, "source_crop_xy")
    if "source_bbox_xyxy" in part:
        x0, y0, x1, y1 = _int_tuple(part["source_bbox_xyxy"], 4, "source_bbox_xyxy")
        if x0 < 0 or y0 < 0 or x1 <= x0 or y1 <= y0:
            raise ValueError(f"invalid source_bbox_xyxy for {part['file']}")
        bbox = image.getchannel("A").getbbox()
        if bbox is None:
            raise ValueError(f"empty alpha in {part['file']}")
        cropped = image.crop(bbox)
        if cropped.size != (x1 - x0, y1 - y0):
            raise ValueError(
                f"alpha bounds for {part['file']} are {cropped.size}, "
                f"but source_bbox_xyxy declares {(x1 - x0, y1 - y0)}"
            )
        return cropped, (x0, y0)
    raise ValueError(f"part {part.get('file')} has no source placement metadata")


def build_workspace(candidate_dir: Path, output: Path, *, force: bool = False) -> Path:
    candidate_dir = candidate_dir.resolve()
    try:
        candidate_dir.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError("candidate directory must be inside the project") from exc
    output = output.resolve()
    if output.exists() and not force:
        raise FileExistsError(f"refusing to overwrite {output}")
    manifest_path = _resolve_confined(candidate_dir, "parts_manifest.json", "parts manifest")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    sx, sy, width, height = _int_tuple(manifest["crop_xywh"], 4, "crop_xywh")
    if sx < 0 or sy < 0 or width <= 0 or height <= 0:
        raise ValueError("crop_xywh must have nonnegative origin and positive dimensions")
    reference_path = _resolve_confined(ROOT, manifest["source"], "source reference")
    with Image.open(reference_path) as opened:
        source = opened.convert("RGBA")
    if sx + width > source.width or sy + height > source.height:
        raise ValueError("crop_xywh extends beyond the source reference")
    reference = source.crop((sx, sy, sx + width, sy + height))
    if reference.size != (width, height):
        raise ValueError("reference crop did not match manifest canvas")

    parts = manifest.get("parts")
    if not isinstance(parts, dict) or not parts:
        raise ValueError("manifest parts must be a nonempty object")
    part_files = [info.get("file") for info in parts.values() if isinstance(info, dict)]
    if len(part_files) != len(parts) or len(set(part_files)) != len(part_files):
        raise ValueError("every semantic part must have a unique file")

    layer_defs: list[tuple[str, str, str]] = []
    pngs: dict[str, bytes] = {}

    def add_layer(name: str, image: Image.Image, visibility: str) -> None:
        filename = f"data/layer{len(layer_defs):03d}.png"
        layer_defs.append((name, filename, visibility))
        pngs[filename] = _png_bytes(image)

    add_layer("AUTHORING - inferred underpaint - label all inference", Image.new("RGBA", (width, height), (0,0,0,0)), "visible")
    for semantic, part_info in parts.items():
        image, (px, py) = _part_origin_and_pixels(candidate_dir, part_info)
        if "source_bbox_xyxy" in part_info:
            _, _, x1, y1 = part_info["source_bbox_xyxy"]
            if x1 > width or y1 > height:
                raise ValueError(f"source_bbox_xyxy for {semantic} exceeds the reference crop")
        aligned = Image.new("RGBA", (width, height), (0,0,0,0))
        aligned.paste(image, (px, py), image)
        add_layer(f"CANDIDATE - {semantic} - verify boundary and pivot", aligned, "hidden")
    add_layer("REFERENCE - approved source crop", reference, "visible")

    root = ET.Element("image", {"w": str(width), "h": str(height), "name": f"{candidate_dir.name} - QUARANTINED", "version": "0.0.1"})
    stack = ET.SubElement(root, "stack", {"name": "Editable art review layers"})
    for name, src, visibility in layer_defs:
        ET.SubElement(stack, "layer", {"name": name, "src": src, "x": "0", "y": "0", "opacity": "1.0", "visibility": visibility, "composite-op": "svg:src-over"})

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w") as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
        archive.writestr("stack.xml", ET.tostring(root, encoding="utf-8", xml_declaration=True), compress_type=zipfile.ZIP_DEFLATED)
        for name, data in pngs.items():
            archive.writestr(name, data, compress_type=zipfile.ZIP_DEFLATED)
        archive.writestr("mergedimage.png", _png_bytes(reference), compress_type=zipfile.ZIP_DEFLATED)
        thumbnail = reference.copy()
        thumbnail.thumbnail((256, 256))
        archive.writestr("Thumbnails/thumbnail.png", _png_bytes(thumbnail), compress_type=zipfile.ZIP_DEFLATED)
    return output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("candidate_dir", type=Path)
    parser.add_argument("output", type=Path, help="new .ora output file; existing files are preserved")
    args = parser.parse_args()
    result = build_workspace(args.candidate_dir, args.output)
    print(f"Created quarantined OpenRaster review workspace: {result}")
    print("Candidate layers are hidden; visual/semantic review is required. No art approval is inferred.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
