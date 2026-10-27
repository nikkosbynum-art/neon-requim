import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

from tools.art.extract_character_atlas_components import (
    connected_components,
    extract_components,
)


class ExtractCharacterAtlasComponentsTests(unittest.TestCase):
    def make_image(self) -> Image.Image:
        image = Image.new("RGBA", (80, 60), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        draw.rectangle((5, 7, 20, 25), fill=(255, 0, 0, 255))
        draw.rectangle((45, 30, 60, 50), fill=(0, 255, 0, 255))
        draw.point((22, 25), fill=(0, 0, 255, 20))
        return image

    def test_connected_components_ignores_subthreshold_alpha(self):
        components = connected_components(self.make_image(), alpha_threshold=32)
        self.assertEqual(len(components), 2)
        self.assertEqual(components[0], {"area": 304, "x0": 5, "y0": 7, "x1": 20, "y1": 25})
        self.assertEqual(components[1], {"area": 336, "x0": 45, "y0": 30, "x1": 60, "y1": 50})

    def test_extracts_transparent_padded_crops_and_quarantine_metadata(self):
        with tempfile.TemporaryDirectory(dir=Path(__file__).parent) as tmp:
            root = Path(tmp)
            source = root / "atlas.png"
            out = root / "parts"
            self.make_image().save(source)

            records = extract_components(
                source,
                out,
                padding=2,
                minimum_area=1,
                trim_subthreshold_alpha=True,
            )

            self.assertEqual(len(records), 2)
            with Image.open(out / "component_01.png") as crop:
                self.assertEqual(crop.mode, "RGBA")
                self.assertEqual(crop.size, (20, 23))
                self.assertEqual(crop.getpixel((0, 0))[3], 0)
                self.assertEqual(crop.getpixel((19, 20))[3], 0)
            metadata = json.loads((out / "components.json").read_text(encoding="utf-8"))
            self.assertFalse(metadata["semantic_part_names_assigned"])
            self.assertFalse(metadata["pivots_authored"])
            self.assertFalse(metadata["production_approved"])
            self.assertTrue(metadata["subthreshold_alpha_trimmed"])

    def test_refuses_nonempty_output_without_force(self):
        with tempfile.TemporaryDirectory(dir=Path(__file__).parent) as tmp:
            root = Path(tmp)
            source = root / "atlas.png"
            out = root / "parts"
            self.make_image().save(source)
            out.mkdir()
            (out / "keep.txt").write_text("preserve", encoding="utf-8")
            with self.assertRaises(FileExistsError):
                extract_components(source, out)
            self.assertEqual((out / "keep.txt").read_text(encoding="utf-8"), "preserve")

    def test_requires_rgba_input(self):
        image = Image.new("RGB", (10, 10), "white")
        with self.assertRaises(ValueError):
            connected_components(image)


if __name__ == "__main__":
    unittest.main()
