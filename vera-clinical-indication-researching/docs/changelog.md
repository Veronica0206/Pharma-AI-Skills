# Changelog

## v1.1 (2026-04-06)
- Added early delivery format check in `step01-clarify-inputs.md` (verify `docx`/`pdf` skill availability before research) to prevent silent fallback to markdown after all research is complete
- Reconciled step07 termination criteria across SKILL.md, `step07-review.md`, and `research-reviewing.md` (single source of truth)

## v1.0 (initial release)
- Eight-step workflow: clarify scope -> MoA landscape -> compound landscape -> endpoint framework -> study designs -> synthesis -> external review -> delivery
- Endpoint authority sources file with three-tier classification (HA-Guided / Community Consensus / Literature Emerging)
- SoC benchmark four-tier selection rule (step03)
- External review via reviewer-LLM MCP with state persistence and self-review fallback (step07)
- Reference templates: `dossier-outline.md`
- Search strategies with rolling year filters
