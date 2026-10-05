-- Rynix Hub Loader (Key Cracker Edition)
-- Dumps every string the obfuscated script touches so we can extract the real key.
-- Repo: lomigg/rynix (public)

pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer

    -- ============================================================
    -- DUMP BUFFER
    -- ============================================================
    local dump = {}
    local function log(tag, msg)
        local line = "[" .. tostring(tag) .. "] " .. tostring(msg)
        table.insert(dump, line)
        print(line)
    end

    local function isInteresting(s)
        if type(s) ~= "string" then return false end
        if #s < 4 or #s > 200 then return false end
        -- Filter out obviously non-key strings
        if s:match("^[%s%p]*$") then return false end
        -- Keep anything that looks key-like: alphanumeric with dashes, mixed case, hex, base64
        if s:match("[A-Za-z0-9%-_]{8,}") then return true end
        return false
    end

    local seen = {}
    local function capture(s, ctx)
        if not isInteresting(s) then return end
        local key = ctx .. "::" .. s
        if not seen[key] then
            seen[key] = true
            log(ctx, s)
        end
    end

    -- ============================================================
    -- HOOK STRING LIBRARY — every string op gets logged
    -- ============================================================
    local rawString = {
        find = string.find,
        gmatch = string.gmatch,
        gsub = string.gsub,
        match = string.match,
        sub = string.sub,
        format = string.format,
        len = string.len,
        lower = string.lower,
        upper = string.upper,
        rep = string.rep,
        reverse = string.reverse,
        byte = string.byte,
        char = string.char,
    }

    if hookfunction then
        pcall(function()
            hookfunction(string.find, function(s, pattern, ...)
                capture(s, "STR.find.s")
                capture(pattern, "STR.find.pat")
                return rawString.find(s, pattern, ...)
            end)
        end)
        pcall(function()
            hookfunction(string.match, function(s, pattern, ...)
                capture(s, "STR.match.s")
                capture(pattern, "STR.match.pat")
                return rawString.match(s, pattern, ...)
            end)
        end)
        pcall(function()
            hookfunction(string.gmatch, function(s, pattern, ...)
                capture(s, "STR.gmatch.s")
                capture(pattern, "STR.gmatch.pat")
                return rawString.gmatch(s, pattern, ...)
            end)
        end)
        pcall(function()
            hookfunction(string.gsub, function(s, pattern, repl, ...)
                capture(s, "STR.gsub.s")
                capture(pattern, "STR.gsub.pat")
                capture(repl, "STR.gsub.repl")
                return rawString.gsub(s, pattern, repl, ...)
            end)
        end)
        pcall(function()
            hookfunction(string.sub, function(s, i, j)
                local r = rawString.sub(s, i, j)
                if r and #r >= 4 and #r <= 100 then
                    capture(r, "STR.sub")
                end
                return r
            end)
        end)
        pcall(function()
            hookfunction(string.format, function(fmt, ...)
                capture(fmt, "STR.format")
                local args = {...}
                for i, a in ipairs(args) do
                    if type(a) == "string" then capture(a, "STR.format.arg" .. i) end
                end
                return rawString.format(fmt, ...)
            end)
        end)
        pcall(function()
            hookfunction(string.lower, function(s)
                capture(s, "STR.lower")
                return rawString.lower(s)
            end)
        end)
        pcall(function()
            hookfunction(string.upper, function(s)
                capture(s, "STR.upper")
                return rawString.upper(s)
            end)
        end)
    end

    -- ============================================================
    -- HOOK HTTP — log every URL + response body
    -- ============================================================
    if hookfunction then
        pcall(function()
            local old
            old = hookfunction(game.HttpGet, function(self, url, ...)
                capture(url, "HTTP.Get.url")
                local body = old(self, url, ...)
                if type(body) == "string" then
                    capture(body:sub(1, 500), "HTTP.Get.resp")
                end
                return body
            end)
        end)
        pcall(function()
            local old
            old = hookfunction(game.HttpGetAsync, function(self, url, ...)
                capture(url, "HTTP.GetAsync.url")
                return old(self, url, ...)
            end)
        end)
    end

    -- Hook request() globally
    pcall(function()
        local orig = request or http_request
        if orig and hookfunction then
            local old = orig
            local hooked = function(args)
                args = args or {}
                capture(args.Url or "", "REQ.url")
                capture(args.Body or "", "REQ.body")
                capture(args.Method or "", "REQ.method")
                local resp = old(args)
                if resp and type(resp.Body) == "string" then
                    capture(resp.Body:sub(1, 500), "REQ.resp")
                end
                return resp
            end
            pcall(function() request = hooked end)
            pcall(function() http_request = hooked end)
            if syn then pcall(function() syn.request = hooked end) end
        end
    end)

    -- ============================================================
    -- HOOK REMOTES — log every FireServer / InvokeServer call
    -- ============================================================
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)

        local oldIndex = mt.__index
        mt.__index = newcclosure and newcclosure(function(self, k)
            return oldIndex(self, k)
        end) or oldIndex

        -- Hook RemoteEvent.FireServer via instance method
        local function hookRemote(instance)
            if not instance then return end
            if instance:IsA("RemoteEvent") then
                local oldFire = instance.FireServer
                if hookfunction then
                    pcall(function()
                        hookfunction(oldFire, function(self, ...)
                            local args = {...}
                            for i, a in ipairs(args) do
                                if type(a) == "string" then
                                    capture(a, "REMOTE.Fire." .. instance.Name .. ".arg" .. i)
                                end
                            end
                            return oldFire(self, ...)
                        end)
                    end)
                end
            elseif instance:IsA("RemoteFunction") then
                local oldInvoke = instance.InvokeServer
                if hookfunction then
                    pcall(function()
                        hookfunction(oldInvoke, function(self, ...)
                            local args = {...}
                            for i, a in ipairs(args) do
                                if type(a) == "string" then
                                    capture(a, "REMOTE.Invoke." .. instance.Name .. ".arg" .. i)
                                end
                            end
                            return oldInvoke(self, ...)
                        end)
                    end)
                end
            end
        end

        -- Walk ReplicatedStorage for remotes
        task.spawn(function()
            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                pcall(hookRemote, obj)
            end
            ReplicatedStorage.DescendantAdded:Connect(function(obj)
                pcall(hookRemote, obj)
            end)
        end)

        setreadonly(mt, true)
    end)

    -- ============================================================
    -- HOOK print / warn — see what the script complains about
    -- ============================================================
    pcall(function()
        local oldPrint = print
        if hookfunction then
            hookfunction(print, function(...)
                local args = {...}
                for _, a in ipairs(args) do
                    if type(a) == "string" then capture(a, "PRINT") end
                end
                return oldPrint(...)
            end)
            hookfunction(warn, function(...)
                local args = {...}
                for _, a in ipairs(args) do
                    if type(a) == "string" then capture(a, "WARN") end
                end
            end)
        end
    end)

    -- ============================================================
    -- HOOK TextBox.FocusLost — capture user input to key fields
    -- ============================================================
    pcall(function()
        local PlayerGui = lp:WaitForChild("PlayerGui")
        task.spawn(function()
            while task.wait(0.5) do
                pcall(function()
                    for _, gui in ipairs(PlayerGui:GetDescendants()) do
                        if gui:IsA("TextBox") and not gui:GetAttribute("RynixHooked") then
                            gui:SetAttribute("RynixHooked", true)
                            local name = gui.Name
                            local placeholder = gui.PlaceholderText or ""
                            if name:lower():find("key") or placeholder:lower():find("key") then
                                gui.FocusLost:Connect(function(enterPressed)
                                    capture(gui.Text, "USER.input." .. name)
                                end)
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- ============================================================
    -- AUTO-DUMP after 60 seconds
    -- ============================================================
    task.spawn(function()
        task.wait(60)
        local out = table.concat(dump, "\n")
        pcall(function()
            if writefile then
                writefile("RynixKeyDump.txt", out)
                print("[RYNIX] Dump saved to workspace: RynixKeyDump.txt")
            end
        end)
        print("[RYNIX] === KEY DUMP ===")
        print(out)
        print("[RYNIX] === END DUMP (" .. #dump .. " entries) ===")
    end)

    -- ============================================================
    -- LOAD TARGET SCRIPT
    -- ============================================================
    local url
    if game.PlaceId == 107778070777162 then
        url = "https://raw.githubusercontent.com/lomigg/rynix/main/RynixEgg.lua"
    elseif game.GameId == 10200395747 then
        url = "https://raw.githubusercontent.com/lomigg/rynix/main/RynixGaG2.lua"
    else
        url = "https://raw.githubusercontent.com/lomigg/rynix/main/RynixBloxFruits.lua"
    end

    print("[RYNIX] Loading target: " .. url)
    print("[RYNIX] Hooks installed. Will dump in 60 seconds.")
    print("[RYNIX] If a key prompt appears, TYPE ANYTHING and press enter — we'll capture what the script compares against.")
    loadstring(game:HttpGet(url))()
end)
