# Clinical Trial Designing — Sample Size Calculation

**An open-source agent skill for Claude Code, Codex, and other file-aware coding agents. It computes required sample size and produces a power curve for clinical trials with binary, continuous, or time-to-event primary endpoints.**

This is the **public release** of the skill. It implements the standard textbook methods every biostatistician needs and demonstrates a clean parameterization-and-execution pattern that drops into an agent workflow. It is deliberately scoped so it stays easy to install, audit, and reason about.

> **The skill structures execution. You own the judgment.**

---

## What this skill does

| Endpoint | Single-arm | Controlled (1:1) |
|---|---|---|
| **Binary** | Exact binomial | Z-test unpooled |
| **Continuous** | One-sample t-test | Two-sample t-test |
| **Time-to-event** | Exponential rate | Schoenfeld log-rank |

For any of the above:

1. Computes required N across a configurable alpha × power grid.
2. Saves the table to `sample_size.csv`.
3. Plots power vs. N for the configured alphas to `power_curve.pdf`.

That's it.

---

## What this skill does NOT do

The following are **intentionally out of scope** for the public release. They are standard but require nontrivial calibration, judgment, and regulatory defense — and that is the part that should not be on autopilot.

- Bayesian Go/No-Go decision frameworks
- Pre-trial assurance / PPOS (Phase 2 → Phase 3)
- 2:1 (or other unequal) randomization
- Poisson sample size for incidence-rate / count endpoints
- Unconditional exact (Barnard-type) tests
- Frequentist post-trial decision analysis (Fisher, Welch, log-rank tests on observed data)
- Operating-characteristics simulation across true-parameter grids
- MMRM-based sizing for repeated-measures designs

See `SKILL.md` § *Beyond This Skill* for references on each.

---

## Who this is for

- **Biostatisticians** producing a first-pass sample size table for a study protocol.
- **Clinical scientists** validating a CRO's calculation or running a quick sensitivity check.
- **PhD / MS holders** entering biostatistics roles who want a clean reference implementation that uses base R only and matches the conventions taught in standard texts.

---

## Installation

Clone into either a Claude Code or Codex skills directory:

```bash
git clone https://github.com/Veronica0206/vera-clinical-trial-designing.git \
  ~/.claude/skills/vera-clinical-trial-designing

git clone https://github.com/Veronica0206/vera-clinical-trial-designing.git \
  ~/.codex/skills/vera-clinical-trial-designing
```

Or invoke from a checked-out repository in any compatible agent environment.

**Requirements:**
- R >= 4.0 (base R only — no external packages required)

See [`docs/setup.md`](docs/setup.md) for verification steps.

---

## Quick start

```r
source("scripts/R/config.R")
source("scripts/R/sample_size.R")
source("scripts/R/run_framework.R")

cfg <- create_config(
  endpoint_type = "binary",
  design        = "controlled",
  null_param    = 0.30,
  alt_param     = 0.50,
  alphas        = c(0.025, 0.05),
  powers        = c(0.80, 0.90),
  label         = "Phase 2 binary"
)

run_sample_size_framework(cfg, output_dir = "outputs/")
```

For three full worked examples (binary, continuous, TTE), see [`scripts/R/example_minimal.R`](scripts/R/example_minimal.R).

---

## Documentation

- [`SKILL.md`](SKILL.md) — full skill specification (parameters, workflow, methods)
- [`docs/guide.md`](docs/guide.md) — getting-started walkthrough
- [`docs/setup.md`](docs/setup.md) — installation and verification
- [`docs/changelog.md`](docs/changelog.md) — version history
- [`reference/specs/config-reference.md`](reference/specs/config-reference.md) — full `create_config()` parameter reference

---

## Related skills

- [`vera-clinical-indication-researching`](https://github.com/Veronica0206/vera-clinical-indication-researching) — pre-design dossier on indication landscape, MoA, endpoints, competitor study designs.
- [`vera-master-trial-designing`](https://github.com/Veronica0206/vera-master-trial-designing) — basket, umbrella, and platform master-protocol designs (also a scope-limited public release).

---

## License

GPL-3.0. See [`LICENSE`](LICENSE).

---

## Citation

If this skill informs published work:

> Veronica. *Clinical Trial Designing — sample size calculation skill (public release).* GitHub repository, https://github.com/Veronica0206/vera-clinical-trial-designing
