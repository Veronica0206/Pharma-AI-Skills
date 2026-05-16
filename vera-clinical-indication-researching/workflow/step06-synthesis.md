# Step 06: Synthesis and Document Assembly

## Goal
Synthesize findings from Steps 02-05 into a coherent strategic narrative and assemble the final dossier document.

## Inputs
- MoA landscape (Step 02)
- Compound landscape with SoC benchmark (Step 03)
- Endpoint framework with classifications (Step 04)
- Study design landscape (Step 05)

## Outputs
- Development Implications section (dossier Section 6)
- Assembled dossier in the user's chosen format (.docx, .pdf, or .md)

## Procedure

### 1. Cross-Domain Synthesis

Connect the four research domains by answering:

1. **MoA-to-Compound linkage**: Which MoA classes have the most validated compounds? Which are crowded vs. white-space?
2. **Compound-to-Endpoint linkage**: What endpoints do the leading programs use? Does the SoC benchmark come from the most relevant approved drug?
3. **Endpoint-to-Design linkage**: What benchmark response rates inform single-arm H0? Which endpoints have regulatory precedent for approval?
4. **Design architecture**: What design patterns (single-arm, RCT, adaptive) have regulatory precedent? What statistical norms apply?

### 2. Write Development Implications (Section 6)

- **6.1 Differentiation Opportunities**: Where can a new entrant differentiate — novel MoA, better safety, faster onset, underserved subpopulation, or superior endpoint strategy?
- **6.2 Endpoint Selection Recommendation**: Recommend the primary endpoint with rationale tied to authority classification and regulatory precedent. If an HA-Guided endpoint exists, default to it. If only Community Consensus, justify why it is sufficient.
- **6.3 Trial Design Recommendation**: Recommend Phase 2 and Phase 3 designs with specific parameters (N, alpha, power, duration, control arm) grounded in Step 05 findings and the SoC benchmark from Step 03.

### 3. Critical Consistency Check

Before writing, verify:
- [ ] The SoC benchmark used in Section 6.3 (Phase 2 single-arm H0) matches the benchmark identified in Section 3 (compound landscape) — same value, same source
- [ ] The recommended endpoint in Section 6.2 has its definition documented in Section 4 (endpoint framework)
- [ ] The recommended design pattern in Section 6.3 has at least one regulatory precedent in Section 5

If any check fails, return to the relevant earlier step and reconcile before proceeding.

### 4. Assemble the Document

Use the structure from `reference/templates/dossier-outline.md`. Sections:
1. Executive Summary (1 page, optional based on Step 01 parameter)
2. Disease Background and MoA Landscape (from Step 02)
3. Compound Landscape (from Step 03)
4. Endpoint Framework (from Step 04)
5. Study Design Landscape (from Step 05)
6. Development Implications (this step)
7. References (numbered, ICMJE style, deduplicated)

Apply the formatting conventions in `dossier-outline.md` (typography, table styles, citation format).

## Validation Checkpoints
- [ ] Section 6 references specific findings from Sections 2-5 (not generic)
- [ ] SoC benchmark consistency check passes (Section 3 ↔ Section 6.3)
- [ ] Endpoint recommendation has explicit authority tier and rationale
- [ ] Trial design recommendation has specific N / alpha / power / duration values
- [ ] References section has no duplicates and follows ICMJE format

## Proceed To
→ `workflow/step07-review.md` (optional external review via reviewer-LLM MCP; falls back to self-review)
→ `workflow/step08-deliver.md` (skip step07 if not requested)
