#!/usr/bin/env bash
# Run all skill triggering tests.
# Verifies that natural-language prompts auto-invoke the correct skills.

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

SKILLS=(
  "architecture-review"
  "architect"
  "oo-design-review"
  "clean-architecture-review"
  "api-design-review"
)

echo "=== Running Skill Triggering Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=()

for skill in "${SKILLS[@]}"; do
  prompt_file="$PROMPTS_DIR/${skill}.txt"

  if [[ ! -f "$prompt_file" ]]; then
    echo "  SKIP: No prompt file for $skill"
    continue
  fi

  echo "Testing: $skill"

  if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file" 5; then
    PASSED=$((PASSED + 1))
    RESULTS+=("PASS $skill")
  else
    FAILED=$((FAILED + 1))
    RESULTS+=("FAIL $skill")
  fi

  echo ""
  echo "---"
  echo ""
done

echo ""
echo "=== Summary ==="
for result in "${RESULTS[@]}"; do
  echo "  $result"
done
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
