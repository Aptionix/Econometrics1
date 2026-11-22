# Run once in R/RStudio: source("setup.R")
packages <- c("haven", "dplyr", "tidyr", "ggplot2", "patchwork")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
invisible(lapply(packages, function(p) stopifnot(requireNamespace(p, quietly = TRUE))))
message("R dependencies are ready. Run source('run_replication.R').")
