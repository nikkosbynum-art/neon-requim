import json
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET
import zipfile

from PIL import Image

from tools.art.build_roster_edit_workspaces import ROOT, build_all, load_plan


class RosterEditWorkspaceTests(unittest.TestCase):
    def test_plan_has_all_twelve_and_attachment_validation_contract(self):
        plan = load_plan()
        self.assertEqual(len(plan["characters"]), 12)
        self.assertGreaterEqual(len(plan.get("functional_attachment_validation_gates", [])), 5)
        ids = {item["id"] for item in plan["characters"]}
        self.assertEqual(len(ids), 12)
        for item in plan["characters"]:
            self.assertTrue(item["attachment_workspace_layers"], item["id"])
            self.assertEqual(len(item["attachment_workspace_layers"]), len(set(item["attachment_workspace_layers"])), item["id"])
            self.assertTrue(item["functional_attachment_contract"], item["id"])
            for attachment in item["functional_attachment_contract"]:
                self.assertTrue(attachment.get("id"), item["id"])
                self.assertTrue(attachment.get("kind"), item["id"])
                self.assertTrue(attachment.get("known_behavior"), item["id"])
                self.assertTrue(attachment.get("gameplay_authority"), item["id"])

    def test_builds_twelve_quarantined_ora_workspaces_with_blank_art_layers(self):
        with tempfile.TemporaryDirectory(dir=ROOT / "tests") as temp:
            outputs = build_all(Path(temp))
            self.assertEqual(len(outputs), 12)
            self.assertEqual(len({p.name for p in outputs}), 12)
            plan_by_id = {item["id"]: item for item in load_plan()["characters"]}
            for output in outputs:
                with self.subTest(workspace=output.name):
                    with zipfile.ZipFile(output) as archive:
                        self.assertEqual(archive.read("mimetype"), b"image/openraster")
                        metadata = json.loads(archive.read("edit_workspace_manifest.json"))
                        self.assertFalse(metadata["production_approved"])
                        self.assertFalse(metadata["semantic_parts_created"])
                        self.assertFalse(metadata["art_pixels_changed"])
                        self.assertTrue(metadata["functional_attachment_contract"])
                        self.assertIn("One independently moving semantic item per ATTACHMENT layer", metadata["attachment_layer_policy"])
                        record = plan_by_id[metadata["character_id"]]
                        self.assertEqual(metadata["attachment_workspace_layers"], record["attachment_workspace_layers"])
                        stack = ET.fromstring(archive.read("stack.xml")).find("./stack")
                        layers = stack.findall("./layer")
                        layer_names = {layer.attrib["name"] for layer in layers}
                        concept_layers = [layer for layer in layers if layer.attrib["name"].startswith("REFERENCE - approved concept")]
                        readme_path = output.parent / "README_EDIT_PREP.md"
                        readme_text = readme_path.read_text(encoding="utf-8")
                        self.assertIn("one independently moving semantic item per layer", readme_text.lower())
                        if metadata["concept_embedded_same_scale"]:
                            self.assertEqual(len(concept_layers), 1)
                            self.assertEqual(concept_layers[0].attrib["visibility"], "hidden")
                            self.assertIn("embedded as a hidden layer", readme_text)
                        else:
                            self.assertEqual(concept_layers, [])
                            self.assertIn("NOT embedded because its canvas differs", readme_text)
                            self.assertIn(metadata["concept_reference"], readme_text)
                        self.assertGreaterEqual(len(layers), len(metadata["attachment_workspace_layers"]) + 16)
                        for attachment_label in record["attachment_workspace_layers"]:
                            layer_name = f"ATTACHMENT - {attachment_label}"
                            self.assertIn(layer_name, layer_names, f"{metadata['character_id']}: {layer_name}")
                        for layer in layers:
                            if layer.attrib["name"].startswith("ATTACHMENT -"):
                                self.assertEqual(layer.attrib["visibility"], "hidden", layer.attrib["name"])
                        anatomy_layers = [layer for layer in layers if layer.attrib["name"].startswith("REFERENCE - approved anatomy") or layer.attrib["name"].startswith("REFERENCE - approved anatomy/target")]
                        self.assertEqual(sum(layer.attrib["visibility"] == "visible" for layer in anatomy_layers), 1)
                        for layer in layers:
                            if layer.attrib["name"].startswith("ART -") or layer.attrib["name"].startswith("ATTACHMENT -"):
                                with archive.open(layer.attrib["src"]) as stream:
                                    with Image.open(stream) as image:
                                        self.assertEqual(image.mode, "RGBA")
                                        self.assertEqual(image.getchannel("A").getbbox(), None, layer.attrib["name"])

    def test_functional_contract_preserves_drone_count_and_simulation_authority(self):
        plan = load_plan()
        spark = next(item for item in plan["characters"] if item["id"] == "SPARK")
        swarm = next(item for item in spark["functional_attachment_contract"] if item["id"] == "attack_drones_01_03")
        self.assertIn("exactly three", swarm["known_behavior"].lower())
        self.assertEqual(swarm["gameplay_authority"], "Combat simulation")
        self.assertTrue(swarm["unknowns"])
        echo = next(item for item in plan["characters"] if item["id"] == "ECHO")
        echo_drones = next(item for item in echo["functional_attachment_contract"] if item["id"] == "sensory_drones_and_decoys")
        self.assertIn("unresolved", " ".join(echo_drones["unknowns"]).lower())
        self.assertEqual(echo_drones["gameplay_authority"], "Combat simulation")

    def test_spark_has_three_independent_drone_authoring_layers(self):
        plan = load_plan()
        spark = next(item for item in plan["characters"] if item["id"] == "SPARK")
        labels = spark["attachment_workspace_layers"]
        for unit in ("01", "02", "03"):
            self.assertTrue(any(f"drone {unit}" in label.lower() for label in labels))

    def test_independently_owned_equipment_has_separate_authoring_layers(self):
        plan = load_plan()
        by_id = {item["id"]: item["attachment_workspace_layers"] for item in plan["characters"]}
        expectations = {
            "IRONCLAD": ("shoulder armor plate", "elbow armor plate", "hip armor plate", "knee armor plate", "shin armor plate"),
            "SPECTER": ("main cape/cloak sheet", "hood", "mask"),
            "STITCH": ("long coat front panel", "long coat back panel", "medical harness", "carried case"),
            "GLITCH": ("sidearm", "thigh gear"),
        }
        for character_id, fragments in expectations.items():
            labels = by_id[character_id]
            for fragment in fragments:
                self.assertEqual(sum(fragment in label.lower() for label in labels), 1, f"{character_id}: {fragment}")

    def test_visual_review_conflicts_are_preserved_as_open_not_guessed(self):
        plan = load_plan()
        by_id = {item["id"]: item for item in plan["characters"]}
        self.assertIn("distinct from the rifle-mounted scope", " ".join(by_id["CIPHER"]["attachment_workspace_layers"]).lower())
        self.assertIn("wrench/tool", " ".join(by_id["SPARK"]["attachment_workspace_layers"]).lower())
        self.assertIn("continuous torn silhouette", " ".join(by_id["SPECTER"]["attachment_workspace_layers"]).lower())
        self.assertIn("no stow point is specified", " ".join(by_id["IRONCLAD"]["attachment_workspace_layers"]).lower())
        self.assertIn("handheld vial", " ".join(by_id["STITCH"]["attachment_workspace_layers"]).lower())
        deadlock_questions = " ".join(by_id["DEADLOCK"].get("attachment_open_questions", [])).lower()
        self.assertIn("one rifle", deadlock_questions)
        self.assertIn("two weapons", deadlock_questions)
        glitch_questions = " ".join(by_id["GLITCH"].get("attachment_open_questions", [])).lower()
        self.assertIn("sidearm", glitch_questions)
        self.assertIn("blade-like", glitch_questions)
        self.assertEqual(by_id["DEADLOCK"]["workspace_batch"], "attachment_decomposition_02")
        self.assertEqual(by_id["GLITCH"]["workspace_version"], 2)

    def test_echo_drone_count_discrepancy_stays_open(self):
        plan = load_plan()
        echo = next(item for item in plan["characters"] if item["id"] == "ECHO")
        self.assertTrue(echo.get("attachment_open_questions"))
        self.assertTrue(any("count" in note.lower() for note in echo["attachment_open_questions"]))
        labels = echo["attachment_workspace_layers"]
        self.assertTrue(any("count unresolved" in label.lower() for label in labels))
        self.assertTrue(any("decoy visual" in label.lower() for label in labels))
        self.assertTrue(any("tether/cable segment" in label.lower() for label in labels))
        self.assertEqual(echo["workspace_batch"], "attachment_decomposition_01")
        self.assertEqual(echo["workspace_version"], 1)

    def test_cipher_candidate_05_is_embedded_only_as_hidden_failed_diagnostic(self):
        with tempfile.TemporaryDirectory(dir=ROOT / "tests") as temp:
            outputs = build_all(Path(temp), "CIPHER")
            with zipfile.ZipFile(outputs[0]) as archive:
                metadata = json.loads(archive.read("edit_workspace_manifest.json"))
                self.assertFalse(metadata["production_approved"])
                diagnostic_layers = [layer for layer in ET.fromstring(archive.read("stack.xml")).find("./stack").findall("./layer") if layer.attrib["name"].startswith("DIAGNOSTIC ONLY - CIPHER candidate 05")]
                self.assertEqual(len(diagnostic_layers), 10)
                self.assertTrue(all(layer.attrib["visibility"] == "hidden" for layer in diagnostic_layers))

    def test_refuses_to_overwrite_existing_workspace(self):
        with tempfile.TemporaryDirectory(dir=ROOT / "tests") as temp:
            output_root = Path(temp)
            output = output_root / "bulwark" / "BULWARK_T1_ART_EDIT_WORKSPACE_01_QUARANTINED.ora"
            output.parent.mkdir(parents=True)
            output.write_bytes(b"preserve")
            with self.assertRaises(FileExistsError):
                build_all(output_root, "BULWARK")
            self.assertEqual(output.read_bytes(), b"preserve")


if __name__ == "__main__":
    unittest.main()
