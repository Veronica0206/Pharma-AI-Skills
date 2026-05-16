# Step 05: Interpret Results

## Goal
Present simulation results to the user with appropriate context and recommendations.

## Inputs
- Validated CSV tables and PDF visualizations from Step 04

## Outputs
- Clear summary tables, key visualizations, and design recommendations

## Procedure

### 1. Present Operating Characteristics

Read the primary OC table for the chosen family and present as a formatted table:

- **Basket**: `basket_oc_table.csv` — per-subgroup rejection rate and posterior mean estimate.
- **Umbrella**: `umbrella_oc_summary.csv` — FWER, 1-minimum power, complete power, complete-correct power, mean total N.
- **Platform**: `platform_arm_results.csv` plus `platform_oc_table.csv` — per-arm rejection rate and FWER.

### 2. Highlight Key Findings

#### Basket Designs

- **No-borrowing baseline**: per-subgroup rejection rate ≈ alpha for null subgroups, high for active subgroups; FWER scales with the number of null subgroups.
- **Complete-pooling baseline**: a single decision applied uniformly across subgroups. Useful when subgroups are believed to respond similarly; misleading when they do not.
- **Boundary reminder**: this skill does not implement adaptive borrowing. If the user wants to compare borrowing methods, point them to SKILL.md § *Beyond This Skill*.

#### Umbrella Designs

- **Sample size savings**: compare umbrella expected N vs. traditional separate-trial N (`umbrella_sample_size.csv`). Shared control gives a structural advantage.
- **Power**: report the relevant power definition (1-minimum vs. complete vs. complete-correct) for the user's objective.
- **Stage-wise behavior**: futility boundaries from `umbrella_boundaries.csv` show when poorly performing arms drop out.

#### Platform Designs

- **Concurrent-control caveat**: this skill compares each arm only against control patients enrolled during that arm's active periods. **No NCC adjustment is applied** — a time trend in the control arm will bias all per-arm comparisons. State this explicitly when presenting results.
- **Per-arm rejection rate**: high for truly active arms, near alpha for null arms. FWER may be controlled at alpha because the arms enter and leave at different times (effectively independent subhypotheses), but this should be confirmed by the OC table.

### 3. Present Key Visualizations

| Family | Primary plot | What to highlight |
|---|---|---|
| Basket | `basket_oc_curves.pdf` | Per-subgroup rejection-rate bar chart, alpha reference line |
| Basket | `basket_forest_plot.pdf` | Spread of effect estimates across simulations vs. true effect |
| Umbrella | `umbrella_arm_comparison.pdf` | Per-arm power; null arms should sit near alpha |
| Umbrella | `umbrella_boundary_plot.pdf` | Stage-wise decision boundaries |
| Platform | `platform_timeline.pdf` | Arm activity Gantt chart |
| Platform | `platform_oc_curves.pdf` | Per-arm rejection rate bar chart |

### 4. Boundary Reminder

End the report with a brief reminder of what the public-scope skill does **not** address:

> This simulation used the public-scope baselines: no information borrowing for
> basket, MAMS only for umbrella, and concurrent-control only for platform. If
> the design depends on adaptive borrowing (Simon's Bayesian, CBHM, full BHM),
> alternative umbrella selection (DTL, BAR), NCC adjustment, RAR, or TTE /
> incidence-rate endpoints, treat these results as a baseline only and bring
> in a more advanced method. See SKILL.md § *Beyond This Skill*.

### 5. Suggested Next Steps

- Sensitivity to effect size and SoC assumptions
- Different `n_per_subgroup` / `n_per_arm_stage` / `n_per_period`
- For umbrella: different `n_stages`
- Handoff to `vera-clinical-trial-designing` for sample size sizing of a single arm
