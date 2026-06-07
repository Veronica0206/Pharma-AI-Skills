# Runtime Compatibility

This skill is authored as a portable `SKILL.md` package with optional
supporting files.

## Codex

- Canonical source folder: `vera-clinical-indirect-comparing/`.
- Codex-specific metadata lives in `agents/openai.yaml`.
- Use the repository folder directly during development, or install into the
  local Codex skills directory with the local skill installer workflow.

## Claude Code

Claude Code discovers skills from `.claude/skills/<skill-name>/SKILL.md` in the
project tree or from `~/.claude/skills/<skill-name>/SKILL.md`.

For a user-level install:

```bash
mkdir -p ~/.claude/skills
rsync -a \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude 'outputs/' \
  --exclude 'runs/' \
  vera-clinical-indirect-comparing/ \
  ~/.claude/skills/vera-clinical-indirect-comparing/
```

For a project-level install from the repository root:

```bash
mkdir -p .claude/skills
rsync -a \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude 'outputs/' \
  --exclude 'runs/' \
  vera-clinical-indirect-comparing/ \
  .claude/skills/vera-clinical-indirect-comparing/
```

Claude Code can execute the bundled R scripts if `Rscript` is available in the
local environment.

## Claude.ai

For Claude.ai custom-skill upload, package the skill as a ZIP containing the
top-level folder:

```text
vera-clinical-indirect-comparing.zip
└── vera-clinical-indirect-comparing/
    ├── SKILL.md
    ├── docs/
    ├── reference/
    └── scripts/
```

Do not zip the contents directly at the ZIP root. Keep `outputs/` and `runs/`
out of the package.

Claude.ai can use the workflow instructions and reference files. If the hosted
code environment does not provide R, run the R scripts in Claude Code or another
local R environment and return the generated CSV/PDF outputs for interpretation.

## Packaging Checks

Before sharing the skill:

```bash
cd vera-clinical-indirect-comparing/scripts/R
Rscript validate_core_formulas.R
Rscript example_minimal.R
```

Then confirm the package excludes generated artifacts:

```bash
find vera-clinical-indirect-comparing -path '*/outputs/*' -o -path '*/runs/*'
```
