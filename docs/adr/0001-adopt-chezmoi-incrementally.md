# ADR-0001: Adopt chezmoi incrementally for multi-machine divergence

Date: 2026-07-17
Status: Accepted

## Context

The dotfiles repo manages 4 Macs with a hand-rolled symlink model
(`setup.sh` + `lib/link.sh`): every machine gets byte-identical files, and
per-machine differences are pushed into untracked `*.local` side files.
Divergence across the fleet became meaningful — different git identities,
different package sets, machine-specific settings inside managed files —
and the `.local` escape hatches were straining. The live `~/.gitconfig` on
the primary Mac had silently drifted from the repo copy (inline email, a
plaintext GitHub token, a different excludesfile), proving the symlink
model was already failing to manage this class of file.

## Decision

Adopt [chezmoi](https://www.chezmoi.io), incrementally by file cohort:

- Source state lives in `home/` inside this repo (`.chezmoiroot`), so
  `bin/`, `tests/`, `lib/`, and the setup scripts coexist untouched during
  the transition. `chezmoi init --source ~/dotfiles` on each machine.
- Machine identity is prompted once per machine at init
  (`home/.chezmoi.toml.tmpl`): `role` (work/personal), git `email`,
  `signingkey`. Templates branch on `.role`.
- The Brewfile (`home/.chezmoitemplates/Brewfile`) is a **snapshot of a
  real machine**, not an aspirational list. brew.sh's accumulated list
  contained three entries that broke fresh installs (gogcli removed
  upstream, macstral never existed, fuse-t's tap never declared). Fleet
  machines contribute their real states to role sections as they migrate.
- Package installs are install-only (`HOMEBREW_BUNDLE_NO_UPGRADE`),
  matching the previous brew.sh semantics.
- Secrets never enter source state: `~/.gitconfig.local` (machine-local,
  mode 600) holds tokens via the `[include]` seam in the managed
  `.gitconfig`.
- Day-to-day edits happen in `home/` in this repo, then `chezmoi apply`.
- The hourly launchd sync keeps its opt-in plumbing; its core swaps from
  `git pull` to `chezmoi update` once the fleet migrates (phase 5).

Migration phases: (1) `.gitconfig` + packages on the primary Mac — done;
(2) shell rc + `.config` cohort; (3) setup scripts → `run_once_`/
`run_onchange_`/`modify_` scripts; (4) fleet init; (5) retire the symlink
machinery (`lib/link.sh`, setup.sh link section, `.gitignore_global`).

## Alternatives rejected

- **Stay symlink-only**: cannot express per-machine values inside managed
  files; divergence keeps leaking into untracked `.local` files.
- **Big-bang migration**: one giant cutover risks every machine's shell at
  once; incremental cohorts are individually verifiable and reversible.
- **Hybrid forever** (chezmoi for divergent files, symlinks for the rest):
  two permanent answers to "how does a file reach $HOME".
- **Default source dir** (`~/.local/share/chezmoi`): would orphan the
  existing repo location, helpers, and muscle memory; `.chezmoiroot`
  gives the same layout benefits in place.

## Consequences

- During phases 1-3, fleet Macs still pull rc files that must work
  without chezmoi: `.zshenv`/`.profile` fall back to
  `~/dotfiles/shell/paths.sh` when `~/.config/shell/paths.sh` is not yet
  linked.
- The repo's root `.gitconfig` stays (unlinked from setup.sh) until phase
  4, because fleet machines may still symlink it.
- `brew.sh` remains for un-migrated machines and is retired in phase 3.
