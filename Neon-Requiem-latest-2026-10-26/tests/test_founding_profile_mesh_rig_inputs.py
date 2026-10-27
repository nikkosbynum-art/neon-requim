import json
from pathlib import Path
import sys
import unittest

from PIL import Image
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from tools.art.audit_semantic_cutout import audit_cutout

CHARACTERS = [
    "BULWARK", "SPARK", "SPECTER", "IRONCLAD", "STITCH",
    "RECOIL", "ECHO", "VECTOR", "DEADLOCK", "GLITCH",
]
PAD = 128


def candidate_dir(character: str) -> Path:
    return ROOT / "assets" / "characters" / character.lower() / "tier_01_drafts" / "profile_mesh_rig_candidate_01"


class FoundingProfileMeshRigInputTests(unittest.TestCase):
    def test_all_founders_have_clean_source_faithful_profile_inputs_and_rig_manifests(self):
        for character in CHARACTERS:
            with self.subTest(character=character):
                directory = candidate_dir(character)
                parts = json.loads((directory / "parts_manifest.json").read_text(encoding="utf-8"))
                rig = json.loads((directory / "rig_manifest.json").read_text(encoding="utf-8"))
                candidate_path = directory / parts["candidate_image"]
                candidate = Image.open(candidate_path).convert("RGBA")
                source = Image.open(ROOT / parts["source"]).convert("RGB")

                self.assertEqual(parts["character"], character)
                self.assertEqual(rig["character"], character)
                self.assertEqual(rig["bone_count"], 19)
                self.assertEqual(len(rig["bone_landmarks_px"]), 12)
                self.assertEqual(rig["bone_landmark_padding_delta_px"], [64, 64])
                self.assertFalse(rig["runtime_approved"])
                self.assertIn("not modular", rig["readiness"])

                alpha_audit = audit_cutout(candidate)
                self.assertEqual(alpha_audit["status"], "PASS", (character, alpha_audit))
                self.assertEqual(alpha_audit["scope"], "mechanical_alpha_cutout_checks_only")

                crop_x, crop_y, _, _ = parts["source_crop_xyxy"]
                alpha = candidate.getchannel("A")
                samples = ((PAD, PAD), (candidate.width // 2, candidate.height // 2), (candidate.width - PAD - 1, candidate.height - PAD - 1))
                for x, y in samples:
                    if alpha.getpixel((x, y)) > 0:
                        source_pixel = source.getpixel((crop_x + x - PAD, crop_y + y - PAD))
                        self.assertEqual(candidate.getpixel((x, y))[:3], source_pixel)


if __name__ == "__main__":
    unittest.main()
