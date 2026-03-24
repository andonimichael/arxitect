#!/usr/bin/env bash
# Shared test helpers for Arxitect test suite
# Inspired by https://github.com/obra/superpowers/blob/main/tests/claude-code/test-helpers.sh

set -euo pipefail

# ── Globals ──────────────────────────────────────────────────────────────────

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${TESTS_DIR}/.." && pwd)"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
FAILURES=()

# ── Colors ───────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN='' RED='' YELLOW='' BOLD='' RESET=''
fi

# ── Core Result Reporters ────────────────────────────────────────────────────

pass() {
  local name="$1"
  PASS_COUNT=$((PASS_COUNT + 1))
  echo -e "  ${GREEN}✓${RESET} ${name}"
}

fail() {
  local name="$1"
  local detail="${2:-}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  FAILURES+=("${name}")
  echo -e "  ${RED}✗${RESET} ${name}"
  if [[ -n "$detail" ]]; then
    echo -e "    ${RED}→ ${detail}${RESET}"
  fi
}

skip() {
  local name="$1"
  local reason="${2:-}"
  SKIP_COUNT=$((SKIP_COUNT + 1))
  echo -e "  ${YELLOW}⊘${RESET} ${name} (skipped${reason:+: $reason})"
}

# ══════════════════════════════════════════════════════════════════════════════
# Static / File Assertion Helpers
# ══════════════════════════════════════════════════════════════════════════════

assert_file_exists() {
  local file="$1"
  local label="${2:-File exists: ${file}}"
  if [[ -f "$file" ]]; then
    pass "$label"
  else
    fail "$label" "file not found: ${file}"
  fi
}

assert_file_not_empty() {
  local file="$1"
  local label="${2:-File not empty: ${file}}"
  if [[ -s "$file" ]]; then
    pass "$label"
  else
    fail "$label" "file is empty: ${file}"
  fi
}

assert_file_executable() {
  local file="$1"
  local label="${2:-File executable: ${file}}"
  if [[ -x "$file" ]]; then
    pass "$label"
  else
    fail "$label" "file not executable: ${file}"
  fi
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  local label="${3:-File contains pattern: ${pattern}}"
  if grep -qE "$pattern" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label" "pattern not found in ${file}"
  fi
}

assert_file_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="${3:-File does not contain: ${pattern}}"
  if ! grep -qE "$pattern" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label" "unexpected pattern found in ${file}"
  fi
}

assert_valid_json() {
  local file="$1"
  local label="${2:-Valid JSON: ${file}}"
  if command -v python3 &>/dev/null; then
    if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
      pass "$label"
    else
      fail "$label" "invalid JSON"
    fi
  elif command -v jq &>/dev/null; then
    if jq empty "$file" 2>/dev/null; then
      pass "$label"
    else
      fail "$label" "invalid JSON"
    fi
  else
    skip "$label" "no JSON validator available"
  fi
}

assert_json_field() {
  local file="$1"
  local field="$2"
  local label="${3:-JSON has field: ${field}}"
  if command -v python3 &>/dev/null; then
    if python3 -c "
import json, sys
data = json.load(open('$file'))
keys = '$field'.split('.')
for k in keys:
    data = data[k]
" 2>/dev/null; then
      pass "$label"
    else
      fail "$label" "field '${field}' not found"
    fi
  else
    skip "$label" "python3 not available"
  fi
}

assert_command_succeeds() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label" "command failed: $*"
  fi
}

assert_equals() {
  local expected="$1"
  local actual="$2"
  local label="${3:-Expected '${expected}', got '${actual}'}"
  if [[ "$expected" == "$actual" ]]; then
    pass "$label"
  else
    fail "$label" "expected '${expected}', got '${actual}'"
  fi
}

# ── YAML Frontmatter Helpers ────────────────────────────────────────────────

yaml_field() {
  local file="$1"
  local field="$2"
  sed -n '/^---$/,/^---$/p' "$file" \
    | grep -E "^${field}:" \
    | head -1 \
    | sed "s/^${field}:[[:space:]]*//"
}

assert_yaml_frontmatter() {
  local file="$1"
  local label="${2:-Has YAML frontmatter: ${file}}"
  if head -1 "$file" | grep -q '^---$'; then
    if sed -n '2,$ p' "$file" | grep -q '^---$'; then
      pass "$label"
    else
      fail "$label" "missing closing --- delimiter"
    fi
  else
    fail "$label" "missing opening --- delimiter"
  fi
}

assert_yaml_field() {
  local file="$1"
  local field="$2"
  local label="${3:-YAML field '${field}' exists in ${file}}"
  local value
  value=$(yaml_field "$file" "$field")
  if [[ -n "$value" ]]; then
    pass "$label"
  else
    fail "$label" "field '${field}' missing or empty"
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# Behavioral / Claude CLI Helpers
# ══════════════════════════════════════════════════════════════════════════════

# Run Claude Code in headless mode and capture output.
# Usage: run_claude "prompt text" [timeout_seconds] [allowed_tools]
run_claude() {
  local prompt="$1"
  local timeout_secs="${2:-60}"
  local allowed_tools="${3:-}"
  local output_file
  output_file=$(mktemp)

  local -a cmd=(claude -p "$prompt" --plugin-dir "$PROJECT_ROOT" --model haiku)
  if [[ -n "$allowed_tools" ]]; then
    cmd+=(--allowed-tools "$allowed_tools")
  fi

  if timeout "$timeout_secs" "${cmd[@]}" > "$output_file" 2>&1; then
    cat "$output_file"
    rm -f "$output_file"
    return 0
  else
    local exit_code=$?
    cat "$output_file" >&2
    rm -f "$output_file"
    return $exit_code
  fi
}

# Run Claude Code in headless mode with stream-json output for log analysis.
# Usage: run_claude_json "prompt" output_log_file [timeout] [max_turns]
run_claude_json() {
  local prompt="$1"
  local log_file="$2"
  local timeout_secs="${3:-300}"
  local max_turns="${4:-3}"

  timeout "$timeout_secs" claude -p "$prompt" \
    --plugin-dir "$PROJECT_ROOT" \
    --model haiku \
    --max-turns "$max_turns" \
    --output-format stream-json \
    --verbose \
    > "$log_file" 2>&1 || true
}

# Check if Claude's output contains a pattern.
# Usage: assert_contains "$output" "pattern" "test name"
assert_contains() {
  local output="$1"
  local pattern="$2"
  local test_name="${3:-test}"

  if echo "$output" | grep -qi "$pattern"; then
    pass "$test_name"
    return 0
  else
    fail "$test_name" "expected to find: $pattern"
    return 1
  fi
}

# Check that Claude's output does NOT contain a pattern.
# Usage: assert_not_contains "$output" "pattern" "test name"
assert_not_contains() {
  local output="$1"
  local pattern="$2"
  local test_name="${3:-test}"

  if echo "$output" | grep -qi "$pattern"; then
    fail "$test_name" "did not expect to find: $pattern"
    return 1
  else
    pass "$test_name"
    return 0
  fi
}

# Check that pattern A appears before pattern B in output.
# Usage: assert_order "$output" "pattern_a" "pattern_b" "test name"
assert_order() {
  local output="$1"
  local pattern_a="$2"
  local pattern_b="$3"
  local test_name="${4:-test}"

  local line_a line_b
  line_a=$(echo "$output" | grep -ni "$pattern_a" | head -1 | cut -d: -f1)
  line_b=$(echo "$output" | grep -ni "$pattern_b" | head -1 | cut -d: -f1)

  if [[ -z "$line_a" ]]; then
    fail "$test_name" "pattern A not found: $pattern_a"
    return 1
  fi
  if [[ -z "$line_b" ]]; then
    fail "$test_name" "pattern B not found: $pattern_b"
    return 1
  fi
  if [[ "$line_a" -lt "$line_b" ]]; then
    pass "$test_name"
    return 0
  else
    fail "$test_name" "'$pattern_a' (line $line_a) should come before '$pattern_b' (line $line_b)"
    return 1
  fi
}

# Check that a pattern appears exactly N times.
# Usage: assert_count "$output" "pattern" expected_count "test name"
assert_count() {
  local output="$1"
  local pattern="$2"
  local expected="$3"
  local test_name="${4:-test}"

  local actual
  actual=$(echo "$output" | grep -ci "$pattern" || echo "0")

  if [[ "$actual" -eq "$expected" ]]; then
    pass "$test_name (found $actual)"
    return 0
  else
    fail "$test_name" "expected $expected instances of '$pattern', found $actual"
    return 1
  fi
}

# Check whether a specific skill was invoked in a stream-json log.
# Usage: assert_skill_triggered log_file "skill-name" "test name"
assert_skill_triggered() {
  local log_file="$1"
  local skill_name="$2"
  local test_name="${3:-Skill '$skill_name' was triggered}"

  local skill_pattern="\"skill\":\"([^\"]*:)?${skill_name}\""
  if grep -q '"name":"Skill"' "$log_file" && grep -qE "$skill_pattern" "$log_file"; then
    pass "$test_name"
    return 0
  else
    fail "$test_name"
    # Show what skills were actually triggered for debugging
    local triggered
    triggered=$(grep -o '"skill":"[^"]*"' "$log_file" 2>/dev/null | sort -u || true)
    if [[ -n "$triggered" ]]; then
      echo "    Skills triggered: $triggered"
    else
      echo "    No skills were triggered"
    fi
    return 1
  fi
}

# Check that no non-system tools were invoked before the Skill tool.
# Catches the failure mode where Claude starts working before loading the skill.
# Usage: assert_no_premature_actions log_file "test name"
assert_no_premature_actions() {
  local log_file="$1"
  local test_name="${2:-No premature tool invocations before Skill}"

  local first_skill_line
  first_skill_line=$(grep -n '"name":"Skill"' "$log_file" | head -1 | cut -d: -f1)

  if [[ -z "$first_skill_line" ]]; then
    fail "$test_name" "no Skill invocation found at all"
    return 1
  fi

  local premature
  premature=$(head -n "$first_skill_line" "$log_file" | \
    grep '"type":"tool_use"' | \
    grep -v '"name":"Skill"' | \
    grep -v '"name":"TodoWrite"' || true)

  if [[ -n "$premature" ]]; then
    fail "$test_name" "tools invoked before Skill tool was loaded"
    return 1
  else
    pass "$test_name"
    return 0
  fi
}

# ── Suite Management ─────────────────────────────────────────────────────────

begin_suite() {
  local name="$1"
  echo ""
  echo -e "${BOLD}${name}${RESET}"
}

print_summary() {
  local total=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
  echo ""
  echo -e "${BOLD}Results${RESET}"
  echo -e "  ${GREEN}${PASS_COUNT} passed${RESET}, ${RED}${FAIL_COUNT} failed${RESET}, ${YELLOW}${SKIP_COUNT} skipped${RESET} (${total} total)"

  if [[ ${#FAILURES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Failures:${RESET}"
    for f in "${FAILURES[@]}"; do
      echo -e "  ${RED}✗${RESET} ${f}"
    done
  fi

  echo ""
  if [[ $FAIL_COUNT -gt 0 ]]; then
    return 1
  fi
  return 0
}

# ── Requirement Checks ──────────────────────────────────────────────────────

require_claude() {
  if ! command -v claude &>/dev/null; then
    echo "ERROR: Claude Code CLI not found. Install: https://code.claude.com"
    echo "Skipping behavioral tests."
    exit 0
  fi

  # Pre-flight: verify the API is reachable with a trivial prompt.
  # Catches rate limits before burning time on real tests.
  local preflight_out
  preflight_out=$(timeout 30 claude -p "Reply with only the word OK." --model haiku 2>&1) || true
  if [[ -z "$preflight_out" ]]; then
    echo "ERROR: claude -p returned empty output (likely rate-limited)."
    echo "Wait for your rate limit to reset and try again."
    exit 1
  fi
}
