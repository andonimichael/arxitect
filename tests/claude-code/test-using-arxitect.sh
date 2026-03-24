#!/usr/bin/env bash
# Test: using-arxitect bootstrap skill behavioral verification
# Verifies that Claude understands when to invoke skills and doesn't skip them
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
require_claude

echo "=== Test: using-arxitect skill ==="
echo ""

# Test 1: Knows when architecture-loop is mandatory
echo "Test 1: When to use architecture-loop..."

output=$(run_claude "According to arxitect:using-arxitect, when MUST you use the architecture-loop skill? List the conditions." 30)

assert_contains "$output" "new feature\|new module\|implement" "New features require the loop" || exit 1
assert_contains "$output" "refactor" "Refactoring requires the loop" || exit 1
assert_contains "$output" "class\|interface\|abstraction" "New abstractions require the loop" || exit 1

echo ""

# Test 2: Distinction between loop and review
echo "Test 2: Loop vs review decision..."

output=$(run_claude "According to arxitect:using-arxitect, when should you use architecture-review instead of architecture-loop?" 30)

assert_contains "$output" "existing\|without.*chang\|read.only\|review.*only\|no.*implement" "Review for existing code" || exit 1

echo ""

# Test 3: Must not skip skills
echo "Test 3: Do not skip skills..."

output=$(run_claude "According to arxitect:using-arxitect, is it ever okay to skip loading a skill and replicate its behavior from memory?" 30)

assert_contains "$output" "no\|never\|must\|not.*skip\|always.*load" "Must not skip skills" || exit 1

echo ""

# Test 4: Lists all available skills
echo "Test 4: Available skills listing..."

output=$(run_claude "What skills are available through Arxitect? List them all." 30)

assert_contains "$output" "architecture-loop" "Lists architecture-loop" || exit 1
assert_contains "$output" "architecture-review" "Lists architecture-review" || exit 1
assert_contains "$output" "oo-design-review" "Lists oo-design-review" || exit 1
assert_contains "$output" "clean-architecture-review" "Lists clean-architecture-review" || exit 1
assert_contains "$output" "api-design-review" "Lists api-design-review" || exit 1

echo ""

# Test 5: Knows the four agents
echo "Test 5: Four collaborating agents..."

output=$(run_claude "According to arxitect:using-arxitect, how many agents collaborate and what are their roles?" 30)

assert_contains "$output" "four\|4" "Four agents" || exit 1
assert_contains "$output" "implement" "Mentions implementer" || exit 1
assert_contains "$output" "object.oriented\|OO" "Mentions OO reviewer" || exit 1
assert_contains "$output" "clean.architecture" "Mentions Clean Architecture reviewer" || exit 1
assert_contains "$output" "api.design\|API" "Mentions API reviewer" || exit 1

echo ""

echo "=== All using-arxitect skill tests passed ==="
