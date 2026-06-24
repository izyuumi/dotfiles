#!/bin/bash

set -euo pipefail

current="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

with_trust_store=false

for arg in "$@"; do
  case "$arg" in
    --with-trust-store)
      with_trust_store=true
      ;;
    -h | --help)
      cat <<'USAGE'
Usage: ./post-setup.sh [--with-trust-store]

Run after ./setup.sh or ./brew.sh on a new Mac.

Options:
  --with-trust-store  Run mkcert -install for the local development CA.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

log() {
  printf '\n==> %s\n' "$1"
}

ok() {
  printf '  ok: %s\n' "$1"
}

warn() {
  printf '  ! %s\n' "$1" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

ensure_macos() {
  log "Checking macOS environment"

  if [ "$(uname -s)" != "Darwin" ]; then
    warn "This script is intended for macOS"
    exit 1
  fi

  ok "Running on macOS"
}

load_shell_paths() {
  log "Loading post-bootstrap PATH"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ok "Loaded Homebrew from /opt/homebrew"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    ok "Loaded Homebrew from /usr/local"
  else
    warn "Homebrew is not available; run ./brew.sh first"
  fi

  if [ -r "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
    ok "Loaded Cargo environment"
  fi

  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
}

require_after_brew() {
  local missing=0
  local tool

  log "Checking required CLI tools"

  for tool in brew git git-lfs mise; do
    if have "$tool"; then
      ok "$tool found"
    else
      warn "$tool missing"
      missing=1
    fi
  done

  if [ "$missing" -ne 0 ]; then
    warn "Run ./setup.sh or ./brew.sh, then re-run ./post-setup.sh"
    exit 1
  fi
}

check_cli_dependencies() {
  local llvm_prefix
  local tool

  log "Checking formatter and LSP CLI dependencies"

  for tool in usage prettierd shfmt stylua; do
    if have "$tool"; then
      ok "$tool found"
    else
      warn "$tool missing; run ./brew.sh after pulling the latest package list"
    fi
  done

  if have clangd; then
    ok "clangd found"
  elif have brew && llvm_prefix="$(brew --prefix llvm 2>/dev/null)" && [ -x "$llvm_prefix/bin/clangd" ]; then
    ensure_link "$llvm_prefix/bin/clangd" "$HOME/.local/bin/clangd"
  else
    warn "clangd missing; run ./brew.sh after pulling the latest package list"
  fi
}

ensure_link() {
  local src="$1"
  local dest="$2"
  local backup

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    ok "Already linked $dest"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="${dest}.backup.$(date +%Y%m%d-%H%M%S)"
    mv "$dest" "$backup"
    warn "Moved existing $dest to $backup"
  fi

  ln -s "$src" "$dest"
  ok "Linked $dest"
}

setup_repo_helpers() {
  local helper

  log "Linking dotfiles helper commands"

  mkdir -p "$HOME/.local/bin"

  for helper in "$current"/bin/dotfiles-*; do
    [ -e "$helper" ] || continue
    ensure_link "$helper" "$HOME/.local/bin/$(basename "$helper")"
  done
}

setup_completions() {
  log "Setting up shell completions"

  ensure_link "$current/.zsh/completions/_mise" "$HOME/.zsh/completions/_mise"

  if have docker; then
    mkdir -p "$HOME/.docker/completions"
    docker completion zsh > "$HOME/.docker/completions/_docker"
    ok "Generated Docker zsh completions"
  else
    warn "docker missing; skipping Docker completions"
  fi
}

setup_git_tools() {
  log "Setting up Git CLI tools"

  git lfs install --skip-repo
  ok "Git LFS global filters installed"

  if have gh && gh auth status --hostname github.com >/dev/null 2>&1; then
    ok "GitHub CLI authenticated"
  else
    warn "Run: gh auth login --hostname github.com --git-protocol https"
  fi
}

setup_tmux_plugins() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  log "Setting up tmux plugins"

  if ! have tmux; then
    warn "tmux missing; skipping TPM setup"
    return 0
  fi

  mkdir -p "$HOME/.tmux/plugins"

  if [ ! -d "$tpm_dir/.git" ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    ok "Installed TPM"
  else
    git -C "$tpm_dir" pull --ff-only
    ok "TPM already installed"
  fi

  if [ -x "$tpm_dir/bin/install_plugins" ]; then
    TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" "$tpm_dir/bin/install_plugins"
    ok "tmux plugins installed"
  else
    warn "TPM install script missing at $tpm_dir/bin/install_plugins"
  fi
}

setup_gpg() {
  local agent_conf
  local pinentry
  local pinentry_line

  log "Setting up GPG signing support"

  if ! have gpg; then
    warn "gpg missing; run ./brew.sh after pulling the latest brew package list"
    return 0
  fi

  if ! have pinentry-mac; then
    warn "pinentry-mac missing; run ./brew.sh"
    return 0
  fi

  pinentry="$(command -v pinentry-mac)"
  pinentry_line="pinentry-program $pinentry"
  agent_conf="$HOME/.gnupg/gpg-agent.conf"

  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  touch "$agent_conf"
  chmod 600 "$agent_conf"

  if grep -Fxq "$pinentry_line" "$agent_conf"; then
    ok "GPG agent already uses pinentry-mac"
  elif grep -q '^pinentry-program ' "$agent_conf"; then
    warn "$agent_conf already has a pinentry-program; leaving it unchanged"
  else
    printf '%s\n' "$pinentry_line" >> "$agent_conf"
    ok "Configured GPG agent to use pinentry-mac"
  fi

  gpgconf --reload gpg-agent >/dev/null 2>&1 || true
}

install_mise_tools() {
  log "Installing mise-managed runtimes and npm tools"

  mise install --yes
  if mise help reshim >/dev/null 2>&1; then
    mise reshim
  fi
  ok "mise tools installed"
}

setup_neovim() {
  local packer_dir

  log "Setting up Neovim plugins"

  if ! have nvim; then
    warn "nvim missing; skipping Neovim plugin setup"
    return 0
  fi

  packer_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/packer/start/packer.nvim"

  if [ ! -d "$packer_dir" ]; then
    mkdir -p "$(dirname "$packer_dir")"
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_dir"
    ok "Installed packer.nvim"
  else
    ok "packer.nvim already installed"
  fi

  nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
  ok "Neovim plugins synced"
}

setup_atuin() {
  log "Checking Atuin sync"

  if ! have atuin; then
    warn "atuin missing; skipping"
    return 0
  fi

  if atuin status >/dev/null 2>&1; then
    atuin sync
    ok "Atuin synced"
  else
    warn "Run: atuin login && atuin sync"
  fi
}

setup_mkcert() {
  log "Checking mkcert"

  if ! have mkcert; then
    warn "mkcert missing; skipping"
    return 0
  fi

  if [ "$with_trust_store" = true ]; then
    mkcert -install
    ok "mkcert local CA installed"
  else
    warn "Run './post-setup.sh --with-trust-store' to install the mkcert local CA"
  fi
}

print_manual_steps() {
  log "Manual follow-up"

  if [ ! -f "$HOME/.gitconfig.local" ]; then
    warn "Create ~/.gitconfig.local with your private Git email"
  fi

  warn "Import your GPG private key if this Mac cannot sign commits yet"
  warn "Run bin/dotfiles-sync-install only on Macs where you want hourly pull-only sync"
  ok "Post-setup checks complete"
}

ensure_macos
load_shell_paths
require_after_brew
setup_repo_helpers
setup_completions
check_cli_dependencies
setup_git_tools
setup_tmux_plugins
setup_gpg
install_mise_tools
setup_neovim
setup_atuin
setup_mkcert
print_manual_steps
