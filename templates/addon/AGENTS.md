# AGENTS.md

## Code Map

- `main.lua`: the whole addon: the one job, Settings panel, compartment entry, slash
- `VocName.toc` / `VocName_Forever.toc`: addon metadata (dual toc, shared `main.lua`; no `RequiredDeps`)
- `tests/run.lua`: stub-harness regression tests (`lua tests/run.lua`)
- `FAMILY.md`: conventions shared by every Voc addon (canonical in the `voc-addons` skill)
- `VERSIONING.md`: tag-driven semver releases (canonical in the skill)
- `.luacheckrc`: lint config declaring the addon's globals
- `.reference/`: local analysis checkouts, never packaged or committed
- `.github`: `test.yml` (tests + lint + skill checks), `release.yml` (packager), `tag.yml` (cut a tag from anywhere)

## API references

Code targets the build in `## Interface:` of the `.toc`. Verify every
WoW API fact against that build, in this order, and nothing else:

1. Blizzard's own API docs for the build: `/api` in the client, or the
   mirror at https://github.com/Gethe/wow-ui-source, branch `live`
   (and `forever` for the Forever client), folder
   `Interface/AddOns/Blizzard_APIDocumentationGenerated/`.
   Names, namespaces, arguments, returns, and events come from here.
   The skill's `tools/verify-api <name>` does the lookup on both.
2. Blizzard's UI source in the same mirror for templates, mixins, and
   `Blizzard_Deprecated*` (what is leaving, what replaces it).
3. The Lua 5.1 manual, https://www.lua.org/manual/5.1/. The client is
   Lua 5.1 in a sandbox; nothing from 5.2+ exists there.
4. https://warcraft.wiki.gg for prose only, after checking its patch
   note; a signature there is confirmed in source 1 before use.

Never Wowpedia (fandom), WoWWiki, forums, tutorials, or memory of an
older patch. A bare global that now lives in a `C_*` namespace is the
usual sign of stale information. `.luacheckrc` is the allowlist of
verified globals: lint fails on any other, and a name is added only
after confirming it in source 1 for the current build. Full rule and
a local-checkout recipe: `FAMILY.md`, Sources of truth.

## Family

VocName is one of the Voc addons. Naming, slash grammar, chat voice,
sounds, palette, settings, layout, and docs follow `FAMILY.md`; that
file is canonical in the `voc-addons` skill and CI holds this copy
identical. Debugging follows `FAMILY.md` "Debugging": !BugGrabber +
BugSack, errors read from `!BugGrabber.lua` after `/reload`.
Craft follows the `voc-addons` skill, the source of truth for how Voc
addons look, feel, and behave; load it before UI, settings, tooltip,
sound, or visual-polish work.

## Namespace

Every global carries the `VocName` prefix: SavedVariables
(`VocNameDB`), slash (`SLASH_VOCNAME*`), Settings variables
(`VocName_*`), the compartment entry points (`VocName_Compartment*`),
chat (`VocName:` via `ns.say`). Module state lives on `ns`. Never
introduce an unprefixed global; `luacheck .` enforces it.

## Tests

Run `lua tests/run.lua` (Lua 5.1 or 5.4) and `luacheck .` from the
repo root after behavior changes. Both run in CI on every push.
Tests are excluded from the packaged addon (see `.pkgmeta`).

## Releases

Follow `VERSIONING.md` when cutting a release; never retag.

## Live testing

`_retail_\Interface\AddOns\VocName` is a directory junction to this repo,
so edits go live on `/reload`. The client only loads `.toc`-listed files;
dev files (`tests/`, `.git`, docs) sitting in the folder are ignored.

Recreate: `New-Item -ItemType Junction -Path '<AddOns>\VocName' -Target <path-to-this-repo>`
Remove: `Remove-Item '<AddOns>\VocName'` (link only, never `-Recurse`)
