###############################################################################
# meta_endpoint_core.R
#
# Base R helpers for clinical endpoint-family meta-analysis.
# Supported families: binary, continuous, time_to_event, incidence_rate.
###############################################################################

inv_logit <- function(x) 1 / (1 + exp(-x))
logit <- function(p) log(p / (1 - p))

check_same_length <- function(..., label = "inputs") {
  lens <- vapply(list(...), length, integer(1))
  if (length(unique(lens)) != 1) {
    stop(label, " must have the same length.")
  }
  invisible(TRUE)
}

meta_iv <- function(yi, vi, alpha = 0.05, random = TRUE) {
  ok <- is.finite(yi) & is.finite(vi) & vi > 0
  yi <- yi[ok]
  vi <- vi[ok]
  if (length(yi) == 0) stop("No valid estimates for inverse-variance pooling.")

  wi <- 1 / vi
  fixed <- sum(wi * yi) / sum(wi)
  q <- sum(wi * (yi - fixed)^2)
  df <- length(yi) - 1
  cval <- sum(wi) - sum(wi^2) / sum(wi)
  tau2 <- if (random && df > 0 && cval > 0) max(0, (q - df) / cval) else 0

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
    i2 = if (df > 0 && q > 0) 100 * max(0, (q - df) / q) else NA_real_
  )
}

binary_logit_inputs <- function(responders, total, continuity = 0.5) {
  check_same_length(responders, total, label = "binary responder inputs")
  if (any(total <= 0) || any(responders < 0) || any(responders > total)) {
    stop("Binary inputs require 0 <= responders <= total and total > 0.")
  }
  nonresponders <- total - responders
  extreme <- responders == 0 | nonresponders == 0
  x_adj <- responders
  y_adj <- nonresponders
  x_adj[extreme] <- x_adj[extreme] + continuity
  y_adj[extreme] <- y_adj[extreme] + continuity
  n_adj <- x_adj + y_adj
  p <- x_adj / n_adj
  data.frame(
    endpoint_family = "binary",
    measure = "logit_proportion",
    yi = logit(p),
    vi = 1 / x_adj + 1 / y_adj
  )
}

binary_comparative_inputs <- function(events_t, total_t, events_c, total_c,
                                      measure = c("risk_difference", "log_risk_ratio", "log_odds_ratio"),
                                      continuity = 0.5) {
  measure <- match.arg(measure)
  check_same_length(events_t, total_t, events_c, total_c, label = "binary comparative inputs")
  if (any(total_t <= 0) || any(total_c <= 0) ||
      any(events_t < 0) || any(events_t > total_t) ||
      any(events_c < 0) || any(events_c > total_c)) {
    stop("Binary comparative inputs require valid event and total counts.")
  }

  a <- events_t
  b <- total_t - events_t
  c <- events_c
  d <- total_c - events_c

  if (measure != "risk_difference" && any(a == 0 | b == 0 | c == 0 | d == 0)) {
    a <- a + continuity
    b <- b + continuity
    c <- c + continuity
    d <- d + continuity
  }

  nt <- a + b
  nc <- c + d
  pt <- a / nt
  pc <- c / nc

  if (measure == "risk_difference") {
    yi <- pt - pc
    vi <- pt * (1 - pt) / nt + pc * (1 - pc) / nc
  } else if (measure == "log_risk_ratio") {
    yi <- log(pt / pc)
    vi <- 1 / a - 1 / nt + 1 / c - 1 / nc
  } else {
    yi <- log((a / b) / (c / d))
    vi <- 1 / a + 1 / b + 1 / c + 1 / d
  }

  data.frame(endpoint_family = "binary", measure = measure, yi = yi, vi = vi)
}

continuous_mean_inputs <- function(mean, sd, n) {
  check_same_length(mean, sd, n, label = "continuous mean inputs")
  if (any(sd <= 0) || any(n <= 1)) {
    stop("Continuous inputs require sd > 0 and n > 1.")
  }
  data.frame(
    endpoint_family = "continuous",
    measure = "mean",
    yi = mean,
    vi = sd^2 / n
  )
}

continuous_comparative_inputs <- function(mean_t, sd_t, n_t, mean_c, sd_c, n_c,
                                          measure = c("mean_difference", "standardized_mean_difference")) {
  measure <- match.arg(measure)
  check_same_length(mean_t, sd_t, n_t, mean_c, sd_c, n_c, label = "continuous comparative inputs")
  if (any(sd_t <= 0) || any(sd_c <= 0) || any(n_t <= 1) || any(n_c <= 1)) {
    stop("Continuous comparative inputs require sd > 0 and n > 1.")
  }

  if (measure == "mean_difference") {
    yi <- mean_t - mean_c
    vi <- sd_t^2 / n_t + sd_c^2 / n_c
  } else {
    pooled_sd <- sqrt(((n_t - 1) * sd_t^2 + (n_c - 1) * sd_c^2) / (n_t + n_c - 2))
    d <- (mean_t - mean_c) / pooled_sd
    j <- 1 - 3 / (4 * (n_t + n_c) - 9)
    yi <- j * d
    vi <- (n_t + n_c) / (n_t * n_c) + yi^2 / (2 * (n_t + n_c - 2))
  }

  data.frame(endpoint_family = "continuous", measure = measure, yi = yi, vi = vi)
}

time_to_event_inputs <- function(hr = NULL, ci_lower = NULL, ci_upper = NULL,
                                 log_hr = NULL, se = NULL) {
  if (is.null(log_hr)) {
    if (is.null(hr)) stop("Provide hr or log_hr.")
    log_hr <- log(hr)
  }
  if (is.null(se)) {
    if (is.null(ci_lower) || is.null(ci_upper)) {
      stop("Provide se or both ci_lower and ci_upper for time-to-event inputs.")
    }
    se <- (log(ci_upper) - log(ci_lower)) / (2 * qnorm(0.975))
  }
  check_same_length(log_hr, se, label = "time-to-event inputs")
  if (any(se <= 0)) stop("Time-to-event inputs require se > 0.")
  data.frame(
    endpoint_family = "time_to_event",
    measure = "log_hazard_ratio",
    yi = log_hr,
    vi = se^2
  )
}

incidence_rate_inputs <- function(events, person_time, continuity = 0.5) {
  check_same_length(events, person_time, label = "incidence-rate inputs")
  if (any(events < 0) || any(person_time <= 0)) {
    stop("Incidence-rate inputs require events >= 0 and person_time > 0.")
  }
  e_adj <- ifelse(events == 0, events + continuity, events)
  data.frame(
    endpoint_family = "incidence_rate",
    measure = "log_rate",
    yi = log(e_adj / person_time),
    vi = 1 / e_adj
  )
}

incidence_rate_ratio_inputs <- function(events_t, person_time_t, events_c, person_time_c,
                                        continuity = 0.5) {
  check_same_length(events_t, person_time_t, events_c, person_time_c,
                    label = "incidence-rate comparative inputs")
  if (any(events_t < 0) || any(events_c < 0) ||
      any(person_time_t <= 0) || any(person_time_c <= 0)) {
    stop("Incidence-rate ratio inputs require events >= 0 and person_time > 0.")
  }
  et <- ifelse(events_t == 0, events_t + continuity, events_t)
  ec <- ifelse(events_c == 0, events_c + continuity, events_c)
  data.frame(
    endpoint_family = "incidence_rate",
    measure = "log_rate_ratio",
    yi = log((et / person_time_t) / (ec / person_time_c)),
    vi = 1 / et + 1 / ec
  )
}

back_transform <- function(x, measure) {
  if (measure %in% c("logit_proportion")) {
    inv_logit(x)
  } else if (measure %in% c("log_risk_ratio", "log_odds_ratio",
                            "log_hazard_ratio", "log_rate", "log_rate_ratio")) {
    exp(x)
  } else {
    x
  }
}
