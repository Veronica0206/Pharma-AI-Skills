# Step 04: Validate Outputs

## Goal
Verify all expected output files are present, non-empty, and contain valid data.

## Inputs
- Output directory from Step 03

## Output
- Validated artifact list
- Any warnings about missing or empty files

## Procedure

### 4.1 Check Required Files

```bash
ls -lh [output_dir]/
wc -l [output_dir]/sample_size.csv
```

### 4.2 Spot-Check `sample_size.csv`

Read first few lines and verify:
- Columns: `design, test, alpha, power_target, n_total, n_trt, n_ctrl, power_achieved, k_crit, label`
- `n_total` is a positive integer (not `NA` or `NaN`)
- Multiple rows (one per alpha × power × design combination)

Expected `test` values by endpoint type and design:

| Endpoint | Design | Rows present |
|---|---|---|
| binary | single_arm | `single_arm,exact_binomial,...` |
| binary | controlled | `single_arm,exact_binomial,...` AND `controlled,z_unpooled,...` |
| continuous | single_arm | `single_arm,one_sample_t,...` |
| continuous | controlled | `single_arm,one_sample_t,...` AND `controlled,two_sample_t,...` |
| tte | single_arm | `single_arm,exponential_rate,...` |
| tte | controlled | `single_arm,exponential_rate,...` AND `controlled,logrank,...` |

For TTE rows, also verify `k_crit` contains the required event count (Schoenfeld d).

For controlled designs, `n_total = n_trt + n_ctrl` should hold (with at most a difference of 1 due to ceiling).

### 4.3 Verify `power_curve.pdf`

- File should be > 1 KB (non-empty plot)
- Power curves should show monotonically increasing trends with N
- One line per alpha in `config$alphas`
- Horizontal reference lines at each `config$powers` target

## Validation Checkpoints

- [ ] `sample_size.csv` exists, non-empty, no `NA` in `n_total`
- [ ] `power_curve.pdf` exists and is non-trivial (> 1 KB)
- [ ] No `NaN` or `Inf` values in `sample_size.csv`
- [ ] `test` column shows only the expected values for the chosen endpoint
- [ ] If TTE: upstream config included `accrual_time` and `followup_time`
- [ ] If continuous: upstream config included `sd`

## Next Step
→ `workflow/step05-deliver-results.md`
