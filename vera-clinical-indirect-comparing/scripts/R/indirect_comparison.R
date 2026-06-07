###############################################################################
# indirect_comparison.R
# Public base R framework for binary/continuous Bucher and MAIC comparisons.
###############################################################################

inv_logit <- function(x) 1 / (1 + exp(-x))

trim_label <- function(x) trimws(as.character(x))

format_available_labels <- function(values) {
  paste(sort(unique(trim_label(values))), collapse = ", ")
}

case_sensitive_label_hint <- function(requested, values) {
  values <- sort(unique(trim_label(values)))
  matched <- values[tolower(values) == tolower(trim_label(requested))]
  if (length(matched) > 0 && !trim_label(requested) %in% values) {
    paste0(" Did you mean exact label '", matched[1],
           "'? Labels are case-sensitive.")
  } else {
    ""
  }
}

validate_label_value <- function(values, requested, role) {
  values <- trim_label(values)
  requested <- trim_label(requested)
  if (!requested %in% values) {
    stop(role, " '", requested, "' not found. Available values: ",
         format_available_labels(values), ".",
         case_sensitive_label_hint(requested, values))
  }
  requested
}

is_log_scale <- function(scale) {
  grepl("^log_", trim_label(scale))
}

z_value <- function(alpha) qnorm(1 - alpha / 2)

natural_scale <- function(estimate, scale) {
  if (is_log_scale(scale)) exp(estimate) else estimate
}

required_direct_effect_columns <- function() {
  c("comparison_id", "treatment", "comparator", "effect_measure",
    "analysis_scale", "estimate", "se", "source")
}

read_direct_effects <- function(input_csv) {
  dat <- read.csv(input_csv, stringsAsFactors = FALSE, check.names = FALSE)
  missing <- setdiff(required_direct_effect_columns(), names(dat))
  if (length(missing) > 0) {
    stop("Missing required direct-effect columns: ",
         paste(missing, collapse = ", "))
  }

  dat$treatment <- trim_label(dat$treatment)
  dat$comparator <- trim_label(dat$comparator)
  dat$effect_measure <- trim_label(dat$effect_measure)
  dat$analysis_scale <- trim_label(dat$analysis_scale)
  dat$estimate <- as.numeric(dat$estimate)
  dat$se <- as.numeric(dat$se)

  bad <- is.na(dat$estimate) | is.na(dat$se) | dat$se <= 0
  if (any(bad)) {
    stop("Invalid estimate/se values in row(s): ",
         paste(which(bad), collapse = ", "))
  }

  dat
}

first_nonmissing_number <- function(row, col_names) {
  for (name in col_names) {
    if (name %in% names(row)) {
      value <- suppressWarnings(as.numeric(row[[name]][1]))
      if (!is.na(value)) return(value)
    }
  }
  NA_real_
}

required_endpoint_columns <- function() {
  c("comparison_id", "treatment", "comparator", "endpoint_type",
    "effect_measure", "source")
}

read_endpoint_contrasts <- function(input_csv) {
  dat <- read.csv(input_csv, stringsAsFactors = FALSE, check.names = FALSE)
  missing <- setdiff(required_endpoint_columns(), names(dat))
  if (length(missing) > 0) {
    stop("Missing required endpoint contrast columns: ",
         paste(missing, collapse = ", "))
  }
  dat$comparison_id <- trim_label(dat$comparison_id)
  dat$treatment <- trim_label(dat$treatment)
  dat$comparator <- trim_label(dat$comparator)
  dat$endpoint_type <- tolower(trim_label(dat$endpoint_type))
  dat$effect_measure <- trim_label(dat$effect_measure)
  dat$source <- trim_label(dat$source)
  dat
}

make_direct_effect_row <- function(comparison_id, treatment, comparator,
                                   effect_measure, analysis_scale, estimate,
                                   se, source, endpoint_type, note = "") {
  if (!is.finite(estimate) || !is.finite(se) || se <= 0) {
    stop("Invalid effect estimate or SE for comparison ", comparison_id)
  }
  data.frame(
    comparison_id = comparison_id,
    treatment = treatment,
    comparator = comparator,
    effect_measure = effect_measure,
    analysis_scale = analysis_scale,
    estimate = estimate,
    se = se,
    source = source,
    endpoint_type = endpoint_type,
    derivation_note = note,
    stringsAsFactors = FALSE
  )
}

continuity_binary_counts <- function(events_t, total_t, events_c, total_c) {
  non_events_t <- total_t - events_t
  non_events_c <- total_c - events_c
  adjusted <- any(c(events_t, non_events_t, events_c, non_events_c) == 0)
  if (adjusted) {
    events_t <- events_t + 0.5
    non_events_t <- non_events_t + 0.5
    events_c <- events_c + 0.5
    non_events_c <- non_events_c + 0.5
    total_t <- events_t + non_events_t
    total_c <- events_c + non_events_c
  }
  list(events_t = events_t, total_t = total_t,
       events_c = events_c, total_c = total_c,
       non_events_t = non_events_t, non_events_c = non_events_c,
       adjusted = adjusted)
}

binary_contrast_from_row <- function(row, alpha = 0.05) {
  events_t <- first_nonmissing_number(row, c("treatment_events", "events_t"))
  total_t <- first_nonmissing_number(row, c("treatment_total", "total_t",
                                            "treatment_n", "n_t"))
  events_c <- first_nonmissing_number(row, c("comparator_events", "events_c"))
  total_c <- first_nonmissing_number(row, c("comparator_total", "total_c",
                                            "comparator_n", "n_c"))
  if (any(is.na(c(events_t, total_t, events_c, total_c)))) {
    stop("Binary endpoint requires treatment/comparator events and totals.")
  }
  if (events_t < 0 || events_c < 0 || total_t <= 0 || total_c <= 0 ||
      events_t > total_t || events_c > total_c) {
    stop("Invalid binary counts for comparison ", row$comparison_id[1])
  }

  measure <- trim_label(row$effect_measure[1])
  counts <- continuity_binary_counts(events_t, total_t, events_c, total_c)
  pt <- counts$events_t / counts$total_t
  pc <- counts$events_c / counts$total_c
  note <- if (counts$adjusted) "0.5 continuity correction applied" else ""

  if (measure %in% c("log_odds_ratio", "odds_ratio")) {
    estimate <- log((counts$events_t / counts$non_events_t) /
                      (counts$events_c / counts$non_events_c))
    se <- sqrt(1 / counts$events_t + 1 / counts$non_events_t +
                 1 / counts$events_c + 1 / counts$non_events_c)
    effect_measure <- "odds_ratio"
    analysis_scale <- "log_odds_ratio"
  } else if (measure %in% c("log_risk_ratio", "risk_ratio")) {
    estimate <- log(pt / pc)
    se <- sqrt(1 / counts$events_t - 1 / counts$total_t +
                 1 / counts$events_c - 1 / counts$total_c)
    effect_measure <- "risk_ratio"
    analysis_scale <- "log_risk_ratio"
  } else if (measure == "risk_difference") {
    estimate <- pt - pc
    se <- sqrt(pt * (1 - pt) / counts$total_t +
                 pc * (1 - pc) / counts$total_c)
    effect_measure <- "risk_difference"
    analysis_scale <- "risk_difference"
  } else {
    stop("Unsupported binary effect measure: ", measure)
  }

  make_direct_effect_row(row$comparison_id[1], row$treatment[1],
                         row$comparator[1], effect_measure, analysis_scale,
                         estimate, se, row$source[1], "binary", note)
}

continuous_contrast_from_row <- function(row) {
  mean_t <- first_nonmissing_number(row, c("treatment_mean", "mean_t"))
  sd_t <- first_nonmissing_number(row, c("treatment_sd", "sd_t"))
  n_t <- first_nonmissing_number(row, c("treatment_n", "n_t",
                                        "treatment_total", "total_t"))
  mean_c <- first_nonmissing_number(row, c("comparator_mean", "mean_c"))
  sd_c <- first_nonmissing_number(row, c("comparator_sd", "sd_c"))
  n_c <- first_nonmissing_number(row, c("comparator_n", "n_c",
                                        "comparator_total", "total_c"))
  if (any(is.na(c(mean_t, sd_t, n_t, mean_c, sd_c, n_c)))) {
    stop("Continuous endpoint requires arm means, SDs, and sample sizes.")
  }
  if (sd_t <= 0 || sd_c <= 0 || n_t <= 1 || n_c <= 1) {
    stop("Invalid continuous summary values for comparison ",
         row$comparison_id[1])
  }
  measure <- trim_label(row$effect_measure[1])
  if (!measure %in% c("mean_difference", "difference_in_means")) {
    stop("Unsupported continuous effect measure: ", measure)
  }
  estimate <- mean_t - mean_c
  se <- sqrt(sd_t^2 / n_t + sd_c^2 / n_c)
  make_direct_effect_row(row$comparison_id[1], row$treatment[1],
                         row$comparator[1], "mean_difference",
                         "mean_difference", estimate, se, row$source[1],
                         "continuous")
}


derive_direct_effects_from_endpoints <- function(input_csv,
                                                 output_csv = NULL,
                                                 alpha = 0.05) {
  dat <- read_endpoint_contrasts(input_csv)
  rows <- lapply(seq_len(nrow(dat)), function(i) {
    row <- dat[i, , drop = FALSE]
    endpoint_type <- row$endpoint_type[1]
    if (endpoint_type == "binary") {
      binary_contrast_from_row(row, alpha = alpha)
    } else if (endpoint_type == "continuous") {
      continuous_contrast_from_row(row)
    } else {
      stop("Unsupported endpoint_type in public release: ", endpoint_type,
           ". Use binary or continuous.")
    }
  })
  out <- do.call(rbind, rows)
  if (!is.null(output_csv)) {
    dir.create(dirname(output_csv), recursive = TRUE, showWarnings = FALSE)
    write.csv(out, output_csv, row.names = FALSE)
  }
  out
}

run_bucher_from_endpoints <- function(endpoint_csv,
                                      output_dir = "outputs/bucher",
                                      treatment_a,
                                      treatment_c,
                                      common_comparator,
                                      alpha = 0.05) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  direct_csv <- file.path(output_dir, "derived_direct_effects.csv")
  direct <- derive_direct_effects_from_endpoints(endpoint_csv, direct_csv,
                                                 alpha = alpha)
  direct_for_bucher <- direct[, required_direct_effect_columns()]
  temp_csv <- tempfile("derived_direct_effects_for_bucher_", fileext = ".csv")
  on.exit(unlink(temp_csv), add = TRUE)
  write.csv(direct_for_bucher, temp_csv, row.names = FALSE)
  run_bucher(temp_csv, output_dir, treatment_a, treatment_c,
             common_comparator, alpha = alpha)
}

run_bucher_chain_from_endpoints <- function(endpoint_csv,
                                            output_dir = "outputs/bucher_chain",
                                            treatment_a,
                                            treatment_b,
                                            via_treatment,
                                            alpha = 0.05) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  direct_csv <- file.path(output_dir, "derived_direct_effects.csv")
  direct <- derive_direct_effects_from_endpoints(endpoint_csv, direct_csv,
                                                 alpha = alpha)
  direct_for_bucher <- direct[, required_direct_effect_columns()]
  temp_csv <- tempfile("derived_direct_effects_for_bucher_chain_",
                       fileext = ".csv")
  on.exit(unlink(temp_csv), add = TRUE)
  write.csv(direct_for_bucher, temp_csv, row.names = FALSE)
  run_bucher_chain(temp_csv, output_dir, treatment_a, treatment_b,
                   via_treatment, alpha = alpha)
}

orient_contrast <- function(dat, treatment, comparator) {
  treatment <- trim_label(treatment)
  comparator <- trim_label(comparator)

  exact <- dat$treatment == treatment & dat$comparator == comparator
  reverse <- dat$treatment == comparator & dat$comparator == treatment

  if (sum(exact) == 1) {
    row <- dat[exact, , drop = FALSE]
    sign <- 1
    orientation <- "as_provided"
  } else if (sum(exact) > 1) {
    stop("Multiple exact contrasts found for ", treatment, " vs ", comparator)
  } else if (sum(reverse) == 1) {
    row <- dat[reverse, , drop = FALSE]
    sign <- -1
    orientation <- "reversed_from_source"
  } else if (sum(reverse) > 1) {
    stop("Multiple reversed contrasts found for ", treatment, " vs ", comparator)
  } else {
    available_pairs <- paste(dat$treatment, "vs", dat$comparator)
    stop("No contrast found for ", treatment, " vs ", comparator,
         ". Available contrasts: ", paste(sort(unique(available_pairs)),
                                          collapse = "; "), ".",
         case_sensitive_label_hint(treatment,
                                   c(dat$treatment, dat$comparator)),
         case_sensitive_label_hint(comparator,
                                   c(dat$treatment, dat$comparator)))
  }

  data.frame(
    comparison_id = row$comparison_id,
    treatment = treatment,
    comparator = comparator,
    effect_measure = row$effect_measure,
    analysis_scale = row$analysis_scale,
    estimate = sign * row$estimate,
    se = row$se,
    source = row$source,
    source_orientation = orientation,
    stringsAsFactors = FALSE
  )
}

check_compatible_effects <- function(effect_a, effect_b) {
  same_measure <- effect_a$effect_measure[1] == effect_b$effect_measure[1]
  same_scale <- effect_a$analysis_scale[1] == effect_b$analysis_scale[1]
  if (!same_measure || !same_scale) {
    stop("Effect measure and analysis scale must match. Got ",
         effect_a$effect_measure[1], "/", effect_a$analysis_scale[1],
         " and ",
         effect_b$effect_measure[1], "/", effect_b$analysis_scale[1], ".")
  }
}

effect_result_row <- function(method, contrast, treatment, comparator,
                              common_comparator, effect_measure, analysis_scale,
                              estimate, se, alpha = 0.05,
                              connection_role = "common_comparator") {
  z <- z_value(alpha)
  lower <- estimate - z * se
  upper <- estimate + z * se
  data.frame(
    method = method,
    contrast = contrast,
    treatment = treatment,
    comparator = comparator,
    common_comparator = common_comparator,
    connection_treatment = common_comparator,
    connection_role = connection_role,
    effect_measure = effect_measure,
    analysis_scale = analysis_scale,
    estimate = estimate,
    se = se,
    lower = lower,
    upper = upper,
    natural_estimate = natural_scale(estimate, analysis_scale),
    natural_lower = natural_scale(lower, analysis_scale),
    natural_upper = natural_scale(upper, analysis_scale),
    alpha = alpha,
    stringsAsFactors = FALSE
  )
}

combine_indirect <- function(effect_ab, effect_cb, treatment_a, treatment_c,
                             common_comparator, method, alpha = 0.05) {
  check_compatible_effects(effect_ab, effect_cb)
  estimate <- effect_ab$estimate[1] - effect_cb$estimate[1]
  se <- sqrt(effect_ab$se[1]^2 + effect_cb$se[1]^2)
  effect_result_row(
    method = method,
    contrast = paste(treatment_a, "vs", treatment_c),
    treatment = treatment_a,
    comparator = treatment_c,
    common_comparator = common_comparator,
    effect_measure = effect_ab$effect_measure[1],
    analysis_scale = effect_ab$analysis_scale[1],
    estimate = estimate,
    se = se,
    alpha = alpha,
    connection_role = "common_comparator"
  )
}

combine_indirect_chain <- function(effect_ac, effect_cb, treatment_a,
                                   treatment_b, via_treatment, method,
                                   alpha = 0.05) {
  check_compatible_effects(effect_ac, effect_cb)
  estimate <- effect_ac$estimate[1] + effect_cb$estimate[1]
  se <- sqrt(effect_ac$se[1]^2 + effect_cb$se[1]^2)
  effect_result_row(
    method = method,
    contrast = paste(treatment_a, "vs", treatment_b),
    treatment = treatment_a,
    comparator = treatment_b,
    common_comparator = via_treatment,
    effect_measure = effect_ac$effect_measure[1],
    analysis_scale = effect_ac$analysis_scale[1],
    estimate = estimate,
    se = se,
    alpha = alpha,
    connection_role = "via_treatment"
  )
}

bucher_assumption_audit <- function(effect_ab, effect_cb, result) {
  data.frame(
    item = c(
      "common_comparator",
      "effect_measure_match",
      "analysis_scale_match",
      "variance_rule",
      "similarity_assumption",
      "endpoint_timing_alignment",
      "unmeasured_effect_modifiers"
    ),
    status = c(
      result$common_comparator[1],
      as.character(effect_ab$effect_measure[1] == effect_cb$effect_measure[1]),
      as.character(effect_ab$analysis_scale[1] == effect_cb$analysis_scale[1]),
      "se_indirect = sqrt(se_ab^2 + se_cb^2)",
      "requires clinical review",
      "requires source review",
      "requires source review"
    ),
    note = c(
      "Both direct estimates must share this comparator.",
      "Checked by script before combining estimates.",
      "Checked by script before combining estimates.",
      "Assumes independent direct evidence sources.",
      "Trial populations and effect modifiers must be comparable.",
      "Endpoint definition and follow-up timing must align.",
      "MAIC/Bucher cannot adjust for unavailable or unmeasured modifiers."
    ),
    stringsAsFactors = FALSE
  )
}

bucher_chain_assumption_audit <- function(effect_ac, effect_cb, result) {
  data.frame(
    item = c(
      "via_treatment",
      "effect_measure_match",
      "analysis_scale_match",
      "orientation_formula",
      "variance_rule",
      "similarity_assumption",
      "endpoint_timing_alignment",
      "unmeasured_effect_modifiers"
    ),
    status = c(
      result$connection_treatment[1],
      as.character(effect_ac$effect_measure[1] == effect_cb$effect_measure[1]),
      as.character(effect_ac$analysis_scale[1] == effect_cb$analysis_scale[1]),
      "d_ab = d_ac + d_cb",
      "se_indirect = sqrt(se_ac^2 + se_cb^2)",
      "requires clinical review",
      "requires source review",
      "requires source review"
    ),
    note = c(
      "The via treatment connects the observed A vs C and C vs B contrasts.",
      "Checked by script before combining estimates.",
      "Checked by script before combining estimates.",
      "Use this orientation when the available evidence is A vs C and C vs B.",
      "Assumes independent direct evidence sources.",
      "Trial populations and effect modifiers must be comparable.",
      "Endpoint definition and follow-up timing must align.",
      "MAIC/Bucher cannot adjust for unavailable or unmeasured modifiers."
    ),
    stringsAsFactors = FALSE
  )
}

plot_comparison_forest <- function(rows, output_file, title) {
  if (nrow(rows) == 0) return(invisible(NULL))
  scale <- rows$analysis_scale[1]
  x_est <- natural_scale(rows$estimate, scale)
  x_low <- natural_scale(rows$lower, scale)
  x_high <- natural_scale(rows$upper, scale)
  null_value <- if (is_log_scale(scale)) 1 else 0
  y <- seq_len(nrow(rows))

  xlim <- range(c(x_low, x_high, null_value), na.rm = TRUE)
  pad <- diff(xlim) * 0.15
  if (!is.finite(pad) || pad == 0) pad <- 0.1
  xlim <- c(xlim[1] - pad, xlim[2] + pad)
  if (is_log_scale(scale)) xlim[1] <- max(xlim[1], .Machine$double.eps)

  pdf(output_file, width = 8, height = max(4, 0.45 * nrow(rows) + 2))
  old <- par(mar = c(4, 11, 3, 2))
  on.exit({
    par(old)
    dev.off()
  })

  plot(x_est, y, xlim = xlim, yaxt = "n", ylab = "", pch = 19,
       xlab = if (is_log_scale(scale)) "Natural ratio scale" else scale,
       main = title, log = if (is_log_scale(scale)) "x" else "")
  abline(v = null_value, lty = 2, col = "gray50")
  segments(x_low, y, x_high, y)
  axis(2, at = y, labels = rows$contrast, las = 2, cex.axis = 0.75)
  grid(nx = NULL, ny = NA)
}

run_bucher <- function(input_csv,
                       output_dir = "outputs/bucher",
                       treatment_a,
                       treatment_c,
                       common_comparator,
                       alpha = 0.05) {
  dat <- read_direct_effects(input_csv)
  effect_ab <- orient_contrast(dat, treatment_a, common_comparator)
  effect_cb <- orient_contrast(dat, treatment_c, common_comparator)
  result <- combine_indirect(
    effect_ab = effect_ab,
    effect_cb = effect_cb,
    treatment_a = treatment_a,
    treatment_c = treatment_c,
    common_comparator = common_comparator,
    method = "bucher_adjusted_indirect_comparison",
    alpha = alpha
  )

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  inputs <- rbind(effect_ab, effect_cb)
  inputs$contrast <- paste(inputs$treatment, "vs", inputs$comparator)
  inputs$lower <- inputs$estimate - z_value(alpha) * inputs$se
  inputs$upper <- inputs$estimate + z_value(alpha) * inputs$se

  audit <- bucher_assumption_audit(effect_ab, effect_cb, result)
  plot_rows <- rbind(
    inputs[, c("contrast", "analysis_scale", "estimate", "lower", "upper")],
    result[, c("contrast", "analysis_scale", "estimate", "lower", "upper")]
  )

  write.csv(inputs, file.path(output_dir, "bucher_inputs.csv"), row.names = FALSE)
  write.csv(result, file.path(output_dir, "bucher_result.csv"), row.names = FALSE)
  write.csv(audit, file.path(output_dir, "assumption_audit.csv"), row.names = FALSE)
  plot_comparison_forest(plot_rows, file.path(output_dir, "bucher_forest.pdf"),
                         "Bucher indirect comparison")

  cat("Bucher analysis complete. Outputs written to:",
      normalizePath(output_dir), "\n")
  invisible(list(inputs = inputs, result = result, audit = audit))
}

run_bucher_chain <- function(input_csv,
                             output_dir = "outputs/bucher_chain",
                             treatment_a,
                             treatment_b,
                             via_treatment,
                             alpha = 0.05) {
  dat <- read_direct_effects(input_csv)
  effect_ac <- orient_contrast(dat, treatment_a, via_treatment)
  effect_cb <- orient_contrast(dat, via_treatment, treatment_b)
  result <- combine_indirect_chain(
    effect_ac = effect_ac,
    effect_cb = effect_cb,
    treatment_a = treatment_a,
    treatment_b = treatment_b,
    via_treatment = via_treatment,
    method = "bucher_chain_indirect_comparison",
    alpha = alpha
  )

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  inputs <- rbind(effect_ac, effect_cb)
  inputs$contrast <- paste(inputs$treatment, "vs", inputs$comparator)
  inputs$lower <- inputs$estimate - z_value(alpha) * inputs$se
  inputs$upper <- inputs$estimate + z_value(alpha) * inputs$se

  audit <- bucher_chain_assumption_audit(effect_ac, effect_cb, result)
  plot_rows <- rbind(
    inputs[, c("contrast", "analysis_scale", "estimate", "lower", "upper")],
    result[, c("contrast", "analysis_scale", "estimate", "lower", "upper")]
  )

  write.csv(inputs, file.path(output_dir, "bucher_chain_inputs.csv"),
            row.names = FALSE)
  write.csv(result, file.path(output_dir, "bucher_chain_result.csv"),
            row.names = FALSE)
  write.csv(audit, file.path(output_dir, "assumption_audit.csv"),
            row.names = FALSE)
  plot_comparison_forest(
    plot_rows,
    file.path(output_dir, "bucher_chain_forest.pdf"),
    "Bucher chain indirect comparison"
  )

  cat("Bucher chain analysis complete. Outputs written to:",
      normalizePath(output_dir), "\n")
  invisible(list(inputs = inputs, result = result, audit = audit))
}

read_target_means <- function(target_csv) {
  target <- read.csv(target_csv, stringsAsFactors = FALSE, check.names = FALSE)
  required <- c("covariate", "target_mean")
  missing <- setdiff(required, names(target))
  if (length(missing) > 0) {
    stop("Missing required target columns: ", paste(missing, collapse = ", "))
  }
  target$covariate <- trim_label(target$covariate)
  target$target_mean <- as.numeric(target$target_mean)
  if (any(is.na(target$target_mean))) {
    stop("Target means must be numeric.")
  }
  stats::setNames(target$target_mean, target$covariate)
}

fit_maic_weights <- function(ipd, covariates, target_means) {
  missing <- setdiff(covariates, names(ipd))
  if (length(missing) > 0) {
    stop("IPD missing covariates: ", paste(missing, collapse = ", "))
  }
  for (covariate in covariates) {
    ipd[[covariate]] <- as.numeric(ipd[[covariate]])
    if (any(is.na(ipd[[covariate]]))) {
      stop("Covariate contains non-numeric or missing values: ", covariate)
    }
  }

  x <- as.matrix(ipd[, covariates, drop = FALSE])
  target <- target_means[covariates]
  centered <- sweep(x, 2, target, "-")

  objective <- function(beta) {
    eta <- as.vector(centered %*% beta)
    eta <- pmax(pmin(eta, 50), -50)
    sum(exp(eta))
  }
  gradient <- function(beta) {
    eta <- as.vector(centered %*% beta)
    eta <- pmax(pmin(eta, 50), -50)
    as.numeric(t(centered) %*% exp(eta))
  }

  fit <- optim(rep(0, length(covariates)), objective, gradient,
               method = "BFGS", control = list(maxit = 1000, reltol = 1e-10))
  if (fit$convergence != 0) {
    warning("MAIC optimization did not converge (code ", fit$convergence, "). ",
            "Review maic_assumption_audit.csv before interpreting results.")
  }
  eta <- as.vector(centered %*% fit$par)
  eta <- pmax(pmin(eta, 50), -50)
  raw_weights <- exp(eta)
  weights <- raw_weights / mean(raw_weights)

  list(
    weights = weights,
    coefficients = stats::setNames(fit$par, covariates),
    convergence = fit$convergence,
    objective = fit$value,
    target = target,
    x = x
  )
}

effective_sample_size <- function(weights) {
  (sum(weights)^2) / sum(weights^2)
}

maic_balance <- function(x, weights, target) {
  unweighted <- colMeans(x)
  weighted <- colSums(weights * x) / sum(weights)
  data.frame(
    covariate = names(target),
    target_mean = as.numeric(target),
    source_unweighted_mean = as.numeric(unweighted[names(target)]),
    source_weighted_mean = as.numeric(weighted[names(target)]),
    unweighted_gap = as.numeric(unweighted[names(target)] - target),
    weighted_gap = as.numeric(weighted[names(target)] - target),
    stringsAsFactors = FALSE
  )
}

maic_ess <- function(ipd, weights, arm_col) {
  overall <- data.frame(
    arm = "overall",
    n = length(weights),
    weight_sum = sum(weights),
    ess = effective_sample_size(weights),
    stringsAsFactors = FALSE
  )
  by_arm <- lapply(split(seq_along(weights), ipd[[arm_col]]), function(idx) {
    data.frame(
      arm = as.character(ipd[[arm_col]][idx[1]]),
      n = length(idx),
      weight_sum = sum(weights[idx]),
      ess = effective_sample_size(weights[idx]),
      stringsAsFactors = FALSE
    )
  })
  rbind(overall, do.call(rbind, by_arm))
}

weighted_mean <- function(x, w) sum(w * x) / sum(w)

weighted_variance <- function(x, w) {
  mu <- weighted_mean(x, w)
  sum(w * (x - mu)^2) / sum(w)
}

weighted_outcome_summary <- function(ipd, weights, arm_col,
                                     endpoint_type = "binary",
                                     outcome_col = "response") {
  endpoint_type <- tolower(trim_label(endpoint_type))
  rows <- lapply(split(seq_along(weights), ipd[[arm_col]]), function(idx) {
    w <- weights[idx]
    total_weight <- sum(w)
    base <- data.frame(
      arm = as.character(ipd[[arm_col]][idx[1]]),
      endpoint_type = endpoint_type,
      n = length(idx),
      weight_sum = total_weight,
      ess = effective_sample_size(w),
      stringsAsFactors = FALSE
    )

    if (endpoint_type == "binary") {
      if (!outcome_col %in% names(ipd)) {
        stop("Missing binary outcome column: ", outcome_col)
      }
      y <- as.numeric(ipd[[outcome_col]][idx])
      if (any(is.na(y)) || any(!(y %in% c(0, 1)))) {
        stop("Binary MAIC outcome must be coded 0/1.")
      }
      events_weight <- sum(w * y)
      cbind(base, data.frame(
        weighted_events = events_weight,
        weighted_rate = events_weight / total_weight
      ))
    } else if (endpoint_type == "continuous") {
      if (!outcome_col %in% names(ipd)) {
        stop("Missing continuous outcome column: ", outcome_col)
      }
      y <- as.numeric(ipd[[outcome_col]][idx])
      if (any(is.na(y))) stop("Continuous outcome contains missing values.")
      cbind(base, data.frame(
        weighted_mean = weighted_mean(y, w),
        weighted_variance = weighted_variance(y, w)
      ))
    } else {
      stop("Unsupported MAIC endpoint_type in public release: ", endpoint_type,
           ". Use binary or continuous.")
    }
  })
  do.call(rbind, rows)
}

bounded_rate <- function(rate, ess) {
  eps <- 0.5 / (ess + 1)
  pmin(pmax(rate, eps), 1 - eps)
}

weighted_binary_effect <- function(arm_summary, treatment_arm, comparator_arm,
                                   measure = "log_odds_ratio",
                                   alpha = 0.05) {
  trt <- arm_summary[arm_summary$arm == treatment_arm, , drop = FALSE]
  ctrl <- arm_summary[arm_summary$arm == comparator_arm, , drop = FALSE]
  if (nrow(trt) != 1 || nrow(ctrl) != 1) {
    stop("Could not find exactly one treatment and one comparator arm.")
  }

  pt <- bounded_rate(trt$weighted_rate, trt$ess)
  pc <- bounded_rate(ctrl$weighted_rate, ctrl$ess)
  measure <- trim_label(measure)

  if (measure == "risk_difference") {
    estimate <- pt - pc
    se <- sqrt(pt * (1 - pt) / trt$ess + pc * (1 - pc) / ctrl$ess)
    effect_measure <- "risk_difference"
    analysis_scale <- "risk_difference"
  } else if (measure == "log_risk_ratio") {
    estimate <- log(pt / pc)
    se <- sqrt((1 - pt) / (pt * trt$ess) + (1 - pc) / (pc * ctrl$ess))
    effect_measure <- "risk_ratio"
    analysis_scale <- "log_risk_ratio"
  } else if (measure == "log_odds_ratio") {
    estimate <- log((pt / (1 - pt)) / (pc / (1 - pc)))
    se <- sqrt(1 / (pt * trt$ess) + 1 / ((1 - pt) * trt$ess) +
                 1 / (pc * ctrl$ess) + 1 / ((1 - pc) * ctrl$ess))
    effect_measure <- "odds_ratio"
    analysis_scale <- "log_odds_ratio"
  } else {
    stop("Unsupported MAIC binary effect measure: ", measure)
  }

  effect_result_row(
    method = "maic_weighted_source_effect",
    contrast = paste(treatment_arm, "vs", comparator_arm),
    treatment = treatment_arm,
    comparator = comparator_arm,
    common_comparator = comparator_arm,
    effect_measure = effect_measure,
    analysis_scale = analysis_scale,
    estimate = estimate,
    se = se,
    alpha = alpha
  )
}

weighted_continuous_effect <- function(arm_summary, treatment_arm,
                                       comparator_arm, alpha = 0.05) {
  trt <- arm_summary[arm_summary$arm == treatment_arm, , drop = FALSE]
  ctrl <- arm_summary[arm_summary$arm == comparator_arm, , drop = FALSE]
  if (nrow(trt) != 1 || nrow(ctrl) != 1) {
    stop("Could not find exactly one treatment and one comparator arm.")
  }
  estimate <- trt$weighted_mean - ctrl$weighted_mean
  se <- sqrt(trt$weighted_variance / trt$ess +
               ctrl$weighted_variance / ctrl$ess)
  effect_result_row(
    method = "maic_weighted_source_effect",
    contrast = paste(treatment_arm, "vs", comparator_arm),
    treatment = treatment_arm,
    comparator = comparator_arm,
    common_comparator = comparator_arm,
    effect_measure = "mean_difference",
    analysis_scale = "mean_difference",
    estimate = estimate,
    se = se,
    alpha = alpha
  )
}

weighted_endpoint_effect <- function(ipd, weights, arm_summary, treatment_arm,
                                     comparator_arm, endpoint_type,
                                     measure = NULL, alpha = 0.05) {
  endpoint_type <- tolower(trim_label(endpoint_type))
  if (endpoint_type == "binary") {
    if (is.null(measure)) measure <- "log_odds_ratio"
    weighted_binary_effect(arm_summary, treatment_arm, comparator_arm,
                           measure = measure, alpha = alpha)
  } else if (endpoint_type == "continuous") {
    weighted_continuous_effect(arm_summary, treatment_arm, comparator_arm,
                               alpha = alpha)
  } else {
    stop("Unsupported endpoint_type in public release: ", endpoint_type,
         ". Use binary or continuous.")
  }
}

maic_assumption_audit <- function(balance, ess, convergence) {
  max_abs_gap <- max(abs(balance$weighted_gap), na.rm = TRUE)
  overall_ess <- ess$ess[ess$arm == "overall"]
  original_n <- ess$n[ess$arm == "overall"]
  data.frame(
    item = c(
      "optimization_convergence",
      "max_weighted_balance_gap",
      "overall_effective_sample_size",
      "ess_fraction",
      "outcome_variance_method",
      "effect_modifier_selection",
      "target_support",
      "unmeasured_effect_modifiers"
    ),
    status = c(
      if (convergence == 0) "converged" else paste("nonzero code", convergence),
      sprintf("%.4f", max_abs_gap),
      sprintf("%.2f", overall_ess),
      sprintf("%.3f", overall_ess / original_n),
      "weighted population variance where applicable",
      "requires prespecification",
      "requires source review",
      "requires source review"
    ),
    note = c(
      "Base R optim convergence code.",
      "Review covariate scale before judging practical importance.",
      "ESS after weighting; lower ESS means less stable evidence.",
      "Values below 0.5 are a common fragility warning.",
      "Continuous-outcome SEs divide arm-specific weighted population variance by ESS; consider sensitivity checks when ESS is small.",
      "Covariates should be clinical effect modifiers or prognostic factors.",
      "Target covariate means should lie within plausible IPD support.",
      "MAIC cannot adjust for unavailable or unmeasured modifiers."
    ),
    stringsAsFactors = FALSE
  )
}

plot_maic_balance <- function(balance, output_file) {
  pdf(output_file, width = 8, height = max(4, 0.45 * nrow(balance) + 2))
  old <- par(mar = c(4, 10, 3, 2))
  on.exit({
    par(old)
    dev.off()
  })

  y <- seq_len(nrow(balance))
  xlim <- range(c(balance$unweighted_gap, balance$weighted_gap, 0), na.rm = TRUE)
  pad <- diff(xlim) * 0.15
  if (!is.finite(pad) || pad == 0) pad <- 0.1
  xlim <- c(xlim[1] - pad, xlim[2] + pad)
  plot(balance$unweighted_gap, y, xlim = xlim, yaxt = "n", pch = 1,
       xlab = "Source mean minus target mean", ylab = "",
       main = "MAIC covariate balance")
  points(balance$weighted_gap, y, pch = 19)
  abline(v = 0, lty = 2, col = "gray50")
  segments(balance$unweighted_gap, y, balance$weighted_gap, y, col = "gray70")
  axis(2, at = y, labels = balance$covariate, las = 2, cex.axis = 0.8)
  legend("topright", legend = c("Unweighted", "Weighted"), pch = c(1, 19),
         bty = "n")
  grid(nx = NULL, ny = NA)
}

run_maic <- function(ipd_csv,
                     target_csv,
                     output_dir = "outputs/maic",
                     covariates = NULL,
                     treatment_arm,
                     comparator_arm = NULL,
                     arm_col = "arm",
                     endpoint_type = "binary",
                     outcome_col = "response",
                     measure = NULL,
                     anchored_comparator_csv = NULL,
                     target_treatment_arm = NULL,
                     common_comparator = NULL,
                     alpha = 0.05) {
  ipd <- read.csv(ipd_csv, stringsAsFactors = FALSE, check.names = FALSE)
  if (!arm_col %in% names(ipd)) stop("Missing arm column: ", arm_col)
  ipd[[arm_col]] <- trim_label(ipd[[arm_col]])
  treatment_arm <- validate_label_value(ipd[[arm_col]], treatment_arm,
                                        "treatment_arm")
  if (!is.null(comparator_arm)) {
    comparator_arm <- validate_label_value(ipd[[arm_col]], comparator_arm,
                                           "comparator_arm")
  }

  target_means <- read_target_means(target_csv)
  if (is.null(covariates)) covariates <- names(target_means)
  missing_targets <- setdiff(covariates, names(target_means))
  if (length(missing_targets) > 0) {
    stop("Target means missing covariates: ", paste(missing_targets, collapse = ", "))
  }

  fit <- fit_maic_weights(ipd, covariates, target_means)
  weights <- fit$weights
  balance <- maic_balance(fit$x, weights, fit$target)
  ess <- maic_ess(ipd, weights, arm_col)
  arm_summary <- weighted_outcome_summary(
    ipd = ipd,
    weights = weights,
    arm_col = arm_col,
    endpoint_type = endpoint_type,
    outcome_col = outcome_col
  )
  audit <- maic_assumption_audit(balance, ess, fit$convergence)

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  weight_out <- data.frame(ipd, maic_weight = weights, check.names = FALSE)

  write.csv(weight_out, file.path(output_dir, "maic_weights.csv"), row.names = FALSE)
  write.csv(balance, file.path(output_dir, "maic_balance.csv"), row.names = FALSE)
  write.csv(ess, file.path(output_dir, "maic_ess.csv"), row.names = FALSE)
  write.csv(arm_summary, file.path(output_dir, "maic_arm_summary.csv"),
            row.names = FALSE)
  write.csv(audit, file.path(output_dir, "maic_assumption_audit.csv"),
            row.names = FALSE)
  plot_maic_balance(balance, file.path(output_dir, "maic_balance_plot.pdf"))

  source_effect <- data.frame()
  anchored_result <- data.frame()
  if (!is.null(comparator_arm)) {
    source_effect <- weighted_endpoint_effect(
      ipd = ipd,
      weights = weights,
      arm_summary = arm_summary,
      treatment_arm = treatment_arm,
      comparator_arm = comparator_arm,
      endpoint_type = endpoint_type,
      measure = measure,
      alpha = alpha
    )
    write.csv(source_effect, file.path(output_dir, "maic_source_effect.csv"),
              row.names = FALSE)
  }

  if (!is.null(anchored_comparator_csv)) {
    if (nrow(source_effect) == 0) {
      stop("Anchored MAIC requires comparator_arm to compute source A vs B.")
    }
    target_dat <- read_direct_effects(anchored_comparator_csv)
    if (is.null(target_treatment_arm)) {
      if (nrow(target_dat) != 1) {
        stop("Provide target_treatment_arm when comparator CSV has multiple rows.")
      }
      target_treatment_arm <- target_dat$treatment[1]
    }
    if (is.null(common_comparator)) common_comparator <- comparator_arm
    target_effect <- orient_contrast(
      target_dat,
      treatment = target_treatment_arm,
      comparator = common_comparator
    )
    source_contrast <- data.frame(
      comparison_id = "maic_weighted_source",
      treatment = treatment_arm,
      comparator = common_comparator,
      effect_measure = source_effect$effect_measure[1],
      analysis_scale = source_effect$analysis_scale[1],
      estimate = source_effect$estimate[1],
      se = source_effect$se[1],
      source = "MAIC weighted source IPD",
      source_orientation = "computed",
      stringsAsFactors = FALSE
    )
    anchored_result <- combine_indirect(
      effect_ab = source_contrast,
      effect_cb = target_effect,
      treatment_a = treatment_arm,
      treatment_c = target_treatment_arm,
      common_comparator = common_comparator,
      method = "anchored_maic",
      alpha = alpha
    )
    write.csv(target_effect, file.path(output_dir, "maic_target_effect.csv"),
              row.names = FALSE)
    write.csv(anchored_result, file.path(output_dir, "maic_anchored_result.csv"),
              row.names = FALSE)
    plot_comparison_forest(
      anchored_result[, c("contrast", "analysis_scale", "estimate", "lower", "upper")],
      file.path(output_dir, "maic_anchored_forest.pdf"),
      "Anchored MAIC result"
    )
  }

  cat("MAIC analysis complete. Outputs written to:",
      normalizePath(output_dir), "\n")
  invisible(list(
    weights = weight_out,
    balance = balance,
    ess = ess,
    arm_summary = arm_summary,
    source_effect = source_effect,
    anchored_result = anchored_result,
    audit = audit
  ))
}
