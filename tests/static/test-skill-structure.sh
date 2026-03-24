#!/usr/bin/env bash
# Validates that all skills have proper YAML frontmatter and required files.

set -euo pipefail
. "$(dirname "$0")/../test-helpers.sh"

SKILLS_DIR="${PROJECT_ROOT}/skills"

# ── All skills must have SKILL.md with name and description ──────────────────

begin_suite "Skill Structure"

for skill_dir in "${SKILLS_DIR}"/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="${skill_dir}SKILL.md"

  assert_file_exists "$skill_file" "skills/${skill_name}/SKILL.md exists"
  assert_file_not_empty "$skill_file" "skills/${skill_name}/SKILL.md not empty"
  assert_yaml_frontmatter "$skill_file" "skills/${skill_name}/SKILL.md has frontmatter"
  assert_yaml_field "$skill_file" "name" "skills/${skill_name}/SKILL.md has 'name' field"
  assert_yaml_field "$skill_file" "description" "skills/${skill_name}/SKILL.md has 'description' field"
done

# ── Reviewer skills must have agent-prompt.md ────────────────────────────────

begin_suite "Reviewer Agent Prompts"

REVIEWERS=("oo-design-review" "clean-architecture-review" "api-design-review")

for reviewer in "${REVIEWERS[@]}"; do
  agent_prompt="${SKILLS_DIR}/${reviewer}/agent-prompt.md"
  assert_file_exists "$agent_prompt" "skills/${reviewer}/agent-prompt.md exists"
  assert_file_not_empty "$agent_prompt" "skills/${reviewer}/agent-prompt.md not empty"
done

# ── Orchestration files referenced by architecture-loop ──────────────────────

begin_suite "Architecture Loop Orchestration Files"

LOOP_FILES=(
  "skills/architecture-loop/implementer-prompt.md"
  "skills/architecture-loop/review-output-format.md"
  "skills/architecture-loop/approval-criteria.md"
)

for f in "${LOOP_FILES[@]}"; do
  assert_file_exists "${PROJECT_ROOT}/${f}" "${f} exists"
  assert_file_not_empty "${PROJECT_ROOT}/${f}" "${f} not empty"
done

# ── Reviewer reference files ─────────────────────────────────────────────────

begin_suite "OO Design Review Reference Files"

OO_REFS=(
  "solid-principles.md"
  "dry-principle.md"
  "design-patterns.md"
  "composition-and-inheritance.md"
)

for ref in "${OO_REFS[@]}"; do
  assert_file_exists "${SKILLS_DIR}/oo-design-review/${ref}" \
    "skills/oo-design-review/${ref} exists"
done

begin_suite "Clean Architecture Review Reference Files"

CA_REFS=(
  "component-cohesion.md"
  "component-coupling.md"
  "quality-attributes.md"
)

for ref in "${CA_REFS[@]}"; do
  assert_file_exists "${SKILLS_DIR}/clean-architecture-review/${ref}" \
    "skills/clean-architecture-review/${ref} exists"
done

begin_suite "API Design Review Reference Files"

API_REFS=(
  "naming-conventions.md"
  "method-and-parameter-design.md"
  "rest-endpoint-design.md"
)

for ref in "${API_REFS[@]}"; do
  assert_file_exists "${SKILLS_DIR}/api-design-review/${ref}" \
    "skills/api-design-review/${ref} exists"
done

# ── Skill names in frontmatter match directory names ─────────────────────────

begin_suite "Skill Name Consistency"

for skill_dir in "${SKILLS_DIR}"/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="${skill_dir}SKILL.md"
  frontmatter_name=$(yaml_field "$skill_file" "name")
  assert_equals "$skill_name" "$frontmatter_name" \
    "skills/${skill_name} frontmatter name matches directory"
done

print_summary
