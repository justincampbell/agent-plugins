---
name: issues
description: Manage GitHub issues. Use "create" to record an idea, bug, or thought. Use "start" to begin work on an issue (finds the best next one if none specified).
---

## Subcommands

Parse the user's invocation to determine the subcommand: `create` or `start`.

---

## create

Record an idea, bug, or thought as a GitHub issue.

### Steps

1. If the user provided a description, use it. Otherwise ask: "What's the idea or issue?"

2. Draft a concise issue title and body from the description. Keep it brief — no padding or fluff.

3. Create the issue:

```bash
gh issue create --title "Title here" --body "Body here"
```

4. Output only the issue URL.

---

## start

Begin work on a GitHub issue.

### Steps

1. If the user specified an issue number, use it. Otherwise find the best next issue:

```bash
gh issue list --limit 20 --json number,title,labels,createdAt
```

Pick the most actionable open issue (prefer bugs over enhancements, older over newer).

2. Show the user which issue was selected (number + title).

3. Create and switch to a branch named after the issue:

```bash
git checkout -b issue-<number>-<slugified-title>
```

4. Assign the issue to yourself and mark it as in-progress if the repo uses labels:

```bash
gh issue edit <number> --add-assignee @me
```

5. Output the issue URL.

6. Fetch the full issue details and begin working on it:

```bash
gh issue view <number>
```

Read the issue title, body, and any comments. Then immediately start implementing the work — read relevant files, make changes, run tests. Do not wait for further instructions.
