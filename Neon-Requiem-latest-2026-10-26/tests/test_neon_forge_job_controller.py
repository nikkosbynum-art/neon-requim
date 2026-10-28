"""Tests for Neon Forge planning-only job orchestration."""
import tempfile
import unittest
from pathlib import Path
from tools.neon_forge.job_controller import new_job, validate_job, save_new_job, load_job, report


class NeonForgeJobTests(unittest.TestCase):
    def test_four_forms_start_pending(self):
        job = new_job()
        self.assertEqual(len(job["forms"]), 4)
        self.assertEqual(job["forms"]["4"]["name"], "Requiem Form")
        self.assertTrue(all(stage["status"] == "pending"
                            for form in job["forms"].values()
                            for stage in form["stages"].values()))

    def test_round_trip_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "breaker.json"
            save_new_job(path, new_job())
            self.assertIn("planning only", report(load_job(path)))
            with self.assertRaises(FileExistsError):
                save_new_job(path, new_job())

    def test_reject_unsafe_mode(self):
        job = new_job()
        job["mode"] = "production"
        with self.assertRaises(ValueError):
            validate_job(job)

    def test_reject_missing_form(self):
        job = new_job()
        del job["forms"]["2"]
        with self.assertRaises(ValueError):
            validate_job(job)


if __name__ == "__main__":
    unittest.main()
