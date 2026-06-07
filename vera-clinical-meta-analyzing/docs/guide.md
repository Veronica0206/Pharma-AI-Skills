# Clinical Meta-Analysis Guide

## Intended Use

Use this skill when the user needs a transparent literature benchmark before
sample-size or Go/No-Go planning.

Good requests:

- "Pool placebo remission rates for endpoint X at week 8."
- "Extract x/N counts from these studies and create a forest plot."
- "Give me a historical control benchmark for this endpoint."
- "Translate these published rates into trial-design assumptions."

Avoid claiming that this public skill is a complete systematic review unless the
user supplies the full search strategy, screening rules, and risk-of-bias work.

## Workflow Summary

1. Define the indication, population, endpoint definition, timing, and arm types.
2. Extract one row per study arm using the endpoint count template.
3. Run the base R analysis script.
4. Validate counts, pooled estimates, heterogeneity, and plots.
5. Translate benchmark rates into design-ready H0/control/target assumptions.

## Endpoint Harmonization

Pool only when these dimensions are compatible:

- Endpoint definition
- Endpoint timing
- Population and treatment line
- Study phase/era
- Arm context
- Count status

If definitions differ, either split the analysis or report a sensitivity result.

## Output Interpretation

Use `pooled_arm_rates.csv` for benchmark rates and `design_benchmarks.csv` for
the trial-design handoff. Always report `k`, `I2`, `tau2`, and count-status
caveats. If heterogeneity is high, present a range rather than a single value.
