# Clinical Indication Researching

**Comprehensive clinical indication research for drug development and trial planning.**

This repo provides an open-source agent skill for Claude Code, Codex, and other web-capable coding agents. It transforms a disease indication into a publication-quality clinical research dossier covering mechanism of action, approved and pipeline compounds, regulatory and consensus endpoints, key secondary endpoints, and study designs of existing compounds in the indication.

It is built for biostatisticians, clinical scientists, and drug-development professionals who need to scope an indication landscape under time pressure — for due diligence, competitive intelligence, indication-selection memos, or to prepare a new clinical-trial design.

**What this skill can do:** systematically research mechanistic pathways and target landscape (MoA), produce a curated table of approved and pipeline compounds with efficacy and safety data, surface the primary and key secondary endpoints supported by FDA/EMA guidance and field consensus, document the study designs of existing compounds for reference, and synthesize all of the above into a structured Word or PDF dossier.

**What this skill cannot do:** decide which indication you should pursue, judge whether a competitor's data is real, evaluate the strategic fit of an indication for your portfolio, or replace the indication dialogue your therapeutic-area lead will demand.

> **The skill structures execution. You own the judgment.**

---

## Who this is for

- **Drug-development professionals** evaluating new indications or indication expansions
- **Biostatisticians and clinical scientists** preparing for a [`vera-clinical-trial-designing`](https://github.com/veronica0206/vera-clinical-trial-designing) or [`vera-master-trial-designing`](https://github.com/veronica0206/vera-master-trial-designing) workflow
- **Regulatory affairs and medical writing professionals** building briefing books that need defensible competitive-landscape sections
- **Postdocs and PhD / MS holders** moving into biotech / pharma R&D who need a structured way to scope a new therapeutic area
- **Consultants** producing indication memos or due-diligence reports

---

## What's included

| Workflow step | What it produces |
|---|---|
| **Step 01 — clarify inputs** | Confirms the indication scope, target population, line of therapy, and any user-specified focus areas. |
| **Step 02 — MoA research** | Mechanistic landscape: pathways, targets, validation tier, and notable target-specific evidence. |
| **Step 03 — compound landscape** | Curated table of approved and clinical-stage compounds with sponsor, mechanism, phase, primary readout, and headline efficacy / safety. |
| **Step 04 — endpoint framework** | Primary endpoint(s) supported by FDA / EMA guidance, plus key secondary endpoints used by the field. Cites authorities. |
| **Step 05 — study designs** | Documented study designs from the compound landscape: arm structure, control choice, endpoint, sample size, duration, region. |
| **Step 06 — synthesis** | First-pass dossier draft: executive summary, MoA section, compound table, endpoint section, design comparison. |
| **Step 07 — review** | External-reviewer pass (via a reviewer-LLM MCP if configured; otherwise structured self-review). |
| **Step 08 — deliver** | Final formatted dossier as Word and / or PDF using the `docx` and `pdf` skills if available. |

The reference search strategies and endpoint authorities are documented in [`reference/specs/search-strategies.md`](reference/specs/search-strategies.md) and [`reference/specs/endpoint-authority-sources.md`](reference/specs/endpoint-authority-sources.md).

---

## How it works

```
Indication name             Workflow                      Outputs
+--------------+    +-------------------------+    +---------------------+
| Indication   |    | step01-08 workflow      |    | dossier.docx        |
| Population   |    |   MoA, compounds,       |    | dossier.pdf         |
| Line of tx   | -> |   endpoints, designs;   | -> | citations.bib       |
| Focus areas  |    |   review + deliver      |    | source-log.csv      |
+--------------+    +-------------------------+    +---------------------+
```

---

## Installation

```bash
git clone https://github.com/veronica0206/vera-clinical-indication-researching.git ~/.claude/skills/vera-clinical-indication-researching

git clone https://github.com/veronica0206/vera-clinical-indication-researching.git ~/.codex/skills/vera-clinical-indication-researching
```

**Requirements:**
- A host agent with current web search/browsing enabled
- Optional: a reviewer-LLM MCP server for the external-reviewer step; the skill falls back to a structured self-review if none is configured
- Optional: document-generation or PDF-export tooling for delivery formatting (skill emits Markdown if unavailable)

See [`docs/guide.md`](docs/guide.md) for a getting-started walkthrough.

---

## Documentation

- [`docs/guide.md`](docs/guide.md) — walkthrough with worked example
- [`docs/changelog.md`](docs/changelog.md) — version history
- [`reference/specs/search-strategies.md`](reference/specs/search-strategies.md) — search strategy specs per workflow step
- [`reference/specs/endpoint-authority-sources.md`](reference/specs/endpoint-authority-sources.md) — accepted authority hierarchy for endpoints (FDA, EMA, ICH, field consensus)
- [`reference/templates/dossier-outline.md`](reference/templates/dossier-outline.md) — the canonical dossier outline

---

## Related skills

- [`vera-clinical-trial-designing`](https://github.com/veronica0206/vera-clinical-trial-designing) — quantitative trial design (sample size, Go/No-Go, PPOS). Use *after* this dossier when you are ready to design.
- [`vera-master-trial-designing`](https://github.com/veronica0206/vera-master-trial-designing) — basket, umbrella, and platform master-protocol designs.

---

## License

GPL-3.0. See [`LICENSE`](LICENSE).

---

## Citation

If this skill informs published work, please cite as:

> Veronica. *Clinical Indication Researching — comprehensive landscape dossier for drug development.* GitHub repository, https://github.com/veronica0206/vera-clinical-indication-researching
