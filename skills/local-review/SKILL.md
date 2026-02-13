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

When the user pastes the review comments, address each concern:

1. Read each comment and the referenced code
2. Make the requested changes (or explain why a change is unnecessary)
3. Summarize what was addressed

## Reference

See [references/difit.md](references/difit.md) for full difit CLI options and usage examples.
