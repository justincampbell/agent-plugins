---
name: quiesce
description: Save session knowledge and in-progress state to disk so context can be cleared without losing anything. User-invoked only via /quiesce.
disable-model-invocation: true
---

# quiesce

Capture everything the next session needs to pick up where we left off — then the user can `/clear` without losing the thread.

Two destinations, by lifetime:

- **`CLAUDE.md`** (committed) — durable, project-level knowledge that benefits anyone working in this repo: discovered conventions, gotchas, "always do X here" rules, architectural facts. Only add things that are still true after this session ends.
- **A local-only scratch markdown file** (gitignored) — only when there's in-progress work that would otherwise be lost on `/clear`. Pick a filename that fits the project's conventions (e.g. `SCRATCH.md`, `NOTES.md`, `.claude-scratch.md`, or match an existing pattern in the repo). Don't create one if not needed.

## Steps

### 1. Decide what's worth saving

Review the conversation. Split candidates into three buckets:

- **Durable repo knowledge** → CLAUDE.md (only if non-obvious from reading the code, and likely to come up again).
- **In-progress session state** → scratch file, but only if losing it would meaningfully set the next session back (mid-refactor, half-formed plan, findings not yet in code/PR/issue).
- **Skip** — code is already written, captured in commits/PR/issues, well-named, or covered by existing docs. Don't restate what git history or the diff already says.

If nothing qualifies for either destination, say so and stop — don't write empty files.

### 2. Update CLAUDE.md (if anything qualifies)

If a `CLAUDE.md` exists at the repo root, append new entries under the most appropriate section (or create one). If it doesn't exist, only create it when there's genuinely durable knowledge to capture.

Keep entries terse — a sentence or two each. No fluff.

### 3. Write a scratch file (only if needed)

If — and only if — there's in-progress state worth preserving:

1. Choose a filename. Look at the repo for an existing convention (an existing scratch/notes file, a `.gitignore` entry that suggests one, a CLAUDE.md hint). Otherwise pick something sensible like `SCRATCH.md` at the repo root. Ask the user if unsure.
2. Write a snapshot a fresh-context Claude can resume from. Suggested sections (skip what doesn't apply):

   ```markdown
   # Session state — <ISO date>

   ## Current task
   <one paragraph: what we're doing and why>

   ## Status
   - <what's done>
   - <what's in progress>
   - <what's blocked / open question>

   ## Next steps
   1. <concrete next action>

   ## Notes for next session
   <anything surprising, half-finished thinking, or context not obvious from the diff>
   ```

3. Ensure it's locally gitignored. Prefer `.git/info/exclude` (per-repo local ignore — doesn't touch the committed `.gitignore`):

   ```bash
   grep -qxF '<filename>' .git/info/exclude 2>/dev/null || echo '<filename>' >> .git/info/exclude
   ```

   If not a git repo, skip and mention the file is plain on disk.

### 4. Report

Tell the user, briefly:
- Which files were written/updated (or that nothing needed saving).
- One-line summary of what's captured.
- If a scratch file was written: remind them to point a fresh session at it to resume.

## Notes

- Distill, don't dump. Future-you should be able to skim the scratch file in 30 seconds and know what to do next.
- No secrets, tokens, or sensitive data in either file.
- Don't duplicate what `CLAUDE.md` or existing docs already cover.
