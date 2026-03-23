# Arxitect

Arxitect is an agentic coding plugin that enforces best-practice software design principles. It adds architecture reviewers to your coding agent that automatically evaluate your code against Object-Oriented Design, Clean Architecture, and API Design standards.

## Background

Arxitect was influenced by the design of [Superpowers](https://github.com/obra/superpowers). Arxitect extends Superpower's concept of improving agents at implementing coding tasks to improving agents at broader code architecture and software design.

Modern coding agents are getting exceptionally good at implementing a given coding task. And with validation-in-the-loop, you can be reasonably confident they will implement a correct solution. However, their implementation often doesn't adhere to the decades of software design best-practices that the community has established and is often myopic to broader software quality attributes including maintainability and extensibility. To make things worse, this low code quality compounds as coding agents implement additional tasks.

Software design principles weren't established specifically to help humans. They were designed to make code easier to refactor, modify, extend, test, and maintain. They proactively mitigate the risk of bugs. They reduce the surface area for changes. They minimize the amount of information needed to grok the code. All of these are just as important for agents. They reduce the amount of context needed to understand the code and make changes. They reduce the chance of bugs and improve testing efficacy. And they make agents more effective at implementing feature requests.

## How it works

When you ask your coding agent to implement something, Arxitect provides skills that review the result against established design principles. Three specialized reviewers examine your code from different angles:

- An **API Design Reviewer** assesses naming conventions, method signatures, parameter design, type safety, and REST endpoint design.
- An **Object Oriented Design Reviewer** checks SOLID principles, DRY violations, composition vs. inheritance choices, and design pattern applicability.
- A **Clean Architecture Reviewer** evaluates component cohesion (REP, CRP, CCP), component coupling (ADP, SDP, SAP), and quality attributes like maintainability and testability.

You can run reviewers individually, run all three at once, or use the **architecture loop** — an automated feedback cycle that implements code, runs all reviewers, fixes findings, and iterates until every reviewer approves or a safety valve triggers (3 iterations max).

Because each reviewer runs as a parallel subagent with its own reference material, reviews are fast and focused. Findings use a structured format with severity levels, so critical issues block progress while minor suggestions don't slow you down.

## Installation

**Note:** Installation differs by platform. Claude Code and Cursor have built-in plugin support. Codex requires manual setup.

### Claude Code (via Plugin Marketplace)

In Claude Code, register the marketplace first:

```bash
/plugin marketplace add andonimichael/arxitect-marketplace
```

Then install the plugin:

```bash
/plugin install arxitect@arxitect-marketplace
```

### Cursor

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/andonimichael/arxitect/refs/heads/main/.cursor/INSTALL.md
```

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/andonimichael/arxitect/refs/heads/main/.codex/INSTALL.md
```

### Gemini CLI

```bash
gemini extensions install https://github.com/andonimichael/arxitect
```

### Verify Installation

Start a new session and ask your agent to review your code's architecture. It should automatically invoke the relevant Arxitect skill.

## Skills

### Reviews

- **architecture-review** — Runs all three reviewers (Object Oriented Design, Clean Architecture, API Design) in parallel against your code.
- **oo-design-review** — Reviews SOLID principles, DRY, composition and inheritance choices, and Gang of Four design pattern applicability.
- **clean-architecture-review** — Reviews component cohesion, component coupling, and quality attributes (maintainability, extensibility, testability).
- **api-design-review** — Reviews naming conventions, self-documenting interfaces, method and parameter design, type safety, and REST endpoint design.

### Workflow

- **architecture-loop** — Implements code, then runs all three architecture reviews in a feedback loop, iterating until all reviewers approve or the safety valve triggers.

### Meta

- **using-arxitect** — Introduction to the skills system. Loaded automatically on session start.
