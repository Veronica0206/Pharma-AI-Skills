# Search Strategies

Replace [indication] with exact disease name in all queries.

## Year Filter Convention

All year-filtered queries use a rolling window: **current year and 3 prior years**.
At execution time, compute the window: if current year is Y, use `Y-3 OR Y-2 OR Y-1 OR Y`.

Example: if running in 2026, year filter = `2023 OR 2024 OR 2025 OR 2026`.

Never hard-code a fixed year range. Always compute from the current date.

---

## Section 1: Indication Scoping

Use these queries during **Step 01** to confirm the indication is well-defined and to detect common
ambiguities before launching the full landscape research. Goal: surface alternate indication names,
the standard ICD-10 / MeSH / SNOMED codings, the major patient subpopulations, and any disease-staging
or severity scoring conventions that downstream sections will need to respect.

"[indication]" disease overview epidemiology
"[indication]" ICD-10 OR MeSH OR SNOMED code
"[indication]" subtypes OR classification OR staging
"[indication]" patient population "line of therapy"
"[indication]" "burden of disease" OR "unmet need" review [Y-3] OR [Y-2] OR [Y-1] OR [Y]
site:pubmed.ncbi.nlm.nih.gov "[indication]" review epidemiology [Y-3] OR [Y-2] OR [Y-1] OR [Y]

If the indication is rare or has multiple naming conventions (e.g., "AAV" vs. "ANCA-associated vasculitis"),
record both forms and use whichever returns more results in subsequent sections. If the indication has
distinct severity strata that drive different trial designs (e.g., "mild-to-moderate" vs. "severe"
ulcerative colitis), record those strata explicitly — Sections 4 and 5 will need them.

## Section 2: MoA Landscape
"[indication] pathophysiology therapeutic targets review"
"[indication] mechanism of action novel therapy pipeline [Y-1] OR [Y]"
"[indication] Breakthrough Designation FDA mechanism"
site:pubmed.ncbi.nlm.nih.gov "[indication]" review mechanism [Y-3] OR [Y-2] OR [Y-1] OR [Y]

## Section 3: Compound Landscape
Approved: "[indication]" "FDA approved" drug site:fda.gov
Pipeline: "[indication]" "phase 3" clinical trial [Y-2] OR [Y-1] OR [Y]
           "[indication]" "phase 2" results interim [Y-1] OR [Y]
ClinicalTrials.gov: https://clinicaltrials.gov/search?cond=[indication]&phase=2,3

## Section 4: Endpoint Framework
site:fda.gov guidance "[indication]" endpoint
"EMA guideline" "[indication]" endpoint OR outcome
"KDIGO" "[indication]" endpoint OR outcome [Y-3] OR [Y-2] OR [Y-1] OR [Y]
"[indication]" endpoint consensus "working group" OR "task force"
"FDA advisory committee" "[indication]" endpoint transcript

## Section 5: Study Designs
"[indication]" randomized controlled trial design Phase 3 results
"[indication]" single arm Phase 2 FDA approval
"[indication]" basket trial OR umbrella trial OR platform trial
"[indication]" trial "alpha" "power" "sample size"

## Tips
- Combine synonyms: "IgA nephropathy" OR "IgAN" OR "Berger disease"
- Year filter: always use rolling window [Y-3] OR [Y-2] OR [Y-1] OR [Y]
- Nephrology sources: JASN, AJKD, Kidney International, CJASN, NDT, ASN Kidney Week abstracts
- Transplant sources: American Journal of Transplantation, Banff classification updates
- Conference abstracts: search society websites directly (e.g., ASN abstracts at asn-online.org, ERA abstracts at era-online.org)
- Deep mode: for each section, run 6-10 queries by adding synonym variants and narrowing by journal or trial phase
