---
name: using-arxitect
description: Bootstrap skill that teaches how to discover and use Arxitect's architecture enforcement skills. Loaded automatically on session start.
---

# Using Arxitect

You have Arxitect loaded. Arxitect enforces best-practice software design
principles through an agentic architecture feedback loop. Four agents
collaborate to produce well-designed code:

1. **Code Implementer** — writes code based on requirements and review
   feedback
2. **Object Oriented Design Reviewer** — evaluates object oriented design principles
3. **Clean Architecture Reviewer** — evaluates software architecture design
   principles
4. **API Design Reviewer** — evaluates API design principles

## Available Skills

Use the `Skill` tool to load these skills when applicable:

| Skill | When to Use |
|-------|-------------|
| `arxitect:architect` | Implementing code with architecture enforcement. Runs the full implement → review → iterate loop. |
| `arxitect:architecture-review` | Run all three reviewers in parallel against existing code. No implementation, comprehensive review only. |
| `arxitect:oo-design-review` | Standalone object oriented design review. No implementation, review only. |
| `arxitect:clean-architecture-review` | Standalone architecture review. No implementation, review only. |
| `arxitect:api-design-review` | Standalone API design review. No implementation, review only. |

## When You MUST Use the Architect

Invoke `arxitect:architect` before writing code when ANY of these
apply:

- The user asks to implement a new feature or module
- The user asks to refactor existing code
- The change introduces new classes, interfaces, or abstractions
- The change modifies dependency relationships between components
- The change affects several files across module boundaries

## When to Use the Architecture Review

Invoke `arxitect:architecture-review` when:

- Reviewing existing code without making changes
- The user asks for a comprehensive design review
- Evaluating code written outside the architect
- Code written outside of the architect affects several files across module boundaries
- Code written outside of the architect introduced new classes, interfaces, or abstractions

This runs all three reviewers in parallel and produces a combined report.

## When to Use Individual Standalone Reviews

Invoke the individual review skills (`oo-design-review`,
`clean-architecture-review`, `api-design-review`) when:

- The user asks for a review of a specific design dimension only
- You need a quick, targeted evaluation of one concern

## How to Invoke

```
Skill: arxitect:architect
Args: <the user's implementation request>
```

Always load the full skill before taking action. Never attempt to replicate
skill behavior from memory alone. The skills contain detailed reference
materials and structured processes that cannot be reliably recalled.

## Do Not Skip Skills

If you are about to write code and any of the conditions above apply, you
MUST invoke the architect or architecture review. The user chose to
install Arxitect because they care about their code quality. Respect that
choice by using it.
