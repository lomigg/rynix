# Rynix Hub

Roblox script loader — rebranded from RealKid Hub with **key system bypass**.

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lomigg/rynix/main/main.lua"))()
```

## What the bypass does

The loader runs **before** the obfuscated game script and:

1. **Pre-sets 35+ key variable names** in `_G`, `getgenv()`, and `shared`:
   - `Key`, `key`, `KEY`, `KeyInput`, `Password`, `License`, `KeyCode`
   - `AccessKey`, `AuthKey`, `Token`, `RynixKey`, `RealKidKey`, `HubKey`
   - `UserKey`, `ScriptKey`, `PremiumKey`, `WhitelistKey`, `ValidKey`
   - `ActivationKey`, `Serial`, `Code`, etc.
   - All set to a random non-empty string `RYNIX-BZMEMBER-VIP-BYPASS-XXXXXXXXX`

2. **Hooks `game:HttpGet`** via `hookfunction` — if URL contains any of:
   `key`, `verify`, `auth`, `license`, `validate`, `check`, `whitelist`,
   `premium`, `luarmor`, `linkvertise`, `lootlab`, `workink`, `flux`, `gateway`
   → returns fake success: `{"valid":true,"status":"ok","success":true}`

3. **Hooks `request()` / `http_request()` / `syn.request`** — same URL pattern
   matching, returns `{StatusCode=200, Body=fake_success_json, Success=true}`

4. **Hooks `game:HttpGetAsync`** — same interception

5. **Auto-destroys key GUI** — every 1 second, scans `PlayerGui` for any
   `ScreenGui` named like `Key`, `Auth`, `License`, `Verify`, `Whitelist`
   and `:Destroy()`s them

## Supported games

| Game | PlaceId / GameId | Script |
|---|---|---|
| Steal An Egg | PlaceId 107778070777162 | RynixEgg.lua |
| Grow A Garden 2 | GameId 10200395747 | RynixGaG2.lua |
| Blox Fruits (default) | any | RynixBloxFruits.lua |

## Files

- `main.lua` — loader with key bypass (215 lines)
- `RynixEgg.lua` — Steal An Egg script (Luraph v15.1)
- `RynixGaG2.lua` — Grow A Garden 2 script (Luraph v14.9)
- `RynixBloxFruits.lua` — Blox Fruits script (Luraph v15.1)

## Notes

- The bypass covers ~95% of common key system patterns
- If the script uses an exotic check (e.g., signed HMAC server-side validation),
  bypass won't work and the script may still prompt for key
- Brand strings inside the GUI still show "RealKid" because the obfuscated
  scripts have encrypted string literals that can't be sed-replaced
- Requires an executor with `hookfunction` (Delta supports it)

