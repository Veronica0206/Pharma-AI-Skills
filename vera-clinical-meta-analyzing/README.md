# Clinical Meta-Analysis - Public Release

**An open-source agent skill for Claude Code, Codex, and other file-aware coding agents. It converts clinical endpoint data into design-ready literature benchmarks.**

This public release is intentionally conservative. It helps a biostatistician or
clinical scientist extract transparent study-level counts, harmonize endpoint
definitions, pool comparable rates with base R, and hand the resulting
benchmarks to trial-design workflows.

> **The skill structures execution. You own the judgment.**

---

## What This Skill Does

- Captures binary `responders / total`, continuous `mean / SD / N`, time-to-event `HR / CI`, and incidence-rate `events / person-time` endpoint data.
- Audits endpoint definition, timing, population, arm type, and count status.
- Pools single-arm placebo/control/treatment rates using a base R logit
  random-effects method and bundles inverse-variance helpers for continuous,
  time-to-event, and incidence-rate endpoints.
- Computes paired risk difference and risk ratio summaries when treatment and
  control rows are available within the same study.
- Writes CSV outputs and simple PDF forest plots.
- Translates pooled rates into H0/control/target assumptions for
  `vera-clinical-trial-designing`.

## What This Skill Does Not Do

The following are intentionally out of scope for the public release:

- Network meta-analysis
- Bayesian meta-analysis
- Publication-bias/funnel-plot modeling
- Automated PDF table extraction
- Cochrane/GRADE risk-of-bias adjudication
- Regulatory-grade systematic-review certification

## Installation

Clone into either a Claude Code or Codex skills directory:

```bash
git clone https://github.com/Veronica0206/Pharma-AI-Skills.git
rsync -a Pharma-AI-Skills/vera-clinical-meta-analyzing/ ~/.claude/skills/vera-clinical-meta-analyzing/
rsync -a Pharma-AI-Skills/vera-clinical-meta-analyzing/ ~/.codex/skills/vera-clinical-meta-analyzing/
```

Or invoke from a checked-out repository in any compatible agent environment.

**Requirements:**

- R >= 4.0
- Base R only; optional packages are not required
- Web search/browsing when gathering current clinical literature

## Quick Start

```bash
cd scripts/R
Rscript example_minimal.R
Rscript validate_endpoint_families.R
```

Outputs land in a generated example output directory that is ignored by git.

For a real analysis, start from
`reference/templates/endpoint_counts_template.csv`, fill one row per study arm,
then run:

```r
source("scripts/R/meta_analysis.R")
run_meta_analysis("endpoint_counts.csv", output_dir = "outputs/meta_analysis")
```

## Related Skills

- `vera-clinical-indication-researching` - use before this skill to define the
  disease landscape, endpoint precedent, and relevant compounds.
- `vera-clinical-indirect-comparing` - use after this skill when published
  evidence supports a Bucher or MAIC indirect treatment comparison.
- `vera-clinical-trial-designing` - use after this skill for sample-size,
  power, and Go/No-Go planning.
- `vera-master-trial-designing` - use when the benchmark informs a basket,
  umbrella, or platform trial concept.

## License

GPL-3.0. See [`LICENSE`](LICENSE).
