# Step 01: Define Scope

## Goal

Define a poolable clinical benchmark question before extracting counts.

## Collect

- Indication and population
- Endpoint name and exact endpoint definition
- Endpoint timing
- Arm types to include: placebo, standard of care, active control,
  investigational treatment, or all
- Study phase, era, geography, and line-of-therapy restrictions
- Whether the benchmark supports single-arm H0, active-control assumptions, or
  treatment target selection

## Decision Rules

- If the user asks for a "quick benchmark", keep inclusion rules narrow and
  document assumptions.
- If the endpoint definition is ambiguous, preserve source wording and do not
  pool until comparable definitions are identified.
- If the user provides local CSV counts, inspect the columns before searching.

## Output

Write a short scope summary with inclusion/exclusion assumptions and the planned
CSV filename.
