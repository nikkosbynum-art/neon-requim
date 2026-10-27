from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET
import zipfile

from PIL import Image

from tools.art.export_reviewed_openraster_parts import ROOT, export_layers


class OpenRasterPartExporterTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="ora_export_test_", dir=ROOT / "assets/characters/spark/tier_01_drafts")
        self.folder = Path(self.temp.name)
        self.workspace = self.folder / "sample.ora"
        self.selection = self.folder / "selection.json"
        self.output = self.folder / "candidate"
        self._write_workspace()

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _write_workspace(self, *, layer_name: str = "ATTACHMENT - SPARK drone 01", opacity: str = "1", source: str = "data/layer0.png", transparent: bool = False, extra_layer: str | None = None, layer_offset: tuple[int, int] = (2, 1), visible_pixel: tuple[int, int] = (0, 0)) -> None:
        image = Image.new("RGBA", (3, 2), (0, 0, 0, 0))
        if not transparent:
            image.putpixel(visible_pixel, (220, 50, 80, 255))
        layer_stream = self.folder / "layer.png"
        image.save(layer_stream)
        root = ET.Element("image", {"w": "8", "h": "6", "name": "fixture", "version": "0.0.1"})
        stack = ET.SubElement(root, "stack")
        ET.SubElement(stack, "layer", {
            "name": layer_name,
            "src": source,
            "x": str(layer_offset[0]),
            "y": str(layer_offset[1]),
            "opacity": opacity,
            "visibility": "hidden",
            "composite-op": "svg:src-over",
        })
        if extra_layer:
            ET.SubElement(stack, "layer", {
                "name": extra_layer,
                "src": "data/layer1.png",
                "x": "4",
                "y": "1",
                "opacity": "1",
                "visibility": "hidden",
                "composite-op": "svg:src-over",
            })
        metadata = {
            "status": "EDIT PREP ONLY - QUARANTINED",
            "character_id": "SPARK",
            "canvas_px": [8, 6],
            "anatomy_reference": "docs/visual_qa/SPARK_T1_ANATOMY_TURNAROUND_01_2026-10-25.png",
            "production_approved": False,
            "runtime_integrated": False,
        }
        with zipfile.ZipFile(self.workspace, "w") as archive:
            archive.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
            archive.writestr("stack.xml", ET.tostring(root, encoding="utf-8"))
            archive.writestr("edit_workspace_manifest.json", json.dumps(metadata))
            archive.write(layer_stream, "data/layer0.png")
            if extra_layer:
                archive.write(layer_stream, "data/layer1.png")
        layer_stream.unlink()

    def _selection(self) -> dict:
        return {
            "schema_version": 1,
            "character_id": "SPARK",
            "tier_id": 1,
            "parts": [{
                "part_id": "attack_drone_01",
                "layer_name": "ATTACHMENT - SPARK drone 01",
                "category": "drone",
                "attachment_role_id": "spark.attack_drone_01",
                "owner_character_id": "SPARK",
                "known_behavior": "One of exactly three source-backed attack drones; its behavior is simulation-driven.",
                "function_status": "source_backed",
                "presentation_triggers": ["ability_activated", "attack_resolved"],
                "gameplay_authority": "combat_simulation",
            }],
        }

    def _save_selection(self, data: dict | None = None) -> None:
        self.selection.write_text(json.dumps(data if data is not None else self._selection()), encoding="utf-8")

    def test_preserves_canvas_alignment_and_quarantine_for_drone(self) -> None:
        self._save_selection()
        export_layers(self.workspace, self.selection, self.output)
        with Image.open(self.output / "parts/attack_drone_01.png") as image:
            self.assertEqual(image.size, (8, 6))
            self.assertEqual(image.getchannel("A").getbbox(), (2, 1, 3, 2))
        manifest = json.loads((self.output / "review_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "REVIEW CANDIDATE - QUARANTINED")
        self.assertFalse(manifest["production_approved"])
        self.assertFalse(manifest["runtime_integrated"])
        drone = manifest["parts"][0]
        self.assertEqual(drone["attachment_role_id"], "spark.attack_drone_01")
        self.assertEqual(drone["gameplay_authority"], "combat_simulation")
        self.assertTrue(drone["source_layer_sha256"])

    def test_clips_negative_layer_offset_without_shifting_pixels(self) -> None:
        self._write_workspace(layer_offset=(-1, -1), visible_pixel=(1, 1))
        self._save_selection()
        export_layers(self.workspace, self.selection, self.output)
        with Image.open(self.output / "parts/attack_drone_01.png") as image:
            self.assertEqual(image.size, (8, 6))
            self.assertEqual(image.getchannel("A").getbbox(), (0, 0, 1, 1))

    def test_weapon_and_presentation_only_accessory_metadata_are_supported(self) -> None:
        base = self._selection()["parts"][0]
        cases = [
            ("ATTACHMENT - SPARK weapon", "weapon", "spark.weapon.primary", "combat_simulation", ["UNRESOLVED"]),
            ("ATTACHMENT - SPARK backpack cable", "cable", "spark.pack.cable", "presentation_only", ["always_attached"]),
        ]
        for index, (layer_name, category, attachment_role_id, authority, triggers) in enumerate(cases):
            with self.subTest(category=category):
                self._write_workspace(layer_name=layer_name)
                output = self.folder / f"candidate_{index}"
                part = dict(base)
                part.update({
                    "part_id": f"equipment_{index}",
                    "layer_name": layer_name,
                    "category": category,
                    "attachment_role_id": attachment_role_id,
                    "known_behavior": "Source-backed attachment identity; unresolved details remain explicitly configurable.",
                    "function_status": "unresolved" if "UNRESOLVED" in triggers else "source_backed",
                    "presentation_triggers": triggers,
                    "gameplay_authority": authority,
                })
                self._save_selection({"schema_version": 1, "character_id": "SPARK", "tier_id": 1, "parts": [part]})
                export_layers(self.workspace, self.selection, output)
                manifest = json.loads((output / "review_manifest.json").read_text(encoding="utf-8"))
                self.assertEqual(manifest["parts"][0]["category"], category)
                self.assertEqual(manifest["parts"][0]["gameplay_authority"], authority)

    def test_rejects_blank_layer_without_creating_output(self) -> None:
        self._write_workspace(transparent=True)
        self._save_selection()
        with self.assertRaisesRegex(ValueError, "fully transparent"):
            export_layers(self.workspace, self.selection, self.output)
        self.assertFalse(self.output.exists())

    def test_rejects_unresolved_owner_mismatch(self) -> None:
        data = self._selection()
        data["parts"][0]["owner_character_id"] = "ECHO"
        self._save_selection(data)
        with self.assertRaisesRegex(ValueError, "owner_character_id"):
            export_layers(self.workspace, self.selection, self.output)
        self.assertFalse(self.output.exists())

    def test_rejects_reference_layer_as_exportable_part(self) -> None:
        self._write_workspace(layer_name="REFERENCE - approved anatomy")
        selection = self._selection()
        selection["parts"][0]["layer_name"] = "REFERENCE - approved anatomy"
        self._save_selection(selection)
        with self.assertRaisesRegex(ValueError, "not a semantic authoring layer"):
            export_layers(self.workspace, self.selection, self.output)
        self.assertFalse(self.output.exists())

    def test_rejects_duplicate_part_identity(self) -> None:
        self._write_workspace(extra_layer="ATTACHMENT - SPARK drone 02")
        data = self._selection()
        second = dict(data["parts"][0])
        second.update({"layer_name": "ATTACHMENT - SPARK drone 02"})
        data["parts"].append(second)
        self._save_selection(data)
        with self.assertRaisesRegex(ValueError, "invalid or duplicate part_id"):
            export_layers(self.workspace, self.selection, self.output)
        self.assertFalse(self.output.exists())

    def test_multiple_visual_parts_may_share_an_attachment_role(self) -> None:
        self._write_workspace(layer_name="ATTACHMENT - SPARK rifle receiver", extra_layer="ATTACHMENT - SPARK rifle optic")
        part = dict(self._selection()["parts"][0])
        part.update({
            "part_id": "rifle_receiver",
            "layer_name": "ATTACHMENT - SPARK rifle receiver",
            "category": "weapon",
            "attachment_role_id": "spark.primary_rifle",
            "known_behavior": "Rifle components share one source-backed role; attack behavior remains simulation-owned.",
        })
        optic = dict(part)
        optic.update({"part_id": "rifle_optic", "layer_name": "ATTACHMENT - SPARK rifle optic"})
        self._save_selection({"schema_version": 1, "character_id": "SPARK", "tier_id": 1, "parts": [part, optic]})
        export_layers(self.workspace, self.selection, self.output)
        manifest = json.loads((self.output / "review_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual([item["attachment_role_id"] for item in manifest["parts"]], ["spark.primary_rifle", "spark.primary_rifle"])
        self.assertEqual([item["runtime_attachment_id"] for item in manifest["parts"]], [None, None])
        self.assertEqual([item["runtime_attachment_id_status"] for item in manifest["parts"]], ["assigned_per_owner_instance_at_runtime"] * 2)

    def test_rejects_non_unit_layer_opacity(self) -> None:
        self._write_workspace(opacity="0.5")
        self._save_selection()
        with self.assertRaisesRegex(ValueError, "non-unit opacity"):
            export_layers(self.workspace, self.selection, self.output)
        self.assertFalse(self.output.exists())

    def test_refuses_overwrite(self) -> None:
        self.output.mkdir()
        self._save_selection()
        with self.assertRaises(FileExistsError):
            export_layers(self.workspace, self.selection, self.output)

    def test_all_twelve_actual_workspaces_refuse_blank_equipment_layers(self) -> None:
        plan = json.loads((ROOT / "tools/art/rigging_prep_all_12.json").read_text(encoding="utf-8"))
        categories = {
            "BULWARK": "accessory", "BREAKER": "cyberware", "CIPHER": "weapon",
            "SPARK": "drone", "SPECTER": "weapon", "IRONCLAD": "weapon",
            "STITCH": "cloth", "RECOIL": "cyberware", "ECHO": "drone",
            "VECTOR": "accessory", "DEADLOCK": "weapon", "GLITCH": "cloth",
        }
        self.assertEqual(set(categories), {entry["id"] for entry in plan["characters"]})
        for record in plan["characters"]:
            character_id = record["id"]
            layer_name = "ATTACHMENT - " + record["attachment_workspace_layers"][0]
            contract = record["functional_attachment_contract"][0]
            selection = {
                "schema_version": 1,
                "character_id": character_id,
                "tier_id": 1,
                "parts": [{
                    "part_id": "attachment_blank_layer_probe",
                    "layer_name": layer_name,
                    "category": categories[character_id],
                    "attachment_role_id": f"{character_id.lower()}.blank_probe",
                    "owner_character_id": character_id,
                    "known_behavior": contract["known_behavior"],
                    "function_status": "source_backed",
                    "presentation_triggers": ["UNRESOLVED"],
                    "gameplay_authority": "combat_simulation",
                }],
            }
            self._save_selection(selection)
            batch = record.get("workspace_batch", plan.get("active_workspace_batch", "edit_batch_01"))
            version = record.get("workspace_version", plan.get("active_workspace_version", 1))
            workspace = ROOT / f"assets/characters/{character_id.lower()}/tier_01_drafts/{batch}/{character_id}_T1_ART_EDIT_WORKSPACE_{version:02d}_QUARANTINED.ora"
            output = ROOT / f"assets/characters/{character_id.lower()}/tier_01_drafts/_blank_layer_probe"
            with self.subTest(character=character_id), self.assertRaisesRegex(ValueError, "fully transparent"):
                export_layers(workspace, self.selection, output)
            self.assertFalse(output.exists(), character_id)

    def test_rejects_runtime_or_non_draft_output_path(self) -> None:
        self._save_selection()
        runtime_path = ROOT / "assets/characters/spark/art/new_candidate"
        with self.assertRaisesRegex(ValueError, "must remain inside"):
            export_layers(self.workspace, self.selection, runtime_path)
        self.assertFalse(runtime_path.exists())


if __name__ == "__main__":
    unittest.main()
