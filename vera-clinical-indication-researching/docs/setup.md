# Setup

## Requirements

- A file-aware coding agent such as Codex, Claude Code, or an equivalent local
  agent runtime
- Current web search or browsing access for clinical, regulatory, trial, and
  literature sources
- Optional document export support when `.docx` or `.pdf` delivery is requested

## Verify Skill Files

From the skill root:

```bash
test -f SKILL.md
test -d workflow
test -d reference
```

Expected: all commands exit successfully.

## Source Access

The skill depends on current public evidence. Before starting a dossier, confirm
that the host can access the needed source classes:

- PubMed or other biomedical literature search
- ClinicalTrials.gov or another trial registry
- FDA, EMA, or other health-authority guidance and review pages
- Drug labels, sponsor pipeline pages, or peer-reviewed compound sources

Prefer primary sources whenever available. Use secondary sources only as routing
or context, then trace important claims back to the primary evidence.

## Optional Document Output

At Step 01, confirm whether the host can render `.docx` or `.pdf` artifacts.
If document tooling is unavailable, deliver the dossier as Markdown.

## First Run

Use a narrow request first:

```text
Use vera-clinical-indication-researching to create a concise indication dossier
for Example Renal Indication A, with Markdown output.
```

Expected behavior:

- Step 01 confirms scope, depth, and output format.
- Each workflow step reads the matching `workflow/stepNN-*.md` file.
- Final output follows `reference/templates/dossier-outline.md`.

## No Local Code Runtime

This skill has no R, Python, or Node runtime requirement. Quality depends on
source selection, citation discipline, endpoint classification, and structured
review rather than local script execution.
