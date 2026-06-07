###############################################################################
# meta_analysis_template.R
#
# Base R skeleton for clinical binary endpoint meta-analysis. Prefer the
# bundled scripts/R/meta_analysis.R for production use.
###############################################################################

source("scripts/R/meta_analysis.R")

run_meta_analysis(
  input_csv = "endpoint_counts.csv",
  output_dir = "outputs/meta_analysis"
)
