#!/usr/bin/env bash
# Validates documentation files exist and contain expected content.

set -euo pipefail
. "$(dirname "$0")/../test-helpers.sh"

# ── Required documentation files ────────────────────────────────────────────

begin_suite "Documentation Files"

assert_file_exists "${PROJECT_ROOT}/README.md" "README.md exists"
assert_file_not_empty "${PROJECT_ROOT}/README.md" "README.md not empty"
assert_file_exists "${PROJECT_ROOT}/CLAUDE.md" "CLAUDE.md exists"
assert_file_not_empty "${PROJECT_ROOT}/CLAUDE.md" "CLAUDE.md not empty"
assert_file_exists "${PROJECT_ROOT}/LICENSE" "LICENSE exists"
assert_file_exists "${PROJECT_ROOT}/CODE_OF_CONDUCT.md" "CODE_OF_CONDUCT.md exists"

# ── README documents all skills ─────────────────────────────────────────────

begin_suite "README Skill Coverage"

README="${PROJECT_ROOT}/README.md"

assert_file_contains "$README" "architecture-review" "README documents architecture-review"
assert_file_contains "$README" "architecture-loop" "README documents architecture-loop"
assert_file_contains "$README" "oo-design-review" "README documents oo-design-review"
assert_file_contains "$README" "clean-architecture-review" "README documents clean-architecture-review"
assert_file_contains "$README" "api-design-review" "README documents api-design-review"
assert_file_contains "$README" "using-arxitect" "README documents using-arxitect"

# ── README documents installation for all platforms ──────────────────────────

begin_suite "README Installation Coverage"

assert_file_contains "$README" "Claude Code" "README has Claude Code installation"
assert_file_contains "$README" "Cursor" "README has Cursor installation"
assert_file_contains "$README" "Codex" "README has Codex installation"
assert_file_contains "$README" "Gemini" "README has Gemini installation"

# ── CLAUDE.md has development guidelines ─────────────────────────────────────

begin_suite "CLAUDE.md Content"

CLAUDE="${PROJECT_ROOT}/CLAUDE.md"

assert_file_contains "$CLAUDE" "SKILL.md" "CLAUDE.md references SKILL.md convention"
assert_file_contains "$CLAUDE" "skills/" "CLAUDE.md references skills directory"
assert_file_contains "$CLAUDE" "hooks/" "CLAUDE.md references hooks directory"

print_summary
