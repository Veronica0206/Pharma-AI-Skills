# Step 01: Define Question

## Goal

Define the estimand, evidence network, and method before extracting numbers.

## Required Decisions

- Target treatments to compare, such as A versus C or A versus B.
- Common comparator or via treatment, usually placebo, standard of care, or the
  treatment connecting two observed contrasts.
- Endpoint definition and timing.
- Effect measure and analysis scale.
- Whether the method is Bucher common-comparator, Bucher chain, MAIC, or
  anchored MAIC.
- Whether the comparison is for exploratory planning, HTA sensitivity work, or
  a manuscript-style evidence summary.

## Method Choice

Use Bucher when the direct contrasts are already available. Use the Bucher chain
command when the target is A versus B but the available contrasts are A versus C
and C versus B. Use MAIC when source IPD are available and target trial
aggregate covariates need to be matched.

## Validation Checkpoint

Before extracting numbers, confirm:

- Target contrast and estimate orientation are written explicitly.
- Evidence layout maps to one method: Bucher common-comparator, Bucher chain,
  MAIC, or anchored MAIC.
- Endpoint family and analysis scale are compatible across evidence sources.

## Proceed To

`workflow/step02-prepare-inputs.md`
