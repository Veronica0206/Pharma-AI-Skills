# Step 02: MoA Landscape Research

## Goal
Identify all mechanistic pathways and therapeutic targets being investigated for the target indication,
with biological rationale and validation status for each.

## Inputs
- Confirmed indication name and subtype
- Optional: focus MoA/compound class

## Output
- Section 2 content: MoA table + narrative
- Source list for bibliography

## Procedure

### 2.1 Pathophysiology Search
- Query: "[indication] pathophysiology therapeutic targets review"
- Query: "[indication] disease mechanism immune pathway"
- Fetch top 2 review articles (PubMed, Nature Reviews)
- Extract: key immune cells, cytokines/proteins, upstream triggers, organ-level damage mechanism

### 2.2 MoA Class Enumeration
- Query: "[indication] treatment mechanism of action novel therapy [Y-2] [Y-1] [Y]"
  (Replace [Y] with current year; see search-strategies.md for year filter convention)
- Query: "[indication] drug targets clinical development pipeline"
- Fetch 1-2 pipeline review papers
- For each MoA class: target name, cell type, pathway, biological rationale, validation level
- Validation levels: Preclinical only / Phase 1-2 data / Phase 3 data / Approved

### 2.3 Regulatory Signals
- Query: "[indication] Breakthrough Designation FDA mechanism"
- Note any MoA with Breakthrough Therapy Designation (signal of regulatory validation)

### 2.4 Focus Class Deep-Dive (if requested)
- Search: "[focus MoA] [indication] mechanism preclinical clinical"
- Position focus class within the broader MoA landscape

## Output Format

### Table: MoA Classes in [Indication]
| MoA Class | Primary Target | Key Pathway | Rationale | Validation Level | Example Compounds |

### Narrative (300-500 words)
- Dominant pathogenic pathways, most validated MoA classes, emerging targets
- Focus class positioning (if applicable)

## Validation Checkpoints
- Identify all discoverable MoA classes. For well-studied indications, expect 4+ classes; for rare
  diseases or narrow indications, fewer is acceptable — document the landscape as found and note
  if limited evidence constrains the count.
- Every class has biological rationale, not just drug names
- Validation level is evidence-based with cited sources

## Next Step
Step 03: Compound Landscape Research
