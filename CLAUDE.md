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
- `agents/` - The architecture-loop and architecture-review agents
- `hooks/` - Session lifecycle hooks (bootstrap injection)
- `scripts/` - The release script
- `skills/` - Core skills, each in its own directory with a `SKILL.md`
- `tests/` - Static and dynamic tests

## Development Guidelines

This plugin is pure Markdown and shell scripts with zero runtime dependencies.

### Skills

Each skill lives in `skills/<skill-name>/SKILL.md` with YAML frontmatter
(`name`, `description`). Supporting reference files live alongside the SKILL.md.

### Subagent Prompts

Subagent prompt templates live alongside their orchestrating skill, not in a
separate directory. The orchestrator reads these templates and injects them
into Agent tool calls.

### Commits

Follow Chris Beams' seven rules of a great git commit message:
1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how
