###############################################################################
# master_config.R -- Configuration builder for master protocol trial designs.
#
# Public scope:
#   - basket: methods "none" or "complete" (binary endpoint only)
#   - umbrella: method "mams" (continuous or binary endpoint)
#   - platform: simple concurrent-control comparison (binary endpoint only)
#
# Advanced features (information borrowing methods, drop-the-losers, BAR,
# NCC adjustment, RAR) are intentionally out of scope. See SKILL.md.
###############################################################################

create_master_config <- function(
  master_design_type,
  endpoint_type,
  n_subgroups,
  null_params,
  alt_params,
  n_per_subgroup   = NULL,
  alpha            = 0.025,
  n_sims           = 5000,
  seed             = 42,
  output_dir       = "results/",
  label            = NULL,

  # --- Basket ---
  borrowing_method = "none",      # "none" or "complete"
  go_threshold     = 0.90,        # posterior probability threshold for Go

  # --- Umbrella ---
  umbrella_method  = "mams",      # public scope: "mams" only
  n_arms           = NULL,
  n_stages         = 2,
  n_per_arm_stage  = NULL,
  sd               = NULL,
  futility_boundaries = NULL,

  # --- Platform ---
  n_periods        = NULL,
  n_per_period     = NULL,
  arms_schedule    = NULL
) {
  master_design_type <- match.arg(master_design_type, c("basket", "umbrella", "platform"))
  endpoint_type      <- match.arg(endpoint_type, c("binary", "continuous"))

  stopifnot(is.numeric(n_subgroups), n_subgroups >= 2)
  stopifnot(is.numeric(null_params))
  stopifnot(is.numeric(alt_params), length(alt_params) == n_subgroups)
  stopifnot(is.numeric(n_sims), n_sims > 0)
  stopifnot(is.numeric(alpha), alpha > 0, alpha < 1)

  if (length(null_params) == 1) {
    null_params <- rep(null_params, n_subgroups)
  }
  stopifnot(length(null_params) == n_subgroups)

  if (is.null(label)) {
    label <- paste0(master_design_type, "_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  }

  # --- Basket validation ---
  if (master_design_type == "basket") {
    if (endpoint_type != "binary") {
      stop("Public-scope basket designs support binary endpoints only. ",
           "See SKILL.md § Beyond This Skill.")
    }
    borrowing_method <- match.arg(borrowing_method, c("none", "complete"))
    if (is.null(n_per_subgroup)) n_per_subgroup <- 25
    stopifnot(all(null_params >= 0 & null_params <= 1))
    stopifnot(all(alt_params >= 0 & alt_params <= 1))
  }

  # --- Umbrella validation ---
  if (master_design_type == "umbrella") {
    umbrella_method <- match.arg(umbrella_method, c("mams"))
    if (is.null(n_arms)) n_arms <- n_subgroups
    if (n_arms != n_subgroups) {
      stop("n_arms (", n_arms, ") must equal n_subgroups (", n_subgroups,
           ") for umbrella designs in this public release.")
    }
    stopifnot(is.numeric(n_stages), length(n_stages) == 1,
              n_stages == as.integer(n_stages), n_stages >= 1)
    if (endpoint_type == "continuous") {
      stopifnot(!is.null(sd), is.numeric(sd), sd > 0)
    }
    if (endpoint_type == "binary") {
      stopifnot(all(null_params >= 0 & null_params <= 1))
      stopifnot(all(alt_params >= 0 & alt_params <= 1))
    }
    if (is.null(n_per_arm_stage)) {
      n_per_arm_stage <- if (!is.null(n_per_subgroup)) {
        ceiling(n_per_subgroup / n_stages)
      } else {
        20
      }
    }
    stopifnot(is.numeric(n_per_arm_stage), length(n_per_arm_stage) == 1,
              n_per_arm_stage == as.integer(n_per_arm_stage),
              n_per_arm_stage > 0)
  }

  # --- Platform validation ---
  if (master_design_type == "platform") {
    if (endpoint_type != "binary") {
      stop("Public-scope platform designs support binary endpoints only. ",
           "See SKILL.md § Beyond This Skill.")
    }
    stopifnot(!is.null(n_periods), is.numeric(n_periods), n_periods >= 2)
    stopifnot(!is.null(n_per_period), is.numeric(n_per_period), n_per_period > 0)
    stopifnot(!is.null(arms_schedule), is.list(arms_schedule))
    stopifnot(!is.null(arms_schedule$enter), !is.null(arms_schedule$leave))
    stopifnot(length(arms_schedule$enter) == n_subgroups)
    stopifnot(length(arms_schedule$leave) == n_subgroups)
    stopifnot(all(arms_schedule$enter >= 1 & arms_schedule$enter <= n_periods))
    stopifnot(all(arms_schedule$leave >= arms_schedule$enter))
    stopifnot(all(null_params >= 0 & null_params <= 1))
    stopifnot(all(alt_params >= 0 & alt_params <= 1))
  }

  cfg <- list(
    master_design_type = master_design_type,
    endpoint_type      = endpoint_type,
    n_subgroups        = n_subgroups,
    null_params        = null_params,
    alt_params         = alt_params,
    n_per_subgroup     = n_per_subgroup,
    alpha              = alpha,
    n_sims             = n_sims,
    seed               = seed,
    output_dir         = output_dir,
    label              = label,
    # basket
    borrowing_method   = borrowing_method,
    go_threshold       = go_threshold,
    # umbrella
    umbrella_method    = umbrella_method,
    n_arms             = n_arms,
    n_stages           = n_stages,
    n_per_arm_stage    = n_per_arm_stage,
    sd                 = sd,
    futility_boundaries = futility_boundaries,
    # platform
    n_periods          = n_periods,
    n_per_period       = n_per_period,
    arms_schedule      = arms_schedule
  )
  class(cfg) <- "master_config"
  return(cfg)
}

print.master_config <- function(x, ...) {
  cat("=== Master Protocol Configuration ===\n")
  cat("Design type:", x$master_design_type, "\n")
  cat("Endpoint:", x$endpoint_type, "\n")
  cat("Subgroups/Arms:", x$n_subgroups, "\n")
  cat("Alpha:", x$alpha, "\n")
  cat("Simulations:", x$n_sims, "\n")
  if (x$master_design_type == "basket") {
    cat("Borrowing method:", x$borrowing_method, "\n")
    cat("N per subgroup:", x$n_per_subgroup, "\n")
  } else if (x$master_design_type == "umbrella") {
    cat("Umbrella method:", x$umbrella_method, "\n")
    cat("Stages:", x$n_stages, "\n")
    cat("N per arm per stage:", x$n_per_arm_stage, "\n")
  } else if (x$master_design_type == "platform") {
    cat("Periods:", x$n_periods, "\n")
    cat("N per period:", x$n_per_period, "\n")
  }
  cat("Output dir:", x$output_dir, "\n")
  invisible(x)
}
