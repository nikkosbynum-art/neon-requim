"""Create an isolated v1 rig trial from canon-review candidate 07.

Reuses the established candidate-05 polygon/pivot layout as provisional data,
then recomputes visible ownership and extrapolated underpaint from candidate 07.
This is a feasibility export only; the art remains quarantined.
"""
from __future__ import annotations

import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE_EXPORTER = ROOT / "tools/art/export_breaker_guarded_pose_trial_08_single_owner_nearest_fill.py"
SOURCE = ROOT / "assets/characters/breaker/tier_01_drafts/BREAKER_T1_tier1_canon_review_candidate_07.png"
OUT = ROOT / "assets/characters/breaker/tier_01_drafts/profile_rig_trial_07_canon_v1"

if OUT.exists():
    raise FileExistsError(f"Refusing to overwrite existing trial: {OUT}")

spec = importlib.util.spec_from_file_location("trial05_single_owner_exporter", BASE_EXPORTER)
if spec is None or spec.loader is None:
    raise RuntimeError(f"Could not load base exporter: {BASE_EXPORTER}")
exporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(exporter)
exporter.SOURCE = SOURCE
exporter.OUT = OUT
exporter.main()

manifest_path = OUT / "pivot_manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
source_image = exporter.Image.open(SOURCE).convert("RGBA")
silhouette = source_image.getchannel("A").point(lambda a: 255 if a >= 245 else 0)
bounds = silhouette.getbbox()
assert bounds is not None
manifest["source_visible_height_px"] = bounds[3] - bounds[1]
manifest["pivot_status"] = "estimated transfer of trial-05 pivots to candidate 07; not artist-authored or verified"
manifest["status"] = "INFERRED CANDIDATE-07 CANON REVIEW RIG FEASIBILITY DRAFT — NOT APPROVED / NOT PRODUCTION ART"
manifest["limitations"].append("Visible ownership polygons and pivots were transferred from candidate 05 and may not match candidate 07's altered shoulder and knee details.")
manifest["validation"]["godot_tested"] = False
manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(f"Candidate 07 v1 source visible height: {manifest['source_visible_height_px']} px; review rig remains quarantined.")
