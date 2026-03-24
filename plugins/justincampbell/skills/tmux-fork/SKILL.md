---
name: tmux-fork
description: Fork the current Claude Code conversation into a new tmux pane or window, keeping both running side-by-side.
args: "[window]"
---

# tmux-fork

Fork the current conversation into a new tmux pane (or window if `window` argument is passed).

## Workflow

### 1. Verify tmux environment

Check that we're inside tmux by reading the `$TMUX_PANE` environment variable:

```bash
echo $TMUX_PANE
```

If `$TMUX_PANE` is empty, inform the user they need to be in a tmux session and stop.

### 2. Detect permission mode

Check if the current Claude process was started with `--permission-mode`:

```bash
ps -o args= -p $PPID 2>/dev/null || true
```

If the output contains `--permission-mode`, extract the value (e.g. `--permission-mode plan`) to pass through to the forked session.

### 3. Determine current session ID

Find the most recently modified `.jsonl` file in the Claude project directory for the current working directory. The project directory path is derived by replacing all non-alphanumeric characters in `$PWD` with `-`.

```bash
project_dir=~/.claude/projects/$(echo "$PWD" | sed 's/[^a-zA-Z0-9]/-/g')
ls -t "$project_dir"/*.jsonl | head -1 | xargs basename | sed 's/.jsonl//'
```

Store this UUID as the session ID to fork from.

### 4. Create the new pane or window

**If the user passed `window` as an argument:**

Use `mcp__tmux__create-window` if the tmux MCP tools are available, otherwise fall back to bash:

```bash
tmux new-window
```

**Otherwise (default — split pane):**

Use `mcp__tmux__split-pane` with horizontal direction on the current pane if the tmux MCP tools are available, otherwise fall back to bash:

```bash
tmux split-window -h
```

### 5. Start the forked conversation

Build the command:

```
claude --resume <session-id> --fork-session
```

Where `<session-id>` is the UUID determined in step 3.

Append `--permission-mode <mode>` if one was detected in step 2.

Send the command to the new pane/window using `mcp__tmux__execute-command` if available, otherwise:

```bash
tmux send-keys -t {new_pane_id} 'claude --resume <session-id> --fork-session' Enter
```

### 6. Report

Tell the user the fork is running in the new pane/window. Be succinct.
