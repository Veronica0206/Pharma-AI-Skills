# Decision Roadmap: Selecting a Master Protocol Design

## Step 1: Choose Master Protocol Type

```
Is there ONE intervention?
  YES --> Is it tested across MULTIPLE prespecified subgroups?
            YES --> BASKET TRIAL
            NO  --> Not a master protocol
  NO  --> Are MULTIPLE interventions tested in ONE protocol population?
            YES --> Are arms entering/leaving over time?
                      YES --> PLATFORM TRIAL
                      NO  --> UMBRELLA TRIAL
            NO  --> Not a master protocol
```

## Step 2: Public-Scope Method Within Each Family

This skill implements **one canonical method per family** in the public release.

### Basket trial (binary endpoint)

```
Is the question "does the drug work in each subgroup independently?"
  YES --> borrowing_method = "none"   (independent Beta-Binomial per subgroup)

Is the question "does the drug work overall, treating subgroups as exchangeable?"
  YES --> borrowing_method = "complete"   (pooled Beta-Binomial across subgroups)
```

For adaptive borrowing strategies (Simon's Bayesian, Chen confirmatory, Wathen
S-TI / SEP, Calibrated BHM, full BHM with Gibbs), see SKILL.md § *Beyond This
Skill*. The two public-scope methods are the **reference baselines** that any
borrowing comparison should be evaluated against.

### Umbrella trial (continuous or binary endpoint)

```
umbrella_method = "mams"   (multi-arm multi-stage with stage-wise futility)
```

For drop-the-losers (DTL) and Bayesian adaptive randomization (BAR), see SKILL.md § *Beyond This Skill*.

### Platform trial (binary endpoint)

```
Default: simple concurrent-control comparison.
Each arm tested using only the control patients enrolled while the arm was active.
No NCC adjustment; no RAR; no time-trend modeling.
```

For NCC adjustment (regression, time-machine) and RAR (Thompson sampling), see SKILL.md § *Beyond This Skill*.

## Additional Reference Documents

- `reference/specs/case-studies.md` — brief real-world examples illustrating each family
- `reference/specs/cross-domain-principles.md` — high-level principles applicable across families
- `reference/specs/config-reference.md` — full `create_master_config()` parameter list
