---
name: copy
description: Copy something to the macOS clipboard via pbcopy, staging the content in a unique temp file so it can be re-copied later. Use when the user asks to copy a URL, command output, file contents, or other text to the clipboard.
args: "[what to copy]"
---

# copy

Copy to clipboard via `pbcopy`.

If no argument, infer the most obvious target from recent conversation — the PR URL you just created, the command output you just showed, the file path you just edited, etc. If genuinely ambiguous, ask.

## Implementation

Always stage the content in a unique temp file via `mktemp`, then pipe that file to `pbcopy`. This way the user can re-copy later with `pbcopy < <path>` if they lose the clipboard, and parallel sessions won't collide.

Pattern: `f=$(mktemp -t copy) && <produce content> > "$f" && pbcopy < "$f" && echo "$f"`

- Literal text: `f=$(mktemp -t copy) && printf %s "..." > "$f" && pbcopy < "$f" && echo "$f"` (no trailing newline)
- File: `f=$(mktemp -t copy) && cp path "$f" && pbcopy < "$f" && echo "$f"`
- Command output: `f=$(mktemp -t copy) && cmd > "$f" && pbcopy < "$f" && echo "$f"`

## After firing

Report in one sentence what you copied plus the re-copy command (e.g. "Copied the PR URL — re-copy with `pbcopy < /tmp/copy.XXXX`"). Don't echo long contents back.
