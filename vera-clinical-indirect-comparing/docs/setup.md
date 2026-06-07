# Setup

## Requirements

- R 4.0 or later
- Base R only for the public binary/continuous Bucher and MAIC examples
- Current source access for trial publications, labels, clinical-study reports,
  or HTA dossiers when extracting real inputs

## Runtime Compatibility

This folder can be used as a Codex skill, Claude Code skill, or Claude.ai custom
skill package. See `reference/specs/runtime-compatibility.md` for install and
packaging details.

Claude Code can execute the bundled R scripts when `Rscript` is installed.
Claude.ai can use the workflow instructions, but hosted execution may require
running the R scripts externally if R is unavailable.

## Verify R

```bash
which Rscript
Rscript --version
```

## Smoke Test

```bash
cd <skill_root>/scripts/R
Rscript validate_core_formulas.R
Rscript example_minimal.R
```

Expected outputs:

- `CORE_FORMULA_VALIDATION=TRUE`
- `outputs/bucher/bucher_result.csv`
- `outputs/bucher/bucher_forest.pdf`
- `outputs/bucher_chain/bucher_chain_result.csv`
- `outputs/bucher_chain/bucher_chain_forest.pdf`
- `outputs/maic/maic_weights.csv`
- `outputs/maic/maic_balance.csv`
- `outputs/maic/maic_ess.csv`
- `outputs/maic/maic_source_effect.csv`
- `outputs/maic/maic_anchored_result.csv`
- `outputs/maic/maic_balance_plot.pdf`
- `outputs/maic_continuous/maic_source_effect.csv`
- `SMOKE_INDIRECT_COMPARISON=TRUE`

The formula validator checks deterministic Bucher, endpoint-derivation, and
MAIC weight-to-effect calculations. The smoke example uses synthetic data and is
intended to verify that all output paths run.
