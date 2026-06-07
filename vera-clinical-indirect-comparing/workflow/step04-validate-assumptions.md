# Step 04: Validate Assumptions

## Goal

Decide whether the numeric output is clinically interpretable.

## Checks

- Endpoint definition and timing align across trials.
- Common comparator or via treatment is clinically comparable across the direct
  evidence sources.
- Target covariates are plausible effect modifiers or prognostic factors.
- MAIC balance gaps are small after weighting.
- ESS is not too low for stable interpretation.
- Target covariate means sit inside plausible source IPD support.
- The analysis scale and contrast orientation are reported correctly.
- Any unmeasured effect modifiers are listed as limitations.

## Red Flags

- Different endpoint definitions or follow-up windows.
- MAIC ESS collapse after weighting.
- Target covariates outside the source IPD support.
- Common comparator or via-treatment dose, background therapy, or eligibility
  criteria differ in clinically important ways.

## Validation Checkpoint

Do not translate the estimate as decision-ready until every red flag is either
cleared or carried forward as an explicit limitation.

## Proceed To

`workflow/step05-translate-results.md`
