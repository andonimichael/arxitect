#!/usr/bin/env bash
# Validates plugin manifests and package configuration.

set -euo pipefail
. "$(dirname "$0")/../test-helpers.sh"

# ── Plugin manifests are valid JSON with required fields ─────────────────────

begin_suite "Claude Code Plugin Manifest"

CLAUDE_MANIFEST="${PROJECT_ROOT}/.claude-plugin/plugin.json"

assert_file_exists "$CLAUDE_MANIFEST" ".claude-plugin/plugin.json exists"
assert_valid_json "$CLAUDE_MANIFEST" ".claude-plugin/plugin.json is valid JSON"
assert_json_field "$CLAUDE_MANIFEST" "name" "plugin.json has 'name'"
assert_json_field "$CLAUDE_MANIFEST" "version" "plugin.json has 'version'"
assert_json_field "$CLAUDE_MANIFEST" "description" "plugin.json has 'description'"

begin_suite "Claude Marketplace Manifest"

MARKETPLACE="${PROJECT_ROOT}/.claude-plugin/marketplace.json"

assert_file_exists "$MARKETPLACE" ".claude-plugin/marketplace.json exists"
assert_valid_json "$MARKETPLACE" ".claude-plugin/marketplace.json is valid JSON"
assert_json_field "$MARKETPLACE" "name" "marketplace.json has 'name'"
assert_json_field "$MARKETPLACE" "plugins" "marketplace.json has 'plugins'"

begin_suite "Cursor Plugin Manifest"

CURSOR_MANIFEST="${PROJECT_ROOT}/.cursor-plugin/plugin.json"

assert_file_exists "$CURSOR_MANIFEST" ".cursor-plugin/plugin.json exists"
assert_valid_json "$CURSOR_MANIFEST" ".cursor-plugin/plugin.json is valid JSON"

begin_suite "Package Configuration"

PKG="${PROJECT_ROOT}/package.json"

assert_file_exists "$PKG" "package.json exists"
assert_valid_json "$PKG" "package.json is valid JSON"
assert_json_field "$PKG" "name" "package.json has 'name'"
assert_json_field "$PKG" "version" "package.json has 'version'"

# ── Version consistency across manifests ─────────────────────────────────────

begin_suite "Version Consistency"

if command -v python3 &>/dev/null; then
  pkg_version=$(python3 -c "import json; print(json.load(open('${PKG}'))['version'])")
  plugin_version=$(python3 -c "import json; print(json.load(open('${CLAUDE_MANIFEST}'))['version'])")
  marketplace_version=$(python3 -c "import json; print(json.load(open('${MARKETPLACE}'))['plugins'][0]['version'])")

  assert_equals "$pkg_version" "$plugin_version" \
    "package.json and plugin.json versions match"
  assert_equals "$pkg_version" "$marketplace_version" \
    "package.json and marketplace.json versions match"
else
  skip "Version consistency" "python3 not available"
fi

# ── Gemini extension config ──────────────────────────────────────────────────

begin_suite "Gemini Extension"

GEMINI="${PROJECT_ROOT}/gemini-extension.json"

assert_file_exists "$GEMINI" "gemini-extension.json exists"
assert_valid_json "$GEMINI" "gemini-extension.json is valid JSON"

print_summary
