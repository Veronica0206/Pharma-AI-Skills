###############################################################################
# run_master_framework.R -- Master entry point for the public release.
#
# Public scope:
#   - basket: dispatch to run_basket() with method 'none' or 'complete'
#   - umbrella: dispatch to run_umbrella_mams()
#   - platform: dispatch to run_platform() (simple concurrent control)
###############################################################################

run_master_framework <- function(cfg) {
  stopifnot(inherits(cfg, "master_config"))

  cat("=== Master Protocol Design Framework ===\n")
  cat("Design type:", cfg$master_design_type, "\n")
  cat("Endpoint:", cfg$endpoint_type, "\n")
  cat("Subgroups/Arms:", cfg$n_subgroups, "\n")

  dir.create(cfg$output_dir, recursive = TRUE, showWarnings = FALSE)

  result <- switch(cfg$master_design_type,
    basket   = run_basket(cfg),
    umbrella = run_umbrella(cfg),
    platform = {
      res <- run_platform(cfg)
      save_platform_outputs(cfg, res)
      res
    },
    stop("Unknown design type: ", cfg$master_design_type)
  )

  cat("=== Done ===\n")
  invisible(result)
}

# --- Basket runner ---

run_basket <- function(cfg) {
  cat("Method:", cfg$borrowing_method, "\n")
  cat("N per subgroup:", cfg$n_per_subgroup, "\n")
  cat("--- Running simulation (N =", cfg$n_sims, ") ---\n")

  results <- simulation_harness(cfg, run_basket_single)
  K <- cfg$n_subgroups

  decision_matrix <- do.call(rbind, lapply(results, function(r) r$decision == "Go"))
  estimate_matrix <- do.call(rbind, lapply(results, function(r) r$estimate))

  true_active <- cfg$alt_params > cfg$null_params
  true_null   <- !true_active

  per_arm_reject <- colMeans(decision_matrix)
  fwer <- compute_fwer(decision_matrix, true_null)

  oc_table <- data.frame(
    subgroup = 1:K,
    null_param = cfg$null_params,
    alt_param = cfg$alt_params,
    truly_active = true_active,
    reject_rate = round(per_arm_reject * 100, 1),
    mean_estimate = round(colMeans(estimate_matrix), 4),
    stringsAsFactors = FALSE
  )

  fwer_table <- data.frame(
    scenario = "Global null",
    fwer = round(ifelse(is.na(fwer), 0, fwer) * 100, 2),
    stringsAsFactors = FALSE
  )

  cat("--- Generating outputs ---\n")
  save_csv(oc_table, "basket_oc_table.csv", cfg$output_dir)
  save_csv(fwer_table, "basket_fwer.csv", cfg$output_dir)
  save_csv(results[[1]], "basket_subgroup_decisions.csv", cfg$output_dir)

  save_pdf_plot(function() {
    barplot(per_arm_reject * 100, names.arg = paste("Subgroup", 1:K),
            main = paste0("Per-Subgroup Rejection Rate (%) - method: ", cfg$borrowing_method),
            ylab = "Rejection Rate (%)",
            col = ifelse(true_active, "steelblue", "gray70"),
            ylim = c(0, 100))
    abline(h = cfg$alpha * 100, lty = 2, col = "red")
    legend("topright", c("Truly active", "Truly null", "Alpha"),
           fill = c("steelblue", "gray70", NA), border = NA,
           lty = c(NA, NA, 2), col = c(NA, NA, "red"))
  }, "basket_oc_curves.pdf", cfg$output_dir)

  save_pdf_plot(function() {
    boxplot(estimate_matrix, names = paste("Subgroup", 1:K),
            main = "Treatment Effect Estimates",
            ylab = "Estimate", col = ifelse(true_active, "steelblue", "gray70"))
    points(1:K, cfg$alt_params, pch = 4, cex = 1.5, col = "red", lwd = 2)
    legend("topright", c("True effect"), pch = 4, col = "red")
  }, "basket_forest_plot.pdf", cfg$output_dir)

  list(oc_table = oc_table, fwer_table = fwer_table)
}

# --- Umbrella runner (MAMS only in public scope) ---

run_umbrella <- function(cfg) {
  cat("Method:", cfg$umbrella_method, "\n")
  cat("Stages:", cfg$n_stages, "\n")

  result <- run_umbrella_mams(cfg)

  cat("--- Generating outputs ---\n")
  save_csv(result$oc_table, "umbrella_power_table.csv", cfg$output_dir)
  if (!is.null(result$power_table)) {
    save_csv(result$power_table, "umbrella_oc_summary.csv", cfg$output_dir)
  }
  if (!is.null(result$sample_size_table)) {
    save_csv(result$sample_size_table, "umbrella_sample_size.csv", cfg$output_dir)
  }

  sd_val <- if (!is.null(cfg$sd)) cfg$sd else 1
  bounds <- umbrella_mams_boundaries(cfg$n_arms, cfg$n_stages, cfg$alpha, sd = sd_val)
  bounds_df <- data.frame(
    stage = seq_along(bounds$futility),
    futility_boundary = round(bounds$futility, 4),
    efficacy_boundary = round(bounds$efficacy, 4),
    source = bounds$source,
    stringsAsFactors = FALSE
  )
  save_csv(bounds_df, "umbrella_boundaries.csv", cfg$output_dir)

  K <- cfg$n_arms
  true_active <- cfg$alt_params != cfg$null_params[1:K]

  save_pdf_plot(function() {
    per_arm <- result$oc_table$per_arm_power
    barplot(per_arm, names.arg = paste("Arm", 1:K),
            main = "Per-Arm Power (%)", ylab = "Power (%)",
            col = ifelse(true_active, "steelblue", "gray70"),
            ylim = c(0, 100))
    abline(h = cfg$alpha * 100, lty = 2, col = "red")
  }, "umbrella_arm_comparison.pdf", cfg$output_dir)

  save_pdf_plot(function() {
    J <- cfg$n_stages
    eff_finite <- bounds_df$efficacy_boundary[is.finite(bounds_df$efficacy_boundary)]
    yr <- range(c(bounds_df$futility_boundary, eff_finite, qnorm(1 - cfg$alpha)))
    plot(1:J, bounds_df$futility_boundary, type = "b", pch = 19, col = "red3",
         lwd = 2, ylim = yr,
         xlab = "Stage", ylab = "Z-statistic boundary",
         main = "MAMS Stage-wise Boundaries")
    if (any(is.finite(bounds_df$efficacy_boundary))) {
      lines(1:J, bounds_df$efficacy_boundary, type = "b", pch = 17, col = "green4", lwd = 2)
      legend("topleft", c("Futility", "Efficacy"), col = c("red3", "green4"),
             pch = c(19, 17), lwd = 2)
    } else {
      legend("topleft", "Futility", col = "red3", pch = 19, lwd = 2)
    }
  }, "umbrella_boundary_plot.pdf", cfg$output_dir)

  result
}

# --- Platform output saver ---

save_platform_outputs <- function(cfg, result) {
  cat("--- Generating platform outputs ---\n")
  K <- cfg$n_subgroups

  save_csv(result$arm_results, "platform_arm_results.csv", cfg$output_dir)
  save_csv(result$oc_table, "platform_oc_table.csv", cfg$output_dir)
  save_csv(result$alloc_df, "platform_allocation.csv", cfg$output_dir)

  save_pdf_plot(function() {
    plot(NULL, xlim = c(1, cfg$n_periods), ylim = c(0.5, K + 0.5),
         xlab = "Period", ylab = "Arm", main = "Platform Trial Timeline",
         yaxt = "n")
    axis(2, at = 1:K, labels = paste("Arm", 1:K))
    colors <- ifelse(cfg$alt_params != cfg$null_params, "steelblue", "gray70")
    for (k in 1:K) {
      rect(cfg$arms_schedule$enter[k] - 0.4, k - 0.3,
           cfg$arms_schedule$leave[k] + 0.4, k + 0.3,
           col = colors[k], border = "black")
    }
    legend("topright", c("Truly active arm", "Null arm"),
           fill = c("steelblue", "gray70"))
  }, "platform_timeline.pdf", cfg$output_dir)

  save_pdf_plot(function() {
    reject_rates <- result$arm_results$reject_rate
    barplot(reject_rates, names.arg = paste("Arm", 1:K),
            main = "Per-Arm Rejection Rate (%)", ylab = "Rate (%)",
            col = ifelse(cfg$alt_params != cfg$null_params, "steelblue", "gray70"),
            ylim = c(0, 100))
    abline(h = cfg$alpha * 100, lty = 2, col = "red")
  }, "platform_oc_curves.pdf", cfg$output_dir)
}
