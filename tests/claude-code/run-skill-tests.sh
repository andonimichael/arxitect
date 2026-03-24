#!/usr/bin/env bash
# Test runner for Claude Code behavioral skill tests.
# Invokes Claude in headless mode and verifies it has internalized skill rules.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " Arxitect Behavioral Skill Tests"
echo "========================================"
echo ""
echo "Repository: $(cd "$SCRIPT_DIR/../.." && pwd)"
echo "Test time:  $(date)"
echo "Claude:     $(claude --version 2>/dev/null || echo 'not found')"
echo ""

if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code CLI not found"
  echo "Install Claude Code first: https://code.claude.com"
  exit 1
fi

# ── Parse arguments ──────────────────────────────────────────────────────────

VERBOSE=false
SPECIFIC_TEST=""
TIMEOUT=600

while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v)   VERBOSE=true; shift ;;
    --test|-t)      SPECIFIC_TEST="$2"; shift 2 ;;
    --timeout)      TIMEOUT="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --verbose, -v        Show full output"
      echo "  --test, -t NAME      Run only the specified test"
      echo "  --timeout SECONDS    Set timeout per test (default: 300)"
      echo "  --help, -h           Show this help"
      echo ""
      echo "Tests:"
      echo "  test-architecture-loop.sh      Architecture loop skill"
      echo "  test-architecture-review.sh    Architecture review skill"
      echo "  test-reviewers.sh              Individual reviewer skills"
      echo "  test-using-arxitect.sh         Bootstrap skill"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Discover tests ───────────────────────────────────────────────────────────

tests=(
  "test-using-arxitect.sh"
  "test-architecture-loop.sh"
  "test-architecture-review.sh"
  "test-reviewers.sh"
)

if [[ -n "$SPECIFIC_TEST" ]]; then
  tests=("$SPECIFIC_TEST")
fi

# ── Run tests ────────────────────────────────────────────────────────────────

passed=0
failed=0

for test in "${tests[@]}"; do
  echo "────────────────────────────────────────"
  echo "Running: $test"
  echo "────────────────────────────────────────"

  test_path="$SCRIPT_DIR/$test"

  if [[ ! -f "$test_path" ]]; then
    echo "  [SKIP] Test file not found: $test"
    continue
  fi

  chmod +x "$test_path" 2>/dev/null || true

  start_time=$(date +%s)

  if $VERBOSE; then
    if timeout "$TIMEOUT" bash "$test_path"; then
      end_time=$(date +%s)
      echo "  [PASS] $test ($((end_time - start_time))s)"
      passed=$((passed + 1))
    else
      end_time=$(date +%s)
      echo "  [FAIL] $test ($((end_time - start_time))s)"
      failed=$((failed + 1))
    fi
  else
    if output=$(timeout "$TIMEOUT" bash "$test_path" 2>&1); then
      end_time=$(date +%s)
      echo "$output"
      echo "  [PASS] ($((end_time - start_time))s)"
      passed=$((passed + 1))
    else
      exit_code=$?
      end_time=$(date +%s)
      echo "$output"
      if [[ $exit_code -eq 124 ]]; then
        echo "  [FAIL] (timeout after ${TIMEOUT}s)"
      else
        echo "  [FAIL] ($((end_time - start_time))s)"
      fi
      failed=$((failed + 1))
    fi
  fi

  echo ""
done

# ── Summary ──────────────────────────────────────────────────────────────────

echo "========================================"
echo " Behavioral Test Results"
echo "========================================"
echo "  Passed:  $passed"
echo "  Failed:  $failed"
echo ""

if [[ $failed -gt 0 ]]; then
  echo "STATUS: FAILED"
  exit 1
else
  echo "STATUS: PASSED"
  exit 0
fi
