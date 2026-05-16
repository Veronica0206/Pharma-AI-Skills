###############################################################################
# shared_utils.R -- Common utilities for master protocol simulations
###############################################################################

# --- Data simulation ---

simulate_binary_data <- function(n, p) {
  rbinom(n, size = 1, prob = p)
}

simulate_continuous_data <- function(n, mu, sd) {
  rnorm(n, mean = mu, sd = sd)
}

# TTE data simulation (exponential model)
simulate_tte_data <- function(n, lambda, accrual_time, followup_time) {
  event_times <- rexp(n, rate = lambda)
  # Uniform accrual: each patient enrolled at random time in [0, accrual_time]
  # Administrative censoring at accrual_time + followup_time from study start
  enroll_times <- runif(n, 0, accrual_time)
  max_obs_times <- accrual_time + followup_time - enroll_times
  censored <- event_times > max_obs_times
  obs_times <- pmin(event_times, max_obs_times)
  list(
    time = obs_times,
    status = as.integer(!censored),
    events = sum(!censored),
    person_time = sum(obs_times)
  )
}

# Incidence rate data simulation (Poisson model)
simulate_rate_data <- function(n, lambda, exposure_time) {
  counts <- rpois(n, lambda = lambda * exposure_time)
  list(
    counts = counts,
    total_count = sum(counts),
    total_exposure = n * exposure_time
  )
}

# TTE posterior probability: P(lambda < threshold | data)
# Gamma conjugate: Prior Gamma(shape0, rate0), Posterior Gamma(shape0+d, rate0+T)
surv_posterior_prob <- function(events, person_time, threshold,
                               prior_shape = 0.5, prior_rate = 1e-6) {
  post_shape <- prior_shape + events
  post_rate  <- prior_rate + person_time
  pgamma(threshold, shape = post_shape, rate = post_rate)
}

# Incidence rate posterior probability: P(lambda < threshold | data)
rate_posterior_prob <- function(count, exposure, threshold,
                               prior_shape = 0.5, prior_rate = 1e-6) {
  post_shape <- prior_shape + count
  post_rate  <- prior_rate + exposure
  pgamma(threshold, shape = post_shape, rate = post_rate)
}

# --- Beta-Binomial posterior ---

beta_posterior_params <- function(x, n, a_prior = 1, b_prior = 1) {
  list(a = a_prior + x, b = b_prior + n - x)
}

beta_posterior_prob <- function(x, n, threshold, a_prior = 1, b_prior = 1) {
  post <- beta_posterior_params(x, n, a_prior, b_prior)
  1 - pbeta(threshold, post$a, post$b)
}

# --- Normal-Normal posterior ---

normal_posterior_params <- function(ybar, n, sigma, mu_prior, sigma_prior) {
  prec_prior <- 1 / sigma_prior^2
  prec_data  <- n / sigma^2
  prec_post  <- prec_prior + prec_data
  mu_post    <- (prec_prior * mu_prior + prec_data * ybar) / prec_post
  sigma_post <- sqrt(1 / prec_post)
  list(mu = mu_post, sigma = sigma_post)
}

normal_posterior_prob <- function(ybar, n, sigma, threshold,
                                  mu_prior = 0, sigma_prior = 10) {
  post <- normal_posterior_params(ybar, n, sigma, mu_prior, sigma_prior)
  1 - pnorm(threshold, mean = post$mu, sd = post$sigma)
}

# --- FWER and power computation ---

compute_fwer <- function(reject_matrix, true_null) {
  # reject_matrix: n_sims x K (TRUE/FALSE)
  # true_null: logical vector of length K (TRUE = truly null)
  if (sum(true_null) == 0) return(NA)
  false_rejections <- reject_matrix[, true_null, drop = FALSE]
  mean(rowSums(false_rejections) > 0)
}

compute_power_per_arm <- function(reject_matrix, true_active) {
  # true_active: logical vector of length K (TRUE = truly active)
  if (sum(true_active) == 0) return(numeric(0))
  active_rejections <- reject_matrix[, true_active, drop = FALSE]
  colMeans(active_rejections)
}

compute_power_disjunctive <- function(reject_matrix, true_active) {
  # 1-minimum power: P(reject at least one active arm)
  if (sum(true_active) == 0) return(NA)
  active_rejections <- reject_matrix[, true_active, drop = FALSE]
  mean(rowSums(active_rejections) > 0)
}

compute_power_conjunctive <- function(reject_matrix, true_active) {
  # Complete power: P(reject all active arms)
  if (sum(true_active) == 0) return(NA)
  active_rejections <- reject_matrix[, true_active, drop = FALSE]
  mean(rowSums(active_rejections) == sum(true_active))
}

compute_power_complete_correct <- function(reject_matrix, true_active) {
  # Complete correct power: P(reject all and only active arms)
  n_active <- sum(true_active)
  if (n_active == 0) return(NA)
  all_active_rejected <- rowSums(reject_matrix[, true_active, drop = FALSE]) == n_active
  no_null_rejected    <- rowSums(reject_matrix[, !true_active, drop = FALSE]) == 0
  mean(all_active_rejected & no_null_rejected)
}

# --- Simulation harness ---

simulation_harness <- function(cfg, sim_fn, progress_interval = 0.10) {
  set.seed(cfg$seed)
  n_sims <- cfg$n_sims

  results <- vector("list", n_sims)
  progress_points <- floor(seq(progress_interval, 1, by = progress_interval) * n_sims)

  for (i in seq_len(n_sims)) {
    results[[i]] <- sim_fn(cfg, i)
    if (i %in% progress_points) {
      cat(sprintf("Simulation progress: %d%%...\n", round(i / n_sims * 100)))
    }
  }

  return(results)
}

# --- Output helpers ---

save_csv <- function(df, filename, output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(output_dir, filename)
  write.csv(df, path, row.names = FALSE)
  cat("Saved:", path, "\n")
}

save_pdf_plot <- function(plot_fn, filename, output_dir, width = 8, height = 6) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(output_dir, filename)
  pdf(path, width = width, height = height)
  plot_fn()
  dev.off()
  cat("Saved:", path, "\n")
}

# --- Inverse gamma (for BHM) ---

rinvgamma <- function(n, shape, scale) {
  1 / rgamma(n, shape = shape, rate = scale)
}

dinvgamma <- function(x, shape, scale, log = FALSE) {
  lp <- shape * log(scale) - lgamma(shape) - (shape + 1) * log(x) - scale / x
  if (log) lp else exp(lp)
}
