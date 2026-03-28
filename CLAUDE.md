# Arxitect

Arxitect is an agentic coding plugin that enforces best-practice software
design & architecture. It contains skills for auditing your code for API
design, object oriented design, and clean architecture. Additionally, it
contains implementation and code review agents.

## Project Structure

- `.claude-plugin/` - Plugin manifest for Claude Code registration
- `.codex/` - Installation instructions for ChatGPT Codex
- `.cursor/` - Installation instructions for Cursor
- `.cursor-plugin/` - Plugin manifest for Cursor registration
- `agents/` - Agent definitions (orchestrators and reviewers)
- `hooks/` - Session lifecycle hooks (bootstrap injection)
- `scripts/` - The release script
- `skills/` - Core skills, each in its own directory with a `SKILL.md`
- `tests/` - Static and dynamic tests

## Development Guidelines

This plugin is pure Markdown and shell scripts with zero runtime dependencies.

### Skills

Each skill lives in `skills/<skill-name>/SKILL.md` with YAML frontmatter
(`name`, `description`). Supporting reference files live alongside the SKILL.md.


### Agents

Orchestrator agents (`architect`, `architecture-review`) delegate to their
corresponding skills. Reviewer agents (`oo-design-reviewer`,
`clean-architecture-reviewer`, `api-design-reviewer`) are spawned by the
architecture-review orchestrator with read-only tools, pre-loaded skills,
and persistent local memory. `reviewer-memory-guide.md` is a shared guide
for what reviewers should remember across reviews.

Subagent prompt templates (`agent-prompt.md`) live alongside their skill as
a fallback for environments that do not support named agent definitions.

### Commits

Follow Chris Beams' seven rules of a great git commit message:
1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how
