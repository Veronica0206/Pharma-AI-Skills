###############################################################################
# config.R
# Configuration builder for clinical trial sample size calculation.
#
# Public scope:
#   - Endpoint types: binary, continuous, tte
#   - Designs: single_arm, controlled (1:1 only)
#   - Alpha and power: configurable, with sensible defaults
###############################################################################

#' Create a sample size configuration
#'
#' @param endpoint_type  "binary", "continuous", or "tte"
#' @param design         "single_arm" or "controlled" (controlled = 1:1)
#' @param null_param     H0 rate (binary), H0 mean (continuous), H0 hazard (tte)
#' @param alt_param      H1 rate (binary), H1 mean (continuous), H1 hazard (tte)
#' @param sd             SD of endpoint (required for continuous)
#' @param alphas         One-sided alpha levels (default c(0.025, 0.05))
#' @param powers         Power targets (default c(0.80, 0.90))
#' @param accrual_time   Accrual period (required for tte)
#' @param followup_time  Follow-up after last enrollment (required for tte)
#' @param label          Display label for the endpoint
create_config <- function(
  endpoint_type   = c("binary", "continuous", "tte"),
  design          = c("single_arm", "controlled"),
  null_param,
  alt_param,
  sd              = NULL,
  alphas          = c(0.025, 0.05),
  powers          = c(0.80, 0.90),
  accrual_time    = NULL,
  followup_time   = NULL,
  label           = "Endpoint"
) {
  endpoint_type <- match.arg(endpoint_type)
  design        <- match.arg(design)

  stopifnot(is.numeric(null_param), length(null_param) == 1)
  stopifnot(is.numeric(alt_param), length(alt_param) == 1)

  if (endpoint_type == "binary") {
    stopifnot(null_param >= 0, null_param <= 1,
              alt_param >= 0, alt_param <= 1,
              alt_param > null_param)
  }
  if (endpoint_type == "continuous") {
    if (is.null(sd)) stop("sd is required for continuous endpoints")
    stopifnot(is.numeric(sd), sd > 0)
    stopifnot(alt_param > null_param)
  }
  if (endpoint_type == "tte") {
    stopifnot(null_param > 0, alt_param > 0)
    # Lower hazard = better treatment, so alt_param < null_param
    stopifnot(alt_param < null_param)
    if (is.null(accrual_time)) stop("accrual_time is required for tte endpoints")
    if (is.null(followup_time)) stop("followup_time is required for tte endpoints")
    stopifnot(is.numeric(accrual_time), accrual_time > 0)
    stopifnot(is.numeric(followup_time), followup_time > 0)
  }

  cfg <- list(
    endpoint_type      = endpoint_type,
    design             = design,
    null_param         = null_param,
    alt_param          = alt_param,
    sd                 = sd,
    alphas             = alphas,
    powers             = powers,
    accrual_time       = accrual_time,
    followup_time      = followup_time,
    label              = label
  )
  class(cfg) <- "ss_config"
  return(cfg)
}

#' Print method for config
print.ss_config <- function(x, ...) {
  cat("=== Sample Size Config ===\n")
  cat("  Endpoint:    ", x$endpoint_type, "\n")
  cat("  Design:      ", x$design, if (x$design == "controlled") " (1:1)" else "", "\n")
  cat("  H0:          ", x$null_param, "\n")
  cat("  H1:          ", x$alt_param, "\n")
  if (x$endpoint_type == "continuous") cat("  SD:          ", x$sd, "\n")
  if (x$endpoint_type == "tte") {
    cat("  Accrual:     ", x$accrual_time, "\n")
    cat("  Follow-up:   ", x$followup_time, "\n")
    cat("  Median(H0):  ", round(log(2) / x$null_param, 2), "\n")
    cat("  Median(H1):  ", round(log(2) / x$alt_param, 2), "\n")
  }
  cat("  Alpha(s):    ", paste(x$alphas, collapse = ", "), "\n")
  cat("  Power(s):    ", paste(x$powers, collapse = ", "), "\n")
  cat("  Label:       ", x$label, "\n")
  invisible(x)
}

cat("config.R loaded.\n")
