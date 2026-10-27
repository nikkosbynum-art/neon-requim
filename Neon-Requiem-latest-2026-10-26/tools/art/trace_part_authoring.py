#!/usr/bin/env python3
"""Visually trace source-backed part polygons and export a quarantined candidate.

The tool helps authors create integer source-coordinate polygons. It does not
infer part boundaries, fill hidden pixels, author pivots, or approve artwork.
Candidates are exported by the existing ``extract_traced_reference_parts``
implementation, which preserves source RGB and enforces the quarantine gates.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog
from typing import Iterable

from PIL import Image, ImageTk

from extract_traced_reference_parts import ROOT, extract_parts


PART_ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]*$")
CATEGORIES = ("body_part", "weapon", "accessory", "cyberware", "drone", "cloth", "cable", "effect")


def source_project_path(path: str | Path, project_root: str | Path = ROOT) -> str:
    """Return a project-relative source path; reject sources outside the repo."""
    root = Path(project_root).resolve()
    source = Path(path).resolve()
    try:
        return source.relative_to(root).as_posix()
    except ValueError as error:
        raise ValueError("The approved source image must be inside this project") from error


def sha256_file(path: str | Path) -> str:
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def validate_trace_polygon(points: Iterable[tuple[int, int]], image_size: tuple[int, int]) -> list[list[int]]:
    """Validate a closed semantic-part boundary in source-image coordinates."""
    width, height = image_size
    source_points = list(points)
    if any(type(x) is not int or type(y) is not int for x, y in source_points):
        raise ValueError("Trace points must be integer source pixels")
    normalized = [[x, y] for x, y in source_points]
    if len(normalized) < 3 or len({tuple(point) for point in normalized}) < 3:
        raise ValueError("A part boundary needs at least three distinct points")
    for x, y in normalized:
        if not (0 <= x < width and 0 <= y < height):
            raise ValueError(f"Trace point {(x, y)} is outside source dimensions {image_size}")
    return normalized


def build_manifest(
    *,
    character_id: str,
    source_image: str,
    source_sha256: str,
    source_view: str,
    parts: list[dict],
    image_size: tuple[int, int],
) -> dict:
    """Build the explicit trace manifest consumed by the quarantine exporter."""
    if not re.fullmatch(r"[A-Z][A-Z0-9_]*", character_id):
        raise ValueError("Character ID must be the uppercase roster ID")
    if not source_view.strip():
        raise ValueError("Identify the approved source view used for tracing")
    if len(image_size) != 2 or any(type(value) is not int or value <= 0 for value in image_size):
        raise ValueError("Image dimensions must be positive integers")
    if not parts:
        raise ValueError("Trace at least one semantic part")

    unique_ids: set[str] = set()
    output_parts = []
    for item in parts:
        part_id = item["part_id"]
        if not PART_ID_RE.fullmatch(part_id) or part_id in unique_ids:
            raise ValueError(f"Invalid or duplicate part ID: {part_id}")
        unique_ids.add(part_id)
        category = item["category"]
        if category not in CATEGORIES:
            raise ValueError(f"Unsupported category for {part_id}: {category}")
        label = item["semantic_label"].strip()
        provenance = item["boundary_provenance"].strip()
        if not label or not provenance:
            raise ValueError(f"Part {part_id} needs a label and boundary provenance")
        polygon = validate_trace_polygon(item["polygon_xy"], image_size)
        output_parts.append({
            "part_id": part_id,
            "file": item["file"],
            "semantic_label": label,
            "category": category,
            "owner_character_id": character_id,
            "attachment_role_id": item.get("attachment_role_id") or None,
            "boundary_provenance": provenance,
            "polygon_xy": polygon,
        })
    return {
        "schema_version": 1,
        "character_id": character_id,
        "tier_id": 1,
        "source_image": source_image,
        "source_sha256": source_sha256,
        "source_view": source_view.strip(),
        "parts": output_parts,
    }


@dataclass
class TracePart:
    character_id: str
    part_id: str
    semantic_label: str
    category: str
    attachment_role_id: str
    boundary_provenance: str
    points: list[tuple[int, int]]


class TracerApp:
    def __init__(self, root: tk.Tk, source_path: Path):
        self.root = root
        self.source_path = source_path.resolve()
        self.source_rel = source_project_path(self.source_path)
        self.image = Image.open(self.source_path).convert("RGBA")
        self.parts: list[TracePart] = []
        self.current_points: list[tuple[int, int]] = []
        self.scale = 1.0
        self.offset_x = 0.0
        self.offset_y = 0.0
        self.photo: ImageTk.PhotoImage | None = None

        self.root.title(f"Trace quarantined character parts — {self.source_path.name}")
        self.root.geometry("1100x820")
        toolbar = tk.Frame(root)
        toolbar.pack(fill=tk.X)
        tk.Button(toolbar, text="Fit", command=self.fit_image).pack(side=tk.LEFT, padx=4, pady=4)
        tk.Button(toolbar, text="Undo point", command=self.undo_point).pack(side=tk.LEFT, padx=4, pady=4)
        tk.Button(toolbar, text="Clear polygon", command=self.clear_polygon).pack(side=tk.LEFT, padx=4, pady=4)
        tk.Button(toolbar, text="Remove last part", command=self.remove_last_part).pack(side=tk.LEFT, padx=4, pady=4)
        tk.Button(toolbar, text="Finish part", command=self.finish_part).pack(side=tk.LEFT, padx=4, pady=4)
        tk.Button(toolbar, text="Export candidate", command=self.export_candidate).pack(side=tk.LEFT, padx=4, pady=4)
        self.status = tk.StringVar(value="Left-click to add boundary points. Right-click to finish a polygon.")
        tk.Label(root, textvariable=self.status, anchor="w").pack(fill=tk.X, padx=6)
        self.canvas = tk.Canvas(root, background="#242630", highlightthickness=0)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        self.canvas.bind("<Button-1>", self.add_point)
        self.canvas.bind("<Button-3>", lambda _event: self.finish_part())
        self.canvas.bind("<MouseWheel>", self.zoom_at)
        self.canvas.bind("<ButtonPress-2>", self.start_pan)
        self.canvas.bind("<B2-Motion>", self.pan)
        self.canvas.bind("<Configure>", lambda _event: self.redraw())
        self.root.bind("<BackSpace>", lambda _event: self.undo_point())
        self.root.bind("<Escape>", lambda _event: self.clear_polygon())
        self.root.after(100, self.fit_image)

    def fit_image(self) -> None:
        self.root.update_idletasks()
        canvas_w = max(1, self.canvas.winfo_width())
        canvas_h = max(1, self.canvas.winfo_height())
        image_w, image_h = self.image.size
        self.scale = min(canvas_w / image_w, canvas_h / image_h, 1.0)
        self.offset_x = (canvas_w - image_w * self.scale) / 2
        self.offset_y = (canvas_h - image_h * self.scale) / 2
        self.redraw()

    def image_to_canvas(self, point: tuple[int, int]) -> tuple[float, float]:
        return self.offset_x + point[0] * self.scale, self.offset_y + point[1] * self.scale

    def canvas_to_image(self, x: float, y: float) -> tuple[int, int]:
        source_x = round((x - self.offset_x) / self.scale)
        source_y = round((y - self.offset_y) / self.scale)
        return source_x, source_y

    def add_point(self, event) -> None:
        point = self.canvas_to_image(event.x, event.y)
        width, height = self.image.size
        if not (0 <= point[0] < width and 0 <= point[1] < height):
            return
        self.current_points.append(point)
        self.status.set(f"Point {len(self.current_points)}: source pixel {point}; image {width}×{height}.")
        self.redraw()

    def undo_point(self) -> None:
        if self.current_points:
            self.current_points.pop()
        self.status.set(f"Current polygon: {len(self.current_points)} point(s).")
        self.redraw()

    def clear_polygon(self) -> None:
        self.current_points.clear()
        self.status.set("Current polygon cleared. Left-click to add boundary points.")
        self.redraw()

    def remove_last_part(self) -> None:
        if self.parts:
            self.parts.pop()
        self.status.set(f"Recorded {len(self.parts)} part(s).")
        self.redraw()

    def finish_part(self) -> None:
        try:
            polygon = validate_trace_polygon(self.current_points, self.image.size)
        except ValueError as error:
            self.status.set(str(error))
            return
        character = simpledialog.askstring("Owner", "Character ID (uppercase roster ID):", parent=self.root)
        if not character:
            return
        character = character.strip().upper()
        if self.parts and character != self.parts[0].character_id:
            messagebox.showerror("Owner mismatch", "All parts in one export must belong to the same character.", parent=self.root)
            return
        part_id = simpledialog.askstring("Part ID", "Semantic ID, e.g. back_unit_cable:", parent=self.root)
        if not part_id:
            return
        label = simpledialog.askstring("Semantic label", "What visible item does this polygon own?", parent=self.root)
        if not label:
            return
        category = simpledialog.askstring("Category", f"Category ({', '.join(CATEGORIES)}):", parent=self.root)
        if not category:
            return
        category = category.strip().lower()
        role = simpledialog.askstring("Attachment role", "Attachment role ID (optional):", parent=self.root) or ""
        provenance = simpledialog.askstring(
            "Boundary provenance",
            "Describe the visible source boundary. Do not describe hidden pixels as source-backed:",
            parent=self.root,
        )
        if not provenance:
            return
        try:
            build_manifest(
                character_id=character,
                source_image=self.source_rel,
                source_sha256=sha256_file(self.source_path),
                source_view=self.source_path.name,
                parts=[{
                    "part_id": part_id,
                    "file": f"{character}_T1_{part_id.upper()}_CANDIDATE_01.png",
                    "semantic_label": label,
                    "category": category,
                    "attachment_role_id": role,
                    "boundary_provenance": provenance,
                    "polygon_xy": polygon,
                }],
                image_size=self.image.size,
            )
        except (KeyError, ValueError) as error:
            messagebox.showerror("Part not recorded", str(error), parent=self.root)
            return
        self.parts.append(TracePart(character, part_id, label, category, role, provenance, [tuple(point) for point in polygon]))
        self.current_points.clear()
        self.status.set(f"Recorded {len(self.parts)} part(s). Candidate remains quarantined; trace another boundary.")
        self.redraw()

    def export_candidate(self) -> None:
        if not self.parts:
            messagebox.showwarning("No parts", "Trace and finish at least one part first.", parent=self.root)
            return
        character = self.parts[0].character_id
        if any(part.character_id != character for part in self.parts):
            messagebox.showerror("Owner mismatch", "All parts in one export must belong to the same character.", parent=self.root)
            return
        character_root = ROOT / "assets" / "characters" / character.lower() / "tier_01_drafts"
        if not character_root.is_dir():
            messagebox.showerror("Unknown character", f"No draft folder exists for {character}.", parent=self.root)
            return
        output_parent = filedialog.askdirectory(
            title="Choose this character's tier_01_drafts folder",
            initialdir=character_root,
            mustexist=True,
        )
        if not output_parent or Path(output_parent).resolve() != character_root.resolve():
            messagebox.showerror("Invalid output location", "Choose the matching tier_01_drafts folder exactly.", parent=self.root)
            return
        output_name = simpledialog.askstring("Candidate folder", "New candidate folder name:", parent=self.root)
        if not output_name or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*", output_name):
            return
        output_dir = character_root / output_name
        if output_dir.exists():
            messagebox.showerror("Refusing overwrite", "That candidate folder already exists.", parent=self.root)
            return
        view = simpledialog.askstring("Source view", "Approved view/document used to trace these parts:", parent=self.root)
        if not view:
            return
        try:
            manifest = build_manifest(
                character_id=character,
                source_image=self.source_rel,
                source_sha256=sha256_file(self.source_path),
                source_view=view,
                parts=[{
                    "part_id": part.part_id,
                    "file": f"{character}_T1_{part.part_id.upper()}_CANDIDATE_01.png",
                    "semantic_label": part.semantic_label,
                    "category": part.category,
                    "attachment_role_id": part.attachment_role_id,
                    "boundary_provenance": part.boundary_provenance,
                    "polygon_xy": part.points,
                } for part in self.parts],
                image_size=self.image.size,
            )
            manifest_dir = ROOT / "tools" / "art" / "trace_manifests"
            manifest_dir.mkdir(parents=True, exist_ok=True)
            stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
            manifest_path = manifest_dir / f"{character.lower()}_{stamp}_{output_name}.json"
            manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
            extract_parts(manifest_path, output_dir)
        except Exception as error:
            messagebox.showerror("Export failed", str(error), parent=self.root)
            return
        messagebox.showinfo(
            "Quarantined candidate created",
            f"{output_dir}\n\nReview all parts at 100%. No pivot, hidden fill, or production approval was inferred.",
            parent=self.root,
        )

    def zoom_at(self, event) -> None:
        old_scale = self.scale
        factor = 1.15 if event.delta > 0 else 1 / 1.15
        self.scale = min(12.0, max(0.05, self.scale * factor))
        image_x = (event.x - self.offset_x) / old_scale
        image_y = (event.y - self.offset_y) / old_scale
        self.offset_x = event.x - image_x * self.scale
        self.offset_y = event.y - image_y * self.scale
        self.redraw()

    def start_pan(self, event) -> None:
        self._pan_anchor = (event.x, event.y, self.offset_x, self.offset_y)

    def pan(self, event) -> None:
        if not hasattr(self, "_pan_anchor"):
            return
        start_x, start_y, offset_x, offset_y = self._pan_anchor
        self.offset_x = offset_x + event.x - start_x
        self.offset_y = offset_y + event.y - start_y
        self.redraw()

    def redraw(self) -> None:
        if not hasattr(self, "canvas"):
            return
        self.canvas.delete("all")
        width = max(1, round(self.image.width * self.scale))
        height = max(1, round(self.image.height * self.scale))
        preview = self.image.resize((width, height), Image.Resampling.LANCZOS)
        self.photo = ImageTk.PhotoImage(preview)
        self.canvas.create_image(self.offset_x, self.offset_y, anchor=tk.NW, image=self.photo)
        colors = ("#37d7e9", "#ff4b9a", "#f3ca4b", "#8bd17c", "#bd8cff", "#ff884d")
        for index, part in enumerate(self.parts):
            points = [self.image_to_canvas(point) for point in part.points]
            self._draw_polygon(points, colors[index % len(colors)], closed=True)
        if self.current_points:
            points = [self.image_to_canvas(point) for point in self.current_points]
            self._draw_polygon(points, "#ffffff", closed=False)
            for x, y in points:
                self.canvas.create_oval(x - 3, y - 3, x + 3, y + 3, fill="#ffcf45", outline="#111111")

    def _draw_polygon(self, points: list[tuple[float, float]], color: str, *, closed: bool) -> None:
        if len(points) < 2:
            return
        flat = [coordinate for point in points for coordinate in point]
        if closed and len(points) > 2:
            flat += [points[0][0], points[0][1]]
        self.canvas.create_line(*flat, fill=color, width=max(1, min(3, round(self.scale * 1.5))))


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", help="Approved source image inside this project")
    args = parser.parse_args()
    root = tk.Tk()
    try:
        source = Path(args.source).resolve() if args.source else Path(filedialog.askopenfilename(
            title="Choose approved source image",
            initialdir=ROOT / "docs" / "visual_qa",
            filetypes=(("Images", "*.png *.jpg *.jpeg *.webp"),),
        ))
        if not source or not source.is_file():
            root.destroy()
            return 0
        try:
            source_project_path(source)
            TracerApp(root, source)
        except Exception as error:
            messagebox.showerror("Cannot open source", str(error), parent=root)
            root.destroy()
            return 2
        root.mainloop()
    except tk.TclError as error:
        print(f"Tk could not start: {error}")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
