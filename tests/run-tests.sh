#!/usr/bin/env bash
# Run Arxitect test suites.
#
# Usage:
#   ./run-tests.sh                    # Run static tests only (fast, no claude needed)
#   ./run-tests.sh --behavioral       # Run behavioral tests (requires claude CLI)
#   ./run-tests.sh --all              # Run everything
#   ./run-tests.sh --test NAME        # Run a single static test suite
#   ./run-tests.sh --triggering       # Run skill-triggering tests
#   ./run-tests.sh --explicit         # Run explicit skill request tests

set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Parse arguments ──────────────────────────────────────────────────────────

RUN_STATIC=true
RUN_BEHAVIORAL=false
RUN_TRIGGERING=false
RUN_EXPLICIT=false
SINGLE_TEST=""
VERBOSE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --behavioral)   RUN_BEHAVIORAL=true; shift ;;
    --triggering)   RUN_TRIGGERING=true; shift ;;
    --explicit)     RUN_EXPLICIT=true; shift ;;
    --all)          RUN_BEHAVIORAL=true; RUN_TRIGGERING=true; RUN_EXPLICIT=true; shift ;;
    --test)         SINGLE_TEST="$2"; shift 2 ;;
    --verbose)      VERBOSE="--verbose"; shift ;;
    *)              echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Colors ───────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  BOLD='\033[1m' GREEN='\033[0;32m' RED='\033[0;31m' YELLOW='\033[0;33m' RESET='\033[0m'
else
  BOLD='' GREEN='' RED='' YELLOW='' RESET=''
fi

SUITE_PASS=0
SUITE_FAIL=0
SUITE_SKIP=0
FAILED_SUITES=()

# ══════════════════════════════════════════════════════════════════════════════
# Static Tests (fast, no claude CLI required)
# ══════════════════════════════════════════════════════════════════════════════

if $RUN_STATIC; then
  echo -e "${BOLD}Arxitect Test Suite — Static Validation${RESET}"
  echo "═══════════════════════════════════════════════════════"

  STATIC_SUITES=(
    "test-skill-structure"
    "test-hooks"
    "test-plugin-manifests"
    "test-skill-content"
    "test-docs"
  )

  for suite in "${STATIC_SUITES[@]}"; do
    if [[ -n "$SINGLE_TEST" && "$suite" != "test-${SINGLE_TEST}" && "$suite" != "$SINGLE_TEST" ]]; then
      continue
    fi

    script="${TESTS_DIR}/static/${suite}.sh"
    if [[ ! -f "$script" ]]; then
      echo -e "${RED}Suite not found: ${suite}${RESET}"
      SUITE_FAIL=$((SUITE_FAIL + 1))
      FAILED_SUITES+=("static/$suite")
      continue
    fi

    if bash "$script"; then
      SUITE_PASS=$((SUITE_PASS + 1))
    else
      SUITE_FAIL=$((SUITE_FAIL + 1))
      FAILED_SUITES+=("static/$suite")
    fi
  done

  echo "═══════════════════════════════════════════════════════"
  echo ""
fi

# ══════════════════════════════════════════════════════════════════════════════
# Behavioral Tests (require claude CLI)
# ══════════════════════════════════════════════════════════════════════════════

if $RUN_BEHAVIORAL; then
  if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}Skipping behavioral tests: claude CLI not found${RESET}"
    SUITE_SKIP=$((SUITE_SKIP + 1))
  else
    echo -e "${BOLD}Arxitect Test Suite — Behavioral (Claude Code)${RESET}"
    echo "═══════════════════════════════════════════════════════"

    if bash "${TESTS_DIR}/claude-code/run-skill-tests.sh" $VERBOSE; then
      SUITE_PASS=$((SUITE_PASS + 1))
    else
      SUITE_FAIL=$((SUITE_FAIL + 1))
      FAILED_SUITES+=("claude-code/behavioral")
    fi

    echo "═══════════════════════════════════════════════════════"
    echo ""
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# Skill Triggering Tests (require claude CLI)
# ══════════════════════════════════════════════════════════════════════════════

if $RUN_TRIGGERING; then
  if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}Skipping skill-triggering tests: claude CLI not found${RESET}"
    SUITE_SKIP=$((SUITE_SKIP + 1))
  else
    echo -e "${BOLD}Arxitect Test Suite — Skill Triggering${RESET}"
    echo "═══════════════════════════════════════════════════════"

    chmod +x "${TESTS_DIR}/skill-triggering/"*.sh
    if bash "${TESTS_DIR}/skill-triggering/run-all.sh"; then
      SUITE_PASS=$((SUITE_PASS + 1))
    else
      SUITE_FAIL=$((SUITE_FAIL + 1))
      FAILED_SUITES+=("skill-triggering")
    fi

    echo "═══════════════════════════════════════════════════════"
    echo ""
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# Explicit Skill Request Tests (require claude CLI)
# ══════════════════════════════════════════════════════════════════════════════

if $RUN_EXPLICIT; then
  if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}Skipping explicit-skill-request tests: claude CLI not found${RESET}"
    SUITE_SKIP=$((SUITE_SKIP + 1))
  else
    echo -e "${BOLD}Arxitect Test Suite — Explicit Skill Requests${RESET}"
    echo "═══════════════════════════════════════════════════════"

    chmod +x "${TESTS_DIR}/explicit-skill-requests/"*.sh
    if bash "${TESTS_DIR}/explicit-skill-requests/run-all.sh"; then
      SUITE_PASS=$((SUITE_PASS + 1))
    else
      SUITE_FAIL=$((SUITE_FAIL + 1))
      FAILED_SUITES+=("explicit-skill-requests")
    fi

    echo "═══════════════════════════════════════════════════════"
    echo ""
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# Final Summary
# ══════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}Final Summary${RESET}"
echo -e "  Suites: ${GREEN}${SUITE_PASS} passed${RESET}, ${RED}${SUITE_FAIL} failed${RESET}, ${YELLOW}${SUITE_SKIP} skipped${RESET}"

if [[ ${#FAILED_SUITES[@]} -gt 0 ]]; then
  echo ""
  echo -e "${RED}Failed suites:${RESET}"
  for s in "${FAILED_SUITES[@]}"; do
    echo -e "  ${RED}✗${RESET} ${s}"
  done
fi

# Hint about behavioral tests if they weren't run
if ! $RUN_BEHAVIORAL && ! $RUN_TRIGGERING && ! $RUN_EXPLICIT; then
  echo ""
  echo "Note: Only static tests were run. Use flags for behavioral tests:"
  echo "  --behavioral   Skill understanding tests (requires claude CLI)"
  echo "  --triggering   Auto-invocation from natural prompts"
  echo "  --explicit     Explicit skill request invocation"
  echo "  --all          Run everything"
fi

echo ""
if [[ $SUITE_FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
