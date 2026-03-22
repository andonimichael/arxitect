---
name: clean-architecture-review
description: Reviews code for clean architecture compliance including component cohesion principles (REP, CRP, CCP), component coupling principles (ADP, SDP, SAP), and quality attributes (maintainability, extensibility, testability). Use when evaluating architectural soundness of new or modified code.
---

# Clean Architecture Review

You are performing a clean architecture review. Evaluate the code against
three dimensions: component cohesion, component coupling, and quality
attributes.

## Review Process

1. **Identify the scope.** Determine the files you are meant to review. Either
   the files specified, recently changed files, or the entire codebase.

2. **Map the component structure.** Identify the logical components
   (packages, modules, directories) and their dependency relationships.
   Trace import/require statements to build a dependency graph.

3. **Evaluate component cohesion.** For each component, assess compliance
   with the three cohesion principles. See `component-cohesion.md` for
   detailed evaluation criteria.

4. **Evaluate component coupling.** Analyze dependencies between components
   for direction, stability, and abstraction. See `component-coupling.md`
   for detailed evaluation criteria.

5. **Assess quality attributes.** Evaluate testability, extensibility, and
   maintainability of the design. See `quality-attributes.md` for specific
   indicators.

6. **Produce structured output.** Follow the review output format defined in
   `skills/architecture-loop/review-output-format.md`. Every finding must
   include a severity, the principle violated, affected files, and a specific
   recommendation.

## Severity Guidelines

- **CRITICAL**: Dependency cycles exist, stable components depend on
  unstable ones, layer boundaries are violated, or the architecture prevents
  independent testing of core business logic.
- **WARNING**: Component boundaries are unclear, a component mixes concerns
  that change at different rates, or dependencies could be better organized.
- **SUGGESTION**: Minor reorganization that would improve clarity or make
  the architecture more self-documenting.

## Pragmatism

Architecture must serve the system's actual scale. A single-module utility
does not need hexagonal architecture. A two-file script does not need
dependency inversion layers. Evaluate architectural decisions against the
complexity they manage, not against an ideal textbook diagram.

The goal is an architecture that makes the system easy to understand, change,
test, and deploy independently -- not one that wins an architecture diagram
contest.
