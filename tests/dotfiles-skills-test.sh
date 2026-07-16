#!/usr/bin/env bash

set -u

TEST_REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CLI="$TEST_REPO/bin/dotfiles-skills"
PASS_COUNT=0
FAIL_COUNT=0
TEMP_ROOTS=""

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
  FIXTURE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-skills-test.XXXXXX") || return 1
  TEMP_ROOTS="$TEMP_ROOTS $FIXTURE_ROOT"
  TEST_HOME="$FIXTURE_ROOT/home"
  TEST_DOTFILES="$FIXTURE_ROOT/dotfiles"
  TEST_BIN="$FIXTURE_ROOT/bin"
  TEST_PATH="$TEST_BIN:/usr/bin:/bin:/usr/sbin:/sbin"
  mkdir -p "$TEST_HOME" "$TEST_DOTFILES/.agents/skills" "$TEST_BIN"
}

make_skill() {
  local parent=$1
  local name=$2
  local description=$3

  mkdir -p "$parent/$name"
  printf '%s\n' \
    '---' \
    "name: $name" \
    "description: $description" \
    '---' \
    '' \
    "# $name" >"$parent/$name/SKILL.md"
}

run_cli() {
  HOME="$TEST_HOME" \
    DOTFILES_DIR="$TEST_DOTFILES" \
    GH_LOG="${GH_LOG:-}" \
    PATH="$TEST_PATH" \
    "$CLI" "$@"
}

test_fresh_sync_links_canonical_skills() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "fresh sync failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  [ -L "$TEST_HOME/.agents/skills" ] || fail '~/.agents/skills is not a symlink' || return 1
  assert_eq "$TEST_DOTFILES/.agents/skills" "$(readlink "$TEST_HOME/.agents/skills")" \
    '~/.agents/skills has the wrong target' || return 1
  [ -L "$TEST_HOME/.claude/skills/alpha" ] || fail 'Claude alpha skill is not a symlink' || return 1
  assert_eq "$TEST_DOTFILES/.agents/skills/alpha" "$(readlink "$TEST_HOME/.claude/skills/alpha")" \
    'Claude alpha skill has the wrong target'
}

test_sync_accepts_quoted_yaml_skill_name() {
  new_fixture || return 1
  mkdir -p "$TEST_DOTFILES/.agents/skills/alpha"
  printf '%s\n' '---' 'name: "alpha"' 'description: canonical' '---' \
    >"$TEST_DOTFILES/.agents/skills/alpha/SKILL.md"

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "quoted-name sync failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1
  [ -L "$TEST_HOME/.claude/skills/alpha" ] || fail 'quoted-name skill was not linked for Claude'
}

test_sync_migrates_live_only_skill_without_backup() {
  new_fixture || return 1
  mkdir -p "$TEST_HOME/.agents/skills"
  make_skill "$TEST_HOME/.agents/skills" caveman live-only

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "migration sync failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  [ -f "$TEST_DOTFILES/.agents/skills/caveman/SKILL.md" ] ||
    fail 'live-only caveman was not imported into the canonical repository' || return 1
  assert_file_contains "$TEST_DOTFILES/.agents/skills/caveman/SKILL.md" 'description: live-only' || return 1
  [ -L "$TEST_HOME/.agents/skills" ] || fail '~/.agents/skills was not replaced by the canonical link' || return 1
  if find "$TEST_HOME" "$TEST_DOTFILES" -iname '*backup*' -print -quit | grep . >/dev/null 2>&1; then
    fail 'sync created a backup despite the no-backup migration contract'
  fi
}

test_sync_refuses_differing_same_name_skill() {
  local result

  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" shared canonical
  mkdir -p "$TEST_HOME/.agents/skills"
  make_skill "$TEST_HOME/.agents/skills" shared live

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1
  result=$?
  if [ "$result" -eq 0 ]; then
    fail 'sync unexpectedly accepted a differing same-name skill' || return 1
  fi
  if [ "$result" -eq 127 ]; then
    fail 'sync command is missing; conflict behavior was not exercised' || return 1
  fi

  [ ! -L "$TEST_HOME/.agents/skills" ] || fail 'conflicting live directory was replaced' || return 1
  assert_file_contains "$TEST_HOME/.agents/skills/shared/SKILL.md" 'description: live' || return 1
  assert_file_contains "$TEST_DOTFILES/.agents/skills/shared/SKILL.md" 'description: canonical'
}

test_sync_is_idempotent_and_repairs_wrong_agents_link() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  mkdir -p "$TEST_HOME/.agents" "$FIXTURE_ROOT/wrong-skills"
  ln -s "$FIXTURE_ROOT/wrong-skills" "$TEST_HOME/.agents/skills"

  run_cli sync >"$FIXTURE_ROOT/first-output" 2>&1 ||
    fail "wrong-link repair failed: $(sed -n '1,20p' "$FIXTURE_ROOT/first-output")" || return 1
  assert_eq "$TEST_DOTFILES/.agents/skills" "$(readlink "$TEST_HOME/.agents/skills")" \
    'wrong ~/.agents/skills link was not repaired' || return 1

  run_cli sync >"$FIXTURE_ROOT/second-output" 2>&1 ||
    fail "second sync failed: $(sed -n '1,20p' "$FIXTURE_ROOT/second-output")" || return 1
  assert_eq "$TEST_DOTFILES/.agents/skills" "$(readlink "$TEST_HOME/.agents/skills")" \
    'second sync changed the canonical link'
}

test_sync_migrates_previous_parent_symlink_without_deleting_skills() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  printf '%s\n' '{"version":3}' >"$TEST_DOTFILES/.agents/.skill-lock.json"
  ln -s "$TEST_DOTFILES/.agents" "$TEST_HOME/.agents"

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "parent-link migration failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  [ -f "$TEST_DOTFILES/.agents/skills/alpha/SKILL.md" ] ||
    fail 'parent-link migration deleted the canonical skill' || return 1
  [ ! -L "$TEST_HOME/.agents" ] || fail 'previous ~/.agents parent link was not migrated' || return 1
  [ -f "$TEST_HOME/.agents/.skill-lock.json" ] ||
    fail 'parent-link migration did not preserve .skill-lock.json' || return 1
  assert_eq "$TEST_DOTFILES/.agents/skills" "$(readlink "$TEST_HOME/.agents/skills")" \
    'migrated skills link has the wrong target'
}

test_sync_refuses_unrecognized_live_content() {
  local result

  new_fixture || return 1
  mkdir -p "$TEST_HOME/.agents/skills/not-a-skill"
  printf '%s\n' important >"$TEST_HOME/.agents/skills/not-a-skill/data.txt"

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1
  result=$?
  [ "$result" -ne 0 ] || fail 'sync accepted unrecognized live content' || return 1
  [ -f "$TEST_HOME/.agents/skills/not-a-skill/data.txt" ] ||
    fail 'sync deleted unrecognized live content'
}

test_sync_refuses_symlinked_live_skill() {
  local result

  new_fixture || return 1
  make_skill "$FIXTURE_ROOT/external" linked external
  mkdir -p "$TEST_HOME/.agents/skills"
  ln -s "$FIXTURE_ROOT/external/linked" "$TEST_HOME/.agents/skills/linked"

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1
  result=$?
  [ "$result" -ne 0 ] || fail 'sync accepted an externally symlinked live skill' || return 1
  [ -L "$TEST_HOME/.agents/skills/linked" ] || fail 'sync removed the live skill symlink' || return 1
  [ ! -e "$TEST_DOTFILES/.agents/skills/linked" ] || fail 'sync imported a non-vendored skill symlink'
}

test_sync_links_claude_per_skill_and_preserves_native_conflict() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  make_skill "$TEST_DOTFILES/.agents/skills" native canonical
  mkdir -p "$TEST_HOME/.claude/skills"
  make_skill "$TEST_HOME/.claude/skills" native claude-owned

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "Claude sync failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  [ -L "$TEST_HOME/.claude/skills/alpha" ] || fail 'missing Claude per-skill alpha link' || return 1
  assert_eq "$TEST_DOTFILES/.agents/skills/alpha" "$(readlink "$TEST_HOME/.claude/skills/alpha")" \
    'Claude alpha link has the wrong target' || return 1
  [ ! -L "$TEST_HOME/.claude/skills/native" ] || fail 'Claude-owned native skill was replaced' || return 1
  assert_file_contains "$TEST_HOME/.claude/skills/native/SKILL.md" 'description: claude-owned'
}

test_sync_leaves_codex_skills_untouched() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  mkdir -p "$TEST_HOME/.codex/skills"
  printf '%s\n' 'codex-owned' >"$TEST_HOME/.codex/skills/marker.txt"

  run_cli sync >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "sync failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_eq 'codex-owned' "$(sed -n '1p' "$TEST_HOME/.codex/skills/marker.txt")" \
    'Codex marker changed' || return 1
  [ ! -e "$TEST_HOME/.codex/skills/alpha" ] || fail 'sync added a skill to ~/.codex/skills'
}

install_fake_gh() {
  GH_LOG="$FIXTURE_ROOT/gh.log"
  : >"$GH_LOG"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -u' \
    'printf "<" >>"$GH_LOG"' \
    'separator=""' \
    'for argument in "$@"; do' \
    '  printf "%s%s" "$separator" "$argument" >>"$GH_LOG"' \
    '  separator="><"' \
    'done' \
    'printf ">\n" >>"$GH_LOG"' \
    'if [ "${1:-}" = skill ] && [ "${2:-}" = preview ]; then' \
    '  printf "%s\n" "preview: ${3:-}/${4:-}"' \
    'fi' \
    'if [ "${1:-}" = skill ] && [ "${2:-}" = install ]; then' \
    '  repository=${3:-}' \
    '  skill=${4:-}' \
    '  destination=""' \
    '  shift 4' \
    '  while [ "$#" -gt 0 ]; do' \
    '    if [ "$1" = --dir ]; then' \
    '      destination=${2:-}' \
    '      shift 2' \
    '    else' \
    '      shift' \
    '    fi' \
    '  done' \
    '  mkdir -p "$destination/$skill"' \
    '  printf "%s\n" "---" "name: $skill" "description: from $repository" "---" >"$destination/$skill/SKILL.md"' \
    'fi' >"$TEST_BIN/gh"
  chmod +x "$TEST_BIN/gh"
}

test_add_previews_then_installs_into_canonical_directory() {
  new_fixture || return 1
  install_fake_gh

  run_cli add acme/skills demo >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "add failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_file_contains "$GH_LOG" '<skill><preview><acme/skills><demo>' || return 1
  assert_file_contains "$GH_LOG" "<skill><install><acme/skills><demo><--dir><$TEST_DOTFILES/.agents/skills>" || return 1
  [ -f "$TEST_DOTFILES/.agents/skills/demo/SKILL.md" ] || fail 'add did not install into canonical skills' || return 1
  [ -L "$TEST_HOME/.agents/skills" ] || fail 'add did not sync ~/.agents/skills after installation'
}

test_check_update_and_list_delegate_to_gh_for_canonical_directory() {
  new_fixture || return 1
  install_fake_gh

  run_cli check >"$FIXTURE_ROOT/check-output" 2>&1 || fail 'check failed' || return 1
  run_cli update >"$FIXTURE_ROOT/update-output" 2>&1 || fail 'update failed' || return 1
  run_cli list >"$FIXTURE_ROOT/list-output" 2>&1 || fail 'list failed' || return 1

  assert_file_contains "$GH_LOG" "<skill><update><--all><--dry-run><--dir><$TEST_DOTFILES/.agents/skills>" || return 1
  assert_file_contains "$GH_LOG" "<skill><update><--all><--dir><$TEST_DOTFILES/.agents/skills>" || return 1
  assert_file_contains "$GH_LOG" "<skill><list><--dir><$TEST_DOTFILES/.agents/skills>"
}

test_status_succeeds_after_sync() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  run_cli sync >"$FIXTURE_ROOT/sync-output" 2>&1 || fail 'setup sync failed' || return 1
  run_cli status >"$FIXTURE_ROOT/status-output" 2>&1 || fail 'status failed for a synchronized installation'
}

test_status_fails_when_claude_link_is_missing() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  run_cli sync >"$FIXTURE_ROOT/sync-output" 2>&1 || fail 'setup sync failed' || return 1
  rm "$TEST_HOME/.claude/skills/alpha"

  if run_cli status >"$FIXTURE_ROOT/status-output" 2>&1; then
    fail 'status accepted a missing Claude skill link'
  fi
}

test_status_fails_for_stale_managed_claude_link() {
  new_fixture || return 1
  make_skill "$TEST_DOTFILES/.agents/skills" alpha canonical
  run_cli sync >"$FIXTURE_ROOT/sync-output" 2>&1 || fail 'setup sync failed' || return 1
  rm -rf "$TEST_DOTFILES/.agents/skills/alpha"

  if run_cli status >"$FIXTURE_ROOT/status-output" 2>&1; then
    fail 'status accepted a stale managed Claude link'
  fi
}

test_installed_symlink_resolves_dotfiles_repository() {
  new_fixture || return 1
  mkdir -p "$TEST_HOME/.local/bin"
  ln -s "$CLI" "$TEST_HOME/.local/bin/dotfiles-skills"

  HOME="$TEST_HOME" PATH="$TEST_PATH" "$TEST_HOME/.local/bin/dotfiles-skills" sync \
    >"$FIXTURE_ROOT/output" 2>&1 ||
    fail "installed invocation failed: $(sed -n '1,20p' "$FIXTURE_ROOT/output")" || return 1

  assert_eq "$TEST_REPO/.agents/skills" "$(readlink "$TEST_HOME/.agents/skills")" \
    'installed helper resolved its symlink directory instead of the dotfiles repository'
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

run_test 'fresh sync links canonical skills' test_fresh_sync_links_canonical_skills
run_test 'sync accepts quoted YAML skill name' test_sync_accepts_quoted_yaml_skill_name
run_test 'sync migrates live-only skill without backup' test_sync_migrates_live_only_skill_without_backup
run_test 'sync refuses differing same-name skill' test_sync_refuses_differing_same_name_skill
run_test 'sync is idempotent and repairs wrong link' test_sync_is_idempotent_and_repairs_wrong_agents_link
run_test 'sync migrates previous parent symlink safely' test_sync_migrates_previous_parent_symlink_without_deleting_skills
run_test 'sync refuses unrecognized live content' test_sync_refuses_unrecognized_live_content
run_test 'sync refuses symlinked live skill' test_sync_refuses_symlinked_live_skill
run_test 'sync links Claude per skill and preserves native conflict' test_sync_links_claude_per_skill_and_preserves_native_conflict
run_test 'sync leaves Codex skills untouched' test_sync_leaves_codex_skills_untouched
run_test 'add previews and installs into canonical directory' test_add_previews_then_installs_into_canonical_directory
run_test 'check, update, and list delegate to gh' test_check_update_and_list_delegate_to_gh_for_canonical_directory
run_test 'status succeeds after sync' test_status_succeeds_after_sync
run_test 'status fails when Claude link is missing' test_status_fails_when_claude_link_is_missing
run_test 'status fails for stale managed Claude link' test_status_fails_for_stale_managed_claude_link
run_test 'installed symlink resolves dotfiles repository' test_installed_symlink_resolves_dotfiles_repository

printf '\n%d passed, %d failed\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
