#!/usr/bin/env bash
# Test: architecture-review skill behavioral verification
# Verifies that Claude understands the parallel review orchestration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
require_claude

echo "=== Test: architecture-review skill ==="
echo ""

# Test 1: Skill purpose
echo "Test 1: Skill recognition..."

output=$(run_claude "What does the arxitect:architecture-review skill do? Is it read-only or does it modify code?" 30)

assert_contains "$output" "review\|evaluate\|assess" "Describes review purpose" || exit 1
assert_contains "$output" "read.only\|not.*modify\|doesn't.*modify\|does not.*change" "Confirms read-only" || exit 1

echo ""

# Test 2: Three parallel reviewers
echo "Test 2: Parallel reviewer dispatch..."

output=$(run_claude "How does arxitect:architecture-review dispatch reviewers? Are they run sequentially or in parallel?" 30)

assert_contains "$output" "parallel\|concurrently\|simultaneous" "Reviewers run in parallel" || exit 1
assert_contains "$output" "three\|3" "All three reviewers dispatched" || exit 1

echo ""

# Test 3: Progressive disclosure — don't pre-load reference material
echo "Test 3: Progressive disclosure..."

output=$(run_claude "In arxitect:architecture-review, does the orchestrator pre-load the reviewer reference files and inject them into the agent prompt, or does each reviewer read its own material?" 30)

assert_contains "$output" "own\|itself\|reads.*its\|read.*its\|self" "Each reviewer reads its own material" || exit 1

echo ""

# Test 4: Combined report with overall verdict
echo "Test 4: Combined report..."

output=$(run_claude "What does arxitect:architecture-review produce as output? What determines the overall verdict?" 30)

assert_contains "$output" "combined\|unified\|merged\|single" "Produces combined report" || exit 1
assert_contains "$output" "approved.*all\|all.*approved" "APPROVED requires all three reviewers" || exit 1

echo ""

# Test 5: Finding structure is preserved
echo "Test 5: Finding structure preservation..."

output=$(run_claude "In arxitect:architecture-review, should the orchestrator summarize away finding details or preserve the structured format?" 30)

assert_contains "$output" "preserve\|structured\|detail\|not.*summarize" "Preserves structured findings" || exit 1

echo ""

# Test 6: Distinction from architect
echo "Test 6: Distinction from architect..."

output=$(run_claude "What is the difference between arxitect:architecture-review and arxitect:architect? When would you use each?" 30)

assert_contains "$output" "read.only\|review.*only\|without.*implement\|no.*implement" "Review is read-only" || exit 1
assert_contains "$output" "loop\|iterate\|feedback\|implement" "Loop includes implementation" || exit 1

echo ""

echo "=== All architecture-review skill tests passed ==="
