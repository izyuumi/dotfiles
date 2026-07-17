# dotfiles

## New Mac setup

```sh
git clone https://github.com/izyuumi/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs `./setup.sh` (Xcode CLT check, Rust and Homebrew packages,
macOS defaults, symlinks) and then `./post-setup.sh` (mise runtimes, Codex
config merge, tmux plugins, GPG, completions). Both steps are idempotent —
re-run `./install.sh` if a step stops, e.g. while waiting on the Xcode CLT
installer or Karabiner permission approvals. Pass `--with-trust-store` to
also install the mkcert local CA.

### chezmoi (incremental migration in progress)

`.gitconfig` and Homebrew packages are managed by [chezmoi](https://www.chezmoi.io);
source state lives in [`home/`](home/) (see `.chezmoiroot`). Per-machine
identity (role, git email, signing key) is prompted once at init:

```sh
chezmoi init --source ~/dotfiles
chezmoi apply
```

Day-to-day: edit files under `home/`, then `chezmoi apply`. Machine-local
secrets stay in `~/.gitconfig.local` (never committed).

Manual follow-ups after install:

- Create `~/.gitconfig.local` with your private Git email
- Import your GPG private key
- `gh auth login --hostname github.com --git-protocol https`
- `atuin login`
- Optionally `bin/dotfiles-sync-install` on Macs that should pull hourly

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
