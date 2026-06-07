# Step 04: Endpoint Framework Research

## Goal
Establish a definitive endpoint framework for the indication, classifying endpoints by authority source
(HA-Guided, Community Consensus, or Literature Emerging), type, and regulatory track record.

## Inputs
- Indication confirmed from Step 01
- Compound list and primary endpoints from Step 03

## Output
- Section 4 content: endpoint classification tables + regulatory notes
- Endpoint recommendation feeding Step 05

## Endpoint Classification Key

Use the definitive classification rules in **reference/specs/endpoint-authority-sources.md § Classification Rules**.
Summary for quick reference (the authority-sources file is the single source of truth):

- **HA-Guided** (meet ONE): named in FDA/EMA guidance; used in approval decision with regulatory review;
  formally qualified by FDA Biomarker Qualification Program or EMA Qualification Opinion;
  endorsed in FDA AdComm transcript with CDER comment.
- **Community Consensus** (meet TWO): primary endpoint in 2+ pivotal trials; endorsed by major society guideline;
  multi-stakeholder consensus paper; used by 3+ different sponsors.
- **Literature Emerging**: Phase 1/2 use only; single sponsor; not yet validated against hard outcomes.

If classification is ambiguous, consult the authority-sources file for the full criteria and apply them strictly.

## Procedure

### 4.1 Regulatory Guidance Search
- Query: FDA guidance "[indication]" endpoint OR "FDA guidance [disease class] endpoint"
- Query: EMA guideline "[indication]" clinical trial endpoints
- Query: "[indication]" "FDA qualification" endpoint surrogate
- Fetch: Relevant FDA guidance document; relevant EMA reflection paper
- See reference/specs/endpoint-authority-sources.md for source directory

### 4.2 Professional Society Consensus Search
- Query: "KDIGO" [indication] endpoints (for kidney diseases)
- Query: "[ACR/ERA/BSR/ASN]" [indication] outcome measures consensus
- Fetch: Most recent KDIGO guideline chapter (nephrology); most recent society consensus paper

### 4.3 Trial Registry Cross-Reference
- For each trial in compound landscape, extract primary endpoint exact definition

### 4.4 PRO and Patient-Reported Outcomes
- Query: "[indication]" "patient reported outcome" validated instrument

### 4.5 Biomarker and Surrogate Endpoint Search
- Query: "[indication]" biomarker "surrogate endpoint" validation

## Output Format

### Table 4.1: Primary Endpoint Options
| Endpoint | Type | Authority | Definition | Validated for Approval? | Used in N Trials | Notes |
Type: Binary / Continuous / TTE | Authority: HA-Guided / Community Consensus / Literature Emerging

### Table 4.2: Key Secondary Endpoints
| Endpoint | Category | Rationale | Standard Instrument/Threshold |

### Table 4.3: Regulatory Notes
| Regulatory Pathway | Endpoint Used | Status | Implication |

## Validation Checkpoints
- At least 1 HA-Guided endpoint identified (or explicit statement that none exists)
- Every endpoint has a precise definition; authority traceable to cited document
- Endpoint type (Binary/Continuous/TTE) specified for each

## Next Step
Step 05: Study Design Analysis
