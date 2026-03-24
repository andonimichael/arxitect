#!/usr/bin/env bash
# Test explicit skill requests.
# Verifies that Claude invokes the skill when the user names it directly
# and does not take premature action before loading the skill.
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
source "$SCRIPT_DIR/../test-helpers.sh"

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/arxitect-tests/${TIMESTAMP}/explicit-skill-requests/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

PROMPT=$(cat "$PROMPT_FILE")

echo "=== Explicit Skill Request Test ==="
echo "Skill:      $SKILL_NAME"
echo "Prompt:     $(basename "$PROMPT_FILE")"
echo "Max turns:  $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""

cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

# Create a minimal project directory so Claude has something to work with
PROJECT_DIR="$OUTPUT_DIR/project"
mkdir -p "$PROJECT_DIR/src"

cat > "$PROJECT_DIR/src/example.ts" << 'EXEOF'
export class UserService {
  private db: Database;

  constructor(db: Database) {
    this.db = db;
  }

  async getUser(id: string): Promise<User> {
    return this.db.findOne('users', { id });
  }

  async createUser(name: string, email: string): Promise<User> {
    const user = { id: crypto.randomUUID(), name, email };
    await this.db.insert('users', user);
    return user;
  }
}
EXEOF

LOG_FILE="$OUTPUT_DIR/claude-output.json"
cd "$PROJECT_DIR"

echo "Running claude -p with explicit skill request..."
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
assert_skill_triggered "$LOG_FILE" "$SKILL_NAME"
TRIGGER_RESULT=$?

# Check for premature actions (warning only — non-deterministic)
check_premature_actions() {
  local log_file="$1"
  local first_skill_line
  first_skill_line=$(grep -n '"name":"Skill"' "$log_file" | head -1 | cut -d: -f1)

  if [[ -z "$first_skill_line" ]]; then
    return
  fi

  local premature
  premature=$(head -n "$first_skill_line" "$log_file" | \
    grep '"type":"tool_use"' | \
    grep -v '"name":"Skill"' | \
    grep -v '"name":"TodoWrite"' || true)

  if [[ -n "$premature" ]]; then
    echo "  WARNING: Tools invoked before Skill tool (non-deterministic, not a failure)"
  else
    echo "  ✓ No premature tool invocations before Skill"
  fi
}

check_premature_actions "$LOG_FILE"

# Show what skills were triggered
echo ""
echo "Skills triggered:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u || echo "  (none)"

echo ""
echo "Full log: $LOG_FILE"

if [[ $TRIGGER_RESULT -eq 0 ]]; then
  exit 0
else
  exit 1
fi
