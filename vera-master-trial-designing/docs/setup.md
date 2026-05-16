# Setup

## Requirements

- **R**: version 4.0 or later
- **macOS / Linux / Windows**: any platform with R installed

## R Packages

| Package | Required For | Install |
|---------|--------------|---------|
| Base R | All core functionality | included |
| `MAMS` | Umbrella MAMS boundary computation (falls back to a built-in approximation if absent) | `install.packages("MAMS")` |

## Verify R Installation

```bash
which Rscript
Rscript --version
```

Expected: R 4.0+ available on PATH.

## First Run (Smoke Test — basket no-borrowing)

```bash
cd <skill_root>/scripts/R
Rscript -e '
source("shared_utils.R")
source("master_config.R")
source("basket_simple.R")
source("run_master_framework.R")
cfg <- create_master_config(
  master_design_type = "basket",
  endpoint_type      = "binary",
  borrowing_method   = "none",
  n_subgroups        = 3,
  null_params        = 0.20,
  alt_params         = c(0.45, 0.20, 0.45),
  n_per_subgroup     = 25,
  alpha              = 0.10,
  n_sims             = 100,
  output_dir         = "/tmp/master_smoke/"
)
run_master_framework(cfg)
cat("Smoke test PASSED.\n")
'
```

Expected: simulation runs to 100% and CSV/PDF outputs are saved to `/tmp/master_smoke/`.

## Worked Examples

To run all three bundled examples (basket, umbrella, platform):

```bash
cd <skill_root>/scripts/R
Rscript example_minimal.R
```

Outputs land in `outputs/basket/`, `outputs/umbrella/`, `outputs/platform/`.

## Supported Endpoint × Method Combinations (Public Scope)

| Family | Method | binary | continuous |
|---|---|---|---|
| Basket | `none` | ✓ | — |
| Basket | `complete` | ✓ | — |
| Umbrella | `mams` | ✓ | ✓ |
| Platform | concurrent-control (default) | ✓ | — |

Other endpoints or methods raise a clear error directing the user to
SKILL.md § *Beyond This Skill*.

## Output Directory

Set `output_dir` in `create_master_config()`. Default: `"results/"` (relative
to the current working directory).
