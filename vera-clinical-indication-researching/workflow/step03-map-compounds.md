# Step 03: Compound Landscape Research

## Goal
Build a comprehensive competitive intelligence map of approved and investigational compounds,
with efficacy, safety, and regulatory data to serve as benchmarking foundation for trial design.

## Inputs
- Confirmed indication and MoA landscape from Step 02

## Output
- Section 3 content: approved drugs table, pipeline tables by phase
- SoC efficacy benchmarks (used in Step 05 for trial design)

## Procedure

### 3.1 Approved Drugs
- Query: "[indication] FDA approved drug treatment"
- Query: "[indication] EMA approved therapy label"
- Fetch: FDA drug label or approval press release; pivotal trial publication
- Document: generic name, brand, sponsor, mechanism, primary endpoint + result (= SoC benchmark),
  key secondary results, safety summary, approval year + type

### 3.2 Phase 3 Pipeline
- Query: "[indication] Phase 3 clinical trial [Y-2] [Y-1] [Y]"
  (Replace [Y] with current year; see search-strategies.md for year filter convention)
- Fetch: ClinicalTrials.gov Phase 3 search + trial publications/press releases

### 3.3 Phase 1/2 Pipeline
- Query: "[indication] Phase 2 clinical trial novel mechanism [Y-1] [Y]"
- Fetch: ClinicalTrials.gov Phase 1/2 search + conference abstracts (ASN, ERA, ACR)

### 3.4 Competitive Dynamics Synthesis
- Which MoA classes are most crowded?
- Which approved drugs set the efficacy bar?
- Any recently failed Phase 3 programs? (critical for design realism)

## Output Format

### Table 3.1: Approved Therapies
| Drug | Mechanism | Sponsor | Approved | Primary Endpoint (Pivotal) | Result | Key Safety |

### Table 3.2: Phase 3 Pipeline
| Drug | Mechanism | Sponsor | Trial | Status | Primary Endpoint | Phase 2 Signal |

### Table 3.3: Phase 1/2 Pipeline
| Drug | Mechanism | Sponsor | NCT | Phase | Status | Latest Data |

### SoC Benchmark Summary (feeds Step 05 trial design)
| Design type | Benchmark | Source | Metric |
| Single-arm vs. SoC | [SoC response rate] | [Trial, year] | [endpoint] |
| H2H control arm | [SAME SoC rate] | [same trial] | [same metric] |

IMPORTANT: Single-arm H0 and H2H control arm rate MUST use the same SoC benchmark value.

### SoC Benchmark Selection Rule

When multiple approved drugs exist with different efficacy rates, select the benchmark using this
priority order:

1. **Most clinically relevant SoC**: the drug most widely used as first-line therapy in the target
   population. Check recent treatment guidelines (KDIGO, ACR, NCCN, etc.) for recommended first-line.
2. **Most recent approval with same primary endpoint**: if two drugs share the same endpoint metric,
   prefer the one approved more recently (reflects current regulatory expectations).
3. **Closest match to planned endpoint**: if your planned primary endpoint differs from some drugs'
   pivotal endpoint, use only drugs whose pivotal trial used the same endpoint metric.
4. **Conservative benchmark (higher bar)**: when two candidates are equally valid, prefer the higher
   efficacy rate — this produces a more conservative (harder to beat) H0 for single-arm designs and
   a more realistic control arm estimate for H2H designs.

If no single benchmark is defensible, report 2-3 candidate benchmarks in the SoC table with a note
explaining the range, and carry all candidates forward to Step 05 as sensitivity scenarios.

## Validation Checkpoints
- At least 1 approved drug documented (or explicit note if none exists)
- SoC benchmark explicitly identified for primary endpoint type
- Failed Phase 3 programs noted if any exist

## Next Step
Step 04: Endpoint Framework Research
