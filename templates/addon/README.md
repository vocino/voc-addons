# VocName

One paragraph: the problem a player has, and the one thing VocName
does about it. Say what it never does, too.

## Install

Download the latest zip from [GitHub
Releases](https://github.com/vocino/vocname/releases) (also on
CurseForge and Wago), copy the folder into `Interface/AddOns`, and
make sure it is named `VocName` (the folder name must match the
`.toc` file). The same package runs on Retail and on the Forever
client.

## Use

What happens with no configuration at all. The addon compartment on
the minimap opens the settings.

```
/vn            toggle VocName on/off
/vn on|off     set it explicitly
/vn config     open Settings > AddOns > VocName
/vn help       this list (/vocname works too)
```

## Config

Settings > AddOns > VocName, or `/vn config`:

- Enable VocName (default on)
- Chat announcements (default on)

Every change applies at once.

## How it works

Two or three sentences a curious player can follow: what it reads,
what it decides, what it never touches.

## What's inside

- `main.lua`: the whole addon
- `VocName.toc` / `VocName_Forever.toc`: metadata for Retail and the Forever client
- `tests/run.lua`: stub-harness regression tests, no WoW client needed

## Tests

```
lua tests/run.lua
luacheck .
```

## License

MIT

---

Part of the Voc family: tiny addons that do one job.
[VocWarbank](https://github.com/vocino/vocwarbank) ·
[VocGear](https://github.com/vocino/vocgear) ·
[VocXP](https://github.com/vocino/vocxp) ·
[VocVendor](https://github.com/vocino/vocvendor)
