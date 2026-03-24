#!/usr/bin/env bash
# Run all explicit skill request tests.
# Verifies that naming a skill by name triggers it without premature actions.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code CLI not found. Install: https://code.claude.com"
  exit 0
fi

# Pre-flight: verify the API is reachable
echo "Pre-flight check..."
PREFLIGHT=$(timeout 30 claude -p "Reply with only the word OK." --model haiku 2>&1) || true
if [[ -z "$PREFLIGHT" ]]; then
  echo "ERROR: claude -p returned empty output (likely rate-limited)."
  echo "Wait for your rate limit to reset and try again."
  exit 1
fi
echo "Pre-flight passed."
echo ""

echo "=== Running Explicit Skill Request Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=()

run_one() {
  local skill="$1"
  local prompt_file="$2"
  local label="${3:-$skill}"

  echo ">>> Test: $label"

  if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file"; then
    PASSED=$((PASSED + 1))
    RESULTS+=("PASS $label")
  else
    FAILED=$((FAILED + 1))
    RESULTS+=("FAIL $label")
  fi

  echo ""
}

run_one "architecture-loop" "$PROMPTS_DIR/use-architecture-loop.txt" \
  "use-architecture-loop"

run_one "architecture-review" "$PROMPTS_DIR/run-architecture-review.txt" \
  "run-architecture-review"

run_one "oo-design-review" "$PROMPTS_DIR/oo-review-please.txt" \
  "oo-review-please"

run_one "clean-architecture-review" "$PROMPTS_DIR/clean-arch-review.txt" \
  "clean-arch-review"

run_one "api-design-review" "$PROMPTS_DIR/api-design-check.txt" \
  "api-design-check"

echo "=== Summary ==="
for result in "${RESULTS[@]}"; do
  echo "  $result"
done
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $((PASSED + FAILED))"

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
