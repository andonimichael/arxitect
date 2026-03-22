---
name: using-arxitect
description: Bootstrap skill that teaches Claude how to discover and use Arxitect's architecture enforcement skills. Loaded automatically on session start.
---

# Using Arxitect

You have Arxitect loaded. Arxitect enforces best-practice software design
principles through an agentic architecture feedback loop.

## Available Skills

Arxitect provides the following skills. Use the `Skill` tool to load them
when applicable:

| Skill | When to Use |
|-------|-------------|
| `arxitect:architecture-loop` | When implementing code that should be reviewed for design quality |
| `arxitect:oo-design-review` | When you need a standalone OO design review (SOLID, DRY, GoF) |
| `arxitect:clean-architecture-review` | When you need a standalone architecture review (cohesion, coupling, quality attributes) |

## When to Invoke Skills

Before writing or modifying code, consider whether the change would benefit
from architecture review. Use the architecture loop skill when:

- Implementing new features or modules
- Refactoring existing code
- Adding new classes, interfaces, or abstractions
- Modifying dependency relationships between components

Use standalone review skills when:

- Reviewing existing code without making changes
- Evaluating a specific design concern (OO or architectural)
- The user explicitly requests a targeted review

## How to Invoke

Load a skill using the Skill tool:

```
Skill: arxitect:architecture-loop
Args: <the user's implementation request>
```

Always load the full skill before taking action. Never attempt to replicate
skill behavior from memory alone.
