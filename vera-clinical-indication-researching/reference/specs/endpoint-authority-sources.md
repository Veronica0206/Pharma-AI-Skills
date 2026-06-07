# Endpoint Authority Sources

## Regulatory Sources
- FDA Drug Guidance: https://www.fda.gov/drugs/guidance-compliance-regulatory-information/guidances-drugs
- FDA Biomarker Qualification: https://www.fda.gov/drugs/drug-development-tool-qualification-programs/biomarker-qualification-program
- EMA Scientific Guidelines: https://www.ema.europa.eu/en/human-regulatory/research-development/scientific-guidelines

## Disease-Specific Sources

Kidney Disease (Nephrology):
- Guideline source: https://kdigo.org/guidelines/ (renal guideline examples)
- ERA: https://www.era-online.org/
- ASN: https://www.asn-online.org/
- Surrogate endpoint development initiative

Immune-Mediated Disease Area:
- ACR: https://www.rheumatology.org/
- EULAR: https://www.eular.org/
- Validated disease activity score — composite example
- Validated damage index example

General:
- COMET Initiative: https://www.comet-initiative.org/
- OMERACT: Outcome Measures in Rheumatology

## Classification Rules

HA-Guided (meet ONE): named in FDA/EMA guidance document; used in approval decision with regulatory review;
formally qualified as surrogate by FDA Biomarker Qualification Program or EMA Qualification Opinion;
endorsed in FDA AdComm transcript with CDER comment.

Community Consensus (meet TWO): primary endpoint in 2+ pivotal trials; endorsed by major society guideline;
multi-stakeholder consensus paper; used by 3+ different sponsors.

Literature Emerging: Phase 1/2 use only, not yet validated against hard outcomes.

## Common Endpoint Definitions

**IMPORTANT**: These definitions are reference examples, not canonical values. Endpoint thresholds
vary by trial sponsor, era, and regulatory negotiation. Before using any definition in a dossier,
verify it against the cited source document and check for more recent updates. Always cite the
specific source in your dossier tables — never present these as uncited facts.

**Last reviewed**: 2026-03-31. Definitions may have been superseded by newer guidance or consensus.

---

Example Renal Indication A:
- UPCR response: >= 40% reduction from baseline (spot urine)
  *Source: [example pivotal trial] primary endpoint definition; also used in [supportive trial].
  Note: some programs use >= 30% (e.g., [example Phase 3 trial]). Confirm current FDA preference via
  guidance or pre-IND meeting feedback.*
- Complete remission: UPCR < 0.3 g/g
  *Source: example working-group convention; threshold aligns with a relevant renal guideline chapter.*
- eGFR slope: annual change (mL/min/1.73m^2/year)
  *Source: relevant indication-specific FDA draft guidance. FDA has
  accepted eGFR slope as a reasonably likely surrogate for accelerated approval.*

Example Renal Indication B:
- Partial remission: UPCR < 1.5 g/g with >= 50% reduction
  *Source: Commonly used in Example Renal Indication B trials (e.g., [example trial], [NCT placeholder]). a surrogate endpoint initiative is working
  toward formal surrogate endpoint validation; thresholds may change.*
- Complete remission: UPCR < 0.3 g/g
  *Source: a relevant renal guideline. Same threshold as a related remission definition.*

Example Immune-Mediated Indication:
- Complete remission: BVAS = 0 at 6 months + no prednisone (or <= 7.5 mg/day in some protocols)
  *Source: [example remission trials]. Prednisone threshold varies by trial.*
- Sustained remission: BVAS = 0 maintained through end of study
  *Source: FDA has accepted sustained remission at protocol-specified follow-up as a primary endpoint in example pivotal programs.*

Example Renal Inflammatory Indication:
- Complete renal response (CRR): UPCR <= 0.5 g/g + eGFR >= 90% of screening (or no decrease >10%)
  *Source: [example pivotal trials] primary endpoint definitions. Relevant draft guidance endorses CRR.*
- Partial renal response: >= 50% UPCR reduction + UPCR <= 3 g/g + eGFR >= 90% baseline
  *Source: ACR/EULAR consensus; used as secondary endpoint in [example pivotal trials].*

---

### Extending This Reference

For indications not listed above, extend this file by therapeutic area:
1. Search FDA guidance documents: site:fda.gov guidance "[indication]" endpoint
2. Search EMA scientific guidelines: site:ema.europa.eu "[indication]" guideline endpoint
3. Identify pivotal trials via ClinicalTrials.gov and extract primary endpoint definitions
4. Search for disease-specific working group consensus or validated response criteria
5. Add entries to this file following the format above, always with source citations
