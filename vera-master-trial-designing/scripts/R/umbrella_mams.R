###############################################################################
# umbrella_mams.R -- Multi-Arm Multi-Stage (MAMS) design for umbrella trials
#   Based on Follmann et al. (1994), Wason et al. (2012), Magirr et al. (2012)
###############################################################################

umbrella_mams_boundaries <- function(K, J, alpha = 0.025, power = 0.90,
                                      delta_interesting = 7, delta_uninteresting = 2,
                                      sd = 7) {
  # Attempt to use MAMS package for boundary computation
  if (requireNamespace("MAMS", quietly = TRUE)) {
    tryCatch({
      design <- MAMS::mams(
        K = K, J = J,
        alpha = alpha, power = power,
        r = rep(1, J), r0 = rep(1, J),
        p = rep(delta_interesting / sd, J),
        p0 = rep(delta_uninteresting / sd, J)
      )
      return(list(
        futility = design$l,
        efficacy = design$u,
        n_per_arm_stage = ceiling(design$n / J),
        source = "MAMS_package"
      ))
    }, error = function(e) {
      cat("MAMS package computation failed, using approximation.\n")
    })
  }

  # Fallback: simple futility boundary approximation
  # Based on Wason et al. (2012) guidelines
  if (J == 1) {
    fb <- qnorm(1 - alpha)
    return(list(futility = fb, efficacy = fb,
                n_per_arm_stage = NULL, source = "approximation"))
  }

  if (J == 2) {
    fb <- c(0.715, qnorm(1 - alpha) - 0.04)
  } else if (J == 3) {
    fb <- c(0, 1.22, qnorm(1 - alpha) - 0.07)
  } else {
    fb <- seq(0, qnorm(1 - alpha), length.out = J)
  }

  list(futility = fb, efficacy = rep(Inf, J), n_per_arm_stage = NULL,
       source = "approximation")
}

umbrella_mams_simulate <- function(cfg, sim_id) {
  K  <- cfg$n_arms
  J  <- cfg$n_stages
  n  <- cfg$n_per_arm_stage
  sd <- if (!is.null(cfg$sd)) cfg$sd else 1
  mu <- c(cfg$alt_params, 0)  # K experimental + 1 control (last)

  # Get boundaries
  if (is.null(cfg$futility_boundaries)) {
    bounds <- umbrella_mams_boundaries(K, J, cfg$alpha, sd = sd)
    f_bounds <- bounds$futility
  } else {
    f_bounds <- cfg$futility_boundaries
  }

  # Generate all data upfront: n*J patients per arm
  endpoint <- if (!is.null(cfg$endpoint_type)) cfg$endpoint_type else "continuous"

  y <- matrix(NA, nrow = n * J, ncol = K + 1)
  if (endpoint == "continuous") {
    for (j in 1:(K + 1)) {
      y[, j] <- rnorm(n * J, mean = mu[j], sd = sd)
    }
  } else if (endpoint == "binary") {
    probs <- c(cfg$alt_params, cfg$null_params[1])
    for (j in 1:(K + 1)) {
      y[, j] <- rbinom(n * J, 1, probs[j])
    }
  } else {
    stop("umbrella MAMS public scope supports binary or continuous endpoints only.")
  }

  # Track which arms are active
  active <- rep(TRUE, K)
  t_stats <- matrix(NA, nrow = J, ncol = K)

  for (stage in 1:J) {
    idx <- 1:(n * stage)
    for (k in 1:K) {
      if (endpoint == "continuous") {
        tt <- t.test(y[idx, k], y[idx, K + 1])
        t_stats[stage, k] <- tt$statistic
      } else if (endpoint == "binary") {
        x_trt <- sum(y[idx, k]); n_trt <- length(idx)
        x_ctrl <- sum(y[idx, K + 1]); n_ctrl <- length(idx)
        p_trt <- x_trt / n_trt; p_ctrl <- x_ctrl / n_ctrl
        p_pool <- (x_trt + x_ctrl) / (n_trt + n_ctrl)
        se <- sqrt(p_pool * (1 - p_pool) * (1/n_trt + 1/n_ctrl))
        t_stats[stage, k] <- if (se > 0) (p_trt - p_ctrl) / se else 0
      }
    }

    # Apply futility boundary
    if (stage < J) {
      for (k in 1:K) {
        if (active[k] && t_stats[stage, k] < f_bounds[stage]) {
          active[k] <- FALSE
        }
      }
    }
  }

  # Final decision: arms that passed all stages
  selected <- active & t_stats[J, ] >= f_bounds[J]
  selected[is.na(selected)] <- FALSE

  # Compute per-arm sample sizes (actual enrollment accounting for dropping)
  per_arm_n <- rep(0, K)
  arm_active_stages <- rep(0, K)
  active_check <- rep(TRUE, K)
  for (stage in 1:J) {
    for (k in 1:K) {
      if (active_check[k]) {
        per_arm_n[k] <- per_arm_n[k] + n
        arm_active_stages[k] <- stage
      }
    }
    if (stage < J) {
      for (k in 1:K) {
        if (active_check[k] && t_stats[stage, k] < f_bounds[stage]) {
          active_check[k] <- FALSE
        }
      }
    }
  }

  ctrl_n <- n * J  # control always enrolled
  total_n <- sum(per_arm_n) + ctrl_n

  # Estimated treatment effects (for selected arms)
  estimates <- rep(NA, K)
  for (k in 1:K) {
    idx <- 1:(n * arm_active_stages[k])
    estimates[k] <- mean(y[idx, k]) - mean(y[idx, K + 1])
  }

  list(
    selected   = selected,
    t_stats    = t_stats,
    estimates  = estimates,
    per_arm_n  = per_arm_n,
    total_n    = total_n
  )
}

# --- Adding Arm Mid-Trial (MAMS) ---
# --- Run full MAMS simulation ---

run_umbrella_mams <- function(cfg) {
  cat("--- Running MAMS simulation ---\n")

  results <- simulation_harness(cfg, umbrella_mams_simulate)

  K <- cfg$n_arms
  n_sims <- cfg$n_sims

  # Aggregate results
  reject_matrix <- do.call(rbind, lapply(results, function(r) r$selected))
  estimate_matrix <- do.call(rbind, lapply(results, function(r) r$estimates))
  total_n_vec <- sapply(results, function(r) r$total_n)

  # Determine which arms are truly active
  true_active <- cfg$alt_params != cfg$null_params[1:K]
  true_null   <- !true_active

  # Operating characteristics
  fwer <- compute_fwer(reject_matrix, true_null)
  per_arm_power <- colMeans(reject_matrix)
  disjunctive_power <- compute_power_disjunctive(reject_matrix, true_active)
  conjunctive_power <- compute_power_conjunctive(reject_matrix, true_active)
  cc_power <- compute_power_complete_correct(reject_matrix, true_active)

  # Conditional estimates
  cond_est <- numeric(K)
  for (k in 1:K) {
    sel_k <- reject_matrix[, k]
    if (sum(sel_k) > 0) {
      cond_est[k] <- mean(estimate_matrix[sel_k, k])
    } else {
      cond_est[k] <- NA
    }
  }

  # Build output tables
  oc_table <- data.frame(
    arm = 1:K,
    true_effect = cfg$alt_params - cfg$null_params[1:K],
    per_arm_power = round(per_arm_power * 100, 1),
    cond_estimate = round(cond_est, 2),
    stringsAsFactors = FALSE
  )

  power_table <- data.frame(
    metric = c("FWER (%)", "1-minimum power (%)", "Complete power (%)",
               "Complete correct power (%)", "Mean total N"),
    value = round(c(fwer * 100, disjunctive_power * 100, conjunctive_power * 100,
                    cc_power * 100, mean(total_n_vec)), 1),
    stringsAsFactors = FALSE
  )

  # Traditional comparison (endpoint-aware)
  za <- qnorm(1 - cfg$alpha); zb <- qnorm(0.90)
  endpoint <- if (!is.null(cfg$endpoint_type)) cfg$endpoint_type else "continuous"

  if (endpoint == "continuous") {
    sd_val <- if (!is.null(cfg$sd)) cfg$sd else 1
    max_delta <- max(abs(cfg$alt_params - cfg$null_params))
    n_traditional <- 2 * ceiling((za + zb)^2 * 2 * sd_val^2 / max_delta^2)
  } else if (endpoint == "binary") {
    p0 <- cfg$null_params[1]
    p1 <- max(cfg$alt_params[cfg$alt_params != p0])
    n_traditional <- 2 * ceiling((za + zb)^2 *
                     (p1*(1-p1) + p0*(1-p0)) / (p1 - p0)^2)
  } else {
    n_traditional <- NA
  }
  trad_total <- if (!is.na(n_traditional)) n_traditional * K else NA

  ss_table <- data.frame(
    design = c("Traditional (separate trials)", "Umbrella (MAMS)"),
    expected_n = c(if (is.na(trad_total)) round(mean(total_n_vec) * 2) else trad_total,
                   round(mean(total_n_vec))),
    stringsAsFactors = FALSE
  )

  list(oc_table = oc_table, power_table = power_table,
       sample_size_table = ss_table, reject_matrix = reject_matrix)
}
