# AGENTS.md

## Local checkouts

All Voc repos live side by side under `D:\Code\`, one directory each.
This repo is the skill and source of truth; the addons are siblings,
not subdirectories.

- `D:\Code\voc-addons` - this repo (skill, `family/`, `checks/`, `templates/`, `tools/`)
- `D:\Code\vocwarbank` - VocWarbank (`https://github.com/vocino/vocwarbank`)
- `D:\Code\vocgear` - VocGear (`https://github.com/vocino/vocgear`)
- `D:\Code\vocxp` - VocXP (`https://github.com/vocino/vocxp`)
- `D:\Code\vocvendor` - VocVendor (`https://github.com/vocino/vocvendor`)

## Working across repos

- Family contract lives here in `family/FAMILY.md` and
  `family/VERSIONING.md`; every sibling carries a byte-identical copy
  (`checks/family-docs.sh` enforces it). Edit here, then copy out.
- Run all checks against a sibling with
  `bash checks/run-all.sh D:/Code/<repo>` from this repo root.
- Scaffold a new addon with `tools/new-addon <Name> <short> D:/Code/<dir>`.
