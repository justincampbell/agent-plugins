# difit Reference

A lightweight Git diff viewer with a GitHub-like interface. Runs a local web server and opens a browser.

## Usage

```
npx difit [options] [commit-ish] [compare-with]
```

## Arguments

- `commit-ish` — Git commit, tag, branch, `HEAD~n`, or special values: `working`, `staged`, `.` (default: `HEAD`)
  - `.` is shorthand for staged + working directory changes
- `compare-with` — Compare with this commit/branch (shows diff between commit-ish and compare-with)

## Options

| Flag | Description |
|---|---|
| `--mode <mode>` | `split` (default) or `unified` |
| `--include-untracked` | Include untracked files in diff |
| `--port <port>` | Preferred port (auto-assigned if busy) |
| `--host <host>` | Host address to bind |
| `--no-open` | Don't auto-open browser |
| `--tui` | Terminal UI instead of web |
| `--pr <url>` | Review a GitHub PR by URL |
| `--clean` | Clear all existing comments |

## Common Invocations

```bash
# Working directory + staged + untracked changes
npx difit --include-untracked --mode unified .

# Everything on this branch vs main
npx difit --include-untracked --mode unified . $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short))

# Review a GitHub PR
npx difit --pr https://github.com/owner/repo/pull/123
```

## Environment Notes

- Requires a TTY to use git mode. Without one, it falls back to reading diff from stdin.
- In Claude Code's Bash tool (no TTY), wrap with `script -q /dev/null` to provide a pseudo-TTY.
- The server stays running until stopped — use `run_in_background` when launching from Claude.
- Auto-selects next available port if preferred port is busy.
