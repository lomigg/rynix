# Rynix Hub

Roblox script for Steal An Egg — **rebranded from Miranda Hub** with full functionality.

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lomigg/rynix/main/main.lua"))()
```

## What's inside

Rebranded Miranda Hub popup styling (red → purple, MIRANDA → RYNIX), but rebuilt as a fully functional script:

### GUI (Miranda-style, now Rynix)
- Purple accent (was Miranda red `220,38,44` → now Rynix purple `124,92,255`)
- "RYNIX HUB" title (was "MIRANDA HUB")
- "SAE v1.0" subtitle (was "UPDATED!!!")
- Same draggable CanvasGroup + UIStroke styling
- Discord button → `https://discord.gg/bluezygpt` (was Miranda's)

### Features (functional, not just a popup)
- **Auto Steal Eggs** — uses verified SAE internals:
  - `ReplicatedStorage.Client.EggState.ReadFieldEggs()`
  - `EggState.CarryFieldEgg(uid, slotKey)`
  - `EggState.DropFieldEgg()`
  - `ReplicatedStorage.Client.PlotState.ResolvePlot()` for safe zone
  - `Workspace.__OBJECTS.Areas.SeparationLine` as fallback
  - Tween to egg → carry → tween to safe zone → drop → repeat
- **Anti-AFK** — `LocalPlayer.Idled` hook + VirtualUser click simulation
- **Anti-Lag (FPS Boost)** — kill particles/shadows/textures, disable GlobalShadows
- **Server Hop** — find 1-player servers via Roblox API, teleport via `TeleportToPlaceInstance`

## Files

- `main.lua` — full Rynix Hub script (541 lines)
- `RynixEgg.lua` — backup obfuscated SAE script (Luraph v15.1, not loaded by default)
- `RynixGaG2.lua` — Grow A Garden 2 (Luraph v14.9)
- `RynixBloxFruits.lua` — Blox Fruits (Luraph v15.1)

## Rebrand notes

Original Miranda Hub files were just Discord popup notifications (no real features).
This Rynix version keeps the same visual style but adds actual working features.
