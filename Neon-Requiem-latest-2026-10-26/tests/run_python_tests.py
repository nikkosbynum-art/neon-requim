#!/usr/bin/env python3
"""Preflight project-local fixture writes, then run the Python regression suite."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys
import tempfile


PROJECT_ROOT = Path(__file__).resolve().parents[1]
TESTS_DIR = PROJECT_ROOT / "tests"

# These are the parent directories used by tests that deliberately exercise
# project-confined output paths. Keep this list in sync with TemporaryDirectory
# calls under tests/ that pass an explicit dir= argument.
FIXTURE_WRITE_DIRS = (
    PROJECT_ROOT,
    TESTS_DIR,
    PROJECT_ROOT / "tools" / "balance_simulator",
    PROJECT_ROOT / "assets" / "characters" / "spark" / "tier_01_drafts",
)


def _preflight() -> list[str]:
    blocked: list[str] = []
    for directory in FIXTURE_WRITE_DIRS:
        if not directory.is_dir():
            blocked.append(f"{directory}: required fixture parent does not exist")
            continue
        try:
            with tempfile.TemporaryDirectory(prefix=".python-test-write-check-", dir=directory) as scratch:
                probe = Path(scratch) / "write_probe.tmp"
                probe.write_text("preflight\n", encoding="utf-8")
                probe.unlink()
        except OSError as exc:
            blocked.append(f"{directory}: {exc}")
    return blocked


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pattern", default="test_*.py", help="unittest discovery filename pattern")
    parser.add_argument("-v", "--verbose", action="store_true", help="show individual test names")
    args = parser.parse_args()

    blocked = _preflight()
    if blocked:
        print("BLOCKED: Python tests were not started because project fixture writes are unavailable.", file=sys.stderr)
        print("This is an environment permission issue, not a test failure. Re-run with approved test-write access to:", file=sys.stderr)
        for item in blocked:
            print(f"  - {item}", file=sys.stderr)
        return 2

    print("Preflight PASS: project-local test fixture directories are writable.")
    command = [
        sys.executable,
        "-m",
        "unittest",
        "discover",
        "-s",
        str(TESTS_DIR),
        "-p",
        args.pattern,
    ]
    if args.verbose:
        command.append("-v")
    return subprocess.run(command, cwd=PROJECT_ROOT, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
