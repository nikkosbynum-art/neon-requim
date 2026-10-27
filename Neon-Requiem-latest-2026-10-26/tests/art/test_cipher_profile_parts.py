import json
import importlib.util
import unittest
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
ASSET_DIR = ROOT / "assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_01"
EXTRACTOR_PATH = ROOT / "tools/art/extract_cipher_profile_parts.py"
SPEC = importlib.util.spec_from_file_location("cipher_profile_extractor", EXTRACTOR_PATH)
EXTRACTOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(EXTRACTOR)


class CipherProfilePartTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ASSET_DIR / "parts_manifest.json").read_text(encoding="utf-8"))

    def assert_cutout_has_safe_margin(self, image, minimum_fraction=0.10):
        self.assertEqual(image.mode, "RGBA")
        alpha = image.getchannel("A")
        bounds = alpha.getbbox()
        self.assertIsNotNone(bounds)
        left, top, right, bottom = bounds
        width, height = image.size
        margins = (left / width, top / height, (width - right) / width, (height - bottom) / height)
        self.assertTrue(all(value >= minimum_fraction for value in margins), f"unsafe margins: {margins}")
        for point in ((0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1)):
            self.assertEqual(alpha.getpixel(point), 0, f"corner not transparent: {point}")

    def test_manifest_keeps_source_and_quarantine_status(self):
        self.assertEqual(self.manifest["status"], "QUARANTINED REVIEW CANDIDATE")
        self.assertEqual(self.manifest["source"], "docs/visual_qa/CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png")
        self.assertEqual(len(self.manifest["parts"]), 10)
        self.assertIn("provisional", self.manifest["pivot_and_overlap_status"])

    def test_every_reference_cutout_is_rgba_with_transparent_safety_margin(self):
        for semantic_name, item in self.manifest["parts"].items():
            with self.subTest(part=semantic_name):
                with Image.open(ASSET_DIR / item["file"]) as image:
                    self.assert_cutout_has_safe_margin(image)
                    self.assertEqual(list(image.size), item["size_px"])
                    self.assertEqual(item["safety_margin_px"], 60)

    def test_generated_rifle_is_a_separate_transparent_attachment(self):
        with Image.open(ASSET_DIR / "CIPHER_T1_RIFLE_ATTACHMENT_CANDIDATE_01.png") as image:
            self.assert_cutout_has_safe_margin(image)
            self.assertEqual(image.size, (540, 270))

    def test_assembly_preview_and_pose_review_exist(self):
        with Image.open(ASSET_DIR / "CIPHER_T1_REFERENCE_CUTOUT_ASSEMBLY_CANDIDATE_01.png") as assembly:
            self.assertEqual(assembly.size, (330, 960))
            self.assertEqual(assembly.mode, "RGBA")
        with Image.open(ROOT / "docs/visual_qa/CIPHER_T1_RIG_POSE_REVIEW_CANDIDATE_01.png") as review:
            self.assertEqual(review.size, (1280, 720))

    def test_neutral_assembly_retains_reference_silhouette(self):
        source_path = ROOT / self.manifest["source"]
        with Image.open(source_path) as source_image:
            source = EXTRACTOR.exterior_background_mask(source_image.crop(EXTRACTOR.SOURCE_CROP))
        with Image.open(ASSET_DIR / "CIPHER_T1_REFERENCE_CUTOUT_ASSEMBLY_CANDIDATE_01.png") as assembly:
            source_mask = source.getchannel("A").point(lambda a: 255 if a > 32 else 0)
            assembly_mask = assembly.getchannel("A").point(lambda a: 255 if a > 32 else 0)
        missing = ImageChops.subtract(source_mask, assembly_mask).histogram()[255]
        extra = ImageChops.subtract(assembly_mask, source_mask).histogram()[255]
        source_area = source_mask.histogram()[255]
        intersection = source_area - missing
        union = source_area + extra
        self.assertEqual(extra, 0, "Assembly must not invent pixels outside the extracted source silhouette.")
        self.assertGreaterEqual(intersection / union, 0.99, "Neutral assembled silhouette must retain at least 99% of source profile.")


if __name__ == "__main__":
    unittest.main()
