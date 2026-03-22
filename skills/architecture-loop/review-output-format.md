# Review Output Format

All architecture reviews MUST use this structured format. The orchestrator
parses verdicts and findings to drive the feedback loop.

## Required Structure

```
### VERDICT: [APPROVED | CHANGES_REQUESTED]

### Summary
[1-2 sentence overall assessment of the code's design quality]

### Findings

#### [FINDING-ID]: [Title]
- **Severity**: CRITICAL | WARNING | SUGGESTION
- **Principle**: [Which principle is violated, e.g., SRP, OCP, ADP, CRP]
- **File(s)**: [Affected file paths]
- **Line(s)**: [Approximate line numbers if applicable]
- **Description**: [What the issue is and why it matters]
- **Recommendation**: [Specific, actionable suggestion for how to fix]

### Metrics
- Critical: [count]
- Warnings: [count]
- Suggestions: [count]
```

## Finding ID Convention

- OO Design findings use prefix `OO-` followed by a three-digit number:
  `OO-001`, `OO-002`, etc.
- Clean Architecture findings use prefix `CA-` followed by a three-digit
  number: `CA-001`, `CA-002`, etc.
- API Design findings use prefix `API-` followed by a three-digit number:
  `API-001`, `API-002`, etc.
- Finding IDs must be unique within a review and stable across iterations
  so the orchestrator can track which findings have been addressed.

## Verdict Rules

- **APPROVED**: Zero CRITICAL findings. Any remaining WARNING or SUGGESTION
  findings are noted but do not block approval.
- **CHANGES_REQUESTED**: One or more CRITICAL findings exist, OR three or
  more WARNING findings exist.

## Writing Effective Findings

- **Be specific.** Point to exact files and lines. "The code violates SRP"
  is not useful. "UserService handles both authentication and email
  notifications (lines 45-80 and 120-160)" is actionable.
- **Explain the consequence.** Why does this violation matter? What will
  break or degrade as the system evolves?
- **Recommend concretely.** "Extract EmailNotifier class implementing a
  NotificationPort interface" is better than "Consider separating concerns."
- **Calibrate severity honestly.** Not every imperfection is CRITICAL.
  Reserve CRITICAL for issues that will cause real pain. Use SUGGESTION for
  improvements that are genuinely optional.
