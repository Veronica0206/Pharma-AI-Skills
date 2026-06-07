###############################################################################
# example_minimal.R
# Minimal walkthrough: three endpoint types, single-arm and 1:1 controlled.
# Run from this directory: Rscript example_minimal.R
###############################################################################

resolve_script_dir <- function() {
  frames <- sys.frames()
  for (i in rev(seq_along(frames))) {
    if (!is.null(frames[[i]]$ofile)) {
      return(dirname(normalizePath(frames[[i]]$ofile)))
    }
  }
  script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(script_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", script_arg[1]))))
  }
  getwd()
}
script_dir <- resolve_script_dir()

source(file.path(script_dir, "config.R"))
source(file.path(script_dir, "sample_size.R"))
source(file.path(script_dir, "run_framework.R"))

out_dir <- "outputs"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Example 1: Binary endpoint, two-arm 1:1 ----
# H0: response rate 0.30, H1: response rate 0.50
cfg_binary <- create_config(
  endpoint_type = "binary",
  design        = "controlled",
  null_param    = 0.30,
  alt_param     = 0.50,
  alphas        = c(0.025, 0.05),
  powers        = c(0.80, 0.90),
  label         = "Binary 30 vs 50 percent"
)
res_binary <- run_sample_size_framework(cfg_binary, output_dir = file.path(out_dir, "binary"))

# ---- Example 2: Continuous endpoint, single-arm ----
# H0: mean change 0, H1: mean change 0.5, SD = 1.5
cfg_cont <- create_config(
  endpoint_type = "continuous",
  design        = "single_arm",
  null_param    = 0,
  alt_param     = 0.5,
  sd            = 1.5,
  label         = "Continuous mean change"
)
res_cont <- run_sample_size_framework(cfg_cont, output_dir = file.path(out_dir, "continuous"))

# ---- Example 3: Time-to-event, two-arm 1:1 ----
# H0: hazard 0.10/month, H1: hazard 0.05/month (HR = 0.5)
# 12 months accrual, 12 months follow-up
cfg_tte <- create_config(
  endpoint_type = "tte",
  design        = "controlled",
  null_param    = 0.10,
  alt_param     = 0.05,
  accrual_time  = 12,
  followup_time = 12,
  label         = "OS HR 0.5"
)
res_tte <- run_sample_size_framework(cfg_tte, output_dir = file.path(out_dir, "tte"))

cat("\n\nAll examples done. See outputs/ for CSV tables and PDF power curves.\n")
