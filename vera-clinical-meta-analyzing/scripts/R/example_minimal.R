###############################################################################
# example_minimal.R
# Synthetic smoke test for the public clinical meta-analysis skill.
###############################################################################

resolve_script_dir <- function() {
  frames <- sys.frames()
  for (i in rev(seq_along(frames))) {
    if (!is.null(frames[[i]]$ofile)) {
      return(dirname(normalizePath(frames[[i]]$ofile)))
    }
  }
  script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(script_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", script_arg[1]))))
  }
  getwd()
}
script_dir <- resolve_script_dir()

source(file.path(script_dir, "meta_analysis.R"))

out_dir <- file.path("outputs", "example")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

example_counts <- data.frame(
  study_id = c("S1", "S1", "S2", "S2", "S3", "S3"),
  study = c("Study A", "Study A", "Study B", "Study B", "Study C", "Study C"),
  year = c(2021, 2021, 2022, 2022, 2023, 2023),
  population = rep("Adults with target disease", 6),
  endpoint = rep("Clinical response", 6),
  endpoint_definition = rep("Responder by week 8 composite endpoint", 6),
  timing = rep("Week 8", 6),
  arm = c("Placebo", "Drug A", "Placebo", "Drug B", "Placebo", "Drug C"),
  arm_type = c("placebo", "treatment", "placebo", "treatment",
               "placebo", "treatment"),
  responders = c(12, 29, 8, 24, 15, 36),
  total = c(60, 62, 55, 58, 70, 72),
  count_status = rep("exact", 6),
  source = rep("Synthetic smoke-test data", 6),
  stringsAsFactors = FALSE
)

input_csv <- file.path(out_dir, "endpoint_counts.csv")
write.csv(example_counts, input_csv, row.names = FALSE)

res <- run_meta_analysis(
  input_csv = input_csv,
  output_dir = out_dir,
  endpoint_filter = "response",
  timing_filter = "Week 8"
)

expected <- c(
  "cleaned_counts.csv",
  "definition_audit.csv",
  "pooled_arm_rates.csv",
  "paired_effects.csv",
  "design_benchmarks.csv",
  "forest_rates.pdf",
  "forest_effects.pdf"
)

ok <- all(file.exists(file.path(out_dir, expected)))
cat("SMOKE_SIMPLIFIED_META=", ok, "\n", sep = "")
if (!ok) stop("Smoke test failed: expected outputs were not all created.")
