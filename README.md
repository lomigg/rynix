# Rynix Hub

Roblox script loader — rebranded from RealKid Hub.

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lomigg/rynix/main/main.lua"))()
```

## Supported games

| Game | PlaceId / GameId | Script |
|---|---|---|
| Steal An Egg | PlaceId 107778070777162 | RynixEgg.lua |
| Grow A Garden 2 | GameId 10200395747 | RynixGaG2.lua |
| Blox Fruits (default) | any | RynixBloxFruits.lua |

## Files

- `main.lua` — loader (auto-routes by PlaceId/GameId)
- `RynixEgg.lua` — Steal An Egg script
- `RynixGaG2.lua` — Grow A Garden 2 script
- `RynixBloxFruits.lua` — Blox Fruits script

## Rebrand notes

The underlying obfuscated scripts retain their original `RealKid` brand strings inside the GUI — they're Luraph-obfuscated so string-level rebranding isn't possible without deobfuscation. The loader, repo, and file names are rebranded to Rynix.

