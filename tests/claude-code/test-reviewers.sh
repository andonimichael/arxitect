#!/usr/bin/env bash
# Test: Individual reviewer skill behavioral verification
# Verifies that Claude understands each reviewer's domain and rules
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
require_claude

echo "=== Test: Individual reviewer skills ==="
echo ""

# ── OO Design Review ────────────────────────────────────────────────────────

echo "Test 1: OO Design — SOLID principles..."

output=$(run_claude "What principles does the arxitect:oo-design-review skill evaluate? List them." 30)

assert_contains "$output" "SOLID\|single.responsibility\|SRP" "Mentions SOLID/SRP" || exit 1
assert_contains "$output" "DRY\|don't repeat\|duplication" "Mentions DRY" || exit 1

echo ""

echo "Test 2: OO Design — pragmatism over pattern maximalism..."

output=$(run_claude "In arxitect:oo-design-review, should a reviewer demand a Strategy pattern for a three-line function? What is the skill's stance on over-engineering?" 30)

assert_contains "$output" "no\|not\|over.engineer\|pragmat" "Advises against over-engineering" || exit 1

echo ""

echo "Test 3: OO Design — composition vs inheritance..."

output=$(run_claude "What does arxitect:oo-design-review check regarding inheritance? When should inheritance be flagged?" 30)

assert_contains "$output" "composition\|is-a\|code.reuse\|deep.hierarch" "Evaluates composition vs inheritance" || exit 1

echo ""

# ── Clean Architecture Review ────────────────────────────────────────────────

echo "Test 4: Clean Architecture — cohesion principles..."

output=$(run_claude "What component cohesion principles does arxitect:clean-architecture-review evaluate? Name them." 30)

assert_contains "$output" "REP\|CRP\|CCP\|cohesion" "Mentions cohesion principles" || exit 1

echo ""

echo "Test 5: Clean Architecture — coupling principles..."

output=$(run_claude "What component coupling principles does arxitect:clean-architecture-review evaluate?" 30)

assert_contains "$output" "ADP\|SDP\|SAP\|coupling" "Mentions coupling principles" || exit 1

echo ""

echo "Test 6: Clean Architecture — dependency cycles..."

output=$(run_claude "In arxitect:clean-architecture-review, what severity level is a dependency cycle?" 30)

assert_contains "$output" "critical" "Dependency cycles are CRITICAL" || exit 1

echo ""

echo "Test 7: Clean Architecture — pragmatism..."

output=$(run_claude "According to arxitect:clean-architecture-review, does a two-file script need dependency inversion layers?" 30)

assert_contains "$output" "no\|not\|doesn't\|overkill\|unnecessary" "No over-architecture for simple scripts" || exit 1

echo ""

# ── API Design Review ────────────────────────────────────────────────────────

echo "Test 8: API Design — what gets reviewed..."

output=$(run_claude "What public surfaces does arxitect:api-design-review evaluate? List the types of interfaces it checks." 30)

assert_contains "$output" "method\|function\|signature" "Checks method signatures" || exit 1
assert_contains "$output" "naming\|name" "Checks naming" || exit 1
assert_contains "$output" "REST\|endpoint" "Checks REST endpoints" || exit 1

echo ""

echo "Test 9: API Design — developer perspective..."

output=$(run_claude "In arxitect:api-design-review, from whose perspective should API names be evaluated?" 30)

assert_contains "$output" "developer\|consumer\|first.time\|user" "Evaluates from consumer perspective" || exit 1

echo ""

echo "Test 10: API Design — finding ID prefix..."

output=$(run_claude "What prefix do arxitect:api-design-review findings use for their IDs?" 30)

assert_contains "$output" "API-" "Uses API- prefix" || exit 1

echo ""

echo "=== All reviewer skill tests passed ==="
