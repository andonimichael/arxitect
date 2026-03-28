---
name: architecture-review
description: Runs all three architecture reviewers (Object Oriented Design, Clean Architecture, and API Design Reviewers).
---

# Architecture Review

You are orchestrating a read-only architecture review. Three independent
reviewers evaluate code for object-oriented design, clean architecture, and
API design quality.

The user's request: **$ARGUMENTS**

## Process

Follow these steps exactly. Do not skip or combine steps.

### Step 1: Identify Files to Review

Determine the files to review from the user's request. If the user
specified files or directories, use those. If the request is vague (e.g.,
"review the auth module"), use Glob and Grep to identify the relevant source
files. Exclude test files, configuration files, and generated files unless
the user explicitly asks to review them.

Build a file list: one file path per line.

### Step 2: Dispatch Reviewers

Spawn all three reviewers as sub-agents using the Agent tool. Each reviewer
must have **read-only** access (Read, Glob, Grep only) — it must not modify any
files.

**If the environment supports parallel agents**, dispatch all three in a
single message so they run concurrently. **If not**, dispatch them one at a
time in any order.

The reason we are delegating these tasks to specialized sub-agents is because
they operate with isolated context and precise instructions that will better
allow them to review the code for their lens.

**If the environment supports named agent definitions** (e.g., Claude Code
`subagent_type`), use the dedicated reviewer agents below. They are
pre-configured with read-only tools and pre-loaded review skills. Pass only
the file list and any additional context in the prompt.

**If not**, spawn generic agents and tell each to read its `agent-prompt.md`
for instructions and reference material. Restrict tool access to Read, Glob,
Grep if the environment supports tool restrictions on agent spawning.

#### Object Oriented Design Reviewer

Named agent: `subagent_type: "oo-design-reviewer"`
Fallback prompt: Tell the agent to read
`skills/oo-design-review/agent-prompt.md`.

#### Clean Architecture Reviewer

Named agent: `subagent_type: "clean-architecture-reviewer"`
Fallback prompt: Tell the agent to read
`skills/clean-architecture-review/agent-prompt.md`.

#### API Design Reviewer

Named agent: `subagent_type: "api-design-reviewer"`
Fallback prompt: Tell the agent to read
`skills/api-design-review/agent-prompt.md`.

### Step 3: Present Combined Report

Wait for all reviewers to complete. Parse each reviewer's output for its
VERDICT and all structured findings. Present a unified report:

```
## Architecture Review Results

### Overall Verdict: [APPROVED | CHANGES_REQUESTED]

APPROVED only if all three reviewers returned APPROVED.

### Object Oriented Design — [VERDICT]
[Findings in structured format]

### Clean Architecture — [VERDICT]
[Findings in structured format]

### API Design — [VERDICT]
[Findings in structured format]

### Priority Actions
[All CRITICAL findings first, then WARNINGs that appeared across multiple
reviewers or compound across domains.]
```

## Rules

- **Read-only.** No reviewer may modify files.
- **Progressive disclosure.** Do not pre-load reviewer reference files
  into prompts. Each agent reads its own material — either via pre-loaded
  skills (named agents) or by reading its `agent-prompt.md` (fallback).
- **Preserve finding structure.** The structured finding format enables
  downstream use (e.g., feeding findings into the architect).
  Do not summarize away the detail.

## Integration

**Required skills:**
- **arxitect:oo-design-review** — Object oriented design reviewer
- **arxitect:clean-architecture-review** — Clean architecture reviewer
- **arxitect:api-design-review** — API design reviewer

**Orchestration files (read by this skill):**
- `skills/architect/review-output-format.md` — Structured output
  format all reviewers must follow

**Alternative workflow:**
- **arxitect:architect** — Use when you want implementation with
  architecture enforcement, not just a read-only review
