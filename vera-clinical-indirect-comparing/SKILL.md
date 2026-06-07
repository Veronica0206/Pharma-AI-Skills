---
name: vera-clinical-indirect-comparing
description: >-
  Performs transparent first-pass clinical indirect treatment comparisons using
  Bucher common-comparator analysis, Bucher chain analysis, MAIC/PAIC, and
  anchored MAIC for binary and continuous endpoints. Activates when direct
  head-to-head evidence is unavailable or for anchored ITC, Bucher, MAIC,
  common-comparator, HTA sensitivity evidence, or connected-trial treatment
  comparison requests.
---

# Clinical Indirect Comparison Skill

Use this skill when a direct head-to-head estimate is unavailable and the user
needs a transparent first-pass indirect comparison using an anchored common
comparator or a connected three-treatment evidence chain.

## Table of Contents

- [Public Scope](#public-scope): supported methods and exclusions.
- [What Requires Judgment](#what-requires-judgment): assumptions the analyst must review.
- [Workflow](#workflow): step-by-step execution path.
- [Running the Base R Framework](#running-the-base-r-framework): Bucher, Bucher chain, and MAIC commands.
- [Output Interpretation](#output-interpretation): required reporting fields and caveats.

## Public Scope

This simplified public release supports binary and continuous endpoints only:

- Bucher's adjusted indirect comparison using two independent direct estimates
  with the same common comparator.
- Bucher's chain orientation when the target is A versus B but the available
  direct estimates are A versus C and C versus B.
- Endpoint-to-effect conversion before Bucher for binary counts and continuous
  mean/SD/N summaries.
- MAIC covariate weighting from source individual patient data (IPD) to published
  target aggregate covariate means.
- Balance and effective sample size (ESS) diagnostics after weighting.
- Weighted MAIC outcome effects for binary and continuous endpoints.
- Optional anchored MAIC by combining a weighted source treatment-control effect
  with a published target comparator-control effect on the same analysis scale.

Do not use this public version for rate endpoints, time-to-event endpoints,
full network meta-analysis, simulated treatment comparison (STC), unanchored
claims without explicit caveats, multi-trial MAIC, Bayesian HTA submissions, or
regulatory-grade evidence-synthesis certification. Use the full local skill when
rate or time-to-event support is needed.

## What Requires Judgment

The scripts compute estimates and diagnostics, but the analyst must decide
whether the comparison is scientifically defensible:

- The common comparator or via treatment must be clinically comparable across
  trials.
- Effect modifiers and prognostic factors must be prespecified, not selected
  only because they are convenient.
- MAIC balance must be judged alongside ESS loss; a numerically balanced but
  tiny ESS is fragile.
- Cross-trial endpoint definitions, timing, population, follow-up, and
  background therapy must be aligned before interpreting the estimate.
- Results are sensitivity evidence, not a substitute for randomized head-to-head
  data.

## Host Runtime Notes

- Works in Claude Code, Codex, and other file-aware coding agents.
- Requires R >= 4.0 and base R only.
- Claude Code can execute the bundled R scripts when `Rscript` is available.
  Claude.ai custom-skill uploads can use the workflow instructions, but may need
  the R analysis run externally if the hosted code environment lacks R.
- Use current web browsing/search tools when gathering trial publications,
  labels, clinical-study reports, or HTA dossiers. Prefer primary sources.
- Use `reference/templates/` for input CSV shapes and `scripts/R/` for the
  executable framework.
- Use `reference/specs/evaluation-cases.md` when checking trigger behavior or
  regression-testing skill activation.
- Use `reference/specs/runtime-compatibility.md` when installing or packaging
  the skill for Claude Code, Claude.ai, Codex, or another file-aware agent.

## Workflow

Read each workflow file before executing that step.

| Step | Responsibility | Executor | Document | Input | Output |
|------|----------------|----------|----------|-------|--------|
| 01 | Define comparison | Main Agent | `workflow/step01-define-question.md` | User request | PICOS + method choice |
| 02 | Prepare inputs | Main Agent | `workflow/step02-prepare-inputs.md` | Trial evidence | Direct-effect or MAIC input CSVs |
| 03 | Run analysis | Script | `workflow/step03-run-analysis.md` | Input CSVs | CSV + PDF outputs |
| 04 | Validate assumptions | Main Agent | `workflow/step04-validate-assumptions.md` | Outputs + evidence | Assumption audit |
| 05 | Translate results | Main Agent | `workflow/step05-translate-results.md` | Validated outputs | Interpretation + handoff |

## Running the Base R Framework

From the skill root:

```bash
cd scripts/R
Rscript validate_core_formulas.R
Rscript example_minimal.R
```

For Bucher's method from binary or continuous endpoint summaries:

```r
source("scripts/R/indirect_comparison.R")
run_bucher_from_endpoints(
  endpoint_csv = "endpoint_contrasts.csv",
  output_dir = "outputs/bucher",
  treatment_a = "Drug A",
  treatment_c = "Drug C",
  common_comparator = "Placebo"
)
```

Or use already-computed direct estimates on an additive analysis scale:

```r
run_bucher(
  input_csv = "bucher_direct_effects.csv",
  output_dir = "outputs/bucher",
  treatment_a = "Drug A",
  treatment_c = "Drug C",
  common_comparator = "Placebo"
)
```

For the alternate Bucher chain orientation, where the desired contrast is
`Drug A vs Drug B` and the available direct estimates are `Drug A vs Drug C`
plus `Drug C vs Drug B`:

```r
source("scripts/R/indirect_comparison.R")
run_bucher_chain(
  input_csv = "bucher_chain_direct_effects.csv",
  output_dir = "outputs/bucher_chain",
  treatment_a = "Drug A",
  treatment_b = "Drug B",
  via_treatment = "Drug C"
)
```

Use `run_bucher_chain_from_endpoints()` with the same treatment arguments when
the A-C and C-B direct effects need to be derived from endpoint summaries first.

For MAIC:

```r
source("scripts/R/indirect_comparison.R")
run_maic(
  ipd_csv = "maic_ipd.csv",
  target_csv = "maic_targets.csv",
  output_dir = "outputs/maic",
  treatment_arm = "Drug A",
  comparator_arm = "Placebo",
  endpoint_type = "binary",
  outcome_col = "response"
)
```

## Output Interpretation

- `derived_direct_effects.csv`: binary or continuous treatment-control effects
  prepared for Bucher.
- `bucher_result.csv`: anchored indirect estimate and uncertainty.
- `bucher_chain_result.csv`: chain-oriented indirect estimate for
  `A vs B = d_AC + d_CB`.
- `maic_balance.csv`: unweighted vs weighted source covariate means compared
  with target aggregate means.
- `maic_ess.csv`: overall and arm-level effective sample size.
- `maic_source_effect.csv`: weighted source effect, when a comparator arm is
  available. Its scale depends on `endpoint_type`.
- `maic_anchored_result.csv`: optional anchored MAIC result when a published
  target comparator contrast is supplied.

Always report the analysis scale, the estimate orientation, the confidence
interval, ESS, balance gaps, and cross-trial comparability caveats. Use
`connection_role` in result CSVs to distinguish a classic common comparator from
a Bucher chain via treatment.
