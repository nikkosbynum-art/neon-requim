"""Source-backed launch-district scope metadata stays distinct from runtime fixtures."""

from __future__ import annotations

import json
from pathlib import Path
import unittest


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCOPE_PATH = PROJECT_ROOT / "data" / "world" / "district_scope.json"
ZONE_FIXTURE_PATH = PROJECT_ROOT / "data" / "zones" / "undercity_prototype_zones.json"


class DistrictScopeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8-sig"))
        cls.zone_fixture = json.loads(ZONE_FIXTURE_PATH.read_text(encoding="utf-8-sig"))

    def test_approved_district_names_and_wave_bands_are_contiguous(self) -> None:
        expected = [
            ("Undercity", 1, 25),
            ("Neon Row", 26, 50),
            ("Black Grid", 51, 75),
            ("Enforcement Zone", 76, 100),
            ("The Spire", 101, 125),
        ]
        actual = [
            (district["display_name"], district["first_wave"], district["last_wave"])
            for district in self.scope["districts"]
        ]
        self.assertEqual(actual, expected)
        self.assertEqual(self.scope["endless_progression_starts_at_wave"], 126)
        for current, next_item in zip(self.scope["districts"], self.scope["districts"][1:]):
            self.assertEqual(current["last_wave"] + 1, next_item["first_wave"])

    def test_boss_and_visual_module_scope_is_explicitly_limited(self) -> None:
        self.assertEqual(len(self.scope["districts"]), 5)
        for district in self.scope["districts"]:
            self.assertEqual(district["named_bosses_per_district"], 1)
            self.assertEqual(district["boss_placement_trial"], "district_endpoint")
            self.assertEqual(district["visual_modules_per_district"], 2)
            self.assertEqual(district["visual_transition_local_wave"], 13)
            self.assertEqual(district["module_names_and_production_art"], "UNSPECIFIED")
        expected_bosses = ["Patchwork", "Ghostlight", "Chainbreak", "Civic Warden", "Sable Venn"]
        actual_bosses = [boss["display_name"] for boss in self.scope["boss_concepts"]]
        self.assertEqual(actual_bosses, expected_bosses)
        self.assertTrue(all(boss["district_assignment"] is None for boss in self.scope["boss_concepts"]))
        self.assertIn("UNSPECIFIED", self.scope["boss_combat_and_recruitment_content"])

    def test_existing_undercity_zone_boundary_remains_a_provisional_fixture(self) -> None:
        self.assertEqual(self.zone_fixture["status"], "prototype_only")
        self.assertIn("not approved level pacing", self.zone_fixture["notes"])
        self.assertEqual(
            [(zone["first_wave"], zone["last_wave"]) for zone in self.zone_fixture["zones"]],
            [(1, 12), (13, 25)],
        )


if __name__ == "__main__":
    unittest.main()
