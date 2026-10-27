from __future__ import annotations

import json
import unittest
from pathlib import Path

from PIL import Image, ImageChops

from tools.art.render_semantic_ownership_board import ROOT


class SpecterBladeCandidateTests(unittest.TestCase):
    def test_visible_blade_cutouts_preserve_source_pixels_and_stay_quarantined(self) -> None:
        candidate = ROOT / "assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01"
        manifest = json.loads((candidate / "parts_manifest.json").read_text(encoding="utf-8"))
        source_path = ROOT / manifest["source_image"]
        with Image.open(source_path) as opened:
            source = opened.convert("RGB")

        self.assertEqual(manifest["character_id"], "SPECTER")
        self.assertFalse(manifest["production_approved"])
        self.assertFalse(manifest["semantic_review_passed"])
        self.assertFalse(manifest["pivots_authored"])
        self.assertFalse(manifest["deformation_reviewed"])
        self.assertFalse(manifest["runtime_integrated"])
        self.assertIn("grip region occluded by glove", manifest["source_view"])
        self.assertEqual(
            {part["part_id"] for part in manifest["parts"]},
            {"handheld_blade_hilt_visible", "handheld_blade_body_visible"},
        )

        masks = []
        for record in manifest["parts"]:
            with Image.open(candidate / record["file"]) as opened:
                part = opened.convert("RGBA")
            self.assertEqual(part.size, source.size)
            alpha = part.getchannel("A")
            self.assertIsNotNone(alpha.getbbox())
            # Compare only selected source pixels; invisible canvas RGB is irrelevant.
            rgb_difference = ImageChops.difference(source, part.convert("RGB"))
            selected_difference = ImageChops.multiply(rgb_difference.getchannel("R"), alpha)
            for channel in ("G", "B"):
                selected_difference = ImageChops.lighter(
                    selected_difference,
                    ImageChops.multiply(rgb_difference.getchannel(channel), alpha),
                )
            self.assertIsNone(selected_difference.getbbox(), record["part_id"])
            masks.append(alpha.point(lambda value: 255 if value else 0))

        overlap = ImageChops.multiply(masks[0], masks[1])
        self.assertEqual(overlap.histogram()[255], 0)


if __name__ == "__main__":
    unittest.main()
