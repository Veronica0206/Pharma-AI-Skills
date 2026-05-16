###############################################################################
# basket_simple.R -- Basket trial: no-borrowing and complete-pooling baselines.
#
# Public scope: implements the two reference designs that frame any basket
# information-borrowing discussion.
#
#   (1) "none"     - independent Beta-Binomial test in each subgroup.
#   (2) "complete" - pool all subgroups into a single Beta-Binomial test.
#
# Adaptive borrowing methods (Simon's Bayesian, Chen, Wathen, CBHM, full BHM
# with Gibbs) are intentionally out of scope for this public release.
###############################################################################

# Single simulation: returns per-subgroup decisions and estimates.
run_basket_single <- function(cfg, sim_id) {
  K <- cfg$n_subgroups
  n <- cfg$n_per_subgroup
  endpoint <- if (!is.null(cfg$endpoint_type)) cfg$endpoint_type else "binary"
  if (endpoint != "binary") {
    stop("basket_simple.R public scope supports binary endpoints only. ",
         "For other endpoints in a basket context, see SKILL.md § Beyond This Skill.")
  }

  # Generate data: each subgroup has n patients with response rate alt_params[k].
  x <- integer(K)
  for (k in 1:K) {
    x[k] <- sum(simulate_binary_data(n, cfg$alt_params[k]))
  }

  method <- cfg$borrowing_method %||% "none"
  if (method == "none") {
    decisions <- character(K); estimates <- numeric(K)
    for (k in 1:K) {
      post <- beta_posterior_prob(x[k], n,
                                  threshold = cfg$null_params[k],
                                  a_prior = 1, b_prior = 1)
      decisions[k] <- if (post >= cfg$go_threshold) "Go" else "No-Go"
      estimates[k] <- (x[k] + 1) / (n + 2)  # posterior mean under Beta(1, 1)
    }
  } else if (method == "complete") {
    pooled_x <- sum(x); pooled_n <- K * n
    pooled_null <- mean(cfg$null_params)
    post <- beta_posterior_prob(pooled_x, pooled_n,
                                threshold = pooled_null,
                                a_prior = 1, b_prior = 1)
    pooled_estimate <- (pooled_x + 1) / (pooled_n + 2)
    decisions <- rep(if (post >= cfg$go_threshold) "Go" else "No-Go", K)
    estimates <- rep(pooled_estimate, K)
  } else {
    stop("Unknown borrowing_method for public release: ", method,
         ". Allowed: 'none' or 'complete'. See SKILL.md § Beyond This Skill.")
  }

  data.frame(
    subgroup = 1:K,
    n        = n,
    x        = x,
    estimate = round(estimates, 4),
    decision = decisions,
    stringsAsFactors = FALSE
  )
}

# Null-coalesce helper (R has no built-in).
`%||%` <- function(a, b) if (is.null(a)) b else a

cat("basket_simple.R loaded.\n")
