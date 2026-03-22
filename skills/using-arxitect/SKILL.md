---
name: using-arxitect
description: Bootstrap skill that teaches Claude how to discover and use Arxitect's architecture enforcement skills. Loaded automatically on session start.
---

# Using Arxitect

You have Arxitect loaded. Arxitect enforces best-practice software design
principles through an agentic architecture feedback loop. Three agents
collaborate to produce well-designed code:

1. **Code Implementer** — writes code based on requirements and review
   feedback
2. **OO Design Reviewer** — evaluates SOLID principles, DRY, and Gang of
   Four design patterns
3. **Clean Architecture Reviewer** — evaluates component cohesion, coupling
   principles, and quality attributes (testability, extensibility,
   maintainability)

## Available Skills

Use the `Skill` tool to load these skills when applicable:

| Skill | When to Use |
|-------|-------------|
| `arxitect:architecture-loop` | Implementing code with architecture enforcement. Runs the full implement → review → iterate loop. |
| `arxitect:oo-design-review` | Standalone OO design review: SOLID, DRY, GoF patterns. No implementation, review only. |
| `arxitect:clean-architecture-review` | Standalone architecture review: cohesion, coupling, quality attributes. No implementation, review only. |

## When You MUST Use the Architecture Loop

Invoke `arxitect:architecture-loop` before writing code when ANY of these
apply:

- The user asks to implement a new feature or module
- The user asks to refactor existing code
- The change introduces new classes, interfaces, or abstractions
- The change modifies dependency relationships between components
- The change touches more than three files

## When to Use Standalone Reviews

Invoke the individual review skills when:

- Reviewing existing code without making changes
- The user explicitly asks for a design review
- Evaluating code written outside the architecture loop

## How to Invoke

```
Skill: arxitect:architecture-loop
Args: <the user's implementation request>
```

Always load the full skill before taking action. Never attempt to replicate
skill behavior from memory alone. The skills contain detailed reference
materials and structured processes that cannot be reliably recalled.

## Do Not Skip Skills

If you are about to write code and any of the conditions above apply, you
MUST invoke the architecture loop. Common rationalizations to watch for:

| Thought | Why It Is Wrong |
|---------|-----------------|
| "This is a simple change" | Simple changes compound. The loop catches issues early. |
| "I already know the design patterns" | The value is in systematic review, not pattern knowledge. |
| "It will be faster without the loop" | Speed without quality creates debt that costs more later. |
| "The user seems to want a quick answer" | The user installed Arxitect because they want quality. |
| "I can review my own code" | Self-review has blind spots. Independent reviewers catch more. |

The user chose to install Arxitect. Respect that choice by using it.
