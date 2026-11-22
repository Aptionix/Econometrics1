# Numerical routines use base R so robust inference does not depend on package defaults.

read_source <- function(name) {
  d <- as.data.frame(haven::read_dta(file.path(data_dir, paste0("ab_rh_police_and_crime_jeea_", name, ".dta"))))
  d[] <- lapply(d, function(x) if (inherits(x, "haven_labelled")) haven::zap_labels(x) else x)
  d
}

save_csv <- function(x, name, folder = "tables") {
  write.csv(x, file.path(output_dir, folder, paste0(name, ".csv")), row.names = FALSE, na = "")
  invisible(x)
}

save_plot <- function(p, name, width = 8, height = 5) {
  ggplot2::ggsave(file.path(output_dir, "figures", paste0(name, ".pdf")), p,
                 width = width, height = height, device = grDevices::pdf)
  ggplot2::ggsave(file.path(output_dir, "figures", paste0(name, ".png")), p,
                 width = width, height = height, dpi = 150, bg = "white")
  invisible(p)
}

theme_set(theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank(),
          legend.position = "bottom", legend.title = element_blank()))

rhs_formula <- function(y, terms, fixed = character()) {
  reformulate(c(terms, if (length(fixed)) paste0("factor(", fixed, ")")), response = y)
}

inverse_crossprod <- function(x) {
  q <- qr(x)
  if (q$rank != ncol(x)) stop("Non-full-rank design after removing aliased columns")
  v <- chol2inv(qr.R(q))
  v[order(q$pivot), order(q$pivot), drop = FALSE]
}

estimate <- function(d, y, terms, fixed = character(), cluster = NULL, poisson = FALSE) {
  variables <- unique(c(y, all.vars(rhs_formula(y, terms, fixed)), cluster))
  d <- d[complete.cases(d[, variables, drop = FALSE]), , drop = FALSE]
  if (poisson) {
    # Conditional FE Poisson drops groups whose outcome is always zero.
    unit <- fixed[1]
    totals <- ave(d[[y]], d[[unit]], FUN = sum)
    d <- d[totals > 0, , drop = FALSE]
  }
  fit <- if (poisson) glm(rhs_formula(y, terms, fixed), data = d, family = poisson(),
                         x = TRUE, y = TRUE, control = glm.control(maxit = 100)) else
    lm(rhs_formula(y, terms, fixed), data = d, x = TRUE, y = TRUE)
  if (poisson && !isTRUE(fit$converged)) stop("Poisson model did not converge")
  keep <- which(!is.na(coef(fit)))
  x <- fit$x[, keep, drop = FALSE]
  b <- coef(fit)[keep]
  n <- nrow(x)
  k <- ncol(x)
  u <- if (poisson) fit$y - fitted(fit) else residuals(fit)
  bread <- inverse_crossprod(if (poisson) x * sqrt(fitted(fit)) else x)
  scores <- x * as.numeric(u)
  if (is.null(cluster)) {
    correction <- n / (n - k)
    df <- n - k
  } else {
    scores <- rowsum(scores, d[[cluster]], reorder = TRUE)
    groups <- nrow(scores)
    # xtpqml uses the unadjusted unit-score sandwich and normal inference.
    correction <- if (poisson) 1 else groups / (groups - 1) * (n - 1) / (n - k)
    df <- if (poisson) Inf else groups - 1
  }
  v <- correction * bread %*% crossprod(scores) %*% bread
  dimnames(v) <- list(names(b), names(b))
  se <- sqrt(pmax(diag(v), 0))
  stat <- b / se
  p <- 2 * pt(abs(stat), df = df, lower.tail = FALSE)
  critical <- qt(.975, df = df)
  tidy <- data.frame(term = names(b), estimate = unname(b), std.error = unname(se),
                     statistic = unname(stat), p.value = unname(p),
                     conf.low = unname(b - critical * se), conf.high = unname(b + critical * se),
                     nobs = n, df = df, estimator = if (poisson) "Poisson QML (IRR)" else "OLS",
                     variance = if (poisson) "unit-cluster sandwich, no finite-sample correction" else
                       if (is.null(cluster)) "HC1" else paste0("CR1: ", cluster))
  if (poisson) {
    tidy$log_estimate <- tidy$estimate
    tidy$log_std.error <- tidy$std.error
    tidy$std.error <- exp(tidy$estimate) * tidy$std.error
    tidy$estimate <- exp(tidy$estimate)
    tidy$conf.low <- exp(tidy$conf.low)
    tidy$conf.high <- exp(tidy$conf.high)
  }
  list(fit = fit, data = d, x = x, bread = bread, covariance = v, coefficients = b,
       tidy = tidy, df = df, cluster = cluster, correction = correction)
}

add_model <- function(models, id, d, y, terms, fixed = character(), cluster = NULL, poisson = FALSE) {
  models[[id]] <- estimate(d, y, terms, fixed, cluster, poisson)
  models
}

export_models <- function(models, name) {
  rows <- bind_rows(lapply(names(models), function(id) mutate(models[[id]]$tidy, model = id, .before = 1)))
  save_csv(rows, name)
  saveRDS(models, file.path(output_dir, "models", paste0(name, ".rds")))
  invisible(models)
}

equality_test <- function(model, terms) {
  indices <- match(terms, names(model$coefficients))
  r <- matrix(0, nrow = length(terms) - 1, ncol = length(model$coefficients))
  for (j in seq_len(nrow(r))) { r[j, indices[1]] <- 1; r[j, indices[j + 1]] <- -1 }
  difference <- r %*% model$coefficients
  w <- as.numeric(t(difference) %*% solve(r %*% model$covariance %*% t(r), difference))
  data.frame(statistic = w / nrow(r), df1 = nrow(r), df2 = model$df,
             p.value = pf(w / nrow(r), nrow(r), model$df, lower.tail = FALSE))
}

summary_rows <- function(d, variables, sample = "all") {
  bind_rows(lapply(variables, function(v) {
    x <- d[[v]]
    data.frame(sample = sample, variable = v, n = sum(!is.na(x)),
               mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE),
               min = if (all(is.na(x))) NA_real_ else min(x, na.rm = TRUE),
               max = if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE))
  }))
}

# Unrestricted wild cluster bootstrap-t, matching cgmwildboot's default null(. ... .).
# Its reps count includes the observed sample; R and Stata RNG streams differ.
wild_bootstrap <- function(model, terms, reps = bootstrap_reps, seed = bootstrap_seed) {
  stopifnot(reps >= 2L, !is.null(model$cluster))
  x <- model$x
  u <- as.numeric(residuals(model$fit))
  cluster <- model$data[[model$cluster]]
  ids <- sort(unique(cluster))
  g <- length(ids)
  scores <- rowsum(x * u, cluster, reorder = TRUE)
  set.seed(seed)
  weights <- matrix(ifelse(runif(g * (reps - 1)) < .5, 1, -1), nrow = g)
  shifts <- model$bread %*% t(scores) %*% weights
  q <- lapply(ids, function(id) crossprod(x[cluster == id, , drop = FALSE]))
  bind_rows(lapply(terms, function(term) {
    j <- match(term, colnames(x))
    a <- model$bread[j, , drop = FALSE]
    boot_scores <- matrix(0, nrow = g, ncol = reps - 1)
    for (h in seq_len(g)) {
      boot_scores[h, ] <- as.numeric(a %*% scores[h, ]) * weights[h, ] - a %*% q[[h]] %*% shifts
    }
    boot_se <- sqrt(model$correction * colSums(boot_scores^2))
    boot_t <- shifts[j, ] / boot_se
    observed <- model$tidy$statistic[match(term, model$tidy$term)]
    all_t <- c(observed, boot_t)
    valid <- !is.na(all_t)
    # cgmwildboot ranks the observed statistic with tolerance 1e-6.
    ranks <- rank(all_t[valid], ties.method = "average")
    rank_observed <- mean(ranks[abs(all_t[valid] - observed) < 1e-6])
    fraction <- rank_observed / sum(valid)
    p <- if (observed < 0) 2 * min(fraction, .5) else if (observed > 0) 2 * min(1 - fraction, .5) else 1
    coefficient <- model$coefficients[j]
    ci <- quantile(c(coefficient, coefficient + shifts[j, ]), c(.025, .975), type = 2)
    data.frame(term = term, estimate = unname(coefficient), bootstrap_p = p,
               bootstrap_conf.low = ci[1], bootstrap_conf.high = ci[2],
               cgm_equivalent_se = if (p == 0) 0 else if (p == 1) Inf else abs(coefficient / qt(1 - p/2, df.residual(model$fit))),
               reps = reps, seed = seed, clusters = g)
  }))
}
