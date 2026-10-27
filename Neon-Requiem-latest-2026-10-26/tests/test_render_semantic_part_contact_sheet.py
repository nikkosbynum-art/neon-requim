import json
from pathlib import Path
import tempfile
import unittest

from PIL import Image

from tools.art.render_semantic_part_contact_sheet import render_contact_sheet


class SemanticPartContactSheetTests(unittest.TestCase):
    def test_renders_named_parts_without_rescaling_and_labels_review_only(self):
        root = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory(dir=root) as temp:
            candidate = Path(temp) / "candidate"
            candidate.mkdir()
            Image.new("RGBA", (31, 19), (255, 0, 0, 255)).save(candidate / "torso.png")
            Image.new("RGBA", (14, 27), (0, 255, 0, 128)).save(candidate / "arm.png")
            (candidate / "parts_manifest.json").write_text(json.dumps({
                "parts": {
                    "torso": {"file": "torso.png"},
                    "near_arm": {"file": "arm.png"},
                }
            }), encoding="utf-8")
            output = Path(temp) / "sheet.png"
            report = render_contact_sheet(candidate, output)
            self.assertTrue(output.is_file())
            self.assertEqual(report["part_count"], 2)
            self.assertEqual(report["semantic_review"], "NOT_VERIFIED")
            self.assertFalse(report["production_approved"])
            self.assertEqual(report["parts"][0]["size_px"], [31, 19])
            with Image.open(output) as image:
                self.assertEqual(image.mode, "RGB")

    def test_refuses_to_overwrite_existing_output(self):
        root = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory(dir=root) as temp:
            candidate = Path(temp) / "candidate"
            candidate.mkdir()
            Image.new("RGBA", (8, 8), (0, 0, 0, 255)).save(candidate / "part.png")
            (candidate / "parts_manifest.json").write_text(json.dumps({
                "parts": {"part": {"file": "part.png"}}
            }), encoding="utf-8")
            output = Path(temp) / "existing.png"
            output.write_bytes(b"keep")
            with self.assertRaises(FileExistsError):
                render_contact_sheet(candidate, output)
            self.assertEqual(output.read_bytes(), b"keep")

    def test_renders_traced_extractor_array_schema_with_semantic_labels(self):
        root = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory(dir=root) as temp:
            candidate = Path(temp) / "candidate"
            candidate.mkdir()
            Image.new("RGBA", (48, 32), (0, 0, 0, 0)).save(candidate / "visible_blade.png")
            (candidate / "parts_manifest.json").write_text(json.dumps({
                "parts": [{
                    "part_id": "blade_body_visible",
                    "semantic_label": "exposed blade body",
                    "file": "visible_blade.png",
                }],
                "production_approved": False,
            }), encoding="utf-8")
            output = Path(temp) / "traced_sheet.png"
            report = render_contact_sheet(candidate, output)
            self.assertEqual(report["part_count"], 1)
            self.assertEqual(report["parts"][0]["part"], "exposed blade body")
            self.assertEqual(report["parts"][0]["size_px"], [48, 32])
            self.assertFalse(report["production_approved"])


if __name__ == "__main__":
    unittest.main()
