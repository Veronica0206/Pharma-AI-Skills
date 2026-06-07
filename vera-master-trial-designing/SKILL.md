---
name: vera-master-trial-designing
description: >-
  Designs and simulates master protocol clinical trials across three families:
  basket (one intervention across prespecified subgroups), umbrella (multiple
  interventions within one protocol population), and platform (arms entering and
  leaving over time). This public release covers the reference baselines for
  each family: basket with no borrowing or complete pooling (binary endpoints),
  umbrella with multi-arm multi-stage (MAMS) design (continuous or binary
  endpoints), and platform with naive concurrent-control comparison (binary
  endpoints). Generates per-arm rejection rates, FWER, and 1-minimum power via
  Monte Carlo simulation. Outputs CSV + PDF. Executes R framework directly.
  Use when user asks about basket trial, umbrella trial, platform trial, master
  protocol, MAMS, multi-arm multi-stage, or wants to size and simulate a
  master-protocol design.
  Triggers on: basket trial, umbrella trial, platform trial, master protocol,
  MAMS, multi-arm multi-stage, multi-arm trial, perpetual platform.
---

# Master Protocol Trial Design Skill — Public Release

A biostatistician's toolkit for designing and simulating master protocol
clinical trials. This is the **public release**; it implements one canonical
method per master-protocol family so users can learn the taxonomy and explore
operating characteristics under standard baselines. Information-borrowing
methods, drop-the-losers, BAR, NCC adjustment, and response-adaptive
randomization are intentionally out of scope — see
"[Beyond This Skill](#beyond-this-skill)" for references.

## What This Skill Automates vs. What Requires Human Judgment

This skill handles the **simulation and computation engine**:

- Monte Carlo simulation of basket / umbrella / platform trials across scenario grids
- FWER computation under any-null configurations for multiplicity assessment
- MAMS boundary computation (with `MAMS` package if available, else approximation)
- 1-minimum and complete power computation for umbrella designs
- Per-period concurrent-control allocation tracking for platform designs
- CSV + PDF output for all operating characteristics

**What this skill does NOT automate — and where the biostatistician's judgment remains essential:**

- **Choosing the master protocol family.** Basket vs. umbrella vs. platform is
  not a statistical decision — it depends on whether the clinical question is
  "one drug across subgroups" vs. "many drugs in one population" vs.
  "perpetual evaluation." This requires understanding portfolio strategy,
  regulatory landscape, and operational feasibility.
- **Borrowing method selection** (when you graduate beyond this skill).
  Choosing among Simon's Bayesian, Chen, Wathen, CBHM, full BHM, etc. and
  defending that choice to a regulator requires understanding the scientific
  basis for borrowing. "The data say borrowing helps" is not enough.
- **Interpreting OC results for governance committees.** The skill produces
  operating-characteristics tables. Translating those into a governance
  recommendation — "this design has adequate power under realistic scenarios
  but the FWER is inflated under adversarial scenarios, here's why we accept
  that tradeoff" — is a communication and judgment skill.
- **Protocol governance design.** Who sits on the DSMB, when do interim looks
  happen, what triggers arm addition or removal, how to handle consent when
  the protocol adapts mid-enrollment — these are operational and ethical
  decisions.
- **Cross-institutional coordination.** Master protocols span multiple sites
  and sometimes multiple sponsors. Aligning SAPs, managing data flow, and
  handling unblinding for dropped arms is project leadership, not simulation.

The machine part is done. The judgment part is yours.

## Host Runtime Notes

- Works in Claude Code, Codex, and other file-aware coding agents.
- Requires R >= 4.0 and base R. The optional `MAMS` package improves umbrella
  boundary computation; the framework falls back to a built-in approximation if
  it is not installed.
- Use the host's normal file-reading, shell, and editing tools. In Codex, use
  shell/Rscript plus `rg` and `apply_patch`; in Claude Code, use the equivalent
  Read/Grep/Glob/Bash/Edit tools.

## Table of Contents

- [When to Use](#when-to-use)
- [Workflow Overview](#workflow-overview)
- [Master Protocol Taxonomy](#master-protocol-taxonomy)
- [Step-by-Step Instructions](#step-by-step-instructions)
- [Output Structure](#output-structure)
- [Configuration Reference](#configuration-reference)
- [Framework Modules](#framework-modules)
- [Beyond This Skill](#beyond-this-skill)
- [Error Handling](#error-handling)

---

## When to Use

Use this skill when the user wants to **size or simulate** a master protocol
trial in one of these configurations:

**Basket (binary endpoint, public scope):**
- One intervention tested across multiple prespecified subgroups
- "No borrowing" baseline: each subgroup analyzed independently
- "Complete pooling" baseline: all subgroups pooled into a single test
- Phase II screening or early-stage evaluation

**Umbrella (continuous or binary endpoint):**
- Multiple interventions tested within one protocol population
- Multi-arm multi-stage (MAMS) design with stage-wise futility stopping

**Platform (binary endpoint, public scope):**
- Multiple arms entering and leaving over time
- Shared concurrent control (no NCC adjustment in this release)
- Per-arm test using only patients enrolled while the arm was active

Do **not** use this skill for: information-borrowing basket methods (Simon's
Bayesian, Chen, Wathen, CBHM, BHM with Gibbs), drop-the-losers or BAR umbrella
designs, NCC-adjusted or RAR platform designs, or TTE/incidence-rate endpoints
in any family. See "[Beyond This Skill](#beyond-this-skill)" for pointers.

---

## Workflow Overview

```
User request
    |
    v
[STEP 1]  Select design type -> reference/specs/decision-roadmap.md
    |
    v
[STEP 2]  Build master config -> create_master_config()
    |
    v
[STEP 3]  Run simulation -> run_master_framework()
    |
    v
[STEP 4]  Validate outputs -> CSV + PDF
    |
    v
[STEP 5]  Interpret results
```

| Step | Document | Input | Output |
|------|----------|-------|--------|
| 01 | `workflow/step01-select-design-type.md` | User request | Chosen master design family |
| 02 | `workflow/step02-build-master-config.md` | Family + parameters | `master_config` object |
| 03 | `workflow/step03-run-simulation.md` | Config | CSV + PDF outputs |
| 04 | `workflow/step04-validate-outputs.md` | Output files | Validated artifacts |
| 05 | `workflow/step05-interpret-results.md` | Validated artifacts | Tables + plots + interpretation |

---

## Master Protocol Taxonomy

| Family | Question | Public-scope method |
|---|---|---|
| **Basket** | One drug, several subgroups (e.g., one TKI across multiple tumor types) — does it work in each? | No borrowing (independent Beta-Binomial test per subgroup) OR complete pooling (single Beta-Binomial across all subgroups) |
| **Umbrella** | One disease, several drugs — which arms graduate? | MAMS with stage-wise futility (and optionally efficacy) boundaries |
| **Platform** | A perpetual protocol — arms enter and leave over time, control evolves | Naïve concurrent-control comparison: each arm tested using only the control patients enrolled during the arm's active periods |

For all three, OCs are computed by Monte Carlo over `n_sims` simulated trials.

---

## Step-by-Step Instructions

### STEP 1: Select Design Type

Ask the user one question: **"Is the trial about one drug across several
subgroups (basket), several drugs in one disease (umbrella), or a perpetual
protocol with arms entering and leaving (platform)?"**

If the user is unsure, see `reference/specs/decision-roadmap.md`.

If the answer maps to an out-of-scope feature (e.g., "I want to use BHM with
information borrowing"), redirect them to "[Beyond This Skill](#beyond-this-skill)"
before proceeding.

### STEP 2: Build the Master Config

Read `workflow/step02-build-master-config.md`.

Generate an R script that sources framework modules and calls
`create_master_config()` with parameters appropriate to the design:

| Family | Required | Optional |
|---|---|---|
| basket | `n_subgroups`, `null_params`, `alt_params`, `borrowing_method` (`"none"` or `"complete"`) | `n_per_subgroup`, `go_threshold`, `alpha`, `n_sims` |
| umbrella | `n_subgroups` (= `n_arms`), `null_params`, `alt_params`, `umbrella_method = "mams"` | `n_stages`, `n_per_arm_stage`, `sd` (continuous), `alpha`, `n_sims` |
| platform | `n_subgroups`, `null_params`, `alt_params`, `n_periods`, `n_per_period`, `arms_schedule = list(enter=, leave=)` | `alpha`, `n_sims` |

Save the generated script to `runs/[run_id]/analysis.R`.

### STEP 3: Run the Simulation

Read `workflow/step03-run-simulation.md`.

```bash
cd "$FRAMEWORK_DIR" && Rscript "runs/[run_id]/analysis.R"
```

Resolve `FRAMEWORK_DIR` to this skill's `scripts/R/` directory.

### STEP 4: Validate Outputs

Read `workflow/step04-validate-outputs.md`. Confirm the expected CSVs and PDFs
exist for the chosen family (see [Output Structure](#output-structure)).

### STEP 5: Interpret Results

Read `workflow/step05-interpret-results.md`. Present operating characteristics
to the user with the boundary reminder that this skill does not automate any
adaptive borrowing, NCC adjustment, or RAR — those decisions remain the
biostatistician's.

---

## Output Structure

### Basket (`output_dir/`)

| File | Content |
|---|---|
| `basket_oc_table.csv` | Per-subgroup rejection rate and posterior mean estimate |
| `basket_fwer.csv` | Family-wise error rate under the global-null configuration |
| `basket_subgroup_decisions.csv` | One representative simulation's decision frame |
| `basket_oc_curves.pdf` | Per-subgroup rejection-rate bar chart |
| `basket_forest_plot.pdf` | Boxplot of per-subgroup effect estimates across simulations |

### Umbrella (`output_dir/`)

| File | Content |
|---|---|
| `umbrella_power_table.csv` | Per-arm power and conditional effect estimate |
| `umbrella_oc_summary.csv` | FWER, 1-minimum power, complete power, mean total N |
| `umbrella_sample_size.csv` | Traditional separate-trial vs. MAMS expected N |
| `umbrella_boundaries.csv` | MAMS futility and efficacy boundaries by stage |
| `umbrella_arm_comparison.pdf` | Per-arm power bar chart |
| `umbrella_boundary_plot.pdf` | Stage-wise boundary plot |

### Platform (`output_dir/`)

| File | Content |
|---|---|
| `platform_arm_results.csv` | Per-arm rejection rate and mean rate |
| `platform_oc_table.csv` | FWER and 1-minimum power |
| `platform_allocation.csv` | Per-period allocation across arms and control |
| `platform_timeline.pdf` | Gantt chart of arms entering and leaving |
| `platform_oc_curves.pdf` | Per-arm rejection-rate bar chart |

---

## Configuration Reference

See `reference/specs/config-reference.md` for the full `create_master_config()` parameter list.

---

## Framework Modules

Located at `scripts/R/` within the skill directory.

| File | Purpose |
|------|---------|
| `master_config.R` | `create_master_config()` — config builder |
| `shared_utils.R` | Data simulation helpers, posterior probability helpers, FWER + power computation, simulation harness, output helpers |
| `basket_simple.R` | `run_basket_single()` — basket trial with `"none"` or `"complete"` method |
| `umbrella_mams.R` | `umbrella_mams_simulate()`, `run_umbrella_mams()`, `umbrella_mams_boundaries()` |
| `platform_simple.R` | `simulate_platform_simple()`, `run_platform()` — naïve concurrent-control comparison |
| `run_master_framework.R` | `run_master_framework()` — top-level dispatcher and output saver |
| `example_minimal.R` | One worked example per family |

---

## Beyond This Skill

The following methods are **intentionally out of scope** for this public
release. They are standard but require nontrivial calibration, defense, and
in some cases external review; this skill does not implement them so it can
stay easy to install, audit, and reason about.

| Method | Use case | References |
|---|---|---|
| **Simon's Bayesian basket** | Adaptive borrowing across two-or-more subgroups based on observed concordance | Simon et al. 2016 (Stat Methods Med Res) |
| **Chen et al. confirmatory basket** | Phase III basket with prespecified borrowing strategy | Chen et al. 2016 (Pharmaceutical Stats) |
| **Calibrated BHM (CBHM)** | Calibrated hierarchical borrowing tuned to control FWER | Chu & Yuan 2018 (J Biopharm Stat) |
| **Full BHM with Gibbs sampling** | Bayesian hierarchical model with full posterior over τ | Berry et al. 2013 (Clin Trials) |
| **Wathen S-TI / SEP** | Single-trial borrowing with different shrinkage profiles | Wathen et al. 2021 |
| **Drop-the-losers (DTL) umbrella** | Stage-wise rank-based arm selection | Sampson & Sill 2005 |
| **Bayesian adaptive randomization (BAR)** | Allocation skewed toward better-performing arms | Trippa et al. 2012; Lee, Chen & Yin 2012 |
| **Non-concurrent control adjustment** | Platform analysis adjusted for time trends via regression or time-machine | Saville et al. 2022; Lee & Wason 2020 |
| **Response-adaptive randomization (RAR) on platforms** | Thompson-sampling allocation across active platform arms | Thompson 1933; Berry et al. 2010 |
| **TTE and incidence-rate endpoints in master protocols** | Survival or event-rate endpoints in basket/umbrella/platform | Schoenfeld 1983; Signorini 1991 |
| **HTA and reimbursement strategy for master protocols** | Evidence packaging across regulators and payers | Bujkiewicz et al. 2023 |
| **External review checkpoint for master designs** | Independent statistical review before protocol lock | Internal expert workflow (not codified here) |

If you need any of the above, treat this skill's output as a baseline against
which to compare a more advanced method.

---

## Error Handling

**R not installed:**
- Check: `Rscript --version`
- Framework uses base R only by default. The optional `MAMS` package improves
  umbrella boundary computation; the skill falls back to an approximation if
  not installed.

**Endpoint not supported:**
- Public-scope basket and platform support **binary only**. Public-scope
  umbrella supports **binary or continuous**. Other endpoints raise a clear
  error directing the user to "Beyond This Skill".

**Borrowing method outside `{none, complete}`:**
- Public scope rejects other methods with an error directing the user to
  "Beyond This Skill".

**Output directory not writable:**
- Default to `runs/[timestamp]/`. Fall back to `/tmp/master_[timestamp]/`.
