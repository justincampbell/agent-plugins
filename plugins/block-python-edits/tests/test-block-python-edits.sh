#!/usr/bin/env bash
# Tests for block-python-edits.sh hook

set -uo pipefail

HOOK="$(dirname "$0")/../hooks/block-python-edits.sh"
PASS=0
FAIL=0

run_hook() {
  echo "{\"tool_input\":{\"command\":$(printf '%s' "$1" | jq -Rs .)}}" | bash "$HOOK"
}

assert_block() {
  local desc="$1" command="$2" output
  output=$(run_hook "$command")
  if echo "$output" | grep -q '"block"'; then
    echo "PASS: $desc"; PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (expected block, got: '$output')"; FAIL=$((FAIL + 1))
  fi
}

assert_allow() {
  local desc="$1" command="$2" output
  output=$(run_hook "$command")
  if [[ -z "$output" ]]; then
    echo "PASS: $desc"; PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (expected allow/empty, got: '$output')"; FAIL=$((FAIL + 1))
  fi
}

echo "=== block-python-edits.sh tests ==="
echo

# Should block — real patterns seen in past sessions
assert_block "heredoc read/replace/write" \
"python3 - <<'EOF'
p='CLAUDE.md'; s=open(p).read()
s=s.replace('old', 'new')
open(p,'w').write(s)
EOF"

assert_block "heredoc chained after sed" \
"cd tools && sed -i '' 's|x|y|' CLAUDE.md && python3 - <<'EOF'
p='CLAUDE.md'; s=open(p).read()
open(p,'w').write(s.replace('a','b'))
EOF"

assert_block "python -c with open write" \
  "python3 -c \"s=open('a.md').read(); open('a.md','w').write(s.replace('x','y'))\""

assert_block "python -c with mode= kwarg" \
  "python3 -c \"open('a.md', mode='w').write('hi')\""

assert_block "python -c append mode" \
  "python3 -c \"open('log.txt','a').write('line')\""

assert_block "python -c r+ mode" \
  "python3 -c \"f=open('a.md','r+'); f.write('x')\""

assert_block "python -c binary write" \
  "python3 -c \"open('a.bin','wb').write(b'x')\""

assert_block "pathlib write_text" \
  "python3 -c \"from pathlib import Path; p=Path('a.md'); p.write_text(p.read_text().replace('x','y'))\""

assert_block "heredoc without dash" \
"python3 <<'PY'
import re
s=open('f.py').read()
s=re.sub(r'foo','bar',s)
open('f.py','w').write(s)
PY"

assert_block "bare python (no version)" \
  "python -c \"open('a','w').write('x')\""

assert_block "python -uc flag combo" \
  "python3 -uc \"open('a','w').write('x')\""

assert_block "os.replace atomic rename" \
  "python3 -c \"import os; open('a.tmp','w').write('x'); os.replace('a.tmp','a')\""

# Should allow
assert_allow "read-only json parsing" \
  "curl -s https://example.com/api | python3 -c 'import json,sys; [print(e[\"title\"]) for e in json.load(sys.stdin)]'"

assert_allow "read-only heredoc analysis" \
"python3 - <<'EOF'
import re
s=open('3D/Objects/object_4.model').read()
print(len(re.findall(r'<vertex', s)))
EOF"

assert_allow "read-only binary open" \
  "python3 -c \"import re;d=open('x.pdf','rb').read();print(len(d))\""

assert_allow "explicit read mode" \
  "python3 -c \"print(open('a.md','r').read())\""

assert_allow "sys.stdout.write" \
  "python3 -c \"import sys; sys.stdout.write('hi')\""

assert_allow "running a script file" \
  "python3 scripts/migrate.py --write output.txt"

assert_allow "python -m http.server" \
  "./script/build && python3 -m http.server -d dist 8000"

assert_allow "python arithmetic" \
  "python3 -c \"print(f'{120/60:.0f} min')\""

assert_allow "python --version" \
  "python3 --version"

assert_allow "unrelated command" \
  "ls -la"

assert_allow "ipython not matched as python" \
  "ipython -c \"open('a','w').write('x')\""

echo
echo "--- Results: $PASS passed, $FAIL failed ---"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
