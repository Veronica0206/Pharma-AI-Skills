---
name: vera-clinical-trial-designing
description: >-
  Calculates clinical-trial sample sizes for binary, continuous, and
  time-to-event endpoints across single-arm and 1:1 controlled designs. Supports
  exact binomial, unpooled two-proportion Z-test, one- and two-sample t-tests,
  exponential-rate single-arm TTE, and Schoenfeld log-rank methods; generates
  CSV sample-size tables and PDF power curves through the bundled base R
  framework. Activates for sample size, power calculation, Schoenfeld,
  log-rank, two-proportion, t-test sizing, or trial-sizing requests.
---

# Clinical Trial Design Skill

A focused sample size calculator for biostatisticians designing clinical trials
with binary, continuous, or time-to-event primary endpoints. Supports single-arm
and 1:1 controlled designs. Produces a sample size table (CSV) across an
alpha/power grid and a power-curve plot (PDF). Executes the R framework directly.

> This is the **public release** of the skill. It implements the standard textbook
> methods every biostatistician needs and demonstrates a clean parameterization +
> execution pattern. For more advanced methods — Bayesian Go/No-Go decision
> frameworks, pre-trial assurance (PPOS), 2:1 allocation, Poisson incidence-rate
> sizing, unconditional exact tests — see "[Beyond This Skill](#beyond-this-skill)".

## What This Skill Automates vs. What Requires Human Judgment

This skill handles the **computational machinery** of sample size calculation.
Everything below runs automatically once parameters are set:

- Sample size search across alpha/power grids
- Per-arm sample size derivation (1:1 designs)
- Schoenfeld events-required + sample size for TTE under exponential hazards with
  uniform accrual
- CSV table generation and power-curve PDF plot

**What this skill does NOT automate — and where the biostatistician's judgment remains essential:**

- **Endpoint selection.** Which primary endpoint to choose for a given indication
  and regulatory context. The skill accepts any of three endpoint families;
  choosing the *right* one requires clinical judgment about regulator
  acceptability, mechanism, and competitive landscape.
- **H0 and H1 parameterization.** The null and alternative hypotheses encode
  clinical assumptions — what counts as "standard of care" and what counts as
  "clinically meaningful improvement." These are judgment calls grounded in
  disease knowledge, not statistical calculations.
- **Estimand strategy.** Treatment-policy vs. hypothetical vs. composite estimand
  is a clinical-regulatory choice about what the sponsor is willing to claim on
  the label. ICH E9(R1) provides the framework; applying it requires
  therapeutic-area knowledge.
- **Design rationale for regulatory submission.** The skill produces numbers.
  Defending those numbers in front of an FDA statistical reviewer — explaining
  why this alpha, why this power, why this sample size is adequate — is a human
  skill built from regulatory experience.
- **MMRM sizing convention.** For primary analyses using MMRM, industry
  convention is to size with a two-sample t-test at the primary timepoint. This
  skill implements that convention. Knowing *when* this convention applies and
  when simulation-based sizing is warranted instead is the biostatistician's
  expertise.

The machine part is done. The judgment part is yours.

## Host Runtime Notes

- Works in Claude Code, Codex, and other file-aware coding agents.
- Requires R >= 4.0 and base R only.
- Use the host's normal file-reading, shell, and editing tools. In Codex, use
  shell/Rscript plus `rg` and `apply_patch`; in Claude Code, use the equivalent
  Read/Grep/Glob/Bash/Edit tools.

## Table of Contents

1. [When to Use](#when-to-use)
2. [Workflow Overview](#workflow-overview)
3. [Step-by-Step Instructions](#step-by-step-instructions)
4. [Output Structure](#output-structure)
5. [Configuration Reference](#configuration-reference)
6. [Framework Modules](#framework-modules)
7. [Beyond This Skill](#beyond-this-skill)
8. [Error Handling](#error-handling)

---

## When to Use

Use this skill when:
- Calculating sample size for a Phase 1b, Phase 2, or Phase 3 clinical trial
  with a binary, continuous, or time-to-event primary endpoint
- Producing a sample size table across an alpha and power grid for a study
  protocol or design discussion
- Generating a power-vs-N curve to illustrate the sensitivity of N to alpha
  level

Do **not** use this skill for: Bayesian Go/No-Go decision frameworks, pre-trial
assurance (PPOS), 2:1 randomization, Poisson incidence-rate endpoints,
unconditional exact tests, or post-trial decision analysis. See
"[Beyond This Skill](#beyond-this-skill)" for pointers.

---

## Workflow Overview

```
User inputs (endpoint type, H0/H1, design)
    |
Step 1: Collect and validate parameters
    |
Step 2: Build R config
    |
Step 3: Run framework
    |
Step 4: Validate outputs (CSV table + PDF curve)
    |
Step 5: Deliver results with interpretation
```

| Step | Responsibility | Executor | Document | Input | Output |
|------|----------------|----------|----------|-------|--------|
| 01 | Collect parameters | Main Agent | `workflow/step01-collect-params.md` | User request | Validated params |
| 02 | Build R config | Main Agent | `workflow/step02-build-config.md` | Params | R config |
| 03 | Run R framework | Main Agent | `workflow/step03-run-framework.md` | R config | CSV + PDF outputs |
| 04 | Validate outputs | Main Agent | `workflow/step04-validate-outputs.md` | Output files | Validated artifacts |
| 05 | Deliver results | Main Agent | `workflow/step05-deliver-results.md` | Validated artifacts | Table + plot + interpretation |

---

## Step-by-Step Instructions

### STEP 1: Collect and Validate Parameters

Ask the user to confirm:

**Required:**
- `endpoint_type`: `binary`, `continuous`, or `tte`
- `null_param`: H0 value (rate, mean, or hazard)
- `alt_param`: H1 value (rate, mean, or hazard; for TTE, must be smaller than `null_param`)
- `design`: `single_arm` or `controlled` (controlled = 1:1 only)

**For continuous endpoints:**
- `sd`: standard deviation of the endpoint

**For TTE endpoints:**
- `accrual_time`: accrual period duration (any consistent time unit)
- `followup_time`: follow-up after last enrollment

**Optional (defaults apply):**
- `alphas`: vector of one-sided alpha levels (default `c(0.025, 0.05)`)
- `powers`: vector of power targets (default `c(0.80, 0.90)`)
- `output_dir`: directory for CSV + PDF outputs

---

### STEP 2: Build R Config and Analysis Script

Read `workflow/step02-build-config.md` before executing.

Generate an R script that:
1. Sources framework modules from this skill's `scripts/R/`
2. Calls `create_config()` with the user's parameters
3. Calls `run_sample_size_framework()` with `output_dir` set

Save the generated script to `runs/[run_id]/analysis.R`.

---

### STEP 3: Run the R Framework

Read `workflow/step03-run-framework.md` before executing.

```bash
cd [framework_dir] && Rscript runs/[run_id]/analysis.R
```

Resolve the framework directory:

```bash
SKILL_ROOT="$(dirname "$(find . -name 'vera-clinical-trial-designing' -type d | head -1)")/vera-clinical-trial-designing"
FRAMEWORK_DIR="$SKILL_ROOT/scripts/R"
```

Watch for:
- R not installed → check `Rscript --version`
- H0 == H1 → ask user to confirm distinct values
- For TTE: `alt_param < null_param` is required (lower hazard = better)

---

### STEP 4: Validate Outputs

Read `workflow/step04-validate-outputs.md` before executing.

**Expected outputs in `output_dir`:**
- `sample_size.csv` — required N across alpha × power combinations
- `power_curve.pdf` — power vs. N for the configured alphas

Verify both files exist and `sample_size.csv` is non-empty.

---

### STEP 5: Deliver Results

Read `workflow/step05-deliver-results.md` before executing.

Present:
1. The `sample_size.csv` contents as a formatted table.
2. A reference to `power_curve.pdf`.
3. Interpretation: "At alpha=[a], power=[p], required N is [n_total] ([n_per_arm] per arm)."
4. A reminder that endpoint selection, H0/H1 parameterization, and regulatory
   defense remain the biostatistician's responsibility.

---

## Output Structure

| File | Content |
|------|---------|
| `sample_size.csv` | N by alpha, power, design, test |
| `power_curve.pdf` | Power vs. N curve, one line per alpha |

---

## Configuration Reference

See `reference/specs/config-reference.md` for full `create_config()` parameter documentation.

---

## Framework Modules

Located at `scripts/R/` within the skill directory.

| File | Purpose |
|------|---------|
| `config.R` | `create_config()` — builds the configuration object |
| `sample_size.R` | Sample size + power functions (exact binomial, Z-unpooled, t-tests, Schoenfeld) |
| `run_framework.R` | `run_sample_size_framework()` — master entry point, saves CSV + PDF |
| `example_minimal.R` | Three worked examples (binary, continuous, TTE) |

### Sample Size Functions (sample_size.R)

| Function | Test | Design |
|----------|------|--------|
| `ss_binomial_single_arm()` | Exact binomial | Single-arm binary |
| `power_binomial_single_arm()` | Exact binomial (fixed N) | Single-arm binary |
| `ss_z_unpooled()` | Z-test unpooled | Controlled binary 1:1 |
| `power_z_unpooled()` | Z-test unpooled (fixed N) | Controlled binary 1:1 |
| `ss_ttest_single_arm()` | One-sample t-test | Single-arm continuous |
| `power_ttest_single_arm()` | One-sample t-test (fixed N) | Single-arm continuous |
| `ss_ttest_two_arm()` | Two-sample t-test | Controlled continuous 1:1 |
| `power_ttest_two_arm()` | Two-sample t-test (fixed N) | Controlled continuous 1:1 |
| `ss_logrank_single_arm()` | Exponential rate | Single-arm TTE |
| `power_logrank_single_arm()` | Exponential rate (fixed N) | Single-arm TTE |
| `ss_logrank_two_arm()` | Schoenfeld log-rank | Controlled TTE 1:1 |
| `power_logrank_two_arm()` | Schoenfeld log-rank (fixed N) | Controlled TTE 1:1 |

---

## Beyond This Skill

The following methods are **intentionally out of scope** for this public release.
They are standard but require nontrivial calibration and defense; this skill
does not implement them so it can stay easy to install, audit, and reason about.

| Method | Use case | References |
|---|---|---|
| **Bayesian Go/No-Go decision framework** | Phase 1b/2a signal detection with predefined Go / Consider / No-Go thresholds on posterior probability | Lalonde et al. 2007 (Clin Pharmacol Ther) |
| **Pre-trial assurance / PPOS** | Phase 2 → Phase 3 transition: probability of trial success given Phase 2 posterior | O'Hagan, Stevens & Campbell 2005 |
| **2:1 (or other unequal) allocation** | When ethical or operational reasons favor more patients on the experimental arm | Standard generalization of Schoenfeld and Z-test sample-size formulas |
| **Poisson sample size for incidence rates** | Recurrent or count-based endpoints (e.g., exacerbation rates, AE counts) | Signorini 1991; Gu, Ng, Tang & Schucany 2008 |
| **Unconditional exact (Barnard-type) test** | Two-proportion testing where exact size matters and Fisher's conditioning is too conservative | Barnard 1947; Berger 1996 |
| **Frequentist post-trial decision analysis** | After data are collected: Fisher / Barnard / Welch / log-rank tests with confidence intervals | Standard texts |
| **Operating characteristics across true-parameter grids** | Pre-trial simulation of P(Go) / P(No-Go) under a range of true effect sizes | Custom simulation |
| **MMRM-based sizing for repeated measures** | Mixed-models simulation when convention assumptions break down | Mallinckrodt et al. 2008 |

If you are sizing a trial that needs any of the above, treat this skill's output
as a baseline and bring in a biostatistician (or a more advanced method) for the
final number.

---

## Error Handling

**R not installed:**
- Check: `Rscript --version`
- Framework uses base R only; no `install.packages` step is required.

**H0 == H1 (no effect):**
- Sample size is undefined. Ask the user to confirm distinct H0 and H1 values.

**TTE with `alt_param >= null_param`:**
- Lower hazard = better treatment in this skill's convention. Ask the user to
  confirm direction.

**Output directory not writable:**
- Default to `runs/[timestamp]/` within framework directory.
- Fall back to `/tmp/sample_size_[timestamp]/`.

**Alpha convention:**
- All alpha values are **one-sided** throughout (e.g., 0.025 one-sided ≈ 0.05 two-sided).
- `power.t.test` calls already use `alternative = "one.sided"`; do not double the alpha.
