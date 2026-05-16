# `create_config()` Parameter Reference

Full parameter documentation for the sample size config builder.

## Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `endpoint_type` | string | `"binary"`, `"continuous"`, or `"tte"` |
| `design` | string | `"single_arm"` or `"controlled"` (controlled = 1:1 only) |
| `null_param` | numeric | H0 value (rate, mean, or hazard) |
| `alt_param` | numeric | H1 value (rate, mean, or hazard) |

## Conditionally Required

| Parameter | Required for | Description |
|-----------|--------------|-------------|
| `sd` | continuous | Standard deviation of the endpoint |
| `accrual_time` | tte | Accrual period duration (any consistent time unit) |
| `followup_time` | tte | Follow-up time after last enrollment |

## Optional Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `alphas` | `c(0.025, 0.05)` | Vector of one-sided alpha levels |
| `powers` | `c(0.80, 0.90)` | Vector of power targets |
| `label` | `"Endpoint"` | Display label for plots and tables |

## Alpha Convention

All alpha values are **one-sided**:
- 0.025 one-sided ≈ 0.05 two-sided (confirmatory standard)
- 0.05 one-sided (PoC)
- 0.10 one-sided (exploratory signal detection)

All `power.t.test` calls use `sig.level = alpha, alternative = "one.sided"`.

## Endpoint-Specific Parameters

### Binary

| Parameter | Type | Description |
|-----------|------|-------------|
| `null_param` | numeric in [0, 1] | H0 response rate |
| `alt_param` | numeric in [0, 1] | H1 response rate (must be > `null_param`) |

### Continuous

| Parameter | Type | Description |
|-----------|------|-------------|
| `null_param` | numeric | H0 mean (or mean change) |
| `alt_param` | numeric | H1 mean (must be > `null_param`) |
| `sd` | numeric (>0) | Standard deviation of the endpoint |

### Time-to-Event

| Parameter | Type | Description |
|-----------|------|-------------|
| `null_param` | numeric (>0) | H0 hazard rate (events per person-time unit) |
| `alt_param` | numeric (>0) | H1 hazard rate (must be < `null_param`; lower hazard = better treatment) |
| `accrual_time` | numeric (>0) | Accrual period duration |
| `followup_time` | numeric (>0) | Follow-up after last enrollment |

Derived quantities: `median_survival = log(2) / hazard_rate`, `HR = alt_param / null_param`.

## Sample Size Functions Reference

### Binary

| Function | Description | Design |
|----------|-------------|--------|
| `ss_binomial_single_arm(p0, p1, alpha, power)` | Required N for exact binomial | Single-arm |
| `power_binomial_single_arm(n, p0, p1, alpha)` | Power at fixed N | Single-arm |
| `ss_z_unpooled(p0, p1, alpha, power)` | Required N per arm for Z-test unpooled | Controlled 1:1 |
| `power_z_unpooled(n_per_arm, p0, p1, alpha)` | Power at fixed N | Controlled 1:1 |

### Continuous

| Function | Description | Design |
|----------|-------------|--------|
| `ss_ttest_single_arm(delta, sd, alpha, power)` | Required N for one-sample t | Single-arm |
| `power_ttest_single_arm(n, delta, sd, alpha)` | Power at fixed N | Single-arm |
| `ss_ttest_two_arm(delta, sd, alpha, power)` | Required N per arm for two-sample t | Controlled 1:1 |
| `power_ttest_two_arm(n_per_arm, delta, sd, alpha)` | Power at fixed N | Controlled 1:1 |

### Time-to-Event

| Function | Description | Design |
|----------|-------------|--------|
| `ss_logrank_single_arm(lambda0, lambda1, accrual_time, followup_time, alpha, power)` | Exponential rate test, events required | Single-arm |
| `power_logrank_single_arm(n, lambda0, lambda1, accrual_time, followup_time, alpha)` | Power at fixed N | Single-arm |
| `ss_logrank_two_arm(lambda0, lambda1, accrual_time, followup_time, alpha, power)` | Schoenfeld log-rank | Controlled 1:1 |
| `power_logrank_two_arm(n_per_arm, lambda0, lambda1, accrual_time, followup_time, alpha)` | Power at fixed N | Controlled 1:1 |

## Sample Size Method References

| Method family | Functions | Reference |
|---------------|-----------|-----------|
| Exact single-arm binomial | `ss_binomial_single_arm()` | A'Hern (2001) |
| Two-arm binary normal approximation | `ss_z_unpooled()` | Casagrande, Pike & Smith (1978) |
| One-sample t-test | `ss_ttest_single_arm()` | Student (1908) |
| Two-sample t-test | `ss_ttest_two_arm()` | Student (1908) |
| Single-arm TTE / one-sample log-rank | `ss_logrank_single_arm()` | Wu (2015) |
| Two-arm log-rank / proportional hazards | `ss_logrank_two_arm()` | Schoenfeld (1983), Freedman (1982) |

## Example Configs

Binary controlled (1:1):

```r
cfg <- create_config(
  endpoint_type = "binary",
  design        = "controlled",
  null_param    = 0.30,
  alt_param     = 0.50,
  alphas        = c(0.025, 0.05),
  powers        = c(0.80, 0.90),
  label         = "Phase 2 binary"
)
```

Continuous single-arm:

```r
cfg <- create_config(
  endpoint_type = "continuous",
  design        = "single_arm",
  null_param    = 0,
  alt_param     = 0.5,
  sd            = 1.5,
  label         = "Continuous mean change"
)
```

Time-to-event controlled (1:1):

```r
cfg <- create_config(
  endpoint_type = "tte",
  design        = "controlled",
  null_param    = 0.10,
  alt_param     = 0.05,
  accrual_time  = 12,
  followup_time = 12,
  label         = "OS HR 0.5"
)
```

## References

- A'Hern, R. P. (2001). Sample size tables for exact single-stage phase II designs. *Statistics in Medicine*, 20(6), 859-866.
- Casagrande, J. T., Pike, M. C. & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. *Biometrics*, 34(3), 483-486.
- Freedman, L. S. (1982). Tables of the number of patients required in clinical trials using the logrank test. *Statistics in Medicine*, 1(2), 121-129.
- Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. *Biometrics*, 39(2), 499-503.
- Student. (1908). The probable error of a mean. *Biometrika*, 6(1), 1-25.
- Wu, J. (2015). Sample size calculation for the one-sample log-rank test. *Pharmaceutical Statistics*, 14(1), 26-33.
