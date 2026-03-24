#!/usr/bin/env bash
# Validates hook scripts and configuration.

set -euo pipefail
. "$(dirname "$0")/../test-helpers.sh"

HOOKS_DIR="${PROJECT_ROOT}/hooks"

# ── Hook files exist and are executable ──────────────────────────────────────

begin_suite "Hook Files"

assert_file_exists "${HOOKS_DIR}/session-start" "hooks/session-start exists"
assert_file_executable "${HOOKS_DIR}/session-start" "hooks/session-start is executable"
assert_file_exists "${HOOKS_DIR}/run-hook.cmd" "hooks/run-hook.cmd exists"
assert_file_exists "${HOOKS_DIR}/hooks.json" "hooks/hooks.json exists"
assert_file_exists "${HOOKS_DIR}/hooks-cursor.json" "hooks/hooks-cursor.json exists"

# ── Hook configs are valid JSON with required structure ──────────────────────

begin_suite "Hook Configuration"

assert_valid_json "${HOOKS_DIR}/hooks.json" "hooks/hooks.json is valid JSON"
assert_json_field "${HOOKS_DIR}/hooks.json" "hooks" \
  "hooks/hooks.json has 'hooks' field"
assert_json_field "${HOOKS_DIR}/hooks.json" "hooks.SessionStart" \
  "hooks/hooks.json has SessionStart hook"

assert_valid_json "${HOOKS_DIR}/hooks-cursor.json" "hooks/hooks-cursor.json is valid JSON"
assert_json_field "${HOOKS_DIR}/hooks-cursor.json" "hooks" \
  "hooks/hooks-cursor.json has 'hooks' field"

# ── session-start script produces valid JSON ─────────────────────────────────

begin_suite "Session Start Output"

# Test Claude Code output (CLAUDE_PLUGIN_ROOT set)
claude_output=$(CLAUDE_PLUGIN_ROOT="${PROJECT_ROOT}" bash "${HOOKS_DIR}/session-start" 2>&1) || true

if echo "$claude_output" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass "session-start produces valid JSON (Claude Code)"
else
  fail "session-start produces valid JSON (Claude Code)" "invalid JSON output"
fi

# Verify the output contains hookSpecificOutput for Claude Code
if echo "$claude_output" | grep -q "hookSpecificOutput"; then
  pass "Claude Code output contains hookSpecificOutput"
else
  fail "Claude Code output contains hookSpecificOutput"
fi

# Test Cursor output (CURSOR_PLUGIN_ROOT set)
cursor_output=$(CURSOR_PLUGIN_ROOT="${PROJECT_ROOT}" bash "${HOOKS_DIR}/session-start" 2>&1) || true

if echo "$cursor_output" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass "session-start produces valid JSON (Cursor)"
else
  fail "session-start produces valid JSON (Cursor)" "invalid JSON output"
fi

if echo "$cursor_output" | grep -q "additional_context"; then
  pass "Cursor output contains additional_context"
else
  fail "Cursor output contains additional_context"
fi

# Test fallback output (no platform env vars)
fallback_output=$(unset CLAUDE_PLUGIN_ROOT CURSOR_PLUGIN_ROOT; bash "${HOOKS_DIR}/session-start" 2>&1) || true

if echo "$fallback_output" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass "session-start produces valid JSON (fallback)"
else
  fail "session-start produces valid JSON (fallback)" "invalid JSON output"
fi

# ── session-start script includes using-arxitect content ─────────────────────

begin_suite "Session Start Content"

if echo "$claude_output" | grep -q "using-arxitect"; then
  pass "Output references using-arxitect skill"
else
  fail "Output references using-arxitect skill"
fi

if echo "$claude_output" | grep -q "architecture"; then
  pass "Output contains architecture context"
else
  fail "Output contains architecture context"
fi

print_summary
