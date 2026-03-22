---
name: architecture-loop
description: Orchestrates an architecture-enforced implementation feedback loop. Implements code, then runs Object Oriented Design, Clean Architecture, and API Design reviews, iterating until all reviewers approve or the safety valve triggers. Use when implementing code that should meet design quality standards.
---

# Architecture Feedback Loop

You are orchestrating a feedback loop that ensures code meets object-oriented
design, clean architecture, and API design standards.

The loop has four agents:
1. **Code Implementer** — writes or modifies code
2. **Object Oriented Design Reviewer** — evaluates object oriented design principles
3. **Clean Architecture Reviewer** — evaluates software architecture design principles
4. **API Design Reviewer** — evaluates API design principles

The user's request: **$ARGUMENTS**

## Process

Follow these steps exactly. Do not skip or combine steps.

### Step 1: Prepare Context

Read these orchestration files (not the reviewer reference material — each
reviewer reads its own):

- `skills/architecture-loop/review-output-format.md`
- `skills/architecture-loop/approval-criteria.md`

### Step 2: Implement

Spawn a Code Implementer agent with full tool access (Read, Write, Edit,
Bash, Glob, Grep). Tell it to read
`skills/architecture-loop/implementer-prompt.md` for its guidelines, then
provide:
- The user's task description
- "This is the first iteration. No review feedback yet."

Collect the implementer's output: files changed and design decisions made.

### Step 3: Object Oriented Design Review

Spawn the Object Oriented Design Reviewer agent with **read-only** access
(Read, Glob, Grep only). Tell it to read
`skills/oo-design-review/agent-prompt.md` for its instructions and reference
material, then provide the list of files the implementer created or modified.

Parse the reviewer's output for:
- `VERDICT: APPROVED` or `VERDICT: CHANGES_REQUESTED`
- All findings with their IDs and severities

### Step 4: Clean Architecture Review

**If the Object Oriented review verdict is CHANGES_REQUESTED**, skip this step
and proceed directly to Step 6. There is no point in running further reviews
if Object Oriented design issues must be fixed first — the fixes may change the
architecture.

**If the Object Oriented review verdict is APPROVED**, spawn the Clean
Architecture Reviewer agent with **read-only** access. Tell it to read
`skills/clean-architecture-review/agent-prompt.md` for its instructions and
reference material, then provide the same file list.

Parse the reviewer's output for verdict and findings.

### Step 5: API Design Review

**If any prior review verdict is CHANGES_REQUESTED**, skip this step and
proceed directly to Step 6. Fix structural issues before polishing the API
surface.

**If both prior reviews are APPROVED**, spawn the API Design Reviewer agent
with **read-only** access. Tell it to read
`skills/api-design-review/agent-prompt.md` for its instructions and
reference material, then provide the same file list

Parse the reviewer's output for verdict and findings.

### Step 6: Evaluate

Check all review verdicts:

**All APPROVED**: The loop is complete. Proceed to Step 8.

**Any CHANGES_REQUESTED**: Compile a feedback document:

```
## Review Feedback — Iteration [N]

### Object Oriented Design Findings
[List each CRITICAL and WARNING finding with ID, description, affected
files, and recommendation]

### Clean Architecture Findings
[List each CRITICAL and WARNING finding — or "Skipped: Object Oriented review
must pass first" if Step 4 was skipped]

### API Design Findings
[List each CRITICAL and WARNING finding — or "Skipped: prior reviews must
pass first" if Step 5 was skipped]

### Previously Addressed
[Finding IDs fixed in prior iterations, to prevent regression]

### Iteration History
- Iteration 1: [summary]
- Iteration 2: [summary]
```

Check the safety valve: if this was iteration 3, proceed to Step 7.
Otherwise, return to Step 2 with the feedback document replacing
`$REVIEW_FEEDBACK` in the implementer prompt.

### Step 7: Safety Valve

Three iterations have completed. Check remaining findings:

- **If CRITICAL findings remain**: Present them to the user with this
  message: "The architecture feedback loop has completed 3 iterations.
  The following CRITICAL findings remain unresolved: [list]. How would you
  like to proceed?"

- **If only WARNING or SUGGESTION findings remain**: Auto-approve with
  caveats. Proceed to Step 8 but note the remaining findings as accepted
  trade-offs.

### Step 8: Complete

Present the final summary to the user:

1. **What was implemented**: Brief description of the changes
2. **Files changed**: Complete list of created or modified files
3. **Review iterations**: How many iterations and what was resolved in each
4. **Design decisions**: Key architectural choices and the principles that
   guided them
5. **Remaining items**: Any SUGGESTION-level or accepted WARNING trade-offs

## Rules

- **Never skip a review.** Even if the code looks good, run all reviewers
  that are eligible (not short-circuited). The value is in the systematic
  evaluation.
- **Never modify files during review.** Reviewers are read-only. Only the
  implementer modifies code.
- **Progressive disclosure.** Do not pre-load reviewer reference files into
  the prompt. Each reviewer agent reads its own skill files.
- **Track finding IDs.** Use finding IDs to correlate fixes with findings
  and detect regressions across iterations.
