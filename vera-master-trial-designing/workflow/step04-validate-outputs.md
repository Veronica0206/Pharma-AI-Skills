# Step 04: Validate Outputs

## Goal
Verify that all output files are complete, well-formed, and contain plausible results.

## Inputs
- CSV and PDF files from Step 03

## Outputs
- Validated artifacts ready for interpretation

## Procedure

### 1. Check File Existence

Verify all expected files exist for the chosen design family. See SKILL.md § *Output Structure*.

### 2. CSV Validation

For each CSV, verify it is non-empty and key columns are well-formed:

```r
df <- read.csv("[file].csv")
stopifnot(nrow(df) > 0)
# Then check key columns for any NA / NaN / Inf:
for (col in [key_cols]) {
  stopifnot(!any(is.na(df[[col]]) | is.nan(df[[col]]) | is.infinite(df[[col]])))
}
```

**Key columns by design family:**

| Family | File | Key columns |
|---|---|---|
| Basket | `basket_oc_table.csv` | `subgroup`, `reject_rate`, `mean_estimate` |
| Basket | `basket_fwer.csv` | `scenario`, `fwer` |
| Umbrella | `umbrella_power_table.csv` | `arm`, `per_arm_power` |
| Umbrella | `umbrella_oc_summary.csv` | `metric`, `value` |
| Umbrella | `umbrella_boundaries.csv` | `stage`, `futility_boundary` |
| Platform | `platform_arm_results.csv` | `arm`, `reject_rate`, `mean_rate` |
| Platform | `platform_oc_table.csv` | `metric`, `value` |

### 3. Design-Specific Plausibility Checks

#### Basket

- `basket_oc_table.csv`: per-subgroup `reject_rate` near `alpha * 100` for null subgroups; high for active subgroups.
- `basket_fwer.csv`: FWER under global null should be at or below `alpha * 100` for `borrowing_method = "none"` (no multiplicity adjustment in this skill — FWER may exceed alpha when multiple null subgroups exist).

#### Umbrella

- `umbrella_power_table.csv`: per-arm power high for active arms, low for null arms.
- `umbrella_oc_summary.csv`: 1-minimum power ≥ complete power ≥ complete-correct power (by definition).
- `umbrella_sample_size.csv`: umbrella expected N should be ≤ traditional separate-trial N.
- `umbrella_boundaries.csv`: futility boundaries should be monotonically non-decreasing across stages.

#### Platform

- `platform_arm_results.csv`: `reject_rate` high for `truly_active = TRUE` arms and near `alpha * 100` for null arms.
- `platform_oc_table.csv`: FWER should not exceed `alpha * 100` plus the simulation margin.

### 4. PDF Validation

Each PDF should be > 1 KB:

```bash
for f in [output_dir]/*.pdf; do
  size=$(stat -f%z "$f" 2>/dev/null || stat --printf="%s" "$f" 2>/dev/null)
  echo "$f: $size bytes"
done
```

Empty or near-zero PDFs indicate a graphics device failure.

### 5. Plausibility Bounds

| Check | Expected range |
|-------|---------------|
| Type I error (per-comparison) | `alpha ± 2*sqrt(alpha*(1-alpha)/n_sims)` |
| FWER under global null | ≤ `alpha * K` (Bonferroni-loose bound) for `none` basket; near `alpha` for MAMS |
| Power under alternative | 50–99% (depends on effect size and N) |
| Sample size savings (umbrella vs traditional) | 10–40% typically |

## Proceed To
→ `workflow/step05-interpret-results.md`
