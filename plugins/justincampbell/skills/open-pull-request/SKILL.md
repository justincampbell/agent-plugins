---
name: open-pull-request
context: fork
description: Use when the user requests to create a PR, open a pull request, or submit changes for review.
---

# Open PR

Opens a pull request with proper git workflow conventions.

## Workflow

Follow these steps in order:

### 1. Commit Changes

Check for uncommitted changes:

```bash
git status
```

If there are staged changes that need to be committed:
- Create a concise commit message following the repository's style
- Commit with: `git commit -m "message"`

If there are uncommitted changes, ask the user what they'd like to commit before proceeding.

### 2. Analyze Branch Changes

Run these commands to understand what's in the branch:

```bash
git fetch origin main
git log origin/main..HEAD
git diff origin/main...HEAD --stat
git diff origin/main...HEAD
```

Use this information to draft the PR title and body.

### 3. Rebase from origin/main

Ensure the branch is up-to-date with origin/main (already fetched in step 2):

```bash
git rebase origin/main
```

If there are merge conflicts:
- Inform the user about the conflicts
- Ask how to proceed before attempting resolution

### 4. Push to Remote

Push the branch to origin (use `-u` flag if it's a new branch):

```bash
git push -u origin HEAD
```

### 5. Create Draft PR

Use `gh pr create` with these requirements:

**PR Title:**
- Derive from the user's initial request or context
- If unclear, derive from branch name or changes
- Format: Human-readable, concise description
- Do NOT include ticket/issue IDs if they auto-link from branch name

**PR Body:**

If a `.github/pull_request_template.md` exists in the repo, use it as the body template:
- **Preserve ALL checklist items** — never delete or omit any `- [ ]` lines
- **Preserve section headers** — keep all headers exactly as they appear
- **Preserve structure** — maintain the exact ordering and nesting
- **Fill in the Description section** with 1-2 factual sentences about what changed
- **Check relevant boxes** based on the diff analysis

If no template exists, write a concise body:

```markdown
## Summary
- Brief description of changes

## Test plan
- How to verify the changes work
```

**Tone requirements:**
- NO customer impact statements or marketing language
- NO signature or "Generated with Claude Code" footer
- Just state the facts

#### Example gh Command

```bash
gh pr create --draft --title "Fix authentication timeout on slow connections" --body "$(cat <<'EOF'
## Summary
Fixes authentication timeout on slow connections by increasing the retry window.

## Test plan
- [ ] Verify login works on slow connections
EOF
)"
```

### 6. Open PR in Browser

After creating the PR, open it in the browser:

```bash
gh pr view --web
```

Return only the PR URL. Be succinct — no explanations or additional commentary unless the user asks.

## Common Issues

**Rebase conflicts:** Stop and ask the user how to proceed. Do not attempt automatic resolution without confirmation.

**Missing template:** If the repo has no PR template, use the simple summary format above.
