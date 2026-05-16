# Step 03: Run R Framework

## Goal
Execute the generated `analysis.R` and capture all outputs.

## Inputs
- `runs/[run_id]/analysis.R`
- R framework files at `FRAMEWORK_DIR` (resolved in Step 02, § 2.1)

## Output
- CSV table and PDF plot in `output_dir`
- Console log for error diagnosis

## Procedure

### 3.1 Execute the Script

```bash
cd "$FRAMEWORK_DIR"
Rscript "runs/[run_id]/analysis.R" 2>&1 | tee "runs/[run_id]/run.log"
```

### 3.2 Success Signals

- `=== Sample Size Framework ===`
- `--- Sample Size Calculations ---`
- `Saved: sample_size.csv`
- `Saved: power_curve.pdf`
- `=== Done ===`

### 3.3 Common Errors and Fixes

| Error | Fix |
|-------|-----|
| `could not find function "create_config"` | `source()` paths wrong; verify `FRAMEWORK_DIR` |
| `Error: alt_param > null_param is not TRUE` | Direction wrong for binary/continuous. Confirm H1 > H0. |
| `Error: alt_param < null_param is not TRUE` | TTE convention violated. Confirm H1 hazard < H0 hazard. |
| `Error: sd is required for continuous endpoints` | Add `sd = ...` to `create_config()`. |
| `Error: accrual_time is required for tte endpoints` | Add `accrual_time` and `followup_time`. |
| `cannot open PDF device` | `output_dir` not writable; change to `/tmp/` or another directory. |

### 3.4 Verify Outputs

`output_dir` should contain:

- `sample_size.csv` (always)
- `power_curve.pdf` (always)

## Validation Checkpoints

- [ ] Exit code 0 (success)
- [ ] `sample_size.csv` exists and is non-empty
- [ ] `power_curve.pdf` exists
- [ ] No `ERROR` lines in `run.log`

## Next Step
→ `workflow/step04-validate-outputs.md`
