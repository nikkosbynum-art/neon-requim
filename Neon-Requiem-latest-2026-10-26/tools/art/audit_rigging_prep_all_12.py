#!/usr/bin/env python3
"""Validate the roster-wide Tier I rigging preparation inventory."""

from __future__ import annotations

import json
import sys
from pathlib import Path
import xml.etree.ElementTree as ET
import zipfile

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "tools/art/rigging_prep_all_12.json"
ROSTER = ROOT / "tools/art/character_art_roster.json"



def _first_image_reference(value: str) -> str | None:
    image_extensions = {".png", ".jpg", ".jpeg", ".webp"}
    for candidate in value.split(" and "):
        if Path(candidate).suffix.lower() in image_extensions:
            return candidate
    return None


def _archive_image_matches_source(archive: zipfile.ZipFile, archive_member: str, source_rel: str) -> bool:
    with Image.open(ROOT / source_rel) as source_opened:
        source = source_opened.convert("RGBA")
    with archive.open(archive_member) as archived_file:
        with Image.open(archived_file) as archive_opened:
            archived = archive_opened.convert("RGBA")
    return source.size == archived.size and source.tobytes() == archived.tobytes()


def _validate_workspace(record: dict) -> list[str]:
    errors: list[str] = []
    character_id = record.get("id", "<missing>")
    plan_data = json.loads(PLAN.read_text(encoding="utf-8"))
    batch = record.get("workspace_batch", plan_data.get("active_workspace_batch", "edit_batch_01"))
    version = record.get("workspace_version", plan_data.get("active_workspace_version", 1))
    workspace = ROOT / f"assets/characters/{str(character_id).lower()}/tier_01_drafts/{batch}/{character_id}_T1_ART_EDIT_WORKSPACE_{version:02d}_QUARANTINED.ora"
    sidecar = workspace.parent / "README_EDIT_PREP.md"
    if not workspace.is_file():
        return [f"{character_id}: generated OpenRaster workspace is missing: {workspace.relative_to(ROOT)}"]
    if not sidecar.is_file():
        errors.append(f"{character_id}: workspace sidecar README is missing.")
    try:
        with zipfile.ZipFile(workspace) as archive:
            corrupt = archive.testzip()
            if corrupt is not None:
                return [f"{character_id}: corrupt OpenRaster member: {corrupt}"]
            if archive.read("mimetype") != b"image/openraster":
                errors.append(f"{character_id}: invalid OpenRaster mimetype.")
            metadata = json.loads(archive.read("edit_workspace_manifest.json"))
            if metadata.get("character_id") != character_id:
                errors.append(f"{character_id}: workspace character ID does not match its directory.")
            if metadata.get("workspace_batch", "edit_batch_01") != batch or metadata.get("workspace_version", 1) != version:
                errors.append(f"{character_id}: workspace batch/version does not match the current roster plan.")
            for field in ("production_approved", "semantic_parts_created", "art_pixels_changed", "runtime_integrated"):
                if metadata.get(field) is not False:
                    errors.append(f"{character_id}: workspace flag {field!r} must remain false.")
            if metadata.get("status") != "EDIT PREP ONLY - QUARANTINED":
                errors.append(f"{character_id}: workspace lost its edit-prep/quarantine status.")
            expected_anatomy = _first_image_reference(record.get("anatomy_reference", ""))
            expected_concept = _first_image_reference(record.get("concept_reference", ""))
            if metadata.get("anatomy_reference") != expected_anatomy or metadata.get("concept_reference") != expected_concept:
                errors.append(f"{character_id}: workspace source references do not match the current roster plan.")
            if expected_anatomy is not None:
                with Image.open(ROOT / expected_anatomy) as anatomy_source:
                    anatomy_size = anatomy_source.size
                if metadata.get("canvas_px") != list(anatomy_size):
                    errors.append(f"{character_id}: workspace canvas size differs from its anatomy reference.")
                if not _archive_image_matches_source(archive, "mergedimage.png", expected_anatomy):
                    errors.append(f"{character_id}: merged OpenRaster reference pixels differ from the approved anatomy source.")
                anatomy_layers = [layer for layer in ET.fromstring(archive.read("stack.xml")).find("./stack").findall("./layer") if layer.attrib.get("name", "").startswith("REFERENCE - approved anatomy")]
                if len(anatomy_layers) == 1 and not _archive_image_matches_source(archive, anatomy_layers[0].attrib["src"], expected_anatomy):
                    errors.append(f"{character_id}: visible anatomy reference layer pixels differ from the approved source.")
            if expected_concept is not None:
                with Image.open(ROOT / expected_concept) as concept_source:
                    expected_concept_embedded = concept_source.size == tuple(metadata.get("canvas_px", []))
                if bool(metadata.get("concept_embedded_same_scale")) != expected_concept_embedded:
                    errors.append(f"{character_id}: concept embedding flag does not match source canvas dimensions.")
                if expected_concept_embedded:
                    concept_layers_for_pixels = [layer for layer in ET.fromstring(archive.read("stack.xml")).find("./stack").findall("./layer") if layer.attrib.get("name", "").startswith("REFERENCE - approved concept")]
                    if len(concept_layers_for_pixels) == 1 and not _archive_image_matches_source(archive, concept_layers_for_pixels[0].attrib["src"], expected_concept):
                        errors.append(f"{character_id}: embedded concept pixels differ from their source reference.")
            if metadata.get("attachment_workspace_layers") != record.get("attachment_workspace_layers"):
                errors.append(f"{character_id}: workspace attachment layers do not match the current roster plan.")
            stack = ET.fromstring(archive.read("stack.xml")).find("./stack")
            if stack is None:
                errors.append(f"{character_id}: OpenRaster stack is missing.")
                return errors
            layers = stack.findall("./layer")
            layer_names = [layer.attrib.get("name", "") for layer in layers]
            if metadata.get("layer_names") != layer_names:
                errors.append(f"{character_id}: layer manifest and stack order disagree.")
            by_name = {layer.attrib.get("name", ""): layer for layer in layers}
            for label in record.get("attachment_workspace_layers", []):
                name = f"ATTACHMENT - {label}"
                layer = by_name.get(name)
                if layer is None:
                    errors.append(f"{character_id}: planned attachment layer missing: {label}")
                    continue
                if layer.attrib.get("visibility") != "hidden":
                    errors.append(f"{character_id}: blank attachment layer must start hidden: {label}")
                with archive.open(layer.attrib["src"]) as image_file:
                    with Image.open(image_file) as image:
                        if image.mode != "RGBA" or image.getchannel("A").getbbox() is not None:
                            errors.append(f"{character_id}: attachment layer is not blank transparent RGBA: {label}")
            anatomy_layers = [layer for layer in layers if layer.attrib.get("name", "").startswith("REFERENCE - approved anatomy")]
            if len(anatomy_layers) != 1 or anatomy_layers[0].attrib.get("visibility") != "visible":
                errors.append(f"{character_id}: exactly one visible anatomy reference is required.")
            embedded_concept_layers = [layer for layer in layers if layer.attrib.get("name", "").startswith("REFERENCE - approved concept")]
            if bool(metadata.get("concept_embedded_same_scale")):
                if len(embedded_concept_layers) != 1 or embedded_concept_layers[0].attrib.get("visibility") != "hidden":
                    errors.append(f"{character_id}: same-canvas concept should be embedded and hidden.")
            elif embedded_concept_layers:
                errors.append(f"{character_id}: differently sized concept should remain an external reference.")
            diagnostic_layers = [layer for layer in layers if layer.attrib.get("name", "").startswith("DIAGNOSTIC ONLY -") ]
            if any(layer.attrib.get("visibility") != "hidden" for layer in diagnostic_layers):
                errors.append(f"{character_id}: quarantined diagnostic layers must remain hidden.")
        if sidecar.is_file():
            readme = sidecar.read_text(encoding="utf-8")
            if "EDIT PREP ONLY / QUARANTINED" not in readme or "docs/ATTACHMENT_FUNCTION_CONTRACT.md" not in readme:
                errors.append(f"{character_id}: sidecar must preserve quarantine status and the attachment contract link.")
            for label in record.get("attachment_workspace_layers", []):
                if label not in readme:
                    errors.append(f"{character_id}: sidecar omits planned attachment: {label}")
            for question in record.get("attachment_open_questions", []):
                if question not in readme:
                    errors.append(f"{character_id}: sidecar does not carry the current open question verbatim.")
            if character_id == "ECHO" and "two sensory drones" in " ".join(metadata.get("special_rig_items", [])).lower():
                if "supersedes that estimate" not in readme:
                    errors.append("ECHO: sidecar must mark the embedded two-drone note as superseded.")
    except (OSError, KeyError, ValueError, zipfile.BadZipFile, ET.ParseError) as error:
        errors.append(f"{character_id}: could not validate generated workspace: {error}")
    return errors


def validate() -> list[str]:
    errors: list[str] = []
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    roster = json.loads(ROSTER.read_text(encoding="utf-8"))
    expected = [item["character_id"] for item in roster["characters"]]
    records = plan.get("characters", [])
    ids = [item.get("id") for item in records]

    if len(ids) != len(set(ids)):
        errors.append("Rigging plan contains duplicate character IDs.")
    if set(ids) != set(expected):
        errors.append(f"Plan roster mismatch: expected {expected}; found {ids}.")
    if len(plan.get("shared_required_parts", [])) < 12:
        errors.append("Shared semantic part list appears incomplete.")
    if len(plan.get("shared_validation_gates", [])) < 8:
        errors.append("Shared validation gates appear incomplete.")

    for item in records:
        character_id = item.get("id", "<missing>")
        for field in ("concept_reference", "anatomy_reference", "existing_candidate", "candidate_status", "special_rig_items"):
            if not item.get(field):
                errors.append(f"{character_id}: required field {field!r} is empty.")
        if "production-approved" in item.get("candidate_status", "").lower():
            errors.append(f"{character_id}: candidate is incorrectly marked production-approved.")
        contracts = item.get("functional_attachment_contract", [])
        if not contracts:
            errors.append(f"{character_id}: functional attachment contract is missing.")
        contract_ids = [entry.get("id") for entry in contracts]
        if len(contract_ids) != len(set(contract_ids)):
            errors.append(f"{character_id}: functional attachment IDs are duplicated.")
        for entry in contracts:
            for field in ("id", "kind", "known_behavior", "gameplay_authority", "unknowns"):
                if not entry.get(field):
                    errors.append(f"{character_id}: attachment contract field {field!r} is empty.")
        if character_id == "SPARK":
            drones = [entry for entry in contracts if entry.get("id") == "attack_drones_01_03"]
            if len(drones) != 1 or "exactly three" not in drones[0].get("known_behavior", "").lower():
                errors.append("SPARK: Scrap Swarm must retain exactly three source-backed attack drone identities.")
        if character_id == "ECHO":
            unresolved = " ".join(item.get("attachment_open_questions", [])).lower()
            if "count" not in unresolved or "unresolved" not in unresolved:
                errors.append("ECHO: drone count must remain explicitly unresolved.")
        errors.extend(_validate_workspace(item))
        candidate = item.get("existing_candidate", "")
        # BREAKER intentionally cites more than one candidate directory in a single field.
        for candidate_path in candidate.split(" and "):
            if not (ROOT / candidate_path).exists():
                errors.append(f"{character_id}: candidate path does not exist: {candidate_path}")
        # Concept/anatomy reference fields may document a pair of BREAKER source documents.
        for field in ("concept_reference", "anatomy_reference"):
            value = item.get(field, "")
            for source_path in value.split(" and "):
                if source_path.startswith("docs/") or source_path.startswith("migration_package/"):
                    if not (ROOT / source_path).exists():
                        errors.append(f"{character_id}: source reference does not exist: {source_path}")

    return errors


def main() -> int:
    try:
        errors = validate()
    except (OSError, json.JSONDecodeError, KeyError, TypeError) as error:
        print(f"FAIL: could not validate roster-wide rigging plan: {error}")
        return 1
    if errors:
        print("FAIL: roster-wide rigging plan has errors:")
        for error in errors:
            print(f"- {error}")
        return 1
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    print(f"PASS: {len(plan['characters'])} founding recruits have references, a candidate inventory, attachment function contracts, and shared production gates.")
    print("PASS: all 12 on-disk OpenRaster archives, sidecars, source references, attachment layers, visibility, blank alpha, and quarantine flags match the plan.")
    print("PASS: every listed source/candidate path exists; no candidate is labeled production-approved.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
