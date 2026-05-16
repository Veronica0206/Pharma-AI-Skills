# Step 05: Deliver Results to User

## Goal
Present the framework outputs to the user in a digestible, actionable format.

## Inputs
- Validated CSV and PDF from Step 04
- Original user parameters from Step 01

## Outputs
- Console summary (formatted table)
- File path listing for the user
- Interpretation guidance and next-step recommendations

## Procedure

### 1. Show the Sample Size Table

Read `sample_size.csv` and present as a formatted table, e.g.:

```
Design        Test                 Alpha   Power   N_total   N_trt   N_ctrl
single_arm    exact_binomial       0.025   0.80    19        19      —
controlled    z_unpooled           0.025   0.80    78        39      39
controlled    z_unpooled           0.025   0.90    104       52      52
controlled    z_unpooled           0.050   0.80    62        31      31
controlled    z_unpooled           0.050   0.90    84        42      42
```

Highlight the row matching the user's chosen design and the alpha/power they consider primary.

### 2. List Output Files

```
[output_dir]/
  sample_size.csv
  power_curve.pdf
```

Use the absolute output directory path so the user can open the files directly.

### 3. Provide Interpretation

For each highlighted row in the table, give one sentence, e.g.:

> At alpha = 0.025, power = 0.80, you need **N = 78 total (39 per arm)**. The corresponding power curve in `power_curve.pdf` shows that increasing alpha to 0.05 drops the requirement to N = 62, while increasing power to 0.90 raises it to N = 104.

For TTE designs, also report the events-required (`k_crit`) alongside total N.

### 4. Boundary Reminders

End with a short reminder of what this skill does **not** decide:

> This skill produced sizing under your specified H0 / H1 / endpoint / design. Endpoint selection, H0 / H1 parameterization, regulatory defense, and any decision about Bayesian Go/No-Go, PPOS, 2:1 allocation, or other advanced methods remain the biostatistician's responsibility. See SKILL.md § *Beyond This Skill* for references.

### 5. Suggest Next Steps (Optional)

Based on context, offer one or two follow-ups:

- "Want to compare against single-arm sizing for the same endpoint?"
- "Want a different alpha/power grid?"
- "Want to evaluate this as part of a basket / umbrella / platform trial?" (handoff to `vera-master-trial-designing`)
- "Need a pre-design dossier on the indication, MoA, and competitor study designs?" (handoff to `vera-clinical-indication-researching`)

## Validation Checkpoints

- [ ] CSV was validated in Step 04 (no `NA` in key columns)
- [ ] `power_curve.pdf` is > 1 KB
- [ ] Output paths shown to user are absolute and correct
- [ ] Highlighted row in sample size table matches the user's chosen design

## End of Workflow

This is the final step. The user can re-run with adjusted parameters by returning to Step 01.
