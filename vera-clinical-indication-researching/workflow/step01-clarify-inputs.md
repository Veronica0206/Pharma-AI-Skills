# Step 01: Clarify Scope and Parameters

## Goal
Collect and confirm all parameters needed before beginning research, ensuring the dossier scope
is well-defined and the agent has unambiguous instructions for Steps 02-06.

## Inputs
- User request (may be as brief as an indication name)

## Output
- Confirmed parameter set for all downstream steps

## Procedure

### 1.1 Required Parameters

| Parameter | Question | Default |
|-----------|----------|---------|
| Indication | Exact disease name or subtype? (e.g., "IgA nephropathy", "primary FSGS") | *required — no default* |

### 1.2 Optional Parameters

| Parameter | Question | Default |
|-----------|----------|---------|
| Focus compound/class | Is there a specific MoA or compound you are developing? | None |
| Output format | Word (.docx), PDF, or Markdown? | docx (see note below) |
| Depth | Standard (3-5 searches/section) or Deep (6-10 searches)? | Deep |
| Population scope | Adult only, pediatric, or both? | Adult |
| Include executive summary | Include a 1-page executive summary at the front? | Yes |
| Endpoint classification | Full (primary + secondary + biomarker) or primary-only? | Full |
| Include failed trials | Document failed Phase 3 programs in compound landscape? | Yes |

### 1.2b Early Delivery Check

Before proceeding, verify that the requested output format is achievable:
- If output format is **docx**: check that document-generation tooling is available. If not, inform the user and switch to **markdown**.
- If output format is **pdf**: check that PDF or document-rendering tooling is available. If not, inform the user and switch to **markdown**.
- If neither formatting skill is available, set output format to **markdown** and inform the user upfront.

This prevents completing all research steps only to discover at assembly time that the requested format is unavailable.

### 1.3 Decision Rules

- If the user provides only the indication and says "go" or similar, use all defaults.
- If the user specifies a focus compound, ensure you understand both the compound name AND its MoA
  class — ask if unclear, as this affects Step 02 (MoA deep-dive) and Step 06 (differentiation).
- If the indication name is ambiguous (e.g., "kidney disease"), ask for the specific subtype.
  Provide examples: "Do you mean IgA nephropathy, FSGS, membranous nephropathy, or another?"
- If the user asks for "quick" or "overview", set Depth = Standard.

### 1.4 Confirmation

Before proceeding to Step 02, confirm the parameter set with the user in a brief summary:

> **Confirmed scope:**
> - Indication: [name]
> - Focus: [compound/class or "none"]
> - Depth: [standard/deep]
> - Population: [adult/pediatric/both]
> - Output: [docx/pdf]
>
> Proceeding to MoA landscape research...

If the user gave enough information upfront, this confirmation can be a single line.
Do not over-ask if the request is clear.

## Validation Checkpoints
- Indication name is specific enough to produce unambiguous search queries
- If focus compound specified, MoA class is identified
- All parameters have explicit values (user-provided or default)

## Next Step
Step 02: MoA Landscape Research (workflow/step02-moa-research.md)
