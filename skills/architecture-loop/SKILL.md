---
name: architecture-loop
description: Orchestrates an architecture-enforced implementation feedback loop. Implements code, then runs OO Design and Clean Architecture reviews, iterating until both reviewers approve or the safety valve triggers. Use when implementing code that should meet design quality standards.
---

# Architecture Feedback Loop

You are orchestrating a feedback loop that ensures code meets both
object-oriented design and clean architecture standards.

## Overview

The loop has three agents:
1. **Code Implementer** — writes or modifies code
2. **OO Design Reviewer** — evaluates SOLID, DRY, and GoF pattern usage
3. **Clean Architecture Reviewer** — evaluates component cohesion, coupling,
   and quality attributes

The user's request: **$ARGUMENTS**

## Process

Follow these steps exactly. Do not skip or combine steps.

### Step 1: Prepare Context

Read the following files from this skill directory to prepare for
orchestration:

- `skills/architecture-loop/implementer-prompt.md`
- `skills/architecture-loop/oo-design-reviewer-prompt.md`
- `skills/architecture-loop/clean-architecture-reviewer-prompt.md`
- `skills/architecture-loop/review-output-format.md`
- `skills/architecture-loop/approval-criteria.md`
- `skills/oo-design-review/SKILL.md`
- `skills/oo-design-review/solid-principles.md`
- `skills/oo-design-review/design-patterns.md`
- `skills/oo-design-review/dry-principle.md`
- `skills/clean-architecture-review/SKILL.md`
- `skills/clean-architecture-review/component-cohesion.md`
- `skills/clean-architecture-review/component-coupling.md`
- `skills/clean-architecture-review/quality-attributes.md`

### Step 2: Implement (Iteration 1)

Construct the implementer prompt by taking `implementer-prompt.md` and
replacing:
- `$TASK` with the user's request
- `$REVIEW_FEEDBACK` with "This is the first iteration. No review feedback
  yet."

Spawn the implementer as a subagent using the Agent tool. The implementer
has full tool access (Read, Write, Edit, Bash, Glob, Grep).

Collect the implementer's output: the list of files changed and design
decisions made.

### Step 3: OO Design Review

Construct the OO reviewer prompt by taking `oo-design-reviewer-prompt.md`
and replacing:
- `$FILES` with the list of files the implementer created or modified
- `$OO_REVIEW_SKILL_CONTENT` with the contents of `skills/oo-design-review/SKILL.md`,
  `solid-principles.md`, `design-patterns.md`, and `dry-principle.md`
- `$REVIEW_OUTPUT_FORMAT` with the contents of `review-output-format.md`
- `$ITERATION_CONTEXT` with "Iteration 1. No prior review history." (or the
  accumulated history for later iterations)

Spawn the OO reviewer as a subagent using the Agent tool. The reviewer has
**read-only** tool access: Read, Glob, Grep only.

Parse the reviewer's output for:
- `VERDICT: APPROVED` or `VERDICT: CHANGES_REQUESTED`
- All findings with their IDs and severities

### Step 4: Clean Architecture Review

**If the OO review verdict is CHANGES_REQUESTED**, skip this step and
proceed directly to Step 5. There is no point in running the architecture
review if OO design issues must be fixed first — the fixes may change the
architecture.

**If the OO review verdict is APPROVED**, construct the Clean Architecture
reviewer prompt by taking `clean-architecture-reviewer-prompt.md` and
replacing:
- `$FILES` with the same file list
- `$CLEAN_ARCH_REVIEW_SKILL_CONTENT` with the contents of
  `skills/clean-architecture-review/SKILL.md`, `component-cohesion.md`,
  `component-coupling.md`, and `quality-attributes.md`
- `$REVIEW_OUTPUT_FORMAT` with the contents of `review-output-format.md`
- `$ITERATION_CONTEXT` with the iteration history

Spawn the Clean Architecture reviewer as a subagent using the Agent tool.
Read-only tool access: Read, Glob, Grep only.

Parse the reviewer's output for verdict and findings.

### Step 5: Evaluate

Check both review verdicts:

**Both APPROVED**: The loop is complete. Proceed to Step 7.

**Either CHANGES_REQUESTED**: Compile a feedback document:

```
## Review Feedback — Iteration [N]

### OO Design Findings
[List each CRITICAL and WARNING finding with ID, description, affected
files, and recommendation]

### Clean Architecture Findings
[List each CRITICAL and WARNING finding with ID, description, affected
files, and recommendation — or "Skipped: OO review must pass first" if
Step 4 was skipped]

### Previously Addressed
[List finding IDs that were fixed in prior iterations, to prevent regression]

### Iteration History
- Iteration 1: [summary of findings and outcomes]
- Iteration 2: [summary of findings and outcomes]
```

Check the safety valve: if this was iteration 3, proceed to Step 6.
Otherwise, return to Step 2 with the feedback document replacing
`$REVIEW_FEEDBACK` in the implementer prompt.

### Step 6: Safety Valve

Three iterations have completed. Check remaining findings:

- **If CRITICAL findings remain**: Present them to the user with this
  message: "The architecture feedback loop has completed 3 iterations.
  The following CRITICAL findings remain unresolved: [list]. How would you
  like to proceed?"

- **If only WARNING or SUGGESTION findings remain**: Auto-approve with
  caveats. Proceed to Step 7 but note the remaining findings as accepted
  trade-offs.

### Step 7: Complete

Present the final summary to the user:

1. **What was implemented**: Brief description of the changes
2. **Files changed**: Complete list of created or modified files
3. **Review iterations**: How many iterations were needed and what was
   resolved in each
4. **Design decisions**: Key architectural choices and the principles that
   guided them
5. **Remaining items**: Any SUGGESTION-level findings or accepted WARNING
   trade-offs for future consideration

## Important Rules

- **Never skip a review.** Even if the code looks good, run both reviewers.
  The value is in the systematic evaluation, not in catching obvious errors.
- **Never modify files during review.** Reviewers are read-only. Only the
  implementer modifies code.
- **Pass complete context.** Each subagent gets a fresh context window. Do
  not assume subagents remember anything from prior iterations. Include all
  relevant information in their prompts.
- **Track finding IDs.** Use finding IDs to correlate fixes with findings
  and detect regressions across iterations.
