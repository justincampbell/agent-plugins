# Shortcut API Patterns

Advanced API usage for operations not covered by CLI commands.

## Story Links (Dependencies)

Create relationships between stories using the `/story-links` endpoint.

### Link Types

| Verb | Meaning |
|------|---------|
| `blocks` | Subject story blocks object story |
| `duplicates` | Subject story duplicates object story |
| `relates to` | General relationship |

### Create a Story Link

```bash
short api /story-links -X POST \
  -f subject_id=<story-that-blocks> \
  -f object_id=<story-being-blocked> \
  -f verb=blocks
```

Example: Story 100 blocks story 200:
```bash
short api /story-links -X POST -f subject_id=100 -f object_id=200 -f verb=blocks
```

### View Story Links

Story links appear in the `story_links` array when fetching a story:

```bash
short api /stories/<id> | jq '.story_links'
```

Each link contains:
- `subject_id`: Story doing the action
- `object_id`: Story receiving the action
- `verb`: Relationship type
- `type`: "subject" or "object" (perspective of current story)

### Delete a Story Link

```bash
short api /story-links/<link-id> -X DELETE
```

## Story Comments

### Read Comments

```bash
short api /stories/<id>/comments
```

Returns array of comment objects with:
- `text`: Comment content (markdown)
- `author_id`: UUID of commenter
- `created_at`: Timestamp
- `updated_at`: Timestamp

### Add Comment via CLI

Use the story command instead of API:

```bash
short story <id> -c "Comment text"
```

### Add Comment via API

```bash
short api /stories/<id>/comments -X POST -f text="Comment text"
```

## Updating Stories via API

For fields not supported by CLI flags, use PUT:

```bash
short api /stories/<id> -X PUT -f field=value
```

Common fields:
- `name`: Story title
- `description`: Story description
- `story_type`: feature, bug, chore
- `workflow_state_id`: Numeric state ID
- `owner_ids`: Array of owner UUIDs
- `epic_id`: Epic ID
- `iteration_id`: Iteration ID

## Searching via API

For complex searches beyond CLI capabilities:

```bash
short api /search/stories -f query="owner:me state:started"
```

Returns paginated results with `data` array and pagination info.

## Members

Get member details (useful for finding UUIDs):

```bash
# List all members
short members

# Via API
short api /members
```

## Tips

- The `-f` flag passes form data as `key=value`
- Use `-X` to specify HTTP method (GET, POST, PUT, DELETE)
- Pipe to `jq` for JSON formatting: `short api /stories/123 | jq .`
- The CLI adds loading spinners to stderr; redirect if needed
