# Public configuration safety

This is a public bootstrap repository, not a backup of the current Mac. Track
only settings that are reproducible and safe for every clone.

## What belongs here

- Plain configuration with no account, device, network, or identity data.
- Identity templates whose values are supplied locally by chezmoi.
- Explicit `defaults write` allowlists for native applications.
- Small JSON fragments merged into existing settings without deleting unknown
  keys.

Do not commit raw preference plists or whole application-support directories.
They commonly mix useful preferences with licenses, tokens, device identifiers,
recent paths, window state, histories, and user content.

## Application boundaries

- Rectangle Pro, Rex, Alcove, Antinote, and Charmstone use allowlisted native
  defaults. License, account, device, display, session, and updater state is
  excluded.
- Aqua Voice and Screen Studio use curated JSON fragments. The merge helper
  preserves credentials, histories, dictionaries, custom instructions,
  recordings, projects, and account/device state already in the live files.
- TinkerTool changes are represented as reviewed macOS defaults, not by copying
  its preference backup.
- RustDesk is install-only. Its local files contain keys, passwords, access
  tokens, device identity, peers, hostnames, addresses, and connection history.

## Always excluded

- SSH/GPG keys, Keychain material, tokens, passwords, OAuth files, and auth
  receipts.
- GitHub CLI, Copilot, Tailscale, OpenCode service, and OpenClaw credentials.
- Shell/assistant histories, databases, caches, logs, recent items, application
  content, recordings, and project state.
- Absolute personal paths, private network details, device IDs, license data,
  and private account identifiers. Public repository coordinates and project
  attribution are allowed where the bootstrap requires them.

Run `bin/dotfiles-public-check` before publishing. It rejects known private
paths and runs Gitleaks with output redaction over both the working tree and all
Git history. `bin/dotfiles-push` invokes it automatically.

Removing personal information from the current tree does not remove it from old
commits or commit metadata. Strict historical removal requires a separately
planned history rewrite and force-push, coordinated with every clone of the
repository.
