---
name: vera-clinical-indication-researching
description: >-
  Performs comprehensive clinical indication research for drug-development and
  trial-planning dossiers. Given a disease indication, it researches mechanism
  landscape, approved and pipeline compounds, endpoint authority, study-design
  precedents, and SoC benchmarks, then assembles a cited dossier with optional
  structured review. Activates for indication research, indication landscape,
  disease landscape, clinical landscape, compound landscape, MoA landscape,
  endpoints for indication, or clinical dossier requests.
---

# Clinical Indication Research Skill

A biostatistician's research tool for drug development and clinical trial planning. Related design
tools: `vera-clinical-trial-designing` and `vera-master-trial-designing`.

Transforms a disease indication into a publication-quality clinical research dossier covering mechanism
landscape, competitive intelligence, endpoint framework, and study design patterns — sourced from current
regulatory guidance, trial registries, and medical literature.

## What This Skill Automates vs. What Requires Human Judgment

This skill handles the **systematic research and assembly engine** for clinical indication intelligence. Everything below runs automatically once the indication is specified:

- Multi-source literature search across PubMed, ClinicalTrials.gov, FDA/EMA guidance databases
- MoA landscape mapping (all mechanistic targets and pathways under investigation)
- Compound cataloging with efficacy benchmarks and development stage tracking
- Endpoint classification into authority tiers (HA-Guided, Community Consensus, Literature Emerging)
- Study design pattern extraction from existing trials
- Structured dossier assembly with cross-referenced tables and narratives
- Optional external adversarial review (via delegated reviewer if configured; structured self-review otherwise)

**What this skill does NOT automate — and where the biostatistician's judgment remains essential:**

- **Endpoint authority assessment.** The skill classifies endpoints into authority tiers, but judging whether a "Community Consensus" endpoint is strong enough to support a registration strategy — or whether to wait for HA guidance — requires regulatory experience and risk tolerance judgment.
- **SoC benchmark selection.** The skill catalogs published efficacy data, but deciding which trial's control arm rate is the right H0 for your design requires understanding which patient population, which line of therapy, and which era of treatment is most relevant. The same indication can have five different "SoC benchmarks" depending on these choices.
- **Competitive positioning.** The skill maps the landscape. But deciding where a new compound can differentiate — novel MoA, better safety, faster onset, underserved subpopulation, superior endpoint strategy — is strategic judgment that integrates clinical, commercial, and regulatory considerations.
- **Development go/no-go recommendation.** The dossier provides all the evidence. But the final call — "should we develop this drug for this indication?" — weighs unquantifiable factors: sponsor appetite for risk, portfolio balance, competitive timing, patent runway, manufacturing feasibility.
- **Translating research into trial design parameters.** The dossier's SoC benchmarks and endpoint selections feed directly into `vera-clinical-trial-designing` as H0, H1, and endpoint type. But the act of translating a landscape into specific design parameters — "given this competitive landscape, we should power for superiority at this margin" — is the bridge that only an experienced biostatistician walks.

The machine part is done. The judgment part is yours.

## Host Runtime Notes

- Works in Claude Code, Codex, and other web-capable coding agents.
- Use current web browsing/search tools for clinical, regulatory, and pipeline
  facts. Prefer primary sources such as labels, regulatory reviews, trial
  registries, guidance, and peer-reviewed publications.
- Optional document-rendering tools can create `.docx` or `.pdf`; if unavailable,
  deliver Markdown.
- Optional delegated review in Step 07 can be used when configured;
  otherwise perform the structured self-review fallback.

## Table of Contents

1. [When to Use](#when-to-use)
2. [Workflow Overview](#workflow-overview)
3. [Workflow Table](#workflow-table)
4. [Step-by-Step Instructions](#step-by-step-instructions)
5. [Output Structure](#output-structure)
6. [Quality Standards](#quality-standards)
7. [Configuration Options](#configuration-options)
8. [Error Handling](#error-handling)

---

## When to Use

Use this skill when:
- Planning a clinical development program for a new indication
- Conducting competitive intelligence before Phase 2/3 design
- Identifying FDA/EMA-endorsed or community-consensus endpoints for a disease
- Understanding what MoA classes are being explored for a condition
- Benchmarking study designs (single-arm vs. controlled, adaptive vs. conventional)
- Building a clinical rationale section for a regulatory brief or IND

---

## Workflow Overview

```
Indication Input
    |
Step 1:  Clarify Scope and Parameters
    |
Step 2:  MoA Landscape Research      -> All mechanistic targets and pathways
    |
Step 3:  Compound Landscape          -> Approved + pipeline drugs
    |
Step 4:  Endpoint Framework          -> Primary + key secondary endpoints
    |
Step 5:  Study Design Analysis       -> Design patterns from existing trials
    |
Step 6:  Synthesis and Assembly      -> Structured Word/PDF dossier
    |
Step 7: Structured Review  -> Factual/classification quality check
    |
Step 8:  Deliver                     -> Final file + executive summary
```

Read each step file in workflow/ before executing that step.

---

## Workflow Table

| Step | Responsibility | Executor | Document | Input | Output |
|------|----------------|----------|----------|-------|--------|
| 01 | Clarify indication scope | Main Agent | `workflow/step01-clarify-inputs.md` | User request | Confirmed params |
| 02 | MoA landscape research | Main Agent | `workflow/step02-research-moa.md` | Indication | MoA table + narrative |
| 03 | Compound landscape | Main Agent | `workflow/step03-map-compounds.md` | MoA classes | Compound tables |
| 04 | Endpoint framework | Main Agent | `workflow/step04-build-endpoints.md` | Compound list | Endpoint tables |
| 05 | Study design analysis | Main Agent | `workflow/step05-analyze-designs.md` | Endpoint framework | Design table |
| 06 | Synthesis and assembly | Main Agent | `workflow/step06-synthesize-dossier.md` | All sections | Final .docx, .pdf, or .md (per Step 01 1.2b early delivery check; markdown is the fallback if neither docx nor pdf skill is available) |
| 07 | Structured review | Main Agent | `workflow/step07-review-dossier.md` | Assembled dossier | Reviewed + corrected dossier |
| 08 | Deliver results | Main Agent | `workflow/step08-deliver-results.md` | Final dossier | Saved file (.docx, .pdf, or .md) + executive summary |

---

## Step-by-Step Instructions

### STEP 1: Clarify Inputs

Read workflow/step01-clarify-inputs.md before executing this step.

Goal: Collect and confirm indication, focus compound, output format, depth, and population scope.
See the workflow file for the full parameter table, decision rules, and confirmation format.

If the user gives only the indication and says go, use defaults and proceed.

---

### STEP 2: MoA Landscape Research

Read workflow/step02-research-moa.md before executing this step.

Goal: Identify all mechanistic classes being investigated for this indication.
Use reference/specs/search-strategies.md Section 2 queries.

Announce: "Researching MoA landscape for [indication]..."

---

### STEP 3: Compound Landscape Research

Read workflow/step03-map-compounds.md before executing this step.

Goal: Catalog approved and investigational compounds with efficacy/safety profiles and SoC benchmarks.
Use reference/specs/search-strategies.md Section 3 queries.

Critical: SoC efficacy benchmark from this step MUST be the same value used as H0 in single-arm designs
and as the expected control arm rate in H2H designs.

Announce: "Researching compound landscape for [indication]..."

---

### STEP 4: Endpoint Framework Research

Read workflow/step04-build-endpoints.md before executing this step.

Goal: Establish endpoint classification (HA-Guided, Community Consensus, or Literature Emerging).
Use reference/specs/endpoint-authority-sources.md for authority source directory and definitions.
Use reference/specs/search-strategies.md Section 4 queries.

Announce: "Researching endpoint framework for [indication]..."

---

### STEP 5: Study Design Analysis

Read workflow/step05-analyze-designs.md before executing this step.

Goal: Characterize trial design patterns, statistical norms, and adaptive design landscape.
Use reference/specs/search-strategies.md Section 5 queries.

Announce: "Researching study designs for [indication]..."

---

### STEP 6: Synthesis and Document Assembly

Read reference/templates/dossier-outline.md for document structure.

**6a. Synthesize findings** — connect MoA to compounds to endpoints to designs into a coherent narrative:

1. **MoA-to-Compound linkage**: Which MoA classes have the most validated compounds? Which are crowded vs. white-space?
2. **Compound-to-Endpoint linkage**: What endpoints do the leading programs use? Does the SoC benchmark come from the most relevant approved drug?
3. **Endpoint-to-Design linkage**: What benchmark response rates inform single-arm H0? Which endpoints have regulatory precedent for approval?
4. **Design architecture**: What design patterns (single-arm, RCT, adaptive) have regulatory precedent? What statistical norms apply?

Write the Development Implications section (dossier Section 6) by answering:
- 6.1 Differentiation Opportunities: Where can a new entrant differentiate — novel MoA, better safety, faster onset, underserved subpopulation, or superior endpoint strategy?
- 6.2 Endpoint Selection Recommendation: Recommend primary endpoint with rationale tied to authority classification and regulatory precedent. If HA-Guided endpoint exists, default to it. If only Community Consensus, justify why it is sufficient.
- 6.3 Trial Design Recommendation: Recommend Phase 2 and Phase 3 designs with specific parameters (N, alpha, power, duration, control arm) grounded in Step 05 findings and SoC benchmark from Step 03.

**6b. Assemble document** using the docx or pdf skill:

> **Note:** Output format availability should have been verified in Step 01 (section 1.2b).
> If the agent reaches this step and discovers the required skill is unavailable, fall back to markdown.

For Word output: use the host's available document-generation workflow to
produce the final document. For PDF output: use the host's available PDF or
document-rendering workflow.

Filename: `indication_dossier_[indication_slug]_[YYYY-MM-DD].docx` (or `.pdf` or `.md`)
Save to the current working directory or the user's preferred output location.

If neither docx nor pdf skill is available, output the full dossier as markdown and inform the user
that formatted export requires the docx or pdf skill.

---

### STEP 7: Structured Review

Read workflow/step07-review-dossier.md before executing this step.

Goal: Cross-check dossier factual accuracy, endpoint classifications, and SoC
benchmarks using a delegated reviewer. If a delegated reviewer is
available in the host environment, use it; otherwise fall back to a structured
self-review using the same evaluation dimensions.

- MAX_ROUNDS = 2 (lighter than stat pipeline — this is research synthesis, not proof verification)
- Reviewer evaluates on: factual accuracy (30%), endpoint classification rigor (25%), SoC benchmark
  validity (20%), regulatory precedent accuracy (15%), synthesis quality (10%)
- Fixes are implemented between rounds (reclassifications, missing compounds, source corrections)
- Outputs: `AUTO_REVIEW.md` (cumulative log) + `REVIEW_STATE.json` (state persistence)

**Skip this step** if the user requests quick output. The fallback self-review path is the default
when no delegated reviewer is configured.

Announce: "Running delegated review of dossier for [indication]..."

---

### STEP 8: Deliver

1. Save the final file to the working directory (or user-specified path)
2. Provide 5-bullet executive summary:
   - MoA landscape highlight
   - SoC efficacy benchmark (the key number for trial design)
   - Recommended primary endpoint
   - Recommended trial design
   - Key differentiation opportunity (if focus compound specified)
3. Offer to expand, add competitor deep-dive, or model trial design with sample size calculations.

---

## Output Structure

| Section | Content | Format |
|---------|---------|--------|
| MoA Landscape | Target table + narrative | Table + prose |
| Compound Landscape | Approved + pipeline tables | Tables + narrative |
| Endpoint Framework | HA-guided vs. community classification | Tables |
| Study Designs | Trial design table + statistical norms | Table + analysis |
| Development Implications | Strategic synthesis | Prose |

---

## Quality Standards

Sourcing: minimum 3 unique sources per section (15+ total); prioritize FDA/EMA guidance,
ClinicalTrials.gov, PubMed, KDIGO/ACR/ERA guidelines; at least 40% from past 3 years;
flag outdated data (>5 years).

Endpoint classification rigor: only classify as HA-Guided if traceable FDA/EMA document exists;
distinguish traditional vs. accelerated approval acceptance; note if endpoint used in successful vs. failed trial.

Compound data accuracy: report efficacy metric matching trial primary endpoint; distinguish Phase 2
signal from Phase 3 confirmatory; always flag failed Phase 3 programs.

Writing: prose in narrative sections; tables for comparative data; no filler phrases; cite every
efficacy number with specific trial name and year.

---

## Configuration Options

| Option | Values | Default |
|--------|--------|---------|
| Output format | docx, pdf, md | docx if export tooling is available; otherwise md |
| Depth | standard, deep | deep |
| Focus MoA/compound | any class or drug name | none |
| Population | adult, pediatric, both | adult |
| Include executive summary | yes, no | yes |
| Endpoint classification | full, primary-only | full |
| Include failed trials | yes, no | yes |
| delegated review (delegated reviewer, optional) | yes, no, self-only | yes |

---

## Error Handling

Rare disease with limited data: expand search to analogous disease class; include compassionate use
or real-world evidence; note data limitations explicitly.

Conflicting endpoint definitions: show both in table; note which definition leading programs use;
flag if field is converging or fragmented.

No FDA/EMA guidance available: classify all endpoints as Community Consensus or Literature Emerging;
search FDA Advisory Committee transcripts; reference KDIGO or disease-specific working group documents.

Compound data unavailable: note "data not publicly available" — do not fabricate; use ClinicalTrials.gov
registration data as minimum floor.

Delegated reviewer unavailable: fall back to structured self-review using the same 5 evaluation dimensions
(see workflow/step07-review-dossier.md). Document self-review in AUTO_REVIEW.md.

---

## Quick Start

User: "[indication] indication research" / "comprehensive research on [indication]" / "disease landscape for [indication]"
Skill: clarify scope -> MoA landscape -> compound landscape -> endpoint framework -> study designs -> synthesis -> delegated review -> deliver
Total time: approximately 15-25 minutes (deep mode, without delegated review); 20-35 minutes (with delegated reviewer-LLM via MCP).
