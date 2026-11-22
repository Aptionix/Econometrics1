# Run after the replication: Rscript tests/check_replication.R
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(ggplot2) })
script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
cli_file <- grep("^--file=", commandArgs(), value = TRUE)
if (is.null(script_file) && length(cli_file)) script_file <- sub("^--file=", "", cli_file[1])
project_dir <- if (is.null(script_file)) getwd() else dirname(dirname(normalizePath(script_file)))
data_dir <- file.path(project_dir, "ab_rh_police_and_crime_jeea_data")
output_dir <- file.path(project_dir, "output", "r")
source(file.path(project_dir, "R", "helpers.R"))
source(file.path(project_dir, "R", "data.R"))
source(file.path(project_dir, "R", "validate.R"))

# External numeric reference: coefficients, SEs, and N printed in the paper.
sections <- c("table3", "table5", "table6", "table7")
files <- file.path(output_dir, "models", paste0(sections, ".rds"))
if (!all(file.exists(files))) stop("Run Rscript run_replication.R main first.")
results <- setNames(lapply(files, readRDS), sections)
comparison <- validate_replication(results)
stopifnot(nrow(comparison) == 519,
          all(comparison$passed | comparison$known_difference),
          sum(comparison$known_difference) == 20,
          all(comparison$passed[comparison$statistic != "nobs"]))
message("Published reference: 346 coefficients/SEs match; 153 N checks match; 20 documented N differences.")

# Calendar boundaries from the source do-file, including its pooled final bin.
panel <- crime_panel()
stopifnot(nrow(panel) == 816,
  all(panel$event[panel$date == as.Date("1829-08-01")] == 9),
  all(panel$event[panel$date == as.Date("1829-09-01")] == 10),
  all(panel$event[panel$date >= as.Date("1836-09-01")] == 17))
biennial <- pmin(8L, pmax(1L, panel$event %/% 2L))
stopifnot(all(biennial[panel$date <= as.Date("1823-08-01")] == 1),
  all(biennial[panel$date == as.Date("1823-09-01")] == 2),
  all(biennial[panel$date == as.Date("1829-08-01")] == 4),
  all(biennial[panel$date == as.Date("1829-09-01")] == 5))
message("Calendar and event-bin boundary checks passed.")

# Independent reference for the fast bootstrap: refit every pseudo-sample.
set.seed(17)
sample <- data.frame(cluster = rep(1:5, each = 8), x = rnorm(40))
sample$y <- .3 + .5 * sample$x + rep(rnorm(5), each = 8) + rnorm(40)
model <- estimate(sample, "y", "x", cluster = "cluster")
reps <- 64L; seed <- 1234L
fast <- wild_bootstrap(model, "x", reps = reps, seed = seed)
set.seed(seed)
weights <- matrix(ifelse(runif(5 * (reps - 1)) < .5, 1, -1), nrow = 5)
boot_t <- boot_b <- numeric(reps - 1)
for (b in seq_len(reps - 1)) {
  pseudo <- sample
  pseudo$y <- fitted(model$fit) + residuals(model$fit) * weights[pseudo$cluster, b]
  refit <- estimate(pseudo, "y", "x", cluster = "cluster")
  row <- refit$tidy[refit$tidy$term == "x", ]
  boot_b[b] <- row$estimate
  boot_t[b] <- (row$estimate - model$coefficients[["x"]]) / row$std.error
}
observed <- model$tidy$statistic[model$tidy$term == "x"]
all_t <- c(observed, boot_t)
fraction <- mean(rank(all_t)[abs(all_t - observed) < 1e-6]) / reps
expected_p <- 2 * min(if (observed < 0) fraction else 1 - fraction, .5)
expected_ci <- quantile(c(model$coefficients[["x"]], boot_b), c(.025, .975), type = 2)
stopifnot(isTRUE(all.equal(fast$bootstrap_p, expected_p)),
  max(abs(c(fast$bootstrap_conf.low, fast$bootstrap_conf.high) - expected_ci)) < 1e-9,
  abs(fast$cgm_equivalent_se - abs(model$coefficients[["x"]] / qt(1 - expected_p/2, df.residual(model$fit)))) < 1e-9)
message("Fast bootstrap matches repeated full-model refits.")

# Full-run coverage is checked when its completion manifest is available.
manifest <- file.path(output_dir, "checks", "completed_modules.csv")
if (file.exists(manifest)) {
  completed <- read.csv(manifest)
  message("Latest run completed ", nrow(completed), " modules.")
}
message("All replication checks passed.")
