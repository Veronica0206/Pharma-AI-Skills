# Changelog

## v0.2.0-public (2026-05-04) — Initial public release

This is the **first public release** of the skill. It is a deliberately scope-limited
version of an internal toolkit (preserved on the `v1.0-internal` git tag).

**What's in this release:**
- Sample size calculation for binary, continuous, and time-to-event endpoints
- Single-arm and 1:1 controlled designs
- Methods: exact binomial, Z-test unpooled, one- and two-sample t-tests, exponential rate, Schoenfeld log-rank
- CSV sample size table + PDF power curve output
- Three worked examples in `scripts/R/example_minimal.R`
- Base R only — no external packages required

**Intentionally out of scope** (see SKILL.md § Beyond This Skill):
- Bayesian Go/No-Go decision frameworks
- Pre-trial assurance (PPOS)
- 2:1 (or other unequal) randomization
- Poisson incidence-rate sizing
- Unconditional exact (Barnard-type) tests
- Frequentist post-trial decision analysis
- Operating-characteristics simulation
