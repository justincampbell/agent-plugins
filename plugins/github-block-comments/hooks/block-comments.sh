#!/usr/bin/env bash
# PreToolUse hook for Bash commands.
# Blocks unsolicited GitHub comments/reviews via gh CLI or GraphQL.
# Allowlist runs first — commands matching ALLOW_PATTERNS pass through.

set -euo pipefail

ALLOW_PATTERNS=(
  "--body[[:space:]]+[\"']@greptileai( review| re-review please| ♻️)?[\"']"
  "body=[\"']@greptileai( review| re-review please| ♻️)?[\"']"
)

PATTERNS=(
  'gh[[:space:]]+(issue|pr)[[:space:]]+comment[[:space:]]'
  'gh[[:space:]]+api[[:space:]].*pulls/.*/comments.*(-f[[:space:]]+body=|--input[[:space:]])'
  'gh[[:space:]]+api[[:space:]].*pulls/.*/reviews[[:space:]].*(-f[[:space:]]+body=".+"|--input[[:space:]])'
  'gh[[:space:]]+pr[[:space:]]+(close|merge)[[:space:]].*(--comment-body|--comment)[[:space:]]'
  'gh[[:space:]]+pr[[:space:]]+review[[:space:]].*(--body-file|--body)[[:space:]]'
  'minimizeComment'
  '(addComment|addPullRequestReview[A-Za-z]*|submitPullRequestReview)[[:space:]]*\('
)

REASONS=(
  "gh issue/pr comment (unsolicited comment)"
  "gh api PR comment/reply (unsolicited PR comment)"
  "gh api PR review with non-empty body"
  "gh pr close/merge with --comment (unsolicited comment)"
  "gh pr review with --body/--body-file (unsolicited PR comment)"
  "minimizeComment hides comments — use resolveReviewThread to resolve PR feedback"
  "GraphQL comment/review mutation (unsolicited PR/issue comment)"
)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

for pattern in "${ALLOW_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE -e "$pattern"; then
    exit 0
  fi
done

for i in "${!PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "${PATTERNS[$i]}"; then
    echo "{\"decision\": \"block\", \"reason\": \"${REASONS[$i]}\"}"
    exit 0
  fi
done

exit 0
