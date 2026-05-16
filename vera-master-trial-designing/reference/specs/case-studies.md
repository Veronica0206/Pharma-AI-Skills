# Master Protocol Design Patterns

This file captures generalized methodological lessons only. It intentionally avoids disease areas,
interventions, and trial identifiers while preserving representative literature references.

## Basket Design Patterns

### Pattern B1: Screening-Heavy Basket
- **Type**: Basket trial
- **Design**: Large qualification funnel across many sites with a low match rate into protocol-defined subgroups
- **Key lesson**: Basket trials can uncover meaningful subgroup signals even when aggregate performance looks weak. Operationally, this pattern requires a substantial screening pipeline.
- **Representative reference**: Flaherty et al. (2020)

### Pattern B2: Small-Cohort Basket
- **Type**: Basket trial (no information borrowing)
- **Design**: Independent cohort-level evaluation with early stopping
- **Key lesson**: Small subgroup cohorts can still be decision-relevant when observed effects are strong, but interpretation depends heavily on uncertainty quantification.
- **Representative reference**: Hyman et al. (2015)

## Umbrella Design Patterns

### Pattern U1: Adaptive Control Framework
- **Type**: Umbrella trial
- **Design**: Shared reference arm with protocol updates as the operating context evolves
- **Key lesson**: Umbrella designs need enough protocol flexibility to refresh control assumptions without breaking comparability.
- **Representative reference**: Herbst et al. (2015)

### Pattern U2: Screening-Dependent Umbrella
- **Type**: Umbrella trial
- **Design**: Large qualification workflow feeding multiple assignment arms
- **Key lesson**: Screening-heavy umbrella designs can lose substantial participants between qualification and enrollment, so attrition planning matters.
- **Representative reference**: Gerber et al. (2015)

### Pattern U3: Multi-Stage Filtering Umbrella
- **Type**: Umbrella / platform hybrid
- **Design**: Multi-arm adaptive filtering with staged continuation decisions
- **Key lesson**: Statistical efficiency depends on strong operational coordination, robust data flow, and clear arm-governance rules.
- **Representative reference**: Adams et al. (2016)

## Platform Design Patterns

### Pattern P1: Adaptive Prioritization Platform
- **Type**: Platform / umbrella hybrid
- **Design**: Adaptive randomization across multiple active arms with a shared reference arm
- **Key lesson**: Adaptive allocation can accelerate prioritization of promising arms, but it raises governance and inference complexity.
- **Representative reference**: Barker et al. (2009); Park et al. (2016)

### Pattern P2: Multi-Arm Adaptive Reassignment
- **Type**: Umbrella / adaptive
- **Design**: Probabilistic reassignment across several active arms
- **Key lesson**: Multi-arm adaptive reassignment is operationally feasible when minimum-allocation and monitoring rules are specified up front.
- **Representative reference**: Kim et al. (2011)

### Pattern P3: Standing Rapid-Response Platform
- **Type**: Platform trial
- **Design**: Persistent infrastructure capable of onboarding and retiring arms quickly
- **Key lesson**: A standing framework materially improves responsiveness when evidence must be generated on compressed timelines.
- **Representative reference**: Collaborative Group (2021)

## Cross-Cutting Design Lessons

| Lesson | Patterns |
|--------|----------|
| Adaptive randomization is operationally feasible | P1, P2 |
| Basket trials can reveal narrow subgroup signals | B1, B2 |
| Control assumptions may need planned updates | U1 |
| Large qualification funnels need operational planning | B1, U2 |
| Cross-team coordination is a major implementation risk | U3, U1 |
| Standing platforms improve responsiveness | P3 |
| Attrition can materially change downstream feasibility | U2 |
| Adaptive methods can accelerate arm prioritization | P1, P2 |
