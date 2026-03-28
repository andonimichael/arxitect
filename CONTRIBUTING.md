# Contributing to Arxitect

Thank you for your interest in contributing to Arxitect! This guide covers
everything you need to get started.

## Getting Started

1. Clone the repository
2. Create a branch for your change
3. Make your changes, add or update any tests, and verify all tests passes
4. Open a pull request against `main`

## Project Layout

```
arxitect/
├── agents/                    # Agent definitions
├── skills/                    # Skill definitions
├── hooks/                     # Session lifecycle hooks
└── tests/                     # Static and behavioral tests
```

## Running Tests

### Prerequisites

Static tests have no dependencies — they just need `bash`. Behavioral tests,
skill-triggering tests, and explicit-skill-request tests require a working
Claude Code CLI with valid API credentials.

### Test Commands

```bash
# Static tests only (fast, no credentials needed)
npm test

# Behavioral tests (requires Claude CLI credentials)
npm run test:behavioral

# Skill triggering tests (requires Claude CLI credentials)
npm run test:triggering

# Explicit skill request tests (requires Claude CLI credentials)
npm run test:explicit

# All tests
npm run test:all
```

You can also run a single static test suite by name:

```bash
./tests/run-tests.sh --test skill-structure
```

At a minimum, run `npm test` before submitting a PR. If your change modifies
skill content or agent behavior, run the relevant behavioral tests too.

## Skills

### Skill Structure

Each skill lives in `skills/<skill-name>/` and contains:

| File | Purpose |
|------|---------|
| `SKILL.md` | The skill definition. Markdown frontmatter (`name`, `description`) followed by the skill's instructions. |
| `agent-prompt.md` | Subagent prompt template for reviewer skills. |
| `*.md` (other) | Reference material the skill reads at runtime (e.g., `solid-principles.md`). |

### Key Design Principles

- **Progressive disclosure** — Skills should only add as much initial context
  as necessary. All additional context, instructions, grading criteria, etc.
  should be progressively disclosed as skills are run via file pointers.
- **Named agents over inline prompts** — Reviewer agents have dedicated
  definitions in `agents/` with pre-loaded skills, tool restrictions, and
  memory. The `agent-prompt.md` files remain as fallbacks for environments
  that do not support named agent definitions.
- **Reference material is skill-scoped** — Each reviewer owns its own
  reference files for isolation.

### Modifying Existing Skills

1. Read the existing SKILL.md and its reference files to understand the
   current behavior.
2. Make your changes. Keep the frontmatter `name` and `description` accurate.
3. If you change review criteria or reference material, make sure the
   corresponding SKILL.md still references it correctly.
4. Update any relevant tests. Static tests verify the file name, location,
   and content. Behavioral tests verify the integration into Claude Code.
5. Verify your changes: `npm run test:all`.
6. Push a pull request against `main`.

### Creating a New Skill

1. Create a new skills directory: `skills/<your-skill-name>`
2. Write your `SKILL.md` with markdown frontmatter. Any additional instructions
   or criteria should be kept as a separate file that allows for progressive
   disclosure.
3. Create a lightweight `agent-prompt.md` that sets up the agent harness and
   calls out to your new skill.
4. Wire your skill throughout the architect & architecture-review skills, their
   corresponding agents, and the using-arxitect overview.
5. Add static and behavioral tests.
6. Update any relevant documentation and coding agent instructions.
7. Verify your changes: `npm run test:all`.
8. Push a pull request against `main`.

## Agents

### Agent Structure

Each agent is a single Markdown file in `agents/` with markdown frontmatter.

**Orchestrator agents** (architect, architecture-review) coordinate skills:

```markdown
name: <agent-name>
description: One-line description of the agent.
model: inherit
skills:
  - <corresponding-skill-name>
```

**Reviewer agents** (oo-design-reviewer, clean-architecture-reviewer,
api-design-reviewer) are spawned by the architecture-review orchestrator
with restricted configuration:

```markdown
name: <reviewer-name>
description: One-line description of the reviewer.
model: inherit
tools: Read, Glob, Grep
permissionMode: dontAsk
memory: local
skills:
  - <corresponding-review-skill>
```

- `tools` restricts reviewers to read-only access.
- `permissionMode: dontAsk` avoids permission prompts for read-only tools.
- `memory: local` gives reviewers persistent memory about the codebase
  (gitignored). See `agents/reviewer-memory-guide.md` for what reviewers
  should remember.

Agent instructions should be straightforward and mostly delegate to their
corresponding skills.

### Modifying Existing Agents

1. If you're changing agent behavior, the change almost certainly belongs
   in the orchestrating skill (SKILL.md), not in the agent definition.
2. If you do need to change the agent behavior, then update their Markdown file.
   Make sure you keep the frontmatter accurate.
3. Update any relevant tests. Static tests verify the file name, location,
   and content. Behavioral tests verify the integration into Claude Code.
4. Verify your changes: `npm run test:all`.
5. Push a pull request against `main`.

## Commit Messages

Follow [Chris Beams'](https://cbea.ms/git-commit) seven rules of a great git commit message:

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

## Submitting a Pull Request

1. Make sure `npm test` passes at minimum
2. Push your branch
3. Open a pull request against `main`
4. Fill out the PR template
5. Wait for review — a maintainer will get back to you

## Reporting Bugs & Requesting Features

Use [GitHub Issues](https://github.com/andonimichael/arxitect/issues) to
report bugs or suggest features. Please use the provided issue templates.

## Code of Conduct

This project follows the [Contributor Covenant 3.0](CODE_OF_CONDUCT.md). By
participating, you agree to uphold its standards.

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).
