#!/usr/bin/env bash
set -euo pipefail

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; exit 1; }

run_linux_stat_order_test() {
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/data/clother" "$tmp/home"
  : > "$tmp/trace"
  cat > "$tmp/data/clother/secrets.env" <<'EOF'
FOO=bar
EOF

  HOME="$tmp/home" XDG_DATA_HOME="$tmp/data" CLOTHER_OS="Linux" TRACE_FILE="$tmp/trace" bash <<'EOF'
set -euo pipefail
source "/home/runner/work/clother/clother/clother.sh"
stat() {
  printf '%s\n' "$1" >> "$TRACE_FILE"
  if [[ "$1" == "-c" ]]; then
    echo "600"
    return 0
  fi
  if [[ "$1" == "-f" ]]; then
    echo "600"
    return 0
  fi
  return 1
}
load_secrets
EOF

  [[ "$(cat "$tmp/trace")" == "-c" ]] || fail "Linux test expected only stat -c call"
  pass "load_secrets prefers stat -c when available"
}

run_mac_stat_selection_test() {
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/data/clother" "$tmp/home"
  : > "$tmp/trace"
  cat > "$tmp/data/clother/secrets.env" <<'EOF'
FOO=bar
EOF

  HOME="$tmp/home" XDG_DATA_HOME="$tmp/data" CLOTHER_OS="Darwin" TRACE_FILE="$tmp/trace" bash <<'EOF'
set -euo pipefail
source "/home/runner/work/clother/clother/clother.sh"
stat() {
  printf '%s\n' "$1" >> "$TRACE_FILE"
  if [[ "$1" == "-f" ]]; then
    echo "600"
    return 0
  fi
  return 1
}
load_secrets
EOF

  [[ "$(cat "$tmp/trace")" == "-f" ]] || fail "macOS test expected only stat -f call"
  pass "load_secrets uses stat -f directly on macOS"
}

run_line_number_test() {
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/data/clother" "$tmp/home"
  cat > "$tmp/data/clother/secrets.env" <<'EOF'
not_valid=1
EOF

  local output status
  set +e
  output="$(
    HOME="$tmp/home" XDG_DATA_HOME="$tmp/data" bash <<'EOF' 2>&1
set -euo pipefail
source "/home/runner/work/clother/clother/clother.sh"
load_secrets
EOF
  )"
  status=$?
  set -e

  [[ "$status" -eq 1 ]] || fail "line-number test expected load_secrets failure status"
  [[ "$output" == *"line 1"* ]] || fail "line-number test expected explicit line number in error output"
  pass "load_secrets reports line numbers under set -e"
}

run_linux_stat_order_test
run_mac_stat_selection_test
run_line_number_test
