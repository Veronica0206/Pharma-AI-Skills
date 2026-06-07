###############################################################################
# meta_analysis.R
# Public base R framework for clinical binary endpoint meta-analysis.
###############################################################################

inv_logit <- function(x) 1 / (1 + exp(-x))

logit <- function(p) log(p / (1 - p))

normalize_arm_type <- function(x) {
  y <- tolower(trimws(as.character(x)))
  y <- gsub("[^a-z0-9]+", "_", y)
  y <- gsub("^_|_$", "", y)
  y
}

required_columns <- function() {
  c("study_id", "study", "year", "population", "endpoint",
    "endpoint_definition", "timing", "arm", "arm_type", "responders", "total",
    "count_status", "source")
}

read_endpoint_counts <- function(input_csv) {
  dat <- read.csv(input_csv, stringsAsFactors = FALSE, check.names = FALSE)
  missing <- setdiff(required_columns(), names(dat))
  if (length(missing) > 0) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }

  dat$responders <- as.numeric(dat$responders)
  dat$total <- as.numeric(dat$total)
  dat$year <- suppressWarnings(as.integer(dat$year))
  dat$arm_type <- normalize_arm_type(dat$arm_type)

  bad <- is.na(dat$responders) | is.na(dat$total) |
    dat$total <= 0 | dat$responders < 0 | dat$responders > dat$total
  if (any(bad)) {
    stop("Invalid responders/total values in row(s): ",
         paste(which(bad), collapse = ", "))
  }

  dat
}

filter_counts <- function(dat, endpoint_filter = NULL, timing_filter = NULL) {
  out <- dat
  if (!is.null(endpoint_filter)) {
    keep <- grepl(endpoint_filter, out$endpoint, ignore.case = TRUE) |
      grepl(endpoint_filter, out$endpoint_definition, ignore.case = TRUE)
    out <- out[keep, , drop = FALSE]
  }
  if (!is.null(timing_filter)) {
    keep <- grepl(timing_filter, out$timing, ignore.case = TRUE)
    out <- out[keep, , drop = FALSE]
  }
  if (nrow(out) == 0) stop("No rows remain after filtering.")
  out
}

definition_audit <- function(dat) {
  key <- paste(dat$endpoint, dat$endpoint_definition, dat$timing, dat$population,
               sep = " | ")
  tab <- as.data.frame(table(key), stringsAsFactors = FALSE)
  names(tab) <- c("definition_key", "n_rows")
  tab
}

logit_inputs <- function(x, n) {
  x_adj <- x
  n_adj <- n
  extreme <- x == 0 | x == n
  x_adj[extreme] <- x_adj[extreme] + 0.5
  n_adj[extreme] <- n_adj[extreme] + 1
  p <- x_adj / n_adj
  data.frame(
    yi = logit(p),
    vi = 1 / x_adj + 1 / (n_adj - x_adj),
    adjusted = extreme
  )
}

meta_iv <- function(yi, vi, alpha = 0.05) {
  ok <- is.finite(yi) & is.finite(vi) & vi > 0
  yi <- yi[ok]
  vi <- vi[ok]
  if (length(yi) == 0) stop("No finite effect estimates available.")

  wi <- 1 / vi
  fixed <- sum(wi * yi) / sum(wi)
  q <- sum(wi * (yi - fixed)^2)
  df <- length(yi) - 1
  cval <- sum(wi) - sum(wi^2) / sum(wi)
  tau2 <- if (df > 0 && cval > 0) max(0, (q - df) / cval) else 0
  wr <- 1 / (vi + tau2)
  est <- sum(wr * yi) / sum(wr)
  se <- sqrt(1 / sum(wr))
  z <- qnorm(1 - alpha / 2)

  data.frame(
    k = length(yi),
    estimate = est,
    se = se,
    lower = est - z * se,
    upper = est + z * se,
    tau2 = tau2,
    q = q,
    i2 = if (df > 0 && q > 0) 100 * max(0, (q - df) / q) else NA_real_,
    stringsAsFactors = FALSE
  )
}

pool_rates_by_arm <- function(dat, alpha = 0.05) {
  groups <- split(dat, dat$arm_type)
  rows <- lapply(names(groups), function(arm_type) {
    g <- groups[[arm_type]]
    inp <- logit_inputs(g$responders, g$total)
    pooled <- meta_iv(inp$yi, inp$vi, alpha = alpha)
    pooled$arm_type <- arm_type
    pooled$total_n <- sum(g$total)
    pooled$total_responders <- sum(g$responders)
    pooled$rate <- inv_logit(pooled$estimate)
    pooled$lower_rate <- inv_logit(pooled$lower)
    pooled$upper_rate <- inv_logit(pooled$upper)
    pooled$continuity_adjusted_rows <- sum(inp$adjusted)
    pooled
  })
  out <- do.call(rbind, rows)
  keep <- c("arm_type", "k", "total_responders", "total_n", "rate",
            "lower_rate", "upper_rate", "estimate", "se", "tau2", "q", "i2",
            "continuity_adjusted_rows")
  out[keep]
}

choose_control_row <- function(g) {
  control_types <- c("placebo", "control", "standard_of_care", "soc",
                     "active_control")
  idx <- which(g$arm_type %in% control_types)
  if (length(idx) == 0) return(NULL)
  g[idx[1], , drop = FALSE]
}

paired_study_effects <- function(dat) {
  groups <- split(dat, paste(dat$study_id, dat$endpoint, dat$timing, sep = " | "))
  rows <- list()

  for (key in names(groups)) {
    g <- groups[[key]]
    ctrl <- choose_control_row(g)
    if (is.null(ctrl)) next
    trt <- g[!(g$arm_type %in% c("placebo", "control", "standard_of_care",
                                 "soc", "active_control")), , drop = FALSE]
    if (nrow(trt) == 0) next

    for (i in seq_len(nrow(trt))) {
      trow <- trt[i, , drop = FALSE]
      pt <- trow$responders / trow$total
      pc <- ctrl$responders / ctrl$total

      rd <- pt - pc
      rd_vi <- pt * (1 - pt) / trow$total + pc * (1 - pc) / ctrl$total

      xt <- trow$responders
      nt <- trow$total
      xc <- ctrl$responders
      nc <- ctrl$total
      if (xt == 0 || xt == nt || xc == 0 || xc == nc) {
        xt <- xt + 0.5
        xc <- xc + 0.5
        nt <- nt + 1
        nc <- nc + 1
      }
      rr <- log((xt / nt) / (xc / nc))
      rr_vi <- 1 / xt - 1 / nt + 1 / xc - 1 / nc

      rows[[length(rows) + 1]] <- data.frame(
        study_id = trow$study_id,
        study = trow$study,
        endpoint = trow$endpoint,
        timing = trow$timing,
        treatment_arm = trow$arm,
        control_arm = ctrl$arm,
        treatment_type = trow$arm_type,
        control_type = ctrl$arm_type,
        treatment_responders = trow$responders,
        treatment_total = trow$total,
        control_responders = ctrl$responders,
        control_total = ctrl$total,
        risk_difference = rd,
        risk_difference_vi = rd_vi,
        log_risk_ratio = rr,
        log_risk_ratio_vi = rr_vi,
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(rows) == 0) {
    return(data.frame())
  }
  do.call(rbind, rows)
}

pool_paired_effects <- function(effects, alpha = 0.05) {
  if (nrow(effects) == 0) return(data.frame())

  rd <- meta_iv(effects$risk_difference, effects$risk_difference_vi, alpha = alpha)
  rr <- meta_iv(effects$log_risk_ratio, effects$log_risk_ratio_vi, alpha = alpha)

  data.frame(
    measure = c("risk_difference", "risk_ratio"),
    k = c(rd$k, rr$k),
    estimate = c(rd$estimate, exp(rr$estimate)),
    lower = c(rd$lower, exp(rr$lower)),
    upper = c(rd$upper, exp(rr$upper)),
    se = c(rd$se, rr$se),
    tau2 = c(rd$tau2, rr$tau2),
    q = c(rd$q, rr$q),
    i2 = c(rd$i2, rr$i2),
    stringsAsFactors = FALSE
  )
}

plot_rate_forest <- function(dat, output_file) {
  pdf(output_file, width = 8, height = max(5, 0.35 * nrow(dat) + 2))

  rate <- dat$responders / dat$total
  se <- sqrt(pmax(rate * (1 - rate) / dat$total, 1e-8))
  lower <- pmax(0, rate - 1.96 * se)
  upper <- pmin(1, rate + 1.96 * se)
  y <- seq_len(nrow(dat))
  labels <- paste(dat$study, dat$arm, paste0(dat$responders, "/", dat$total),
                  sep = " - ")

  old <- par(mar = c(4, 12, 3, 2))
  on.exit({
    par(old)
    dev.off()
  })
  plot(rate, y, xlim = c(0, 1), yaxt = "n", xlab = "Observed rate",
       ylab = "", pch = 19, main = "Study-arm rates")
  segments(lower, y, upper, y)
  axis(2, at = y, labels = labels, las = 2, cex.axis = 0.7)
  grid(nx = NULL, ny = NA)
}

plot_effect_forest <- function(effects, output_file) {
  if (nrow(effects) == 0) return(invisible(NULL))
  pdf(output_file, width = 8, height = max(5, 0.35 * nrow(effects) + 2))

  rd <- effects$risk_difference
  se <- sqrt(effects$risk_difference_vi)
  lower <- rd - 1.96 * se
  upper <- rd + 1.96 * se
  y <- seq_len(nrow(effects))
  labels <- paste(effects$study, effects$treatment_arm, "vs",
                  effects$control_arm)

  old <- par(mar = c(4, 12, 3, 2))
  on.exit({
    par(old)
    dev.off()
  })
  plot(rd, y, xlim = range(c(lower, upper, 0), na.rm = TRUE), yaxt = "n",
       xlab = "Risk difference", ylab = "", pch = 19,
       main = "Paired treatment-control effects")
  abline(v = 0, lty = 2, col = "gray50")
  segments(lower, y, upper, y)
  axis(2, at = y, labels = labels, las = 2, cex.axis = 0.7)
  grid(nx = NULL, ny = NA)
}

make_design_benchmarks <- function(pooled_rates, pooled_effects) {
  out <- pooled_rates[, c("arm_type", "k", "rate", "lower_rate", "upper_rate",
                          "i2")]
  names(out) <- c("benchmark_role", "k", "estimate", "lower", "upper", "i2")
  out$recommended_use <- ifelse(
    out$benchmark_role %in% c("placebo", "control", "standard_of_care", "soc"),
    "single-arm null_param or expected control rate",
    ifelse(out$benchmark_role == "active_control",
           "expected active-control rate",
           "candidate alt_param or treatment target")
  )
  if (nrow(pooled_effects) > 0) {
    effects <- data.frame(
      benchmark_role = paste0("paired_", pooled_effects$measure),
      k = pooled_effects$k,
      estimate = pooled_effects$estimate,
      lower = pooled_effects$lower,
      upper = pooled_effects$upper,
      i2 = pooled_effects$i2,
      recommended_use = "clinically meaningful treatment-control effect",
      stringsAsFactors = FALSE
    )
    out <- rbind(out, effects)
  }
  out
}

run_meta_analysis <- function(input_csv,
                              output_dir = "outputs/meta_analysis",
                              endpoint_filter = NULL,
                              timing_filter = NULL,
                              alpha = 0.05) {
  dat <- read_endpoint_counts(input_csv)
  dat <- filter_counts(dat, endpoint_filter, timing_filter)

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  audit <- definition_audit(dat)
  pooled_rates <- pool_rates_by_arm(dat, alpha = alpha)
  effects <- paired_study_effects(dat)
  pooled_effects <- pool_paired_effects(effects, alpha = alpha)
  benchmarks <- make_design_benchmarks(pooled_rates, pooled_effects)

  write.csv(dat, file.path(output_dir, "cleaned_counts.csv"), row.names = FALSE)
  write.csv(audit, file.path(output_dir, "definition_audit.csv"), row.names = FALSE)
  write.csv(pooled_rates, file.path(output_dir, "pooled_arm_rates.csv"),
            row.names = FALSE)
  write.csv(benchmarks, file.path(output_dir, "design_benchmarks.csv"),
            row.names = FALSE)
  if (nrow(effects) > 0) {
    write.csv(effects, file.path(output_dir, "study_level_effects.csv"),
              row.names = FALSE)
    write.csv(pooled_effects, file.path(output_dir, "paired_effects.csv"),
              row.names = FALSE)
  }

  plot_rate_forest(dat, file.path(output_dir, "forest_rates.pdf"))
  if (nrow(effects) > 0) {
    plot_effect_forest(effects, file.path(output_dir, "forest_effects.pdf"))
  }

  cat("Meta-analysis complete. Outputs written to:", normalizePath(output_dir), "\n")
  invisible(list(
    counts = dat,
    definition_audit = audit,
    pooled_arm_rates = pooled_rates,
    study_level_effects = effects,
    paired_effects = pooled_effects,
    design_benchmarks = benchmarks
  ))
}
