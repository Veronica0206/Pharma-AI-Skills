# Data Contracts

## Direct-Effect CSV

Required columns:

- `comparison_id`
- `treatment`
- `comparator`
- `effect_measure`
- `analysis_scale`
- `estimate`
- `se`
- `source`

`estimate` and `se` must be on the additive analysis scale. Use log scale for
ratio measures such as odds ratio or risk ratio.

For the common-comparator Bucher command, the direct effects usually represent
A versus B and C versus B. For the chain Bucher command, the same columns are
used, but the rows represent A versus C and C versus B so the script can compute
A versus B.

## Endpoint-Contrast CSV

Use `reference/templates/endpoint_contrasts_template.csv` when direct effects
need to be created from binary or continuous endpoint summaries before Bucher's
method.

Required columns:

- `comparison_id`
- `treatment`
- `comparator`
- `endpoint_type`
- `effect_measure`
- `source`

Endpoint-specific columns:

- Binary: `treatment_events`, `treatment_total`, `comparator_events`,
  `comparator_total`.
- Continuous: `treatment_mean`, `treatment_sd`, `treatment_n`,
  `comparator_mean`, `comparator_sd`, `comparator_n`.

Supported `endpoint_type` values in the public release are `binary` and
`continuous` only.

## MAIC IPD CSV

Required columns:

- one patient identifier column
- an arm column, default `arm`
- all covariates listed in the target aggregate CSV
- one binary or continuous outcome column

Endpoint-specific outcome columns:

- Binary: 0/1 `outcome_col`, default `response`.
- Continuous: numeric `outcome_col`, for example `change_score`.

## MAIC Target CSV

Required columns:

- `covariate`
- `target_mean`

Each covariate must exist in the IPD CSV and be numeric.

## Result CSV Columns

Bucher, Bucher chain, MAIC source-effect, and anchored MAIC result CSVs share
the same result schema:

- `method`
- `contrast`
- `treatment`
- `comparator`
- `common_comparator`
- `connection_treatment`
- `connection_role`
- `effect_measure`
- `analysis_scale`
- `estimate`
- `se`
- `lower`
- `upper`
- `natural_estimate`
- `natural_lower`
- `natural_upper`
- `alpha`

Use `connection_role` to interpret the connecting treatment:

- `common_comparator`: classic A versus C through B, using
  `d_AC = d_AB - d_CB`.
- `via_treatment`: chain orientation A versus B through C, using
  `d_AB = d_AC + d_CB`.

`common_comparator` is retained as a backward-compatible column name in all
result files. For Bucher chain outputs, read it together with
`connection_role = "via_treatment"`.

## MAIC Output Files

- `maic_weights.csv`: source IPD with the final `maic_weight` column.
- `maic_balance.csv`: target, unweighted source, and weighted source covariate
  means with balance gaps.
- `maic_ess.csv`: overall and arm-specific effective sample sizes.
- `maic_arm_summary.csv`: weighted endpoint summaries by arm.
- `maic_source_effect.csv`: weighted treatment effect when `comparator_arm` is
  provided.
- `maic_target_effect.csv`: oriented published comparator contrast when anchored
  MAIC is requested.
- `maic_anchored_result.csv`: anchored indirect effect after Bucher
  combination.
