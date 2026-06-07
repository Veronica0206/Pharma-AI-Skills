# Clinical Indication Researching — Usage Guide

## What This Skill Does

Conducts comprehensive clinical indication research for drug development planning. Given a disease indication, systematically researches:
1. **Mechanism-of-action (MoA) landscape** — pathways, targets, biology
2. **Compound landscape** — approved drugs + pipeline by phase, with SoC benchmarks
3. **Endpoint framework** — primary/secondary/biomarker endpoints with regulatory authority classification
4. **Study design landscape** — single-arm vs. controlled precedent, statistical norms
5. **Synthesis** — strategic recommendations connecting all four research domains
6. **delegated review** — delegated reviewer quality loop or structured self-review (optional)

Output: a publication-quality dossier (`.docx`, `.pdf`, or `.md`) with full citations.

## Quick Start

> "Run an indication dossier on Example Renal Indication A"

The skill will:
1. Confirm scope (default depth, focus compound, output format)
2. Run all 6 research steps with validation checkpoints
3. (Optional) Run delegated review until convergence (max 2 rounds)
4. Assemble and deliver the dossier

## Common Invocations

| User Request | Behavior |
|---|---|
| "Quick overview of Example Indication B" | Standard depth (3-5 searches per section), markdown output |
| "Deep dossier on Example Indication A with focus on [example drug class]" | Deep depth (6-10 searches per section), focus compound MoA deep-dive |
| "What endpoints does FDA accept for Example Indication C?" | Step 04 only — endpoint framework with HA-Guided/Community Consensus/Literature Emerging classification |
| "Compare Phase 3 [example abbreviation] designs across approved sponsors" | Step 05 only — regulatory precedent table |

## Output Structure

The dossier follows the structure in `reference/templates/dossier-outline.md`:
1. Executive Summary (1 page, optional)
2. Disease Background and MoA Landscape
3. Compound Landscape (approved + pipeline by phase)
4. Endpoint Framework (with authority classification)
5. Study Design Landscape (single-arm vs. controlled precedent + statistical norms)
6. Development Implications (differentiation, endpoint recommendation, design recommendation)
7. References (numbered, ICMJE style)

## Key Design Choices

### Endpoint Classification System
Three tiers with explicit criteria — see `reference/specs/endpoint-authority-sources.md`:
- **HA-Guided**: Named in FDA/EMA guidance (most weight)
- **Community Consensus**: Multi-trial use across approved drugs (must meet 2 criteria)
- **Literature Emerging**: Validation in progress (must meet 1 criterion + caveat)

### SoC Benchmark Selection
Four-tier priority rule in step03 ensures the same SoC benchmark value is used in both single-arm H0 and H2H control arm assumptions — preventing a common dossier error.

### External Review (Step 07)
Optional delegated review with state persistence. Termination criteria:
- Score ≥ 7/10, OR
- Verdict contains "ready" or "almost"
- OR max 2 rounds reached

If no delegated reviewer is available, falls back to self-review.

## Integration with Other Skills

After delivering the dossier, the user can hand off to:
- **vera-clinical-trial-designing** — for sample size modeling using the SoC benchmark and endpoint identified in this dossier
- **vera-master-trial-designing** — for basket/umbrella/platform design if multiple subpopulations or treatments are in scope

## Naming Convention Note

Domain `clinical` is a custom domain (not in the official `dev/doc/content/data/ops` list). Custom domains are accepted when they are semantically more accurate than any of the standard five — clinical research methodology has no clean fit in the default taxonomy.

## Limitations

- **Therapeutic area coverage**: `endpoint-authority-sources.md` currently has the strongest coverage for renal and immune-mediated example areas. Other indications follow the same classification system but may need extending the reference file (see "Extending This Reference" section in that file).
- **No automated fact-checking**: delegated review (step07) is the safety net but is optional.
- **Output format depends on document/PDF tooling**: Verified upfront in step01 — falls back to markdown if formatted export is unavailable.
