# Methods Reference

## Bucher's Adjusted Indirect Comparison

For treatment A versus treatment C through common comparator B:

```text
d_AC = d_AB - d_CB
Var(d_AC) = Var(d_AB) + Var(d_CB)
```

The formula assumes independent direct evidence and aligned effect orientation.
Ratio measures must be analyzed on the log scale.

The same three-treatment evidence triangle can appear in a second orientation.
If the target contrast is A versus B and the available direct estimates are
A versus C and C versus B, use the chain form:

```text
d_AB = d_AC + d_CB
Var(d_AB) = Var(d_AC) + Var(d_CB)
```

This is algebraically equivalent to reversing C versus B into B versus C and
using the common-comparator formula, but the public script exposes it as
`run_bucher_chain()` so the reported contrast matches the evidence layout.

The simplified public script can create the required direct contrasts from:

- binary counts,
- continuous means/SDs/sample sizes.

## MAIC

The public MAIC implementation estimates exponential tilting weights so that
weighted source covariate means match published target aggregate covariate means.
Weights are normalized to have mean 1 in the source IPD.

The same covariate-derived weights are applied to every source arm. This keeps
the source trial contrast internally aligned with the reweighted target
population, but finite-sample arm balance, overlap, and ESS still require
review.

The effective sample size is:

```text
ESS = (sum(w)^2) / sum(w^2)
```

Low ESS indicates that only a small subset of source patients supports the
target population and should be treated as a fragility warning.

## Anchored MAIC

When source IPD include A and B, and the target publication provides C versus B,
the weighted source A versus B effect can be combined with the target C versus B
effect using the Bucher variance rule.

The public script separates the two MAIC steps:

1. Estimate weights and report balance/ESS.
2. Apply the weights to the chosen outcome family:
   - binary: log odds ratio, log risk ratio, or risk difference,
   - continuous: mean difference.

Binary endpoint SEs are first-pass approximations based on ESS and bounded
weighted response rates. Continuous endpoint SEs divide arm-specific weighted
population variance by ESS. Treat results as sensitivity evidence, especially
when ESS is small.
