---
name: api-design-review
description: Reviews code for API design quality including naming conventions, self-documenting interfaces, method signatures, parameter design, type safety, and REST endpoint design. Use when evaluating the usability and readability of public interfaces, class APIs, or REST endpoints.
---

# API Design Review

You are performing an API design review. Evaluate the code's public
interfaces — class APIs, method signatures, REST endpoints, and type
definitions — for usability, clarity, and self-documentation.

## Review Process

1. **Identify the scope.** Read all files specified in $ARGUMENTS. If no files
   are specified, identify recently changed files via `git diff --name-only`.

2. **Catalog public interfaces.** Identify all public-facing surfaces: class
   methods, exported functions, REST endpoints, type definitions, and
   configuration interfaces.

3. **Evaluate naming.** Check all names (classes, methods, parameters,
   endpoints) against the naming conventions in `naming-conventions.md`.

4. **Evaluate method and parameter design.** Assess method signatures for
   clarity, parameter count, type safety, and self-documentation. See
   `method-and-parameter-design.md`.

5. **Evaluate REST endpoints** (if applicable). Check endpoint design against
   the REST best practices in `rest-endpoint-design.md`.

6. **Produce structured output.** Follow the review output format defined in
   `skills/architecture-loop/review-output-format.md`. Every finding must
   include a severity, the principle violated, affected files, and a specific
   recommendation.

## Finding ID Convention

API Design findings use prefix `API-` followed by a three-digit number:
`API-001`, `API-002`, etc.

## Severity Guidelines

- **CRITICAL**: A public interface name is misleading, a method signature
  makes incorrect usage easy, or an API violates established conventions in
  a way that will confuse consumers.
- **WARNING**: Naming could be clearer, a parameter list is too long, types
  are weaker than they could be, or an endpoint deviates from REST
  conventions.
- **SUGGESTION**: Minor naming polish, documentation improvements, or
  stylistic consistency that would enhance readability.

## Pragmatism

API design serves the humans who will use the interface. Evaluate names and
signatures from the perspective of a developer encountering the API for the
first time:

- Can they understand what a method does from its name alone?
- Can they call it correctly without reading the implementation?
- Will their IDE's autocomplete guide them toward correct usage?
- Will they be surprised by the behavior?

The best API is one that requires no documentation because the names and
types communicate everything. But do not demand perfection in internal
utilities that have a single caller — reserve the highest standards for
public interfaces that many consumers will depend on.
