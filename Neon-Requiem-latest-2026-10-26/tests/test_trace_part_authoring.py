from __future__ import annotations

import sys
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools" / "art"))

from trace_part_authoring import build_manifest, source_project_path, validate_trace_polygon
from extract_traced_reference_parts import extract_parts


class TracePartAuthoringTests(unittest.TestCase):
    def test_source_path_must_be_inside_project(self) -> None:
        self.assertEqual(source_project_path(ROOT / "docs" / "README.md"), "docs/README.md")
        with self.assertRaisesRegex(ValueError, "inside this project"):
            source_project_path(ROOT.parent / "outside.png")

    def test_polygon_points_remain_source_pixel_coordinates(self) -> None:
        self.assertEqual(validate_trace_polygon([(1, 2), (8, 2), (4, 9)], (10, 10)), [[1, 2], [8, 2], [4, 9]])
        with self.assertRaisesRegex(ValueError, "integer source pixels"):
            validate_trace_polygon([(1.5, 2), (8, 2), (4, 9)], (10, 10))  # type: ignore[list-item]
        with self.assertRaisesRegex(ValueError, "outside source dimensions"):
            validate_trace_polygon([(1, 2), (10, 2), (4, 9)], (10, 10))

    def test_manifest_records_owner_and_explicit_semantic_provenance(self) -> None:
        manifest = build_manifest(
            character_id="IRONCLAD",
            source_image="docs/visual_qa/IRONCLAD.png",
            source_sha256="a" * 64,
            source_view="approved profile turnaround",
            image_size=(20, 20),
            parts=[{
                "part_id": "back_power_cable",
                "file": "IRONCLAD_T1_BACK_POWER_CABLE_CANDIDATE_01.png",
                "semantic_label": "visible cable loop",
                "category": "cable",
                "attachment_role_id": "ironclad.back_power_cable",
                "boundary_provenance": "manually traced from visible source pixels; no hidden ends",
                "polygon_xy": [(2, 2), (10, 2), (8, 12), (3, 12)],
            }],
        )
        self.assertEqual(manifest["source_sha256"], "a" * 64)
        part = manifest["parts"][0]
        self.assertEqual(part["owner_character_id"], "IRONCLAD")
        self.assertEqual(part["attachment_role_id"], "ironclad.back_power_cable")
        self.assertIn("no hidden ends", part["boundary_provenance"])
        self.assertNotIn("pivot", part)

    def test_manifest_rejects_duplicate_parts_and_missing_source_view(self) -> None:
        base = {
            "part_id": "drone",
            "file": "SPARK_T1_DRONE_CANDIDATE_01.png",
            "semantic_label": "visible drone shell",
            "category": "drone",
            "boundary_provenance": "manually traced from approved visible art",
            "polygon_xy": [(1, 1), (8, 1), (8, 8)],
        }
        args = dict(
            character_id="SPARK", source_image="docs/spark.png", source_sha256="b" * 64,
            source_view="approved turnaround", parts=[base], image_size=(10, 10),
        )
        with self.assertRaisesRegex(ValueError, "duplicate part ID"):
            build_manifest(**{**args, "parts": [base, {**base}]})
        with self.assertRaisesRegex(ValueError, "approved source view"):
            build_manifest(**{**args, "source_view": "   "})

    def test_manifest_rejects_unknown_character_category_or_bad_polygon(self) -> None:
        base = {
            "part_id": "visible_part", "file": "SPARK_T1_VISIBLE_PART_CANDIDATE_01.png",
            "semantic_label": "visible part", "category": "drone",
            "boundary_provenance": "manually traced visible boundary", "polygon_xy": [(1, 1), (8, 1), (8, 8)],
        }
        args = dict(
            character_id="SPARK", source_image="docs/spark.png", source_sha256="b" * 64,
            source_view="approved turnaround", parts=[base], image_size=(10, 10),
        )
        with self.assertRaisesRegex(ValueError, "uppercase roster ID"):
            build_manifest(**{**args, "character_id": "Spark"})
        with self.assertRaisesRegex(ValueError, "Unsupported category"):
            build_manifest(**{**args, "parts": [{**base, "category": "unknown"}]})
        with self.assertRaisesRegex(ValueError, "at least three distinct points"):
            build_manifest(**{**args, "parts": [{**base, "polygon_xy": [(1, 1), (1, 1), (8, 8)]}]})

    def test_trace_manifest_exports_through_quarantine_only_pipeline(self) -> None:
        with tempfile.TemporaryDirectory(dir=ROOT / "tests") as temporary:
            project = Path(temporary)
            source = project / "docs" / "visual_qa" / "source.png"
            source.parent.mkdir(parents=True)
            Image.new("RGB", (20, 16), (35, 42, 51)).save(source)
            drafts = project / "assets" / "characters" / "spark" / "tier_01_drafts"
            drafts.mkdir(parents=True)
            manifest_path = project / "tools" / "art" / "trace_manifests" / "spark_smoke.json"
            manifest_path.parent.mkdir(parents=True)
            manifest = build_manifest(
                character_id="SPARK",
                source_image="docs/visual_qa/source.png",
                source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                source_view="approved source smoke fixture",
                image_size=(20, 16),
                parts=[{
                    "part_id": "visible_drone_shell",
                    "file": "SPARK_T1_VISIBLE_DRONE_SHELL_CANDIDATE_01.png",
                    "semantic_label": "visible drone shell",
                    "category": "drone",
                    "attachment_role_id": "spark.visible_drone_shell",
                    "boundary_provenance": "test polygon; source pixels only",
                    "polygon_xy": [(2, 2), (15, 2), (15, 12), (2, 12)],
                }],
            )
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            output = drafts / "trace_tool_smoke_QUARANTINED"
            result = extract_parts(manifest_path, output, project_root=project)
            self.assertEqual(result, output)
            written = json.loads((output / "parts_manifest.json").read_text(encoding="utf-8"))
            self.assertFalse(written["production_approved"])
            self.assertFalse(written["semantic_review_passed"])
            self.assertFalse(written["pivots_authored"])
            self.assertEqual(written["parts"][0]["visible_source_pixels"], 14 * 11)
            with Image.open(output / written["parts"][0]["file"]) as cutout:
                self.assertEqual(cutout.size, (20, 16))
                self.assertEqual(cutout.getpixel((4, 4)), (35, 42, 51, 255))
                self.assertEqual(cutout.getpixel((0, 0))[3], 0)


if __name__ == "__main__":
    unittest.main()
