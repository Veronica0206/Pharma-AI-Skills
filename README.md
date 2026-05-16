# Pharma AI Skills

Open-source agent skills for pharma and clinical-development workflows.

This repository follows an umbrella structure: each skill lives in its own
self-contained folder with its own `SKILL.md`, documentation, workflow files,
reference material, and scripts. The four skills can be used independently, but
they are designed to work naturally as a clinical-development sequence.

## Skills

| Skill | Use it for | Primary output |
|---|---|---|
| [`vera-clinical-indication-researching`](vera-clinical-indication-researching/) | Disease landscape, MoA, compounds, endpoints, and study-design precedent | Clinical indication dossier |
| [`vera-clinical-meta-analysis`](vera-clinical-meta-analysis/) | x/N extraction, endpoint harmonization, pooled benchmark rates, and forest plots | Literature benchmark tables |
| [`vera-clinical-trial-designing`](vera-clinical-trial-designing/) | Standard sample size and power calculations for single-arm or 1:1 controlled trials | Sample-size table and power curve |
| [`vera-master-trial-designing`](vera-master-trial-designing/) | Basket, umbrella, and platform trial baseline simulations | Operating-characteristics tables and plots |

## Recommended Workflow

1. Start with `vera-clinical-indication-researching` to define the disease
   landscape, target population, endpoints, and precedent study designs.
2. Use `vera-clinical-meta-analysis` when published clinical data should be
   translated into historical-control, placebo, active-control, or target-effect
   benchmarks.
3. Use `vera-clinical-trial-designing` for a conventional first-pass protocol
   sample size or power calculation.
4. Use `vera-master-trial-designing` when the question becomes a basket,
   umbrella, or platform-trial concept.

## Host Compatibility

The simplified public skills are written for Claude Code, Codex, and other
file-aware coding agents. They avoid host-specific frontmatter and keep
runtime notes inside each `SKILL.md`.

Codex users can use the bundled `agents/openai.yaml` files for display metadata.
Claude Code users can use the same `SKILL.md` workflow instructions directly.

## Installation

Clone the suite repository, then install whichever skill folders you want into
your host agent's skill directory.

```bash
git clone https://github.com/Veronica0206/Pharma-AI-Skills.git
cd Pharma-AI-Skills
```

Install one skill for Codex:

```bash
mkdir -p ~/.codex/skills
rsync -a vera-clinical-trial-designing/ ~/.codex/skills/vera-clinical-trial-designing/
```

Install one skill for Claude Code:

```bash
mkdir -p ~/.claude/skills
rsync -a vera-clinical-trial-designing/ ~/.claude/skills/vera-clinical-trial-designing/
```

Install all four skills for Codex:

```bash
mkdir -p ~/.codex/skills
for skill in vera-*; do
  rsync -a "$skill/" "$HOME/.codex/skills/$skill/"
done
```

Install all four skills for Claude Code:

```bash
mkdir -p ~/.claude/skills
for skill in vera-*; do
  rsync -a "$skill/" "$HOME/.claude/skills/$skill/"
done
```

## Requirements

- R >= 4.0 for the quantitative skills.
- Base R is sufficient for the public trial-design and meta-analysis examples.
- The `MAMS` R package is optional for the master-protocol umbrella workflow.
- Current web search or browsing is useful for indication research and literature
  benchmarking.

Each skill folder includes its own setup guide and quick-start examples.

## Scope

These skills are public, simplified reference workflows. They are intended for
transparent first-pass research, benchmarking, and design support. They do not
replace regulatory review, clinical judgment, statistical sign-off, medical
monitoring, or formal systematic-review governance.

## Repository Layout

```text
Pharma-AI-Skills/
├── README.md
├── LICENSE
├── vera-clinical-indication-researching/
├── vera-clinical-meta-analysis/
├── vera-clinical-trial-designing/
└── vera-master-trial-designing/
```

## License

GPL-3.0. See [`LICENSE`](LICENSE).

## Citation

If this repository or one of its skills informs published or shared work,
please cite the specific skill folder and version used.
