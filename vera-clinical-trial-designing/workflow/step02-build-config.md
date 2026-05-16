# Step 02: Build R Config and Analysis Script

## Goal
Generate a ready-to-run R analysis script using the user's parameters.

## Inputs
- Validated parameters from Step 01

## Output
- `runs/[run_id]/analysis.R` — executable R script

## Procedure

### 2.1 Determine Framework Directory

Resolve the framework directory in this order:
1. **Skill-bundled scripts** (preferred): find this skill's `scripts/R/` directory. It contains
   the core modules (`config.R`, `sample_size.R`, `run_framework.R`).
2. **Ask the user**: if the bundled scripts cannot be located, stop and ask for the path.

Verify the resolved directory contains `config.R`, `sample_size.R`, and `run_framework.R`
before proceeding. Store the path as `FRAMEWORK_DIR` for use in subsequent steps.

### 2.2 Generate analysis.R

Template:

```r
# Source framework modules from FRAMEWORK_DIR (resolved in Step 2.1).
# Avoid setwd() — it breaks parallel / Rmd execution.
source(file.path(FRAMEWORK_DIR, "config.R"))
source(file.path(FRAMEWORK_DIR, "sample_size.R"))
source(file.path(FRAMEWORK_DIR, "run_framework.R"))

# Build config
cfg <- create_config(
  endpoint_type = "[binary|continuous|tte]",
  design        = "[single_arm|controlled]",
  null_param    = [H0_VALUE],
  alt_param     = [H1_VALUE],
  sd            = [SD_OR_NULL],          # continuous only
  accrual_time  = [ACCRUAL_OR_NULL],     # tte only
  followup_time = [FOLLOWUP_OR_NULL],    # tte only
  alphas        = c(0.025, 0.05),
  powers        = c(0.80, 0.90),
  label         = "[Endpoint Label]"
)

# Run framework
results <- run_sample_size_framework(
  config     = cfg,
  output_dir = "[OUTPUT_DIR]"
)
```

### 2.3 Set Output Directory

Default: `[FRAMEWORK_DIR]/runs/[YYYYMMDD_HHMMSS]/`. Create the directory before running.

## Validation Checkpoints

- [ ] Script is syntactically valid R (parse with `Rscript -e 'parse("analysis.R")'`)
- [ ] `output_dir` is set and creatable
- [ ] All three sourced files exist at the resolved paths
- [ ] Alpha values are one-sided (do NOT double them)

## Next Step
→ `workflow/step03-run-framework.md`
