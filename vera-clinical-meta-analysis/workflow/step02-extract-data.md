# Step 02: Extract Data

## Goal

Create one clean row per study arm using exact responder/overall counts.

## Required Columns

Use `reference/templates/endpoint_counts_template.csv`.

- `study_id`
- `study`
- `year`
- `population`
- `endpoint`
- `endpoint_definition`
- `timing`
- `arm`
- `arm_type`
- `responders`
- `total`
- `count_status`
- `source`

## Extraction Rules

- Prefer primary articles, labels, regulatory reviews, and registry results.
- Keep exact x/N counts; avoid percentages-only rows.
- Reconstruct counts only when the denominator is explicit, and set
  `count_status = reconstructed`.
- Keep each active arm as a separate row unless the source explicitly pools arms.
- For paired comparative summaries, ensure treatment and control rows share the
  same `study_id`, endpoint, and timing.

## Output

Save the extracted CSV as `endpoint_counts.csv` or another descriptive filename.
