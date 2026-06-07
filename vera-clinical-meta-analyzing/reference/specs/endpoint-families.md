# Endpoint Families

The meta-analysis skill supports four design-facing endpoint families. Keep
families separate unless a clinical/statistical rationale justifies conversion.

| Family | Required source data | Single-arm measure | Comparative measure |
|--------|----------------------|--------------------|---------------------|
| `binary` | responders, total | logit proportion | risk difference, risk ratio, odds ratio |
| `continuous` | mean, SD, N | mean | mean difference, standardized mean difference |
| `time_to_event` | HR with CI/SE, or log HR with SE | not pooled as a rate by default | hazard ratio |
| `incidence_rate` | events and person-time | rate | rate ratio |

## Extraction Rules

- Preserve endpoint definition and timing before mapping to a family.
- Store the analysis scale explicitly, for example `log_hazard_ratio` or
  `mean_difference`.
- If only a p-value, median, Kaplan-Meier landmark, or percentage is available,
  mark the row as reconstructed or unusable unless a defensible variance can be
  recovered.
- Ordinal or multi-category endpoints are not pooled directly. Convert them to a
  prespecified responder threshold, mean score, or proportional-odds effect only
  when the source data and trial-design target justify that conversion.

## Design Handoff

- Binary: hand off `h0`, control rate, target rate, risk difference, or risk
  ratio.
- Continuous: hand off null mean, target mean, SD, and clinically meaningful
  delta.
- Time-to-event: hand off control event assumptions, target hazard ratio, and
  CI/sensitivity range.
- Incidence-rate: hand off control rate per person-time, target rate or rate
  ratio, and exposure assumptions.
