# Step 05: Study Design Analysis

## Goal
Characterize the trial design landscape to support evidence-based design recommendations.

## Inputs
- Compound landscape from Step 03 (trial names, endpoints, SoC benchmark)
- Endpoint framework from Step 04

## Output
- Section 5 content: design pattern table, statistical norms, adaptive design landscape
- Design recommendation for development implications section

## Procedure

### 5.1 Conventional Trial Design Search
- Query: "[indication]" randomized controlled trial design Phase 3 results
- Query: "[indication]" single arm FDA approval clinical trial
- Fetch: Methods sections from 2-3 pivotal trial publications
- For each trial: name, sponsor, NCT, phase, design type, N, randomization, primary endpoint,
  alpha/power, duration, outcome

### 5.2 Adaptive and Master Protocol Search
- Query: "[indication]" adaptive trial Bayesian design
- Query: "[indication]" basket trial OR umbrella trial OR platform trial OR master protocol
- Document: adaptive features, basket/umbrella/platform designs

### 5.3 Single-Arm vs. Controlled Regulatory Precedent

Determine whether single-arm evidence has been accepted for approval in this indication:

**Search method:**
1. Query: site:fda.gov "[indication]" "accelerated approval" OR "single arm"
2. Query: "[indication]" FDA approval "single-arm" OR "uncontrolled" clinical trial
3. Check FDA Drugs@FDA database (https://www.accessdata.fda.gov/scripts/cder/daf/) for approved drugs
   in this indication — read the approval letter and review document to identify pivotal trial design.
4. For each approved drug from Step 03 Table 3.1, check whether the pivotal trial was single-arm
   or controlled (this information should already be captured).

**Determine control arm type:**
- If all approvals used RCTs: note control arm type (placebo, active SoC, best supportive care)
- If any approval used single-arm: note the regulatory pathway (accelerated vs. full approval)
  and whether a confirmatory trial was required
- If no approvals exist: check whether FDA draft guidance recommends specific trial design, or
  search for FDA Advisory Committee transcripts discussing trial design for this indication

**Record as:**
| Question | Answer | Source |
|----------|--------|--------|
| Single-arm precedent for approval? | Yes/No | [FDA approval letter, trial NCT, or guidance doc] |
| Regulatory pathway | Full / Accelerated / Not applicable | [source] |
| Control arm type used | Placebo / Active SoC / BSC / N/A | [pivotal trial(s)] |
| Confirmatory trial required? | Yes/No/N/A | [FDA post-marketing requirement] |

### 5.4 Statistical Norms
- Most common alpha level (one-sided 0.025, two-sided 0.05, exploratory 0.10)
- Power targets (80% vs. 90%)
- Primary analysis method (MMRM, ANCOVA, CMH, logrank)
- MCID used in sample size calculations

## Output Format

### Table 5.1: Trial Design Landscape
| Trial | Drug | Phase | Design | N | Duration | Primary Endpoint | Alpha/Power | Outcome |

### Table 5.2: Master Protocol and Adaptive Designs
| Program | Type | Sponsor | Indications | Adaptive Feature | Status |

### Table 5.3: Statistical Norms Summary
| Parameter | Most Common | Range Observed | Notes |

### Design Recommendation
- Phase 1b/2a: design, N, alpha, endpoint
- Phase 2b: design, N, alpha, endpoint
- Phase 3: RCT, N, alpha 0.025/90% power, endpoint

## Validation Checkpoints
- Document all discoverable pivotal and major trials. For well-studied indications, expect 5+;
  for rare/orphan indications, document all available (even if 1-2) and note the limited landscape.
- Single-arm vs. RCT regulatory precedent explicitly addressed (see 5.3 table)
- Design recommendation is specific with numerical parameters (N, alpha, power, duration, control)

## Next Step
Step 06: Synthesis and Assembly (SKILL.md Step 6)
