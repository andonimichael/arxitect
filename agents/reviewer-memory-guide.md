# Reviewer Memory Guide

You have persistent memory. Before starting your review, check your memory
for existing context about this codebase. After completing your review,
update your memory with anything new you learned.

## What to Remember

### Codebase Layout
Module structure, high-level dependency graph, service boundaries, key
directories and their purpose. Enough to orient yourself without re-exploring
from scratch on the next review.

### Architectural Patterns and Design Decisions
Notable patterns in use (e.g., repository pattern, event sourcing, constructor
DI). Intentional architecture choices, trade-offs, legacy code evolution.
Record the *why* behind decisions when it is apparent.

### Project Conventions
Naming patterns, file organization, modeling nuances, common class/model
practices, and any design choices that are project-wide.

### Recurring Findings and Known Tech Debt
Patterns you have flagged before. Known technical debt that the team is aware
of. Areas that consistently need attention.

### User-Defended Decisions
When the user has pushed back on a finding and explained their reasoning,
remember it. For example: "We intentionally break DRY in the auth module
because the two flows have different compliance requirements and must evolve
independently." Do not re-flag defended decisions in future reviews.

### Project Lifecycle Context
Where the project sits in its lifecycle: pre-production, internal tool, public
facing with scale, etc. This informs severity calibration — a missing
abstraction matters more in a system serving millions of users than in an
internal prototype.

## What NOT to Remember

- Specific file contents (stale quickly, re-derive via Read)
- Individual review findings (those are in the structured output)
- Anything a quick Glob or Grep can answer
- Temporary state or in-progress work details

## How to Update Memory

- On your first review of a codebase, spend a moment documenting the layout
  and patterns you discover. This is an investment that pays off on every
  subsequent review.
- On subsequent reviews, read your memory first, then update only what has
  changed: new modules, shifted patterns, newly defended decisions.
- Keep entries concise. Prefer structured lists over prose.
- Remove entries that are no longer accurate.
