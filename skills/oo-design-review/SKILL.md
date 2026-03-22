---
name: oo-design-review
description: Reviews code for object-oriented design quality including SOLID principles, DRY violations, composition and inheritance choices, and Gang of Four design pattern applicability. Use when evaluating OO design of new or modified code.
---

# OO Design Review

You are performing an object-oriented design review. Evaluate the code against
four pillars: SOLID principles, DRY, composition and inheritance, and Gang
of Four design patterns.

## Review Process

1. **Identify the scope.** Read all files specified in $ARGUMENTS. If no files
   are specified, identify recently changed files via `git diff --name-only`.

2. **Evaluate SOLID principles.** For each file, check compliance with all five
   SOLID principles. See `solid-principles.md` in this skill directory for
   detailed evaluation criteria and violation indicators.

3. **Check for DRY violations.** Look for duplicated logic, repeated
   conditionals, and copy-pasted structures. See `dry-principle.md` for
   guidance on distinguishing true duplication from accidental similarity.

4. **Evaluate composition and inheritance usage.** Check that inheritance
   models true "is-a" relationships and passes the Liskov Substitution test.
   Flag inheritance used solely for code reuse, deep hierarchies, and
   refused bequests. See `composition-and-inheritance.md` for the decision
   framework and common misapplications.

5. **Assess design pattern applicability.** Identify places where a Gang of
   Four pattern would reduce complexity or improve extensibility. Also flag
   misapplied patterns that add unnecessary abstraction. See
   `design-patterns.md` for the pattern catalog and applicability heuristics.

6. **Produce structured output.** Follow the review output format defined in
   `skills/architecture-loop/review-output-format.md`. Every finding must
   include a severity, the principle violated, affected files, and a specific
   recommendation.

## Severity Guidelines

- **CRITICAL**: The violation will cause maintenance problems at scale, makes
  the code resistant to change, or introduces tight coupling that prevents
  independent deployment or testing.
- **WARNING**: The code works but misses an opportunity for better design, or
  uses a pattern in a way that may cause friction as the system grows.
- **SUGGESTION**: Minor improvement that would enhance clarity or
  expressiveness but does not affect correctness or maintainability.

## Pragmatism

Do not demand patterns for the sake of patterns. A three-line function does
not need a Strategy pattern. A single implementation does not need an
interface. Evaluate design decisions in the context of the system's current
scale and likely evolution. Flag over-engineering as readily as under-engineering.

The goal is code that is easy to understand, change, and test -- not code that
demonstrates the maximum number of design patterns.
