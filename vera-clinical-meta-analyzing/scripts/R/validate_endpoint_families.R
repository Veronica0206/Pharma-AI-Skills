###############################################################################
# validate_endpoint_families.R
#
# Deterministic smoke checks for supported meta-analysis endpoint families.
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
source(file.path(script_dir, "meta_endpoint_core.R"))

assert_close <- function(actual, expected, label, tolerance = 1e-10) {
  if (!is.finite(actual) || abs(actual - expected) > tolerance) {
    stop(label, " mismatch: got ", actual, ", expected ", expected)
  }
}

# Binary single-arm rate and comparative effect.
bin_rate <- binary_logit_inputs(c(30, 45), c(100, 100))
stopifnot(all(bin_rate$endpoint_family == "binary"))
pooled_bin <- meta_iv(bin_rate$yi, bin_rate$vi)
stopifnot(pooled_bin$k == 2)

bin_rr <- binary_comparative_inputs(
  events_t = 30, total_t = 100,
  events_c = 20, total_c = 100,
  measure = "log_risk_ratio"
)
assert_close(bin_rr$yi[1], log(1.5), "Binary log risk ratio")

# Continuous single-arm mean and comparative mean difference.
cont_mean <- continuous_mean_inputs(mean = c(10, 12), sd = c(2, 3), n = c(25, 30))
assert_close(cont_mean$vi[1], 4 / 25, "Continuous mean variance")
pooled_cont <- meta_iv(cont_mean$yi, cont_mean$vi)
stopifnot(pooled_cont$k == 2)

cont_md <- continuous_comparative_inputs(
  mean_t = 14, sd_t = 3, n_t = 40,
  mean_c = 11, sd_c = 4, n_c = 38,
  measure = "mean_difference"
)
assert_close(cont_md$yi[1], 3, "Continuous mean difference")

# Time-to-event hazard ratio from CI.
tte <- time_to_event_inputs(hr = 0.70, ci_lower = 0.50, ci_upper = 0.98)
assert_close(tte$yi[1], log(0.70), "Time-to-event log HR")
stopifnot(tte$vi[1] > 0)

# Incidence-rate single-arm rate and comparative rate ratio.
rate <- incidence_rate_inputs(events = c(12, 20), person_time = c(100, 120))
stopifnot(all(rate$endpoint_family == "incidence_rate"))
pooled_rate <- meta_iv(rate$yi, rate$vi)
stopifnot(pooled_rate$k == 2)

rate_ratio <- incidence_rate_ratio_inputs(
  events_t = 12, person_time_t = 100,
  events_c = 20, person_time_c = 100
)
assert_close(rate_ratio$yi[1], log(0.6), "Incidence log rate ratio")

cat("META_ENDPOINT_FAMILIES=binary,continuous,time_to_event,incidence_rate\n")
cat("META_ENDPOINT_FAMILY_VALIDATION=TRUE\n")
