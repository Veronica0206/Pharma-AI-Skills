# Master Protocol Trial Designing — Public Release

**An open-source agent skill for Claude Code, Codex, and other file-aware coding agents. It simulates the three master-protocol families — basket, umbrella, and platform — with one canonical method per family.**

This is the **public release** of the skill. It implements the reference baselines that frame any master-protocol discussion, plus the canonical multi-arm multi-stage (MAMS) design for umbrella trials. It is deliberately scoped so it stays easy to install, audit, and reason about. The skill teaches the **taxonomy** and lets users compare their hand-tuned designs against the standard baselines.

> **The skill structures execution. You own the judgment.**

---

## What this skill does

| Family | Public-scope method | Endpoint |
|---|---|---|
| **Basket** | No borrowing (independent Beta-Binomial per subgroup) **OR** complete pooling | Binary |
| **Umbrella** | Multi-arm multi-stage (MAMS) with stage-wise futility boundaries | Continuous or binary |
| **Platform** | Naïve concurrent-control comparison (no NCC adjustment) | Binary |

For each family, the skill runs Monte Carlo simulation and reports:

- Per-arm rejection rate / power
- Family-wise error rate (FWER)
- 1-minimum power across truly active arms
- (Umbrella) traditional separate-trial vs. MAMS expected N
- (Platform) per-period allocation across arms and shared control

CSV tables and PDF plots are written to a user-specified output directory.

---

## What this skill does NOT do

The following are **intentionally out of scope** for the public release. They are documented in `SKILL.md` § *Beyond This Skill* with primary references for each.

- **Basket information-borrowing methods**: Simon's Bayesian, Chen confirmatory, Wathen S-TI / SEP, Calibrated BHM (CBHM), full BHM with Gibbs sampling
- **Umbrella adaptive selection**: drop-the-losers (DTL), Bayesian adaptive randomization (BAR)
- **Platform NCC adjustment**: regression and time-machine adjustment for non-concurrent control
- **Platform response-adaptive randomization (RAR)** via Thompson sampling
- **Time-to-event and incidence-rate endpoints** in any of the three families
- **HTA and reimbursement strategy** for master protocols
- **External design-review checklists** (workflow step)

If you need any of these, treat this skill's output as a baseline against which to compare a more advanced method (or a more advanced biostatistician).

---

## Who this is for

- **Biostatisticians** producing a first-pass operating-characteristics table for a master-protocol concept paper or an early protocol draft.
- **Clinical scientists** validating that a CRO's basket / umbrella / platform proposal makes sense at the baseline level before evaluating the borrowing or adaptation features.
- **Postdocs and PhD / MS holders** who want a clean reference implementation of the master-protocol taxonomy, using base R with optional `MAMS`.

---

## Installation

Clone into either a Claude Code or Codex skills directory:

```bash
git clone https://github.com/Veronica0206/vera-master-trial-designing.git \
  ~/.claude/skills/vera-master-trial-designing

git clone https://github.com/Veronica0206/vera-master-trial-designing.git \
  ~/.codex/skills/vera-master-trial-designing
```

Or invoke from a checked-out repository in any compatible agent environment.

**Requirements:**
- R >= 4.0 (base R only, by default)
- Optional: `MAMS` R package — improves umbrella boundary computation; falls back to a built-in approximation if not installed (`install.packages("MAMS")`)

See `docs/setup.md` for verification steps.

---

## Quick start

```r
source("scripts/R/shared_utils.R")
source("scripts/R/master_config.R")
source("scripts/R/basket_simple.R")
source("scripts/R/umbrella_mams.R")
source("scripts/R/platform_simple.R")
source("scripts/R/run_master_framework.R")

cfg <- create_master_config(
  master_design_type = "basket",
  endpoint_type      = "binary",
  n_subgroups        = 4,
  null_params        = 0.20,
  alt_params         = c(0.45, 0.45, 0.20, 0.20),
  borrowing_method   = "none",
  alpha              = 0.10,
  n_sims             = 2000,
  seed               = 42,
  output_dir         = "outputs/basket"
)

run_master_framework(cfg)
```

For one full worked example per family, see [`scripts/R/example_minimal.R`](scripts/R/example_minimal.R).

---

## Documentation

- [`SKILL.md`](SKILL.md) — full skill specification (methods, workflow, scope)
- [`reference/specs/decision-roadmap.md`](reference/specs/decision-roadmap.md) — basket vs. umbrella vs. platform decision logic
- [`docs/guide.md`](docs/guide.md) — design notes for the public release
- [`docs/setup.md`](docs/setup.md) — installation and verification
- [`docs/changelog.md`](docs/changelog.md) — version history
- [`reference/specs/config-reference.md`](reference/specs/config-reference.md) — full `create_master_config()` parameter reference
- [`reference/specs/case-studies.md`](reference/specs/case-studies.md) — brief case studies illustrating each family
- [`reference/specs/cross-domain-principles.md`](reference/specs/cross-domain-principles.md) — high-level principles applicable across all master designs

---

## Related skills

- [`vera-clinical-indication-researching`](https://github.com/Veronica0206/vera-clinical-indication-researching) — pre-design dossier on indication landscape, MoA, endpoints, competitor study designs.
- [`vera-clinical-trial-designing`](https://github.com/Veronica0206/vera-clinical-trial-designing) — sample size calculation for binary, continuous, and time-to-event endpoints (also a scope-limited public release).

---

## License

GPL-3.0. See [`LICENSE`](LICENSE).

---

## Citation

If this skill informs published work:

> Veronica. *Master Protocol Trial Designing — basket, umbrella, and platform skill (public release).* GitHub repository, https://github.com/Veronica0206/vera-master-trial-designing
