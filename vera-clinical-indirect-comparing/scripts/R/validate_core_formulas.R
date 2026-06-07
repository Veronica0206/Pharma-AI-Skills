###############################################################################
# validate_core_formulas.R
# Deterministic regression checks for the simplified binary/continuous framework.
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
source(file.path(script_dir, "indirect_comparison.R"))

assert_close <- function(actual, expected, label, tolerance = 1e-10) {
  if (!is.finite(actual) || abs(actual - expected) > tolerance) {
    stop(label, " mismatch: got ", actual, ", expected ", expected)
  }
}

tmp <- tempfile("indirect_formula_validation_")
dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(tmp)) stop("Could not create temporary validation directory: ", tmp)

# Bucher common-comparator orientation: d_AC = d_AB - d_CB.
bucher_common <- data.frame(
  comparison_id = c("ab", "cb"),
  treatment = c("Drug A", "Drug C"),
  comparator = c("Placebo", "Placebo"),
  effect_measure = rep("odds_ratio", 2),
  analysis_scale = rep("log_odds_ratio", 2),
  estimate = c(log(1.90), log(1.35)),
  se = c(0.20, 0.18),
  source = c("Synthetic AB", "Synthetic CB"),
  stringsAsFactors = FALSE
)
bucher_common_csv <- file.path(tmp, "bucher_common.csv")
write.csv(bucher_common, bucher_common_csv, row.names = FALSE)
bucher_common_res <- run_bucher(
  input_csv = bucher_common_csv,
  output_dir = file.path(tmp, "bucher_common"),
  treatment_a = "Drug A",
  treatment_c = "Drug C",
  common_comparator = "Placebo"
)
assert_close(bucher_common_res$result$estimate[1],
             log(1.90) - log(1.35), "Bucher common estimate")
assert_close(bucher_common_res$result$se[1],
             sqrt(0.20^2 + 0.18^2), "Bucher common SE")

# Bucher chain orientation: d_AB = d_AC + d_CB.
bucher_chain <- data.frame(
  comparison_id = c("ac", "cb"),
  treatment = c("Drug A", "Drug C"),
  comparator = c("Drug C", "Drug B"),
  effect_measure = rep("mean_difference", 2),
  analysis_scale = rep("mean_difference", 2),
  estimate = c(2.8, 1.1),
  se = c(0.62, 0.54),
  source = c("Synthetic AC", "Synthetic CB"),
  stringsAsFactors = FALSE
)
bucher_chain_csv <- file.path(tmp, "bucher_chain.csv")
write.csv(bucher_chain, bucher_chain_csv, row.names = FALSE)
bucher_chain_res <- run_bucher_chain(
  input_csv = bucher_chain_csv,
  output_dir = file.path(tmp, "bucher_chain"),
  treatment_a = "Drug A",
  treatment_b = "Drug B",
  via_treatment = "Drug C"
)
assert_close(bucher_chain_res$result$estimate[1], 3.9, "Bucher chain estimate")
assert_close(bucher_chain_res$result$se[1], sqrt(0.62^2 + 0.54^2), "Bucher chain SE")

# Endpoint derivation for supported public endpoint families.
endpoint_rows <- data.frame(
  comparison_id = c("binary", "continuous"),
  treatment = rep("Drug A", 2),
  comparator = rep("Placebo", 2),
  endpoint_type = c("binary", "continuous"),
  effect_measure = c("log_odds_ratio", "mean_difference"),
  treatment_events = c(45, NA),
  treatment_total = c(100, NA),
  comparator_events = c(30, NA),
  comparator_total = c(100, NA),
  treatment_mean = c(NA, 12.1),
  treatment_sd = c(NA, 4.2),
  treatment_n = c(NA, 80),
  comparator_mean = c(NA, 9.3),
  comparator_sd = c(NA, 4.5),
  comparator_n = c(NA, 78),
  source = c("Synthetic binary", "Synthetic continuous"),
  stringsAsFactors = FALSE
)
endpoint_csv <- file.path(tmp, "endpoints.csv")
write.csv(endpoint_rows, endpoint_csv, row.names = FALSE)
derived <- derive_direct_effects_from_endpoints(endpoint_csv)
assert_close(derived$estimate[derived$comparison_id == "binary"],
             log((45 / 55) / (30 / 70)), "Binary derivation")
assert_close(derived$estimate[derived$comparison_id == "continuous"],
             12.1 - 9.3, "Continuous derivation")

# MAIC with target means equal to source means should produce unit weights.
ipd <- data.frame(
  patient_id = sprintf("P%03d", 1:6),
  arm = rep(c("Drug A", "Placebo"), each = 3),
  response = c(1, 1, 0, 1, 0, 0),
  change_score = c(4, 5, 3, 2, 1, 3),
  age = c(60, 62, 64, 60, 62, 64),
  prior_tx = c(0, 1, 0, 0, 1, 0),
  stringsAsFactors = FALSE
)
targets <- data.frame(
  covariate = c("age", "prior_tx"),
  target_mean = c(mean(ipd$age), mean(ipd$prior_tx)),
  stringsAsFactors = FALSE
)
ipd_csv <- file.path(tmp, "maic_ipd.csv")
target_csv <- file.path(tmp, "maic_targets.csv")
write.csv(ipd, ipd_csv, row.names = FALSE)
write.csv(targets, target_csv, row.names = FALSE)
maic_binary <- run_maic(
  ipd_csv = ipd_csv,
  target_csv = target_csv,
  output_dir = file.path(tmp, "maic_binary"),
  treatment_arm = "Drug A",
  comparator_arm = "Placebo",
  endpoint_type = "binary",
  outcome_col = "response"
)
if (max(abs(maic_binary$weights$maic_weight - 1)) > 1e-8) {
  stop("MAIC unit-weight check failed.")
}
source_effect <- maic_binary$source_effect
pt <- bounded_rate(2 / 3, 3)
pc <- bounded_rate(1 / 3, 3)
assert_close(source_effect$estimate[1],
             log((pt / (1 - pt)) / (pc / (1 - pc))),
             "MAIC binary estimate")

maic_cont <- run_maic(
  ipd_csv = ipd_csv,
  target_csv = target_csv,
  output_dir = file.path(tmp, "maic_continuous"),
  treatment_arm = "Drug A",
  comparator_arm = "Placebo",
  endpoint_type = "continuous",
  outcome_col = "change_score"
)
assert_close(maic_cont$source_effect$estimate[1],
             mean(ipd$change_score[ipd$arm == "Drug A"]) -
               mean(ipd$change_score[ipd$arm == "Placebo"]),
             "MAIC continuous estimate")

unlink(tmp, recursive = TRUE)
cat("CORE_FORMULA_VALIDATION=TRUE\n")
