#!/usr/bin/env bash
# Bumps the version across all manifest files.
#
# Usage:
#   ./scripts/release.sh <patch|minor|major>
#   ./scripts/release.sh --set 1.2.3
#
# Reads the current version from package.json and writes the new version
# to all manifest files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Parse arguments ──────────────────────────────────────────────────────────

SCOPE=""
EXPLICIT_VERSION=""

case "${1:-}" in
  patch|minor|major)
    SCOPE="$1"
    ;;
  --set)
    EXPLICIT_VERSION="${2:?Usage: release.sh --set <version>}"
    ;;
  *)
    echo "Usage: release.sh <patch|minor|major>" >&2
    echo "       release.sh --set <version>" >&2
    exit 1
    ;;
esac

# ── Read current version ────────────────────────────────────────────────────

CURRENT=$(python3 -c "import json; print(json.load(open('${PROJECT_ROOT}/package.json'))['version'])")

if [[ -z "$CURRENT" ]]; then
  echo "Error: could not read current version from package.json" >&2
  exit 1
fi

# ── Calculate new version ───────────────────────────────────────────────────

if [[ -n "$EXPLICIT_VERSION" ]]; then
  NEW_VERSION="$EXPLICIT_VERSION"
else
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

  case "$SCOPE" in
    major)
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    minor)
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    patch)
      PATCH=$((PATCH + 1))
      ;;
  esac

  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
fi

# ── Update all manifest files ───────────────────────────────────────────────

VERSION_FILES=(
  "package.json"
  ".claude-plugin/plugin.json"
  ".claude-plugin/marketplace.json"
  ".cursor-plugin/plugin.json"
  "gemini-extension.json"
)

for file in "${VERSION_FILES[@]}"; do
  filepath="${PROJECT_ROOT}/${file}"
  if [[ -f "$filepath" ]]; then
    python3 -c "
import json, sys

with open('${filepath}', 'r') as f:
    data = json.load(f)

# marketplace.json nests version inside plugins[0]
if 'plugins' in data and isinstance(data['plugins'], list):
    data['plugins'][0]['version'] = '${NEW_VERSION}'
else:
    data['version'] = '${NEW_VERSION}'

with open('${filepath}', 'w') as f:
    json.dump(data, f, indent=4)
    f.write('\n')
"
    echo "  Updated ${file}: ${CURRENT} → ${NEW_VERSION}"
  else
    echo "  Warning: ${file} not found, skipping" >&2
  fi
done

# ── Output for downstream consumers ─────────────────────────────────────────

echo ""
echo "Version bumped: ${CURRENT} → ${NEW_VERSION}"

# If GITHUB_OUTPUT is set (running in GitHub Actions), export variables
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "old_version=${CURRENT}" >> "$GITHUB_OUTPUT"
  echo "new_version=${NEW_VERSION}" >> "$GITHUB_OUTPUT"
fi
