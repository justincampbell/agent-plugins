#!/usr/bin/env bash
# PreToolUse hook for Bash commands.
# Blocks inline Python (python -c / python - <<EOF / python <<EOF) that writes
# files. Editing via Python scripts is error-prone and loses the anchoring that
# the Read/Edit/Write tools provide. Running a real script file (python foo.py)
# and read-only inline Python (parsing JSON, printing) are allowed.

set -euo pipefail

INLINE_PYTHON='(^|[^A-Za-z0-9_./-])python[0-9.]*[[:space:]]+(-[a-zA-Z]*c[[:space:]]|-[[:space:]]*<<|<<|-[[:space:]])'

WRITE_PATTERNS=(
  "open\([^)]*['\"]([wax]|r\+)[bt+]*['\"]"
  "open\([^)]*mode[[:space:]]*=[[:space:]]*['\"]([wax]|r\+)"
  "\.write_(text|bytes)\("
  "\.writelines\("
  "\.write\("
  "os\.(replace|rename)\("
  "shutil\.(copy|copyfile|copy2|move)\("
)

REASON="Inline Python that writes files is blocked. Never edit files via Python scripts (or sed/regex rewrites); use the Read/Edit/Write tools, which anchor changes to the file's actual current content."

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

if ! echo "$COMMAND" | grep -qE "$INLINE_PYTHON"; then
  exit 0
fi

# Writing to stdout/stderr is fine.
STRIPPED=$(echo "$COMMAND" | sed -E 's/sys\.(stdout|stderr)\.write\(//g')

for pattern in "${WRITE_PATTERNS[@]}"; do
  if echo "$STRIPPED" | grep -qE "$pattern"; then
    echo "{\"decision\": \"block\", \"reason\": \"$REASON\"}"
    exit 0
  fi
done

exit 0
