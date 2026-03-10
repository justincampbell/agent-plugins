---
name: shortcut
context: fork
description: Work with Shortcut stories via the `short` CLI. Use when the user wants to view, create, or update Shortcut stories, assign owners, change workflow states, link dependencies, or query epics and objectives.
---

# Shortcut CLI

Work with Shortcut project management via the `short` command line tool.

## Installation Check

**IMPORTANT**: Before using any `short` commands, verify the CLI is installed:

```bash
short --version
```

If not installed or the command fails, guide the user to install:

### Installation Steps

1. Install via npm:
   ```bash
   npm install @shortcut-cli/shortcut-cli -g
   ```

2. Configure API access:
   ```bash
   short install
   ```
   This will prompt for authentication setup.

**GitHub repo**: https://github.com/shortcut-cli/shortcut-cli

## Quick Reference

```bash
# View story
short story <id>

# Update state
short story <id> -s "In Development"

# Assign owner (use Shortcut mention name)
short story <id> -o <mention-name>

# Add comment
short story <id> -c "Comment text"

# Create story
short create -t "Title" -T <team> -s <state>

# Search stories
short search <query>
short search owner:%self%           # Your stories
short search is:blocked             # Blocked stories

# Open in browser
short story <id> -O
```

## Workflow States

To list all workflows and their states:

```bash
short workflows
```

Use the exact state name when updating: `short story <id> -s "State Name"`

## Creating Stories

Required: title (`-t`) and either team (`-T`) + state (`-s`) or project (`-p`).

**IMPORTANT**: Team names must use the full name as shown in Shortcut (e.g., `"Team Engineering"`, not `"Engineering"`). The `-T` flag does a prefix match and may match the wrong team if shortened.

### Determining the user's team

When creating a story, **always look up the user's team dynamically** rather than guessing or using a default. To find the user's team:

1. Get the user's member ID: `short api /member` → look for `"id"`
2. Get all groups: `short api /groups` → find the group whose `member_ids` contains the user's member ID
3. Use that group's `name` as the `-T` value

If the user belongs to multiple groups, determine the most likely team by searching their recent stories (`short search owner:%self%`) and checking which team appears most frequently. Use that team as the default. Cache the result for the rest of the conversation.

```bash
# With team and state
short create -t "Story title" -T "Team Engineering" -s "Ready for Development"

# With project
short create -t "Story title" -p "Project Name"

# Full example with owner
short create -t "Fix login bug" -T "Team Engineering" -s "In Development" -o myuser -y bug
```

Options:
- `-t` title (required)
- `-T` team name (only available at creation — cannot be changed via `short story`)
- `-s` workflow state
- `-p` project
- `-o` owner(s), comma-separated
- `-y` type: feature (default), bug, chore
- `-d` description
- `-e` estimate
- `--epic` epic id or name
- `-l` label

## Updating Stories

The `short story <id>` command supports updating most fields but **not team**. To change a story's team after creation, use the API directly:

```bash
# Change team via API (requires team UUID)
curl -s -X PUT \
  -H "Content-Type: application/json" \
  -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
  "https://api.app.shortcut.com/api/v3/stories/<id>" \
  -d '{"group_id":"<team-uuid>"}'
```

Available update flags for `short story`:
- `-s` workflow state
- `-o` owner(s)
- `-t` title
- `-d` description
- `-y` type
- `-e` estimate
- `-c` comment
- `-l` label
- `--epic` epic
- `-i` iteration
- `-a` archived

## Search

```bash
short search <operators>

# By owner
short search owner:myuser
short search owner:%self%           # Current user

# By state
short search state:"In Development"
short search is:blocked
short search is:started
short search is:done

# By epic/label
short search epic:"Epic Name"
short search label:"Label Name"

# Combined
short search owner:%self% state:"In Development"
```

See [Search Operators](https://help.shortcut.com/hc/en-us/articles/360000046646-Search-Operators) for full documentation.

## Epics

```bash
# List all epics
short epics

# Filter by title
short epics -t "Epic Name"

# Get epic details via API
short api /epics/<id>
```

## Objectives (Milestones)

Shortcut calls these "milestones" in the API:

```bash
# List objectives
short api /objectives

# Get specific objective
short api /objectives/<id>
```

## Story Dependencies and Comments

See [references/api-patterns.md](references/api-patterns.md) for:
- Creating story links (blocks, duplicates, relates to)
- Reading story comments
- Batch API operations
