#!/bin/bash
# install.sh — one-command dotfiles setup for a new Mac
#
# Runs ./setup.sh (packages, macOS defaults, symlinks), applies chezmoi-managed
# templates, then runs ./post-setup.sh (tool-dependent bootstraps). Every step
# is idempotent; if one stops, fix the issue it reports and re-run this script.

set -uo pipefail

current="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

post_setup_args=()

for arg in "$@"; do
  case "$arg" in
    --with-trust-store)
      post_setup_args+=("$arg")
      ;;
    -h | --help)
      cat <<'USAGE'
Usage: ./install.sh [--with-trust-store]

One-command setup for a new Mac: runs setup, chezmoi apply, then post-setup.

Options:
  --with-trust-store  Forwarded to post-setup.sh (installs the mkcert local CA).
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

run_step() {
  local label="$1"
  local status
  shift

  printf '\n🏁 %s\n' "$label"

  "$@"
  status=$?

  if [ "$status" -ne 0 ]; then
    printf '\n! %s failed (exit %d)\n' "$label" "$status" >&2
    printf '  Fix the issue above, then re-run ./install.sh (steps are idempotent)\n' >&2
    exit "$status"
  fi
}

setup_chezmoi() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi is missing; re-run ./setup.sh" >&2
    return 1
  fi

  chezmoi init --source "$current" && chezmoi apply
}

chmod +x "${current}/setup.sh" "${current}/post-setup.sh"

run_step "Step 1/3: setup.sh" "${current}/setup.sh"
run_step "Step 2/3: chezmoi" setup_chezmoi
run_step "Step 3/3: post-setup.sh" "${current}/post-setup.sh" ${post_setup_args[@]+"${post_setup_args[@]}"}

printf '\n✅ install.sh complete\n'
