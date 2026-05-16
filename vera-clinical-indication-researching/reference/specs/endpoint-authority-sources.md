# Endpoint Authority Sources

## Regulatory Sources
- FDA Drug Guidance: https://www.fda.gov/drugs/guidance-compliance-regulatory-information/guidances-drugs
- FDA Biomarker Qualification: https://www.fda.gov/drugs/drug-development-tool-qualification-programs/biomarker-qualification-program
- EMA Scientific Guidelines: https://www.ema.europa.eu/en/human-regulatory/research-development/scientific-guidelines

## Disease-Specific Sources

Kidney Disease (Nephrology):
- KDIGO: https://kdigo.org/guidelines/ (IgAN 2021, GN, CKD, Transplant)
- ERA: https://www.era-online.org/
- ASN: https://www.asn-online.org/
- PARASOL Initiative (FSGS surrogate endpoint development)

Rheumatology / Vasculitis:
- ACR: https://www.rheumatology.org/
- EULAR: https://www.eular.org/
- BVAS (Birmingham Vasculitis Activity Score) — validated composite for ANCA vasculitis
- VDI (Vasculitis Damage Index)

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

IgA Nephropathy:
- UPCR response: >= 40% reduction from baseline (spot urine)
  *Source: TESTING (NCT04578834) primary endpoint definition; also used in NefIgArd (NCT03643965).
  Note: some programs use >= 30% (e.g., PROTECT, NCT03762850). Confirm current FDA preference via
  guidance or pre-IND meeting feedback.*
- Complete remission: UPCR < 0.3 g/g
  *Source: IgAN working group convention; threshold aligns with KDIGO 2021 GN guideline Chapter 3.*
- eGFR slope: annual change (mL/min/1.73m^2/year)
  *Source: FDA Draft Guidance "IgA Nephropathy: Developing Drugs for Treatment" (2023). FDA has
  accepted eGFR slope as a reasonably likely surrogate for accelerated approval.*

FSGS:
- Partial remission: UPCR < 1.5 g/g with >= 50% reduction
  *Source: Commonly used in FSGS trials (e.g., DUET, NCT02235857). PARASOL initiative is working
  toward formal surrogate endpoint validation; thresholds may change.*
- Complete remission: UPCR < 0.3 g/g
  *Source: KDIGO 2021 GN guideline. Same threshold as general nephrotic syndrome remission.*

ANCA Vasculitis:
- Complete remission: BVAS = 0 at 6 months + no prednisone (or <= 7.5 mg/day in some protocols)
  *Source: RAVE (NCT00104299) and RITUXVAS definitions. Prednisone threshold varies by trial.*
- Sustained remission: BVAS = 0 maintained through end of study
  *Source: FDA has accepted sustained remission at 12-18 months as primary endpoint (e.g., ADVOCATE,
  NCT02994927 used BVAS remission at 26 and 52 weeks).*

Lupus Nephritis:
- Complete renal response (CRR): UPCR <= 0.5 g/g + eGFR >= 90% of screening (or no decrease >10%)
  *Source: AURORA (NCT03021499) and BLISS-LN (NCT01639339) primary endpoint definitions. FDA 2024
  Draft Guidance "Lupus Nephritis: Developing Drugs for Treatment" endorses CRR.*
- Partial renal response: >= 50% UPCR reduction + UPCR <= 3 g/g + eGFR >= 90% baseline
  *Source: ACR/EULAR consensus; used as secondary endpoint in AURORA and BLISS-LN.*

---

### Extending This Reference

For indications not listed above (oncology, cardiovascular, CNS, infectious disease, etc.):
1. Search FDA guidance documents: site:fda.gov guidance "[indication]" endpoint
2. Search EMA scientific guidelines: site:ema.europa.eu "[indication]" guideline endpoint
3. Identify pivotal trials via ClinicalTrials.gov and extract primary endpoint definitions
4. Search for disease-specific working group consensus (e.g., RECIST for oncology, NYHA for heart failure)
5. Add entries to this file following the format above, always with source citations
