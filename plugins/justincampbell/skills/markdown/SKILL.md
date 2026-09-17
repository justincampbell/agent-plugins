---
name: markdown
description: Hand off a list to vim for review, then read back the user's edits. Use when the user wants to approve, prune, or annotate a list before you act on it.
args: "[items or topic]"
---

# markdown

Write a markdown list about the given topic, hand it to the user in vim, and act on what comes back.

If no argument, infer from recent conversation — pending decisions, the list we were just discussing, items we were about to act on, or an expanded/annotated version of whatever you were about to produce. Name the topic in one sentence when you hand back the path.

## Steps

1. Write the list to `/tmp/claude-markdown-$(date +%s).md` as plain `- item` bullets. Top line: an HTML comment explaining — kept line = approved, deleted line = rejected, edited line = revised, new line = new item.
2. Tell the user the path and that they can edit with `! vim <path>`, then reply when done.
3. Wait for their confirmation.
4. Read the file back and diff against what you wrote. Summarize deltas (kept / removed / edited / added) in one short line before acting.
