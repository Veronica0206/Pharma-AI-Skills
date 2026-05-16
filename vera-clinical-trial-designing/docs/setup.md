# Setup

## Requirements

- **R**: version 4.0 or later (base R only)
- **macOS / Linux / Windows**: any platform with R installed

## R Packages

The framework uses **base R only**. No external packages required.

## Verify R Installation

```bash
which Rscript
Rscript --version
```

Expected: R 4.0+ available on PATH (or in `/usr/local/bin/Rscript` on macOS).

## First Run (Smoke Test)

```bash
cd <skill_root>/scripts/R
Rscript -e '
source("config.R")
source("sample_size.R")
cfg <- create_config(endpoint_type="binary", design="single_arm",
                     null_param=0.20, alt_param=0.50)
ss <- ss_binomial_single_arm(0.20, 0.50, alpha=0.025, power=0.80)
cat("Smoke test PASSED. N =", ss$n, "\n")
'
```

Expected output: `Smoke test PASSED. N = 19` (or similar).

## Worked Examples

To run the bundled three-example walkthrough (binary, continuous, TTE):

```bash
cd <skill_root>/scripts/R
Rscript example_minimal.R
```

Outputs land in `outputs/binary/`, `outputs/continuous/`, `outputs/tte/`.

## Framework Directory Resolution

The skill resolves the R framework directory in this order:
1. **Skill-bundled scripts** (preferred): `scripts/R/` within this skill directory — always available
2. **Ask the user**: if the bundled scripts cannot be located

The skill-bundled scripts are the authoritative source. See `SKILL.md` Step 2 for details.

## Output Directory

By default, outputs go to `runs/[run_id]/` (relative to the framework directory). Override with `output_dir = "/your/path/"` in the `run_sample_size_framework()` call.
