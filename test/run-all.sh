#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RUN_STRUCTURAL=false
RUN_KNOWLEDGE=false
RUN_INTEGRATION=false
export VERBOSE=false

if [ $# -eq 0 ]; then
  RUN_STRUCTURAL=true
  RUN_KNOWLEDGE=true
  RUN_INTEGRATION=true
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      RUN_STRUCTURAL=true
      RUN_KNOWLEDGE=true
      RUN_INTEGRATION=true
      shift
      ;;
    --structural)
      RUN_STRUCTURAL=true
      shift
      ;;
    --knowledge)
      RUN_KNOWLEDGE=true
      shift
      ;;
    --integration)
      RUN_INTEGRATION=true
      shift
      ;;
    --verbose|-v)
      export VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

FAILURES=0

if [ "$RUN_STRUCTURAL" = true ]; then
  ./test-structural.sh || FAILURES=$((FAILURES+1))
fi

if [ "$RUN_KNOWLEDGE" = true ]; then
  ./test-knowledge.sh || FAILURES=$((FAILURES+1))
fi

if [ "$RUN_INTEGRATION" = true ]; then
  ./test-integration.sh || FAILURES=$((FAILURES+1))
fi

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "❌ Some test suites failed."
  exit 1
else
  echo "✅ All requested test suites passed!"
  exit 0
fi
