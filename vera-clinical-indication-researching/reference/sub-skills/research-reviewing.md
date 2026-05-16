# Clinical Indication Research Review via Reviewer-LLM MCP (xhigh reasoning)

Get a multi-round critical review of a clinical indication research dossier from an external LLM
with maximum reasoning depth. Adapted from the statistics research review pattern for clinical
pharmacology content.

## Constants

- REVIEWER_MODEL = `gpt-5.4` when using Codex MCP, or the strongest configured
  reasoning model exposed by the available reviewer-LLM MCP.
- MAX_ROUNDS = 2
- POSITIVE_THRESHOLD: score >= 7/10, or verdict contains "ready" or "sufficient"

## Context: $ARGUMENTS

## Prerequisites

- A reviewer-LLM MCP server configured in the host environment. For example,
  Codex MCP in Claude Code:
  ```bash
  claude mcp add codex -s user -- codex mcp-server
  ```

## Workflow

### Step 1: Gather Dossier Context

Before calling the external reviewer, compile a comprehensive briefing from the dossier sections:

1. Read the assembled dossier content (all tables and narrative from Steps 02-06)
2. Read endpoint-authority-sources.md classification rules and definitions used
3. Read the SoC benchmark summary from Step 03
4. Identify: core claims, endpoint classifications, SoC benchmarks, design recommendations, known gaps

Package this into a single structured context block. The external model cannot read your files —
you must send everything it needs to evaluate.

### Step 2: Initial Review (Round 1)

Send a detailed prompt with xhigh reasoning:

```
mcp__codex__codex:
  config: {"model_reasoning_effort": "xhigh"}
  prompt: |
    [Round 1/2 of clinical indication research review]

    You are reviewing a clinical indication research dossier for [indication].
    This dossier will inform drug development strategy and clinical trial design decisions.

    [Full dossier content: MoA landscape table + narrative, compound landscape tables + SoC
    benchmark, endpoint classification tables, study design tables + recommendations,
    development implications section]

    Please act as a senior clinical pharmacology reviewer with regulatory affairs expertise
    (FDA/EMA submission experience).

    Evaluate this dossier on the following dimensions:

    **1. Factual Accuracy (weight: 30%)**
    - Are compound names, trial names, NCT numbers, and approval dates correct?
    - Are efficacy numbers accurately attributed to specific trials?
    - Are any claims made without citation or source?
    - Are failed programs correctly identified?

    **2. Endpoint Classification Rigor (weight: 25%)**
    - Is every HA-Guided classification traceable to a specific FDA/EMA document?
    - Are Community Consensus classifications supported by 2+ independent criteria?
    - Are any endpoints misclassified (e.g., Literature Emerging labeled as HA-Guided)?
    - Are endpoint definitions precise and sourced?

    **3. SoC Benchmark Validity (weight: 20%)**
    - Is the selected SoC benchmark from the most clinically relevant approved therapy?
    - Is the benchmark endpoint metric consistent with the recommended primary endpoint?
    - If multiple benchmarks exist, are they properly reported with rationale for selection?
    - Is the same benchmark used consistently for both single-arm H0 and H2H control arm?

    **4. Regulatory Precedent Accuracy (weight: 15%)**
    - Is the single-arm vs. controlled regulatory precedent correctly characterized?
    - Are regulatory pathway descriptions accurate (accelerated vs. full approval)?
    - Are design recommendations consistent with what regulators have accepted?

    **5. Synthesis Quality (weight: 10%)**
    - Does the Development Implications section logically connect MoA → compound → endpoint → design?
    - Are differentiation opportunities specific and actionable?
    - Is the overall narrative coherent and free of contradictions?

    Score this dossier 1-10 for use in informing clinical development strategy.
    List remaining critical weaknesses (ranked by severity).
    For each weakness, specify the MINIMUM fix (additional search, reclassification,
    benchmark correction, or narrative revision).
    State clearly: is this READY to inform development decisions? Yes/No/Almost.

    Be rigorous. Incorrect endpoint classification or SoC benchmarks can misguide
    a multi-million dollar clinical program.
```

### Step 3: Iterative Dialogue (Round 2)

Use `mcp__codex__codex-reply` with the returned `threadId`:

Key follow-up patterns for clinical indication research:
- "We reclassified endpoint X from HA-Guided to Community Consensus because [reason]. Is this correct?"
- "The SoC benchmark was updated from Drug A (60%) to Drug B (55%) because [reason]. Does this change your assessment?"
- "We added [missing trial/compound] to the landscape. Does this address your coverage concern?"
- "Please verify this endpoint definition against current FDA guidance: [paste definition]"
- "Is our single-arm regulatory precedent assessment correct given [new evidence found]?"
- "Does the design recommendation (Phase 2: [design], Phase 3: [design]) align with regulatory precedent?"

### Step 4: Convergence

Stop iterating when:
- Score >= 7/10 AND verdict is positive → dossier is ready
- Round 2 completed → max iterations reached (document remaining issues for user)
- All factual errors corrected and classifications verified

### Step 5: Document Everything

Save the full interaction and conclusions to `AUTO_REVIEW.md`:
- Round-by-round summary of criticisms and responses
- Final consensus on endpoint classifications and SoC benchmarks
- Corrections made (with before/after)
- Remaining issues flagged for user attention
- Final score and verdict

## Key Rules

- ALWAYS use `config: {"model_reasoning_effort": "xhigh"}`
- Send comprehensive context in Round 1 — the external model cannot read your files
- Be honest about gaps — hiding weak sourcing leads to worse feedback
- Focus on FACTUAL ACCURACY above all — incorrect claims are the highest risk
- Endpoint classification errors are the second highest risk — always request verification
- The review document should be self-contained
- Do NOT fabricate sources to satisfy reviewer concerns — note "data not publicly available" if needed

## Prompt Template for Round 2

```
mcp__codex__codex-reply:
  threadId: [saved from round 1]
  config: {"model_reasoning_effort": "xhigh"}
  prompt: |
    [Round 2 update]

    Since your last review, we have:
    1. [Action 1]: [result — e.g., "Reclassified eGFR slope from Community Consensus to
       HA-Guided based on FDA Draft Guidance 'IgA Nephropathy: Developing Drugs' (2023)"]
    2. [Action 2]: [result — e.g., "Updated SoC benchmark from sparsentan 49.8% to
       ixazomib 40.2% (more conservative, most recent Phase 3)"]
    3. [Action 3]: [result — e.g., "Added PROTECT trial (NCT03762850) to compound landscape
       — previously missing Phase 3 program"]

    Updated dossier sections:
    [paste corrected tables/narrative]

    Please re-score and re-assess. Are the remaining concerns addressed?
    Same format: Score, Verdict, Remaining Weaknesses, Minimum Fixes.
```

## Fix Categories for Clinical Indication Research

Unlike statistical research (which involves proof corrections and new simulations), fixes for
indication research dossiers fall into these categories:

| Fix Category | Action | Dossier Section Affected |
|--------------|--------|--------------------------|
| Factual correction | Fix compound name, trial result, approval date | Sections 2-5 |
| Missing compound/trial | Additional search + add to landscape table | Section 3 |
| Endpoint reclassification | Change authority level with updated sourcing | Section 4 |
| SoC benchmark revision | Select different benchmark per selection rule | Section 3 + 5 |
| Regulatory precedent update | Additional search for approval letters/guidance | Section 5 |
| Narrative revision | Rewrite synthesis to fix logic or add nuance | Section 6 |
| Source addition | Find and cite missing authority document | Any section |
