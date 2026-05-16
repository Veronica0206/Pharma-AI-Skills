###############################################################################
# example_minimal.R
# Minimal walkthrough for the public release: one example per master design family.
# Run from this directory: Rscript example_minimal.R
###############################################################################

source("shared_utils.R")
source("master_config.R")
source("basket_simple.R")
source("umbrella_mams.R")
source("platform_simple.R")
source("run_master_framework.R")

out_root <- "outputs"
dir.create(out_root, showWarnings = FALSE, recursive = TRUE)

# ---- Example 1: Basket trial, 4 subgroups, no borrowing ----
# 4 prespecified subgroups for one drug. SoC response 20%; arms 1 and 2 are
# truly active (45% response); arms 3 and 4 are null (20% response).
cfg_basket <- create_master_config(
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
  seed               = 42,
  output_dir         = file.path(out_root, "basket")
)
run_master_framework(cfg_basket)

# ---- Example 2: Umbrella trial, 3 arms, MAMS ----
# 3 experimental arms vs shared control, continuous endpoint.
cfg_umbrella <- create_master_config(
  master_design_type = "umbrella",
  endpoint_type      = "continuous",
  n_subgroups        = 3,
  null_params        = 0,
  alt_params         = c(7, 7, 0),  # arms 1 and 2 truly active
  sd                 = 7,
  umbrella_method    = "mams",
  n_stages           = 2,
  n_per_arm_stage    = 30,
  alpha              = 0.025,
  n_sims             = 2000,
  seed               = 42,
  output_dir         = file.path(out_root, "umbrella")
)
run_master_framework(cfg_umbrella)

# ---- Example 3: Platform trial, 3 arms over 6 periods ----
# 3 arms entering and leaving at different periods; shared concurrent control.
cfg_platform <- create_master_config(
  master_design_type = "platform",
  endpoint_type      = "binary",
  n_subgroups        = 3,
  null_params        = 0.30,
  alt_params         = c(0.55, 0.30, 0.55),  # arms 1 and 3 truly active
  arms_schedule      = list(
    enter = c(1, 1, 3),
    leave = c(4, 4, 6)
  ),
  n_periods          = 6,
  n_per_period       = 60,
  alpha              = 0.025,
  n_sims             = 2000,
  seed               = 42,
  output_dir         = file.path(out_root, "platform")
)
run_master_framework(cfg_platform)

cat("\n\nAll examples done. See outputs/ for CSV tables and PDF plots.\n")
