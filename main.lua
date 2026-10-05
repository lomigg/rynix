-- Rynix Hub Loader (Key Bypass Edition)
-- Auto-routes to the correct game script based on PlaceId / GameId
-- Originally RealKid Hub — rebranded to Rynix for BZMEMBER
-- Repo: lomigg/rynix (public)
-- This loader pre-sets key globals and hooks HttpGet to bypass key systems.

pcall(function()
    -- ============================================================
    -- KEY BYPASS LAYER
    -- ============================================================
    -- Pre-set every common key variable name to a non-empty string.
    -- Most key systems just check `_G.Key ~= nil and #_G.Key > 0`.
    local FAKE_KEY = "RYNIX-BZMEMBER-VIP-BYPASS-" .. tostring(math.random(1e9, 9e9))
    local keyNames = {
        "Key", "key", "KEY",
        "KeyInput", "keyinput", "KeyInput",
        "Password", "password", "PASSWORD",
        "License", "license", "LICENSE",
        "KeyCode", "keycode", "KEYCODE",
        "AccessKey", "accesskey", "ACCESSKEY",
        "AuthKey", "authkey", "AUTHKEY",
        "Token", "token", "TOKEN",
        "RynixKey", "RealKidKey", "HubKey",
        "UserKey", "userkey", "USERKEY",
        "ScriptKey", "scriptkey", "SCRIPTKEY",
        "PremiumKey", "premiumkey",
        "WhitelistKey", "whitelistkey",
        "ValidKey", "validkey",
        "ActivationKey", "activationkey",
        "Serial", "serial",
        "Code", "code",
    }
    for _, name in ipairs(keyNames) do
        pcall(function() _G[name] = FAKE_KEY end)
        pcall(function() getgenv()[name] = FAKE_KEY end)
        pcall(function() shared[name] = FAKE_KEY end)
    end

    -- Also set common key attribute on LocalPlayer
    pcall(function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        if lp then
            for _, name in ipairs(keyNames) do
                pcall(function() lp:SetAttribute(name, FAKE_KEY) end)
            end
        end
    end)

    -- ============================================================
    -- HTTP HOOK — intercept key-verification URLs
    -- ============================================================
    -- Many key systems call game:HttpGet(url) to verify the key.
    -- We return "true" / "valid" / success JSON for any URL that looks like a key check.
    local originalHttpGet = game.HttpGet
    local originalRequest = request or http_request or (syn and syn.request)
    local originalHttpGetAsync = game.HttpGetAsync

    local KEY_URL_PATTERNS = {
        "key", "Key", "KEY",
        "verify", "Verify",
        "auth", "Auth",
        "license", "License",
        "validate", "Validate",
        "check", "Check",
        "whitelist", "Whitelist",
        "premium", "Premium",
        "luarmor", "linkvertise", "lootlab",
        "workink", "flux", "gateway",
        "discord.com/api/webhooks",  -- some scripts phone home
    }

    local function isKeyUrl(url)
        if type(url) ~= "string" then return false end
        for _, pat in ipairs(KEY_URL_PATTERNS) do
            if url:find(pat, 1, true) then return true end
        end
        return false
    end

    local function fakeKeyResponse()
        -- Return a response that satisfies common key check formats
        local responses = {
            "valid",
            "true",
            '{"valid":true,"status":"ok","success":true}',
            '{"success":true,"valid":true,"message":"Key verified"}',
            "Key Verified",
            "OK",
            "1",
        }
        return responses[math.random(1, #responses)]
    end

    -- Hook game:HttpGet
    pcall(function()
        local oldGet = game.HttpGet
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__index = mt.__index -- safety
        -- Use hookfunction if available (most executors have it)
        if hookfunction then
            local old
            old = hookfunction(game.HttpGet, function(self, url, ...)
                if isKeyUrl(url) then
                    return fakeKeyResponse()
                end
                return old(self, url, ...)
            end)
        end
        setreadonly(mt, true)
    end)

    -- Hook global request() / http_request for key URLs
    pcall(function()
        if originalRequest and hookfunction then
            local old = originalRequest
            local hooked = function(args)
                args = args or {}
                if isKeyUrl(args.Url) then
                    return {
                        StatusCode = 200,
                        StatusMessage = "OK",
                        Body = fakeKeyResponse(),
                        Headers = {},
                        Success = true,
                    }
                end
                return old(args)
            end
            -- Set hooked in multiple globals
            pcall(function() request = hooked end)
            pcall(function() http_request = hooked end)
            if syn then pcall(function() syn.request = hooked end) end
        end
    end)

    -- Hook game:HttpGetAsync too
    pcall(function()
        if hookfunction then
            local old
            old = hookfunction(game.HttpGetAsync, function(self, url, ...)
                if isKeyUrl(url) then
                    return fakeKeyResponse()
                end
                return old(self, url, ...)
            end)
        end
    end)

    -- ============================================================
    -- HOOK LOADSTRING — skip nested key check loaders
    -- ============================================================
    -- Some scripts loadstring() a key-gate URL first; intercept those.
    pcall(function()
        if hookfunction and loadstring then
            local oldLoad = loadstring
            local hookedLoad = function(src, name)
                -- If source is a URL fetch for key, return no-op function
                if type(src) == "string" and src:find("HttpGet", 1, true) then
                    -- Check if this is a key-fetch wrapper by inspecting the URL
                    if isKeyUrl(src) then
                        return function() end
                    end
                end
                return oldLoad(src, name)
            end
            -- Don't override loadstring globally — too risky for legit uses
            -- Only override _G.loadstring
            -- pcall(function() _G.loadstring = hookedLoad end)
        end
    end)

    -- ============================================================
    -- MESSAGEINTERCEPT — auto-confirm any "Enter Key" UI dialog
    -- ============================================================
    pcall(function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local PlayerGui = lp:WaitForChild("PlayerGui")
        -- Watch for any ScreenGui named like "Key", "Auth", "License" and destroy it
        task.spawn(function()
            while task.wait(1) do
                pcall(function()
                    for _, gui in ipairs(PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") then
                            local n = gui.Name:lower()
                            if n:find("key") or n:find("auth") or n:find("license")
                               or n:find("verify") or n:find("whitelist") then
                                gui:Destroy()
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- ============================================================
    -- LOAD TARGET SCRIPT
    -- ============================================================
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
