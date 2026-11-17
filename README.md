# dotfiles

## New Mac setup

```sh
git clone https://github.com/izyuumi/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs three idempotent stages:

1. `setup.sh` installs package managers and packages, applies public-safe
   macOS/app defaults, and links managed files.
2. `chezmoi init/apply` renders per-machine identity and managed templates.
3. `post-setup.sh` installs runtimes/plugins, merges curated application
   settings, and checks manual follow-ups.

Re-run `./install.sh` if a stage stops, for example while waiting on Xcode CLT
or Karabiner permission approval. Pass `--with-trust-store` to also install the
mkcert local CA.

### chezmoi (incremental migration in progress)

`.gitconfig`, Jujutsu identity, and Homebrew packages are managed by
[chezmoi](https://www.chezmoi.io); source state lives in [`home/`](home/) (see
`.chezmoiroot`). Per-machine role, name, email, signing key, and GitHub username
are prompted once at init and remain in the local chezmoi data file:

```sh
chezmoi init --source ~/dotfiles
chezmoi apply
```

Day-to-day: edit files under `home/`, then `chezmoi apply`. Tokens and other
machine-local overrides stay in `~/.gitconfig.local` (never committed).

## Managed configuration

The repository tracks reproducible, public-safe preferences for shells, Git,
JJ, tmux, Neovim, Zed, Karabiner, Ghostty, Docker, NuGet, mise, macOS, and
selected applications. Raw preference stores are not copied: native apps use
allowlisted `defaults write` commands, while Aqua Voice and Screen Studio get
small curated JSON fragments merged into their existing settings without
replacing credentials, history, projects, or account state.

The package manifests install Rectangle Pro, RustDesk, Alcove, Aqua Voice,
Antinote, Screen Studio, and Charmstone. Rex and TinkerTool do not have suitable
Homebrew casks, so install them from their official sources:

- [Rex installation](https://www.superlogical.com/rex/docs/installation)
- [TinkerTool download](https://www.bresink.com/osx/0TinkerTool/download.php)

RustDesk is installed but its configuration is intentionally not migrated: its
files mix UI settings with keys, passwords, peer identities, and network data.
See [Public configuration safety](docs/public-config-safety.md) for the complete
boundary and the pre-push check.

Manual follow-ups after install:

- Add any token-bearing Git overrides to `~/.gitconfig.local`
- Import your GPG private key
- `gh auth login --hostname github.com --git-protocol https`
- `atuin login`
- Configure RustDesk identity, trust, and peers privately
- Launch Aqua Voice and Screen Studio once, quit them, then re-run
  `./post-setup.sh` to merge their curated settings
- After installing Rex or TinkerTool manually, re-run `./setup.sh` to apply
  the reviewed macOS and application defaults
- Sign in to applications whose account state is not tracked
- Optionally `bin/dotfiles-sync-install` on Macs that should pull hourly

Before publishing changes, run `bin/dotfiles-public-check`. `dotfiles-push`
runs it automatically before staging.

## Agent skills

The Git-tracked `.agents/skills` directory is the source of truth for personal
[Agent Skills](https://agentskills.io/specification). `~/.agents/skills` points
to that directory, so Codex and other compatible harnesses see the same skills.
Claude Code receives per-skill links under `~/.claude/skills` because it uses a
client-specific discovery directory.

Run `./post-setup.sh` once to expose the helper as `dotfiles-skills`, or invoke
`bin/dotfiles-skills` directly:

```sh
dotfiles-skills status
dotfiles-skills sync
dotfiles-skills add OWNER/REPO SKILL
dotfiles-skills check
dotfiles-skills update
dotfiles-skills list
```

`add` renders `gh skill preview` before installing into the repository. `sync`
imports skills found only in the live `~/.agents/skills` directory, refuses
differing same-name skills, replaces that directory with the canonical symlink,
and preserves real Claude-owned skill directories when names collide. It does
not create migration backups or modify `~/.codex/skills`.

Upstream provenance for older vendored skills is recorded in
[`.agents/SOURCES.md`](.agents/SOURCES.md). New skills installed with GitHub CLI
carry update metadata in their `SKILL.md` frontmatter and remain reviewable in
Git like any other dotfile change.
