-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/GRPGaming/Key-System/refs/heads/Xycer-Hub-Script/ZusumeLib(Slider)'))()

-- Create window
local Window = OrionLib:MakeWindow({
    Name = "AlvaroScript | Tower Of Hell Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "ASTOH"
})

-- Tabs
local BypassTab = Window:MakeTab({ Name = "Bypass", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local ModsTab = Window:MakeTab({ Name = "Player Editor", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- Variables
local originalWalkSpeed, originalJumpPower = 16, 50
local speedEnabled, jumpEnabled = false, false
local currentSpeedValue, currentJumpValue = 50, 100
local isBypassed = false
local espEnabled = false
local espObjects = {}
local godmodeEnabled, noclipEnabled = false, false

-- Smooth ESP Functions
local function createESP(target)
    if espObjects[target] then return end
    local char = target.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = hrp
    box.Size = hrp.Size + Vector3.new(2, 2, 2)
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 1
    box.AdornCullingMode = Enum.AdornCullingMode.Never
    box.Parent = hrp

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPName"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = hrp
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = hrp

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = target.Name
    nameLabel.TextColor3 = Color3.new(0, 1, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextTransparency = 1
    nameLabel.Parent = billboard

    -- Animate ESP in
    TweenService:Create(box, TweenInfo.new(0.5), { Transparency = 0.5 }):Play()
    TweenService:Create(nameLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()

    espObjects[target] = { box = box, name = billboard, label = nameLabel }
end

local function removeESP(target)
    local data = espObjects[target]
    if data then
        TweenService:Create(data.box, TweenInfo.new(0.5), { Transparency = 1 }):Play()
        TweenService:Create(data.label, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
        task.delay(0.5, function()
            if data.box and data.box.Parent then data.box:Destroy() end
            if data.name and data.name.Parent then data.name:Destroy() end
        end)
        espObjects[target] = nil
    end
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            if espEnabled then
                createESP(plr)
            else
                removeESP(plr)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then createESP(plr) end
    end)
end)

MainTab:AddButton({
    Name = "Toggle Player ESP",
    Callback = function()
        espEnabled = not espEnabled
        updateESP()
        OrionLib:MakeNotification({
            Name = "ESP",
            Content = espEnabled and "Enabled (Smooth)" or "Disabled",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

-- Bypass
BypassTab:AddButton({
    Name = "Bypass Anti-Cheat",
    Callback = function()
        for _, v in pairs(player:WaitForChild("PlayerScripts"):GetDescendants()) do
            if v:IsA("LocalScript") and not v:IsDescendantOf(script) then
                local name = v.Name:lower()
                if name:find("anti") or name:find("cheat") or name:find("kick") or name:find("ban") then
                    pcall(function()
                        v.Disabled = true
                    end)
                end
            end
        end
        isBypassed = true
        OrionLib:MakeNotification({
            Name = "Bypass Status",
            Content = "Potential Anti-Cheat scripts disabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

local statusLabel = BypassTab:AddLabel("Bypass Status: Not Bypassed")
task.spawn(function()
    while true do
        task.wait(1)
        statusLabel:Set("Bypass Status: " .. (isBypassed and "Bypassed ✅" or "Not Bypassed ❌"))
    end
end)

-- Finish TP
local function getFinishPart()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("finish") then
            return v
        end
    end
end

MainTab:AddButton({
    Name = "Teleport to Finish (Instant)",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local finish = getFinishPart()
        if hrp and finish then
            hrp.CFrame = finish.CFrame + Vector3.new(0, 3, 0)
            OrionLib:MakeNotification({
                Name = "Teleported!",
                Content = "Instant teleport complete.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Error!",
                Content = "Finish part not found.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Speed/Jump Hacks
local function applyCharacterMods()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedEnabled and currentSpeedValue or originalWalkSpeed
        humanoid.JumpPower = jumpEnabled and currentJumpValue or originalJumpPower
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyCharacterMods()
end)

ModsTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(enabled)
        speedEnabled = enabled
        applyCharacterMods()
        OrionLib:MakeNotification({
            Name = "Speed Hack",
            Content = enabled and "Enabled!" or "Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

ModsTab:AddSlider({
    Name = "WalkSpeed Value",
    Min = 16, Max = 200, Default = 50, Increment = 1,
    ValueName = "Speed",
    Callback = function(val)
        currentSpeedValue = val
        if speedEnabled then applyCharacterMods() end
    end
})

ModsTab:AddToggle({
    Name = "Jump Hack",
    Default = false,
    Callback = function(enabled)
        jumpEnabled = enabled
        applyCharacterMods()
        OrionLib:MakeNotification({
            Name = "Jump Hack",
            Content = enabled and "Enabled!" or "Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

ModsTab:AddSlider({
    Name = "JumpPower Value",
    Min = 50, Max = 500, Default = 100, Increment = 5,
    ValueName = "Power",
    Callback = function(val)
        currentJumpValue = val
        if jumpEnabled then applyCharacterMods() end
    end
})

-- Godmode
local function toggleGodmode(enable)
    godmodeEnabled = enable
    local function apply()
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            hum:GetPropertyChangedSignal("Health"):Connect(function()
                if godmodeEnabled then hum.Health = hum.MaxHealth end
            end)
        end
    end
    apply()
    player.CharacterAdded:Connect(function()
        if godmodeEnabled then task.wait(0.5) apply() end
    end)
end

ModsTab:AddToggle({
    Name = "Godmode",
    Default = false,
    Callback = function(state)
        toggleGodmode(state)
        OrionLib:MakeNotification({
            Name = "Godmode",
            Content = state and "Enabled" or "Disabled",
            Time = 2
        })
    end
})

-- Noclip
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

ModsTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        OrionLib:MakeNotification({
            Name = "Noclip",
            Content = state and "Enabled" or "Disabled",
            Time = 2
        })
    end
})

-- Init
OrionLib:Init()
