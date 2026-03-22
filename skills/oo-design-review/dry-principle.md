# DRY Principle Reference

## Definition

Don't Repeat Yourself: Every piece of knowledge must have a single,
unambiguous, authoritative representation within a system.

DRY is about knowledge duplication, not code duplication. Two identical code
blocks that represent different domain concepts are not DRY violations. Two
different code blocks that encode the same business rule are.

## True Duplication vs. Accidental Similarity

### True duplication
Two code blocks:
- Change for the same reason
- Represent the same business rule or domain concept
- Must be updated in lockstep when requirements change

**Example**: A validation rule duplicated in both the API handler and the
domain model. When the rule changes, both must be updated identically.

### Accidental similarity
Two code blocks:
- Happen to look alike today
- Represent different domain concepts
- Will likely diverge as the system evolves

**Example**: Two different entities both have a `validate()` method that checks
`name.length > 0`. These serve different business purposes and will likely
diverge as each entity's validation rules grow.

## The Rule of Three

Before extracting shared code, wait until you see three instances of true
duplication. Two instances might be accidental similarity. Three instances
confirm a pattern worth abstracting.

When you do extract:
1. Ensure all instances truly change for the same reason
2. Name the abstraction after the concept it represents, not the code it
   contains
3. Make the abstraction easy to discover so future developers use it instead
   of creating a fourth copy

## Appropriate Abstraction Strategies

### Extract a function
Best for duplicated logic within a single module. Keep it close to its
callers.

### Extract a class
Best for duplicated logic that involves state or multiple cooperating
operations.

### Extract a module or package
Best for duplication across multiple modules that represents a shared domain
concept.

### Parameterize
Best when two code blocks differ only in a value or small behavioral
variation. Pass the difference as a parameter.

## When Duplication Is Acceptable

- **Test code**: Tests should be readable in isolation. Extracting shared
  setup or assertions into helpers can make tests harder to understand when
  they fail. Prefer explicit test code over DRY test code.

- **Decoupling over DRY**: If removing duplication would couple two modules
  that should be independent, keep the duplication. Independence is more
  valuable than deduplication.

- **Trivial code**: One-line expressions or simple assignments are not worth
  extracting even if repeated. The indirection cost exceeds the duplication
  cost.

- **Cross-boundary duplication**: DTOs, API contracts, or protocol buffers
  that mirror domain objects are intentional. They isolate boundaries from
  internal changes.
