#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"
SKILL_PATH="$(cd "$SCRIPT_DIR/../skills/supershaping" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

VERBOSE=${VERBOSE:-false}
MODELS_ENV="${PI_TEST_MODELS:-anthropic/claude-opus-4-6:high openai-codex/gpt-5.3-codex:high}"
read -ra MODELS <<< "$MODELS_ENV"

ONLY_SCENARIO="${1:-}"

OUTPUT_DIR="$SCRIPT_DIR/output/run-$(date +%s)"
mkdir -p "$OUTPUT_DIR"

RESULTS_CSV="$OUTPUT_DIR/results.csv"
echo "status,scenario_id,scenario_name,model,failed_checks" > "$RESULTS_CSV"

PASS=0
FAIL=0

run_scenario() {
  local scenario_id="$1"
  local scenario_name="$2"
  local fixture_name="$3"
  local prompt="$4"
  local model="$5"
  shift 5
  local checks=("$@")

  if [[ -n "$ONLY_SCENARIO" && "$scenario_id" != "$ONLY_SCENARIO" ]]; then
    return
  fi

  local model_slug=$(echo "$model" | tr '/: ' '---')
  local out_dir="$OUTPUT_DIR/$model_slug"
  mkdir -p "$out_dir"
  local out_file="$out_dir/${scenario_id}.txt"
  local fx_dir=$(mktemp -d)

  if [ -n "$fixture_name" ] && [ -d "$FIXTURES_DIR/$fixture_name" ]; then
    setup_fixture "$FIXTURES_DIR/$fixture_name" "$fx_dir"
  fi

  echo "------------------------------------------------"
  echo "  Scenario $scenario_id: $scenario_name ($model)"

  local actual_prompt="${prompt//__FX_DIR__/$fx_dir}"

  local pi_exit=0
  if ! timeout 180 pi -p --no-session -m "$model" --skill "$SKILL_PATH" "$actual_prompt" > "$out_file" 2>&1; then
    pi_exit=$?
    echo "  ⚠ pi exited with code $pi_exit"
  fi

  if [[ ! -s "$out_file" ]]; then
    echo "  [FAIL] Empty output"
    FAIL=$((FAIL+1))
    echo "FAIL,\"$scenario_id\",\"$scenario_name\",\"$model\",\"empty output\"" >> "$RESULTS_CSV"
    return
  fi

  local all_pass=true
  local failed_names=()

  local i=0
  while [[ $i -lt ${#checks[@]} ]]; do
    local check_name="${checks[$i]}"
    local check_pattern="${checks[$((i+1))]}"
    i=$((i+2))
    if ! assert_contains "$out_file" "$check_pattern" "$check_name"; then
      all_pass=false
      failed_names+=("[$check_name]")
    fi
  done

  if $all_pass; then
    echo "  [PASS] All checks passed"
    PASS=$((PASS+1))
    echo "PASS,\"$scenario_id\",\"$scenario_name\",\"$model\",\"\"" >> "$RESULTS_CSV"
  else
    FAIL=$((FAIL+1))
    local failed_str=$(IFS=';' ; echo "${failed_names[*]}")
    echo "FAIL,\"$scenario_id\",\"$scenario_name\",\"$model\",\"${failed_str}\"" >> "$RESULTS_CSV"
    if [ "$VERBOSE" != true ]; then
        echo "  --- Output tail ---"
        tail -n 20 "$out_file" | sed 's/^/  | /'
    fi
  fi
}

echo "=== Integration Tests ==="
echo "Output dir: $OUTPUT_DIR"

for MODEL in "${MODELS[@]}"; do
  run_scenario "01" "empty-small" "" \
    "I want to add a quick tooltip to the user menu button showing the user's name. Small UI change, nothing complex. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to brainstorming" "brainstorm" \
    "acknowledges small/quick/direct scope" "small|quick|direct|superpowers"

  run_scenario "02" "empty-large" "" \
    "I need to design and build a full multi-tenant authentication system. Touches many services. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to shaping or frame" "shap|frame" \
    "mentions Frame document or shaping first" "frame|shaping.first|start.with.frame"

  run_scenario "03" "frame-only" "scenario-03-frame-only" \
    "Continuing work on the multi-tenant auth feature. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to shaping/requirements/shapes" "shap|requirement|breadboard|shape"

  run_scenario "04" "shaping-no-slices" "scenario-04-shaping-no-slices" \
    "Continuing work on the multi-tenant auth feature. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to slicing" "slice"

  run_scenario "05" "slices-no-spec" "scenario-05-slices-no-spec" \
    "Continuing work on the multi-tenant auth feature. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to slice/spec/brainstorm phase" "slice" \
    "uses derive/ground-truth framing" "ground.truth|derive|don.t re-?negotiat|settled"

  run_scenario "06" "spec-no-plan" "scenario-06-spec-no-plan" \
    "Continuing work on the multi-tenant auth feature. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "engages with plan creation" "plan"

  run_scenario "07" "plan-exists" "scenario-07-plan-exists" \
    "Continuing work on the multi-tenant auth feature. Feature folder: __FX_DIR__. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to execution" "execut|implement|subagent|dispatch|proceed.with"

  run_scenario "08" "external-ux-artifacts" "scenario-08-external-ux" \
    "I have some UI mockups for a new feature. Feature folder: __FX_DIR__. Check what artifacts exist there (including any image files) and recommend the next step using the supershaping skill." \
    "$MODEL" \
    "routes to shaping" "shap" \
    "treats mockups as source material or mentions frame" "source.material|source material|frame|input.to.shap|material for|as.source"
done

echo ""
TOTAL=$((PASS+FAIL))
echo "Integration: $PASS/$TOTAL passed, $FAIL failed."
if [ "$FAIL" -gt 0 ]; then exit 1; else exit 0; fi
