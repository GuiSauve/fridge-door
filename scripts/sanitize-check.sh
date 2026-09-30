#!/usr/bin/env bash
# Fails if anything private appears in this folder, so it's safe to share.
# Usage: scripts/sanitize-check.sh [denylist-file]
#   denylist-file: private, one term per line (names, IDs, domains, emails).
#   Keep it OUTSIDE this folder. Lines starting with # are ignored.
set -u
denylist=""
if [ $# -ge 1 ]; then
  [ -r "$1" ] || { echo "✗ Can't read denylist: $1"; exit 2; }
  denylist="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
fi
cd "$(dirname "$0")/.."
fail=0

scan() { # $1 = label, rest = grep args
  local label=$1; shift
  local hits
  hits=$(grep -rnI --exclude-dir=.git --exclude-dir=private --exclude=sanitize-check.sh "$@" . 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}

# Generic patterns, no denylist needed
scan "Telegram bot token"   -E '[0-9]{8,10}:[A-Za-z0-9_-]{30,}'
scan "Google calendar ID"   -E '[0-9a-f]{20,}@group\.calendar\.google\.com'
scan "Routine/env ID"       -E '\b(trig|env)_0[0-9A-Za-z]{10,}'
scan "Telegram chat ID"     -E '(^|[^0-9])-?[0-9]{9,13}([^0-9]|$)'
scan "Email address"        -E '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}'

# Private denylist
if [ -n "$denylist" ]; then
  while IFS= read -r term || [ -n "$term" ]; do
    term=${term%%#*}; term=$(echo "$term" | xargs)
    [ -z "$term" ] && continue
    scan "Denylisted: $term" -i -w -F -- "$term"
  done < "$denylist"
else
  echo "! No denylist given, so only generic patterns were checked."
fi

if [ $fail -eq 0 ]; then echo "✓ Nothing private found."; else echo; echo "Fix the above before sharing."; fi
exit $fail
