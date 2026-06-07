# Step 03: Run Analysis

## Goal

Run the base R framework and write reproducible CSV/PDF outputs.

## Bucher Command

From binary or continuous endpoint summaries:

```r
source("scripts/R/indirect_comparison.R")
run_bucher_from_endpoints(
  endpoint_csv = "endpoint_contrasts.csv",
  output_dir = "outputs/bucher",
  treatment_a = "Drug A",
  treatment_c = "Drug C",
  common_comparator = "Placebo"
)
```

From already-computed direct effects:

```r
source("scripts/R/indirect_comparison.R")
run_bucher(
  input_csv = "bucher_direct_effects.csv",
  output_dir = "outputs/bucher",
  treatment_a = "Drug A",
  treatment_c = "Drug C",
  common_comparator = "Placebo"
)
```

Alternate chain orientation, when the target is `Drug A vs Drug B` and the
available direct effects are `Drug A vs Drug C` plus `Drug C vs Drug B`:

```r
source("scripts/R/indirect_comparison.R")
run_bucher_chain(
  input_csv = "bucher_chain_direct_effects.csv",
  output_dir = "outputs/bucher_chain",
  treatment_a = "Drug A",
  treatment_b = "Drug B",
  via_treatment = "Drug C"
)
```

From endpoint summaries in the same A-C plus C-B layout:

```r
source("scripts/R/indirect_comparison.R")
run_bucher_chain_from_endpoints(
  endpoint_csv = "endpoint_contrasts.csv",
  output_dir = "outputs/bucher_chain",
  treatment_a = "Drug A",
  treatment_b = "Drug B",
  via_treatment = "Drug C"
)
```

## MAIC Command

```r
source("scripts/R/indirect_comparison.R")
run_maic(
  ipd_csv = "maic_ipd.csv",
  target_csv = "maic_targets.csv",
  output_dir = "outputs/maic",
  treatment_arm = "Drug A",
  comparator_arm = "Placebo",
  endpoint_type = "binary",
  outcome_col = "response",
  anchored_comparator_csv = "published_c_vs_placebo.csv",
  target_treatment_arm = "Drug C"
)
```

Omit `anchored_comparator_csv` when only MAIC weights and a weighted source
effect are needed.

For continuous outcomes, set `endpoint_type = "continuous"` and set
`outcome_col` to the numeric endpoint column.

## Framework Validation

When changing the R framework or before packaging the skill, run:

```bash
cd <skill_root>/scripts/R
Rscript validate_core_formulas.R
Rscript example_minimal.R
```

## Validation Checkpoint

Before moving to interpretation, confirm:

- The expected result CSV exists for the selected method.
- The `contrast`, `analysis_scale`, and `connection_role` columns match the
  intended estimand.
- MAIC runs include `maic_balance.csv`, `maic_ess.csv`, and
  `maic_assumption_audit.csv`.
- No warning about MAIC optimization convergence is ignored.

## Proceed To

`workflow/step04-validate-assumptions.md`
