---
name: vera-clinical-meta-analyzing
description: >-
  Performs public clinical meta-analysis for drug-development benchmarks by
  extracting binary x/N, continuous mean/SD/N, time-to-event HR/CI, and
  incidence-rate events/person-time data; harmonizing endpoint definitions and
  timing; pooling benchmarks with base R helpers; summarizing comparative
  effects; creating simple forest plots; and translating pooled estimates into
  trial-design assumptions. Activates for clinical meta-analysis, pooled rate,
  literature benchmark, historical control, forest plot, endpoint harmonization,
  or benchmark-for-power requests.
---

# Clinical Meta-Analysis Skill

This skill turns clinical endpoint data into defensible benchmark estimates
for trial planning. It is deliberately narrower than a full systematic-review
tool: the public release focuses on transparent endpoint extraction, endpoint
harmonization, base R pooling helpers, simple plots, and a clean handoff to
`vera-clinical-trial-designing`.

## Table of Contents

- [Host Runtime Notes](#host-runtime-notes)
- [Public Scope](#public-scope)
- [Endpoint Families](#endpoint-families)
- [Workflow](#workflow)
- [Data Contract](#data-contract)
- [Running the Base R Framework](#running-the-base-r-framework)
- [Output Interpretation](#output-interpretation)
- [Resources](#resources)

## Host Runtime Notes

- Works in Claude Code, Codex, and other file-aware coding agents.
- Requires R >= 4.0 and base R only.
- Use current web browsing/search tools when gathering literature, labels,
  registries, and regulatory sources. Prefer primary sources.
- Use the host's normal file-reading, shell, and editing tools. In Codex, use
  shell/Rscript plus `rg` and `apply_patch`; in Claude Code, use the equivalent
  file, search, shell, and edit tools.

## Public Scope

Use this skill for:

- Extracting study-level binary x/N, continuous mean/SD/N, time-to-event
  HR/CI, and incidence-rate events/person-time data from papers, labels,
  clinical trial registries, or regulatory reviews.
- Auditing whether endpoint definition, timing, population, and arm type are
  comparable enough to pool.
- Pooling single-arm rates for placebo, standard of care, active control, or
  investigational arms using logit inverse-variance random effects.
- Summarizing paired treatment-control effects when both rows exist for a study.
- Creating base R forest plots and CSV outputs.
- Translating pooled estimates into design-ready H0/control/target assumptions.

## Endpoint Families

Supported endpoint families are:

| Family | Source data | Measures |
|--------|-------------|----------|
| `binary` | responders and total | pooled proportions, risk difference, risk ratio, odds ratio |
| `continuous` | mean, SD, N | pooled means, mean difference, standardized mean difference |
| `time_to_event` | HR with CI/SE or log HR with SE | hazard ratio |
| `incidence_rate` | events and person-time | pooled rates, rate ratio |

See `reference/specs/endpoint-families.md` for extraction rules and trial-design handoff mapping. The bundled end-to-end example remains intentionally small and demonstrates binary x/N pooling; `scripts/R/meta_endpoint_core.R` provides the endpoint-family transformations and inverse-variance pooling helpers for broader public examples.

Do not use this public version for network meta-analysis, Bayesian
meta-analysis, publication-bias modeling, automated PDF extraction, GRADE/Cochrane
judgment, or regulatory-grade systematic-review claims.

## Workflow

Read each workflow file before executing that step.

| Step | Responsibility | Executor | Document | Input | Output |
|------|----------------|----------|----------|-------|--------|
| 01 | Define scope | Main Agent | `workflow/step01-define-scope.md` | User request | Analysis scope |
| 02 | Extract counts | Main Agent | `workflow/step02-extract-data.md` | Sources | Endpoint count CSV |
| 03 | Run analysis | Script | `workflow/step03-run-analysis.md` | Count CSV | CSV + PDF outputs |
| 04 | Validate outputs | Main Agent | `workflow/step04-validate-outputs.md` | Outputs | Validation notes |
| 05 | Translate benchmarks | Main Agent | `workflow/step05-translate-benchmarks.md` | Validated outputs | Design assumptions |

## Data Contract

For the public binary x/N end-to-end framework, use
`reference/templates/endpoint_counts_template.csv` as the starting shape.
Required columns:

- `study_id`
- `study`
- `year`
- `population`
- `endpoint`
- `endpoint_definition`
- `timing`
- `arm`
- `arm_type`
- `responders`
- `total`
- `count_status`
- `source`

Keep exact x/N counts. Reconstruct from percentages only when the denominator is
explicit, and mark `count_status` as `reconstructed`. For continuous,
time-to-event, and incidence-rate endpoints, follow
`reference/specs/endpoint-families.md`.

## Running the Base R Framework

From the skill root:

```bash
cd scripts/R
Rscript example_minimal.R
```

For a real extraction:

```r
source("scripts/R/meta_analysis.R")
run_meta_analysis(
  input_csv = "endpoint_counts.csv",
  output_dir = "outputs/meta_analysis",
  endpoint_filter = "response",
  timing_filter = "week 8"
)
```

The framework writes:

- `cleaned_counts.csv`
- `definition_audit.csv`
- `pooled_arm_rates.csv`
- `paired_effects.csv` when paired treatment-control rows exist
- `design_benchmarks.csv`
- `forest_rates.pdf`
- `forest_effects.pdf` when paired effects exist

## Interpretation Rules

- Do not pool endpoint names alone. Pool only when definition, timing, population,
  and arm context are sufficiently comparable.
- Report heterogeneity (`Q`, `I2`, `tau2`) with every pooled estimate.
- Separate placebo/control, active-control, and treatment-target estimates.
- State all limitations: reconstructed counts, mixed definitions, sparse studies,
  study-era changes, shared controls, and population drift.
- Pass conservative benchmark ranges to trial design rather than a single number
  when heterogeneity is material.

## Handoff To Trial Design

Map outputs into `vera-clinical-trial-designing` as:

- placebo/control pooled rate -> contextual placebo or single-arm `null_param`
- active-control pooled rate -> expected control arm rate
- treatment pooled rate or target range -> `alt_param`
- pooled treatment-control effect -> clinically meaningful delta
- sensitivity range -> scenario grid for power/sample-size checks


## Resources

- `scripts/R/meta_analysis.R`: public binary x/N end-to-end pooling framework.
- `scripts/R/meta_endpoint_core.R`: base-R helpers for binary, continuous, time-to-event, and incidence-rate endpoint transformations and inverse-variance pooling.
- `scripts/R/validate_endpoint_families.R`: deterministic smoke test covering all supported endpoint families.
- `reference/specs/endpoint-families.md`: required columns, measures, and trial-design handoff rules.
- `reference/templates/meta-analysis-r-skeleton.R`: starter script for project-specific extraction tables.

## Quality Checks

Run `Rscript scripts/R/validate_endpoint_families.R` after changing endpoint logic, and `Rscript scripts/R/example_minimal.R` after changing the public x/N framework.
