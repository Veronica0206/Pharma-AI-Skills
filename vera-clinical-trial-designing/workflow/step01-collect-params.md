# Step 01: Collect and Validate Parameters

## Goal
Gather all parameters needed to construct a `create_config()` call before generating the analysis script.

## Inputs
- User request (may be as terse as "size a Phase 2 trial with a binary response endpoint")

## Outputs
- A validated parameter set ready for Step 02 (build config)

## Procedure

### 1.1 Required Parameters

| Parameter | Question | Notes |
|-----------|----------|-------|
| `endpoint_type` | Binary, continuous, or TTE? | Drives all downstream methodology |
| `null_param` | H0 value (rate, mean, or hazard) | Single number |
| `alt_param` | H1 value (target treatment effect) | Direction: binary `>` null; continuous `>` null; TTE `<` null (lower hazard = better) |
| `design` | `single_arm` or `controlled` (1:1)? | Public scope is 1:1 only |

### 1.2 Endpoint-Specific Required Parameters

| Endpoint | Required |
|----------|----------|
| `binary` | (none beyond the above) |
| `continuous` | `sd` (standard deviation of the endpoint) |
| `tte` | `accrual_time`, `followup_time` (in same time units as hazard rate) |

### 1.3 Optional Parameters (defaults apply if omitted)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `alphas` | `c(0.025, 0.05)` | Vector of one-sided alpha levels |
| `powers` | `c(0.80, 0.90)` | Vector of power targets |
| `label` | `"Endpoint"` | Display label for the table and plot |

### 1.4 Out of Scope

If the user asks for any of the following, redirect them to `SKILL.md` § *Beyond This Skill*:

- Bayesian Go/No-Go decision frameworks (signal_detection / poc with Go / Consider thresholds)
- Pre-trial assurance / PPOS (confirmatory with Phase 2 data)
- 2:1 (or other unequal) randomization
- Poisson incidence-rate sizing
- Unconditional exact (Barnard-type) tests
- Frequentist post-trial decision analysis

### 1.5 Confirmation

Before proceeding to Step 02, confirm in one line:

> **Confirmed:** [endpoint], H0=[null], H1=[alt], [design], alphas=[...], powers=[...]. Proceeding to build config.

## Validation Checkpoints

- [ ] `endpoint_type` is one of `binary`, `continuous`, `tte`
- [ ] `null_param` and `alt_param` satisfy the directionality constraint
- [ ] Endpoint-specific required parameters are set (`sd` for continuous; `accrual_time` + `followup_time` for tte)
- [ ] Request does not require any "Beyond This Skill" feature

## Proceed To
→ `workflow/step02-build-config.md`
