#!/usr/bin/env bash

set -u

TEST_REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CLI="$TEST_REPO/bin/dotfiles-codex-config"
PASS_COUNT=0
FAIL_COUNT=0
TEMP_ROOTS=""
NO_UV_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

UV_BIN=$(command -v uv 2>/dev/null || true)
if [ -z "$UV_BIN" ] && [ -x "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims/uv" ]; then
  UV_BIN="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims/uv"
fi
if [ -n "$UV_BIN" ] && command -v mise >/dev/null 2>&1; then
  MISE_UV=$(mise which uv 2>/dev/null || true)
  if [ -n "$MISE_UV" ] && [ -x "$MISE_UV" ]; then
    UV_BIN="$MISE_UV"
  fi
fi

UV_TEST_PATH=""
UV_CACHE=""
UV_PYTHON_DIR=""
if [ -n "$UV_BIN" ]; then
  UV_TEST_PATH="$(CDPATH= cd -- "$(dirname -- "$UV_BIN")" && pwd):$NO_UV_PATH"
  UV_CACHE=$("$UV_BIN" cache dir 2>/dev/null || true)
  UV_CACHE=${UV_CACHE:-"$HOME/.cache/uv"}
  UV_PYTHON_DIR=$("$UV_BIN" python dir 2>/dev/null || true)
  UV_PYTHON_DIR=${UV_PYTHON_DIR:-"$HOME/.local/share/uv/python"}
fi

cleanup() {
  local root
  for root in $TEMP_ROOTS; do
    rm -rf "$root"
  done
}
trap cleanup EXIT HUP INT TERM

fail() {
  printf '    %s\n' "$*" >&2
  return 1
}

assert_eq() {
  local expected=$1
  local actual=$2
  local message=${3:-"values differ"}

  if [ "$expected" != "$actual" ]; then
    fail "$message (expected: '$expected', actual: '$actual')"
  fi
}

assert_file_contains() {
  local file=$1
  local expected=$2

  if ! grep -F "$expected" "$file" >/dev/null 2>&1; then
    fail "expected $file to contain: $expected"
  fi
}

new_fixture() {
  FIXTURE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-codex-config-test.XXXXXX") || return 1
  TEMP_ROOTS="$TEMP_ROOTS $FIXTURE_ROOT"
  TEST_HOME="$FIXTURE_ROOT/home"
  TEST_DOTFILES="$FIXTURE_ROOT/dotfiles"
  LIVE_CONFIG="$TEST_HOME/.codex/config.toml"
  mkdir -p "$TEST_HOME" "$TEST_DOTFILES/bin" "$TEST_DOTFILES/.codex"
  cp "$CLI" "$TEST_DOTFILES/bin/dotfiles-codex-config"
  chmod +x "$TEST_DOTFILES/bin/dotfiles-codex-config"
}

write_curated() {
  printf '%s\n' \
    'model = "gpt"' \
    'approval_policy = "on-request"' \
    '' \
    '[tools]' \
    'web_search = true' >"$TEST_DOTFILES/.codex/config.toml"
}

write_live_with_machine_state() {
  mkdir -p "$TEST_HOME/.codex"
  printf '%s\n' \
    '# machine comment' \
    'model = "old-model"' \
    'cached_terms_version = "1.0"' \
    '' \
    '[tools]' \
    'web_search = false' \
    'view_image = true' \
    '' \
    '[projects."/Users/x"]' \
    'trust_level = "trusted"' >"$LIVE_CONFIG"
}

run_codex_config() {
  HOME="$TEST_HOME" \
    PATH="$UV_TEST_PATH" \
    UV_CACHE_DIR="$UV_CACHE" \
    UV_PYTHON_INSTALL_DIR="$UV_PYTHON_DIR" \
    "$TEST_DOTFILES/bin/dotfiles-codex-config" "$@"
}

run_codex_config_without_uv() {
  HOME="$TEST_HOME" \
    PATH="$NO_UV_PATH" \
    "$TEST_DOTFILES/bin/dotfiles-codex-config" "$@"
}

test_fresh_run_creates_live_config_from_curated() {
  new_fixture || return 1
  write_curated

  run_codex_config >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "fresh run failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_file_contains "$FIXTURE_ROOT/output" '+ Created' || return 1
  [ -f "$LIVE_CONFIG" ] || fail 'live config was not created' || return 1
  cmp -s "$TEST_DOTFILES/.codex/config.toml" "$LIVE_CONFIG" ||
    fail 'fresh live config does not match the curated content'
}

test_second_run_is_idempotent() {
  new_fixture || return 1
  write_curated

  run_codex_config >"$FIXTURE_ROOT/first-output" 2>&1 ||
    fail "first run failed: $(sed -n '1,20p' "$FIXTURE_ROOT/first-output")" || return 1
  cp "$LIVE_CONFIG" "$FIXTURE_ROOT/after-first.toml"

  run_codex_config >"$FIXTURE_ROOT/second-output" 2>&1 ||
    fail "second run failed: $(sed -n '1,20p' "$FIXTURE_ROOT/second-output")" || return 1

  assert_file_contains "$FIXTURE_ROOT/second-output" '= Codex config already up to date' || return 1
  cmp -s "$FIXTURE_ROOT/after-first.toml" "$LIVE_CONFIG" ||
    fail 'second run changed the live config bytes'
}

test_curated_keys_override_live_values_deeply() {
  new_fixture || return 1
  write_curated
  write_live_with_machine_state

  run_codex_config >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "merge run failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_file_contains "$LIVE_CONFIG" 'model = "gpt"' || return 1
  if grep -F 'model = "old-model"' "$LIVE_CONFIG" >/dev/null 2>&1; then
    fail 'stale top-level live value survived the merge' || return 1
  fi
  assert_file_contains "$LIVE_CONFIG" 'web_search = true' || return 1
  assert_file_contains "$LIVE_CONFIG" 'view_image = true' ||
    fail 'nested merge replaced the whole [tools] table instead of deep-merging'
}

test_live_only_machine_state_survives_merge() {
  new_fixture || return 1
  write_curated
  write_live_with_machine_state

  run_codex_config >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "merge run failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_file_contains "$LIVE_CONFIG" 'cached_terms_version = "1.0"' || return 1
  assert_file_contains "$LIVE_CONFIG" '[projects."/Users/x"]' || return 1
  assert_file_contains "$LIVE_CONFIG" 'trust_level = "trusted"'
}

test_merge_preserves_comments_and_writes_backup() {
  new_fixture || return 1
  write_curated
  write_live_with_machine_state
  cp "$LIVE_CONFIG" "$FIXTURE_ROOT/pre-merge.toml"

  run_codex_config >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "merge run failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_file_contains "$LIVE_CONFIG" '# machine comment' || return 1
  [ -f "$LIVE_CONFIG.bak" ] || fail 'backup file was not written for a changing merge' || return 1
  cmp -s "$FIXTURE_ROOT/pre-merge.toml" "$LIVE_CONFIG.bak" ||
    fail 'backup does not hold the pre-merge live content'
}

test_missing_uv_fails_with_guidance() {
  local result

  new_fixture || return 1
  write_curated

  run_codex_config_without_uv >"$FIXTURE_ROOT/output" 2>&1
  result=$?

  assert_eq 1 "$result" 'uv-missing run has the wrong exit code' || return 1
  assert_file_contains "$FIXTURE_ROOT/output" "uv missing; run 'mise install'"
}

test_missing_curated_config_fails() {
  local result

  new_fixture || return 1

  run_codex_config_without_uv >"$FIXTURE_ROOT/output" 2>&1
  result=$?

  assert_eq 1 "$result" 'missing-curated run has the wrong exit code' || return 1
  assert_file_contains "$FIXTURE_ROOT/output" 'Missing curated config'
}

run_test() {
  local name=$1
  shift
  printf 'test: %s ... ' "$name"
  if "$@"; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'ok\n'
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL\n'
  fi
}

if [ -n "$UV_BIN" ]; then
  run_test 'fresh run creates live config from curated' test_fresh_run_creates_live_config_from_curated
  run_test 'second run is idempotent' test_second_run_is_idempotent
  run_test 'curated keys override live values deeply' test_curated_keys_override_live_values_deeply
  run_test 'live-only machine state survives merge' test_live_only_machine_state_survives_merge
  run_test 'merge preserves comments and writes backup' test_merge_preserves_comments_and_writes_backup
else
  printf 'warning: uv not found; skipping merge test cases\n'
fi
run_test 'missing uv fails with guidance' test_missing_uv_fails_with_guidance
run_test 'missing curated config fails' test_missing_curated_config_fails

printf '\n%d passed, %d failed\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
