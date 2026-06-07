# Clinical Indication Research Review

Use this checklist when the user explicitly asks for an additional review pass
or when the dossier is high-stakes enough to merit formal review. Self-review is
the portable default. Delegated review is optional and depends on the active host.

## Self-Review Checklist

- Verify every clinical efficacy number against the cited source.
- Confirm endpoint definitions and timing match the intended benchmark.
- Confirm each health-authority endpoint claim cites an actual guidance,
  label, approval review, or other primary source.
- Check that the SoC benchmark used for design planning is not mixed across
  incompatible populations, endpoint definitions, or treatment eras.
- Identify missing approved or late-stage pipeline compounds that could alter
  the benchmark or endpoint recommendation.
- Check the development recommendation follows from the evidence tables.

Record findings in `AUTO_REVIEW.md` and fix material issues before delivery.

## Optional External Review Prompt

Use only when the host exposes a delegated reviewer and the user
explicitly wants delegated review. Send a complete briefing because the reviewer
may not be able to read local files.

```text
You are reviewing a clinical indication research dossier for [indication].
The dossier will inform drug development strategy and clinical trial design.

Review context:
[Paste MoA landscape, compound landscape, SoC benchmark, endpoint tables,
study design tables, Development Implications, source-date limits, and known
gaps.]

Act as a senior clinical pharmacology and regulatory reviewer. Evaluate:

1. Factual accuracy
2. Endpoint classification rigor
3. SoC benchmark validity
4. Regulatory precedent accuracy
5. Synthesis quality

Score the dossier 1-10. Return:
- Verdict: ready, almost, or not ready
- Ranked critical weaknesses
- Minimum fix for each weakness
- Any endpoint reclassification needed
- Any SoC benchmark or regulatory-precedent concern
```

For a second round, send only after implementing fixes. Include a before/after
summary and the corrected tables or narrative.
