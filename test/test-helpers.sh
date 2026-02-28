#!/usr/bin/env bash

assert_contains() {
  local file="$1"
  local pattern="$2"
  local name="${3:-$pattern}"
  if grep -qiE "$pattern" "$file"; then
    if [ "$VERBOSE" = true ]; then echo "  [PASS] $name"; fi
    return 0
  else
    echo "  [FAIL] $name (expected to match: $pattern)"
    return 1
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local name="${3:-$pattern}"
  if grep -qiE "$pattern" "$file"; then
    echo "  [FAIL] $name (did not expect to match: $pattern)"
    return 1
  else
    if [ "$VERBOSE" = true ]; then echo "  [PASS] $name"; fi
    return 0
  fi
}

assert_order() {
  local file="$1"
  local pattern_a="$2"
  local pattern_b="$3"
  local name="${4:-Order $pattern_a before $pattern_b}"

  local line_a=$(grep -niE "$pattern_a" "$file" | head -1 | cut -d: -f1)
  local line_b=$(grep -niE "$pattern_b" "$file" | head -1 | cut -d: -f1)

  if [ -z "$line_a" ]; then
    echo "  [FAIL] $name (missing A: $pattern_a)"
    return 1
  fi
  if [ -z "$line_b" ]; then
    echo "  [FAIL] $name (missing B: $pattern_b)"
    return 1
  fi
  if [ "$line_a" -lt "$line_b" ]; then
    if [ "$VERBOSE" = true ]; then echo "  [PASS] $name"; fi
    return 0
  else
    echo "  [FAIL] $name (A matched at $line_a, B matched at $line_b)"
    return 1
  fi
}

setup_fixture() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  if [ -d "$src" ] && [ "$(ls -A "$src")" ]; then
    cp -r "$src"/* "$dest"/
  fi
}
