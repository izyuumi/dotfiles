# Skill Sources

Tracks where the user-level Agent Skills in `~/.agents/skills` came from.

## Sources

| Source | URL | Installed skills | Notes |
| --- | --- | --- | --- |
| Codex First | https://github.com/steipete/agent-scripts/tree/main/skills/codex-first | `codex-first` | Installed from `steipete/agent-scripts`, path `skills/codex-first`. Original file: https://github.com/steipete/agent-scripts/blob/main/skills/codex-first/SKILL.md |
| Matt Pocock Skills | https://github.com/mattpocock/skills | `ask-matt`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `improve-codebase-architecture`, `prototype`, `research`, `setup-matt-pocock-skills`, `tdd`, `teach`, `to-spec`, `to-tickets`, `triage`, `wayfinder`, `writing-great-skills` | Installed from the repo's `.claude-plugin/plugin.json` skill list into `~/.agents/skills`. Client-specific top-level frontmatter fields were moved under `metadata:` so the files validate against the Agent Skills spec. |

## Standard

- Agent Skills overview: https://agentskills.io/home
- Agent Skills specification: https://agentskills.io/specification
- Cross-client user directory convention: `~/.agents/skills`
