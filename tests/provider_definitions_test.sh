#!/usr/bin/env bash
set -euo pipefail

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; exit 1; }
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$REPO_DIR/clother.sh"

run_modelstudio_provider_def_test() {
  local def
  def="$(get_provider_def "modelstudio")"

  [[ "$def" == "DASHSCOPE_API_KEY|https://dashscope-intl.aliyuncs.com/compatible-mode/v1|qwen-plus||Alibaba Model Studio" ]] \
    || fail "modelstudio provider definition mismatch"
  pass "modelstudio provider definition is correct"
}

run_config_help_lists_modelstudio_test() {
  local output
  output="$(show_command_help config)"

  [[ "$output" == *"modelstudio"* ]] || fail "config help should list modelstudio"
  pass "config help lists modelstudio"
}

run_modelstudio_provider_def_test
run_config_help_lists_modelstudio_test
