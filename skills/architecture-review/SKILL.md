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

Spawn all three reviewers using the Agent tool. Each reviewer must have
**read-only** access (Read, Glob, Grep only) — it must not modify any
files.

**If the environment supports parallel agents**, dispatch all three in a
single message so they run concurrently. **If not**, dispatch them one at a
time in any order.

Each reviewer agent gets a focused prompt with the file list and a pointer
to its `agent-prompt.md`. The reviewer reads its own skill files — do
**not** pre-load reference files and inject them into the prompt.

For each reviewer, tell it to read its `agent-prompt.md` for instructions
and reference material, then provide the file list to review.

The reason we are delegating these tasks to specialized sub-agents is because
they operate with isolated context and precise instructions that wll better
allow them to review the code for their lens.

#### Object Oriented Design Reviewer

Tell the agent to read `skills/oo-design-review/agent-prompt.md`.

#### Clean Architecture Reviewer

Tell the agent to read `skills/clean-architecture-review/agent-prompt.md`.

#### API Design Reviewer

Tell the agent to read `skills/api-design-review/agent-prompt.md`.

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
- **Progressive disclosure.** Do not pre-load reviewer reference files.
  Each agent reads its own material.
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
