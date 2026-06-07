# Step 04: Validate Outputs

## Goal

Confirm the analysis outputs are internally consistent and fit for design use.

## Checks

- `cleaned_counts.csv` has no missing `responders`, `total`, `arm_type`, or
  `study_id`.
- All `responders` values are between 0 and `total`.
- `definition_audit.csv` shows only compatible endpoint definitions for the
  intended pooled analysis.
- `pooled_arm_rates.csv` reports `k`, `rate`, confidence limits, `Q`, `I2`, and
  `tau2`.
- Forest plot PDFs exist and are non-trivial in file size.
- If `paired_effects.csv` exists, confirm each comparison used rows from the
  same `study_id`, endpoint, and timing.

## Red Flags

- Mixed endpoint definitions hidden inside one pooled estimate.
- High heterogeneity reported as a single definitive benchmark.
- Reconstructed counts dominating the analysis.
- Shared controls double-counted without an explicit rule.

## Proceed To

`workflow/step05-translate-benchmarks.md`
