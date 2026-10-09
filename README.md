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
- `references/`: the Foolkevin craft study and the visual identity spec
  (palette values, the tooltip contract, the icon table).
- `checks/`: mechanical checks that run in CI on every Voc repo: no
  hardcoded colors, no `ReloadUI`, dual tocs, the addon compartment wired.
- `tools/read-buggrabber`: reads !BugGrabber's saved errors without
  opening the game.

## License

MIT
