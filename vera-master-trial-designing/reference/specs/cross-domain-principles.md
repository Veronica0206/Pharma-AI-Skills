# Cross-Domain Design Principles for Master Protocols

## Source

These principles are drawn from the synthesis document "The Architecture of Containment, Protection, and Integration," which identifies structural imperatives shared across physical craftsmanship (basketry, umbrella engineering, modular staging), software architecture (cloud-native platforms, microservices), and clinical trial master protocols.

## Principle 1: Modularity

**Definition**: The ability to update or replace individual components without compromising the entire system.

**In clinical trials**: Multi-arm multi-stage (MAMS) designs allow the foundational research platform to persist while individual treatment arms are rotated in or out. Arms can be:
- Added when new compounds become available
- Dropped when interim analyses show futility
- Graduated when efficacy thresholds are met

**Design implication**: Protocol infrastructure (screening, randomization, data systems, IRB, DMC) should be designed as permanent shared services, decoupled from any specific treatment arm.

**Parallel in software**: Microservices architecture -- each service is independently deployable and replaceable without affecting the platform.

## Principle 2: Sustainable and Circular Design

**Definition**: Eliminating work duplication and centralizing resource management to reduce overall operational overhead.

**In clinical trials**: Master protocols achieve operational efficiency through:
- **Shared screening platform**: One molecular profiling pipeline serves all arms/baskets
- **Common control arm**: Shared across treatment comparisons (umbrella/platform)
- **Centralized governance**: Single IRB, DMC, and data management system
- **Reduced redundancy**: No duplicated site startup, training, or regulatory submissions per sub-study

**Design implication**: Quantify operational savings when presenting master protocol proposals to stakeholders. The "resource tax" of running K separate trials vs. one master protocol can be substantial (30-60% reduction in per-patient cost).

**Parallel in manufacturing**: Circular design in umbrella manufacturing -- using recycled materials and shared production infrastructure across product lines.

## Principle 3: Unified Integration (Weaving)

**Definition**: Interconnecting disparate elements into a coherent framework that provides stable, transparent, and adaptive support for complex interactions.

**In clinical trials**: Master protocols "weave" together:
- Multiple scientific hypotheses (different interventions, different subgroup hypotheses)
- Multiple stakeholders (collaborators, investigators, regulators, participants)
- Multiple data streams (efficacy, safety, subgroup, external evidence)
- Multiple timelines (arms enter and leave at different times)

**Design implication**: The protocol document itself must serve as the integrating framework. Pre-specify:
- Governance rules for adding/dropping arms
- Statistical analysis plans per arm and for the overall protocol
- Data sharing agreements across collaborating groups
- Communication pathways between DMC, steering committee, and arm-specific teams

**Parallel in basketry**: Traditional basket weaving interweaves warp and weft to create structural integrity from individually weak fibers.

## Principle 4: Adaptive Responsiveness

**Definition**: The system adjusts its behavior based on accumulated information without requiring a fundamental redesign.

**In clinical trials**:
- Bayesian adaptive randomization shifts allocation toward promising arms
- Interim futility analyses prune ineffective arms early
- Platform trials evolve as the operating landscape changes (for example, refreshing reference-arm assumptions as practice standards shift)

**Design implication**: Build adaptation rules into the protocol prospectively. Define:
- What triggers an adaptation (enrollment count, calendar time, event count)
- What changes are permitted (allocation ratio, arm addition/removal, sample size re-estimation)
- What stays fixed (primary endpoint, alpha level, control arm definition)

## Applying These Principles to Trial Design

| Design Phase | Modularity | Sustainability | Integration | Adaptiveness |
|-------------|-----------|---------------|-------------|-------------|
| Protocol development | Define arm-agnostic infrastructure | Identify shared resources | Map stakeholder interactions | Pre-specify adaptation rules |
| Screening | Shared qualification platform | Central assessment pipeline | Unified participant registry | Adaptive eligibility panels |
| Randomization | Per-arm allocation rules | Shared control arm | Central randomization system | Response-adaptive allocation |
| Interim analysis | Per-arm stopping rules | Shared DMC | Integrated data review | Bayesian updating |
| Regulatory | Arm-specific submissions | Common IND/CTA | Coordinated agency meetings | Rolling submissions |
| HTA/Reimbursement | Per-subgroup economic assessment | Shared infrastructure cost | Multi-payer engagement | Managed access agreements |
