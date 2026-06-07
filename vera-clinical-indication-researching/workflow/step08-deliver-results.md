# Step 08: Deliver Dossier

## Goal
Format and save the final dossier in the user's chosen output format and present file path + summary to the user.

## Inputs
- Assembled dossier content from Step 06 (Markdown source)
- Review-approved version (if Step 07 was run)
- Output format from Step 01 (`docx`, `pdf`, or `md`)

## Outputs
- Saved file at the user's chosen location
- Console summary with file path and key findings

## Procedure

### 1. Format Conversion

The output format was confirmed in Step 01 (section 1.2b — early delivery check). Use the corresponding skill:

- **docx**: use the host's document-generation workflow to produce `.docx`
- **pdf**: use the host's PDF or document-rendering workflow to produce `.pdf`
- **md**: save directly as `.md` (no conversion needed)

If the chosen format's skill is unavailable at this point (which should not happen if Step 01 1.2b was followed), fall back to markdown and inform the user.

### 2. Filename Convention

```
indication_dossier_[indication_slug]_[YYYY-MM-DD].[ext]
```

Where:
- `[indication_slug]` is the disease name in lowercase with hyphens (e.g., `example-renal-indication-a`, `example-immune-indication`)
- `[YYYY-MM-DD]` is today's date
- `[ext]` is `docx`, `pdf`, or `md`

### 3. Save Location

Save to the user's preferred output location. If unspecified, save to the current working directory.

### 4. Console Summary

Show the user:

```
✓ Dossier saved: [absolute path]
  - Pages/sections: [count]
  - Indication:    [name]
  - Focus:         [compound or "general"]
  - Depth:         [standard | deep]
  - References:    [count]

Key recommendations from Section 6:
  - Endpoint:      [recommended endpoint + tier]
  - Phase 2 design: [single-arm | controlled, N=[value]]
  - Phase 3 design: [pattern, N=[value]]
  - Differentiation: [one-line strategic angle]
```

### 5. Suggest Next Steps

Offer one or two follow-ups:
- "Want to model the recommended Phase 2 / Phase 3 sample size with the trial designing skill?" → handoff to `vera-clinical-trial-designing` with the SoC benchmark and endpoint pre-filled
- "Want to evaluate this as a basket trial across multiple indications?" → handoff to `vera-master-trial-designing`
- "Want to extend to a related indication?" → return to Step 01 with new inputs

## Validation Checkpoints
- [ ] File saved successfully (verify path exists and size > 1KB)
- [ ] Filename follows the convention
- [ ] Console summary includes all key fields
- [ ] At least one next-step suggestion offered

## End of Workflow
This is the final step. The dossier is delivered.
