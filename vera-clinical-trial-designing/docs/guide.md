# Skill Design Notes

## Public Scope

This is the public release of the skill. It is deliberately scope-limited.

**What's in the public version:**
- Sample size for binary, continuous, and time-to-event endpoints
- Single-arm and 1:1 controlled designs
- Methods: exact binomial, Z-test unpooled, t-tests, exponential rate, Schoenfeld log-rank
- CSV table + power-curve PDF output

**What's intentionally excluded** (see SKILL.md § Beyond This Skill):
- Bayesian Go/No-Go decision frameworks
- Pre-trial assurance (PPOS)
- 2:1 (or other unequal) randomization
- Poisson incidence-rate sizing
- Unconditional exact (Barnard-type) tests
- Frequentist post-trial decision analysis
- Operating-characteristics simulation across true-parameter grids

The `v1.0-internal` git tag preserves the full internal version that was the
starting point for this release.

## Naming Convention

The `vera-clinical-*` skill family uses a `clinical` domain (not in the official
Anthropic skill domain list). Accepted deviation — no standard domain covers
clinical pharmacology workflows.

## R Framework Location

The R framework modules are bundled at `scripts/R/` within the skill directory.
The skill-bundled scripts are the authoritative source. See SKILL.md § Step 3
for resolution order.

## Framework Modules Summary

- **config.R** — `create_config()` returns a single config object that drives the
  framework. One endpoint type, one design, one alpha grid, one power grid.
- **sample_size.R** — sample size and fixed-N power functions:
  - Binary single-arm: `ss_binomial_single_arm`, `power_binomial_single_arm`
  - Binary controlled (1:1): `ss_z_unpooled`, `power_z_unpooled`
  - Continuous: `ss_ttest_single_arm`, `ss_ttest_two_arm`, `power_ttest_*`
  - TTE: `ss_logrank_single_arm`, `ss_logrank_two_arm`, `power_logrank_*`,
    `prob_event_exponential` (helper)
  - Alpha convention: one-sided throughout
    (`sig.level = alpha, alternative = "one.sided"`)
- **run_framework.R** — `run_sample_size_framework()` master entry point.
  Internally calls `compute_sample_size()` and `save_power_curve()`.

## Worked Example

`scripts/R/example_minimal.R` runs three end-to-end examples (binary, continuous,
TTE) and writes outputs into `outputs/`. This is the recommended starting point
for a new user.
