# Approval Criteria

These criteria govern when the architecture feedback loop terminates.

## APPROVED Conditions

A reviewer issues APPROVED when:
- Zero CRITICAL findings exist
- Fewer than three WARNING findings exist
- Remaining WARNING findings (if any) are acknowledged as acceptable
  trade-offs with documented rationale

## CHANGES_REQUESTED Conditions

A reviewer issues CHANGES_REQUESTED when:
- Any CRITICAL finding exists
- Three or more WARNING findings exist
- A previously fixed finding has regressed (see Regression Guard below)

## Reviewer Discretion

For borderline cases with one or two WARNING findings, reviewers lean toward
APPROVED when:
- The warnings represent deliberate trade-offs documented in the code
- Fixing the warnings would require changes disproportionate to the benefit

Reviewers lean toward CHANGES_REQUESTED when:
- The warnings interact with each other to create a compound risk
- The fix is straightforward and proportionate

## Safety Valve

The feedback loop runs a maximum of **3 full iterations**. One iteration
consists of: implementation (or re-implementation) followed by reviews.

After 3 iterations:
- If CRITICAL findings remain: **stop and present remaining issues to the
  user** for a decision. The user may accept the current state, provide
  guidance, or request additional iterations.
- If only WARNING or SUGGESTION findings remain: **auto-approve with
  caveats**. List the remaining findings and note them as accepted
  trade-offs given the iteration budget.

## Regression Guard

If a finding that was marked as addressed in iteration N reappears in
iteration N+1:
- Escalate it to CRITICAL regardless of its original severity
- Include in the finding description: "Regression: this issue was addressed
  in iteration N but has reappeared"
- The regression likely indicates the implementer did not understand the
  root cause; the finding description should clarify the underlying issue

## Iteration Tracking

The orchestrator tracks:
- Current iteration number (1-3)
- Finding IDs from each iteration
- Which findings were addressed vs. which persisted or regressed
- Running tally of CRITICAL, WARNING, and SUGGESTION counts per iteration

This tracking is passed to the implementer as context in the feedback
document so the implementer understands the history and avoids regressions.
