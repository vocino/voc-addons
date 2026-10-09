#!/usr/bin/env bash
# voc-addons check: the family docs are byte-identical to the canonical
# copies in the skill (FAMILY.md, VERSIONING.md). The contract that
# makes four addons feel like one product cannot drift one repo at a
# time.
#
# Usage: bash family-docs.sh <repo-dir>
# Exit nonzero on violation. Fast, dependency-free.

set -u
dir="${1:?usage: family-docs.sh <repo-dir>}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
canon="$here/../family"
fail=0

for doc in FAMILY.md VERSIONING.md; do
  if [ ! -f "$dir/$doc" ]; then
    echo "missing $dir/$doc (copy it from the skill's family/$doc)"
    fail=1
  elif ! diff -q "$canon/$doc" "$dir/$doc" >/dev/null; then
    echo "$dir/$doc differs from the skill's family/$doc:"
    diff "$canon/$doc" "$dir/$doc" | head -10
    fail=1
  fi
done

if [ "$fail" -eq 1 ]; then
  echo "FAIL: copy family/FAMILY.md and family/VERSIONING.md from the skill; edit them there."
  exit 1
fi
echo "OK: family docs match the skill."
