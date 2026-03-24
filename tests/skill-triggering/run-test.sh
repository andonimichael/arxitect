#!/usr/bin/env bash
# Test skill triggering with natural prompts.
# Verifies that Claude triggers the correct skill from context alone,
# without the user explicitly naming the skill.
#
# Usage: ./run-test.sh <skill-name> <prompt-file> [max-turns]

set -e

SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-5}"

if [[ -z "$SKILL_NAME" || -z "$PROMPT_FILE" ]]; then
  echo "Usage: $0 <skill-name> <prompt-file> [max-turns]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/arxitect-tests/${TIMESTAMP}/skill-triggering/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

PROMPT=$(cat "$PROMPT_FILE")

echo "=== Skill Triggering Test ==="
echo "Skill:      $SKILL_NAME"
echo "Prompt:     $PROMPT_FILE"
echo "Max turns:  $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""

cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

LOG_FILE="$OUTPUT_DIR/claude-output.json"
cd "$OUTPUT_DIR"

echo "Running claude -p with natural prompt..."
timeout 300 claude -p "$PROMPT" \
  --plugin-dir "$PLUGIN_DIR" \
  --model haiku \
  --allowed-tools Skill Read Glob Grep \
  --max-turns "$MAX_TURNS" \
  --output-format stream-json \
  --verbose \
  > "$LOG_FILE" 2>&1 || true

echo ""
echo "=== Results ==="

# Detect empty output (rate limit, timeout, or other failure)
if [[ ! -s "$LOG_FILE" ]]; then
  echo "FAIL: claude produced no output (likely rate-limited or timed out)"
  echo "Wait for your rate limit to reset and try again."
  exit 1
fi

# Check if skill was triggered
SKILL_PATTERN="\"skill\":\"([^\"]*:)?${SKILL_NAME}\""
if grep -q '"name":"Skill"' "$LOG_FILE" && grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
  echo "PASS: Skill '$SKILL_NAME' was triggered"
  TRIGGERED=true
else
  echo "FAIL: Skill '$SKILL_NAME' was NOT triggered"
  TRIGGERED=false
fi

echo ""
echo "Skills triggered in this run:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u || echo "  (none)"

echo ""
echo "Full log: $LOG_FILE"

if [[ "$TRIGGERED" == "true" ]]; then
  exit 0
else
  exit 1
fi
