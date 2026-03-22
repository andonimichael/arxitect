---
name: architecture-loop
description: Orchestrates an architecture-enforced implementation feedback loop. Implements code, then runs Object Oriented Design, Clean Architecture, and API Design reviews, iterating until all reviewers approve or the safety valve triggers. Use when implementing code that should meet design quality standards.
---

# Architecture Feedback Loop

You are orchestrating a feedback loop that ensures code meets object-oriented
design, clean architecture, and API design standards.

The loop alternates between two phases:
1. **Implement** — a Code Implementer agent writes or modifies code
2. **Review** — the **arxitect:architecture-review** skill dispatches all
   three design reviewers and returns a combined report

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

### Step 3: Architecture Review

Run the **arxitect:architecture-review** skill on the list of files the
implementer created or modified. It dispatches all three reviewers (Object
Oriented Design, Clean Architecture, API Design) and returns a combined
report with verdicts and structured findings.

### Step 4: Evaluate

Check all review verdicts:

**All APPROVED**: The loop is complete. Proceed to Step 6.

**Any CHANGES_REQUESTED**: Compile a feedback document from the combined
review report:

```
## Review Feedback — Iteration [N]

### Object Oriented Design Findings
[CRITICAL and WARNING findings with ID, description, files, recommendation]

### Clean Architecture Findings
[CRITICAL and WARNING findings with ID, description, files, recommendation]

### API Design Findings
[CRITICAL and WARNING findings with ID, description, files, recommendation]

### Previously Addressed
[Finding IDs fixed in prior iterations, to prevent regression]

### Iteration History
- Iteration 1: [summary]
- Iteration 2: [summary]
```

Check the safety valve: if this was iteration 3, proceed to Step 5.
Otherwise, return to Step 2 with the feedback document as review feedback.

### Step 5: Safety Valve

Three iterations have completed. Check remaining findings:

- **If CRITICAL findings remain**: Present them to the user with this
  message: "The architecture feedback loop has completed 3 iterations.
  The following CRITICAL findings remain unresolved: [list]. How would you
  like to proceed?"

- **If only WARNING or SUGGESTION findings remain**: Auto-approve with
  caveats. Proceed to Step 6 but note the remaining findings as accepted
  trade-offs.

### Step 6: Complete

Present the final summary to the user:

1. **What was implemented**: Brief description of the changes
2. **Files changed**: Complete list of created or modified files
3. **Review iterations**: How many iterations and what was resolved in each
4. **Design decisions**: Key architectural choices and the principles that
   guided them
5. **Remaining items**: Any SUGGESTION-level or accepted WARNING trade-offs

## Rules

- **Never skip a review.** Even if the code looks good, always run the
  architecture-review skill. The value is in the systematic evaluation.
- **Never modify files during review.** Only the implementer modifies code.
- **Track finding IDs.** Use finding IDs to correlate fixes with findings
  and detect regressions across iterations.

## Integration

**Required skills:**
- **arxitect:architecture-review** — Dispatches all three design reviewers

**Orchestration files (read by this skill):**
- `skills/architecture-loop/implementer-prompt.md` — Guidelines for the
  Code Implementer agent
- `skills/architecture-loop/review-output-format.md` — Structured output
  format all reviewers must follow
- `skills/architecture-loop/approval-criteria.md` — Verdict rules and
  safety valve logic

**Alternative workflow:**
- **arxitect:architecture-review** — Use for read-only review without the
  implement-iterate loop
