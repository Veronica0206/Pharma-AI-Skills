# Changelog

## v0.2.0-public (2026-05-04) — Initial public release

This is the **first public release** of the skill. It is a deliberately
scope-limited version of an internal toolkit (preserved on the `v1.0-internal`
git tag).

**What's in this release:**
- Basket trials with `"none"` (independent per-subgroup) or `"complete"` (pooled) baselines, binary endpoint
- Umbrella trials with multi-arm multi-stage (MAMS) design, continuous or binary endpoint
- Platform trials with naïve concurrent-control comparison, binary endpoint
- Monte Carlo operating characteristics: per-arm rejection rate, FWER, 1-minimum power
- CSV + PDF outputs for each family
- Three worked examples in `scripts/R/example_minimal.R`
- Base R only (optional `MAMS` package improves boundary computation; falls back to a built-in approximation if not installed)

**Intentionally out of scope** (see SKILL.md § Beyond This Skill):
- Basket information-borrowing methods (Simon's Bayesian, Chen confirmatory, Wathen S-TI / SEP, Calibrated BHM, full BHM with Gibbs)
- Umbrella adaptive selection (drop-the-losers, Bayesian adaptive randomization)
- Platform NCC adjustment (regression, time-machine)
- Platform RAR (Thompson sampling)
- TTE and incidence-rate endpoints
- HTA / reimbursement strategy considerations
- External design-review checkpoint
