#!/usr/bin/env bash
# Tests for block-comments.sh hook

set -uo pipefail

HOOK="$(dirname "$0")/../hooks/block-comments.sh"
PASS=0
FAIL=0

assert_ask() {
  local desc="$1"
  local command="$2"
  local output
  output=$(echo "{\"tool_input\":{\"command\":$(echo "$command" | jq -Rs .)}}" | bash "$HOOK")
  if echo "$output" | grep -q '"block"'; then
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (expected ask, got: '$output')"
    FAIL=$((FAIL + 1))
  fi
}

assert_allow() {
  local desc="$1"
  local command="$2"
  local output
  output=$(echo "{\"tool_input\":{\"command\":$(echo "$command" | jq -Rs .)}}" | bash "$HOOK")
  if [[ -z "$output" ]]; then
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (expected allow/empty, got: '$output')"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== block-comments.sh tests ==="
echo

# Should block
assert_ask "gh pr review with --body" \
  'gh pr review 24298 --approve --body "Looks good! The implementation is clean."'

assert_ask "gh pr review with --body (short)" \
  'gh pr review 123 --body "LGTM"'

assert_ask "gh pr review with --body-file" \
  'gh pr review 28616 --approve --body-file /tmp/pr_approval.txt && rm /tmp/pr_approval.txt'

assert_ask "gh api PR review with non-empty body" \
  'gh api repos/org/repo/pulls/123/reviews -f event=APPROVE -f body="Nice work"'

assert_ask "gh api PR comment reply" \
  "gh api repos/huntresslabs/portal/pulls/25384/comments/2924977825/replies -f body='Good callout'"

assert_ask "gh api PR comment reply (long body)" \
  "gh api repos/org/repo/pulls/123/comments/456/replies -f body='Good callout — a concern that auto-wires the callback based on naming conventi…'"

assert_ask "gh api PR new comment" \
  'gh api repos/org/repo/pulls/123/comments -f body="This looks wrong"'

assert_ask "gh api PR comment via --input" \
  'gh api repos/org/repo/pulls/123/comments --input /tmp/comment.json'

assert_ask "gh api PR review via --input" \
  'gh api repos/org/repo/pulls/123/reviews --input /tmp/review.json'

assert_ask "gh pr close with --comment" \
  'gh pr close 123 --comment "Closing: superseded by #456"'

assert_ask "gh pr merge with --comment" \
  'gh pr merge 123 --squash --comment "Merging after review"'

assert_ask "gh pr comment" \
  'gh pr comment 123 --body "Looks good"'

assert_ask "gh issue comment" \
  'gh issue comment 456 --body "Working on this"'

assert_ask "minimizeComment GraphQL mutation" \
  'gh api graphql -f query="mutation { minimizeComment(input: {subjectId: \"abc\", classifier: RESOLVED}) { minimizedComment { isMinimized } } }"'

assert_ask "addPullRequestReviewThreadReply GraphQL mutation" \
  'gh api graphql -f query="mutation(\$inReplyTo: ID!, \$body: String!) { addPullRequestReviewThreadReply(input: { pullRequestReviewThreadId: \$inReplyTo, body: \$body }) { comment { id } } }"'

assert_ask "addComment GraphQL mutation" \
  'gh api graphql -f query="mutation { addComment(input: {subjectId: \"abc\", body: \"hi\"}) { commentEdge { node { id } } } }"'

assert_ask "addPullRequestReview GraphQL mutation" \
  'gh api graphql -f query="mutation { addPullRequestReview(input: {pullRequestId: \"abc\", event: APPROVE, body: \"LGTM\"}) { pullRequestReview { id } } }"'

assert_ask "addPullRequestReviewComment GraphQL mutation" \
  'gh api graphql -f query="mutation { addPullRequestReviewComment(input: {pullRequestReviewId: \"abc\", body: \"nit\"}) { comment { id } } }"'

assert_ask "submitPullRequestReview GraphQL mutation" \
  'gh api graphql -f query="mutation { submitPullRequestReview(input: {pullRequestReviewId: \"abc\", event: APPROVE, body: \"LGTM\"}) { pullRequestReview { id } } }"'

# Should allow
assert_allow "resolveReviewThread GraphQL mutation" \
  'gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"PRRT_abc\"}) { thread { isResolved } } }"'
assert_allow "gh pr close without --comment" \
  'gh pr close 123'
assert_allow "gh pr review without --body" \
  'gh pr review 24466 --approve'

assert_allow "gh api PR review with empty body" \
  'gh api repos/org/repo/pulls/123/reviews -f event=APPROVE -f body=""'

assert_allow "unrelated command" \
  'ls -la'

assert_allow "git command" \
  'git status'

assert_allow "gh pr list (not review)" \
  'gh pr list'

assert_allow "gh pr comment with @greptileai (allowlisted)" \
  'gh pr comment 123 --body "@greptileai review"'

assert_allow "gh api PR comment with @greptileai (allowlisted)" \
  'gh api repos/org/repo/pulls/123/comments -f body="@greptileai please review"'

echo
echo "--- Results: $PASS passed, $FAIL failed ---"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
