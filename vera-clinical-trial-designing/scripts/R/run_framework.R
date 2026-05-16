###############################################################################
# run_framework.R
# Master entry point for sample size calculation.
#
# Public scope:
#   - Sample size table across alpha/power grid
#   - Power curve plot (PDF)
#   - CSV output for the sample size table
#
# Callers must source config.R and sample_size.R before this file. See
# scripts/R/example_minimal.R for the canonical sourcing order.
###############################################################################

#' Compute sample sizes across the configured alpha/power grid
#'
#' @param config A ss_config from create_config()
#' @return data.frame with columns: design, test, alpha, power_target,
#'         n_total, n_trt, n_ctrl, power_achieved, k_crit
compute_sample_size <- function(config) {
  results <- data.frame()

  for (a in config$alphas) {
    for (pwr in config$powers) {

      if (config$endpoint_type == "binary") {
        p0 <- config$null_param; p1 <- config$alt_param

        sa <- ss_binomial_single_arm(p0, p1, alpha = a, power = pwr)
        results <- rbind(results, data.frame(
          design = "single_arm", test = "exact_binomial",
          alpha = a, power_target = pwr,
          n_total = sa$n, n_trt = sa$n, n_ctrl = NA,
          power_achieved = sa$power, k_crit = sa$k_crit,
          stringsAsFactors = FALSE))

        if (config$design == "controlled") {
          zu <- ss_z_unpooled(p0, p1, a, pwr)
          results <- rbind(results, data.frame(
            design = "controlled", test = "z_unpooled",
            alpha = a, power_target = pwr,
            n_total = zu$n_total, n_trt = zu$n_trt, n_ctrl = zu$n_ctrl,
            power_achieved = zu$power, k_crit = NA,
            stringsAsFactors = FALSE))
        }

      } else if (config$endpoint_type == "continuous") {
        delta <- config$alt_param - config$null_param

        sa <- ss_ttest_single_arm(delta, config$sd, a, pwr)
        results <- rbind(results, data.frame(
          design = "single_arm", test = "one_sample_t",
          alpha = a, power_target = pwr,
          n_total = sa$n, n_trt = sa$n, n_ctrl = NA,
          power_achieved = pwr, k_crit = NA,
          stringsAsFactors = FALSE))

        if (config$design == "controlled") {
          ta <- ss_ttest_two_arm(delta, config$sd, a, pwr)
          results <- rbind(results, data.frame(
            design = "controlled", test = "two_sample_t",
            alpha = a, power_target = pwr,
            n_total = ta$n_total, n_trt = ta$n_trt, n_ctrl = ta$n_ctrl,
            power_achieved = pwr, k_crit = NA,
            stringsAsFactors = FALSE))
        }

      } else if (config$endpoint_type == "tte") {
        lam0 <- config$null_param; lam1 <- config$alt_param
        acr <- config$accrual_time; fu <- config$followup_time

        sa <- ss_logrank_single_arm(lam0, lam1, acr, fu, a, pwr)
        results <- rbind(results, data.frame(
          design = "single_arm", test = "exponential_rate",
          alpha = a, power_target = pwr,
          n_total = sa$n, n_trt = sa$n, n_ctrl = NA,
          power_achieved = sa$power, k_crit = sa$events,
          stringsAsFactors = FALSE))

        if (config$design == "controlled") {
          lr <- ss_logrank_two_arm(lam0, lam1, acr, fu, a, pwr)
          results <- rbind(results, data.frame(
            design = "controlled", test = "logrank",
            alpha = a, power_target = pwr,
            n_total = lr$n_total, n_trt = lr$n_trt, n_ctrl = lr$n_ctrl,
            power_achieved = lr$power, k_crit = lr$events,
            stringsAsFactors = FALSE))
        }
      }
    }
  }

  results$label <- config$label
  return(results)
}

#' Run the sample size calculation
#'
#' @param config        A ss_config object
#' @param output_dir    If provided, save CSV + PDF to this directory
#' @return list with sample_size table and config
run_sample_size_framework <- function(config, output_dir = NULL) {
  stopifnot(inherits(config, "ss_config"))
  cat("\n=== Sample Size Framework ===\n")
  print(config)

  cat("\n--- Sample Size Calculations ---\n")
  ss <- compute_sample_size(config)
  print(ss[, c("design", "test", "alpha", "power_target", "n_total",
               "n_trt", "n_ctrl")], row.names = FALSE)

  results <- list(config = config, sample_size = ss)

  if (!is.null(output_dir)) {
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    cat("\n--- Saving Outputs ---\n")
    write.csv(ss, file.path(output_dir, "sample_size.csv"), row.names = FALSE)
    cat("  Saved: sample_size.csv\n")
    save_power_curve(config, output_dir)
  }

  cat("\n=== Done ===\n")
  return(invisible(results))
}

# =============================================================================
# Power curve plot — single endpoint, all configured alphas, range of N.
# =============================================================================

save_power_curve <- function(config, output_dir) {
  pdf(file.path(output_dir, "power_curve.pdf"), width = 8, height = 6)
  on.exit(dev.off())
  colors <- c("darkred", "steelblue", "darkgreen", "purple")

  if (config$endpoint_type == "binary") {
    ns <- 5:200
    p0 <- config$null_param; p1 <- config$alt_param

    pwr_list <- lapply(config$alphas, function(a) {
      if (config$design == "single_arm") {
        sapply(ns, function(n) power_binomial_single_arm(n, p0, p1, a))
      } else {
        sapply(ns, function(n) power_z_unpooled(ceiling(n / 2), p0, p1, a))
      }
    })

    plot(ns, pwr_list[[1]], type = "l", lwd = 2.5, col = colors[1],
         xlab = if (config$design == "single_arm") "N" else "N total",
         ylab = "Power",
         main = paste0(config$label, " (H0=", p0, ", H1=", p1, ")"),
         ylim = c(0, 1))
    for (i in seq_along(config$alphas)[-1]) {
      lines(ns, pwr_list[[i]], lwd = 2.5, col = colors[min(i, 4)])
    }
    abline(h = config$powers, lty = 2, col = "gray50")
    legend("bottomright",
           legend = paste0("alpha=", config$alphas),
           col = colors[seq_along(config$alphas)], lwd = 2.5, cex = 0.8)

  } else if (config$endpoint_type == "continuous") {
    ns <- 10:300
    delta <- config$alt_param - config$null_param

    pwr_list <- lapply(config$alphas, function(a) {
      if (config$design == "single_arm") {
        sapply(ns, function(n) power_ttest_single_arm(n, delta, config$sd, a))
      } else {
        sapply(ns, function(n) power_ttest_two_arm(ceiling(n / 2), delta, config$sd, a))
      }
    })

    plot(ns, pwr_list[[1]], type = "l", lwd = 2.5, col = colors[1],
         xlab = if (config$design == "single_arm") "N" else "N total",
         ylab = "Power",
         main = paste0(config$label, " (delta=", round(delta, 3), ", SD=", config$sd, ")"),
         ylim = c(0, 1))
    for (i in seq_along(config$alphas)[-1]) {
      lines(ns, pwr_list[[i]], lwd = 2.5, col = colors[min(i, 4)])
    }
    abline(h = config$powers, lty = 2, col = "gray50")
    legend("bottomright",
           legend = paste0("alpha=", config$alphas),
           col = colors[seq_along(config$alphas)], lwd = 2.5, cex = 0.8)

  } else if (config$endpoint_type == "tte") {
    ns <- seq(20, 500, by = 10)
    lam0 <- config$null_param; lam1 <- config$alt_param
    acr <- config$accrual_time; fu <- config$followup_time

    pwr_list <- lapply(config$alphas, function(a) {
      if (config$design == "single_arm") {
        sapply(ns, function(n) power_logrank_single_arm(n, lam0, lam1, acr, fu, a))
      } else {
        sapply(ns, function(n) power_logrank_two_arm(ceiling(n / 2), lam0, lam1, acr, fu, a))
      }
    })

    plot(ns, pwr_list[[1]], type = "l", lwd = 2.5, col = colors[1],
         xlab = if (config$design == "single_arm") "N" else "N total",
         ylab = "Power",
         main = paste0(config$label, " (HR=", round(lam1 / lam0, 3), ")"),
         ylim = c(0, 1))
    for (i in seq_along(config$alphas)[-1]) {
      lines(ns, pwr_list[[i]], lwd = 2.5, col = colors[min(i, 4)])
    }
    abline(h = config$powers, lty = 2, col = "gray50")
    legend("bottomright",
           legend = paste0("alpha=", config$alphas),
           col = colors[seq_along(config$alphas)], lwd = 2.5, cex = 0.8)
  }
  cat("  Saved: power_curve.pdf\n")
}

cat("run_framework.R loaded.\n")
