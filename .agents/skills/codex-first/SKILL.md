---
name: codex-first
description: "Route implementation work to Codex CLI; Claude specs, reviews, verifies."
---

# Codex First

Claude Code sessions only. Codex/other harnesses: skip; never self-delegate.

Rationale: Claude (Fable/Opus) tokens metered + expensive; Codex flat-rate. GPT-6 (Astra/Sol/Luna) is usually the better and faster model at writing/implementing code; Claude wins at ergonomics — judgment, design, spec-writing, review, orchestration. So Codex types, Claude thinks and verifies.

## Route

Delegate to Codex (default for hands-on work):

- implementation from a frozen spec; refactors; mechanical migrations
- bug fixes with known repro; test writing; coverage fills
- CI fixes, dependency bumps, scripts/tooling
- bulk codebase exploration where raw reading ≫ the answer

Keep in Claude:

- design, API design, architecture, naming, UX judgment
- tasks where writing the spec IS the work (ambiguity = design)
- tiny edits (~<20 lines, single obvious change) — delegation overhead loses
- anything needing session tools: MCP (browser/computer-use/chronicle), 1Password, secrets
- destructive/irreversible ops, releases, pushes, GitHub mutations — Claude-side per git rules
- review of Codex output — never delegated, never skipped

Mixed task: Claude designs first, freezes spec, delegates build-out.
Heuristic: prompt reads as a work order → delegate; writing it forces decisions → design, Claude.
Portfolio/multi-repo work: `$maintainer-orchestrator` instead.

## Model pick (GPT-6 series)

- `gpt-6-sol` — default for delegation: implementation, refactors, bug fixes, tests. Workhorse; `~/.codex/config.toml` default.
- `gpt-6-astra` — frontier; escalate only: hard bugs, gnarly refactors, or after Sol fails a round. Costs more usage, fast mode included.
- `gpt-6-luna` — fastest/cheapest: bulk exploration, mechanical migrations, scripts, dep bumps.

No Terra in GPT-6. Omit `-m` for Sol; pass `-m <slug>` on `codex exec` for Astra or Luna.

## Invoke

Prompt via temp file, never inline quoting:

```bash
P=$(mktemp); cat >"$P" <<'EOF'
<goal, repo + key paths, constraints ("don't touch X"), non-goals, proof expected, output shape>
EOF
command codex exec --yolo -C <repo> \
  --enable fast_mode \
  -c 'service_tier="fast"' \
  -c model_reasoning_effort="high" \
  -o /tmp/codex-last.md - <"$P" 2>/dev/null
```

- `--yolo` is the house default; Codex may run commands/tests freely. Keep prompts scoped to the target repo.
- Fast mode is mandatory for every delegated Codex command, including fresh runs, resumes, and any additional invocation added later. Always pass both `--enable fast_mode` and `-c 'service_tier="fast"'`; never rely on inherited config. Fast mode trades higher credit consumption for lower latency and requires ChatGPT sign-in plus a supported model.
- `command codex` bypasses the interactive zsh wrapper; if not on PATH: `fnm exec --using default -- codex`
- stderr suppressed (thinking noise bloats context); drop `2>/dev/null` only to debug a failing run
- read `-o` file for the result; don't parse the JSONL stream
- long runs: Bash run_in_background, read `-o` file on exit; don't kill quiet runs <30 min
- parallel independent tasks OK: separate repos/dirs, separate `-o` files
- outside a git repo add `--skip-git-repo-check`

Follow-up fixes — cheaper than fresh runs, keeps context. `resume` has no `-C`/`--yolo`: run from the repo dir, spell the long flag:

```bash
(cd <repo> && command codex exec resume --last \
  --dangerously-bypass-approvals-and-sandbox \
  --enable fast_mode \
  -c 'service_tier="fast"' \
  -o /tmp/codex-last.md - <"$P2" 2>/dev/null)
```

## Prompt contract

Codex starts with zero session context. Every prompt: goal, exact repo/paths, constraints, non-goals, proof expected (exact test command), output shape ("report files changed + test output"). Spec quality decides success.

For substantial parallelizable work, also require: use the maximum available sub-agent concurrency; partition work by independently owned deliverables; keep freed capacity working on the next ready workstream; avoid search-only agents; preserve the frozen spec; report ownership and verification evidence for every stream.

## Sub-agent saturation

Keep every useful sub-agent slot occupied until no independent work remains. Give each agent a substantial, self-contained responsibility, such as bounded research that produces a decision, implementation with focused tests, test development with failure analysis, or implementation-level review with concrete fixes. Never create agents merely to search or summarize; their investigation must lead to an artifact, verified result, or actionable recommendation.

As soon as an agent finishes, assign its slot the next unblocked workstream. Partition file and component ownership to prevent overlapping edits, and let the lead Codex run integrate the results. Planning inside a frozen spec and implementation-level peer review may be delegated, but Claude retains architecture, API, naming, and UX decisions plus the final review and verification.

## Verify (Claude, always)

- `git status -sb` + read the full diff; judge like a contributor PR
- run focused tests yourself or demand proof output; Codex claims are advisory
- iterate via resume; after 2 failed rounds, take over and do it directly
- normal closeout still applies: `$autoreview` before ship

## Economics

Win = generation + exploration tokens moved to Codex; Claude spends only on spec + diff review. Don't ping-pong trivia through delegation; don't re-read what Codex already summarized.
