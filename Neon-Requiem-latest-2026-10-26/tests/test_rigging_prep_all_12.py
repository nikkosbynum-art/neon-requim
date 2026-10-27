import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools/art/audit_rigging_prep_all_12.py"
SPEC = importlib.util.spec_from_file_location("audit_rigging_prep_all_12", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class RiggingPrepRosterTests(unittest.TestCase):
    def test_all_twelve_roster_ids_have_complete_existing_sources(self):
        self.assertEqual(MODULE.validate(), [])

    def test_generated_open_raster_archives_match_all_twelve_attachment_plans(self):
        import json
        plan = json.loads((ROOT / "tools/art/rigging_prep_all_12.json").read_text(encoding="utf-8"))
        self.assertEqual(len(plan["characters"]), 12)
        for record in plan["characters"]:
            with self.subTest(character=record["id"]):
                self.assertEqual(MODULE._validate_workspace(record), [])

    def test_functional_attachment_contract_covers_each_character_and_keeps_open_count(self):
        self.assertEqual(MODULE.validate(), [])
        import json
        plan = json.loads((ROOT / "tools/art/rigging_prep_all_12.json").read_text(encoding="utf-8"))
        self.assertTrue(all(record.get("functional_attachment_contract") for record in plan["characters"]))
        spark = next(record for record in plan["characters"] if record["id"] == "SPARK")
        drones = [entry for entry in spark["functional_attachment_contract"] if entry["id"] == "attack_drones_01_03"]
        self.assertEqual(len(drones), 1)
        self.assertIn("exactly three", drones[0]["known_behavior"].lower())
        echo = next(record for record in plan["characters"] if record["id"] == "ECHO")
        self.assertTrue(any("count" in question.lower() and "unresolved" in question.lower() for question in echo["attachment_open_questions"]))


if __name__ == "__main__":
    unittest.main()
