# Clinical Indirect Comparison

**An open-source agent skill for Claude Code, Codex, and other file-aware coding
agents. It runs transparent first-pass binary and continuous indirect treatment
comparisons using Bucher's method and MAIC.**

This public release is intentionally conservative. It helps a biostatistician or
clinical scientist structure an anchored indirect comparison, compute estimates
with lightweight R scripts, and document the assumptions that determine whether
the comparison is interpretable.

> **The skill computes the contrast. You own the similarity judgment.**

---

## What This Skill Does

- Runs Bucher's adjusted indirect comparison through a common comparator.
- Supports the alternate Bucher chain orientation where `A vs B` is estimated
  from available `A vs C` and `C vs B` contrasts.
- Converts binary counts and continuous mean/SD/N summaries into direct effects
  for Bucher's method.
- Builds MAIC weights to match source IPD to published target aggregate
  covariate means.
- Reports covariate balance and effective sample size after weighting.
- Computes weighted binary and continuous endpoint effects for MAIC.
- Optionally combines a weighted source effect with a published target effect
  for anchored MAIC.
- Writes CSV outputs and simple PDF diagnostics.

## What This Skill Does Not Do

The following are intentionally out of scope for the public release:

- Rate endpoints
- Time-to-event endpoints
- Full network meta-analysis
- Simulated treatment comparison (STC)
- Unanchored claims without strong caveats
- Multi-trial MAIC
- Bayesian HTA submission models
- Regulatory-grade evidence-synthesis certification

## Quick Start

```bash
cd scripts/R
Rscript validate_core_formulas.R
Rscript example_minimal.R
```

Outputs land in `outputs/bucher/`, `outputs/bucher_chain/`, and
`outputs/maic/`.

For Claude Code or Claude.ai usage, see
`reference/specs/runtime-compatibility.md`. Claude Code can run the bundled R
scripts when `Rscript` is installed; Claude.ai may need the R analysis run in a
local R environment before interpretation.

For a real analysis, start from the templates in `reference/templates/`:

- `bucher_direct_effects_template.csv`
- `bucher_chain_direct_effects_template.csv`
- `endpoint_contrasts_template.csv`
- `maic_ipd_template.csv`
- `maic_targets_template.csv`

Use `reference/specs/evaluation-cases.md` for trigger and regression checks
when improving the skill.

## Related Skills

- `vera-clinical-indication-researching` - use before this skill to define the
  disease landscape, endpoint precedent, and relevant trials.
- `vera-clinical-meta-analyzing` - use before this skill when published arm-level
  results need to be pooled or converted into direct effects.
- `vera-clinical-trial-designing` - use after this skill when an indirect
  estimate informs sample-size or sensitivity planning.

## License

GPL-3.0. See [`LICENSE`](LICENSE).
