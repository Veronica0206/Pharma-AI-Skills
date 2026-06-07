# Step 02: Prepare Inputs

## Goal

Create analysis-ready CSV files using the templates in `reference/templates/`.

## Bucher Inputs

Use `reference/templates/bucher_direct_effects_template.csv` when direct
effects and SEs are already available. Use
`reference/templates/endpoint_contrasts_template.csv` when direct effects need
to be derived from binary counts or continuous mean/SD/N summaries.

Use `reference/templates/bucher_chain_direct_effects_template.csv` for the
alternate chain orientation where the target is A versus B but the available
direct estimates are A versus C and C versus B.

Each estimate must be oriented as `treatment` versus `comparator`. If an input is
reversed, the R script can re-orient it by negating the analysis-scale estimate,
but the source should still be documented clearly.

## MAIC Inputs

Use:

- `reference/templates/maic_ipd_template.csv`
- `reference/templates/maic_targets_template.csv`

The IPD file must include one row per patient, a treatment arm column, all
covariates listed in the target file, and the outcome column required by the
chosen endpoint type:

- Binary: 0/1 outcome column.
- Continuous: numeric outcome column.

## Anchored MAIC Comparator Input

When creating an anchored MAIC, provide a direct-effect CSV for the published
target comparator contrast using the same direct-effect template.

The published target comparator label should match `comparator_arm` unless the
analyst intentionally maps two labels that refer to the same clinical
comparator.

## Validation Checkpoint

Before running the script, confirm:

- Required columns are present for the selected input contract.
- Treatment, comparator, and arm labels match exactly, including case.
- Ratio measures are on the log scale in direct-effect CSVs.
- Bucher inputs use one endpoint family, effect measure, and analysis scale.
- MAIC covariates are numeric, clinically justified, and present in both IPD and
  target aggregate files.

## Proceed To

`workflow/step03-run-analysis.md`
