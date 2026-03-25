#!/usr/bin/env bash
# Test: architect skill behavioral verification
# Verifies that Claude has internalized the architect skill's rules
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
require_claude

echo "=== Test: architect skill ==="
echo ""

# Test 1: Skill recognition and purpose
echo "Test 1: Skill recognition..."

output=$(run_claude "What is the arxitect:architect skill? Describe its purpose and key phases briefly." 30)

assert_contains "$output" "implement" "Mentions implementation phase" || exit 1
assert_contains "$output" "review" "Mentions review phase" || exit 1

echo ""

# Test 2: Three reviewers are dispatched
echo "Test 2: Reviewer dispatch..."

output=$(run_claude "In the arxitect:architect skill, which reviewers are used during the review phase? Name all of them." 30)

assert_contains "$output" "object.oriented\|oo.design\|OO" "Mentions OO Design reviewer" || exit 1
assert_contains "$output" "clean.architecture" "Mentions Clean Architecture reviewer" || exit 1
assert_contains "$output" "api.design" "Mentions API Design reviewer" || exit 1

echo ""

# Test 3: Safety valve exists at 3 iterations
echo "Test 3: Safety valve..."

output=$(run_claude "In arxitect:architect, how many iterations does the feedback loop run before stopping? What happens when it reaches that limit?" 30)

assert_contains "$output" "3\|three" "Safety valve at 3 iterations" || exit 1
assert_contains "$output" "critical\|user\|stop\|present" "Describes what happens at the limit" || exit 1

echo ""

# Test 4: Review is never skipped
echo "Test 4: Review is mandatory..."

output=$(run_claude "In arxitect:architect, is it ever okay to skip the architecture review step after implementation? Even if the code looks good?" 30)

assert_contains "$output" "never\|no\|always\|must\|not.*skip" "Review must never be skipped" || exit 1

echo ""

# Test 5: Implementation strategies and fallback order
echo "Test 5: Implementation strategy order..."

output=$(run_claude "In the arxitect:architect skill, what are the implementation strategies and in what order are they checked?" 30)

assert_contains "$output" "superpowers\|Superpowers" "Mentions Superpowers as preferred strategy" || exit 1
assert_contains "$output" "fallback\|direct\|native" "Mentions fallback strategy" || exit 1

echo ""

# Test 6: Finding IDs tracked across iterations
echo "Test 6: Finding ID tracking..."

output=$(run_claude "In arxitect:architect, how are review findings tracked across iterations? What happens if a fixed finding reappears?" 30)

assert_contains "$output" "ID\|finding.*id\|track" "Finding IDs are tracked" || exit 1
assert_contains "$output" "regress" "Regressions are handled" || exit 1

echo ""

# Test 7: Severity escalation for regressions
echo "Test 7: Regression escalation..."

output=$(run_claude "In arxitect:architect, if a finding was fixed in iteration 1 but reappears in iteration 2, what happens to its severity?" 30)

assert_contains "$output" "critical\|escalat" "Regressions escalate to CRITICAL" || exit 1

echo ""

# Test 8: Implementer reads its own prompt
echo "Test 8: Implementer prompt..."

output=$(run_claude "In arxitect:architect, does the implementer agent receive design guidelines? Where are they defined?" 30)

assert_contains "$output" "implementer-prompt" "References implementer-prompt.md" || exit 1

echo ""

# Test 9: Read-only reviewers
echo "Test 9: Read-only review..."

output=$(run_claude "In the architect skill, can the architecture reviewers modify files during review?" 30)

assert_contains "$output" "no\|read.only\|not\|never\|cannot" "Reviewers are read-only" || exit 1

echo ""

echo "=== All architect skill tests passed ==="
