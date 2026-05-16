# Step 03: Run Simulation

## Goal
Execute the R analysis script and monitor for successful completion.

## Inputs
- Validated `analysis.R` from Step 02

## Outputs
- CSV and PDF output files in the specified `output_dir`

## Procedure

### 1. Execute the Script

```bash
cd "$FRAMEWORK_DIR"
Rscript "runs/[run_id]/analysis.R" 2>&1 | tee "runs/[run_id]/run.log"
```

For larger simulations (`n_sims` > 5000), expect longer runtimes. The framework prints progress indicators every 10%.

### 2. Success Indicators

```
=== Master Protocol Design Framework ===
Design type: [basket|umbrella|platform]
...
--- Running simulation (N = [n_sims]) ---
Simulation progress: 10%... 20%... ... 100%
--- Generating outputs ---
Saved: [filename].csv
Saved: [filename].pdf
=== Done ===
```

### 3. Common Runtime Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Script hangs at simulation | Large `n_sims` | Reduce `n_sims` for an initial test (e.g. 1000), then scale up |
| `there is no package called 'MAMS'` | Optional `MAMS` package not installed | Either install (`install.packages("MAMS")`) or accept the built-in approximation (umbrella runs anyway) |
| `Error: Public-scope basket designs support binary endpoints only.` | Tried `endpoint_type` other than `binary` for basket / platform | Use binary, or see SKILL.md § *Beyond This Skill* |
| `Error: Unknown borrowing_method for public release` | Tried a method other than `"none"` or `"complete"` for basket | Same as above |
| PDF device error | No graphics device available | The framework uses `pdf()`, not X11. Check write permissions on `output_dir`. |

### 4. Quick Verification

After the script completes, verify output files exist:

```bash
ls -la [output_dir]/
```

Expected files depend on the design family — see SKILL.md § *Output Structure*.

## Proceed To
→ `workflow/step04-validate-outputs.md`
