# Step 02: Build Master Config

## Goal
Construct the R analysis script with a valid `create_master_config()` call and all required module sources.

## Inputs
- Design type, method, and parameters from Step 01

## Outputs
- `analysis.R` script ready for execution

## Procedure

### 1. Source the Framework Modules

```r
# FRAMEWORK_DIR resolves to this skill's scripts/R/ directory.
source(file.path(FRAMEWORK_DIR, "shared_utils.R"))
source(file.path(FRAMEWORK_DIR, "master_config.R"))
source(file.path(FRAMEWORK_DIR, "basket_simple.R"))
source(file.path(FRAMEWORK_DIR, "umbrella_mams.R"))
source(file.path(FRAMEWORK_DIR, "platform_simple.R"))
source(file.path(FRAMEWORK_DIR, "run_master_framework.R"))
```

(All five method files can be sourced regardless of the chosen family — they
do not collide.)

### 2. Build the Configuration

Use `create_master_config()` with validated parameters. See
`reference/specs/config-reference.md` for the full parameter list.

**Basket (no borrowing baseline, binary):**

```r
cfg <- create_master_config(
  master_design_type = "basket",
  endpoint_type      = "binary",
  n_subgroups        = 4,
  null_params        = 0.20,
  alt_params         = c(0.45, 0.45, 0.20, 0.20),
  n_per_subgroup     = 25,
  borrowing_method   = "none",
  go_threshold       = 0.90,
  alpha              = 0.10,
  n_sims             = 2000,
  output_dir         = "results/"
)
```

**Umbrella (MAMS, continuous):**

```r
cfg <- create_master_config(
  master_design_type = "umbrella",
  endpoint_type      = "continuous",
  n_subgroups        = 3,
  null_params        = 0,
  alt_params         = c(7, 7, 0),
  sd                 = 7,
  umbrella_method    = "mams",
  n_stages           = 2,
  n_per_arm_stage    = 30,
  alpha              = 0.025,
  n_sims             = 2000,
  output_dir         = "results/"
)
```

**Platform (concurrent control, binary):**

```r
cfg <- create_master_config(
  master_design_type = "platform",
  endpoint_type      = "binary",
  n_subgroups        = 3,
  null_params        = 0.30,
  alt_params         = c(0.55, 0.30, 0.55),
  arms_schedule      = list(enter = c(1, 1, 3), leave = c(4, 4, 6)),
  n_periods          = 6,
  n_per_period       = 60,
  alpha              = 0.025,
  n_sims             = 2000,
  output_dir         = "results/"
)
```

### 3. Run the Framework

```r
run_master_framework(cfg)
```

### 4. Validation Checkpoint

Before executing, verify:

- [ ] `analysis.R` is syntactically valid R (`Rscript -e 'parse("analysis.R")'`)
- [ ] `output_dir` path is set and writable
- [ ] All `source()` paths point to existing framework files
- [ ] Parameter values match Step 01 decisions
- [ ] Request does not require any "Beyond This Skill" feature

## Proceed To
→ `workflow/step03-run-simulation.md`
