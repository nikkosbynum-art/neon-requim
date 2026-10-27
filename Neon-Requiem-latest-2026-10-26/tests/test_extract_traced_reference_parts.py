from __future__ import annotations

import json
import hashlib
from pathlib import Path
import tempfile
import unittest

from PIL import Image

from tools.art.extract_traced_reference_parts import extract_parts


class TracedReferencePartExportTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.drafts = self.root / "assets/characters/ironclad/tier_01_drafts"
        self.drafts.mkdir(parents=True)
        self.source = self.root / "approved_source.png"
        image = Image.new("RGBA", (12, 10), (0, 0, 0, 0))
        for y in range(10):
            for x in range(12):
                image.putpixel((x, y), (x * 10, y * 10, 90, 255))
        image.putpixel((0, 0), (255, 0, 0, 0))
        image.save(self.source)
        self.manifest_path = self.root / "parts.json"
        self.manifest = {
            "schema_version": 1,
            "character_id": "IRONCLAD",
            "tier_id": 1,
            "source_image": "approved_source.png",
            "source_view": "approved side profile; test fixture",
            "parts": [
                {
                    "part_id": "back_unit",
                    "file": "IRONCLAD_T1_BACK_UNIT_CANDIDATE_01.png",
                    "semantic_label": "back-mounted power unit",
                    "category": "accessory",
                    "owner_character_id": "IRONCLAD",
                    "attachment_role_id": "ironclad.back_unit",
                    "boundary_provenance": "manually traced visible source boundary",
                    "polygon_xy": [[1, 1], [5, 1], [5, 5], [1, 5]],
                },
                {
                    "part_id": "shoulder_plate",
                    "file": "IRONCLAD_T1_SHOULDER_PLATE_CANDIDATE_01.png",
                    "semantic_label": "joint-owned shoulder plate",
                    "category": "cyberware",
                    "owner_character_id": "IRONCLAD",
                    "attachment_role_id": "ironclad.shoulder_plate",
                    "boundary_provenance": "manually traced visible source boundary",
                    "polygon_xy": [[7, 1], [10, 1], [10, 5], [7, 5]],
                },
            ],
        }
        self.manifest_path.write_text(json.dumps(self.manifest), encoding="utf-8")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def test_exports_canvas_aligned_source_rgb_and_quarantined_flags(self) -> None:
        output = self.drafts / "review_candidate_01_QUARANTINED"
        result = extract_parts(self.manifest_path, output, project_root=self.root)
        self.assertEqual(result, output)
        source = Image.open(self.source).convert("RGBA")
        for record in json.loads((output / "parts_manifest.json").read_text())["parts"]:
            image = Image.open(output / record["file"]).convert("RGBA")
            self.assertEqual(image.size, source.size)
            self.assertIsNone(record["pivot_source_xy"])
            self.assertEqual(record["alpha_bounds_xyxy_exclusive"], list(image.getchannel("A").getbbox()))
            for y in range(source.height):
                for x in range(source.width):
                    pixel = image.getpixel((x, y))
                    if pixel[3] > 0:
                        self.assertEqual(pixel[:3], source.getpixel((x, y))[:3])
        manifest = json.loads((output / "parts_manifest.json").read_text())
        for field in ("production_approved", "semantic_review_passed", "pivots_authored", "deformation_reviewed", "runtime_integrated"):
            self.assertIs(manifest[field], False)

    def test_rejects_overlapping_visible_ownership_before_writing(self) -> None:
        self.manifest["parts"][1]["polygon_xy"] = [[4, 4], [8, 4], [8, 8], [4, 8]]
        self.manifest_path.write_text(json.dumps(self.manifest), encoding="utf-8")
        output = self.drafts / "review_candidate_02_QUARANTINED"
        with self.assertRaisesRegex(ValueError, "masks overlap"):
            extract_parts(self.manifest_path, output, project_root=self.root)
        self.assertFalse(output.exists())

    def test_rejects_out_of_bounds_points_before_writing(self) -> None:
        self.manifest["parts"][0]["polygon_xy"][0] = [-1, 1]
        self.manifest_path.write_text(json.dumps(self.manifest), encoding="utf-8")
        output = self.drafts / "review_candidate_03_QUARANTINED"
        with self.assertRaisesRegex(ValueError, "outside source size"):
            extract_parts(self.manifest_path, output, project_root=self.root)
        self.assertFalse(output.exists())

    def test_refuses_overwrite_and_mismatched_owner(self) -> None:
        output = self.drafts / "review_candidate_04_QUARANTINED"
        output.mkdir()
        with self.assertRaises(FileExistsError):
            extract_parts(self.manifest_path, output, project_root=self.root)
        output.rmdir()
        self.manifest["parts"][0]["owner_character_id"] = "CIPHER"
        self.manifest_path.write_text(json.dumps(self.manifest), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "owner_character_id"):
            extract_parts(self.manifest_path, output, project_root=self.root)
        self.assertFalse(output.exists())

    def test_verifies_and_preserves_upstream_reference_provenance(self) -> None:
        source_hash = hashlib.sha256(self.source.read_bytes()).hexdigest()
        self.manifest["upstream_sources"] = [{
            "source_image": "approved_source.png",
            "source_sha256": source_hash,
            "registration": "fixture link; no transform asserted",
        }]
        self.manifest_path.write_text(json.dumps(self.manifest), encoding="utf-8")
        output = self.drafts / "review_candidate_05_QUARANTINED"
        extract_parts(self.manifest_path, output, project_root=self.root)
        result = json.loads((output / "parts_manifest.json").read_text())
        self.assertEqual(result["upstream_sources"][0]["source_sha256"], source_hash)
        self.assertEqual(result["upstream_sources"][0]["registration"], "fixture link; no transform asserted")

    def test_supports_multiple_disjoint_polygons_for_one_attachment(self) -> None:
        part = self.manifest["parts"][0]
        part.pop("polygon_xy")
        part["polygons_xy"] = [
            [[1, 1], [3, 1], [3, 3], [1, 3]],
            [[4, 4], [5, 4], [5, 5], [4, 5]],
        ]
        self.manifest_path.write_text(json.dumps(self.manifest), encoding="utf-8")
        output = self.drafts / "review_candidate_06_QUARANTINED"
        extract_parts(self.manifest_path, output, project_root=self.root)
        image = Image.open(output / self.manifest["parts"][0]["file"]).convert("RGBA")
        self.assertGreater(image.getpixel((2, 2))[3], 0)
        self.assertGreater(image.getpixel((4, 4))[3], 0)
        self.assertEqual(image.getpixel((6, 6))[3], 0)


if __name__ == "__main__":
    unittest.main()
