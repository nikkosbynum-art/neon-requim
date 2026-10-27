# Local Balance Simulator

This Python CLI reads current local prototype JSON profiles and emits CSV and Markdown scenario reports. It is analysis-only: it does not edit source profiles, runtime saves, or game state, and it does not predict combat outcomes or clear times.

## Run

From the Neon Requiem project root:

```powershell
python tools/balance_simulator/balance_simulator.py --safe-output-root "C:\NeonRequiemReports" --output-dir "C:\NeonRequiemReports\baseline"
```

Choose a report root that you control and pass it with `--safe-output-root`. The report directory's resolved path must be inside that root, including after resolving existing symlinks or Windows junctions. The root and report directory must also stay outside protected project folders (`data`, `scripts`, `tests`, `saves`, and `.godot`). The metadata records both resolved paths. Do not point the root into runtime data or save locations.

The default scenario assumes one successful clear of each wave from 1 through 125, lists ten BREAKER upgrade purchases starting at level 1, compares evolution supply for one and twelve recruits, and leaves reboot/offline rows empty unless supplied. These are analysis defaults, not gameplay rules or release caps. Recruitment cost output uses configured trial prices and the selected starting-owned roster.

To model a shorter horizon, pass `--wave-horizon 75`. The tool refuses horizons beyond the source profile's configured prototype limit. Where an integer is expected, JSON integers and finite integral JSON numbers (such as `3` and `3.0`) are accepted; fractions and booleans are rejected. If named report files already exist in the output directory, generation stops unless `--overwrite` is provided. With overwrite enabled, only the simulator's nine named report files are replaced.

## Scenario JSON

All fields are optional. Unspecified fields use the documented analysis defaults.

```json
{
  "name": "manual sample",
  "wave_horizon": 125,
  "starting_credits": 600,
  "starting_lifetime_influence": 0,
  "starting_spendable_influence": 0,
  "clear_each_wave_once": true,
  "reboot_runs": [
    { "highest_cleared_wave": 25 },
    { "highest_cleared_wave": 50 }
  ],
  "offline_claims": [
    { "holding_wave": 25, "elapsed_seconds": 28800 }
  ],
  "evolution_recruit_counts": [1, 12],
  "breaker_starting_level": 1,
  "breaker_upgrade_count": 10,
  "breaker_credit_budgets": [600, 1200],
  "candidate_overrides": [
    {
      "name": "offline rate what-if",
      "overrides": {
        "offline_earnings.ordinary_rewards_per_hour": 2.0
      }
    }
  ]
}
```

The reboot endpoints and offline claim above are illustrative inputs, not an approved schedule or policy. Candidate overrides accept only numeric paths listed in the script and remain in memory; they never modify source profiles. Reports include input hashes, assumptions, and prototype-only labels.

## Outputs

- `wave_progression.csv`
- `reboot_scenarios.csv`
- `offline_claims.csv`
- `evolution_supply.csv`
- `breaker_upgrades.csv`
- `recruitment_costs.csv`
- `sensitivity.csv`
- `summary.md`
- `run_metadata.json`

Outputs are arithmetic consequences of the supplied prototype profiles. Material surplus, a what-if delta, or a high wave reward is not a balance verdict; compare it with approved targets and actual playtest evidence.
