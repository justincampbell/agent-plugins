---
name: agent-review
description: Request a code review from another CLI coding agent (Copilot or Codex). Sends the current branch diff and returns their feedback.
args: "[agent]"
---

# Agent Review

Request a code review from another CLI coding agent.

## Workflow

### 1. Detect available agents

Check which agents are installed:

```bash
which copilot codex 2>/dev/null
```

Build a list of available agents. If none are found, tell the user and stop.

If the user passed an agent name as an argument, use that one. Otherwise:
- If only one agent is available, use it
- If multiple are available, default to `copilot`

### 2. Get the diff

Get the diff of the current branch against origin's default branch:

```bash
git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short))...HEAD
```

Also get a summary of changed files:

```bash
git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short))...HEAD --stat
```

If the diff is empty, tell the user there are no changes to review and stop.

### 3. Send to the agent for review

#### Copilot

Pipe the diff to `copilot` in non-interactive mode:

```bash
git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short))...HEAD | copilot -p "You are a senior code reviewer. Review the following git diff. Be concise and actionable. Focus on: bugs, logic errors, security issues, performance problems, and readability concerns. Skip nitpicks and style preferences. For each issue, reference the file and line. If the code looks good, say so briefly.

Diff:"
```

#### Codex

Pipe the diff to `codex` in quiet/non-interactive mode:

```bash
git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short))...HEAD | codex --quiet -p "You are a senior code reviewer. Review the following git diff. Be concise and actionable. Focus on: bugs, logic errors, security issues, performance problems, and readability concerns. Skip nitpicks and style preferences. For each issue, reference the file and line. If the code looks good, say so briefly.

Diff:"
```

Run the command and capture the output.

### 4. Present the review

Display the agent's review feedback to the user. Prefix it with which agent provided the review (e.g. "**Copilot review:**").

Then ask: would you like to address any of this feedback?

### 5. Address feedback (if requested)

If the user wants to address the feedback:

1. Group related items into tasks
2. Create tasks using TaskCreate
3. Work through each task — read the referenced code, make the change
4. After all tasks are complete, summarize what was addressed
