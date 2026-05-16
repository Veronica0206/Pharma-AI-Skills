###############################################################################
# sample_size.R
# Sample size calculation for clinical trials.
#
# Public scope:
#   - Binary endpoints: exact binomial (single-arm), Z-test unpooled (two-arm 1:1)
#   - Continuous endpoints: one-sample t (single-arm), two-sample t (two-arm 1:1)
#   - Time-to-event: exponential rate (single-arm), Schoenfeld log-rank (two-arm 1:1)
#
# Alpha convention: alpha = one-sided alpha throughout (e.g., 0.025).
# All controlled designs use 1:1 allocation.
###############################################################################

# =============================================================================
# BINARY: SINGLE-ARM (exact binomial)
# =============================================================================

ss_binomial_single_arm <- function(p0, p1, alpha = 0.025, power = 0.80,
                                   n_min = 5, n_max = 300) {
  for (n in n_min:n_max) {
    k_crit <- qbinom(1 - alpha, size = n, prob = p0) + 1
    if (k_crit > n) next
    pwr <- 1 - pbinom(k_crit - 1, size = n, prob = p1)
    if (pwr >= power) {
      return(list(n = n, k_crit = k_crit, power = round(pwr, 4),
                  alpha = alpha, p0 = p0, p1 = p1))
    }
  }
  return(list(n = NA, k_crit = NA, power = NA,
              alpha = alpha, p0 = p0, p1 = p1))
}

power_binomial_single_arm <- function(n, p0, p1, alpha = 0.025) {
  k_crit <- qbinom(1 - alpha, size = n, prob = p0) + 1
  if (k_crit > n) return(0)
  return(1 - pbinom(k_crit - 1, size = n, prob = p1))
}

# =============================================================================
# BINARY: TWO-ARM 1:1 (Z-test unpooled)
# =============================================================================

power_z_unpooled <- function(n_per_arm, p0, p1, alpha = 0.025) {
  se <- sqrt(p1 * (1 - p1) / n_per_arm + p0 * (1 - p0) / n_per_arm)
  ncp <- (p1 - p0) / se
  z_crit <- qnorm(1 - alpha)
  return(pnorm(ncp - z_crit))
}

ss_z_unpooled <- function(p0, p1, alpha = 0.025, power = 0.80,
                          n_min = 5, n_max = 500) {
  for (n_per in n_min:n_max) {
    pwr <- power_z_unpooled(n_per, p0, p1, alpha)
    if (pwr >= power) {
      return(list(n_total = 2 * n_per, n_trt = n_per,
                  n_ctrl = n_per, power = round(pwr, 4),
                  test = "z_unpooled"))
    }
  }
  return(list(n_total = NA, n_trt = NA, n_ctrl = NA,
              power = NA, test = "z_unpooled"))
}

# =============================================================================
# CONTINUOUS: SINGLE-ARM (one-sample t-test)
# =============================================================================

power_ttest_single_arm <- function(n, delta, sd, alpha = 0.025) {
  res <- power.t.test(n = n, delta = delta, sd = sd,
                      sig.level = alpha,
                      type = "one.sample",
                      alternative = "one.sided")
  return(res$power)
}

ss_ttest_single_arm <- function(delta, sd, alpha = 0.025, power = 0.80) {
  res <- power.t.test(delta = delta, sd = sd,
                      sig.level = alpha,
                      power = power,
                      type = "one.sample",
                      alternative = "one.sided")
  return(list(n = ceiling(res$n), delta = delta, sd = sd,
              alpha = alpha, power = power, test = "one_sample_t"))
}

# =============================================================================
# CONTINUOUS: TWO-ARM 1:1 (two-sample t-test)
# =============================================================================

power_ttest_two_arm <- function(n_per_arm, delta, sd, alpha = 0.025) {
  res <- power.t.test(n = n_per_arm, delta = delta, sd = sd,
                      sig.level = alpha,
                      type = "two.sample",
                      alternative = "one.sided")
  return(res$power)
}

ss_ttest_two_arm <- function(delta, sd, alpha = 0.025, power = 0.80) {
  res <- power.t.test(delta = delta, sd = sd,
                      sig.level = alpha,
                      power = power,
                      type = "two.sample",
                      alternative = "one.sided")
  n_per <- ceiling(res$n)
  return(list(n_total = 2 * n_per, n_trt = n_per, n_ctrl = n_per,
              test = "two_sample_t"))
}

# =============================================================================
# TTE helper: P(event) under exponential hazard with uniform accrual
# =============================================================================

prob_event_exponential <- function(lambda, accrual_time, followup_time) {
  if (lambda <= 0) return(0)
  a <- accrual_time; f <- followup_time
  p <- 1 - (exp(-lambda * f) - exp(-lambda * (a + f))) / (lambda * a)
  return(max(0, min(1, p)))
}

# =============================================================================
# TTE: SINGLE-ARM (exponential rate)
# Events required: d = (z_alpha + z_beta)^2 / (log(lambda_0 / lambda_1))^2
# =============================================================================

ss_logrank_single_arm <- function(lambda0, lambda1, accrual_time, followup_time,
                                  alpha = 0.025, power = 0.80) {
  za <- qnorm(1 - alpha); zb <- qnorm(power)
  log_hr <- log(lambda0 / lambda1)
  d <- ceiling((za + zb)^2 / log_hr^2)
  p_event <- prob_event_exponential(lambda1, accrual_time, followup_time)
  if (p_event <= 0) return(list(n = NA, events = d, p_event = 0, test = "exponential_rate"))
  n <- ceiling(d / p_event)
  return(list(n = n, events = d, p_event = round(p_event, 4),
              power = round(power, 4), alpha = alpha,
              lambda0 = lambda0, lambda1 = lambda1,
              median0 = log(2) / lambda0, median1 = log(2) / lambda1,
              test = "exponential_rate"))
}

power_logrank_single_arm <- function(n, lambda0, lambda1, accrual_time, followup_time,
                                     alpha = 0.025) {
  p_event <- prob_event_exponential(lambda1, accrual_time, followup_time)
  d <- n * p_event
  if (d <= 0) return(0)
  log_hr <- log(lambda0 / lambda1)
  z_stat <- sqrt(d) * abs(log_hr) - qnorm(1 - alpha)
  return(pnorm(z_stat))
}

# =============================================================================
# TTE: TWO-ARM 1:1 (Schoenfeld log-rank)
# d = 4 * (z_alpha + z_beta)^2 / (log(HR))^2
# =============================================================================

ss_logrank_two_arm <- function(lambda0, lambda1, accrual_time, followup_time,
                               alpha = 0.025, power = 0.80) {
  za <- qnorm(1 - alpha); zb <- qnorm(power)
  HR <- lambda1 / lambda0
  log_hr <- log(HR)
  d <- ceiling(4 * (za + zb)^2 / log_hr^2)
  p_event_trt  <- prob_event_exponential(lambda1, accrual_time, followup_time)
  p_event_ctrl <- prob_event_exponential(lambda0, accrual_time, followup_time)
  p_event_avg  <- (p_event_trt + p_event_ctrl) / 2
  if (p_event_avg <= 0) return(list(n_total = NA, events = d, test = "logrank"))
  n_total <- ceiling(d / p_event_avg)
  n_per <- ceiling(n_total / 2)
  return(list(n_total = 2 * n_per, n_trt = n_per, n_ctrl = n_per,
              events = d, p_event_avg = round(p_event_avg, 4),
              HR = round(HR, 4), power = round(power, 4),
              test = "logrank"))
}

power_logrank_two_arm <- function(n_per_arm, lambda0, lambda1,
                                  accrual_time, followup_time, alpha = 0.025) {
  p_event_trt  <- prob_event_exponential(lambda1, accrual_time, followup_time)
  p_event_ctrl <- prob_event_exponential(lambda0, accrual_time, followup_time)
  d <- n_per_arm * p_event_trt + n_per_arm * p_event_ctrl
  if (d <= 0) return(0)
  HR <- lambda1 / lambda0
  z_stat <- sqrt(d / 4) * abs(log(HR)) - qnorm(1 - alpha)
  return(pnorm(z_stat))
}

cat("sample_size.R loaded.\n")
