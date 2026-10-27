#!/usr/bin/env python3
"""Read-only local balance arithmetic for Neon Requiem prototype profiles."""

from __future__ import annotations

import argparse
import copy
import csv
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import sys
from typing import Any


TOOL_VERSION = "1.1.0"
PROFILE_FILES = {
    "progression": Path("data/progression/progression_prototype_profile.json"),
    "wave": Path("data/waves/undercity_prototype.json"),
    "breaker": Path("data/characters/breaker_t1.json"),
    "recruitment": Path("data/progression/recruitment_prototype_profile.json"),
    "roster": Path("data/characters/founding_recruits.json"),
}
OUTPUT_NAMES = [
    "wave_progression.csv",
    "reboot_scenarios.csv",
    "offline_claims.csv",
    "evolution_supply.csv",
    "breaker_upgrades.csv",
    "recruitment_costs.csv",
    "sensitivity.csv",
    "summary.md",
    "run_metadata.json",
]
TIERS = ["Adapted Form", "Signature Form", "Requiem Form"]
MAX_OFFLINE_CAP_SECONDS = 8 * 60 * 60

ALLOWED_OVERRIDES = {
    "system_reboot.first_eligibility_wave": ("progression", "system_reboot", "first_eligibility_wave"),
    "system_reboot.waves_per_influence_step": ("progression", "system_reboot", "waves_per_influence_step"),
    "system_reboot.influence_per_step": ("progression", "system_reboot", "influence_per_step"),
    "lifetime_influence_benefit.coefficient": ("progression", "lifetime_influence_benefit", "coefficient"),
    "lifetime_influence_benefit.influence_exponent": ("progression", "lifetime_influence_benefit", "influence_exponent"),
    "lifetime_influence_benefit.maximum_bonus_fraction": ("progression", "lifetime_influence_benefit", "maximum_bonus_fraction"),
    "evolution_material_policy.repeatable_per_clear": ("progression", "evolution_material_policy", "repeatable_per_clear"),
    "evolution_material_policy.first_clear_extra": ("progression", "evolution_material_policy", "first_clear_extra"),
    "offline_earnings.cap_seconds": ("progression", "offline_earnings", "cap_seconds"),
    "offline_earnings.ordinary_rewards_per_hour": ("progression", "offline_earnings", "ordinary_rewards_per_hour"),
    "wave.base_credit_reward": ("wave", "base_credit_reward"),
    "wave.credit_reward_per_wave": ("wave", "credit_reward_per_wave"),
    "breaker.upgrade_cost_base": ("breaker", "upgrade_cost_base"),
    "breaker.upgrade_cost_growth": ("breaker", "upgrade_cost_growth"),
}
for _tier in TIERS:
    _tier_key = _tier
    ALLOWED_OVERRIDES[f"evolution.gates.{_tier_key}.minimum_cleared_wave"] = (
        "progression", "evolution", "gates", _tier_key, "minimum_cleared_wave"
    )
    ALLOWED_OVERRIDES[f"evolution.gates.{_tier_key}.material_costs.evolution_data"] = (
        "progression", "evolution", "gates", _tier_key, "material_costs", "evolution_data"
    )


def read_json(path: Path) -> tuple[Any, str]:
    raw = path.read_bytes()
    try:
        return json.loads(raw.decode("utf-8-sig")), hashlib.sha256(raw).hexdigest()
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ValueError(f"Could not parse JSON input {path}: {exc}") from exc


def require_object(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ValueError(f"{label} must be a JSON object.")
    return value


def require_int(value: Any, label: str, minimum: int = 0) -> int:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} must be an integer >= {minimum}.")
    if isinstance(value, float) and (not math.isfinite(value) or not value.is_integer()):
        raise ValueError(f"{label} must be an integer >= {minimum}.")
    result = int(value)
    if result < minimum:
        raise ValueError(f"{label} must be an integer >= {minimum}.")
    return result


def require_number(value: Any, label: str, minimum: float | None = None) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(float(value)):
        raise ValueError(f"{label} must be a finite number.")
    result = float(value)
    if minimum is not None and result < minimum:
        raise ValueError(f"{label} must be >= {minimum}.")
    return result


def object_path(root: dict[str, Any], path: tuple[str, ...], label: str) -> tuple[dict[str, Any], str]:
    current: Any = root
    for part in path[:-1]:
        if not isinstance(current, dict) or part not in current:
            raise ValueError(f"Missing profile field for {label}.")
        current = current[part]
    if not isinstance(current, dict) or path[-1] not in current:
        raise ValueError(f"Missing profile field for {label}.")
    return current, path[-1]


def ordinary_reward(wave_number: int, wave_profile: dict[str, Any]) -> int:
    wave_number = max(1, wave_number)
    base = require_int(wave_profile.get("base_credit_reward"), "wave.base_credit_reward")
    step = require_int(wave_profile.get("credit_reward_per_wave"), "wave.credit_reward_per_wave")
    return max(0, base + (wave_number - 1) * step)


def reboot_award(highest_wave: int, reboot_rules: dict[str, Any]) -> int:
    first = require_int(reboot_rules.get("first_eligibility_wave"), "system_reboot.first_eligibility_wave", 1)
    step = require_int(reboot_rules.get("waves_per_influence_step"), "system_reboot.waves_per_influence_step", 1)
    amount = require_int(reboot_rules.get("influence_per_step"), "system_reboot.influence_per_step", 1)
    if highest_wave < first:
        return 0
    return (1 + (highest_wave - first) // step) * amount


def damage_bonus(lifetime_influence: int, benefit: dict[str, Any]) -> float:
    coefficient = require_number(benefit.get("coefficient"), "lifetime_influence_benefit.coefficient", 0)
    exponent = require_number(benefit.get("influence_exponent"), "lifetime_influence_benefit.influence_exponent", 0.0000001)
    cap = require_number(benefit.get("maximum_bonus_fraction"), "lifetime_influence_benefit.maximum_bonus_fraction", 0)
    return min(coefficient * (lifetime_influence ** exponent), cap)


def round_positive_like_godot(value: float) -> int:
    """Match roundi for positive upgrade costs (half values round upward)."""
    return math.floor(value + 0.5)


def upgrade_cost(level: int, breaker_profile: dict[str, Any]) -> int:
    base = require_number(breaker_profile.get("upgrade_cost_base"), "breaker.upgrade_cost_base", 0)
    growth = require_number(breaker_profile.get("upgrade_cost_growth"), "breaker.upgrade_cost_growth", 0)
    return max(1, round_positive_like_godot(base * (growth ** max(0, level - 1))))


def build_wave_rows(horizon: int, wave_profile: dict[str, Any], material_policy: dict[str, Any], starting_credits: int = 0) -> list[dict[str, Any]]:
    repeatable = require_int(material_policy.get("repeatable_per_clear"), "evolution_material_policy.repeatable_per_clear", 1)
    extra = require_int(material_policy.get("first_clear_extra"), "evolution_material_policy.first_clear_extra", 1)
    milestones_value = material_policy.get("district_milestones")
    if not isinstance(milestones_value, list):
        raise ValueError("evolution_material_policy.district_milestones must be an array.")
    milestone_by_wave: dict[int, list[str]] = {}
    seen_claims: set[str] = set()
    seen_waves: set[int] = set()
    for item in milestones_value:
        item = require_object(item, "district milestone")
        wave_number = require_int(item.get("wave"), "district milestone.wave", 1)
        claim_id = item.get("claim_id")
        if not isinstance(claim_id, str) or not claim_id.strip() or claim_id != claim_id.strip() or claim_id in seen_claims:
            raise ValueError("District milestone claim IDs must be unique non-empty strings.")
        if wave_number in seen_waves:
            raise ValueError("District milestone waves must be unique.")
        seen_claims.add(claim_id)
        seen_waves.add(wave_number)
        milestone_by_wave.setdefault(wave_number, []).append(claim_id)

    rows: list[dict[str, Any]] = []
    cumulative_credits = 0
    cumulative_materials = 0
    for wave_number in range(1, horizon + 1):
        credits = ordinary_reward(wave_number, wave_profile)
        claims = milestone_by_wave.get(wave_number, [])
        material_bonus = extra * len(claims)
        cumulative_credits += credits
        cumulative_materials += repeatable + material_bonus
        rows.append({
            "wave": wave_number,
            "ordinary_credits": credits,
            "cumulative_ordinary_credits": cumulative_credits,
            "credits_available_before_spending": starting_credits + cumulative_credits,
            "repeatable_evolution_data": repeatable,
            "first_clear_bonus": material_bonus,
            "first_clear_claim_ids": ";".join(claims),
            "cumulative_evolution_data": cumulative_materials,
        })
    return rows


def build_reboot_rows(runs: list[Any], progression: dict[str, Any], scenario: dict[str, Any], horizon: int) -> list[dict[str, Any]]:
    reboot_rules = require_object(progression.get("system_reboot"), "system_reboot")
    benefit = require_object(progression.get("lifetime_influence_benefit"), "lifetime_influence_benefit")
    lifetime = require_int(scenario.get("starting_lifetime_influence", 0), "starting_lifetime_influence")
    spendable = require_int(scenario.get("starting_spendable_influence", lifetime), "starting_spendable_influence")
    if spendable > lifetime:
        raise ValueError("starting_spendable_influence cannot exceed starting_lifetime_influence.")
    rows: list[dict[str, Any]] = []
    for index, item in enumerate(runs, start=1):
        item = require_object(item, f"reboot_runs[{index - 1}]")
        endpoint = require_int(item.get("highest_cleared_wave"), f"reboot_runs[{index - 1}].highest_cleared_wave")
        if endpoint > horizon:
            raise ValueError(f"reboot_runs[{index - 1}] exceeds the simulated horizon {horizon}.")
        award = reboot_award(endpoint, reboot_rules)
        if award <= 0:
            raise ValueError(f"reboot_runs[{index - 1}] is below the configured Reboot eligibility wave.")
        lifetime += award
        spendable += award
        rows.append({
            "run_index": index,
            "highest_cleared_wave_since_previous_reboot": endpoint,
            "influence_awarded": award,
            "lifetime_influence_after_reboot": lifetime,
            "spendable_influence_after_reboot": spendable,
            "lifetime_damage_bonus_fraction": f"{damage_bonus(lifetime, benefit):.8f}",
            "run_wave_after_reboot": 1,
            "run_highest_cleared_after_reboot": 0,
            "run_credits_after_reboot": 0,
            "breaker_level_after_reboot": 1,
        })
    return rows


def build_offline_rows(claims: list[Any], progression: dict[str, Any], wave_profile: dict[str, Any], horizon: int) -> list[dict[str, Any]]:
    rules = require_object(progression.get("offline_earnings"), "offline_earnings")
    cap = require_int(rules.get("cap_seconds"), "offline_earnings.cap_seconds", 1)
    if cap > MAX_OFFLINE_CAP_SECONDS:
        raise ValueError("offline_earnings.cap_seconds exceeds the approved eight-hour ceiling.")
    rate = require_number(rules.get("ordinary_rewards_per_hour"), "offline_earnings.ordinary_rewards_per_hour", 0)
    if rate > 10:
        raise ValueError("offline_earnings.ordinary_rewards_per_hour exceeds the service's 10x validation bound.")
    rows: list[dict[str, Any]] = []
    for index, item in enumerate(claims, start=1):
        item = require_object(item, f"offline_claims[{index - 1}]")
        holding_wave = require_int(item.get("holding_wave"), f"offline_claims[{index - 1}].holding_wave")
        if holding_wave > horizon:
            raise ValueError(f"offline_claims[{index - 1}].holding_wave is beyond the simulated horizon {horizon}.")
        elapsed = require_int(item.get("elapsed_seconds"), f"offline_claims[{index - 1}].elapsed_seconds")
        capped = min(elapsed, cap)
        reward = ordinary_reward(max(1, holding_wave), wave_profile)
        credits = math.floor(reward * rate * capped / 3600.0)
        rows.append({
            "claim_index": index,
            "holding_wave": max(1, holding_wave),
            "elapsed_seconds": elapsed,
            "capped_elapsed_seconds": capped,
            "cap_seconds": cap,
            "ordinary_reward_at_holding_wave": reward,
            "ordinary_rewards_per_hour": f"{rate:.8g}",
            "credits_awarded": credits,
            "wave_advancement": False,
            "material_rewards": 0,
        })
    return rows


def build_evolution_rows(horizon: int, wave_rows: list[dict[str, Any]], progression: dict[str, Any], recruit_counts: list[Any]) -> list[dict[str, Any]]:
    evolution_profile = require_object(progression.get("evolution"), "evolution")
    gates = require_object(evolution_profile.get("gates"), "evolution.gates")
    material_by_wave = {row["wave"]: row["cumulative_evolution_data"] for row in wave_rows}
    rows: list[dict[str, Any]] = []
    for recruit_count_value in recruit_counts:
        recruit_count = require_int(recruit_count_value, "evolution_recruit_counts entry", 1)
        cumulative_cost_per_recruit = 0
        for tier in TIERS:
            gate = require_object(gates.get(tier), f"evolution.gates.{tier}")
            gate_wave = require_int(gate.get("minimum_cleared_wave"), f"evolution.gates.{tier}.minimum_cleared_wave", 1)
            costs = require_object(gate.get("material_costs"), f"evolution.gates.{tier}.material_costs")
            if set(costs) != {"evolution_data"}:
                raise ValueError(f"evolution.gates.{tier}.material_costs must contain only evolution_data in simulator v1.")
            tier_cost = require_int(costs.get("evolution_data"), f"evolution.gates.{tier}.material_costs.evolution_data", 1)
            cumulative_cost_per_recruit += tier_cost
            reached = gate_wave <= horizon
            earned = material_by_wave.get(min(gate_wave, horizon), 0)
            roster_cumulative_cost = cumulative_cost_per_recruit * recruit_count
            rows.append({
                "recruit_count": recruit_count,
                "tier": tier,
                "required_permanent_wave": gate_wave,
                "milestone_reached_by_horizon": reached,
                "material_cost_per_recruit_for_tier": tier_cost,
                "cumulative_material_cost_per_recruit_through_tier": cumulative_cost_per_recruit,
                "cumulative_roster_material_cost_through_tier": roster_cumulative_cost,
                "cumulative_materials_earned_at_gate": earned if reached else "",
                "roster_material_surplus_at_gate": earned - roster_cumulative_cost if reached else "",
            })
    return rows


def build_upgrade_rows(scenario: dict[str, Any], breaker_profile: dict[str, Any]) -> list[dict[str, Any]]:
    starting_level = require_int(scenario.get("breaker_starting_level", 1), "breaker_starting_level", 1)
    upgrade_count = require_int(scenario.get("breaker_upgrade_count", 10), "breaker_upgrade_count", 1)
    budgets_value = scenario.get("breaker_credit_budgets", [])
    if not isinstance(budgets_value, list):
        raise ValueError("breaker_credit_budgets must be an array of non-negative integers.")
    budgets = [require_int(value, "breaker_credit_budgets entry") for value in budgets_value]
    costs = [upgrade_cost(starting_level + index, breaker_profile) for index in range(upgrade_count)]
    rows: list[dict[str, Any]] = []
    cumulative = 0
    for index, cost in enumerate(costs):
        cumulative += cost
        rows.append({
            "row_type": "per_upgrade",
            "upgrade_number": index + 1,
            "level_before_purchase": starting_level + index,
            "level_after_purchase": starting_level + index + 1,
            "cost_at_current_level": cost,
            "cumulative_cost_for_sequence": cumulative,
            "credit_budget": "",
            "levels_bought_with_budget": "",
            "unspent_credits": "",
        })
    for budget in budgets:
        remaining = budget
        bought = 0
        cost_paid = 0
        level = starting_level
        while bought < upgrade_count:
            cost = upgrade_cost(level, breaker_profile)
            if remaining < cost:
                break
            remaining -= cost
            cost_paid += cost
            bought += 1
            level += 1
        rows.append({
            "row_type": "budget_summary",
            "upgrade_number": "",
            "level_before_purchase": starting_level,
            "level_after_purchase": level,
            "cost_at_current_level": "",
            "cumulative_cost_for_sequence": cost_paid,
            "credit_budget": budget,
            "levels_bought_with_budget": bought,
            "unspent_credits": remaining,
        })
    return rows


def build_recruitment_rows(recruitment_profile: dict[str, Any], roster_profile: dict[str, Any], scenario: dict[str, Any]) -> list[dict[str, Any]]:
    prices = require_object(recruitment_profile.get("price_by_rarity"), "recruitment.price_by_rarity")
    recruits = roster_profile.get("recruits")
    if not isinstance(recruits, list) or not recruits:
        raise ValueError("founding_recruits.recruits must be a non-empty array.")
    starting_owned = scenario.get("starting_owned_recruits", recruitment_profile.get("starting_owned_recruits", []))
    if not isinstance(starting_owned, list) or any(not isinstance(item, str) for item in starting_owned):
        raise ValueError("starting_owned_recruits must be an array of recruit IDs.")
    if len(starting_owned) != len(set(starting_owned)):
        raise ValueError("starting_owned_recruits cannot contain duplicate IDs.")
    rows: list[dict[str, Any]] = []
    seen_ids: set[str] = set()
    for index, recruit_value in enumerate(recruits):
        recruit = require_object(recruit_value, f"founding_recruits.recruits[{index}]")
        recruit_id = recruit.get("id")
        rarity = recruit.get("rarity")
        name = recruit.get("name")
        if not isinstance(recruit_id, str) or not recruit_id.strip() or recruit_id in seen_ids:
            raise ValueError("Recruitment roster must contain unique non-empty recruit IDs.")
        if not isinstance(rarity, str) or rarity not in prices or not isinstance(name, str):
            raise ValueError(f"Recruit {recruit_id} has an unknown rarity or invalid name.")
        price = require_int(prices[rarity], f"recruitment.price_by_rarity.{rarity}")
        seen_ids.add(recruit_id)
        owned = recruit_id in starting_owned
        rows.append({
            "recruit_id": recruit_id,
            "name": name,
            "rarity": rarity,
            "trial_price": price,
            "owned_at_start": owned,
            "additional_purchase_cost": 0 if owned else price,
        })
    unknown = sorted(set(starting_owned) - seen_ids)
    if unknown:
        raise ValueError("starting_owned_recruits contains IDs absent from the roster: " + ", ".join(unknown))
    return rows


def apply_candidate_overrides(base_profiles: dict[str, dict[str, Any]], overrides: Any, label: str) -> dict[str, dict[str, Any]]:
    if not isinstance(overrides, dict):
        raise ValueError(f"Candidate {label} overrides must be a JSON object.")
    result = copy.deepcopy(base_profiles)
    for path, value in overrides.items():
        if path not in ALLOWED_OVERRIDES:
            raise ValueError(f"Candidate {label} uses unsupported override path {path!r}.")
        if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(float(value)):
            raise ValueError(f"Candidate override {path} must be a finite number.")
        target = ALLOWED_OVERRIDES[path]
        profile_name, *profile_path = target
        container, key = object_path(result[profile_name], tuple(profile_path), path)
        original = container[key]
        if isinstance(original, int) and not isinstance(original, bool):
            if not float(value).is_integer():
                raise ValueError(f"Candidate override {path} must be an integer.")
            container[key] = int(value)
        elif isinstance(original, (int, float)) and not isinstance(original, bool):
            container[key] = float(value)
        else:
            raise ValueError(f"Candidate override {path} does not target a numeric profile value.")
    return result


def candidate_metrics(profiles: dict[str, dict[str, Any]], scenario: dict[str, Any], horizon: int) -> dict[str, float | int]:
    progression = profiles["progression"]
    wave_profile = profiles["wave"]
    breaker_profile = profiles["breaker"]
    wave_rows = build_wave_rows(horizon, wave_profile, require_object(progression.get("evolution_material_policy"), "evolution_material_policy"), int(scenario.get("starting_credits", 0)))
    reboot_rules = require_object(progression.get("system_reboot"), "system_reboot")
    bonus_profile = require_object(progression.get("lifetime_influence_benefit"), "lifetime_influence_benefit")
    lifetime_start = require_int(scenario.get("starting_lifetime_influence", 0), "starting_lifetime_influence")
    award = reboot_award(horizon, reboot_rules)
    offline_rows = build_offline_rows(scenario.get("offline_claims", []), progression, wave_profile, horizon)
    upgrade_rows = build_upgrade_rows(scenario, breaker_profile)
    recruitment_rows = build_recruitment_rows(profiles["recruitment"], profiles["roster"], scenario)
    upgrade_costs = [row["cost_at_current_level"] for row in upgrade_rows if isinstance(row.get("cost_at_current_level"), int)]
    evolution_rows = build_evolution_rows(horizon, wave_rows, progression, [12])
    apex_cost = next((int(row["cumulative_roster_material_cost_through_tier"]) for row in evolution_rows if row["tier"] == "Requiem Form"), 0)
    return {
        "ordinary_credits_through_horizon": sum(int(row["ordinary_credits"]) for row in wave_rows),
        "credits_available_before_spending": int(scenario.get("starting_credits", 0)) + sum(int(row["ordinary_credits"]) for row in wave_rows),
        "evolution_data_through_horizon": int(wave_rows[-1]["cumulative_evolution_data"]) if wave_rows else 0,
        "influence_award_if_reboot_at_horizon": award,
        "damage_bonus_if_reboot_at_horizon": damage_bonus(lifetime_start + award, bonus_profile),
        "offline_credits_in_scenario_claims": sum(int(row["credits_awarded"]) for row in offline_rows),
        "breaker_upgrade_sequence_cost": sum(upgrade_costs),
        "twelve_recruit_total_apex_path_cost": apex_cost,
        "trial_cost_for_unowned_recruits": sum(int(row["additional_purchase_cost"]) for row in recruitment_rows),
    }


def write_csv(path: Path, rows: list[dict[str, Any]], columns: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def write_text(path: Path, contents: str) -> None:
    path.write_text(contents, encoding="utf-8", newline="\n")


def parse_scenario(path: Path | None) -> tuple[dict[str, Any], str | None]:
    if path is None:
        return {}, None
    value, digest = read_json(path)
    return require_object(value, "scenario file"), digest


def ensure_output_safe(output_dir: Path, safe_output_root: Path, project_root: Path, overwrite: bool) -> None:
    resolved = output_dir.resolve()
    resolved_safe_root = safe_output_root.resolve()
    if resolved != resolved_safe_root and resolved_safe_root not in resolved.parents:
        raise ValueError("Resolved output directory must remain inside the caller-selected safe output root.")
    blocked_roots = [
        (project_root / "data").resolve(),
        (project_root / "scripts").resolve(),
        (project_root / "tests").resolve(),
        (project_root / "saves").resolve(),
        (project_root / ".godot").resolve(),
    ]
    if any(resolved == blocked or blocked in resolved.parents for blocked in blocked_roots):
        raise ValueError("Output directory cannot be inside data, scripts, tests, saves, or .godot.")
    existing = [resolved / name for name in OUTPUT_NAMES if (resolved / name).exists()]
    if existing and not overwrite:
        listed = ", ".join(path.name for path in existing)
        raise ValueError(f"Report files already exist ({listed}); pass --overwrite to replace only the simulator's named reports.")


def markdown_summary(
    horizon: int,
    wave_rows: list[dict[str, Any]],
    reboot_rows: list[dict[str, Any]],
    offline_rows: list[dict[str, Any]],
    evolution_rows: list[dict[str, Any]],
    upgrade_rows: list[dict[str, Any]],
    scenario_name: str,
    candidate_rows: list[dict[str, Any]],
    recruitment_rows: list[dict[str, Any]],
) -> str:
    credits_total = int(wave_rows[-1]["cumulative_ordinary_credits"]) if wave_rows else 0
    material_total = int(wave_rows[-1]["cumulative_evolution_data"]) if wave_rows else 0
    apex_twelve = next((row for row in evolution_rows if row["tier"] == "Requiem Form" and row["recruit_count"] == 12), None)
    upgrade_costs = [int(row["cost_at_current_level"]) for row in upgrade_rows if row.get("row_type") == "per_upgrade"]
    lines = [
        "# Neon Requiem local balance scenario", "",
        f"- Scenario: `{scenario_name}`",
        f"- Prototype horizon: waves 1–{horizon}",
        "- Status: arithmetic report from prototype trial profiles; not a balance recommendation or combat forecast.",
        "- Wave clears are assumed once each through the horizon. Named-boss material rewards are excluded.", "",
        "## Scenario totals", "",
        f"- Ordinary credits across modeled clears: **{credits_total}**",
        f"- Starting credits plus modeled rewards, before spending: **{(int(wave_rows[-1]['credits_available_before_spending']) if wave_rows else 0)}**",
        f"- Evolution Data across modeled clears: **{material_total}**",
        f"- Reboot runs supplied: **{len(reboot_rows)}**",
        f"- Offline claims supplied / total credits: **{len(offline_rows)} / {sum(int(row['credits_awarded']) for row in offline_rows)}**",
        f"- BREAKER upgrade sequence cost: **{sum(upgrade_costs)}** for {len(upgrade_costs)} modeled purchases",
        f"- Trial cost to purchase all recruits not in the selected starting-owned list: **{sum(int(row['additional_purchase_cost']) for row in recruitment_rows)}**",
    ]
    if apex_twelve:
        lines.append(f"- Twelve-recruit cumulative trial cost through Requiem Form: **{apex_twelve['cumulative_roster_material_cost_through_tier']} Evolution Data**")
        balance = apex_twelve["roster_material_surplus_at_gate"] if apex_twelve["milestone_reached_by_horizon"] else "gate not reached"
        lines.append(f"- Material balance at Apex gate under the one-clear-per-wave assumption: **{balance}**")
    lines.extend([
        "", "## Reading the outputs", "",
        "- `wave_progression.csv`: ordinary credits and repeatable/first-clear Evolution Data by wave.",
        "- `reboot_scenarios.csv`: only manual run endpoints supplied in the scenario file.",
        "- `offline_claims.csv`: configured cap/rate without wave advancement or material rewards.",
        "- `evolution_supply.csv`: shared trial material supply and cumulative costs for selected roster sizes.",
        "- `breaker_upgrades.csv`: per-level rounded costs and optional explicit budget summaries.",
        "- `recruitment_costs.csv`: configured trial price and additional cost by founding recruit.",
        "- `sensitivity.csv`: base profile versus named numeric what-if overrides.", "",
        "No value is labeled balanced/unbalanced. A changed outcome requires a named scenario; source profiles were not changed.", "",
    ])
    if candidate_rows:
        lines.extend(["## Candidate comparison", "", "Overrides are what-if scenarios only; they do not replace the base trial profile.", ""])
    return "\n".join(lines)


def generate(args: argparse.Namespace) -> Path:
    project_root = args.project_root.resolve()
    loaded: dict[str, Any] = {}
    input_hashes: dict[str, str] = {}
    for label, relative_path in PROFILE_FILES.items():
        value, digest = read_json(project_root / relative_path)
        loaded[label] = require_object(value, label)
        input_hashes[str(relative_path).replace("\\", "/")] = digest

    scenario, scenario_hash = parse_scenario(args.scenario.resolve() if args.scenario else None)
    scenario_name = scenario.get("name", "baseline")
    if not isinstance(scenario_name, str) or not scenario_name.strip():
        raise ValueError("Scenario name must be a non-empty string.")
    horizon = args.wave_horizon if args.wave_horizon is not None else scenario.get("wave_horizon", 125)
    horizon = require_int(horizon, "wave_horizon", 1)
    prototype_limit = require_int(loaded["wave"].get("prototype_wave_limit"), "wave.prototype_wave_limit", 1)
    if horizon > prototype_limit:
        raise ValueError(f"wave_horizon {horizon} exceeds the profile prototype limit {prototype_limit}; post-limit extrapolation is unsupported.")
    if scenario.get("clear_each_wave_once", True) is not True:
        raise ValueError("Version 1 assumes one clear of each wave through the horizon; clear_each_wave_once must be true.")

    scenario.setdefault("starting_credits", 0)
    scenario.setdefault("starting_lifetime_influence", 0)
    scenario.setdefault("starting_spendable_influence", scenario["starting_lifetime_influence"])
    scenario.setdefault("reboot_runs", [])
    scenario.setdefault("offline_claims", [])
    scenario.setdefault("evolution_recruit_counts", [1, 12])
    scenario.setdefault("breaker_starting_level", 1)
    scenario.setdefault("breaker_upgrade_count", 10)
    scenario.setdefault("breaker_credit_budgets", [])
    scenario.setdefault("candidate_overrides", [])
    require_int(scenario["starting_credits"], "starting_credits")
    require_int(scenario["starting_lifetime_influence"], "starting_lifetime_influence")
    require_int(scenario["starting_spendable_influence"], "starting_spendable_influence")
    for name in ("reboot_runs", "offline_claims", "evolution_recruit_counts", "breaker_credit_budgets", "candidate_overrides"):
        if not isinstance(scenario[name], list):
            raise ValueError(f"{name} must be an array.")
    if not scenario["evolution_recruit_counts"]:
        raise ValueError("evolution_recruit_counts must be non-empty.")

    profiles = copy.deepcopy(loaded)
    wave_rows = build_wave_rows(horizon, profiles["wave"], require_object(profiles["progression"].get("evolution_material_policy"), "evolution_material_policy"), scenario["starting_credits"])
    reboot_rows = build_reboot_rows(scenario["reboot_runs"], profiles["progression"], scenario, horizon)
    offline_rows = build_offline_rows(scenario["offline_claims"], profiles["progression"], profiles["wave"], horizon)
    evolution_rows = build_evolution_rows(horizon, wave_rows, profiles["progression"], scenario["evolution_recruit_counts"])
    upgrade_rows = build_upgrade_rows(scenario, profiles["breaker"])
    recruitment_rows = build_recruitment_rows(profiles["recruitment"], profiles["roster"], scenario)

    candidate_rows: list[dict[str, Any]] = []
    base_metrics = candidate_metrics(profiles, scenario, horizon)
    for index, candidate_value in enumerate(scenario["candidate_overrides"]):
        candidate = require_object(candidate_value, f"candidate_overrides[{index}]")
        name = candidate.get("name")
        if not isinstance(name, str) or not name.strip():
            raise ValueError(f"candidate_overrides[{index}].name must be a non-empty string.")
        candidate_profiles = apply_candidate_overrides(profiles, candidate.get("overrides", {}), name)
        changed_metrics = candidate_metrics(candidate_profiles, scenario, horizon)
        for metric, base_value in base_metrics.items():
            candidate_value = changed_metrics[metric]
            candidate_rows.append({
                "candidate_name": name,
                "metric": metric,
                "base_value": f"{base_value:.8f}" if isinstance(base_value, float) else base_value,
                "candidate_value": f"{candidate_value:.8f}" if isinstance(candidate_value, float) else candidate_value,
                "difference": f"{candidate_value - base_value:.8f}" if isinstance(candidate_value, float) else candidate_value - base_value,
                "overrides": json.dumps(candidate.get("overrides", {}), sort_keys=True),
            })

    output_dir = args.output_dir.resolve()
    safe_output_root = args.safe_output_root.resolve()
    ensure_output_safe(output_dir, safe_output_root, project_root, args.overwrite)
    output_dir.mkdir(parents=True, exist_ok=True)
    definitions = {
        "wave_progression.csv": (wave_rows, ["wave", "ordinary_credits", "cumulative_ordinary_credits", "credits_available_before_spending", "repeatable_evolution_data", "first_clear_bonus", "first_clear_claim_ids", "cumulative_evolution_data"]),
        "reboot_scenarios.csv": (reboot_rows, ["run_index", "highest_cleared_wave_since_previous_reboot", "influence_awarded", "lifetime_influence_after_reboot", "spendable_influence_after_reboot", "lifetime_damage_bonus_fraction", "run_wave_after_reboot", "run_highest_cleared_after_reboot", "run_credits_after_reboot", "breaker_level_after_reboot"]),
        "offline_claims.csv": (offline_rows, ["claim_index", "holding_wave", "elapsed_seconds", "capped_elapsed_seconds", "cap_seconds", "ordinary_reward_at_holding_wave", "ordinary_rewards_per_hour", "credits_awarded", "wave_advancement", "material_rewards"]),
        "evolution_supply.csv": (evolution_rows, ["recruit_count", "tier", "required_permanent_wave", "milestone_reached_by_horizon", "material_cost_per_recruit_for_tier", "cumulative_material_cost_per_recruit_through_tier", "cumulative_roster_material_cost_through_tier", "cumulative_materials_earned_at_gate", "roster_material_surplus_at_gate"]),
        "breaker_upgrades.csv": (upgrade_rows, ["row_type", "upgrade_number", "level_before_purchase", "level_after_purchase", "cost_at_current_level", "cumulative_cost_for_sequence", "credit_budget", "levels_bought_with_budget", "unspent_credits"]),
        "recruitment_costs.csv": (recruitment_rows, ["recruit_id", "name", "rarity", "trial_price", "owned_at_start", "additional_purchase_cost"]),
        "sensitivity.csv": (candidate_rows, ["candidate_name", "metric", "base_value", "candidate_value", "difference", "overrides"]),
    }
    for filename, (rows, columns) in definitions.items():
        write_csv(output_dir / filename, rows, columns)
    write_text(output_dir / "summary.md", markdown_summary(horizon, wave_rows, reboot_rows, offline_rows, evolution_rows, upgrade_rows, scenario_name, candidate_rows, recruitment_rows))
    metadata = {
        "tool": "Neon Requiem Local Balance Simulator",
        "tool_version": TOOL_VERSION,
        "generated_at_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "scenario_name": scenario_name,
        "scenario_file": str(args.scenario.resolve()) if args.scenario else None,
        "scenario_sha256": scenario_hash,
        "safe_output_root": str(safe_output_root),
        "output_directory": str(output_dir),
        "wave_horizon": horizon,
        "assumptions": {
            "one_successful_clear_per_wave": True,
            "combat_outcomes_or_clear_times_predicted": False,
            "named_boss_rewards_included": False,
            "post_prototype_horizon_extrapolated": False,
            "source_profiles_modified": False,
            "all_balance_values_are_release_approved": False,
        },
        "input_sha256": input_hashes,
        "outputs": OUTPUT_NAMES,
    }
    write_text(output_dir / "run_metadata.json", json.dumps(metadata, indent=2, ensure_ascii=False) + "\n")
    return output_dir


def main() -> int:
    parser = argparse.ArgumentParser(description="Read-only local progression/economy scenario reports for Neon Requiem.")
    parser.add_argument("--project-root", type=Path, default=Path(__file__).resolve().parents[2], help="Project root (default: inferred from this script).")
    parser.add_argument("--scenario", type=Path, help="Optional JSON file containing named scenario inputs.")
    parser.add_argument("--wave-horizon", type=int, help="Override the scenario horizon; cannot exceed the prototype profile limit.")
    parser.add_argument("--safe-output-root", type=Path, required=True, help="Caller-selected root that contains the resolved report directory, including through symlinks/junctions.")
    parser.add_argument("--output-dir", type=Path, required=True, help="Report directory, which must resolve inside --safe-output-root and outside protected project folders.")
    parser.add_argument("--overwrite", action="store_true", help="Replace only the simulator's named report files if present.")
    args = parser.parse_args()
    try:
        output = generate(args)
    except (OSError, ValueError, KeyError, TypeError, OverflowError) as exc:
        print(f"Balance simulator error: {exc}", file=sys.stderr)
        return 2
    print(f"Reports written to: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
