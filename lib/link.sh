# shellcheck shell=bash
# lib/link.sh — shared symlink helpers for setup.sh and post-setup.sh.
#
# Source this file; do not execute it. Conflicting files are moved to a
# single per-run backup directory under ~/.dotfiles-backup/<timestamp>/.

backup_dir=""

backup_if_needed() {
  if [ -z "$backup_dir" ]; then
    backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
  fi
}

link_item() {
  local src="$1"
  local dest="$2"
  local dest_dir

  if [ ! -e "$src" ]; then
    echo "  ! Skipped missing $(basename "$src")"
    return 0
  fi

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "  ✓ Already linked $(basename "$dest")"
      return 0
    fi
    backup_if_needed
    mv "$dest" "$backup_dir/"
  elif [ -e "$dest" ]; then
    backup_if_needed
    mv "$dest" "$backup_dir/"
  fi

  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  ln -s "$src" "$dest"
  echo "  ✓ Linked $(basename "$dest")"
}

ensure_real_directory() {
  local dir="$1"
  local temp_dir

  if [ -L "$dir" ] && [ -d "$dir" ]; then
    temp_dir="$(mktemp -d)"
    cp -R "$dir/." "$temp_dir/" 2>/dev/null || true
    rm "$dir"
    mkdir -p "$dir"
    cp -R "$temp_dir/." "$dir/" 2>/dev/null || true
    rm -rf "$temp_dir"
    echo "  ✓ Migrated $(basename "$dir") to a real directory"
    return 0
  fi

  mkdir -p "$dir"
}
