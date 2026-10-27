import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools/art/extract_reference_prop_candidate.py"
SPEC = importlib.util.spec_from_file_location("extract_reference_prop_candidate", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
AUDIT_SCRIPT = ROOT / "tools/art/audit_reference_prop_candidate.py"
AUDIT_SPEC = importlib.util.spec_from_file_location("audit_reference_prop_candidate", AUDIT_SCRIPT)
AUDIT_MODULE = importlib.util.module_from_spec(AUDIT_SPEC)
AUDIT_SPEC.loader.exec_module(AUDIT_MODULE)


def make_source(path: Path) -> None:
    image = Image.new("RGB", (240, 150), (204, 200, 196))
    draw = ImageDraw.Draw(image)
    draw.rectangle((35, 40, 65, 75), fill=(12, 45, 210))
    draw.rectangle((100, 40, 130, 75), fill=(210, 30, 32))
    draw.rectangle((165, 40, 195, 75), fill=(220, 130, 12))
    image.save(path)


def test_manifest(source: str) -> dict:
    items = []
    for item_id, left in (("drone_blue", 30), ("drone_red", 95), ("drone_amber", 160)):
        items.append({
            "id": item_id,
            "bbox": [left, 30, left + 40, 90],
            "background_seed": [left + 1, 31],
            "object_seed": [left + 20, 55],
            "background_tolerance": 22,
            "safety_margin_px": 8,
        })
    return {"schema_version": 1, "character_id": "SPARK", "source_reference": source, "items": items}


class ReferencePropCandidateTests(unittest.TestCase):
    def test_each_seeded_shape_is_isolated_and_background_is_transparent(self):
        with tempfile.TemporaryDirectory() as temp:
            source_path = Path(temp) / "source.png"
            make_source(source_path)
            image = Image.open(source_path)
            manifest = test_manifest("unused")
            masks = []
            for record in manifest["items"]:
                mask, audit = MODULE._foreground_from_seed(
                    image,
                    record["bbox"],
                    record["background_seed"],
                    record["object_seed"],
                    record["background_tolerance"],
                )
                self.assertIsNotNone(mask.getbbox())
                self.assertGreater(audit["source_alpha_pixels"], 500)
                self.assertEqual(mask.getpixel((0, 0)), 0)
                self.assertEqual(mask.getpixel((20, 25)), 255)
                masks.append(mask.tobytes())
            self.assertEqual(len(masks), 3)

    def test_creates_quarantined_assets_under_matching_character_drafts(self):
        with tempfile.TemporaryDirectory() as temp:
            project = Path(temp)
            source = project / "docs/visual_qa/spark.png"
            source.parent.mkdir(parents=True)
            make_source(source)
            manifest_path = project / "selection.json"
            manifest_path.write_text(json.dumps(test_manifest("docs/visual_qa/spark.png")), encoding="utf-8")
            output = project / "assets/characters/spark/tier_01_drafts/review_01"
            output.parent.mkdir(parents=True)
            original_root = MODULE.ROOT
            MODULE.ROOT = project
            try:
                result = MODULE.create_candidate(manifest_path, output)
                self.assertEqual(len(result["items"]), 3)
                self.assertFalse(result["animation_ready"])
                self.assertFalse(result["production_approved"])
                self.assertFalse(result["runtime_integrated"])
                self.assertIn("not animation-ready", result["source_status"])
                self.assertTrue((output / "README_QUARANTINED.md").is_file())
                center_colors = []
                source_image = Image.open(source).convert("RGB")
                for item in result["items"]:
                    image = Image.open(output / item["file"]).convert("RGBA")
                    margin = item["safety_margin_px"]
                    self.assertEqual(image.size[0], item["source_crop_px"][0] + 2 * margin)
                    self.assertEqual(image.getpixel((0, 0))[3], 0)
                    self.assertIsNone(item["pivot"])
                    center_colors.append(image.getpixel((margin + 20, margin + 25))[:3])
                    left, top, right, bottom = item["bbox_source_px"]
                    for crop_y in range(bottom - top):
                        for crop_x in range(right - left):
                            candidate_pixel = image.getpixel((margin + crop_x, margin + crop_y))
                            if candidate_pixel[3] > 0:
                                self.assertEqual(candidate_pixel[:3], source_image.getpixel((left + crop_x, top + crop_y)))
                self.assertEqual(len(set(center_colors)), 3)
            finally:
                MODULE.ROOT = original_root

    def test_rejects_output_outside_matching_draft_quarantine(self):
        with tempfile.TemporaryDirectory() as temp:
            project = Path(temp)
            manifest_path = project / "selection.json"
            manifest_path.write_text(json.dumps({"schema_version": 1, "character_id": "SPARK"}), encoding="utf-8")
            original_root = MODULE.ROOT
            MODULE.ROOT = project
            try:
                with self.assertRaisesRegex(ValueError, "inside the matching character"):
                    MODULE.create_candidate(manifest_path, project / "assets/runtime/characters/spark")
            finally:
                MODULE.ROOT = original_root

    def test_candidate_audit_checks_source_fidelity_alpha_and_separate_masks(self):
        with tempfile.TemporaryDirectory() as temp:
            project = Path(temp)
            source = project / "docs/visual_qa/spark.png"
            source.parent.mkdir(parents=True)
            make_source(source)
            manifest_path = project / "selection.json"
            manifest_path.write_text(json.dumps(test_manifest("docs/visual_qa/spark.png")), encoding="utf-8")
            output = project / "assets/characters/spark/tier_01_drafts/review_01"
            output.parent.mkdir(parents=True)
            original_root = MODULE.ROOT
            original_audit_root = AUDIT_MODULE.ROOT
            MODULE.ROOT = project
            AUDIT_MODULE.ROOT = project
            try:
                MODULE.create_candidate(manifest_path, output)
                report = AUDIT_MODULE.audit_candidate(output)
                self.assertEqual(report["status"], "PASS")
                self.assertTrue(all(item["alpha_audit"]["status"] == "PASS" for item in report["items"]))
                self.assertTrue(all(item["source_rgb_mismatches"] == 0 for item in report["items"]))
                self.assertTrue(all(pair["shared_source_pixels"] == 0 for pair in report["pairwise_mask_overlap"]))
                self.assertFalse(report["production_approved"])
            finally:
                MODULE.ROOT = original_root
                AUDIT_MODULE.ROOT = original_audit_root

    def test_candidate_audit_detects_changed_source_pixels(self):
        with tempfile.TemporaryDirectory() as temp:
            project = Path(temp)
            source = project / "docs/visual_qa/spark.png"
            source.parent.mkdir(parents=True)
            make_source(source)
            manifest_path = project / "selection.json"
            manifest_path.write_text(json.dumps(test_manifest("docs/visual_qa/spark.png")), encoding="utf-8")
            output = project / "assets/characters/spark/tier_01_drafts/review_01"
            output.parent.mkdir(parents=True)
            original_root = MODULE.ROOT
            original_audit_root = AUDIT_MODULE.ROOT
            MODULE.ROOT = project
            AUDIT_MODULE.ROOT = project
            try:
                result = MODULE.create_candidate(manifest_path, output)
                item = result["items"][0]
                candidate = output / item["file"]
                image = Image.open(candidate).convert("RGBA")
                image.putpixel((item["safety_margin_px"] + 20, item["safety_margin_px"] + 25), (255, 0, 255, 255))
                image.save(candidate)
                report = AUDIT_MODULE.audit_candidate(output)
                self.assertEqual(report["status"], "FAIL")
                self.assertIn("image_hash_mismatch", report["items"][0]["errors"])
                self.assertIn("source_rgb_changed", report["items"][0]["errors"])
            finally:
                MODULE.ROOT = original_root
                AUDIT_MODULE.ROOT = original_audit_root


if __name__ == "__main__":
    unittest.main()
