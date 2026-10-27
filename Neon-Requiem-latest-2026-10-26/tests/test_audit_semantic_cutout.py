import unittest

from PIL import Image, ImageDraw

from tools.art.audit_semantic_cutout import audit_cutout


class AuditSemanticCutoutTests(unittest.TestCase):
    def make_good_cutout(self):
        image = Image.new("RGBA", (100, 100), (0, 0, 0, 0))
        ImageDraw.Draw(image).rectangle((10, 10, 89, 89), fill=(200, 30, 50, 255))
        return image

    def test_clean_cutout_passes_mechanical_gate(self):
        report = audit_cutout(self.make_good_cutout())
        self.assertEqual(report["status"], "PASS")
        self.assertFalse(report["production_approved"])
        self.assertEqual(report["external_low_alpha_pixels"], 0)

    def test_insufficient_margin_fails(self):
        image = Image.new("RGBA", (100, 100), (0, 0, 0, 0))
        ImageDraw.Draw(image).rectangle((2, 10, 97, 89), fill=(200, 30, 50, 255))
        report = audit_cutout(image)
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("insufficient_transparent_margin", report["failures"])

    def test_diffuse_halo_outside_edge_tolerance_fails(self):
        image = self.make_good_cutout()
        image.putpixel((2, 50), (255, 0, 255, 8))
        report = audit_cutout(image, max_external_halo_pixels=0)
        self.assertIn("external_low_alpha_halo", report["failures"])

    def test_antialias_pixels_inside_tolerance_do_not_count_as_halo(self):
        image = self.make_good_cutout()
        image.putpixel((8, 50), (255, 0, 255, 8))
        report = audit_cutout(image, max_external_halo_pixels=0)
        self.assertEqual(report["external_low_alpha_pixels"], 0)

    def test_disconnected_pieces_are_reported_but_do_not_auto_approve_or_reject(self):
        image = Image.new("RGBA", (100, 100), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        draw.rectangle((10, 10, 75, 75), fill=(200, 30, 50, 255))
        draw.rectangle((80, 30, 85, 35), fill=(30, 200, 50, 255))
        report = audit_cutout(image)
        diagnostic = report["connectivity_diagnostic"]
        self.assertEqual(report["status"], "PASS")
        self.assertFalse(report["production_approved"])
        self.assertEqual(diagnostic["neighbor_rule"], "4-connected")
        self.assertEqual(diagnostic["component_count"], 2)
        self.assertEqual(diagnostic["component_areas_px_descending"], [4356, 36])
        self.assertEqual(
            diagnostic["component_bounds_xyxy_exclusive_descending_area"],
            [[10, 10, 76, 76], [80, 30, 86, 36]],
        )
        self.assertAlmostEqual(diagnostic["largest_secondary_component_ratio"], 36 / 4356, places=6)

    def test_rejects_non_rgba_input(self):
        with self.assertRaises(ValueError):
            audit_cutout(Image.new("RGB", (10, 10), "red"))

    def test_rejects_empty_threshold_mask(self):
        with self.assertRaises(ValueError):
            audit_cutout(Image.new("RGBA", (10, 10), (0, 0, 0, 0)))


if __name__ == "__main__":
    unittest.main()
