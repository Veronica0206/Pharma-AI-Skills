###############################################################################
# example_minimal.R
# Synthetic smoke test for binary/continuous Bucher and MAIC workflows.
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

set.seed(60606)
out_root <- "outputs"
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)

# ---- Example 1: binary endpoint summaries -> Bucher's method through placebo ----
bucher_endpoint_input <- data.frame(
  comparison_id = c("binary_ab", "binary_cb"),
  treatment = c("Drug A", "Drug C"),
  comparator = c("Placebo", "Placebo"),
  endpoint_type = c("binary", "binary"),
  effect_measure = c("log_odds_ratio", "log_odds_ratio"),
  treatment_events = c(45, 38),
  treatment_total = c(100, 100),
  comparator_events = c(30, 30),
  comparator_total = c(100, 100),
  source = c("Synthetic binary Trial AB", "Synthetic binary Trial CB"),
  stringsAsFactors = FALSE
)
bucher_endpoint_csv <- file.path(out_root, "bucher_endpoint_contrasts.csv")
write.csv(bucher_endpoint_input, bucher_endpoint_csv, row.names = FALSE)

run_bucher_from_endpoints(
  endpoint_csv = bucher_endpoint_csv,
  output_dir = file.path(out_root, "bucher"),
  treatment_a = "Drug A",
  treatment_c = "Drug C",
  common_comparator = "Placebo"
)

# ---- Example 2: continuous Bucher chain orientation, AC + CB -> AB ----
bucher_chain_input <- data.frame(
  comparison_id = c("chain_ac", "chain_cb"),
  treatment = c("Drug A", "Drug C"),
  comparator = c("Drug C", "Drug B"),
  effect_measure = rep("mean_difference", 2),
  analysis_scale = rep("mean_difference", 2),
  estimate = c(2.8, 1.1),
  se = c(0.62, 0.54),
  source = c("Synthetic continuous Trial AC", "Synthetic continuous Trial CB"),
  stringsAsFactors = FALSE
)
bucher_chain_csv <- file.path(out_root, "bucher_chain_direct_effects.csv")
write.csv(bucher_chain_input, bucher_chain_csv, row.names = FALSE)

bucher_chain_res <- run_bucher_chain(
  input_csv = bucher_chain_csv,
  output_dir = file.path(out_root, "bucher_chain"),
  treatment_a = "Drug A",
  treatment_b = "Drug B",
  via_treatment = "Drug C"
)
if (abs(bucher_chain_res$result$estimate[1] - 3.9) > 1e-10) {
  stop("Bucher chain smoke check failed: expected 2.8 + 1.1.")
}

# ---- Example 3: derive continuous direct effects from endpoint summaries ----
endpoint_examples <- data.frame(
  comparison_id = c("continuous_ab", "continuous_cb"),
  treatment = c("Drug A", "Drug C"),
  comparator = rep("Placebo", 2),
  endpoint_type = rep("continuous", 2),
  effect_measure = rep("mean_difference", 2),
  treatment_mean = c(12.1, 10.2),
  treatment_sd = c(4.2, 4.1),
  treatment_n = c(80, 82),
  comparator_mean = c(9.3, 9.3),
  comparator_sd = c(4.5, 4.5),
  comparator_n = c(78, 78),
  source = c("Synthetic continuous AB", "Synthetic continuous CB"),
  stringsAsFactors = FALSE
)
endpoint_examples_csv <- file.path(out_root, "endpoint_contrasts_continuous.csv")
write.csv(endpoint_examples, endpoint_examples_csv, row.names = FALSE)
derive_direct_effects_from_endpoints(
  endpoint_examples_csv,
  output_csv = file.path(out_root, "derived_direct_effects_continuous.csv")
)

# ---- Example 4: MAIC weighting and anchored binary MAIC ----
n <- 120
arm <- rep(c("Drug A", "Placebo"), each = n / 2)
age <- round(rnorm(n, mean = ifelse(arm == "Drug A", 57, 56), sd = 7), 1)
prior_tx <- rbinom(n, size = 1, prob = ifelse(arm == "Drug A", 0.34, 0.30))
baseline_score <- round(rnorm(n, mean = 6.4 + 0.5 * prior_tx, sd = 1.0), 1)
linear_predictor <- -0.75 + 0.85 * (arm == "Drug A") -
  0.015 * (age - 58) - 0.25 * prior_tx + 0.08 * (baseline_score - 6.5)
response <- rbinom(n, size = 1, prob = inv_logit(linear_predictor))
change_score <- rnorm(n, mean = 1.0 + 1.8 * (arm == "Drug A") -
                        0.02 * (age - 58), sd = 2.5)

ipd <- data.frame(
  patient_id = sprintf("P%03d", seq_len(n)),
  arm = arm,
  response = response,
  change_score = change_score,
  age = age,
  prior_tx = prior_tx,
  baseline_score = baseline_score,
  stringsAsFactors = FALSE
)
targets <- data.frame(
  covariate = c("age", "prior_tx", "baseline_score"),
  target_mean = c(62, 0.45, 7.4),
  stringsAsFactors = FALSE
)
target_effect <- data.frame(
  comparison_id = "trial_cb",
  treatment = "Drug C",
  comparator = "Placebo",
  effect_measure = "odds_ratio",
  analysis_scale = "log_odds_ratio",
  estimate = 0.45,
  se = 0.22,
  source = "Synthetic published Trial CB",
  stringsAsFactors = FALSE
)

ipd_csv <- file.path(out_root, "maic_ipd.csv")
target_csv <- file.path(out_root, "maic_targets.csv")
target_effect_csv <- file.path(out_root, "published_c_vs_placebo.csv")
write.csv(ipd, ipd_csv, row.names = FALSE)
write.csv(targets, target_csv, row.names = FALSE)
write.csv(target_effect, target_effect_csv, row.names = FALSE)

run_maic(
  ipd_csv = ipd_csv,
  target_csv = target_csv,
  output_dir = file.path(out_root, "maic"),
  treatment_arm = "Drug A",
  comparator_arm = "Placebo",
  endpoint_type = "binary",
  outcome_col = "response",
  measure = "log_odds_ratio",
  anchored_comparator_csv = target_effect_csv,
  target_treatment_arm = "Drug C"
)

run_maic(
  ipd_csv = ipd_csv,
  target_csv = target_csv,
  output_dir = file.path(out_root, "maic_continuous"),
  treatment_arm = "Drug A",
  comparator_arm = "Placebo",
  endpoint_type = "continuous",
  outcome_col = "change_score"
)

expected <- c(
  "derived_direct_effects_continuous.csv",
  file.path("bucher", "bucher_result.csv"),
  file.path("bucher", "derived_direct_effects.csv"),
  file.path("bucher", "bucher_forest.pdf"),
  file.path("bucher_chain", "bucher_chain_result.csv"),
  file.path("bucher_chain", "bucher_chain_forest.pdf"),
  file.path("maic", "maic_weights.csv"),
  file.path("maic", "maic_balance.csv"),
  file.path("maic", "maic_ess.csv"),
  file.path("maic", "maic_source_effect.csv"),
  file.path("maic", "maic_anchored_result.csv"),
  file.path("maic", "maic_balance_plot.pdf"),
  file.path("maic_continuous", "maic_source_effect.csv")
)
ok <- all(file.exists(file.path(out_root, expected)))
cat("SMOKE_INDIRECT_COMPARISON=", ok, "\n", sep = "")
if (!ok) stop("Smoke test failed: expected outputs were not all created.")
