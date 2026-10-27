from __future__ import annotations

import argparse
import importlib.util
import json
import math
from pathlib import Path
import subprocess
import tempfile
import unittest


PROJECT_ROOT = Path(__file__).resolve().parents[1]
FIXTURE_TEMP_DIR = PROJECT_ROOT / "tools" / "balance_simulator"
MODULE_PATH = PROJECT_ROOT / "tools" / "balance_simulator" / "balance_simulator.py"
SPEC = importlib.util.spec_from_file_location("balance_simulator", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
simulator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(simulator)


class IntegralJsonNumberTests(unittest.TestCase):
    def test_accepts_integer_and_integral_float(self) -> None:
        self.assertEqual(simulator.require_int(3, "value"), 3)
        self.assertEqual(simulator.require_int(3.0, "value"), 3)

    def test_rejects_boolean_fraction_nonfinite_and_below_minimum(self) -> None:
        for value in (True, False, 3.5, math.inf, -math.inf, math.nan, -1, -1.0):
            with self.subTest(value=value), self.assertRaises(ValueError):
                simulator.require_int(value, "value")

    def test_integer_profile_override_accepts_integral_float_as_int(self) -> None:
        profiles = {"progression": {"system_reboot": {"first_eligibility_wave": 25}}}
        updated = simulator.apply_candidate_overrides(
            profiles,
            {"system_reboot.first_eligibility_wave": 30.0},
            "integral float",
        )
        self.assertEqual(updated["progression"]["system_reboot"]["first_eligibility_wave"], 30)
        self.assertIsInstance(updated["progression"]["system_reboot"]["first_eligibility_wave"], int)

    def test_integer_profile_override_rejects_boolean_and_fraction(self) -> None:
        profiles = {"progression": {"system_reboot": {"first_eligibility_wave": 25}}}
        for value in (True, 30.5):
            with self.subTest(value=value), self.assertRaises(ValueError):
                simulator.apply_candidate_overrides(
                    profiles,
                    {"system_reboot.first_eligibility_wave": value},
                    "invalid integer",
                )


class SafeOutputRootTests(unittest.TestCase):
    def test_accepts_output_under_caller_selected_root(self) -> None:
        with tempfile.TemporaryDirectory(dir=FIXTURE_TEMP_DIR) as temp:
            root = Path(temp) / "safe"
            output = root / "reports"
            output.mkdir(parents=True)
            simulator.ensure_output_safe(output, root, PROJECT_ROOT, False)

    def test_rejects_output_outside_caller_selected_root(self) -> None:
        with tempfile.TemporaryDirectory(dir=FIXTURE_TEMP_DIR) as temp:
            root = Path(temp) / "safe"
            output = Path(temp) / "outside"
            output.mkdir()
            with self.assertRaisesRegex(ValueError, "caller-selected safe output root"):
                simulator.ensure_output_safe(output, root, PROJECT_ROOT, False)

    def test_rejects_symlink_that_resolves_outside_safe_root(self) -> None:
        with tempfile.TemporaryDirectory(dir=FIXTURE_TEMP_DIR) as temp:
            temp_path = Path(temp)
            root = temp_path / "safe"
            root.mkdir()
            outside = temp_path / "outside"
            outside.mkdir()
            link = root / "redirect"
            try:
                link.symlink_to(outside, target_is_directory=True)
            except (OSError, NotImplementedError) as exc:
                junction = subprocess.run(
                    ["cmd", "/c", "mklink", "/J", str(link), str(outside)],
                    capture_output=True,
                    text=True,
                    check=False,
                )
                if junction.returncode != 0:
                    self.skipTest(f"directory symlink/junction creation is unavailable: {exc}; {junction.stderr.strip()}")
            with self.assertRaisesRegex(ValueError, "caller-selected safe output root"):
                simulator.ensure_output_safe(link / "reports", root, PROJECT_ROOT, False)

    def test_still_rejects_protected_project_locations_inside_safe_root(self) -> None:
        output = PROJECT_ROOT / "data" / "simulator-report"
        with self.assertRaisesRegex(ValueError, "cannot be inside data"):
            simulator.ensure_output_safe(output, PROJECT_ROOT, PROJECT_ROOT, False)

    def test_generate_records_resolved_safe_root_and_output_paths(self) -> None:
        with tempfile.TemporaryDirectory(dir=FIXTURE_TEMP_DIR) as temp:
            safe_root = Path(temp) / "safe"
            output_dir = safe_root / "reports"
            args = argparse.Namespace(
                project_root=PROJECT_ROOT,
                scenario=None,
                wave_horizon=1,
                safe_output_root=safe_root,
                output_dir=output_dir,
                overwrite=False,
            )
            generated = simulator.generate(args)
            metadata = json.loads((generated / "run_metadata.json").read_text(encoding="utf-8"))
            self.assertEqual(generated, output_dir.resolve())
            self.assertEqual(metadata["safe_output_root"], str(safe_root.resolve()))
            self.assertEqual(metadata["output_directory"], str(output_dir.resolve()))
            self.assertTrue((generated / "wave_progression.csv").is_file())

    def test_generate_rejects_escape_before_creating_output(self) -> None:
        with tempfile.TemporaryDirectory(dir=FIXTURE_TEMP_DIR) as temp:
            safe_root = Path(temp) / "safe"
            output_dir = Path(temp) / "outside" / "reports"
            args = argparse.Namespace(
                project_root=PROJECT_ROOT,
                scenario=None,
                wave_horizon=1,
                safe_output_root=safe_root,
                output_dir=output_dir,
                overwrite=False,
            )
            with self.assertRaisesRegex(ValueError, "caller-selected safe output root"):
                simulator.generate(args)
            self.assertFalse(output_dir.exists())


if __name__ == "__main__":
    unittest.main()
