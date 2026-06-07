# Clinical Indirect Comparison Guide

## Intended Use

Use this skill when the user needs an anchored indirect comparison and can
provide either:

- two direct estimates sharing a common comparator for Bucher's method,
- two connected direct estimates for the Bucher chain case, such as A versus C
  and C versus B when the target contrast is A versus B,
- binary counts or continuous mean/SD/N summaries that can be converted into
  those direct estimates, or
- source IPD plus target aggregate covariate means for MAIC.

Good requests:

- "Run a Bucher comparison for Drug A vs Drug C through placebo."
- "Compare Drug A vs Drug B using published Drug A vs Drug C and Drug C vs Drug B."
- "Use MAIC to reweight our trial to match the published comparator trial."
- "Check whether the MAIC ESS is too low to trust the estimate."
- "Create an anchored MAIC using weighted A vs placebo and published C vs placebo."

Avoid presenting the output as definitive comparative effectiveness evidence
unless trial similarity, endpoint alignment, and effect modifiers have been
audited.

## Method Selection

Use Bucher's method when both direct effects are available or can be derived
from arm-level summaries and the common comparator is aligned. Use MAIC when
source IPD are available and the target trial differs on important baseline
covariates that are available as published aggregate means.

## Bucher Requirements

- Same common comparator or connected via treatment.
- Same endpoint definition and timing.
- Same effect measure and analysis scale.
- Independent evidence sources.
- No unaddressed effect modifiers across trial populations.

For ratio measures, use log scale estimates such as log odds ratio or log risk
ratio.

Supported endpoint conversions in the public release:

- Binary: log odds ratio, log risk ratio, or risk difference.
- Continuous: mean difference.

Two Bucher orientations are supported:

- Common-comparator orientation: estimate A versus C from A versus B and
  C versus B using `run_bucher()`.
- Chain orientation: estimate A versus B from A versus C and C versus B using
  `run_bucher_chain()`.

## MAIC Requirements

- Source IPD contains the selected effect modifiers or prognostic factors.
- Target aggregate means are available for the same covariates.
- Binary endpoint is coded as 0/1 when `endpoint_type = "binary"`.
- Continuous outcome is numeric when `endpoint_type = "continuous"`.
- Comparator arm is present for anchored source treatment-control estimation,
  unless the analysis is deliberately single-arm and caveated.

## Interpretation Rules

- Report ESS and balance before reporting the treatment effect.
- Treat ESS below half of the original sample size as a serious fragility flag.
- If balance remains poor after weighting, do not interpret the indirect effect
  as adjusted for that covariate.
- If endpoint timing or population differs across trials, present results as an
  exploratory sensitivity analysis.
- State the estimate orientation, for example `Drug A vs Drug C`.
