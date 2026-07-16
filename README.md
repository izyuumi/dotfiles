# dotfiles

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
