# Bindler and Hjalmarsson (2021), JEEA: R replication.
# In RStudio, open Econometrics1.Rproj, then source this file.
# Select individual modules with, for example:
#   sections <- c("table3", "figure4")
#   source("run_replication.R")
# From a terminal: Rscript run_replication.R table3 figure4

if (!exists("sections", inherits = FALSE)) sections <- "all"
if (!exists("bootstrap_reps", inherits = FALSE)) bootstrap_reps <- 1000L
if (!exists("bootstrap_seed", inherits = FALSE)) bootstrap_seed <- 1234L

# Resolve paths from this script, not a machine-specific working directory.
script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
cli_file <- grep("^--file=", commandArgs(), value = TRUE)
if (is.null(script_file) && length(cli_file)) script_file <- sub("^--file=", "", cli_file[1])
project_dir <- if (is.null(script_file)) getwd() else dirname(normalizePath(script_file))
if (sys.nframe() == 0L && length(commandArgs(trailingOnly = TRUE))) {
  sections <- commandArgs(trailingOnly = TRUE)
}
data_dir <- file.path(project_dir, "ab_rh_police_and_crime_jeea_data")
output_dir <- file.path(project_dir, "output", "r")
packages <- c("haven", "dplyr", "tidyr", "ggplot2", "patchwork")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Run source('setup.R') first. Missing: ", paste(missing, collapse = ", "))
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
})
for (folder in c("tables", "figures", "models", "data", "checks")) {
  dir.create(file.path(output_dir, folder), recursive = TRUE, showWarnings = FALSE)
}
for (script in c("helpers.R", "data.R", "tables.R", "figures.R", "validate.R")) {
  source(file.path(project_dir, "R", script), local = TRUE)
}
modules <- c("figure1", "figure3", "figure4", "figure5", paste0("table", 1:7),
             paste0("figureA", 1:5), paste0("tableA", c(1, 3:7)),
             "figureB1", "figureB2", paste0("tableB", c(1, 3:7)),
             "fn13", "fn22", "fn28", "fn33", "ref1")
groups <- list(main = modules[seq_len(11)],
               appendix = modules[12:30], footnotes = modules[31:35])
if ("all" %in% sections) sections <- modules
sections <- unique(unlist(lapply(sections, function(s) if (s %in% names(groups)) groups[[s]] else s)))
if (length(setdiff(sections, modules))) stop("Unknown sections: ", paste(setdiff(sections, modules), collapse = ", "))

results <- setNames(vector("list", length(sections)), sections)
for (section in sections) {
  message("Running ", section, " ...")
  results[[section]] <- get(paste0("run_", section))()
}
validation <- validate_replication(results)
write.csv(validation, file.path(output_dir, "checks", "paper_comparison.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(output_dir, "sessionInfo.txt"))
write.csv(data.frame(section = sections, status = "completed"),
          file.path(output_dir, "checks", "completed_modules.csv"), row.names = FALSE)
message("Completed ", length(sections), " modules. Outputs: ", output_dir)
if (nrow(validation)) {
  message("Paper checks: ", sum(validation$passed), "/", nrow(validation), " passed.")
  if (any(validation$known_difference)) message(sum(validation$known_difference), " documented sample-count differences; see README.md.")
  if (any(!validation$passed & !validation$known_difference)) stop("Paper comparison failed; inspect output/r/checks/paper_comparison.csv")
}
