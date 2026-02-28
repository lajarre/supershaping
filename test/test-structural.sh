#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"
SKILL_PATH="$(cd "$SCRIPT_DIR/../skills/supershaping" && pwd)/SKILL.md"

VERBOSE=${VERBOSE:-false}
PASSED=0
FAILED=0

echo "=== Structural Tests ==="

test_file_exists() {
  if [ -f "$SKILL_PATH" ]; then
    PASSED=$((PASSED+1))
    [ "$VERBOSE" = true ] && echo "  [PASS] SKILL.md exists"
  else
    FAILED=$((FAILED+1))
    echo "  [FAIL] SKILL.md not found at $SKILL_PATH"
  fi
}

test_content() {
  local pattern="$1"
  local desc="$2"
  if assert_contains "$SKILL_PATH" "$pattern" "$desc"; then
    PASSED=$((PASSED+1))
  else
    FAILED=$((FAILED+1))
  fi
}

test_file_exists
test_content "Determine feature folder" "Has 'Determine feature folder' section"
test_content "Assess artifacts" "Has 'Assess artifacts' section"
test_content "Route" "Has routing table"
test_content "Superpowers direct" "Has 'Superpowers direct' route"
test_content "Shaping first" "Has 'Shaping first' route"
test_content "Pick slice" "Has 'Pick slice' route"

echo ""
echo "Structural: $PASSED passed, $FAILED failed."
if [ "$FAILED" -gt 0 ]; then exit 1; else exit 0; fi
