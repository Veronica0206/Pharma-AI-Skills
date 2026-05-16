# Step 01: Select Design Type

## Goal
Determine the appropriate master protocol family and the public-scope method
within that family.

## Inputs
- User request describing their clinical trial design problem

## Outputs
- `master_design_type`: one of `basket`, `umbrella`, `platform`
- Public-scope method for that family
- Key design parameters

## Decision

### 1. Master Protocol Family

| Question | If Yes → |
|----------|----------|
| One intervention, multiple prespecified subgroups? | **Basket** |
| Multiple interventions, one protocol population? | **Umbrella** |
| Arms enter / leave over time, perpetual protocol? | **Platform** |

Read `docs/decision-roadmap.md` for the full decision logic.

### 2. Public-Scope Method

| Family | Public-scope method | Endpoint |
|---|---|---|
| Basket | `borrowing_method = "none"` (independent per subgroup) **or** `"complete"` (pooled) | binary |
| Umbrella | `umbrella_method = "mams"` | continuous or binary |
| Platform | concurrent-control comparison (default) | binary |

If the user asks for an out-of-scope method (information borrowing, DTL, BAR,
NCC adjustment, RAR, TTE / incidence-rate endpoints, HTA strategy), redirect
them to SKILL.md § *Beyond This Skill* and stop.

### 3. Collect Key Parameters

**All families:**
- `n_subgroups` (number of subgroups or experimental arms)
- `endpoint_type` (`binary` or, for umbrella, `continuous`)
- `null_params`, `alt_params`
- `alpha` (default 0.025)
- `n_sims` (default 5000)

**Basket-specific:** `borrowing_method`, `n_per_subgroup`, `go_threshold`.

**Umbrella-specific:** `n_stages`, `n_per_arm_stage`, `sd` (continuous endpoint).

**Platform-specific:** `n_periods`, `n_per_period`, `arms_schedule = list(enter, leave)`.

## Proceed To
→ `workflow/step02-build-master-config.md`
