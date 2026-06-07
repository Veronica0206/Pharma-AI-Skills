# Step 03: Run Analysis

## Goal

Run the base R framework to pool rates and generate benchmark outputs.

## Command

From the skill root:

```r
source("scripts/R/meta_analysis.R")
run_meta_analysis(
  input_csv = "endpoint_counts.csv",
  output_dir = "outputs/meta_analysis"
)
```

Optional filters:

```r
run_meta_analysis(
  input_csv = "endpoint_counts.csv",
  output_dir = "outputs/week8_response",
  endpoint_filter = "response",
  timing_filter = "week 8"
)
```

## Expected Outputs

- `cleaned_counts.csv`
- `definition_audit.csv`
- `pooled_arm_rates.csv`
- `paired_effects.csv` when paired data exist
- `design_benchmarks.csv`
- `forest_rates.pdf`
- `forest_effects.pdf` when paired data exist

## Proceed To

`workflow/step04-validate-outputs.md`
