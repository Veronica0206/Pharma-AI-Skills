# Evaluation Cases

Use these prompts when checking whether the skill triggers at the right time and
changes agent behavior usefully.

## Positive Trigger Cases

1. "Run a Bucher indirect comparison for Drug A versus Drug C through placebo
   using binary response counts from two trials."
   - Expected behavior: use `run_bucher_from_endpoints()`, derive log odds
     ratios, report the `Drug A vs Drug C` orientation and common-comparator
     assumptions.

2. "We need Drug A versus Drug B, but only have Drug A versus Drug C and Drug C
   versus Drug B mean-difference estimates."
   - Expected behavior: use `run_bucher_chain()` or
     `run_bucher_chain_from_endpoints()`, apply `d_AB = d_AC + d_CB`, and label
     Drug C as the via treatment.

3. "Use MAIC to reweight our IPD to match the published target trial baseline
   age, prior therapy, and baseline score, then estimate a weighted binary
   treatment effect."
   - Expected behavior: fit exponential-tilting weights, report balance, ESS,
     arm summaries, and `maic_source_effect.csv`.

4. "Create an anchored MAIC using weighted A versus placebo from IPD and a
   published C versus placebo odds ratio."
   - Expected behavior: run MAIC first, then combine source A versus placebo
     with target C versus placebo using the Bucher variance rule.

## Edge Cases

1. "The C versus placebo estimate is entered as placebo versus C."
   - Expected behavior: re-orient the contrast, record
     `source_orientation = reversed_from_source`, and keep the reported target
     contrast orientation explicit.

2. "The binary endpoint has zero events in one arm."
   - Expected behavior: apply the documented continuity correction or bounded
     response-rate behavior and flag fragility in interpretation.

3. "The target means are outside the IPD support and ESS collapses."
   - Expected behavior: report balance and ESS first, avoid strong comparative
     claims, and label the estimate as exploratory sensitivity evidence.

## Negative Trigger Cases

1. "Design a new phase 2 trial sample-size plan."
   - Expected behavior: prefer a trial-designing skill unless the user supplies
     an indirect estimate to use as a sensitivity input.

2. "Run a full Bayesian network meta-analysis across ten trials."
   - Expected behavior: do not use this skill as the primary method; state that
     full NMA is out of scope.

3. "Write a clinical background landscape for an indication."
   - Expected behavior: prefer an indication-researching workflow unless the
     user asks for an indirect treatment comparison.
