---
name: local-review
description: Launch a local code review UI (difit) to review the current branch's diff against main, then address pasted review comments.
disable-model-invocation: true
---

# Local Review

Launch a diff review UI for the current branch, then address review feedback.

## Step 1: Launch the review UI

First, check if you already have a background bash task running difit in this session. Use the TaskOutput tool with `block: false` on any existing background task IDs to check. If one is still running, skip launching — tell the user the review UI is already open and they should check their browser.

If no existing difit task is running, launch with `run_in_background` (the server stays running). Wrap with `script -q /dev/null` to provide a pseudo-TTY — difit requires one to use git mode instead of stdin mode.

```bash
script -q /dev/null npx difit --include-untracked --mode unified . $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short))
```

Tell the user the review UI is open. Instruct them to review the diff, add comments, then use the copy button to copy the review prompt.

## Step 2: Address review comments

When the user pastes the review comments:

1. Group related comments into tasks — comments about the same topic, file, or change should be a single task rather than separate ones
2. Create tasks using TaskCreate (subject: short description of the change, description: all related comments with file/line context)
3. Work through tasks in order — mark each `in_progress` before starting, `completed` when done
4. For each task: read the referenced code, make the requested change (or explain why it's unnecessary)
5. After all tasks are complete, give a brief summary of what was addressed

## Reference

See [references/difit.md](references/difit.md) for full difit CLI options and usage examples.
