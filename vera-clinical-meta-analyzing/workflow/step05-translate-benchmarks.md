# Step 05: Translate Benchmarks

## Goal

Turn validated pooled estimates into trial-design assumptions.

## Report

- Most relevant placebo/control pooled rate
- Active-control pooled rate, if relevant
- Treatment-arm pooled rate or target range
- Risk difference or risk ratio summary when paired data are available
- Sensitivity range if heterogeneity, timing, endpoint definitions, or
  population differences matter
- Caveats about reconstructed counts, sparse studies, mixed eras, or non-pooled
  endpoints

## Handoff

For `vera-clinical-trial-designing`:

- placebo/control rate -> single-arm `null_param` or expected control arm rate
- treatment target -> `alt_param`
- paired risk difference -> clinically meaningful delta
- sensitivity range -> scenario grid

Use cautious wording: "supports a planning benchmark" rather than "proves the
true control rate."
