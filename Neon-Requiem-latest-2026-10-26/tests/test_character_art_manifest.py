from __future__ import annotations

import copy
import json
import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from tools.art.validate_character_art_manifest import validate_manifest_data  # noqa: E402


MANIFEST_PATH = (
    PROJECT_ROOT
    / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_01/pivot_manifest.json"
)


class CharacterArtManifestTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        cls.manifest_root = MANIFEST_PATH.parent

    def test_current_breaker_manifest_is_structurally_valid_but_not_production_ready(self) -> None:
        errors, blockers, measured_height = validate_manifest_data(
            self.manifest, self.manifest_root, require_production=True
        )
        self.assertEqual(errors, [])
        self.assertEqual(measured_height, 1427)
        self.assertIn("asset_status_not_production_ready", blockers)
        self.assertIn("hidden_anatomy_authored", blockers)
        self.assertIn("pivots_authored", blockers)

    def test_duplicate_draw_order_is_rejected(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["parts"][1]["draw_order"] = manifest["parts"][0]["draw_order"]
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("duplicate draw_order" in error for error in errors))

    def test_unresolved_bone_is_rejected(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["parts"][0]["parent_bone"] = "MissingBone"
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("unknown parent_bone" in error for error in errors))

    def test_unexpected_visible_height_is_rejected(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["measured_visible_height_px"] += 1
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("part alpha union" in error for error in errors))

    def test_non_transparent_part_mode_is_rejected(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["parts"][0]["alpha_mode"] = "opaque"
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("alpha_mode" in error for error in errors))

    def test_non_string_asset_status_is_rejected_without_crashing(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["asset_status"] = ["production_ready"]
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("asset_status" in error for error in errors))

    def test_boolean_tier_is_not_accepted_as_integer(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["tier_id"] = True
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("tier_id" in error for error in errors))

    def test_boolean_manifest_version_is_not_accepted_as_integer(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["manifest_version"] = True
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("manifest_version" in error for error in errors))

    def test_non_string_cross_references_are_rejected_without_crashing(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        manifest["bone_hierarchy"][1]["parent"] = ["GroundRoot"]
        manifest["parts"][0]["parent_bone"] = {"name": "Root"}
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("parent" in error for error in errors))
        self.assertTrue(any("parent_bone" in error for error in errors))

    def test_missing_schema_required_bone_field_is_rejected(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        del manifest["bone_hierarchy"][0]["parent_pivot"]
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("missing required fields" in error and "parent_pivot" in error for error in errors))

    def test_missing_or_non_boolean_gate_is_rejected(self) -> None:
        manifest = copy.deepcopy(self.manifest)
        del manifest["production_gates"]["visible_art_approved"]
        manifest["production_gates"]["hidden_anatomy_authored"] = "false"
        errors, _, _ = validate_manifest_data(manifest, self.manifest_root)
        self.assertTrue(any("production_gates is missing" in error for error in errors))
        self.assertTrue(any("must be a boolean" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
