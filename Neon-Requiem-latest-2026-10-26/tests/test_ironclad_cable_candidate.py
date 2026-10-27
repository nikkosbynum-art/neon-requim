from __future__ import annotations

import hashlib
import json
from pathlib import Path
import unittest

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CANDIDATE_DIR = ROOT / "assets/characters/ironclad/tier_01_drafts/attachment_cutout_candidate_01"
PROFILE = ROOT / "assets/characters/ironclad/tier_01_drafts/profile_mesh_rig_candidate_01/IRONCLAD_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png"
REFERENCE = ROOT / "docs/visual_qa/IRONCLAD_T1_ANATOMY_TURNAROUND_01_2026-10-25.png"
QA_BOARD = ROOT / "docs/visual_qa/IRONCLAD_T1_BACK_POWER_CABLE_LOOP_CANDIDATE_01_QUARANTINED.png"


class IroncladCableCandidateTests(unittest.TestCase):
    def test_candidate_is_source_aligned_and_stays_quarantined(self) -> None:
        manifest = json.loads((CANDIDATE_DIR / "parts_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "QUARANTINED REVIEW CANDIDATE")
        for field in ("production_approved", "semantic_review_passed", "pivots_authored", "deformation_reviewed", "runtime_integrated"):
            self.assertIs(manifest[field], False)
        self.assertEqual(hashlib.sha256(PROFILE.read_bytes()).hexdigest(), manifest["source_sha256"])
        upstream = manifest["upstream_sources"][0]
        self.assertEqual(hashlib.sha256(REFERENCE.read_bytes()).hexdigest(), upstream["source_sha256"])

        source = Image.open(PROFILE).convert("RGBA")
        approved = Image.open(REFERENCE).convert("RGBA")
        part = manifest["parts"][0]
        cutout = Image.open(CANDIDATE_DIR / part["file"]).convert("RGBA")
        self.assertEqual(cutout.size, source.size)
        self.assertEqual(cutout.getchannel("A").getbbox(), (190, 598, 259, 649))
        self.assertEqual(sum(cutout.getchannel("A").histogram()[1:]), 781)
        self.assertIsNone(part["pivot_source_xy"])

        for y in range(cutout.height):
            for x in range(cutout.width):
                pixel = cutout.getpixel((x, y))
                if pixel[3] == 0:
                    continue
                profile_pixel = source.getpixel((x, y))
                ref_x, ref_y = x + 441, y - 123
                reference_pixel = approved.getpixel((ref_x, ref_y))
                self.assertGreater(profile_pixel[3], 0)
                self.assertEqual(pixel[:3], profile_pixel[:3])
                self.assertEqual(pixel[:3], reference_pixel[:3])

        self.assertTrue(QA_BOARD.is_file())


if __name__ == "__main__":
    unittest.main()
