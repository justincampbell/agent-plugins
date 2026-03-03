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

### 3. Create the new pane or window

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

### 4. Start the forked conversation

Build the command:

```
claude --continue --fork-session
```

Append `--permission-mode <mode>` if one was detected in step 2.

Send the command to the new pane/window using `mcp__tmux__execute-command` if available, otherwise:

```bash
tmux send-keys -t {new_pane_id} 'claude --continue --fork-session' Enter
```

### 5. Report

Tell the user the fork is running in the new pane/window. Be succinct.
