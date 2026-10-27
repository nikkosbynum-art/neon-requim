from __future__ import annotations

import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from tools.art.validate_character_art_roster import (  # noqa: E402
    CANONICAL_ROSTER_IDS,
    _exit_code,
    audit_roster,
    load_roster,
)


class CharacterArtRosterTests(unittest.TestCase):
    def test_roster_file_matches_the_canonical_twelve_ids(self) -> None:
        roster = load_roster()
        self.assertEqual(
            tuple(item["character_id"] for item in roster["characters"]),
            CANONICAL_ROSTER_IDS,
        )
        self.assertEqual(roster["source"]["url"], "https://app.notion.com/p/40394c5658c8812d849be3d32629920e")

    def test_shared_schema_and_template_are_present_and_gates_default_closed(self) -> None:
        schema = json.loads((PROJECT_ROOT / "tools/art/character_art_manifest.schema.json").read_text(encoding="utf-8"))
        template = json.loads((PROJECT_ROOT / "tools/art/character_art_manifest.template.json").read_text(encoding="utf-8"))
        self.assertEqual(schema["properties"]["manifest_version"]["const"], 1)
        self.assertIn("production_gates", schema["required"])
        self.assertEqual(template["character_id"], "REPLACE_WITH_FOUNDING_ROSTER_ID")
        self.assertTrue(all(value is False for value in template["production_gates"].values()))

    def test_live_project_counts_only_the_registered_breaker_pilot(self) -> None:
        report = audit_roster(load_roster(), PROJECT_ROOT)
        self.assertEqual(report["errors"], [])
        self.assertEqual(report["missing_count"], 11)
        self.assertEqual(_exit_code(report), 0)
        submitted = [row for row in report["characters"] if row["status"] == "SUBMITTED"]
        self.assertEqual([row["character_id"] for row in submitted], ["BREAKER"])
        self.assertEqual(len(submitted[0]["manifests"]), 1)
        self.assertEqual(submitted[0]["manifests"][0]["status"], "REVIEW_ONLY")

    def test_all_character_draft_folders_are_excluded_from_godot_imports(self) -> None:
        draft_folders = sorted((PROJECT_ROOT / "assets/characters").glob("*/tier_01_drafts"))
        self.assertEqual(len(draft_folders), len(CANONICAL_ROSTER_IDS))
        missing = [path.as_posix() for path in draft_folders if not (path / ".gdignore").is_file()]
        self.assertEqual(missing, [])

    def test_require_all_reports_missing_recruits_without_creating_manifests(self) -> None:
        report = audit_roster(load_roster(), PROJECT_ROOT, require_all=True)
        self.assertEqual(_exit_code(report), 2)
        self.assertEqual(report["missing_count"], 11)

    def test_require_production_keeps_review_candidate_blocked(self) -> None:
        report = audit_roster(load_roster(), PROJECT_ROOT, require_production=True)
        self.assertEqual(_exit_code(report), 3)
        breaker = next(row for row in report["characters"] if row["character_id"] == "BREAKER")
        self.assertIn("hidden_anatomy_authored", breaker["manifests"][0]["blockers"])

    def test_roster_missing_or_unknown_id_is_an_error(self) -> None:
        roster = copy.deepcopy(load_roster())
        roster["characters"].pop()
        report = audit_roster(roster, PROJECT_ROOT)
        self.assertTrue(any("canonical twelve IDs" in error for error in report["errors"]))

    def test_standard_intake_filename_is_discovered_for_any_recruit(self) -> None:
        with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temporary:
            root = Path(temporary)
            roster = self._empty_roster()
            self._write_manifest(root, "BULWARK")
            report = audit_roster(roster, root)
            self.assertEqual(report["errors"], [])
            self.assertEqual(report["missing_count"], 11)
            bulwark = next(row for row in report["characters"] if row["character_id"] == "BULWARK")
            self.assertEqual(bulwark["manifests"][0]["status"], "REVIEW_ONLY")

    def test_higher_tier_does_not_substitute_for_required_tier_one(self) -> None:
        with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temporary:
            root = Path(temporary)
            roster = self._empty_roster()
            self._write_manifest(root, "BULWARK", tier_id=2, folder="tier_02")
            report = audit_roster(roster, root, require_all=True)
            bulwark = next(row for row in report["characters"] if row["character_id"] == "BULWARK")
            self.assertEqual(bulwark["status"], "INCOMPLETE")
            self.assertEqual(bulwark["missing_required_tiers"], [1])
            self.assertEqual(report["missing_required_tier_count"], 12)
            self.assertEqual(_exit_code(report), 2)

    def test_manifest_for_the_wrong_recruit_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temporary:
            root = Path(temporary)
            roster = self._empty_roster()
            self._write_manifest(root, "CIPHER", folder_id="BULWARK")
            report = audit_roster(roster, root)
            self.assertTrue(any("does not match roster ID BULWARK" in error for error in report["errors"]))

    def test_duplicate_tier_manifests_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temporary:
            root = Path(temporary)
            roster = self._empty_roster()
            self._write_manifest(root, "BULWARK", folder_id="BULWARK", folder="tier_01")
            self._write_manifest(root, "BULWARK", folder_id="BULWARK", folder="review_copy")
            report = audit_roster(roster, root)
            self.assertTrue(any("BULWARK: duplicate tier_id 1" in error for error in report["errors"]))

    def test_explicit_manifest_path_cannot_escape_character_folder(self) -> None:
        with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temporary:
            root = Path(temporary)
            roster = self._empty_roster()
            roster["characters"][0]["manifest_paths"] = ["assets/characters/not-bulwark/manifest.json"]
            report = audit_roster(roster, root)
            self.assertTrue(any("outside its character folder" in error for error in report["errors"]))

    @staticmethod
    def _empty_roster() -> dict:
        roster = copy.deepcopy(load_roster())
        for character in roster["characters"]:
            character["manifest_paths"] = []
        return roster

    @staticmethod
    def _write_manifest(
        root: Path,
        manifest_id: str,
        *,
        folder_id: str | None = None,
        folder: str = "tier_01",
        tier_id: int = 1,
    ) -> Path:
        """Write a tiny synthetic raster fixture; it is not character art or a project asset."""
        folder_id = folder_id or manifest_id
        project_marker = root / "project.godot"
        project_marker.touch(exist_ok=True)
        asset_dir = root / "assets" / "characters" / folder_id.lower() / folder
        asset_dir.mkdir(parents=True, exist_ok=True)
        Image.new("RGBA", (2, 2), (255, 255, 255, 255)).save(asset_dir / "test_tile.png")
        Image.new("RGBA", (2, 2), (10, 10, 10, 255)).save(asset_dir / "source_tile.png")
        manifest = {
            "manifest_version": 1,
            "character_id": manifest_id,
            "tier_id": tier_id,
            "asset_status": "review_only",
            "source_reference": f"assets/characters/{folder_id.lower()}/{folder}/source_tile.png",
            "source_canvas_px": [2, 2],
            "target_visible_height_px": 2,
            "measured_visible_height_px": 2,
            "pivots_px": {"origin": [0, 0]},
            "bone_hierarchy": [{"name": "Root", "parent": None, "pivot": "origin", "parent_pivot": None}],
            "parts": [{
                "name": "body",
                "file": "test_tile.png",
                "parent_bone": "Root",
                "pivot": "origin",
                "draw_order": 0,
                "alpha_mode": "transparent_cutout",
            }],
            "layers_back_to_front": ["body"],
            "production_gates": {
                "visible_art_approved": False,
                "hidden_anatomy_authored": False,
                "pivots_authored": False,
                "joint_seams_reviewed": False,
                "animation_reviewed": False,
            },
        }
        manifest_path = asset_dir / "character_art_manifest.json"
        manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
        return manifest_path


if __name__ == "__main__":
    unittest.main()
