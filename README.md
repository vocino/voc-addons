# voc-addons

Craft philosophy, visual identity, and source of truth for the Voc World of
Warcraft addon family (VocWarbank, VocGear, VocXP, VocVendor).

## Install

Clone into your agent's skills directory:

```bash
git clone https://github.com/vocino/voc-addons.git ~/.claude/skills/voc-addons
```

(Also works under `~/.config/opencode/skills/`.)

## What's inside

- `SKILL.md`: the 11 principles: visual identity, interaction standards,
  scope discipline. When this skill and a repo's local notes disagree about
  craft, this skill wins.
- `family/`: the canonical `FAMILY.md` and `VERSIONING.md` every Voc repo
  carries; a check holds the copies identical.
- `references/`: the Foolkevin craft study and the visual identity spec
  (palette values, the tooltip contract, the icon table).
- `checks/`: mechanical checks that run in CI on every Voc repo: no
  hardcoded colors, no `ReloadUI`, dual tocs, the addon compartment wired.
- `templates/addon/` and `tools/new-addon`: scaffold a new Voc addon that
  passes every test, lint, and check before its one job is written.
- `tools/verify-api`: checks an API name against Blizzard's own source on
  both the live and Forever branches and says ok, bare, GONE, or unknown.
- `tools/read-buggrabber`: reads !BugGrabber's saved errors without
  opening the game.

## License

MIT
