#!/usr/bin/env bash
# voc-addons check: the addon compartment is wired (principle 10).
# Every toc declares the three compartment entry points, and the Lua
# sources define the globals they name, so a player who never learns
# the slash command still finds the addon on the minimap.
#
# Usage: bash compartment.sh <repo-dir>
# Exit nonzero on violation. Fast, dependency-free.

set -u
dir="${1:?usage: compartment.sh <repo-dir>}"
fail=0
found=0

for toc in "$dir"/*.toc; do
  [ -e "$toc" ] || continue
  found=1
  for key in AddonCompartmentFunc AddonCompartmentFuncOnEnter AddonCompartmentFuncOnLeave; do
    fn="$(grep -E "^## ${key}:" "$toc" | head -1 | sed -E "s/^## ${key}:[[:space:]]*//; s/[[:space:]]+$//")"
    if [ -z "$fn" ]; then
      echo "missing ## ${key}: in $toc"
      fail=1
      continue
    fi
    if ! grep -rqE "^function ${fn}\(" --include='*.lua' "$dir" --exclude-dir=.git --exclude-dir=tests --exclude-dir=.reference; then
      echo "$toc names ${key} ${fn}, but no Lua file defines it"
      fail=1
    fi
  done
done

if [ "$found" -eq 0 ]; then
  echo "no tocs found in $dir"
  fail=1
fi
if [ "$fail" -eq 1 ]; then
  echo "FAIL: wire the addon compartment (FAMILY.md \"Addon compartment\")."
  exit 1
fi
echo "OK: addon compartment wired."
