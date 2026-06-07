# Setup

## Requirements

- R 4.0 or later
- Base R only

## Verify R

```bash
which Rscript
Rscript --version
```

## Smoke Test

```bash
cd <skill_root>/scripts/R
Rscript example_minimal.R
```

Expected outputs:

- `outputs/example/cleaned_counts.csv`
- `outputs/example/definition_audit.csv`
- `outputs/example/pooled_arm_rates.csv`
- `outputs/example/paired_effects.csv`
- `outputs/example/design_benchmarks.csv`
- `outputs/example/forest_rates.pdf`
- `outputs/example/forest_effects.pdf`

The example uses synthetic study counts for a binary endpoint and is intended
only to verify that the base R framework runs.
