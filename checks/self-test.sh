#!/usr/bin/env bash
# voc-addons: prove every check passes a clean repo and fails a dirty
# one. Repos clone this skill's main branch live, so a check that
# silently broke would break four CIs at once; this runs before any
# check lands.
#
# Usage: bash checks/self-test.sh
# The clean repo is checks/fixtures/pass (plus the canonical family
# docs, copied in at run time). Each failing case is that folder with
# one mutation applied, so a check must fail for exactly its reason.

set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0
ran=0

fresh() {
  rm -rf "$work/repo"
  cp -r "$here/fixtures/pass" "$work/repo"
  cp "$here/../family/FAMILY.md" "$here/../family/VERSIONING.md" "$work/repo/"
}

expect() { # expect <pass|fail> <check> <label>
  local want="$1" check="$2" label="$3" out rc
  ran=$((ran + 1))
  out="$(bash "$here/$check" "$work/repo" 2>&1)"; rc=$?
  if [ "$want" = pass ] && [ "$rc" -ne 0 ]; then
    echo "FAIL: $check should pass ($label):"; echo "$out" | sed 's/^/    /'; fail=1
  elif [ "$want" = fail ] && [ "$rc" -eq 0 ]; then
    echo "FAIL: $check should fail ($label):"; echo "$out" | sed 's/^/    /'; fail=1
  else
    echo "ok: $check $want ($label)"
  fi
}

# The clean fixture passes everything, through run-all like CI does.
fresh
expect pass run-all.sh "clean fixture"

# One mutation per check; each must fail its own check and nothing else.
fresh; printf 'local s = "|cffff0000red|r"\n' >> "$work/repo/main.lua"
expect fail no-hardcoded-colors.sh "|cff literal"
fresh; printf 'local c = CreateColor(1, 0, 0)\n' >> "$work/repo/main.lua"
expect fail no-hardcoded-colors.sh "numeric CreateColor"
fresh; printf 'GameTooltip:SetTextColor(1, 0.82, 0)\n' >> "$work/repo/main.lua"
expect fail no-hardcoded-colors.sh "numeric SetTextColor"
fresh; printf 'local p = { SetTextColor = function() end }\np:SetTextColor(ns.COLORS.gold[1], 0, 0)\n' >> "$work/repo/main.lua"
expect pass no-hardcoded-colors.sh "token text color"

fresh; printf 'ReloadUI()\n' >> "$work/repo/main.lua"
expect fail no-reloadui.sh "ReloadUI call"
fresh; printf 'local x = MyReloadUI()\n' >> "$work/repo/main.lua"
expect pass no-reloadui.sh "other function ending in ReloadUI"

fresh; rm "$work/repo/VocFixture_Forever.toc"
expect fail dual-toc.sh "no Forever toc"

fresh; sed -i '/AddonCompartmentFuncOnLeave/d' "$work/repo/VocFixture.toc"
expect fail compartment.sh "missing OnLeave key"
fresh; sed -i 's/^function VocFixture_CompartmentEnter/function VocFixture_CompartmentHover/' "$work/repo/main.lua"
expect fail compartment.sh "named global not defined"

fresh; printf 'local a = GetItemInfo(1)\n' >> "$work/repo/main.lua"
expect fail no-deprecated-globals.sh "bare GetItemInfo call"
fresh; printf 'read_globals = { "IsAddOnLoaded" }\n' >> "$work/repo/.luacheckrc"
expect fail no-deprecated-globals.sh "allowlisted IsAddOnLoaded"
fresh; printf -- '-- GetItemInfo( moved to C_Item\nlocal b = C_Item.GetItemInfo(1)\n' >> "$work/repo/main.lua"
expect pass no-deprecated-globals.sh "namespaced call and a comment"

fresh; printf 'drift\n' >> "$work/repo/FAMILY.md"
expect fail family-docs.sh "FAMILY.md drift"
fresh; rm "$work/repo/VERSIONING.md"
expect fail family-docs.sh "VERSIONING.md missing"

# Every check in the folder got at least one failing case above.
for check in "$here"/*.sh; do
  n="$(basename "$check")"
  case "$n" in run-all.sh|self-test.sh) continue ;; esac
  if ! grep -q "expect fail $n" "$here/self-test.sh"; then
    echo "FAIL: $n has no failing case in self-test.sh"; fail=1
  fi
done

if [ "$fail" -eq 1 ]; then
  echo "FAIL: self-test ($ran cases)."
  exit 1
fi
echo "OK: self-test, $ran cases."
