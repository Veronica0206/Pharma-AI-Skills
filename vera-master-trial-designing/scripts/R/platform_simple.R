###############################################################################
# platform_simple.R -- Platform trial: naive concurrent-control comparison.
#
# Public scope:
#   - Binary endpoint
#   - Equal allocation across active arms + shared concurrent control
#   - Each arm tested at end of its window using only patients enrolled while
#     it was active (concurrent control). No adjustment for time trends.
#
# Methods intentionally out of scope (see SKILL.md § Beyond This Skill):
#   - Non-concurrent control (NCC) adjustment via regression or time-machine
#   - Response-adaptive randomization (RAR) via Thompson sampling
#   - Time-trend modeling
###############################################################################

# Single simulation: simulate the platform trial across all periods.
simulate_platform_simple <- function(cfg, sim_id) {
  endpoint <- if (!is.null(cfg$endpoint_type)) cfg$endpoint_type else "binary"
  if (endpoint != "binary") {
    stop("platform_simple.R public scope supports binary endpoints only.")
  }

  K <- cfg$n_subgroups
  n_periods <- cfg$n_periods
  n_per_period <- cfg$n_per_period
  enter <- cfg$arms_schedule$enter
  leave <- cfg$arms_schedule$leave

  # Each arm collects (response, period) tuples while active.
  arm_data <- vector("list", K)
  for (k in 1:K) arm_data[[k]] <- data.frame(response = integer(0), period = integer(0))
  ctrl_data <- data.frame(response = integer(0), period = integer(0))
  alloc_history <- matrix(0, nrow = n_periods, ncol = K + 1)

  for (t in 1:n_periods) {
    active_arms <- which(enter <= t & leave >= t)
    if (length(active_arms) == 0) next

    n_arms_active <- length(active_arms)
    # Equal allocation across (active arms + 1 control).
    base <- floor(n_per_period / (n_arms_active + 1))
    rem  <- n_per_period - base * (n_arms_active + 1)
    n_per_arm <- rep(base, n_arms_active)
    n_ctrl <- base + rem  # control absorbs any remainder

    for (j in seq_along(active_arms)) {
      k <- active_arms[j]
      n_k <- n_per_arm[j]
      if (n_k > 0) {
        resp <- simulate_binary_data(n_k, cfg$alt_params[k])
        arm_data[[k]] <- rbind(arm_data[[k]],
                               data.frame(response = resp, period = rep(t, n_k)))
      }
      alloc_history[t, k] <- n_k
    }
    if (n_ctrl > 0) {
      ctrl_resp <- simulate_binary_data(n_ctrl, cfg$null_params[1])
      ctrl_data <- rbind(ctrl_data,
                         data.frame(response = ctrl_resp, period = rep(t, n_ctrl)))
    }
    alloc_history[t, K + 1] <- n_ctrl
  }

  # Per-arm test using concurrent control only (patients enrolled during the
  # same periods the arm was active).
  arm_results <- data.frame(
    arm = 1:K,
    n_arm = integer(K),
    n_concurrent_ctrl = integer(K),
    rate_arm = numeric(K),
    rate_ctrl_concurrent = numeric(K),
    p_value = numeric(K),
    reject = logical(K),
    stringsAsFactors = FALSE
  )

  for (k in 1:K) {
    arm_periods <- enter[k]:leave[k]
    arm_d <- arm_data[[k]]
    ctrl_d <- ctrl_data[ctrl_data$period %in% arm_periods, ]
    n_a <- nrow(arm_d); n_c <- nrow(ctrl_d)
    arm_results$n_arm[k] <- n_a
    arm_results$n_concurrent_ctrl[k] <- n_c
    if (n_a == 0 || n_c == 0) {
      arm_results$p_value[k] <- NA
      arm_results$reject[k]  <- FALSE
      next
    }
    p_a <- mean(arm_d$response); p_c <- mean(ctrl_d$response)
    arm_results$rate_arm[k] <- round(p_a, 4)
    arm_results$rate_ctrl_concurrent[k] <- round(p_c, 4)
    # Pooled-variance Z-test, one-sided (arm > control).
    p_pool <- (sum(arm_d$response) + sum(ctrl_d$response)) / (n_a + n_c)
    se <- sqrt(p_pool * (1 - p_pool) * (1 / n_a + 1 / n_c))
    z  <- if (se > 0) (p_a - p_c) / se else 0
    arm_results$p_value[k] <- round(1 - pnorm(z), 6)
    arm_results$reject[k]  <- !is.na(arm_results$p_value[k]) &&
                              arm_results$p_value[k] <= cfg$alpha
  }

  alloc_df <- as.data.frame(alloc_history)
  colnames(alloc_df) <- c(paste0("arm_", 1:K), "control")
  alloc_df$period <- 1:n_periods

  list(arm_results = arm_results, alloc_df = alloc_df)
}

# Aggregate across simulations and emit OC table.
run_platform <- function(cfg) {
  cat("Method: simple concurrent-control\n")
  cat("Periods:", cfg$n_periods, "| Arms:", cfg$n_subgroups, "\n")
  cat("--- Running simulation (N =", cfg$n_sims, ") ---\n")

  results <- simulation_harness(cfg, simulate_platform_simple)

  K <- cfg$n_subgroups
  reject_matrix <- do.call(rbind, lapply(results, function(r) r$arm_results$reject))
  rate_matrix   <- do.call(rbind, lapply(results, function(r) r$arm_results$rate_arm))

  per_arm_reject <- colMeans(reject_matrix)
  true_active <- cfg$alt_params != cfg$null_params

  arm_summary <- data.frame(
    arm = 1:K,
    null_param = cfg$null_params,
    alt_param = cfg$alt_params,
    truly_active = true_active,
    reject_rate = round(per_arm_reject * 100, 1),
    mean_rate = round(colMeans(rate_matrix), 4),
    stringsAsFactors = FALSE
  )

  fwer <- compute_fwer(reject_matrix, !true_active)
  oc_table <- data.frame(
    metric = c("FWER under any null arm (%)",
               "1-minimum power across active arms (%)"),
    value = c(round(ifelse(is.na(fwer), 0, fwer) * 100, 2),
              round(compute_power_disjunctive(reject_matrix, true_active) * 100, 1)),
    stringsAsFactors = FALSE
  )

  # alloc_df is identical in shape across sims; use the first.
  list(
    arm_results = arm_summary,
    oc_table    = oc_table,
    alloc_df    = results[[1]]$alloc_df
  )
}

cat("platform_simple.R loaded.\n")
