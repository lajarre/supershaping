#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"
SKILL_PATH="$(cd "$SCRIPT_DIR/../skills/supershaping" && pwd)"

VERBOSE=${VERBOSE:-false}
MODEL="${PI_TEST_MODELS:-anthropic/claude-3-5-sonnet:high}"
MODEL=$(echo "$MODEL" | awk '{print $1}')

echo "=== Knowledge Tests (Model: $MODEL) ==="

OUT_DIR=$(mktemp -d)
OUT_FILE="$OUT_DIR/knowledge.txt"

echo "Running pi to ask about supershaping skill..."
if ! timeout 180 pi -p --no-session -m "$MODEL" --skill "$SKILL_PATH" "According to the supershaping skill, what is the recommended route when only frame.md exists? Be brief." > "$OUT_FILE" 2>&1; then
  echo "  [FAIL] pi execution failed or timed out"
  cat "$OUT_FILE"
  exit 1
fi

PASSED=0
FAILED=0

if assert_contains "$OUT_FILE" "shaping" "Knows route for frame.md only involves shaping"; then
  PASSED=$((PASSED+1))
else
  FAILED=$((FAILED+1))
  cat "$OUT_FILE"
fi

echo ""
echo "Knowledge: $PASSED passed, $FAILED failed."
if [ "$FAILED" -gt 0 ]; then exit 1; else exit 0; fi
