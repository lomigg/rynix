-- Rynix Hub - Steal An Egg
-- Rebranded from Miranda Hub for BZMEMBER
-- Repo: lomigg/rynix (public)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local P = Players.LocalPlayer
local PG = P:WaitForChild("PlayerGui")

-- ============================================================
-- CLEANUP OLD INSTANCE
-- ============================================================
local old = PG:FindFirstChild("RynixHubUI")
if old then old:Destroy() end

-- ============================================================
-- ROOT GUI
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "RynixHubUI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = PG

-- ============================================================
-- MAIN WINDOW (mirrors Miranda styling - now Rynix purple)
-- ============================================================
local Main = Instance.new("CanvasGroup")
Main.AnchorPoint = Vector2.new(.5, .5)
Main.Position = UDim2.fromScale(.5, .5)
Main.Size = UDim2.fromOffset(520, 380)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.GroupTransparency = 1
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", Main)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(124, 92, 255)
stroke.Thickness = 2

local scale = Instance.new("UIScale", Main)
scale.Scale = .92

-- ============================================================
-- HEADER
-- ============================================================
local Header = Instance.new("Frame", Main)
Header.Position = UDim2.fromOffset(24, 18)
Header.Size = UDim2.new(1, -72, 0, 46)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(.58, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.RichText = true
Title.Text = '<font color="rgb(124,92,255)">RYNIX</font> <font color="rgb(255,255,255)">HUB</font>'
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 23
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Divider = Instance.new("Frame", Header)
Divider.AnchorPoint = Vector2.new(.5, .5)
Divider.Position = UDim2.new(.59, 0, .5, 0)
Divider.Size = UDim2.fromOffset(2, 29)
Divider.BackgroundColor3 = Color3.fromRGB(124, 92, 255)
Divider.BorderSizePixel = 0

local Updated = Instance.new("TextLabel", Header)
Updated.Position = UDim2.new(.62, 0, 0, 0)
Updated.Size = UDim2.new(.38, 0, 1, 0)
Updated.BackgroundTransparency = 1
Updated.Text = "SAE v1.0"
Updated.TextColor3 = Color3.new(1, 1, 1)
Updated.Font = Enum.Font.GothamBlack
Updated.TextSize = 19
Updated.TextXAlignment = Enum.TextXAlignment.Center

local Close = Instance.new("TextButton", Main)
Close.AnchorPoint = Vector2.new(1, 0)
Close.Position = UDim2.new(1, -10, 0, 10)
Close.Size = UDim2.fromOffset(30, 30)
Close.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
Close.BorderSizePixel = 0
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(220, 220, 225)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 11
Close.AutoButtonColor = false
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local Rail = Instance.new("Frame", Main)
Rail.Position = UDim2.fromOffset(24, 67)
Rail.Size = UDim2.new(1, -48, 0, 2)
Rail.BackgroundColor3 = Color3.fromRGB(124, 92, 255)
Rail.BorderSizePixel = 0

local Desc = Instance.new("TextLabel", Main)
Desc.Position = UDim2.fromOffset(28, 78)
Desc.Size = UDim2.new(1, -56, 0, 22)
Desc.BackgroundTransparency = 1
Desc.Text = "Steal An Egg - auto steal + anti-AFK + anti-lag"
Desc.TextColor3 = Color3.fromRGB(178, 175, 185)
Desc.Font = Enum.Font.GothamMedium
Desc.TextSize = 13
Desc.TextXAlignment = Enum.TextXAlignment.Center

-- ============================================================
-- TOGGLES
-- ============================================================
local states = { autoSteal = false, antiAfk = true, antiLag = false }

local function makeToggle(text, y, default, callback)
    local holder = Instance.new("Frame", Main)
    holder.Position = UDim2.fromOffset(28, y)
    holder.Size = UDim2.new(1, -56, 0, 36)
    holder.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text

    local toggle = Instance.new("Frame", holder)
    toggle.Size = UDim2.fromOffset(36, 18)
    toggle.Position = UDim2.new(1, -48, 0.5, -9)
    toggle.BackgroundColor3 = default and Color3.fromRGB(124, 92, 255) or Color3.fromRGB(60, 60, 70)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 9)

    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    local state = default
    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(.15), {
            BackgroundColor3 = state and Color3.fromRGB(124, 92, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(.15), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        callback(state)
    end)

    return holder
end

-- ============================================================
-- DISCORD BUTTON
-- ============================================================
local function makeDiscordButton(y)
    local Copy = Instance.new("TextButton", Main)
    Copy.AnchorPoint = Vector2.new(.5, 0)
    Copy.Position = UDim2.new(.5, 0, 0, y)
    Copy.Size = UDim2.fromOffset(330, 44)
    Copy.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    Copy.BorderSizePixel = 0
    Copy.AutoButtonColor = false
    Copy.Text = ""
    Instance.new("UICorner", Copy).CornerRadius = UDim.new(0, 11)

    local DiscordIcon = Instance.new("ImageLabel", Copy)
    DiscordIcon.AnchorPoint = Vector2.new(0, .5)
    DiscordIcon.Position = UDim2.new(0, 70, .5, 0)
    DiscordIcon.Size = UDim2.fromOffset(26, 26)
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.Image = "rbxassetid://10367063084"
    DiscordIcon.ScaleType = Enum.ScaleType.Fit

    local CopyText = Instance.new("TextLabel", Copy)
    CopyText.Position = UDim2.fromOffset(108, 0)
    CopyText.Size = UDim2.new(1, -128, 1, 0)
    CopyText.BackgroundTransparency = 1
    CopyText.Text = "JOIN DISCORD"
    CopyText.TextColor3 = Color3.new(1, 1, 1)
    CopyText.Font = Enum.Font.GothamBlack
    CopyText.TextSize = 15
    CopyText.TextXAlignment = Enum.TextXAlignment.Left

    local DISCORD = "https://discord.gg/bluezygpt"

    Copy.MouseEnter:Connect(function()
        TweenService:Create(Copy, TweenInfo.new(.12), { BackgroundColor3 = Color3.fromRGB(100, 112, 255) }):Play()
    end)
    Copy.MouseLeave:Connect(function()
        TweenService:Create(Copy, TweenInfo.new(.12), { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }):Play()
    end)
    Copy.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD)
        elseif toclipboard then
            toclipboard(DISCORD)
        end
        CopyText.Text = "COPIED!"
        task.delay(1, function()
            if CopyText.Parent then CopyText.Text = "JOIN DISCORD" end
        end)
    end)

    return Copy
end

-- Build toggles
makeToggle("Auto Steal Eggs", 110, false, function(s) states.autoSteal = s end)
makeToggle("Anti-AFK", 152, true, function(s) states.antiAfk = s end)
makeToggle("Anti-Lag (FPS Boost)", 194, false, function(s) states.antiLag = s end)

-- Server Hop button
local HopBtn = Instance.new("TextButton", Main)
HopBtn.Position = UDim2.fromOffset(28, 240)
HopBtn.Size = UDim2.new(1, -56, 0, 34)
HopBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
HopBtn.BorderSizePixel = 0
HopBtn.Text = "Server Hop (1-Player Server)"
HopBtn.TextColor3 = Color3.fromRGB(235, 235, 245)
HopBtn.Font = Enum.Font.GothamBold
HopBtn.TextSize = 13
HopBtn.AutoButtonColor = false
Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0, 8)

-- Discord button
makeDiscordButton(290)

-- ============================================================
-- CLOSE BUTTON
-- ============================================================
Close.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(.2), { GroupTransparency = 1 }):Play()
    TweenService:Create(scale, TweenInfo.new(.2), { Scale = .92 }):Play()
    task.wait(.22)
    GUI:Destroy()
end)

-- ============================================================
-- OPEN ANIMATION
-- ============================================================
TweenService:Create(Main, TweenInfo.new(.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    GroupTransparency = 0
}):Play()
TweenService:Create(scale, TweenInfo.new(.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Scale = 1
}):Play()

-- ============================================================
-- FEATURE LOGIC
-- ============================================================
local function getChar()
    local char = P.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

-- Anti-AFK
do
    local VU = game:GetService("VirtualUser")
    P.Idled:Connect(function()
        if states.antiAfk then
            pcall(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
                task.wait(.3)
                VU:Button1Down(Vector2.new())
                task.wait(.3)
                VU:Button1Up(Vector2.new())
            end)
        end
    end)
end

-- Anti-Lag
local lagCullConn
local function applyAntiLag(state)
    if state then
        local Lighting = game:GetService("Lighting")
        pcall(function() Lighting.GlobalShadows = false end)
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        for _, m in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if m:IsA("Texture") or m:IsA("Decal") then
                    m.Transparency = 1
                elseif m:IsA("ParticleEmitter") or m:IsA("Trail") or m:IsA("Sparkles") or m:IsA("Smoke") or m:IsA("Fire") then
                    m.Enabled = false
                    m.Rate = 0
                elseif m:IsA("BasePart") then
                    m.CastShadow = false
                    if m.Material == Enum.Material.Neon or m.Material == Enum.Material.Glass then
                        m.Material = Enum.Material.SmoothPlastic
                    end
                end
            end)
        end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    else
        if lagCullConn then lagCullConn:Disconnect() lagCullConn = nil end
    end
end

-- Track anti-lag state changes
task.spawn(function()
    local prevState = false
    while task.wait(1) do
        if states.antiLag ~= prevState then
            prevState = states.antiLag
            applyAntiLag(prevState)
        end
    end
end)

-- Auto Steal — uses verified SAE internals
local stealThread
local function safeRequire(getMod)
    local ok, m = pcall(getMod)
    return ok and m or nil
end

local EggState_m = safeRequire(function() return require(ReplicatedStorage.Client.EggState) end)
local PlotState_m = safeRequire(function() return require(ReplicatedStorage.Client.PlotState) end)
local PlotCmds_m = safeRequire(function() return require(ReplicatedStorage.Client.PlotCmds) end)
local AreaEggSlotIdentity_m = ReplicatedStorage:FindFirstChild("Shared") and
    safeRequire(function() return require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity) end) or nil

local function getSafeZone()
    if PlotState_m then
        local ok, plot = pcall(PlotState_m.ResolvePlot, P)
        if ok and type(plot) == "table" and plot.PetArea and plot.PetArea:IsA("BasePart") then
            return plot.PetArea.Position
        end
    end
    local areas = Workspace:FindFirstChild("__OBJECTS")
    areas = areas and areas:FindFirstChild("Areas")
    local sep = areas and areas:FindFirstChild("SeparationLine")
    if sep and sep:IsA("BasePart") then
        return sep.Position - sep.CFrame.LookVector * 10
    end
    return nil
end

local function isCarrying()
    if not EggState_m or not EggState_m.ReadFieldEggs then return false end
    local ok, rows = pcall(function() return EggState_m.ReadFieldEggs() end)
    if not ok or type(rows) ~= "table" then return false end
    for _, r in ipairs(rows.Records or {}) do
        if r.State == "Carried" and r.CarrierUserId == P.UserId then return true end
    end
    return false
end

local function findTarget(root)
    if not EggState_m or not EggState_m.ReadFieldEggs then return nil end
    local ok, rows = pcall(function() return EggState_m.ReadFieldEggs() end)
    if not ok or type(rows) ~= "table" then return nil end
    local best, bestD = nil, math.huge
    for _, r in ipairs(rows.Records or {}) do
        if (r.State == "Slot" or r.State == "Dropped") and r.BottomCFrame then
            local d = (r.BottomCFrame.Position - root.Position).Magnitude
            if d < bestD then bestD, best = d, r end
        end
    end
    return best
end

local function carryEgg(rec)
    if not EggState_m or not EggState_m.CarryFieldEgg then return false end
    local slotKey
    if AreaEggSlotIdentity_m and rec.Uid then
        local ok, k = pcall(function() return AreaEggSlotIdentity_m.SlotKey(rec.AreaId, rec.NestId) end)
        if ok then slotKey = k end
    end
    pcall(function() P:SetAttribute("AreaId", rec.AreaId) end)
    task.wait(.15)
    local ok = pcall(function() return EggState_m.CarryFieldEgg(rec.Uid, slotKey) end)
    return ok
end

local function moveTo(target, opts)
    opts = opts or {}
    local _, hum, root = getChar()
    if not (hum and root) or hum.Health <= 0 then return false end
    local speed = math.clamp(opts.speed or 200, 16, 300)
    pcall(function() hum.WalkSpeed = speed end)
    local timeout = ((target - root.Position).Magnitude / speed) + 8
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        _, hum, root = getChar()
        if not (hum and root) or hum.Health <= 0 then break end
        if opts.onStep and opts.onStep() then
            pcall(function() hum:MoveTo(root.Position) end)
            return false
        end
        local delta = target - root.Position
        if Vector3.new(delta.X, 0, delta.Z).Magnitude < 5 then return true end
        local dir = delta.Unit
        pcall(function() hum:MoveTo(target) end)
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, root.AssemblyLinearVelocity.Y, dir.Z * speed)
        end)
        task.wait(.03)
    end
    return false
end

local function startStealLoop()
    if stealThread then return end
    if not EggState_m then
        print("[Rynix] EggState module not loaded - rejoin game")
        return
    end
    stealThread = task.spawn(function()
        while states.autoSteal do
            pcall(function()
                local _, _, root = getChar()
                if not root then return end
                if isCarrying() then
                    local sz = getSafeZone()
                    if sz then
                        pcall(function()
                            local hum = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum:UnequipTools() end
                        end)
                        local dropped = false
                        moveTo(sz, {
                            speed = 250,
                            onStep = function()
                                if not isCarrying() then dropped = true return true end
                                return false
                            end,
                        })
                        if dropped or not isCarrying() then
                            task.wait(.3)
                        else
                            local t0 = os.clock()
                            while os.clock() - t0 < 20 do
                                if not isCarrying() then break end
                                task.wait(.1)
                            end
                            if not isCarrying() and EggState_m.DropFieldEgg then
                                pcall(function() EggState_m.DropFieldEgg(nil) end)
                            end
                            task.wait(.5)
                        end
                    end
                else
                    local target = findTarget(root)
                    if target then
                        if moveTo(target.BottomCFrame.Position, { speed = 250 }) then
                            carryEgg(target)
                        end
                    else
                        task.wait(1.5)
                    end
                end
            end)
            task.wait(.1)
        end
        stealThread = nil
    end)
end

task.spawn(function()
    local prev = false
    while task.wait(.5) do
        if states.autoSteal and not prev then
            prev = true
            startStealLoop()
        elseif not states.autoSteal and prev then
            prev = false
        end
    end
end)

-- Server Hop
HopBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local placeId = game.PlaceId
        local targetJobId
        local cursor = ""
        for _ = 1, 10 do
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100&cursor=" .. cursor
            local body
            if request then
                body = request({ Url = url, Method = "GET" }).Body
            else
                body = game:HttpGet(url)
            end
            local data = HttpService:JSONDecode(body)
            if not data or not data.data then break end
            table.sort(data.data, function(a, b) return a.playing < b.playing end)
            for _, s in ipairs(data.data) do
                if s.playing == 1 then targetJobId = s.id break end
            end
            if targetJobId then break end
            if data.data[1] and data.data[1].playing <= 3 then
                targetJobId = data.data[1].id
                break
            end
            cursor = data.nextPageCursor
            if not cursor or cursor == "" then break end
            task.wait(.3)
        end
        if targetJobId then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, targetJobId, P)
            end)
        end
    end)
end)

print("[Rynix] Hub loaded - placeId=" .. tostring(game.PlaceId))
