#!/usr/bin/env bash
# Validates skill content: required sections, cross-references, and conventions.

set -euo pipefail
. "$(dirname "$0")/../test-helpers.sh"

SKILLS_DIR="${PROJECT_ROOT}/skills"

# ── Reviewer skills define finding ID prefixes ───────────────────────────────

begin_suite "Review Output Format and Finding ID Prefixes"

OUTPUT_FORMAT="${SKILLS_DIR}/architecture-loop/review-output-format.md"

assert_file_contains "$OUTPUT_FORMAT" "OO-" "Output format documents OO- prefix"
assert_file_contains "$OUTPUT_FORMAT" "CA-" "Output format documents CA- prefix"
assert_file_contains "$OUTPUT_FORMAT" "API-" "Output format documents API- prefix"
assert_file_contains "$OUTPUT_FORMAT" "VERDICT" "Output format defines VERDICT"
assert_file_contains "$OUTPUT_FORMAT" "APPROVED" "Output format defines APPROVED"
assert_file_contains "$OUTPUT_FORMAT" "CHANGES_REQUESTED" "Output format defines CHANGES_REQUESTED"
assert_file_contains "$OUTPUT_FORMAT" "CRITICAL" "Output format defines CRITICAL severity"
assert_file_contains "$OUTPUT_FORMAT" "WARNING" "Output format defines WARNING severity"
assert_file_contains "$OUTPUT_FORMAT" "SUGGESTION" "Output format defines SUGGESTION severity"

# ── Reviewer skills define severity levels ───────────────────────────────────

begin_suite "Severity Level Definitions"

for reviewer in "oo-design-review" "clean-architecture-review" "api-design-review"; do
  skill_file="${SKILLS_DIR}/${reviewer}/SKILL.md"
  assert_file_contains "$skill_file" "CRITICAL" \
    "skills/${reviewer} defines CRITICAL severity"
  assert_file_contains "$skill_file" "WARNING" \
    "skills/${reviewer} defines WARNING severity"
  assert_file_contains "$skill_file" "SUGGESTION" \
    "skills/${reviewer} defines SUGGESTION severity"
done

# ── Architecture review references all three reviewers ───────────────────────

begin_suite "Architecture Review Cross-References"

REVIEW_SKILL="${SKILLS_DIR}/architecture-review/SKILL.md"

assert_file_contains "$REVIEW_SKILL" "oo-design-review" \
  "architecture-review references oo-design-review"
assert_file_contains "$REVIEW_SKILL" "clean-architecture-review" \
  "architecture-review references clean-architecture-review"
assert_file_contains "$REVIEW_SKILL" "api-design-review" \
  "architecture-review references api-design-review"

# ── Architecture loop references architecture-review ─────────────────────────

begin_suite "Architecture Loop Cross-References"

LOOP_SKILL="${SKILLS_DIR}/architecture-loop/SKILL.md"

assert_file_contains "$LOOP_SKILL" "architecture-review" \
  "architecture-loop references architecture-review"
assert_file_contains "$LOOP_SKILL" "implementer-prompt" \
  "architecture-loop references implementer-prompt"
assert_file_contains "$LOOP_SKILL" "review-output-format" \
  "architecture-loop references review-output-format"
assert_file_contains "$LOOP_SKILL" "approval-criteria" \
  "architecture-loop references approval-criteria"
assert_file_contains "$LOOP_SKILL" "safety valve" \
  "architecture-loop documents safety valve"

# ── Skills with Integration sections have them at the end ────────────────────

begin_suite "Integration Section Placement"

for skill_dir in "${SKILLS_DIR}"/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="${skill_dir}SKILL.md"

  if grep -q "^## Integration" "$skill_file" 2>/dev/null; then
    # Get total line count and Integration section line number
    total_lines=$(wc -l < "$skill_file")
    integration_line=$(grep -n "^## Integration" "$skill_file" | tail -1 | cut -d: -f1)
    # Integration should be in the last 40% of the file
    threshold=$(( total_lines * 60 / 100 ))

    if [[ $integration_line -ge $threshold ]]; then
      pass "skills/${skill_name} Integration section near end (line ${integration_line}/${total_lines})"
    else
      fail "skills/${skill_name} Integration section near end" \
        "Integration at line ${integration_line} of ${total_lines} (should be in last 40%)"
    fi
  fi
done

# ── using-arxitect skill lists available skills ──────────────────────────────

begin_suite "Using Arxitect Skill"

USING="${SKILLS_DIR}/using-arxitect/SKILL.md"

assert_file_contains "$USING" "architecture-review" \
  "using-arxitect lists architecture-review"
assert_file_contains "$USING" "architecture-loop" \
  "using-arxitect lists architecture-loop"
assert_file_contains "$USING" "oo-design-review" \
  "using-arxitect lists oo-design-review"
assert_file_contains "$USING" "clean-architecture-review" \
  "using-arxitect lists clean-architecture-review"
assert_file_contains "$USING" "api-design-review" \
  "using-arxitect lists api-design-review"

print_summary
