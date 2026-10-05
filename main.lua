-- Rynix Hub Loader
-- Auto-routes to the correct game script based on PlaceId / GameId
-- Originally RealKid Hub — rebranded to Rynix for BZMEMBER
-- Repo: lomigg/rynix (public)

pcall(function()
    local url

    if game.PlaceId == 107778070777162 then
        -- Steal An Egg
        url = "https://raw.githubusercontent.com/lomigg/rynix/main/RynixEgg.lua"
    elseif game.GameId == 10200395747 then
        -- Grow A Garden 2
        url = "https://raw.githubusercontent.com/lomigg/rynix/main/RynixGaG2.lua"
    else
        -- Blox Fruits (default)
        url = "https://raw.githubusercontent.com/lomigg/rynix/main/RynixBloxFruits.lua"
    end

    loadstring(game:HttpGet(url))()
end)
