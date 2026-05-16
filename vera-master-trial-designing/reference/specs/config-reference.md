# Configuration Reference: `create_master_config()`

## Required Parameters (all design types)

| Parameter | Type | Values | Description |
|-----------|------|--------|-------------|
| `master_design_type` | character | `"basket"`, `"umbrella"`, `"platform"` | Master protocol family |
| `endpoint_type` | character | `"binary"`, `"continuous"` | Primary endpoint type. Public scope: basket and platform are **binary only**; umbrella supports binary or continuous. |
| `n_subgroups` | integer | >= 2 | Number of subgroups (basket) or treatment arms (umbrella / platform) |
| `null_params` | numeric (length 1 or `n_subgroups`) | endpoint-appropriate | H0 value(s) per subgroup/arm |
| `alt_params` | numeric (length `n_subgroups`) | endpoint-appropriate | H1 value(s) per subgroup/arm |

## Common Optional Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `alpha` | `0.025` | One-sided significance level |
| `n_sims` | `5000` | Number of Monte Carlo simulation replicates |
| `seed` | `42` | Random seed |
| `output_dir` | `"results/"` | Directory for CSV + PDF output |
| `label` | auto-generated | Display label |

## Basket-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `borrowing_method` | character | `"none"` | `"none"` (independent per subgroup) or `"complete"` (pooled across subgroups). Other methods raise an error directing to SKILL.md § *Beyond This Skill*. |
| `n_per_subgroup` | integer | 25 | Sample size per subgroup |
| `go_threshold` | numeric in (0, 1) | 0.90 | Posterior probability threshold for Go decision |

## Umbrella-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `umbrella_method` | character | `"mams"` | Public scope: MAMS only |
| `n_arms` | integer | `n_subgroups` | Number of experimental arms (excludes control) |
| `n_stages` | integer | 2 | Number of stages (interim + final) |
| `n_per_arm_stage` | integer | auto (20) | Patients per arm per stage |
| `sd` | numeric (>0) | required for continuous | Standard deviation of endpoint |
| `futility_boundaries` | numeric vector | NULL (calculated) | Override stage-wise futility boundaries |

## Platform-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `n_periods` | integer (>=2) | required | Number of enrollment periods |
| `n_per_period` | integer (>0) | required | Patients enrolled per period (split across active arms + control) |
| `arms_schedule` | list | required | `list(enter = c(...), leave = c(...))` — 1-indexed period when each arm enters and leaves |

## Example Configurations

### Basket — no borrowing baseline (binary, Phase II)
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
  output_dir         = "results_basket/"
)
```

### Umbrella — MAMS (continuous)
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
  output_dir         = "results_umbrella/"
)
```

### Platform — concurrent-control (binary)
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
  output_dir         = "results_platform/"
)
```

## See Also

- `docs/decision-roadmap.md` — choosing between basket / umbrella / platform
- `SKILL.md` § *Beyond This Skill* — references for methods not implemented in the public release
