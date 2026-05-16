# Design Guide

## Public Scope

This is the public release of the skill. It is deliberately scope-limited.

**What's in the public version:**
- Basket trial: `"none"` (independent per-subgroup) and `"complete"` (pooled) baselines, binary endpoint
- Umbrella trial: multi-arm multi-stage (MAMS), continuous or binary endpoint
- Platform trial: naïve concurrent-control comparison, binary endpoint

**What's intentionally excluded** (see SKILL.md § Beyond This Skill):
- Information-borrowing methods (Simon's Bayesian, Chen, Wathen, CBHM, full BHM with Gibbs)
- Drop-the-losers (DTL) and Bayesian adaptive randomization (BAR) for umbrella
- Non-concurrent-control (NCC) adjustment and response-adaptive randomization (RAR) for platform
- TTE and incidence-rate endpoints
- HTA / reimbursement strategy
- External design-review checkpoint

The `v1.0-internal` git tag preserves the full internal version that was the
starting point for this release.

## Framework Location

R scripts: `scripts/R/` within this skill directory.

## Module Summary

| Module | Function |
|--------|----------|
| `master_config.R` | Configuration builder and validator |
| `shared_utils.R` | Common simulation utilities (data generators, posterior helpers, FWER/power, simulation harness, CSV/PDF writers) |
| `basket_simple.R` | Basket trial: `"none"` or `"complete"` |
| `umbrella_mams.R` | Umbrella trial: MAMS boundaries and simulation |
| `platform_simple.R` | Platform trial: naïve concurrent-control simulation |
| `run_master_framework.R` | Master dispatcher and output saver |
| `example_minimal.R` | One worked example per family |

## Naming Convention

- Functions: `verb_design_method()` (e.g., `run_basket_single()`, `umbrella_mams_simulate()`).
- Config class: `"master_config"`.
- Output files: `{design}_{content}.{csv|pdf}`.

## Dependencies

- Base R (all modules)
- Optional: `MAMS` package — improves umbrella boundary computation; falls back to a built-in approximation when absent.
